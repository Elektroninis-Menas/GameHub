class_name Go
extends RefCounted

const GRID_SIZE := 10

# Game state
var occupied_cells := {}  # Stores Vector2i -> bool (true for white, false for black)
var is_white_turn := false
var white_captures := 0
var black_captures := 0
var last_player_passed := false
var consecutive_passes := 0

# Returns true if a specific grid position is valid
func is_valid_position(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < GRID_SIZE and pos.y >= 0 and pos.y < GRID_SIZE

# Get adjacent cells (orthogonal neighbors)
func get_adjacent_cells(cell: Vector2i) -> Array:
	var adj = []
	for offset in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var neighbor = cell + offset
		if is_valid_position(neighbor):
			adj.append(neighbor)
	return adj

# Get all stones of the same color connected to the starting cell
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

# Check if a group has any liberties (empty adjacent spaces)
func has_liberties(group: Array) -> bool:
	for cell in group:
		for neighbor in get_adjacent_cells(cell):
			if not occupied_cells.has(neighbor):
				return true
	return false

# Capture a group and return the number of stones captured
func capture_group(group: Array) -> int:
	var capture_count = 0
	
	for cell in group:
		occupied_cells.erase(cell)
		capture_count += 1
	
	return capture_count

# Reset the game state
func reset_game() -> void:
	occupied_cells.clear()
	white_captures = 0
	black_captures = 0
	is_white_turn = false
	last_player_passed = false
	consecutive_passes = 0

# Switch turn between players
func switch_turn() -> void:
	is_white_turn = !is_white_turn

# Pass the current turn
func pass_turn() -> bool:
	consecutive_passes += 1 if last_player_passed else 1
	last_player_passed = true
	
	# Check for two consecutive passes (game over)
	if consecutive_passes >= 2:
		return true  # Game is over
	
	# Switch turns
	switch_turn()
	return false  # Game continues

# Find territory - empty points surrounded by a single color
func find_territory() -> Dictionary:
	var black_territory := 0
	var white_territory := 0
	
	# Check all empty points
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			var pos = Vector2i(x, y)
			if occupied_cells.has(pos):
				continue  # Skip occupied points
				
			# Check if this empty point is surrounded by stones of one color
			var white_surrounding := true
			var black_surrounding := true
			
			
			var visited := {}
			var stack := [pos]
			var empty_group := []
			
			while stack.size() > 0:
				var current = stack.pop_back()
				if visited.has(current):
					continue
					
				visited[current] = true
				empty_group.append(current)
				
				for neighbor in get_adjacent_cells(current):
					if occupied_cells.has(neighbor):
						# Check surrounding stones
						if occupied_cells[neighbor]:  # White stone
							black_surrounding = false
						else:  # Black stone
							white_surrounding = false
					else:
						# Continue flood fill to empty points
						stack.append(neighbor)
			
			# Count territory if surrounded by only one color
			if white_surrounding and !black_surrounding:
				white_territory += empty_group.size()
			elif black_surrounding and !white_surrounding:
				black_territory += empty_group.size()
	
	return {
		"black_territory": black_territory,
		"white_territory": white_territory
	}

# Calculate final score including territory and captures
func calculate_score() -> Dictionary:
	var territory = find_territory()
	
	var black_score = black_captures + territory.black_territory
	var white_score = white_captures + territory.white_territory
	
	return {
		"black_territory": territory.black_territory,
		"white_territory": territory.white_territory,
		"black_score": black_score,
		"white_score": white_score
	}

# Attempt to place a stone at the given position
func place_stone(pos: Vector2i) -> Dictionary:
	var result = {
		"success": false,
		"captures": 0,
		"reason": "Invalid position"
	}
	
	# Check if position is valid
	if !is_valid_position(pos):
		return result
	
	# Check if cell is already occupied
	if occupied_cells.has(pos):
		result.reason = "Cell already occupied"
		return result
	
	# Reset passing state
	last_player_passed = false
	consecutive_passes = 0
	
	# Temporarily place stone to test
	occupied_cells[pos] = is_white_turn
	var opponent_color = !is_white_turn
	
	# Check captures around placed stone
	var captured_any := false
	var total_captures := 0
	
	for neighbor in get_adjacent_cells(pos):
		if occupied_cells.has(neighbor) and occupied_cells[neighbor] == opponent_color:
			var group = get_group(neighbor, opponent_color)
			if not has_liberties(group):
				captured_any = true
				# Don't actually capture yet, just note that we could
				total_captures += group.size()
	
	# Check if move is suicide
	var own_group = get_group(pos, is_white_turn)
	var suicide = not has_liberties(own_group)
	
	# Undo temporary placement to restore the original state
	occupied_cells.erase(pos)
	
	# If move is suicide and doesn't capture enemy, reject
	if suicide and not captured_any:
		result.reason = "Suicide move not allowed"
		return result
	
	# Now actually place the stone (legal move)
	occupied_cells[pos] = is_white_turn
	result.success = true
	
	# Perform actual captures
	for neighbor in get_adjacent_cells(pos):
		if occupied_cells.has(neighbor) and occupied_cells[neighbor] == opponent_color:
			var group = get_group(neighbor, opponent_color)
			if not has_liberties(group):
				var captures = capture_group(group)
				result.captures += captures
				
				# Update capture counters
				if is_white_turn:
					white_captures += captures
				else:
					black_captures += captures
	
	# Check again if own group has no liberties (for suicide moves that are allowed)
	var own_group_after = get_group(pos, is_white_turn)
	if not has_liberties(own_group_after):
		# This would be a self-capture, which we allow only if capturing enemy stones
		var self_captures = capture_group(own_group_after)
		if is_white_turn:
			black_captures += self_captures
		else:
			white_captures += self_captures
	
	# Change turn
	switch_turn()
	return result

# Get current score (territory counting not implemented)
func get_score() -> Dictionary:
	return {
		"white_captures": white_captures,
		"black_captures": black_captures
	}
