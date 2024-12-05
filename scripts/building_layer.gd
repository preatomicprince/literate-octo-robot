extends Node2D

@onready var map = $".."

func generate_setlement():
	pass

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
						build_level: type.BUILD_LEVEL = type.BUILD_LEVEL.Ruins):
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
	
