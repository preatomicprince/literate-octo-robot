extends TileMapLayer

###this refers to the data structure
@onready var level_info = get_node("/root/GameVars")

var width : int = 500
var height : int = 500

var rand_i = RandomNumberGenerator.new()

func _ready() -> void:
	generate_map()
	#$"map objects".generate_points_of_interest()

func _process(delta: float) -> void:
	
	var tile_pos = $".".local_to_map($".".get_local_mouse_position())
	###dont need this tile data function right now, but could be usful later on
	#var tile_data = $".".get_cell_tile_data(tile_pos)
	#print(tile_data)
	var tile_world_pos = $".".map_to_local(tile_pos) 
	#print("Tile world position: ", tile_world_pos)
	$test_highlight.position = tile_world_pos


func generate_map():
	###this function generates the tile map upon load
	var tile_pos = local_to_map(Vector2(0, 0))
	
	for x in range(width):
		for y in range(height):
			
			###this is just a test, right now it just places one of two tiles on the tile map based on if
			###the random number generator is one or two
			###in future those numbers could be dictated by noise maps or whatever map script we end up
			### generating
			var one_or_two = rand_i.randi_range(0, 1)
			if one_or_two == 0:
				set_cell(Vector2i(tile_pos.x + x, tile_pos.y + y), 0, Vector2i(0, 0))
			else:
				set_cell(Vector2i(tile_pos.x + x, tile_pos.y + y), 0, Vector2i(1, 0))
			
			###this appends to the map info data structure
			level_info.map_info.append([tile_pos.x + x, tile_pos.y + y, ["yes"]])
	print(level_info.map_info[0][2][0])
