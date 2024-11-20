extends Node2D

var peer = ENetMultiplayerPeer.new()
var peer_id: int = 1

const PORT: int = 7777
const IP_ADRESS: String = "192.168.1.196"

var connected_peers: Array = []
var unit_count: int = 0

var input: Dictionary = {}
var camera: Dictionary = {}
var player: Dictionary = {}

enum MONTH {
	January,
	February,
	March,
	April,
	May, 
	June,
	July,
	August,
	September,
	October,
	November,
	December
}

var current_turn: int = 0

var year: int = 1983

# Returns a vec2 in the format (month, year)
func calculate_date() -> Vector2:
	var current_month: int = current_turn%12
	var current_year: int = year + round(current_turn/12)
	return Vector2(current_month, current_year)

func _on_host_pressed() -> void:
	$menu.visible = false
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	set_multiplayer_authority(1)
	$Map/Map_Objects.generate_points_of_interest()
	$Map.generate_nav_grid()
	#load_gamestate(1)
	
	multiplayer.peer_connected.connect(
		func(new_peer_id):
			connected_peers.append(new_peer_id)
			# Create instance on server
			load_local(new_peer_id)
			
			# Create instances on new peer
			rpc_id(new_peer_id, "load_local", new_peer_id)
			#rpc_id(new_peer_id, "load_gamestate", new_peer_id)
			
			# Sets player map and 
			$Map.call_tile_data_sync(new_peer_id)
			$Map.set_all_tiles_invisible(new_peer_id)
			
			# todo: Deprecate, access only when fog of war lifted
			#$Map/Map_Objects.call_tile_data_sync(new_peer_id)
	)

func _on_join_pressed() -> void:
	$menu.visible = false
	peer.create_client(IP_ADRESS, PORT)
	multiplayer.multiplayer_peer = peer
	peer_id = multiplayer.get_unique_id()
	
# Creates instance of local data that in only synced with server, not other clients
# Only need instance on each specific player and one for each player on server
@rpc("reliable")
func load_local(peer_id):
	var new_camera: Camera2D = preload("res://scenes/camera.tscn").instantiate()
	camera[peer_id] = new_camera
	new_camera.peer_id = peer_id
	new_camera.name = "Camera" + str(peer_id)
	add_child(new_camera)
	
	var new_input: Node = preload("res://scenes/input.tscn").instantiate()
	new_input.set_multiplayer_authority(peer_id)
	input[peer_id] = new_input
	new_input.name = "Input" + str(peer_id)
	new_input.peer_id = peer_id
	add_child(new_input)
	
	var new_player: Node = preload("res://scenes/player.tscn").instantiate()
	new_player.peer_id = peer_id
	new_player.peer_id = peer_id
	player[peer_id] = new_player
	add_child(new_player)
	new_player.name = "Player" + str(peer_id)
	

# Synced continually between all peers
# One per peer
@rpc("reliable")
func load_gamestate(peer_id):
	var new_gamestate: Node = preload("res://scenes/game_state.tscn").instantiate()
	new_gamestate.name = "Game_State"
	add_child(new_gamestate)
	
	var new_map: Node = preload("res://scenes/ground_map.tscn").instantiate()
	new_map.name = "Map"
	add_child(new_map)
	
func _select_tile(peer_id):
	player[peer_id].selected_tile = input[peer_id].mouse_pos
	_select_unit(peer_id)
	
func _select_unit(peer_id):
	var selected_tile: Vector2i = player[peer_id].selected_tile
	if selected_tile == Vector2i(-1, -1):
		return
		
	var selected_tile_str: String = str(selected_tile)
	if not $Map.units.has(selected_tile_str):
		return
	if $Map.units[selected_tile_str] == null:
		return
	
	player[peer_id].selected_unit = $Map.units[selected_tile_str]
	player[peer_id].selected_unit.set_selected(true)
	
func _deselect_all(peer_id):
	player[peer_id].selected_tile = Vector2i(-1, -1)
	if player[peer_id].selected_unit == null:
		return
	player[peer_id].selected_unit.set_selected(false)
	player[peer_id].selected_unit = null
	
func _set_unit_navigation(peer_id):
	var player: Node = player[peer_id]
	var input: Node = input[peer_id]
	
	if player.selected_unit == null:
		return
	if not player.selected_unit.nav_path.is_empty():
		return
		
	var nav_path: Array = $Map.nav_grid.get_id_path($Map.local_to_map(player.selected_unit.position), input.mouse_pos).slice(1)
	
	player.selected_unit.nav_path = nav_path
	
func _handle_input(peer_id: int):
	var EVENT_TYPE = input[peer_id].EVENT_TYPE
	var input: Node = input[peer_id]
	
	while not input.event_queue.is_empty():
		var event = input.event_queue.pop_front()
		
		match event:
			EVENT_TYPE.key_left:
				camera[peer_id].velocity.x -= 1
			EVENT_TYPE.key_right:
				camera[peer_id].velocity.x += 1
			EVENT_TYPE.key_up:
				camera[peer_id].velocity.y -= 1
			EVENT_TYPE.key_down:
				camera[peer_id].velocity.y += 1
			EVENT_TYPE.mouse_left:
				if player[peer_id].selected_unit == null:
					_select_tile(peer_id)
				else:
					_set_unit_navigation(peer_id)
			EVENT_TYPE.mouse_right:
				_deselect_all(peer_id)
				
			EVENT_TYPE.key_e:
				$Map.spawn_new_unit(peer_id, input.mouse_pos)
	
	###this allows the ui to move with the camera
	#camera[peer_id].position.x += (input[peer_id].key_right - input[peer_id].key_left)*_speed_x*delta
	#camera[peer_id].position.y += (input[peer_id].key_down - input[peer_id].key_up)*_speed_y*delta
	
func _process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	for peer_id in connected_peers:
		_handle_input(peer_id)
