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
var unit_id: int

var accel = 7

@export var speed = 100
var _speed_y :float = speed
var _speed_x :float = _speed_y*(sqrt(3))

var velo = Vector2(0, 0)

var prev_pos: Vector2 = Vector2(-1, -1) 
var direction : Direction = 0

# Index in map tile list for current location (parent)
var tile_index : Vector2
var target_tile : Vector2
# Unique names dont work moving up the tree here, so these variables point to key nodes
var map
var input

@export var max_moves = 5
@onready var moves_remaining = max_moves
# 1 if currently selected
var selected : bool = false
var is_moving : bool = false
var distance : Vector2 = Vector2(0, 0)
var move_target_tile_index : Vector2 

var nav_path = []

@rpc("reliable")
func sync_select(select: bool) -> void:
	self.selected = select
	$Highlight.visible = select
	
func set_selected(select: bool) -> void:
	self.selected = select
	$Highlight.visible = select
	
	if is_multiplayer_authority():
		rpc_id(player_id, "sync_select", select)
	
func set_unselected() -> void:
	selected = false
	$Highlight.visible = false

########################
## _process functions ##
########################


func _set_direction() -> void:
	var target_pos = self.nav_path.front()
	if tile_index.y > target_pos.y && tile_index.x == target_pos.x:
		direction = Direction.ur
	elif tile_index.x < target_pos.x && tile_index.y == target_pos.y:
		direction = Direction.dr
	elif tile_index.y < target_pos.y && tile_index.x == target_pos.x:
		direction = Direction.dl
	elif tile_index.x > target_pos.x && tile_index.y == target_pos.y:
		direction = Direction.ul


func _set_animation() -> void:
	if direction == 2 or direction == 3:
		$Sprite.flip_h = true
	else:
		$Sprite.flip_h = false
		
	if is_moving:
		if direction == 0 or direction == 3:
			$Sprite.play("run_u")
		else:
			$Sprite.play("run_d")
		
	else:
		if direction == 0 or direction == 3:
			$Sprite.play("idle_u")
		else:
			$Sprite.play("idle_d")
		
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

@rpc
func sync_pos(auth_pos):
	prev_pos = position
	position = auth_pos
	velocity = position - prev_pos
	if $".."/".."/"..".player[$".."/".."/"..".peer_id].tile_is_visible[str($".."/"..".local_to_map(position))]:
		visible = true
	else:
		visible =  false

@rpc
func sync_dir(auth_dir, auth_is_moving):
	direction = auth_dir
	is_moving = auth_is_moving
	
func _process(delta: float) -> void:
	_set_animation()
	if not is_multiplayer_authority():
		return
		
	if nav_path.is_empty() or moves_remaining <= 0:
		is_moving = false
		return
	var target_pos = $".."/"..".map_to_local(self.nav_path.front())
	
	# Checks cost of move to next tile. Disallowed if higher than moves remaining
	if $".."/"..".nav_grid.get_point_weight_scale(self.nav_path.front()) > moves_remaining:
		return
		 
	if $".."/"..".units[str(self.nav_path.front())] != null:
		position = $".."/"..".map_to_local(tile_index)
		nav_path = []
		return
	
	is_moving = true
	prev_pos = position
	position = position.move_toward(target_pos, speed*delta)
	velocity = position - prev_pos
	_set_direction()
	if position == target_pos:
		moves_remaining -= 1;
		$".."/"..".units[str(tile_index)] = null
		tile_index = nav_path.pop_front()
		$".."/"..".units[str(tile_index)] = self
		$".."/".."/Fog_Of_War.map_reveal(player_id, tile_index)

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	"""for peer_id in $".."/".."/"..".connected_peers:
		print($".."/".."/"..".player[peer_id].tile_is_visible[str(tile_index)])
		if $".."/".."/"..".player[peer_id].tile_is_visible[str(tile_index)]:"""
	rpc("sync_pos", position)
	rpc("sync_dir", direction, is_moving)
	
