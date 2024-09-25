extends Camera2D

@export var speed : float = 10
var _speed_y :float = speed
var _speed_x :float = _speed_y*(sqrt(3))
var velocity = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("key_left"):
		self.velocity.x += _speed_x
	if event.is_action_pressed("key_right"):
		self.velocity.x -= _speed_x
	if event.is_action_pressed("key_up"):
		self.velocity.y += _speed_y
	if event.is_action_pressed("key_down"):
		self.velocity.y -= _speed_y

	if event.is_action_released("key_left"):
		self.velocity.x -= _speed_x
	if event.is_action_released("key_right"):    
		self.velocity.x += _speed_x
	if event.is_action_released("key_up"):
		self.velocity.y -= _speed_y
	if event.is_action_released("key_down"):
		self.velocity.y += _speed_y
		
	self.position -= self.velocity
