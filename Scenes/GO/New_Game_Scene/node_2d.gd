extends Control

const GRID_SIZE := 10
var padding := 20
var cell_size := 45.5
const OFFSET_X := 60
const OFFSET_Y := 55

var occupied_cells := {}  # Stores Vector2i -> bool (true for white, false for black)

@export var stones_container: Node2D
@export var turn_label: Label
@export var white_captures_label: Label
@export var black_captures_label: Label
@export var grey_l1: HBoxContainer
@export var grey_l2: HBoxContainer
@export var black_l1: HBoxContainer
@export var black_l2: HBoxContainer
@export var tile_map: TileMapLayer

@onready var white_pebble_scene = preload("res://Scenes/GO/New_Game_Scene/white_pebble.tscn")
@onready var black_pebble_scene = preload("res://Scenes/GO/New_Game_Scene/black_pebble.tscn")
@onready var highlight_scene = preload("res://Scenes/GO/New_Game_Scene/hover_flower.tscn")
var last_player_passed := false  # Track if previous player passed
var consecutive_passes := 0

var hover_preview: Node2D
var is_white_turn := true  # Start with white
var white_captures := 0
var black_captures := 0
var bounds = Rect2i(Vector2i(0, 0), Vector2i(GRID_SIZE, GRID_SIZE))


func update_turn_label():
	turn_label.text = "White's Turn" if is_white_turn else "Black's Turn"


func update_capture_labels():
	white_captures_label.text = "White Captures: %d" % white_captures
	black_captures_label.text = "Black Captures: %d" % black_captures


func _ready():
	hover_preview = highlight_scene.instantiate()
	hover_preview.modulate.a = 0.5
	hover_preview.visible = false
	stones_container.add_child(hover_preview)
	is_white_turn = !is_white_turn
	update_capture_labels()
	update_turn_label()


func get_world_position(x: int, y: int) -> Vector2:
	return Vector2(padding + OFFSET_X + x * cell_size, padding + OFFSET_Y + y * cell_size)


func get_grid_coordinates(mouse_pos: Vector2):
	var x = int((mouse_pos.x) / cell_size)
	var y = int((mouse_pos.y) / cell_size)

	if x >= 0 and x < GRID_SIZE and y >= 0 and y < GRID_SIZE:
		var center = get_world_position(x, y)
		var dist = mouse_pos.distance_to(center)
		if dist < cell_size:
			return Vector2i(x, y)
	return null


# === CAPTURE LOGIC ===


func get_adjacent_cells(cell: Vector2i) -> Array[Vector2i]:
	var adj: Array[Vector2i] = []
	const directions = [
		TileSet.CELL_NEIGHBOR_TOP_SIDE, 
		TileSet.CELL_NEIGHBOR_LEFT_SIDE, 
		TileSet.CELL_NEIGHBOR_RIGHT_SIDE, 
		TileSet.CELL_NEIGHBOR_BOTTOM_SIDE]
	for dir in directions:
		var neighbor := tile_map.get_neighbor_cell(cell, dir)
		if (
			neighbor.x >= 0
			and neighbor.x < GRID_SIZE
			and neighbor.y >= 0
			and neighbor.y < GRID_SIZE
		):
			adj.append(neighbor)
	return adj


func get_group(start_cell: Vector2i, color: bool) -> Array[Vector2i]:
	var visited : Dictionary[Vector2i, bool] = {}
	var stack := [start_cell]
	var group: Array[Vector2i] = []

	while stack.size() > 0:
		var current = stack.pop_back()
		if visited.has(current):
			continue
		visited[current] = true
		group.append(current)

		for neighbor in get_adjacent_cells(current):
			if occupied_cells.has(neighbor) and occupied_cells[neighbor] == color:
				stack.append(neighbor)

	return group


func has_liberties(group: Array) -> bool:
	for cell in group:
		for neighbor in get_adjacent_cells(cell):
			if not occupied_cells.has(neighbor):
				return true
	return false


func capture_group(group: Array) -> void:
	for cell in group:
		for child in stones_container.get_children():
			if child == hover_preview:
				continue
			if child.position == tile_map.map_to_local(cell):
				child.queue_free()
				break
		# Increase capture count based on who captured
		if is_white_turn:
			white_captures += 1
			update_grey_hearts(white_captures, "res://Scenes/GO/New_Game_Scene/greyheart_dead.png")
		else:
			black_captures += 1

		occupied_cells.erase(cell)

	update_capture_labels()

