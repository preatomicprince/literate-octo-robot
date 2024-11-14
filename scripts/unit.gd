extends Node2D

################################################
## Declarations, constants and node variables ##
################################################

# Enum to store current direction
enum Direction {
	ur = 0,
	dr = 1,
	dl = 2,
	ul = 3
}

@onready var sprite = get_node("sprite")

var highlight
@export var speed = 50
var _speed_y :float = speed
var _speed_x :float = _speed_y*(sqrt(3))

var velocity = Vector2(0, 0)

var direction : Direction = 0

# Index in map tile list for current location (parent)
var tile_index : int

# Unique names dont work moving up the tree here, so these variables point to key nodes
var map
var input

# 1 if currently selected
var selected : int = 0
var is_moving : bool = false
var distance : Vector2 = Vector2(0, 0)
var move_target_tile_index : int = -1

func set_selected() -> void:
	print("yabadaba")
	selected = true
	self.highlight.visible = true
	print(self.highlight.visible)
	
func set_unselected() -> void:
	selected = false
	#self.highlight.visible = false

func _ready() -> void:
	position = Vector2(0, map.HALF_TILE_H)
	highlight = get_node("highlight")
	
########################
## _process functions ##
########################

func _set_direction(target_position) -> void:
	var unit_tile_position = map.index_to_tile_pos(tile_index)

	if unit_tile_position.y > target_position.y:
		direction = 0
		velocity = Vector2(_speed_x, -_speed_y)
	if unit_tile_position.x < target_position.x:
		direction = 1
		velocity = Vector2(_speed_x, _speed_y)
	if unit_tile_position.y < target_position.y:
		direction = 2
		velocity = Vector2(-_speed_x, _speed_y)
	if unit_tile_position.x > target_position.x:
		direction = 3
		velocity = Vector2(-_speed_x, -_speed_y)
		
func _set_animation() -> void:
	if direction == 2 or direction == 3:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
		
	if is_moving:
		if direction == 0 or direction == 3:
			sprite.play("run_u")
		else:
			sprite.play("run_d")
		
	else:
		if direction == 0 or direction == 3:
			sprite.play("idle_u")
		else:
			sprite.play("idle_d")
		
func check_reached_target():
	if distance.x >= map.HALF_TILE_W or distance.y >= map.HALF_TILE_H:
		map.get_child(tile_index).has_units = false
		map.get_child(tile_index).remove_child(self)
		map.get_child(move_target_tile_index).add_child(self)
		map.get_child(move_target_tile_index).has_units = true
		self.position.x = 0
		self.position.y = map.HALF_TILE_H
		self.distance = Vector2(0, 0)
		is_moving = false
		self.tile_index = move_target_tile_index
		move_target_tile_index = -1
		_set_animation()

func _handle_movement(delta) -> void:
	if move_target_tile_index < 0:
		return
		
	var unit_tile_position = map.index_to_tile_pos(tile_index)
	var target_tile_position = map.index_to_tile_pos(move_target_tile_index)
	
	# Temp. Check if tile is next to it
	var next_on_x = (target_tile_position.x == unit_tile_position.x + 1 or target_tile_position.x == unit_tile_position.x - 1)
	var next_on_y = (target_tile_position.y == unit_tile_position.y + 1 or target_tile_position.y == unit_tile_position.y - 1)
	
	# If can move to tile
	if  next_on_x != next_on_y: # != functions as XOR here
		is_moving = true
		_set_direction(target_tile_position)
		_set_animation()
	else:
		# TODO:- Find why this stops the input making any more selections, but left clicking doesn't 
		input.handle_deselection()
		return
		
	if is_moving:
		position += velocity*delta
		distance.x += abs(velocity.x)*delta
		distance.y += abs(velocity.y)*delta
		check_reached_target()
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
		_handle_movement(delta)
	
