# test_tetris.gd
extends GutTest

var tetris_instance: Tetris
var default_width = 10
var default_height = 20

func before_each():
	tetris_instance = Tetris.new(default_height, default_width)

func test_tetris_initialization():
	assert_eq(tetris_instance.score, 0, "Score should be 0 on init") 
	assert_eq(tetris_instance.lines_broken, 0, "Lines broken should be 0 on init") 
	assert_eq(tetris_instance.pieces_placed, 0, "Pieces placed should be 0 on init") 
	assert_eq(tetris_instance.height, default_height, "Height should be set by constructor") 
	assert_eq(tetris_instance.width, default_width, "Width should be set by constructor") 
	assert_true(is_instance_valid(tetris_instance.next_figure), "Next figure should be a valid Figure instance") 
	assert_eq(tetris_instance.field.size(), default_height, "Field should have correct number of rows") 
	if default_height > 0:
		assert_eq(tetris_instance.field[0].size(), default_width, "Field rows should have correct number of columns") 
		assert_eq(tetris_instance.field[0][0], 0, "Field cells should be initialized to 0") 
	gut.p("Tetris initialized correctly")

func test_tetris_new_figure():
	var initial_next_figure = tetris_instance.next_figure
	var initial_pieces_placed = tetris_instance.pieces_placed

	# Test signal emission
	await wait_for_signal(tetris_instance.preview_figure, 0.5)
	
	tetris_instance.new_figure() 
	
	assert_signal_emitted(tetris_instance, "preview_figure", "preview_figure signal should be emitted") 
	assert_eq(tetris_instance.figure, initial_next_figure, "Current figure should be the previous next_figure") 
	assert_true(is_instance_valid(tetris_instance.next_figure), "A new next_figure should be generated") 
	assert_ne(tetris_instance.next_figure, initial_next_figure, "New next_figure should be a different instance") 
	assert_eq(tetris_instance.pieces_placed, initial_pieces_placed + 1, "Pieces placed should be incremented") 
	gut.p("new_figure method works as expected")

func test_tetris_intersects_boundary():
	tetris_instance.new_figure() # Get a figure
	tetris_instance.figure.type = Figure.TetraminoType.I # Use a predictable 'I' shape
	tetris_instance.figure.rotation = 0 # [[1, 5, 9, 13]] relative to 4x4, so it's a vertical bar (col 1)
	
	# Test intersection with bottom
	tetris_instance.figure.x = 0
	tetris_instance.figure.y = tetris_instance.height - 1 # Figure's lowest block is at y + 3
	# For I (0) -> blocks are at relative y 0,1,2,3. If figure.y = height-1, 
	# lowest block (y=3) is at height-1+3 = height+2, which is out of bounds.
	# Need to be careful with figure.image() which are indices in 4x4 grid.
	# image() for I,0 is [1,5,9,13] -> (0,1), (1,1), (2,1), (3,1) in 4x4
	# If figure.y = height - 4 (lowest part of 4x4 box hits bottom row)
	# cell (3,1) which is fig.y+3, fig.x+1
	tetris_instance.figure.y = tetris_instance.height - 3 # Should intersect if piece occupies row 3 of its 4x4 box
	assert_true(tetris_instance.intersects(), "Should intersect with bottom boundary") # [cite: 5]

	# Test intersection with right wall
	tetris_instance.figure.y = 0
	tetris_instance.figure.x = tetris_instance.width - 1 # Figure's rightmost block is at x + 1
	assert_true(tetris_instance.intersects(), "Should intersect with right boundary") # [cite: 5]

	# Test intersection with left wall
	tetris_instance.figure.y = 0
	tetris_instance.figure.x = -1 # Figure's leftmost block is at x (if image contains col 0)
	# For I (0), it uses column 1 of its 4x4 grid, so x= -1 means field_x = -1 + 1 = 0 (ok)
	# x = -2 means field_x = -2 + 1 = -1 (intersects)
	tetris_instance.figure.x = -2 
	assert_true(tetris_instance.intersects(), "Should intersect with left boundary") # [cite: 5]

	# Test no intersection in valid space
	tetris_instance.figure.x = tetris_instance.width / 2
	tetris_instance.figure.y = 0
	assert_false(tetris_instance.intersects(), "Should not intersect in a valid open space") # [cite: 5]
	gut.p("Boundary intersection checks work")


