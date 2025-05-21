extends GutTest

var figure_instance: Figure

func before_each():
	figure_instance = Figure.new()
	# Optional: seed the random number generator for predictable types if needed for specific tests
	# seed(12345) 
	# figure_instance = Figure.new() # Re-initialize after seeding for deterministic type

func test_figure_initialization():
	assert_eq(figure_instance.x, 0, "Figure should initialize x to 0")
	assert_eq(figure_instance.y, 0, "Figure should initialize y to 0")
	assert_gte(figure_instance.type, 0, "Figure type should be non-negative")
	assert_lt(figure_instance.type, figure_instance.figures.size(), "Figure type should be within range of defined figures")
	assert_eq(figure_instance.rotation, 0, "Figure should initialize rotation to 0")
	gut.p("Figure initialized with default values")

func test_figure_image_retrieval():
	# Assuming we can set a specific type for testing or know the first type
	figure_instance.type = Figure.TetraminoType.I # Example: Set to 'I'
	figure_instance.rotation = 0
	var expected_image = [[1, 5, 9, 13], [4, 5, 6, 7]][0] # Image for I, rotation 0
	assert_eq(figure_instance.image(), expected_image, "image() should return the correct block array for type I, rotation 0")

	figure_instance.rotation = 1
	expected_image = [[1, 5, 9, 13], [4, 5, 6, 7]][1] # Image for I, rotation 1
	assert_eq(figure_instance.image(), expected_image, "image() should return the correct block array for type I, rotation 1")
	gut.p("Figure image retrieval works")

func test_figure_rotation():
	figure_instance.type = Figure.TetraminoType.T # T-shape has 4 rotations
	var initial_rotation = figure_instance.rotation
	
	figure_instance.rotate()
	assert_eq(figure_instance.rotation, (initial_rotation + 1) % 4, "Rotation should increment by 1")

	figure_instance.rotation = 3 # Set to last rotation
	figure_instance.rotate()
	assert_eq(figure_instance.rotation, 0, "Rotation should wrap around to 0")

	figure_instance.type = Figure.TetraminoType.O # O-shape has 1 rotation
	figure_instance.rotation = 0
	figure_instance.rotate()
	assert_eq(figure_instance.rotation, 0, "O-shape rotation should remain 0 after rotate")
	gut.p("Figure rotation logic works")

func test_figure_to_string():
	figure_instance.type = Figure.TetraminoType.L
	figure_instance.x = 3
	figure_instance.y = 5
	figure_instance.rotation = 1
	var expected_string = "L r:1 x:3 y:5" # Based on enum keys
	assert_eq(str(figure_instance), expected_string, "Figure _to_string representation is not as expected.")
	gut.p("Figure _to_string works")
