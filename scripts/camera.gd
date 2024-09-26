extends Camera2D

@export var speed : float = 500
var _speed_y :float = speed
var _speed_x :float = _speed_y*(sqrt(3))
var velocity = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	velocity = Vector2(0, 0)
	velocity.x += (%Input.key_right - %Input.key_left)*_speed_x*delta
	velocity.y += (%Input.key_down - %Input.key_up)*_speed_y*delta
	
	self.position += velocity
