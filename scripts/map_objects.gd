extends TileMapLayer

@onready var level_info = get_node("/root/GameVars")

var rand_i = RandomNumberGenerator.new()

func _process(delta: float) -> void:
	for key in level_info.map_info.keys():
		if level_info.map_info[key][4] == "yes" and level_info.map_info[key][3] is Object:
			resource_collection(key)

func generate_points_of_interest():
	###after the initial map has been generated, we can look at the tiles and figure out 
	###needs to be generated on a seperate layer
	###i.e. towns, animals ect
	
	for key in level_info.map_info.keys():
		if level_info.map_info[key][4] == "yes":
			
			var rand_res = rand_i.randi_range(0, 1)
			if rand_res == 0:
				set_cell(Vector2i(level_info.map_info[key][0], level_info.map_info[key][1]), 0, Vector2i(0, 0))
			else:
				set_cell(Vector2i(level_info.map_info[key][0], level_info.map_info[key][1]), 0, Vector2i(1, 0))

func resource_collection(key):
	print("You find some scraps of food")
	set_cell($".".local_to_map(Vector2(level_info.map_info[key][3].position.x, level_info.map_info[key][3].position.y)), 0, Vector2i(-1, -1))
	level_info.map_info[key][4] = "no"
	level_info.player_stats["player one"][0] += 10
	###just print it to test it
	print("you found a ", find_item())

func find_item():
	###this returns an item that gets added to the players inventory
	rand_i.randi_range(0, 3)
	if rand_i == 0:
		###weapons
		rand_i.randi_range(0, len(level_info.Weapons)-1)
		return level_info.Weapons[rand_i]
		
	if rand_i == 1:
		###clothing
		rand_i.randi_range(0, len(level_info.Clothes)-1)
		return level_info.Clothes[rand_i]
		
	if rand_i == 2:
		###vehicles
		rand_i.randi_range(0, len(level_info.Vehicles)-1)
		return level_info.Vehicles[rand_i]
