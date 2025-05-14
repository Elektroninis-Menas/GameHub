extends GutTest

# Reference to the Go class script
var GoClass = load("res://Unit_testing/GoGame/GO.gd")
var game = null


func before_each():
	game = GoClass.new()


func after_each():
	game = null


func test_initial_state():
	assert_eq(game.occupied_cells.size(), 0, "Board should be empty initially")
	assert_eq(game.is_white_turn, false, "Black should go first")
	assert_eq(game.white_captures, 0, "White should have no captures initially")
	assert_eq(game.black_captures, 0, "Black should have no captures initially")
	assert_eq(game.consecutive_passes, 0, "Should be no passes initially")


func test_is_valid_position():
	assert_true(game.is_valid_position(Vector2i(0, 0)), "Origin should be valid")
	assert_true(game.is_valid_position(Vector2i(9, 9)), "Max coordinate should be valid")
	assert_false(game.is_valid_position(Vector2i(-1, 5)), "Negative x should be invalid")
	assert_false(game.is_valid_position(Vector2i(5, -1)), "Negative y should be invalid")
	assert_false(game.is_valid_position(Vector2i(10, 5)), "x >= GRID_SIZE should be invalid")
	assert_false(game.is_valid_position(Vector2i(5, 10)), "y >= GRID_SIZE should be invalid")


func test_get_adjacent_cells():
	var center = Vector2i(5, 5)
	var edges = game.get_adjacent_cells(center)
	assert_eq(edges.size(), 4, "Center position should have 4 adjacent cells")
	assert_true(edges.has(Vector2i(4, 5)), "Left edge missing")
	assert_true(edges.has(Vector2i(6, 5)), "Right edge missing")
	assert_true(edges.has(Vector2i(5, 4)), "Top edge missing")
	assert_true(edges.has(Vector2i(5, 6)), "Bottom edge missing")

	var corner = Vector2i(0, 0)
	edges = game.get_adjacent_cells(corner)
	assert_eq(edges.size(), 2, "Corner position should have 2 adjacent cells")
	assert_true(edges.has(Vector2i(1, 0)), "Right edge missing from corner")
	assert_true(edges.has(Vector2i(0, 1)), "Bottom edge missing from corner")


func test_switch_turn():
	assert_eq(game.is_white_turn, false, "Initial turn should be black")
	game.switch_turn()
	assert_eq(game.is_white_turn, true, "Turn should switch to white")
	game.switch_turn()
	assert_eq(game.is_white_turn, false, "Turn should switch back to black")


func test_pass_turn():
	assert_eq(game.consecutive_passes, 0, "Should start with 0 passes")

	var game_ended = game.pass_turn()
	assert_false(game_ended, "Game shouldn't end after one pass")
	assert_eq(game.consecutive_passes, 1, "Should have 1 pass")
	assert_true(game.last_player_passed, "last_player_passed should be true")
	assert_eq(game.is_white_turn, true, "Turn should switch to white after pass")

	game_ended = game.pass_turn()
	assert_true(game_ended, "Game should end after two consecutive passes")
	assert_eq(game.consecutive_passes, 2, "Should have 2 passes")


func test_place_stone_basic():
	var pos = Vector2i(3, 3)
	var result = game.place_stone(pos)

	assert_true(result["success"], "Stone placement should succeed")
	assert_eq(result["captures"], 0, "No stones should be captured")
	assert_true(game.occupied_cells.has(pos), "Position should be occupied")
	assert_eq(game.occupied_cells[pos], false, "Stone should be black")
	assert_eq(game.is_white_turn, true, "Turn should switch to white")


func test_place_stone_occupied():
	var pos = Vector2i(3, 3)
	game.place_stone(pos)  # Place first stone

	var result = game.place_stone(pos)  # Try to place on same spot
	assert_false(result["success"], "Cannot place stone on occupied position")
	assert_eq(game.occupied_cells[pos], false, "Stone should remain the original color")


func test_capture_single_stone():
	# Set up a capture scenario:
	# . . . . .
	# . B W . .
	# . W . W .
	# . B W . .
	# . . . . .
	# Black to play at the center to capture

	game.occupied_cells[Vector2i(1, 1)] = false  # B
	game.occupied_cells[Vector2i(2, 1)] = true  # W
	game.occupied_cells[Vector2i(1, 2)] = true  # W
	game.occupied_cells[Vector2i(3, 2)] = true  # W
	game.occupied_cells[Vector2i(1, 3)] = false  # B
	game.occupied_cells[Vector2i(2, 3)] = true  # W

	var center = Vector2i(2, 2)
	var result = game.place_stone(center)

	assert_true(result["success"], "Capture move should succeed")
	assert_eq(result["captures"], 4, "Should capture 4 white stones")
	assert_eq(game.black_captures, 4, "Black should have 4 captures")
	assert_false(game.occupied_cells.has(Vector2i(2, 1)), "Top stone should be captured")
	assert_false(game.occupied_cells.has(Vector2i(1, 2)), "Left stone should be captured")
	assert_false(game.occupied_cells.has(Vector2i(3, 2)), "Right stone should be captured")
	assert_false(game.occupied_cells.has(Vector2i(2, 3)), "Bottom stone should be captured")


