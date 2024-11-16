extends Node

var event_queue = []
var mouse_pos: Vector2 = Vector2(-1, -1)
var peer_id

enum EVENT_TYPE {
	key_left,
	key_right,
	key_up,
	key_down,
	key_e,
	mouse_left,
	mouse_right
}
func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return
	if event is InputEventMouseMotion:
		mouse_pos = $".."/Map.local_to_map($".."/Map.get_local_mouse_position())# + $"..".camera[peer_id].offset)
		rpc_id(1, "sync_mouse_pos", mouse_pos)
	
func _process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
		
	var event_type
	
	if Input.is_action_pressed("key_left"):
		event_type = EVENT_TYPE.key_left
		rpc_id(1, "push_event_to_server", event_type)
		
	if Input.is_action_pressed("key_right"):
		event_type = EVENT_TYPE.key_right
		rpc_id(1, "push_event_to_server", event_type)
		
	if Input.is_action_pressed("key_up"):
		event_type = EVENT_TYPE.key_up
		rpc_id(1, "push_event_to_server", event_type)
		
	if Input.is_action_pressed("key_down"):
		event_type = EVENT_TYPE.key_down
		rpc_id(1, "push_event_to_server", event_type)
	
	if Input.is_action_just_pressed("key_e"):
		print(mouse_pos)
		event_type = EVENT_TYPE.key_e
		rpc_id(1, "push_event_to_server", event_type)
		
	if Input.is_action_pressed("key_esc"):
		get_tree().quit() 

# Channel 2 is reserved for transfering input to server
@rpc("authority", "unreliable", "call_remote", 2)
func push_event_to_server(event):
	event_queue.push_back(event)
	
@rpc("authority", "unreliable", "call_remote", 2)
func sync_mouse_pos(auth_mouse_pos):
	mouse_pos = auth_mouse_pos

	
