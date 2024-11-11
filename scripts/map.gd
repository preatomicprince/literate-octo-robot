extends Node2D

################################################
## Declarations, constants and node variables ##
################################################

var tiles : Array
@export var map_size_x : int = 100
@export var map_size_y : int = 100
const TILE_W = 222.0
const TILE_H = 128.0
const HALF_TILE_W = TILE_W/2
const HALF_TILE_H = TILE_H/2


#######################################
## Map and screen position functions ##
#######################################

# Returns index for self.tiles[] from a given map position
func tile_pos_to_index(pos_x, pos_y) -> int:
	pos_x = int(pos_x)
	pos_y = int(pos_y)
	return (map_size_x*pos_y + pos_x)
	
# Returns a tile's x and y in map grid from tile list index
func index_to_tile_pos(index) -> Vector2:
	var tile_pos = Vector2(0,0)
	tile_pos.y = int(index/map_size_x)
	tile_pos.x =  index - tile_pos.y*map_size_x
	return tile_pos

# Returns screen position for given map pos
func map_to_screen_pos(pos_x, pos_y) -> Vector2:
	var screen_pos = Vector2(0, 0)
	screen_pos.x = ((pos_x - pos_y)*HALF_TILE_W + %camera.offset.x)
	screen_pos.y = ((pos_x + pos_y)*HALF_TILE_H + %camera.offset.y)
	return screen_pos

# Returns map pos from a given position on screen
func screen_to_map_pos(pos_x, pos_y) -> Vector2:
	var map_pos = Vector2(0, 0)
	map_pos.x = ((pos_x + %camera.offset.x * %camera.zoom.x) / (TILE_W * %camera.zoom.x) + (pos_y + %camera.offset.y * %camera.zoom.x) / (TILE_H * %camera.zoom.x) )
	map_pos.y = ((pos_y + %camera.offset.y * %camera.zoom.x)/(TILE_H * %camera.zoom.x)  - (pos_x + %camera.offset.x * %camera.zoom.x)/(TILE_W * %camera.zoom.x) )
	return map_pos

# Returns true if map position is within the map's bounds
func point_on_map(pos) -> bool:
	return (0 <= pos.x and pos.x < self.map_size_x) and (0 <= pos.y and pos.y < self.map_size_y)


######################
## _Ready functions ##
######################

# Inits number of tiles based upon map size
func load_all_tile_instances() -> void:
	var index = 0
	for y in range(map_size_y):
		for x in range(map_size_x):
			var new_tile = load("res://scenes/tile.tscn")
			var tile_instance = new_tile.instantiate()
			tile_instance.index = index
			index += 1
			tile_instance.input = get_node("%input")
			tile_instance.position = map_to_screen_pos(x, y)
			self.add_child(tile_instance)
			
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_all_tile_instances()


########################
## _process functions ##
########################

# Sets tile with mouse over to be highlighted
func update_highlighted_tile() -> void:
	get_child(%input.highlighted_tile_index).highlight.visible = false
	if %input.mouse_tile_index >= 0:
		%input.highlighted_tile_index = %input.mouse_tile_index
		get_child(%input.mouse_tile_index).highlight.visible = true
	
	##
	## Temp function to spawn units on command
	##
	if %input.key_s:
		get_child(%input.highlighted_tile_index).spawn_unit()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	update_highlighted_tile()
