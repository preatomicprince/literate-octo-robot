extends Camera2D

################################################
## Declarations, constants and node variables ##
################################################

@export var speed : float = 500.0
@export var zoom_speed : float = 0.5

@onready var _speed_y :float = speed*(1/$".".zoom.x)
@onready var _speed_x :float = _speed_y*(sqrt(3))

const MAX_ZOOM = 1.0
const MIN_ZOOM = 0.1
var velocity = Vector2(0,0)

var peer_id: int
#########################
## _proccess functions ##
#########################
@rpc
func sync(auth_offset):
	offset = auth_offset
	
func update_zoom(delta: float) -> void:
	if self.zoom.x < MIN_ZOOM:
		%input.key_zoom_in = 0 
	if self.zoom.x > MAX_ZOOM:
		%input.key_zoom_out = 0
		
	self.zoom.x  += (%input.key_zoom_out - %input.key_zoom_in)*zoom_speed*delta
	self.zoom.y = zoom.x
	_speed_y = speed*(1/zoom.x)
	_speed_x = _speed_y*(sqrt(3))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	var prev_offset = offset
	
	velocity.x += velocity.x*_speed_x*delta
	velocity.y += velocity.y*_speed_y*delta	
	
	offset += velocity
	
	# Sync only when change occurs
	if offset != prev_offset:
		rpc_id(peer_id, "sync", offset)
	velocity = Vector2(0, 0)