func update_grey_hearts(capture_count: int, dead_texture_path: String) -> void:
	var grey_heart_dead_texture = load(dead_texture_path)
	var grey_heart_default_texture = load("res://Scenes/GO/New_Game_Scene/greyheart.png")
	
	# Reset both HBoxes first
	for i in range(5):
		grey_l1.get_child(i).texture = grey_heart_default_texture
		grey_l2.get_child(i).texture = grey_heart_default_texture
	
	# Fill hearts based on capture count
	if capture_count > 0:
		# Determine how many hearts to fill in each HBox
		var hearts_in_l1 = min(capture_count, 5)
		var hearts_in_l2 = max(0, capture_count - 5)
		
		# Fill hearts in grey_l1
		for i in range(hearts_in_l1):
			grey_l1.get_child(i).texture = grey_heart_dead_texture
		
		# Fill hearts in grey_l2
		for i in range(hearts_in_l2):
			grey_l2.get_child(i).texture = grey_heart_dead_texture



# === INPUT HANDLING ===
func _unhandled_input(event):
	var grid_coords := tile_map.local_to_map(tile_map.get_local_mouse_position())
	
	if !bounds.has_point(grid_coords):
		hover_preview.visible = false
		return
	
	if grid_coords != null and not occupied_cells.has(grid_coords):
		hover_preview.position = tile_map.map_to_local(grid_coords)
		hover_preview.visible = true

		if (
			event is InputEventMouseButton
			and event.pressed
			and event.button_index == MOUSE_BUTTON_LEFT
		):
			last_player_passed = false
			consecutive_passes = 0
			# Temporarily place stone to test
			occupied_cells[grid_coords] = is_white_turn
			var opponent_color = !is_white_turn

			# Check captures around placed stone
			var captured_any := false
			for neighbor in get_adjacent_cells(grid_coords):
				if occupied_cells.has(neighbor) and occupied_cells[neighbor] == opponent_color:
					var group = get_group(neighbor, opponent_color)
					if not has_liberties(group):
						captured_any = true
						break

			# Check if move is suicide
			var own_group = get_group(grid_coords, is_white_turn)
			var suicide = not has_liberties(own_group)

			# Undo temporary placement
			occupied_cells.erase(grid_coords)

			# If move is suicide and doesn't capture enemy, reject
			if suicide and not captured_any:
				return  # Don't place the stone, don't change turn

			# Actually place the pebble (legal move)
			var pebble = (
				white_pebble_scene.instantiate()
				if is_white_turn
				else black_pebble_scene.instantiate()
			)
			pebble.position = tile_map.map_to_local(grid_coords)
			stones_container.add_child(pebble)

			# Track placement
			occupied_cells[grid_coords] = is_white_turn

			# Now perform actual captures
			for neighbor in get_adjacent_cells(grid_coords):
				if occupied_cells.has(neighbor) and occupied_cells[neighbor] == opponent_color:
					var group = get_group(neighbor, opponent_color)
					if not has_liberties(group):
						capture_group(group)

			# Check again if own group has no liberties (for suicide moves allowed)
			var own_group_after = get_group(grid_coords, is_white_turn)
			if not has_liberties(own_group_after):
				capture_group(own_group_after)

			# Change turn
			is_white_turn = !is_white_turn
			update_turn_label()
	else:
		hover_preview.visible = false


func _on_reset_button_pressed() -> void:
	for child in stones_container.get_children():
		# Keep hover_preview and all labels
		if (
			child != hover_preview
			and child != turn_label
			and child != white_captures_label
			and child != black_captures_label
		):
			child.queue_free()
			occupied_cells.clear()
			white_captures = 0
			black_captures = 0
			is_white_turn = false
			update_capture_labels()
			update_turn_label()
			last_player_passed = false
			consecutive_passes = 0
			hover_preview.visible = false
	reset_grey_hearts()
	
	
func reset_grey_hearts():
	var default_texture = load("res://Scenes/GO/New_Game_Scene/greyheart.png")
	for i in range(5):
		var texture_rect = grey_l1.get_child(i)
		texture_rect.texture = default_texture
	for i in range(5):
		var texture_rect = grey_l2.get_child(i)
		texture_rect.texture = default_texture

func _on_pass_pressed() -> void:
	consecutive_passes += 1 if last_player_passed else 1
	last_player_passed = true

	# Check for two consecutive passes
	if consecutive_passes >= 2:
		_on_reset_button_pressed()  # Reset the game
		return

		# Switch turns
		is_white_turn = !is_white_turn
		update_turn_label()

	# Reset hover preview if visible
	hover_preview.visible = false
