extends TileMapLayer

@onready var level_info = get_node("/root/GameVars")


func generate_points_of_interest():
	###after the initial map has been generated, we can look at the tiles and figure out 
	###needs to be generated on a seperate layer
	###i.e. towns, animals ect
	
	for i in range(len(level_info.map_info)):
		
		###this is just a test, but it involves going through the list of map info, checking its coresponding
		###list to see if the thing says yes or no
		if level_info.map_info[i][2][0] == "yes":
			set_cell(Vector2i(level_info.map_info[i][0], level_info.map_info[i][1]), 0, Vector2i(1, 0))
