extends GutTest

const TestGrid = preload("res://Scenes/LightsOut/lights_out_game.gd")
var grid: TestGrid = null

func before_each():
	grid = autofree(TestGrid.new())
	grid.grid_size = 3
	#grid.pressed_counter=Label.new()
	#grid.victory_label=Label.new()
	#grid.highscore_counter=Label.new()


	grid.buttons = []
	grid.buttons.resize(grid.grid_size)
	for i in range(grid.grid_size):
		grid.buttons[i] = []
		grid.buttons[i].resize(grid.grid_size)

func after_each():
	if len(grid.buttons) > 0:
		for row in grid.buttons:
			for button: Button in row:
				if button != null:
					button.free()

func test_grid_initialization():
	assert_not_null(grid, "Grid should be initialized")
	assert_eq(grid.grid_size, 3, "Grid size should be 3")
	assert_eq(grid.buttons.size(), 3, "Buttons array should have size 3")
	assert_eq(grid.buttons[0].size(), 3, "Each row should have size 3")
	
func test_different_grid_distributions():	
	var first_grid_state = []
	for y in range(grid.grid_size):
		for x in range(grid.grid_size):
			first_grid_state.append(grid.rng.randf() < 0.5)
	
	if not has_red_buttons_in_state(first_grid_state):
		first_grid_state[0] = false
	
	var found_different_grid = false
	for i in range(5):
		var current_grid_state = []
		for y in range(grid.grid_size):
			for x in range(grid.grid_size):
				current_grid_state.append(grid.rng.randf() < 0.5)
		
		if not has_red_buttons_in_state(current_grid_state):
			current_grid_state[0] = false
		
		var different = false
		for j in range(current_grid_state.size()):
			if first_grid_state[j] != current_grid_state[j]:
				different = true
				break
		
		if different:
			found_different_grid = true
			break
	
	assert_true(found_different_grid, "Should generate at least one different grid distribution in 5 attempts")

func has_red_buttons_in_state(state_array) -> bool:
	for value in state_array:
		if not value:  
			return true
	return false
	

func test_victory_condition():
	for y in range(grid.grid_size):
		for x in range(grid.grid_size):
			var button= Button.new()
			button.set_meta("is_green", true)
			grid.buttons[x][y]=button
	assert_true(grid.all_green(),"Should detect victory bcs all buttons are green")
	grid.buttons[1][1].set_meta("is_green",false)
	assert_false(grid.all_green(), "Shouldn't detect victory bcs one button is red")

func test_button_toggling_affects_neighbours():
	for y in range(grid.grid_size):
		for x in range(grid.grid_size):
			var button = Button.new()
			button.set_meta("is_green", false)
			grid.buttons[x][y] = button
			
	var red_style=StyleBoxFlat.new()
	var green_style=StyleBoxFlat.new()
	grid.pressed_counter = Label.new()
	grid._on_button_pressed(1, 1, red_style, green_style)
	assert_true(grid.buttons[1][1].get_meta("is_green"), "Center button should be toggled")
	assert_true(grid.buttons[0][1].get_meta("is_green"), "Left button should be toggled")
	assert_true(grid.buttons[2][1].get_meta("is_green"), "Right button should be toggled")
	assert_true(grid.buttons[1][0].get_meta("is_green"), "Top button should be toggled")
	assert_true(grid.buttons[1][2].get_meta("is_green"), "Bottom button should be toggled")
	assert_false(grid.buttons[0][0].get_meta("is_green"), "Top-left corner should remain unchanged")
	assert_false(grid.buttons[2][0].get_meta("is_green"), "Top-right corner should remain unchanged")
	assert_false(grid.buttons[0][2].get_meta("is_green"), "Bottom-left corner should remain unchanged")
	assert_false(grid.buttons[2][2].get_meta("is_green"), "Bottom-right corner should remain unchanged")
	grid.pressed_counter.free()

func test_all_green_when_all_buttons_are_green():

	for y in range(grid.grid_size):
		for x in range(grid.grid_size):
			var button = Button.new()
			button.set_meta("is_green", true)
			grid.buttons[x][y] = button
	
	assert_true(grid.all_green(), "Should return true when all buttons are green")

func test_all_green_when_one_button_is_red():
	for y in range(grid.grid_size):
		for x in range(grid.grid_size):
			var button = Button.new()
			button.set_meta("is_green", true)
			grid.buttons[x][y] = button
	
	grid.buttons[1][1].set_meta("is_green", false)
	
	assert_false(grid.all_green(), "Should return false when at least one button is red")

func test_toggle_button_changes_state():
	var button = Button.new()
	button.set_meta("is_green", false)
	grid.buttons[1][1] = button
	
	var red_style = StyleBoxFlat.new()
	var green_style = StyleBoxFlat.new()
	
	grid.toggle_button(1, 1, red_style, green_style)
	assert_true(button.get_meta("is_green"), "Should toggle button from red to green")
	
	grid.toggle_button(1, 1, red_style, green_style)
	assert_false(button.get_meta("is_green"), "Should toggle button back to red")

func test_toggle_button_out_of_bounds():
	var red_style = StyleBoxFlat.new()
	var green_style = StyleBoxFlat.new()
	
	grid.toggle_button(-1, 0, red_style, green_style)
	grid.toggle_button(0, -1, red_style, green_style)  
	grid.toggle_button(grid.grid_size, 0, red_style, green_style)  
	grid.toggle_button(0, grid.grid_size, red_style, green_style)  
	
	pass_test("Should handle out-of-bounds coordinates without errors")
