extends Node2D

const GRID_SIZE := 10
var padding := 20
var cell_size := 45.5
const OFFSET_X := 60
const OFFSET_Y := 55

var occupied_cells := {}  # Stores Vector2i -> bool (true for white, false for black)

@onready var turn_label = $Intersections/TurnLabel
@onready var stones_container = $Intersections

@onready var white_pebble_scene = preload("res://Scenes/GO/New_Game_Scene/white_pebble.tscn")
@onready var black_pebble_scene = preload("res://Scenes/GO/New_Game_Scene/black_pebble.tscn") 
@onready var highlight_scene = preload("res://Scenes/GO/New_Game_Scene/hover_flower.tscn")

var hover_preview: Node2D
var is_white_turn := true  # Start with white

func update_turn_label():
	turn_label.text = "White's Turn" if is_white_turn else "Black's Turn"

func _ready():
	hover_preview = highlight_scene.instantiate()
	hover_preview.modulate.a = 0.5
	hover_preview.visible = false
	stones_container.add_child(hover_preview)
	is_white_turn = !is_white_turn 
	update_turn_label()

func get_world_position(x: int, y: int) -> Vector2:
	return Vector2(
		padding + OFFSET_X + x * cell_size,
		padding + OFFSET_Y + y * cell_size
	)

func get_grid_coordinates(mouse_pos: Vector2):
	var x = int((mouse_pos.x - padding - OFFSET_X) / cell_size)
	var y = int((mouse_pos.y - padding - OFFSET_Y) / cell_size)

	if x >= 0 and x < GRID_SIZE and y >= 0 and y < GRID_SIZE:
		var center = get_world_position(x, y)
		var dist = mouse_pos.distance_to(center)
		if dist < cell_size * 0.8:
			return Vector2i(x, y)
	return null

# === CAPTURE LOGIC ===

func get_adjacent_cells(cell: Vector2i) -> Array:
	var adj = []
	for offset in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var neighbor = cell + offset
		if neighbor.x >= 0 and neighbor.x < GRID_SIZE and neighbor.y >= 0 and neighbor.y < GRID_SIZE:
			adj.append(neighbor)
	return adj

func get_group(start_cell: Vector2i, color: bool) -> Array:
	var visited := {}
	var stack := [start_cell]
	var group := []

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

func capture_group(group: Array):
	for cell in group:
		for child in stones_container.get_children():
			if child.position == get_world_position(cell.x, cell.y):
				child.queue_free()
				break
		occupied_cells.erase(cell)

# === INPUT HANDLING ===

func _unhandled_input(event):
	var mouse_pos = stones_container.get_local_mouse_position()
	var grid_coords = get_grid_coordinates(mouse_pos)

	if grid_coords != null and not occupied_cells.has(grid_coords):
		hover_preview.position = get_world_position(grid_coords.x, grid_coords.y)
		hover_preview.visible = true

		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			# Place pebble
			var pebble = white_pebble_scene.instantiate() if is_white_turn else black_pebble_scene.instantiate()
			pebble.position = get_world_position(grid_coords.x, grid_coords.y)
			stones_container.add_child(pebble)

			# Track placement
			occupied_cells[grid_coords] = is_white_turn
			var opponent_color = !is_white_turn

			# Check captures around placed stone
			for neighbor in get_adjacent_cells(grid_coords):
				if occupied_cells.has(neighbor) and occupied_cells[neighbor] == opponent_color:
					var group = get_group(neighbor, opponent_color)
					if not has_liberties(group):
						capture_group(group)

			# Optional suicide check (currently allows suicide)
			var own_group = get_group(grid_coords, is_white_turn)
			if not has_liberties(own_group):
				capture_group(own_group)

			# Change turn
			is_white_turn = !is_white_turn
			update_turn_label()
	else:
		hover_preview.visible = false