func test_tetris_intersects_with_field_blocks():
	tetris_instance.new_figure()
	tetris_instance.figure.type = Figure.TetraminoType.O # O-Shape: [[1,2,5,6]]
	tetris_instance.figure.rotation = 0
	tetris_instance.figure.x = 0
	tetris_instance.figure.y = 0
	
	# Place a block where the 'O' shape would land
	# O shape uses relative (0,1), (0,2), (1,1), (1,2)
	# If figure is at (0,0), this means field cells (0,1), (0,2), (1,1), (1,2)
	tetris_instance.field[1][1] = 1 # Put a block at (1,1)
	assert_true(tetris_instance.intersects(), "Should intersect with a block in the field") # [cite: 5]

	tetris_instance.field[1][1] = 0 # Clear the block
	assert_false(tetris_instance.intersects(), "Should not intersect if field is clear") # [cite: 5]
	gut.p("Field block intersection checks work")


func test_tetris_break_lines_single():
	# Setup field with one completable line
	# Line at y=default_height-1
	for c in range(tetris_instance.width):
		tetris_instance.field[default_height-1][c] = 1
	
	var initial_score = tetris_instance.score
	var initial_lines_broken = tetris_instance.lines_broken
	var level = (initial_lines_broken / 10) as int
	var expected_score_increase = 40 * (level + 1)

	await wait_for_signal(tetris_instance.line_broken, 0.5)
	
	tetris_instance.break_lines() 
	
	assert_signal_emitted(tetris_instance, "line_broken", "line_broken signal should be emitted for single line") 
	assert_eq(tetris_instance.lines_broken, initial_lines_broken + 1, "Lines broken should increment by 1") 
	assert_eq(tetris_instance.score, initial_score + expected_score_increase, "Score should increase correctly for 1 line") 
	
	# Check if line was cleared and lines above shifted down
	var all_zero = true
	for c in range(tetris_instance.width):
		if tetris_instance.field[default_height-1][c] != 0:
			all_zero = false
			break
	assert_true(all_zero, "Cleared line should be all zeros") 
	gut.p("Single line break works")


func test_tetris_break_lines_tetris(): # 4 lines
	# Setup field for a Tetris
	for r_offset in range(4):
		var row_idx = default_height - 1 - r_offset
		for c in range(tetris_instance.width):
			tetris_instance.field[row_idx][c] = 1 # Fill bottom 4 lines
	
	var initial_score = tetris_instance.score
	var initial_lines_broken = tetris_instance.lines_broken
	var level = (initial_lines_broken / 10) as int
	var expected_score_increase = 1200 * (level + 1)

	await wait_for_signal(tetris_instance.line_broken, 0.5)

	tetris_instance.break_lines() 

	assert_signal_emitted(tetris_instance, "line_broken", "line_broken signal should be emitted for tetris") 
	assert_eq(tetris_instance.lines_broken, initial_lines_broken + 4, "Lines broken should increment by 4 for Tetris") 
	assert_eq(tetris_instance.score, initial_score + expected_score_increase, "Score should increase correctly for 4 lines (Tetris)") 
	gut.p("Tetris (4 lines) break works")

func test_tetris_level_change_signal():
	tetris_instance.lines_broken = 9 # About to complete 10th line
	# Fill one line
	for c in range(tetris_instance.width):
		tetris_instance.field[default_height-1][c] = 1
	
	await wait_for_signal(tetris_instance.level_change, 0.5)
	tetris_instance.break_lines() 

	assert_signal_emitted_with_parameters(tetris_instance, "level_change", [1])
	#assert_signal_emitted(tetris_instance, "line_broken", "level_change signal should be emitted with new level 1") 
	assert_eq(tetris_instance.lines_broken, 10, "Lines broken should be 10") 
	gut.p("Level change signal works")

# Mock Figure for go_side, go_down, rotate, freeze to control its state
# For more complex interactions (like freeze calling new_figure, break_lines),
# you might need more sophisticated mocking or partial mocks if GUT supports them easily.
# Or test those parts more integratedly.

