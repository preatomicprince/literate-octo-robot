extends Node2D

###############################################
## Declarations, constants and node variables #
###############################################

var tiles : Array
@export var map_size_x : int = 8
@export var map_size_y : int = 8
const TILE_W = 222.0
const TILE_H = 128.0
const HALF_TILE_W = TILE_W/2
const  HALF_TILE_H = TILE_H/2

######################################
## Map and screen position functions #
######################################

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
	screen_pos.x = ((pos_x - pos_y)*HALF_TILE_W + %camera.position.x)
	screen_pos.y = ((pos_x + pos_y)*HALF_TILE_H + %camera.position.y)
	return screen_pos

# Returns map pos from a given position on screen
func screen_to_map_pos(pos_x, pos_y) -> Vector2:
	var map_pos = Vector2(0, 0)
	map_pos.x = ((pos_x + %camera.position.x) / TILE_W + (pos_y + %camera.position.y) / TILE_H)
	map_pos.y = ((pos_y + %camera.position.y)/TILE_H - (pos_x + %camera.position.x)/TILE_W)
	return map_pos

# Returns true if map position is within the map's bounds
func point_on_map(pos) -> bool:
	return (0 <= pos.x and pos.x < self.map_size_x) and (0 <= pos.y and pos.y < self.map_size_y)

#####################
## _Ready functions #
#####################

# Inits number of tiles based upon map size
func load_all_tile_instances() -> void:
	for y in range(map_size_y):
		for x in range(map_size_x):
			var new_tile = load("res://scenes/tile.tscn")
			var tile_instance = new_tile.instantiate()
			tile_instance.position = map_to_screen_pos(x, y)
			self.add_child(tile_instance)
			
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_all_tile_instances()

#######################
## _process functions #
#######################

# Sets tile with mouse over to be highlighted
func update_highlighted_tile() -> void:
	get_child(%Input.highlighted_tile_index).highlight.visible = false
	
	var mouse_map_pos = screen_to_map_pos(%Input.mouse_pos.x, %Input.mouse_pos.y)	
	if point_on_map(mouse_map_pos):
		var index = tile_pos_to_index(mouse_map_pos.x, mouse_map_pos.y)
		get_child(index, true).highlight.visible = true
		%Input.highlighted_tile_index = index
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_highlighted_tile()
