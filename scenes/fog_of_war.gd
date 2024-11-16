extends TileMapLayer

@onready var level_info = $".."/".."/Game_State

func _process(delta: float) -> void:
	for key in level_info.map_info.keys():
		if level_info.map_info[key][6] == true:
			map_reveal(key)

func generate_fog():
	for tile in $"..".tiles:
		set_cell(tile , 0, Vector2i(0, 0))

func map_reveal(tile):
	tile = Vector2i(tile)
	set_cell(tile,                   0, Vector2i(-1, -1))
	set_cell(tile + Vector2i(0, 1),  0, Vector2i(-1, -1))
	set_cell(tile + Vector2i(-1, 0), 0, Vector2i(-1, -1))
	set_cell(tile + Vector2i(1, 0),  0, Vector2i(-1, -1))
	set_cell(tile + Vector2i(0, -1), 0, Vector2i(-1, -1))
	set_cell(tile + Vector2i(0, -2), 0, Vector2i(-1, -1))
	set_cell(tile + Vector2i(0, 2),  0, Vector2i(-1, -1))
	
	###these take into account the fact that the numbers have different behaviour depending
	###on whether the unit is on and even tile or odd tile
	if tile.y % 2 == 0:
		set_cell(tile + Vector2i(-1, -1), 0, Vector2i(-1, -1))
		set_cell(tile + Vector2i(-1, 1), 0, Vector2i(-1, -1))
		
	else:
		set_cell(tile + Vector2i(1, 1), 0, Vector2i(-1, -1))
		set_cell(tile + Vector2i(1, -1), 0, Vector2i(-1, -1))
	
