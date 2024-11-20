extends TileMapLayer

###this refers to the data structure
@onready var level_info = $".."/Game_State
@onready var unit = preload("res://scenes/unit.tscn")

@export var width : int = 10
@export var height : int = 10

###
### Dictionaries to store map data
### Only synced with player when fog of war is lifted
###

var tiles = []
var units = {}
var objects = {}

var rand_i = RandomNumberGenerator.new()

###to save the tile between clicks
var selected_ground_tile

func _ready() -> void:
	generate_map()
	$Map_Objects.generate_points_of_interest()
	if not is_multiplayer_authority():
		$Fog_Of_War.generate_fog()

func _process(delta: float) -> void:
	var tile_pos = $".".local_to_map($".".get_local_mouse_position())
	###dont need this tile data function right now, but could be usful later on
	#var tile_data = $".".get_cell_tile_data(tile_pos)
	var tile_world_pos = $".".map_to_local(tile_pos) 
	$Highlight.position = tile_world_pos



func generate_map():
	###this function generates the tile map upon load
	var tile_pos = local_to_map(Vector2(10, 10))

	for x in range(width):
		for y in range(height):
			
			###this is just a test, right now it just places one of two tiles on the tile map based on if
			###the random number generator is one or two
			###in future those numbers could be dictated by noise maps or whatever map script we end up
			### generating
			
			# Randomly pick index for tile in tilemap
			var tile_type = rand_i.randi_range(0, 1)
			set_cell(Vector2i(tile_pos.x + x, tile_pos.y + y), 0, Vector2i(tile_type, 0))
			
			var tile_pos_str = str(Vector2i(tile_pos.x + x, tile_pos.y + y))

			tiles.append(Vector2i(tile_pos.x + x, tile_pos.y + y))
			# If server, automatically discover all tiles and store data in dictionaries
			# A list of visible tiles is availiable in the player node
			if is_multiplayer_authority():
				units[tile_pos_str] = null
				objects[tile_pos_str] = null
			else:
				$"..".player[$"..".peer_id].tile_is_visible[tile_pos_str] = false
			
func set_all_tiles_invisible(peer_id):
	for tile in tiles:
		$"..".player[peer_id].tile_is_visible[str(tile)] = false


# Used to tile_map_data in a packedByteArray
# Should take get_tile_map_data_as_array() as argument from server
@rpc("reliable")
func sync_initial_tile_data(peer_id, auth_packed_array):
	set_tile_map_data_from_array(auth_packed_array)
	set_all_tiles_invisible(peer_id)
		


# Called once when player joins to get initial map state
func call_tile_data_sync(peer_id):
	rpc_id(peer_id, "sync_initial_tile_data", peer_id, get_tile_map_data_as_array())
	
@rpc("reliable")
func generate_unit(peer_id: int, map_pos: Vector2i):
	# Don't spawn if tile already has unit
	if units[str(map_pos)] != null:
		return
		
	var unit_instance = unit.instantiate()
	unit_instance.tile_index = map_pos
	unit_instance.position = map_to_local(map_pos)
	unit_instance.player_id = peer_id
	units[str(map_pos)] = unit_instance
	$Unit_Layer.add_child(unit_instance)
	
	if is_multiplayer_authority():
		$Fog_Of_War.map_reveal(peer_id, map_pos)


# Adds new unit to game
func spawn_new_unit(peer_id: int, map_pos: Vector2i):
	var map_pos_str = str(map_pos)
	
	# Check if tile exists
	if not units.has(map_pos_str):
		return
		
	# Check tile has no unit
	if units[(map_pos_str)] != null:
		return
		
	generate_unit(peer_id, map_pos)
	rpc_id(peer_id, "generate_unit", peer_id, map_pos)
	
	# Only appears to others if player has discovered tile
	for peer in $"..".connected_peers:
		if peer == peer_id:
			continue
		if $"..".player[peer].tile_is_visible[map_pos_str]:
			rpc_id(peer, "generate_unit", peer_id, map_pos)

# Adds an existing unit to a peer's game when it comes out the fog of war
func spawn_existing_unit(peer_id: int, map_pos: Vector2i):
	# Can't spawn existing unit on non-existing tile
	if not units.has(str(map_pos)):
		return
	# Can't spawn existing unit if none on tile
	if units[str(map_pos)] == null:
		return
		
	var unit_owner_id = units[str(map_pos)].player_id
	
	rpc_id(peer_id, "generate_unit", unit_owner_id, map_pos)
	
	
###not to stay just to test
func _inut(event: InputEvent) -> void:
	###this is for selecting a unit
	if event.is_action_pressed("mouse_left"):
		for key in level_info.map_info.keys():
			if level_info.map_info[key][3] is Object:
				level_info.map_info[key][3].set_unselected()
		
		if level_info.map_info[str($".".local_to_map($".".get_local_mouse_position()))][3] is Object:
			level_info.map_info[str($".".local_to_map($".".get_local_mouse_position()))][3].set_selected()
		
	if event.is_action_pressed("mouse_right"):
		for key in level_info.map_info.keys():
			if level_info.map_info[key][3] is Object:
				if level_info.map_info[key][3].selected == true:
					if level_info.map_info[str($".".local_to_map($".".get_local_mouse_position()))][3] is not Object:
						level_info.map_info[key][3].target_tile = Vector2(level_info.map_info[str($".".local_to_map($".".get_local_mouse_position()))][0], level_info.map_info[str($".".local_to_map($".".get_local_mouse_position()))][1])
						level_info.map_info[key][3].set_unselected()