func test_suicide_move():
	# Set up a suicide scenario:
	# . W . .
	# W . W .
	# . W . .
	# . . . .
	# White to play at the center (suicide move)

	game.occupied_cells[Vector2i(1, 0)] = true  # W
	game.occupied_cells[Vector2i(0, 1)] = true  # W
	game.occupied_cells[Vector2i(2, 1)] = true  # W
	game.occupied_cells[Vector2i(1, 2)] = true  # W
	game.is_white_turn = true  # White's turn

	var center = Vector2i(1, 1)
	var result = game.place_stone(center)

	assert_false(result["success"], "Suicide move should be illegal")
	assert_false(game.occupied_cells.has(center), "Stone should not be placed")


func test_legal_suicide_with_capture():
	# Set up a scenario where suicide is allowed because it captures:
	# . B . .
	# B W B .
	# . B . .
	# . . . .
	# White to play at the center (captures all black stones)

	game.occupied_cells[Vector2i(1, 0)] = false  # B
	game.occupied_cells[Vector2i(0, 1)] = false  # B
	game.occupied_cells[Vector2i(1, 1)] = true  # W
	game.occupied_cells[Vector2i(2, 1)] = false  # B
	game.occupied_cells[Vector2i(1, 2)] = false  # B
	game.is_white_turn = false  # Black's turn

	var result = game.place_stone(Vector2i(1, 1))  # Try to replace the white stone

	assert_true(result["success"], "Capturing move should be legal")
	assert_eq(game.black_captures, 1, "Black should capture 1 white stone")


func test_ko_rule():
	# TODO: Add ko rule implementation and test
	pass_test("Ko rule not implemented yet")


func test_reset_game():
	# Place some stones and make captures
	game.place_stone(Vector2i(1, 1))
	game.place_stone(Vector2i(1, 2))
	game.place_stone(Vector2i(2, 1))
	game.consecutive_passes = 1

	game.reset_game()

	assert_eq(game.occupied_cells.size(), 0, "Board should be empty after reset")
	assert_eq(game.white_captures, 0, "White captures should be reset")
	assert_eq(game.black_captures, 0, "Black captures should be reset")
	assert_eq(game.is_white_turn, false, "Turn should reset to black")
	assert_eq(game.consecutive_passes, 0, "Passes should be reset")


func test_find_territory():
	# Set up a simple territory scenario:
	# B B B . .
	# B . B . .
	# B B B . .
	# . . . . .
	# . . . . .
	# Black has surrounded 1 empty point

	game.occupied_cells[Vector2i(0, 0)] = false  # B
	game.occupied_cells[Vector2i(1, 0)] = false  # B
	game.occupied_cells[Vector2i(2, 0)] = false  # B
	game.occupied_cells[Vector2i(0, 1)] = false  # B
	game.occupied_cells[Vector2i(2, 1)] = false  # B
	game.occupied_cells[Vector2i(0, 2)] = false  # B
	game.occupied_cells[Vector2i(1, 2)] = false  # B
	game.occupied_cells[Vector2i(2, 2)] = false  # B

	var territory = game.find_territory()

	assert_eq(territory["black_territory"], 1, "Black should have 1 territory point")
	assert_eq(territory["white_territory"], 0, "White should have 0 territory points")


func test_calculate_score():
	# Set up a simple game state with captures and territory
	game.black_captures = 5  # Black captured 5 white stones
	game.white_captures = 3  # White captured 3 black stones

	# Add territory (using same setup as test_find_territory)
	game.occupied_cells[Vector2i(0, 0)] = false  # B
	game.occupied_cells[Vector2i(1, 0)] = false  # B
	game.occupied_cells[Vector2i(2, 0)] = false  # B
	game.occupied_cells[Vector2i(0, 1)] = false  # B
	game.occupied_cells[Vector2i(2, 1)] = false  # B
	game.occupied_cells[Vector2i(0, 2)] = false  # B
	game.occupied_cells[Vector2i(1, 2)] = false  # B
	game.occupied_cells[Vector2i(2, 2)] = false  # B

	# Add white territory
	game.occupied_cells[Vector2i(7, 7)] = true  # W
	game.occupied_cells[Vector2i(8, 7)] = true  # W
	game.occupied_cells[Vector2i(9, 7)] = true  # W
	game.occupied_cells[Vector2i(7, 8)] = true  # W
	game.occupied_cells[Vector2i(9, 8)] = true  # W
	game.occupied_cells[Vector2i(7, 9)] = true  # W
	game.occupied_cells[Vector2i(8, 9)] = true  # W
	game.occupied_cells[Vector2i(9, 9)] = true  # W

	var score = game.calculate_score()

	assert_eq(score["black_territory"], 1, "Black should have 1 territory point")
	assert_eq(score["white_territory"], 1, "White should have 1 territory point")
	assert_eq(score["black_score"], 6, "Black score should be 5 captures + 1 territory = 6")
	assert_eq(score["white_score"], 4, "White score should be 3 captures + 1 territory = 4")
