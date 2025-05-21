extends Control

const GRID_SIZE := 10
var padding := 20
var cell_size := 45.5
const OFFSET_X := 60
const OFFSET_Y := 55

var occupied_cells := {}  # Stores Vector2i -> bool (true for white, false for black)

@onready var turn_label = $TurnLabel
@onready var stones_container = $Intersections

@onready var white_pebble_scene = preload("res://Scenes/GO/New_Game_Scene/white_pebble.tscn")
@onready var black_pebble_scene = preload("res://Scenes/GO/New_Game_Scene/black_pebble.tscn") 
@onready var highlight_scene = preload("res://Scenes/GO/New_Game_Scene/hover_flower.tscn")
var last_player_passed := false  # Track if previous player passed
var consecutive_passes := 0  

var hover_preview: Node2D
var is_white_turn := true  # Start with white
var white_captures := 0
var black_captures := 0

# Add reference to Winner canvas
@onready var winner_canvas = $"../Winner"
@onready var winner_label = $"../Winner/PanelContainer/MarginContainer/Rows/Winner_Label"

# Win threshold
const CAPTURE_WIN_THRESHOLD := 10


func _ready():
	# Hide winner canvas at start
	winner_canvas.visible = false
	
	hover_preview = white_pebble_scene.instantiate()  # Start with white pebble
	hover_preview.modulate.a = 0.5
	hover_preview.visible = false
	stones_container.add_child(hover_preview)
	is_white_turn = !is_white_turn 
	update_turn_label()
	update_hover_preview()  # Set initial hover preview

func update_turn_label():
	turn_label.text = "White's Turn" if is_white_turn else "Black's Turn"

func update_hover_preview():
	# Remove current hover preview
	if hover_preview:
		hover_preview.queue_free()
	
	# Create new hover preview based on current turn
	if is_white_turn:
		hover_preview = white_pebble_scene.instantiate()
	else:
		hover_preview = black_pebble_scene.instantiate()
	
	hover_preview.modulate.a = 0.5
	hover_preview.visible = false
	stones_container.add_child(hover_preview)

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
		if dist < cell_size:
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
			if child == hover_preview:
				continue
			if child.position == get_world_position(cell.x, cell.y):
				child.queue_free()
				break
		
		occupied_cells.erase(cell)

	# Increase capture count and update hearts based on who captured
	if is_white_turn:
		white_captures += group.size()
		update_hearts(white_captures, "white")
		check_win_condition("White")
	else:
		black_captures += group.size()
		update_hearts(black_captures, "black")
		check_win_condition("Black")

# New function to check if player has won
func check_win_condition(player: String):
	var captures = white_captures if player == "White" else black_captures
	
	if captures >= CAPTURE_WIN_THRESHOLD:
		# Game over, show winner
		declare_winner(player)

# New function to declare winner
func declare_winner(player: String):
	# Set winner text
	winner_label.text = player + " Wins!"
	
	# Show winner canvas
	winner_canvas.visible = true
	
	# Disable input for the game
	set_process_unhandled_input(false)

