extends Node2D


var tiles : Array
@export var map_size_x : int = 8
@export var map_size_y : int = 8
const TILE_W = 222.0
const TILE_H = 128.0
const HALF_TILE_W = TILE_W/2
const  HALF_TILE_H = TILE_H/2
var camera
var input

func tile_pos_to_index(pos_x, pos_y) -> int:
	pos_x = int(pos_x)
	pos_y = int(pos_y)
	return (map_size_x*pos_y + pos_x)
	
func map_to_screen_pos(pos_x, pos_y) -> Vector2:
	var screen_pos = Vector2(0, 0)
	screen_pos.x = ((pos_x - pos_y)*HALF_TILE_W + camera.position.x)
	screen_pos.y = ((pos_x + pos_y)*HALF_TILE_H + camera.position.y)
	return screen_pos
	
func screen_to_map_pos(pos_x, pos_y) -> Vector2:
	var map_pos = Vector2(0, 0)
	map_pos.x = ((pos_x + camera.position.x) / TILE_W + (pos_y + camera.position.y) / TILE_H) - 5
	map_pos.y = ((pos_y + camera.position.y)/TILE_H - (pos_x + camera.position.x)/TILE_W)
	return map_pos
	
func point_on_map(pos) -> bool:
	return (0 <= pos.x and pos.x < self.map_size_x) and (0 <= pos.y and pos.y < self.map_size_y)

func load_all_tile_instances() -> void:
	for y in range(map_size_y):
		for x in range(map_size_x):
			var new_tile = load("res://scenes/tile.tscn")
			var tile_instance = new_tile.instantiate()
			var screem_pos = map_to_screen_pos(x, y)
			tile_instance.position = screem_pos
			self.add_child(tile_instance)
			
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera = get_node("../camera")
	input = get_node("%input")
	load_all_tile_instances()


func update_highlighted_tile() -> void:
	var mouse_map_pos = screen_to_map_pos(%Input.mouse_pos.x, %Input.mouse_pos.y)
		
	get_child(%Input.highlighted_tile_index).highlight.visible = false
	if point_on_map(mouse_map_pos):
		var index = tile_pos_to_index(mouse_map_pos.x, mouse_map_pos.y)
		get_child(index, true).highlight.visible = true
		%Input.highlighted_tile_index = index
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_highlighted_tile()
