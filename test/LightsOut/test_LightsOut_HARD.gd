extends GutTest

const TestGrid = preload("res://Scenes/LightsOut/lights_out_game.gd")
var grid: TestGrid = null

func before_each():
	grid = autofree(TestGrid.new())
	grid.grid_size = 9 
	grid.pressed_counter = Label.new()
	grid.victory_label = Label.new()
	grid.highscore_counter = Label.new()
	grid.difficulty_name = Label.new()  

	grid.buttons = []
	grid.buttons.resize(grid.grid_size)
	for i in range(grid.grid_size):
		grid.buttons[i] = []
		grid.buttons[i].resize(grid.grid_size)

func test_grid_initialization():
	assert_not_null(grid, "Grid should be initialized")
	assert_eq(grid.grid_size, 9, "Grid size should be 9")  
	assert_eq(grid.buttons.size(), 9, "Buttons array should have size 9") 
	assert_eq(grid.buttons[0].size(), 9, "Each row should have size 9")  

func test_victory_condition():
	for y in range(grid.grid_size):
		for x in range(grid.grid_size):
			var button = Button.new()
			button.set_meta("is_green", true)
			grid.buttons[x][y] = button
	assert_true(grid.all_green(), "Should detect victory because all buttons are green")
	grid.buttons[4][4].set_meta("is_green", false) 
	assert_false(grid.all_green(), "Shouldn't detect victory because one button is red")

func test_button_toggling_affects_neighbours():
	for y in range(grid.grid_size):
		for x in range(grid.grid_size):
			var button = Button.new()
			button.set_meta("is_green", false)
			grid.buttons[x][y] = button
			
	var red_style = StyleBoxFlat.new()
	var green_style = StyleBoxFlat.new()
	grid._on_button_pressed(4, 4, red_style, green_style)  
	

	assert_true(grid.buttons[4][4].get_meta("is_green"), "Center button should be toggled")
	assert_true(grid.buttons[3][4].get_meta("is_green"), "Left button should be toggled")
	assert_true(grid.buttons[5][4].get_meta("is_green"), "Right button should be toggled")
	assert_true(grid.buttons[4][3].get_meta("is_green"), "Top button should be toggled")
	assert_true(grid.buttons[4][5].get_meta("is_green"), "Bottom button should be toggled")
	
	
	assert_false(grid.buttons[0][0].get_meta("is_green"), "Top-left corner should remain unchanged")
	assert_false(grid.buttons[8][0].get_meta("is_green"), "Top-right corner should remain unchanged")
	assert_false(grid.buttons[0][8].get_meta("is_green"), "Bottom-left corner should remain unchanged")
	assert_false(grid.buttons[8][8].get_meta("is_green"), "Bottom-right corner should remain unchanged")
	assert_false(grid.buttons[0][4].get_meta("is_green"), "Far left edge should remain unchanged")
	assert_false(grid.buttons[8][4].get_meta("is_green"), "Far right edge should remain unchanged")
	assert_false(grid.buttons[4][0].get_meta("is_green"), "Top edge should remain unchanged")
	assert_false(grid.buttons[4][8].get_meta("is_green"), "Bottom edge should remain unchanged")

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
	grid.buttons[4][4].set_meta("is_green", false) 
	assert_false(grid.all_green(), "Should return false when at least one button is red")

func test_toggle_button_changes_state():
	var button = Button.new()
	button.set_meta("is_green", false)
	grid.buttons[4][4] = button  
	
	var red_style = StyleBoxFlat.new()
	var green_style = StyleBoxFlat.new()
	
	grid.toggle_button(4, 4, red_style, green_style)
	assert_true(button.get_meta("is_green"), "Should toggle button from red to green")
	
	grid.toggle_button(4, 4, red_style, green_style)
	assert_false(button.get_meta("is_green"), "Should toggle button back to red")

func test_toggle_button_out_of_bounds():
	var red_style = StyleBoxFlat.new()
	var green_style = StyleBoxFlat.new()
	
	grid.toggle_button(-1, 0, red_style, green_style)
	grid.toggle_button(0, -1, red_style, green_style)
	grid.toggle_button(grid.grid_size, 0, red_style, green_style)
	grid.toggle_button(0, grid.grid_size, red_style, green_style)
	
	pass_test("Should handle out-of-bounds coordinates without errors")

func test_edge_button_toggling():
	for y in range(grid.grid_size):
		for x in range(grid.grid_size):
			var button = Button.new()
			button.set_meta("is_green", false)
			grid.buttons[x][y] = button
	
	var red_style = StyleBoxFlat.new()
	var green_style = StyleBoxFlat.new()
	
	grid._on_button_pressed(0, 0, red_style, green_style)
	assert_true(grid.buttons[0][0].get_meta("is_green"), "(0,0) should toggle")
	assert_true(grid.buttons[1][0].get_meta("is_green"), "(1,0) should toggle")
	assert_true(grid.buttons[0][1].get_meta("is_green"), "(0,1) should toggle")
	assert_false(grid.buttons[1][1].get_meta("is_green"), "(1,1) should not toggle")
	
	# Test bottom-right corner
	grid._on_button_pressed(8, 8, red_style, green_style)
	assert_true(grid.buttons[8][8].get_meta("is_green"), "(8,8) should toggle")
	assert_true(grid.buttons[7][8].get_meta("is_green"), "(7,8) should toggle")
	assert_true(grid.buttons[8][7].get_meta("is_green"), "(8,7) should toggle")
	assert_false(grid.buttons[7][7].get_meta("is_green"), "(7,7) should not toggle")

func test_counter_increments_on_button_press():
	assert_eq(grid.counter, 0, "Counter should start at 0")
	var red_style = StyleBoxFlat.new()
	var green_style = StyleBoxFlat.new()
	
	grid._on_button_pressed(4, 4, red_style, green_style)
	assert_eq(grid.counter, 1, "Counter should increment on button press")
	assert_eq(grid.pressed_counter.text, "1", "Press counter label should update")

func test_middle_edge_button_toggling():
	for y in range(grid.grid_size):
		for x in range(grid.grid_size):
			var button = Button.new()
			button.set_meta("is_green", false)
			grid.buttons[x][y] = button
	
	var red_style = StyleBoxFlat.new()
	var green_style = StyleBoxFlat.new()
	
	grid._on_button_pressed(0, 4, red_style, green_style)
	assert_true(grid.buttons[0][4].get_meta("is_green"), "(0,4) should toggle")
	assert_true(grid.buttons[1][4].get_meta("is_green"), "(1,4) should toggle")
	assert_true(grid.buttons[0][3].get_meta("is_green"), "(0,3) should toggle")
	assert_true(grid.buttons[0][5].get_meta("is_green"), "(0,5) should toggle")
	assert_false(grid.buttons[1][3].get_meta("is_green"), "(1,3) should not toggle")
	
	grid._on_button_pressed(4, 0, red_style, green_style)
	assert_true(grid.buttons[4][0].get_meta("is_green"), "(4,0) should toggle")
	assert_true(grid.buttons[4][1].get_meta("is_green"), "(4,1) should toggle")
	assert_true(grid.buttons[3][0].get_meta("is_green"), "(3,0) should toggle")
	assert_true(grid.buttons[5][0].get_meta("is_green"), "(5,0) should toggle")
	assert_false(grid.buttons[3][1].get_meta("is_green"), "(3,1) should not toggle")