func update_hearts(capture_count: int, player_color: String):
	var dead_texture_path: String
	var default_texture_path: String
	
	# Choose appropriate textures based on player color (flipped assignment)
	if player_color == "white":
		dead_texture_path = "res://Scenes/GO/New_Game_Scene/blackheart_dead.png"
		default_texture_path = "res://Scenes/GO/New_Game_Scene/blackheart.png"
	else:  # black player
		dead_texture_path = "res://Scenes/GO/New_Game_Scene/greyheart_dead.png"
		default_texture_path = "res://Scenes/GO/New_Game_Scene/greyheart.png"
	
	var dead_texture = load(dead_texture_path)
	var default_texture = load(default_texture_path)
	
	# Update hearts for the capturing player (flipped assignments)
	var hbox1_name: String
	var hbox2_name: String
	
	if player_color == "white":
		hbox1_name = "black_l1"  # White player uses black heart containers
		hbox2_name = "black_l2"  # White player uses black heart containers
	else:  # black player
		hbox1_name = "grey_l1"  # Black player uses grey heart containers
		hbox2_name = "grey_l2"  # Black player uses grey heart containers
	
	# Reset hearts first
	for i in range(5):
		if get_node(hbox1_name).get_child_count() > i:
			get_node(hbox1_name).get_child(i).texture = default_texture
		if get_node(hbox2_name).get_child_count() > i:
			get_node(hbox2_name).get_child(i).texture = default_texture
	
	# Fill hearts based on capture count
	if capture_count > 0:
		# Determine how many hearts to fill in each HBox
		var hearts_in_first = min(capture_count, 5)
		var hearts_in_second = max(0, capture_count - 5)
		
		# Fill hearts in first HBox, with bounds checking
		for i in range(hearts_in_first):
			if get_node(hbox1_name).get_child_count() > i:
				get_node(hbox1_name).get_child(i).texture = dead_texture
		
		# Fill hearts in second HBox, with bounds checking
		for i in range(hearts_in_second):
			if get_node(hbox2_name).get_child_count() > i:
				get_node(hbox2_name).get_child(i).texture = dead_texture

# === INPUT HANDLING ===
func _unhandled_input(event):
	var mouse_pos = stones_container.get_local_mouse_position()
	var grid_coords = get_grid_coordinates(mouse_pos)

	if grid_coords != null and not occupied_cells.has(grid_coords):
		hover_preview.position = get_world_position(grid_coords.x, grid_coords.y)
		hover_preview.visible = true

		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
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
			var pebble = white_pebble_scene.instantiate() if is_white_turn else black_pebble_scene.instantiate()
			pebble.position = get_world_position(grid_coords.x, grid_coords.y)
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
			update_hover_preview()  # Update hover preview for new turn
	else:
		hover_preview.visible = false


func _on_reset_button_pressed() -> void:
	# Re-enable input processing
	set_process_unhandled_input(true)
	
	# Hide winner canvas
	winner_canvas.visible = false
	
	for child in stones_container.get_children():
		# Keep hover_preview and turn_label
		if child != hover_preview and child != turn_label:
			child.queue_free()
	
	occupied_cells.clear()
	white_captures = 0
	black_captures = 0
	is_white_turn = false
	update_turn_label()
	update_hover_preview()  # Reset hover preview to match turn
	last_player_passed = false
	consecutive_passes = 0
	hover_preview.visible = false
	reset_all_hearts()
	
	
func reset_all_hearts():
	# Reset white player hearts (now using black heart textures)
	var black_default_texture = load("res://Scenes/GO/New_Game_Scene/blackheart.png")
	if has_node("black_l1") and has_node("black_l2"):
		for i in range(5):
			if $black_l1.get_child_count() > i:
				$black_l1.get_child(i).texture = black_default_texture
			if $black_l2.get_child_count() > i:
				$black_l2.get_child(i).texture = black_default_texture
	
	# Reset black player hearts (now using grey heart textures)
	var grey_default_texture = load("res://Scenes/GO/New_Game_Scene/greyheart.png")
	if has_node("grey_l1") and has_node("grey_l2"):
		for i in range(5):
			if $grey_l1.get_child_count() > i:
				$grey_l1.get_child(i).texture = grey_default_texture
			if $grey_l2.get_child_count() > i:
				$grey_l2.get_child(i).texture = grey_default_texture

# Add a new function for the play again button on the winner canvas
func _on_play_again_button_pressed() -> void:
	_on_reset_button_pressed()

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
	update_hover_preview()  # Update hover preview for new turn
	
	# Reset hover preview if visible
	hover_preview.visible = false


func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/GO/Go_Menu.tscn")


func _on_main_menu_panel_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main menu/Main menu.tscn")


func _on_restart_panel_pressed() -> void:
	_on_reset_button_pressed()


func _on_go_menu_panel_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/GO/Go_Menu.tscn")
