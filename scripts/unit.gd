extends CharacterBody2D

################################################
## Declarations, constants and node variables ##
################################################
@onready var level_info = get_node("/root/GameVars")

# peer_id of owner
var player_id: int

# Enum to store current direction
enum Direction {
	ur = 0,
	dr = 1,
	dl = 2,
	ul = 3
}

@onready var sprite = get_node("sprite")

@onready var nav = $NavigationAgent2D
var accel = 7
@onready var highlight = $highlight

@export var speed = 100
var _speed_y :float = speed
var _speed_x :float = _speed_y*(sqrt(3))

var velo = Vector2(0, 0)

var direction : Direction = 0

# Index in map tile list for current location (parent)
var tile_index : Vector2
var target_tile : Vector2
# Unique names dont work moving up the tree here, so these variables point to key nodes
var map
var input

# 1 if currently selected
var selected : bool = false
var is_moving : bool = false
var distance : Vector2 = Vector2(0, 0)
var move_target_tile_index : Vector2 

var point_list = []

func set_selected() -> void:
	print("yabadaba")
	selected = true
	self.highlight.visible = true
	print(self.highlight.visible)
	
func set_unselected() -> void:
	selected = false
	#self.highlight.visible = false

func _ready() -> void:
	$".".position = get_parent().get_parent().map_to_local(tile_index)
	tile_index = target_tile
	
########################
## _process functions ##
########################

func _set_direction() -> void:
	#var unit_tile_position = map.index_to_tile_pos(tile_index)

	if $".".velocity[0] > 0:
		direction = 0
	if $".".velocity[0] < 0:
		direction = 1
	if $".".velocity[1] > 0:
		direction = 2
	if $".".velocity[0] < 0:
		direction = 3
		
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
		
		self.position.x = 0
		self.position.y = map.HALF_TILE_H
		self.distance = Vector2(0, 0)
		is_moving = false
		#self.tile_index = move_target_tile_index
		move_target_tile_index = Vector2(1, 1)
		_set_animation()

func _handle_movement(delta) -> void:
	if move_target_tile_index != Vector2(0, 0):
		return
		
	var unit_tile_position = map.index_to_tile_pos(tile_index)
	var target_tile_position = map.index_to_tile_pos(move_target_tile_index)
	
	# Temp. Check if tile is next to it
	var next_on_x = (target_tile_position.x == unit_tile_position.x + 1 or target_tile_position.x == unit_tile_position.x - 1)
	var next_on_y = (target_tile_position.y == unit_tile_position.y + 1 or target_tile_position.y == unit_tile_position.y - 1)
	
	# If can move to tile
	if  next_on_x != next_on_y: # != functions as XOR here
		is_moving = true

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
func _prcess(delta: float) -> void:
	var direction = Vector3()
	###this bit works out whats being explored
	level_info.map_info[str(get_parent().get_parent().local_to_map($".".position))][6] = true
	
	###this deletes the current saved unit, used to remove tiles its no longer on before it moves tile
	level_info.map_info[str(get_parent().get_parent().local_to_map($".".position))][3] = 0
	
	if tile_index != target_tile:
		point_list
		nav.target_position = get_parent().get_parent().map_to_local(target_tile) #get_global_mouse_position()
		direction = nav.get_next_path_position() - global_position
		direction = direction.normalized()
	
		velocity = velocity.lerp(direction * speed, accel * delta)
		
		move_and_slide()
		_set_direction()
		_set_animation()
		
		print($".".velocity)
		#_handle_movement(delta)
	
	###this sets the current position of the unit to have a unit
	level_info.map_info[str(get_parent().get_parent().local_to_map($".".position))][3] = $"."
	
	if get_parent().get_parent().map_to_local(target_tile) == round($".".position):
		tile_index = target_tile
		
		###gonna need to set both tiles to no unit, has unit respectfully
