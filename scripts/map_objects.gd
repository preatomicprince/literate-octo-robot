extends TileMapLayer

@onready var level_info = $".."/".."/Game_State

var rand_i = RandomNumberGenerator.new()

func _process(delta: float) -> void:
	for key in level_info.map_info.keys():
		if level_info.map_info[key][3] is Object and level_info.map_info[key][4] == "yes":
			resource_collection(key)

func generate_points_of_interest():
	###after the initial map has been generated, we can look at the tiles and figure out 
	###needs to be generated on a seperate layer
	###i.e. towns, animals ect
	
	# Ensures a set number of objects on map. Can replace with a range in future
	var num_of_objs = 10
	var counter = 0
	
	while counter < num_of_objs:
		var rand_tile_ind = rand_i.randi_range(0, len($"..".tiles) - 1)
		var rand_obj_type = rand_i.randi_range(0, 1)
		if $"..".objects.has($"..".tiles[rand_tile_ind]):
			continue
			
		$"..".objects[str($"..".tiles[rand_tile_ind])] = true
		set_cell($"..".tiles[rand_tile_ind], 0, Vector2i(rand_obj_type, 0))
		counter += 1
	
	for key in level_info.map_info.keys():
		if level_info.map_info[key][4] == "yes":
			
			var rand_res = rand_i.randi_range(0, 1)
			if rand_res == 0:
				set_cell(Vector2i(level_info.map_info[key][0], level_info.map_info[key][1]), 0, Vector2i(0, 0))
			else:
				set_cell(Vector2i(level_info.map_info[key][0], level_info.map_info[key][1]), 0, Vector2i(1, 0))
				
@rpc("reliable")
func sync_tile_data(auth_packed_array):
	print("Data synced")
	set_tile_map_data_from_array(auth_packed_array)

func call_tile_data_sync(peer_id):
	rpc_id(peer_id, "sync_tile_data", get_tile_map_data_as_array())

func resource_collection(key):
	print("You find some scraps of food")
	set_cell($".".local_to_map(Vector2(level_info.map_info[key][3].position.x, level_info.map_info[key][3].position.y)), 0, Vector2i(-1, -1))
	level_info.map_info[key][4] = "no"
	level_info.player_stats["player one"][0] += 10
