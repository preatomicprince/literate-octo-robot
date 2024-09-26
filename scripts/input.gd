extends Node2D

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

func _update_mouse_tile_index() -> void:
		# Viewport size used to offset because camera anchor set to Drag Center mode. Otherwise can't find tile properly
	var viewport_size = get_viewport().get_visible_rect().size
	var mouse_map_pos = %map.screen_to_map_pos(mouse_pos.x - viewport_size.x/2, mouse_pos.y - viewport_size.y/2)
	
	if %map.point_on_map(mouse_map_pos):
		mouse_tile_index = %map.tile_pos_to_index(mouse_map_pos.x, mouse_map_pos.y)
	else:
		mouse_tile_index = -1
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_update_mouse_tile_index()
	
func _handle_selection() -> void:
	var over_tile = %map.get_child(mouse_tile_index)
	if over_tile.has_units:
		# TODO:- Actually pick out a unit, not just child. Occasionally can break
		selected_unit = over_tile.get_child(-1)
		selected_unit.set_selected()
		
func handle_deselection() -> void:
	if selected_unit != null:
		selected_unit.set_unselected()
		selected_unit = null

func _set_unit_movement() -> void:
	if !selected_unit.is_moving:
		selected_unit.move_target_tile_index = mouse_tile_index

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_pos = event.position
		_update_mouse_tile_index()
		
	if event.is_action_pressed("mouse_right"):
		if selected_unit != null:
			_set_unit_movement()
		else:
			_handle_selection()
		
	if event.is_action_pressed("mouse_left"):
		handle_deselection()

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
		
