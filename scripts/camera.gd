extends Camera2D

################################################
## Declarations, constants and node variables ##
################################################

@export var speed : float = 500.0
@export var zoom_speed : float = 0.5

@onready var _speed_y :float = speed*(1/%camera.zoom.x)
@onready var _speed_x :float = _speed_y*(sqrt(3))

const MAX_ZOOM = 1.0
const MIN_ZOOM = 0.1
var velocity = Vector2(0,0)


#########################
## _proccess functions ##
#########################

func update_zoom(delta: float) -> void:
	if self.zoom.x < MIN_ZOOM:
		%input.key_zoom_in = 0 
	if self.zoom.x > MAX_ZOOM:
		%input.key_zoom_out = 0
		
	self.zoom.x  += (%input.key_zoom_out - %input.key_zoom_in)*zoom_speed*delta
	self.zoom.y = zoom.x
	_speed_y = speed*(1/%camera.zoom.x)
	_speed_x = _speed_y*(sqrt(3))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	velocity = Vector2(0, 0)
	velocity.x += (%input.key_right - %input.key_left)*_speed_x*delta
	velocity.y += (%input.key_down - %input.key_up)*_speed_y*delta
	
	update_zoom(delta)
	
	
	self.offset += velocity