func test_tetris_go_side_no_intersection():
	tetris_instance.new_figure()
	tetris_instance.figure.x = default_width / 2
	tetris_instance.figure.y = 0
	
	var initial_x = tetris_instance.figure.x
	tetris_instance.go_side(1) # Move right 
	assert_eq(tetris_instance.figure.x, initial_x + 1, "Figure should move right if no intersection") 

	initial_x = tetris_instance.figure.x
	tetris_instance.go_side(-1) # Move left 
	assert_eq(tetris_instance.figure.x, initial_x - 1, "Figure should move left if no intersection") 
	gut.p("go_side without intersection works")

func test_tetris_go_side_with_intersection():
	tetris_instance.new_figure()
	tetris_instance.figure.type = Figure.TetraminoType.I # Vertical bar
	tetris_instance.figure.rotation = 0 
	tetris_instance.figure.y = 0
	# Position it right next to the right wall (assuming I is 1 block wide in its 4x4 grid's column 1)
	# A figure at x will occupy field cells x + image_col_offset
	# For I (rot 0), image uses col 1. So if x = width - 2, it occupies width-2+1 = width-1.
	tetris_instance.figure.x = default_width - 2 
	
	var initial_x = tetris_instance.figure.x
	tetris_instance.go_side(1) # Try to move right into wall 
	assert_eq(tetris_instance.figure.x, initial_x, "Figure should not move right if it causes intersection") 
	gut.p("go_side with intersection works")

func test_tetris_rotate_no_intersection():
	tetris_instance.new_figure()
	tetris_instance.figure.type = Figure.TetraminoType.T # T has multiple rotations
	tetris_instance.figure.x = default_width / 2
	tetris_instance.figure.y = 0
	
	var initial_rotation = tetris_instance.figure.rotation
	var expected_rotations = len(tetris_instance.figure.figures[tetris_instance.figure.type])
	tetris_instance.rotate() 
	assert_eq(tetris_instance.figure.rotation, (initial_rotation + 1) % expected_rotations, "Figure should rotate if no intersection") 
	gut.p("Rotate without intersection works")

func test_tetris_rotate_with_intersection():
	tetris_instance.new_figure()
	tetris_instance.figure.type = Figure.TetraminoType.I # I shape
	tetris_instance.figure.rotation = 0 # Vertical
	tetris_instance.figure.x = 0 
	tetris_instance.figure.y = 0
	# Place a block that would intersect if 'I' rotates to horizontal
	# I vertical (rot 0): [1,5,9,13] -> (0,1), (1,1), (2,1), (3,1)
	# I horizontal (rot 1): [4,5,6,7] -> (1,0), (1,1), (1,2), (1,3)
	# If figure is at (0,0), horizontal I would occupy (1,0), (1,1), (1,2), (1,3) in field
	tetris_instance.field[1][3] = 1 # Block at (1,3) which I horizontal would hit
	
	var initial_rotation = tetris_instance.figure.rotation
	tetris_instance.rotate() 
	assert_eq(tetris_instance.figure.rotation, initial_rotation, "Figure should not rotate if it causes intersection") 
	tetris_instance.field[1][3] = 0 # Clean up
	gut.p("Rotate with intersection works")

func test_tetris_go_down_no_freeze():
	tetris_instance.new_figure()
	tetris_instance.figure.x = default_width / 2
	tetris_instance.figure.y = 0 # Start at top
	
	var initial_y = tetris_instance.figure.y
	tetris_instance.go_down() 
	assert_eq(tetris_instance.figure.y, initial_y + 1, "Figure should move down by 1") 
	gut.p("go_down without freeze works")

