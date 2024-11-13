extends TileMapLayer

###this refers to the data structure
@onready var level_info = get_node("/root/GameVars")
@onready var unit = preload("res://scenes/unit.tscn")

var width : int = 10
var height : int = 10

var rand_i = RandomNumberGenerator.new()

###to save the tile between clicks
var selected_ground_tile

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
			###it turns the tile reference into a dictionary key
			level_info.map_info[str("(", tile_pos.x + x,", ",tile_pos.y + y,")")] = [ tile_pos.x + x,tile_pos.y + y,"no unit", 0]
	
	

func generate_unit(position):
	
	var unit_instance = unit.instantiate()
	unit_instance.tile_index = position
	$"unit layer".add_child(unit_instance)
	level_info.map_info[str(position)][3] = unit_instance


###not to stay just to test
func _input(event: InputEvent) -> void:
	
	
	if event.is_action_pressed("key_s"):
		if level_info.map_info[str($".".local_to_map($".".get_local_mouse_position()))][3] is not Object:
			generate_unit(Vector2(level_info.map_info[str($".".local_to_map($".".get_local_mouse_position()))][0], level_info.map_info[str($".".local_to_map($".".get_local_mouse_position()))][1]))
			for key in level_info.map_info.keys():
				if level_info.map_info[key][3] is Object:
					level_info.map_info[key][3].set_unselected()

	###this is for selecting a unit
	if event.is_action_pressed("mouse_left"):
		for key in level_info.map_info.keys():
			if level_info.map_info[key][3] is Object:
				level_info.map_info[key][3].set_unselected()
		
		if level_info.map_info[str($".".local_to_map($".".get_local_mouse_position()))][3] is Object:
			level_info.map_info[str($".".local_to_map($".".get_local_mouse_position()))][3].set_selected()
		
	if event.is_action_pressed("mouse_right"):
		for key in level_info.map_info.keys():
			if level_info.map_info[key][3] is Object:
				if level_info.map_info[key][3].selected == true:
					if level_info.map_info[str($".".local_to_map($".".get_local_mouse_position()))][3] is not Object:
						level_info.map_info[key][3].target_tile = Vector2(level_info.map_info[str($".".local_to_map($".".get_local_mouse_position()))][0], level_info.map_info[str($".".local_to_map($".".get_local_mouse_position()))][1])
						level_info.map_info[key][3].set_unselected()
						level_info.map_info[str($".".local_to_map($".".get_local_mouse_position()))][3] = level_info.map_info[key][3]
						level_info.map_info[key][3] = 0
