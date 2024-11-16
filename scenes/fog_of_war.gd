extends TileMapLayer

@onready var level_info = $".."/".."/Game_State

func _process(delta: float) -> void:
	for key in level_info.map_info.keys():
		if level_info.map_info[key][6] == true:
			map_reveal(key)

func generate_fog():
	for key in level_info.map_info.keys():
		set_cell(Vector2i(level_info.map_info[key][0], level_info.map_info[key][1]), 0, Vector2i(0, 0))

func map_reveal(key):
	
	set_cell(Vector2(level_info.map_info[key][0], level_info.map_info[key][1]), 0, Vector2i(-1, -1))
	set_cell(Vector2(level_info.map_info[key][0]-1, level_info.map_info[key][1]), 0, Vector2i(-1, -1))
	set_cell(Vector2(level_info.map_info[key][0]+1, level_info.map_info[key][1]), 0, Vector2i(-1, -1))
	set_cell(Vector2(level_info.map_info[key][0], level_info.map_info[key][1]+1), 0, Vector2i(-1, -1))
	set_cell(Vector2(level_info.map_info[key][0], level_info.map_info[key][1]-1), 0, Vector2i(-1, -1))
	set_cell(Vector2(level_info.map_info[key][0], level_info.map_info[key][1]-2), 0, Vector2i(-1, -1))
	set_cell(Vector2(level_info.map_info[key][0], level_info.map_info[key][1]+2), 0, Vector2i(-1, -1))
	
	###these take into account the fact that the numbers have different behaviour depending
	###on whether the unit is on and even tile or odd tile
	if level_info.map_info[key][1] % 2 == 0:
		set_cell(Vector2(level_info.map_info[key][0]-1, level_info.map_info[key][1]-1), 0, Vector2i(-1, -1))
		set_cell(Vector2(level_info.map_info[key][0]-1, level_info.map_info[key][1]+1), 0, Vector2i(-1, -1))
		level_info.map_info[key][6] = true
		
	else:
		print(Vector2(level_info.map_info[key][0], level_info.map_info[key][1]))
		set_cell(Vector2(level_info.map_info[key][0]+1, level_info.map_info[key][1]+1), 0, Vector2i(-1, -1))
		set_cell(Vector2(level_info.map_info[key][0]+1, level_info.map_info[key][1]-1), 0, Vector2i(-1, -1))
		level_info.map_info[key][6] = true
	#set_cell(Vector2(level_info.map_info[key][0]+1, level_info.map_info[key][1]-1), 0, Vector2i(-1, -1))
	#set_cell(Vector2(level_info.map_info[key][0]-1, level_info.map_info[key][1]+1), 0, Vector2i(-1, -1))
