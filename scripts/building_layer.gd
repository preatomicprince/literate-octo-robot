extends Node2D

@onready var map = $".."

func generate_setlement():
	pass

@rpc("reliable")
func generate_building(player_id: int,
						map_pos: Vector2i, 
						population: int, 
						build_type: type.BUILD_TYPE, 
						build_level: type.BUILD_LEVEL = type.BUILD_LEVEL.Ruins):
						
	if map.buildings[str(map_pos)] != null:
		return
		
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
	
	
func spawn_new_building():
	pass
