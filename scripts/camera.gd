extends Camera2D

@export var speed : float = 500.0
@export var zoom_speed : float = 0.5

@onready var _speed_y :float = speed*(1/%camera.zoom.x)
@onready var _speed_x :float = _speed_y*(sqrt(3))

const MAX_ZOOM = 1.0
const MIN_ZOOM = 0.1
var velocity = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func update_zoom(delta: float) -> void:
	print(zoom.x)
	if self.zoom.x < MIN_ZOOM:
		%Input.key_zoom_in = 0 
	if self.zoom.x > MAX_ZOOM:
		%Input.key_zoom_out = 0
		
	self.zoom.x  += (%Input.key_zoom_out - %Input.key_zoom_in)*zoom_speed*delta
	self.zoom.y = zoom.x
	_speed_y = speed*(1/%camera.zoom.x)
	_speed_x = _speed_y*(sqrt(3))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	velocity = Vector2(0, 0)
	velocity.x += (%Input.key_right - %Input.key_left)*_speed_x*delta
	velocity.y += (%Input.key_down - %Input.key_up)*_speed_y*delta
	
	update_zoom(delta)
	
	
	self.offset += velocity