# Test freeze() is harder as it calls break_lines and new_figure which have side effects
# and signals. You might need to stub/double those methods or test outcomes carefully.
func test_tetris_freeze_basic_placement():
	tetris_instance.new_figure()
	tetris_instance.figure.type = Figure.TetraminoType.O # O-shape [[1,2,5,6]]
	tetris_instance.figure.rotation = 0
	var fig_x = default_width / 2 - 1
	var fig_y = default_height - 2 # Place it so it rests on the bottom
	tetris_instance.figure.x = fig_x
	tetris_instance.figure.y = fig_y
	
	# Spy on signals from methods called by freeze
	await wait_for_signal(tetris_instance.game_over, 0.1)
	await wait_for_signal(tetris_instance.line_broken, 0.1)

	# Manually make the current figure point to a new instance to avoid double free later
	var old_figure = tetris_instance.figure
	tetris_instance.figure = Figure.new()
	tetris_instance.figure.type = old_figure.type
	tetris_instance.figure.rotation = old_figure.rotation
	tetris_instance.figure.x = old_figure.x
	tetris_instance.figure.y = old_figure.y
	#old_figure.free()


	tetris_instance.freeze() 

	# Check field for O-shape blocks
	# O-shape: relative (0,1), (0,2), (1,1), (1,2) from Figure.figures
	var expected_type_in_field = tetris_instance.figure.type + 1 # before freeze, figure was the one being frozen
	# Actually, freeze() calls new_figure() which replaces tetris_instance.figure. 
	# We need to capture the type of the figure *before* it's frozen.
	# Let's assume O is type 4 (0-indexed: I,T,L,J,O -> O is 4). So field value should be 5.
	# This part of test needs careful setup of which figure was frozen
	# For simplicity, this check is illustrative, actual type matching would be needed.
	# One way: tetris_instance.figure in freeze() IS the figure being frozen.
	# Its type is tetris_instance.figure.type. This value + 1 is stored.
	# After new_figure(), tetris_instance.figure is different.

	# To test the field, we'd need to know the type of the figure that WAS frozen.
	# For this example, let's assume the O-shape was frozen.
	# This check is tricky because `freeze` calls `new_figure` which changes `tetris_instance.figure`
	# A better test would check `field` against the `figure_instance.type` *before* `new_figure` was called within `freeze`.
	# This might involve creating a temporary figure to hold the state or modifying the test.
	# For now, let's assert that some blocks of the *new* figure are NOT where the old one was,
	# and that some cells where the old one was ARE now filled. This is indirect.

	# Example check: one of the O-shape's expected cells
	assert_ne(tetris_instance.field[fig_y + 0][fig_x + 1], 0, "Field should be updated by freeze (cell 0,1 of O)") 
	assert_ne(tetris_instance.field[fig_y + 1][fig_x + 2], 0, "Field should be updated by freeze (cell 1,2 of O)") 
	
	assert_signal_not_emitted(tetris_instance, "game_over", "Game over should not be signaled for simple placement") 
	# line_broken_signal depends on whether the O shape completed a line, assume not here.
	gut.p("Basic freeze places blocks and creates new figure")

func test_tetris_game_over_on_immediate_intersection():
	tetris_instance.new_figure() # Figure A
	# Fill the top rows where the new figure (Figure B) would spawn after Figure A is "frozen"
	# New figures usually spawn around x = width/2 -1, y = 0
	var spawn_x = int(float(tetris_instance.width) / 2.0) - 1
	var spawn_y = 0

	# We need to know what shape the *next* figure will be to make it intersect.
	# This is hard without controlling Figure.new() randomness.
	# Alternative: Fill a wide area at the top.
	for r in range(2): # Fill top 2 rows
		for c in range(tetris_instance.width):
			tetris_instance.field[r][c] = 1 
	
	# Set current figure to something simple at bottom, ready to be frozen
	tetris_instance.figure.type = Figure.TetraminoType.O
	tetris_instance.figure.x = spawn_x
	tetris_instance.figure.y = tetris_instance.height - 2 # Near bottom

	await wait_for_signal(tetris_instance.game_over, 0.1)
	
	tetris_instance.freeze() # This will call new_figure(), new figure spawns at top and should intersect 

	assert_signal_emitted(tetris_instance, "game_over", "Game over signal should be emitted if new figure intersects immediately")

	# Clean up field
	for r in range(2):
		for c in range(tetris_instance.width):
			tetris_instance.field[r][c] = 0
	gut.p("Game over on immediate intersection works")


