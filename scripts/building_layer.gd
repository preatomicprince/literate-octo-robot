extends Node2D

@onready var map = $".."

# Maximum width and height of a given generated settlement
const MAX_CITY_SIZE = 6

# Should only be called on server. Serialised map data can then be sent to client on load
func generate_rand_setlement(seed: int, size: int, pos: Vector2i) -> int:
	# Seed is sent to ensure consistent generation
	# size is width and height of settlement
	# pos is the upper left tile of settlement
	# Returns 1 if success, 0 if settlement can't be built
	
	if not is_multiplayer_authority():
		return 0
		
	# If settlement goes off map, return as invalid
	if pos.x + size >= map.width or pos.y + size >= map.width:
		return 0
	if size > MAX_CITY_SIZE:
		return 0
		
	if size == 1:
		# Used to generate single structures such as farms or unique buildings
		return 1
		
	for x in range(size):
		for y in range(size):
			# TODO: Add check that all tiles in current selection are empty 
			pass
	
	var rng = RandomNumberGenerator.new()
	rng.seed = seed
	
	# Number of  buildings to be placed in the size x size grid
	var min_buildings: int = (size*size)/2
	var max_buildings: int = size*size
	var building_count: int = rng.randi_range(min_buildings, max_buildings)
	
	# Number of unique (i.e. not housing) buildings
	var min_unique_buildings: int = size - 1
	var max_unique_buildings: int = building_count/2 + 1
	var unique_building_count = rng.randi_range(min_unique_buildings, max_unique_buildings)
	
	# Tracks number of buildings that have been placed
	var current_building_count: int = 0
	
	var buildings: Array = []
	for i in range(0, building_count):
		buildings.append(type.BUILD_TYPE.House)
	
	# Temporarily limited while there are fewer buildings set up. Uncomment below and delete current
	var building_types = [type.BUILD_TYPE.Shop, type.BUILD_TYPE.Factory]
	# var building_types = type.BUILD_TYPE.keys()
	while unique_building_count > 0:
		# TODO: Place limits on number of certain building types
		var rand_building = rng.randi_range(0, len(building_types) - 1)
		var rand_build_order = rng.randi_range(0, building_count - 1)
	
		if buildings[rand_build_order] == type.BUILD_TYPE.House:
			unique_building_count -= 1
			buildings[rand_build_order] = building_types[rand_build_order]
	# Tile currently being generated. Starts roughly in middle
	var current_tile: Vector2i = pos + Vector2i(size/2, size/2)
	# List of Vector2i for each tile that's placed
	var placed_buildings: Array = []
	
	while current_building_count < building_count:
		
		placed_buildings.append(current_tile)
		current_building_count += 1
		

		var next_tile: Array = []
		
		# Checks if each direction is valid in random order
		var dir_count = 3
		var dirs = [0, 1, 2, 3]
		# TODO: Add backtracking to revisit previous tiles if no valid directions
		while dir_count > 0:
			dir_count -= 1
			
			var rand_dir = rng.randi_range(0, dir_count)
			next_tile.append(dirs[rand_dir])
			next_tile.remove_at(rand_dir)
			
			var new_tile = current_tile
			match next_tile:
				0:
					new_tile.x -= 1
				1:
					new_tile.y += 1
				2:
					new_tile.x += 1
				3:
					new_tile.y -= 1
			# Check tile in range
			if new_tile.x < pos.x or new_tile.x > pos.x + size or new_tile.y < pos.y or new_tile.y > pos.y + size:
				continue
			# Check tile not placed already
			if placed_buildings.has(new_tile):
				continue
			current_tile = new_tile
			# Breaks check direction is valid attempts
			break
		generate_building(1, current_tile, 0, buildings.pop_front(), type.BUILD_LEVEL.Ruins)
		rpc("generate_building", 1, current_tile, 0, buildings.pop_front(), type.BUILD_LEVEL.Ruins)
	return 1
	
	
@rpc("reliable")
func generate_building(player_id: int,
						map_pos: Vector2i, 
						population: int, 
						build_type: type.BUILD_TYPE, 
						build_level: type.BUILD_LEVEL) -> int:
						
	if map.buildings[str(map_pos)] != null:
		return 0
		
	var new_building = preload("res://scenes/building.tscn").instantiate()
	new_building.player_id = player_id
	new_building.build_type = build_type
	new_building.build_level = build_level
	new_building.population = population
	new_building.position = map.map_to_local(map_pos)
	add_child(new_building)
	
	map.buildings[str(map_pos)] = new_building
	
	if is_multiplayer_authority():
		$".."/"..".player[player_id].buildings.append(new_building)
		$".."/Fog_Of_War.map_reveal(player_id, map_pos)
	
	return 1
	
func spawn_new_building(peer_id: int,
						unit: Node,
						build_type: type.BUILD_TYPE = type.BUILD_TYPE.House, 
						build_level: type.BUILD_LEVEL = type.BUILD_LEVEL.Ruins) -> void:
	var map_pos = unit.tile_index
	var map_pos_str = str(unit.tile_index)
	
	# Cost to create new building
	var population = 5
	
	# Check if tile exists
	if not map.buildings.has(map_pos_str):
		return
		
	# Check tile has no unit
	if map.buildings[(map_pos_str)] != null:
		return
	
	# Can't spawn if pop too low
	if unit.percent_ready <= population:
		return
		
	if generate_building(peer_id, map_pos, population, build_type, build_level):
		# If succesful, decrease unit pop.
		unit.percent_ready -= population
		# And call on clients
		rpc("generate_building", peer_id, map_pos, population, build_type, build_level)
	
