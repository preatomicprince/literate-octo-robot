extends Node2D

@onready var level_info = get_node("/root/GameVars")

var mouse_pos : Vector2 = Vector2(-1, -1)
var mouse_tile_index : int = -1
var key_left : int = 0
var key_right : int = 0
var key_up : int = 0
var key_down : int = 0
var key_zoom_in : int = 0
var key_zoom_out : int = 0
var key_s : int = 0

var highlighted_tile_index : int = -1
var selected_tile_index : int = -1
# Pointer to the currently selected unit
var selected_unit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_pos = event.position

		

	if event.is_action_pressed("key_left"):
		key_left = 1
	if event.is_action_pressed("key_right"):
		key_right = 1
	if event.is_action_pressed("key_up"):
		key_up = 1
	if event.is_action_pressed("key_down"):
		key_down = 1
		
	if event.is_action_pressed("key_s"):
		key_s = 1
		print($"../ground map".local_to_map($"../ground map".get_local_mouse_position()))
		
	if event.is_action_pressed("key_zoom_in"):
		key_zoom_in = 1
	if event.is_action_pressed("key_zoom_out"):
		key_zoom_out = 1
		

	if event.is_action_released("key_left"):
		key_left = 0
	if event.is_action_released("key_right"):    
		key_right = 0
	if event.is_action_released("key_up"):
		key_up = 0
	if event.is_action_released("key_down"):
		key_down = 0
		
	if event.is_action_released("key_zoom_in"):
		key_zoom_in = 0
	if event.is_action_released("key_zoom_out"):
		key_zoom_out = 0
		
	if event.is_action_released("key_s"):
		key_s = 0
	
	if event.is_action_released("new_turn"):
		level_info.turn += 1