func test_tetris_go_space():
	tetris_instance.new_figure()
	tetris_instance.figure.type = Figure.TetraminoType.I # Vertical I
	tetris_instance.figure.rotation = 0
	tetris_instance.figure.x = default_width / 2
	tetris_instance.figure.y = 0 # Start at top

	var initial_score = tetris_instance.score
	# I-shape (rot 0) is 4 blocks high. If it drops from y=0 to y=height-4 (bottom-most position)
	# it drops (height-4) rows.
	# Score added is (rows_dropped_effectively * 2)
	# The loop in go_space increments y then checks. So it goes one step too far.
	# Expected final y: height - 4 (assuming I is 4 units tall and field indices are 0 to height-1)
	var expected_final_y = default_height - 4 
	var cells_dropped = expected_final_y - tetris_instance.figure.y 
	var expected_score_increase = cells_dropped * 2
	
	# go_space calls freeze, which calls new_figure, break_lines. This makes isolated testing hard.
	# For a focused test of go_space's drop and score part, you might need to mock freeze.
	# Assuming a simple drop without line breaks for this test.
	
	# Stub `freeze` to prevent its side effects if GUT allows, or test integratively
	# For now, let it run, but be aware of side effects on score from break_lines.
	# To simplify, ensure no lines are completed by this drop.
	
	tetris_instance.go_space() 
	
	# After go_space, figure.y would be the y where it *intersected*, then it's moved back by 1.
	# And `freeze` is called, which then calls `new_figure`, changing `tetris_instance.figure`.
	# So, checking tetris_instance.figure.y after go_space() refers to the *new* figure.
	# This test needs refinement to check the state *during* go_space or use mocks.

	# Let's check the score part, assuming no lines were broken by the freeze.
	# The score logic in go_space is `score += 2` for each step down, then `score -=2` once.
	# So if it drops `N` steps successfully, score increases by `N*2`.
	# If it drops from y=0 to y_final, that's y_final steps.
	# This means this test will be very tricky without mocking `freeze`.
	
	# A simplified check assuming `freeze` doesn't add score via line breaks here:
	assert_gte(tetris_instance.score, initial_score + expected_score_increase, "Score should increase due to go_space drop (ignoring break_lines bonus)") 
	# Due to `freeze` being called, the original figure is gone.
	# A more robust test would involve checking the `y` value *just before* `freeze` is called within `go_space`.
	gut.p("go_space basic functionality (score part needs careful isolation from freeze)")

func test_tetris_get_shadow():
	tetris_instance.new_figure()
	tetris_instance.figure.type = Figure.TetraminoType.L
	tetris_instance.figure.rotation = 0
	tetris_instance.figure.x = default_width / 3
	tetris_instance.figure.y = 2 # Some initial y

	var original_y = tetris_instance.figure.y
	var original_x = tetris_instance.figure.x
	var original_type = tetris_instance.figure.type
	var original_rotation = tetris_instance.figure.rotation

	var shadow = tetris_instance.get_shadow() 
	assert_true(is_instance_valid(shadow), "get_shadow should return a valid Figure instance") 

	# Shadow's x, type, rotation should match original
	assert_eq(shadow.x, original_x, "Shadow x should match original figure's x") 
	assert_eq(shadow.type, original_type, "Shadow type should match original figure's type") 
	assert_eq(shadow.rotation, original_rotation, "Shadow rotation should match original figure's rotation") 

	# Shadow's y should be the lowest possible y
	# This means if we put the original figure at shadow.y, it should not intersect,
	# but if we put it at shadow.y + 1, it *would* (or hit bottom)
	var temp_figure_y = tetris_instance.figure.y # Store current figure's y
	tetris_instance.figure.y = shadow.y
	assert_false(tetris_instance.intersects(), "Shadow figure at its y should not intersect") 
	
	tetris_instance.figure.y = shadow.y + 1
	assert_true(tetris_instance.intersects(), "Figure one unit below shadow.y should intersect or be out of bounds") 

	# Restore original figure's y (get_shadow should do this internally)
	tetris_instance.figure.y = temp_figure_y 
	assert_eq(tetris_instance.figure.y, original_y, "Original figure's y should be restored after get_shadow") 
	
	#shadow.free()
	gut.p("get_shadow works as expected")
