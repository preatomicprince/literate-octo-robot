extends TileMapLayer

###this refers to the data structure
@onready var level_info = $".."/Game_State
@onready var unit = preload("res://scenes/unit.tscn")
@export var width : int = 5
@export var height : int = 5

const TILE_SIZE = Vector2(222, 128)
@onready var settlement = preload("res://scenes/settlement.tscn")
@onready var narrative_box = preload("res://user interface/narrative_events.tscn")
@onready var highlight = $Highlight

var nav_grid: AStarGrid2D
###
### Dictionaries to store map data
### Only synced with player when fog of war is lifted
###

var tiles = []
var units = {}
var buildings = {}
var objects = {}

var unit_count = 789
var rand_i = RandomNumberGenerator.new()

###to save the tile between clicks
var selected_ground_tile

func generate_nav_grid() -> void:
	nav_grid = AStarGrid2D.new()
	# CellShape.CELL_SHAPE_ISOMETRIC_DOWN = 2
	nav_grid.cell_shape = 2
	nav_grid.cell_size = TILE_SIZE
	nav_grid.region = get_used_rect()
	nav_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	nav_grid.update()
	
func _ready() -> void:
	
	generate_map()

	if not is_multiplayer_authority():
		$Fog_Of_War.generate_fog()

func _process(delta: float) -> void:
	var tile_pos = $".".local_to_map($".".get_local_mouse_position())
	###dont need this tile data function right now, but could be usful later on
	#var tile_data = $".".get_cell_tile_data(tile_pos)
	var tile_world_pos = $".".map_to_local(tile_pos) 
	$Highlight.position = tile_world_pos
	#print("Tile world position: ", tile_world_pos)
	if level_info.hover == false:
		highlight.visible = true
		highlight.position = tile_world_pos
	else:
		highlight.visible = false



func generate_map():
	###this function generates the tile map upon load
	var tile_pos = local_to_map(Vector2(width, height))

	for x in range(width):
		for y in range(height):
			# Randomly pick index for tile in tilemap
			var tile_type = rand_i.randi_range(0, 1)
			set_cell(Vector2i(x, y), 0, Vector2i(tile_type, 0))
			
			var tile_pos_str = str(Vector2i(x, y))

			tiles.append(Vector2i(x, y))
			# If server, automatically discover all tiles and store data in dictionaries
			# A list of visible tiles is availiable in the player node
			if is_multiplayer_authority():
				units[tile_pos_str] = null
				objects[tile_pos_str] = null
				buildings[tile_pos_str] = null
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
func generate_unit(peer_id: int, map_pos: Vector2i, unit_count: int):
	# Don't spawn if tile already has unit
	if units[str(map_pos)] != null:
		return
		
	var unit_instance = unit.instantiate()
	unit_instance.tile_index = map_pos
	unit_instance.position = map_to_local(map_pos)
	unit_instance.player_id = peer_id
	unit_instance.unit_id = unit_count
	unit_instance.name = "Unit" + str(unit_count)
	
	$Unit_Layer.add_child(unit_instance)
	units[str(map_pos)] = unit_instance
	
	if is_multiplayer_authority() or peer_id == $"..".peer_id:
		$"..".player[peer_id].units[unit_count] = unit_instance
	
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
	unit_count += 1
	generate_unit(peer_id, map_pos, unit_count)
	rpc("generate_unit", peer_id, map_pos, unit_count)
	
	
	"""# Only appears to others if player has discovered tile
	for peer in $"..".connected_peers:
		if peer == peer_id:
			continue
		if $"..".player[peer].tile_is_visible[map_pos_str]:
			rpc_id(peer, "generate_unit", peer_id, map_pos, unit_count)"""
			

# Adds an existing unit to a peer's game when it comes out the fog of war
func spawn_existing_unit(peer_id: int, map_pos: Vector2i):
	# Can't spawn existing unit on non-existing tile
	if not units.has(str(map_pos)):
		return
	# Can't spawn existing unit if none on tile
	if units[str(map_pos)] == null:
		return
	var unit_id = units[str(map_pos)].unit_id
	var unit_owner_id = units[str(map_pos)].player_id
	
	rpc_id(peer_id, "generate_unit", unit_owner_id, map_pos, unit_id)

@rpc("reliable")
func spawn_object(map_pos: Vector2i, obj_ind: int):
	$Map_Objects.set_cell(map_pos, 0, Vector2i(obj_ind, 0))
	
func spawn_existing_object(peer_id: int, map_pos: Vector2i):
	if not objects.has(str(map_pos)):
		return
	
	if objects[str(map_pos)] == null:
		return
	
	var atlas_x_coord = $Map_Objects.get_cell_atlas_coords(map_pos).x
	rpc_id(peer_id, "spawn_object", map_pos, atlas_x_coord)

@rpc("unreliable_ordered")
func sync_units(auth_units: Dictionary):
	units = auth_units
	

func call_sync_tiles():
	rpc("sync_units", units)

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	
	#call_sync_tiles()
	"""
	###this is just a test, right now it just places one of two tiles on the tile map based on if
	###the random number generator is one or two
	###in future those numbers could be dictated by noise maps or whatever map script we end up
	### generating
	var one_or_two = rand_i.randi_range(0, 1)
	if one_or_two == 0:
		set_cell(Vector2i(tile_pos.x + x, tile_pos.y + y), 0, Vector2i(0, 0))
	else:
		set_cell(Vector2i(tile_pos.x + x, tile_pos.y + y), 0, Vector2i(1, 0))
	
	###this appends to the map info data structure
	###it turns the tile reference into a dictionary key
	var rand_res = rand_i.randi_range(0, 4)
	if rand_res > 3:
		###adding two on the end for the settlment info, i know the dictionary needs switch up, but move fast and break stuff, become ungovernable
		level_info.map_info[str("(", tile_pos.x + x,", ",tile_pos.y + y,")")] = [ tile_pos.x + x,tile_pos.y + y,"no unit", 0, "yes", 0, false, "no settlement", null]
	else:
		level_info.map_info[str("(", tile_pos.x + x,", ",tile_pos.y + y,")")] = [ tile_pos.x + x,tile_pos.y + y,"no unit", 0, "no", 0, false, "no settlement", null]

func generate_unit(position, start_pop):
	var unit_instance = unit.instantiate()
	unit_instance.percent_ready = start_pop
	unit_instance.tile_index = position
	$"unit layer".add_child(unit_instance)
	
func generate_settlement(position, start_pop):
	###this function creates a settlement the spot of the unit that spawns it
	var new_settlement = settlement.instantiate()
	new_settlement.position = position
	new_settlement.population = start_pop
	$"settlement layer".add_child(new_settlement)
	
	###this adds the object to the dictionary
	level_info.map_info[str($".".local_to_map(position))][7] = "has settlement"
	level_info.map_info[str($".".local_to_map(position))][8] = new_settlement


###not to stay just to test
func _input(event: InputEvent) -> void:
	###this is just to test out spawning settlements, the unit will lose some of its percent_ready
	###which will go into the new town. or you could dismand the entire unit into the town
	if event.is_action_pressed("key_r"):
		if level_info.unit_selected != null:
			
			###so this will pop up the narrative event slider 
			if level_info.map_info[str($".".local_to_map(level_info.unit_selected.position))][7] == "no settlement":
				var pop_up = narrative_box.instantiate()
				###this adds the event to the main game scene
				pop_up.purpose = "pop transfer"
				###it takes the unit for its location and stuff
				pop_up.started_event = level_info.unit_selected
				pop_up.target = level_info.map_info[str($".".local_to_map(level_info.unit_selected.position))]
				###it adds it to the parent, the main game node
				self.get_parent().get_node("narrative layer").add_child(pop_up)
			else:
				var pop_up = narrative_box.instantiate()
				pop_up.purpose = "pop transfer"
				pop_up.started_event = level_info.unit_selected
				pop_up.target = level_info.map_info[str($".".local_to_map(level_info.unit_selected.position))]
				self.get_parent().get_node("narrative layer").add_child(pop_up)
	
	if event.is_action_pressed("key_e"):
		if level_info.map_info[str($".".local_to_map($".".get_local_mouse_position()))][3] is not Object:
			generate_unit(Vector2(level_info.map_info[str($".".local_to_map($".".get_local_mouse_position()))][0], level_info.map_info[str($".".local_to_map($".".get_local_mouse_position()))][1]), 10)
			for key in level_info.map_info.keys():
				if level_info.map_info[key][3] is Object:
					level_info.map_info[key][3].set_unselected()


	###this is for selecting a unit
	###this checks if the ui is being hovered over
	if level_info.hover == false:
		if event.is_action_pressed("mouse_left"):
			#print(str($".".local_to_map($".".get_local_mouse_position())))
			for key in level_info.map_info.keys():
				###this is to unselect all units
				
				if level_info.map_info[key][3] is Object:
					level_info.map_info[key][3].set_unselected()
					###this is for the ui to know whats happening with the unit selection, so it can show what the unit has
				###this is to unselect all towns
				if level_info.map_info[key][8] is Object:
					level_info.map_info[key][8].set_unselected()
					
				level_info.unit_selected = null
				
			###we then work out if theres anything else that needs to be selected 
			###this is for the towns
			if level_info.map_info[str($".".local_to_map($".".get_local_mouse_position()))][8] is Object:
				level_info.map_info[str($".".local_to_map($".".get_local_mouse_position()))][8].set_selected()
				
				###same with this
				level_info.unit_selected = level_info.map_info[str($".".local_to_map($".".get_local_mouse_position()))][8]
			
			###this is for the units. the way this is currently set up if theyre on the same tile, theyll only the unit
			if level_info.map_info[str($".".local_to_map($".".get_local_mouse_position()))][3] is Object:
				level_info.map_info[str($".".local_to_map($".".get_local_mouse_position()))][3].set_selected()
				
				###same with this
				level_info.unit_selected = level_info.map_info[str($".".local_to_map($".".get_local_mouse_position()))][3]
			
	if event.is_action_pressed("mouse_right"):
		for key in level_info.map_info.keys():
			if level_info.map_info[key][3] is Object:
				if level_info.map_info[key][3].selected == true:
					if level_info.map_info[str($".".local_to_map($".".get_local_mouse_position()))][3] is not Object:
						level_info.map_info[key][3].target_tile = Vector2(level_info.map_info[str($".".local_to_map($".".get_local_mouse_position()))][0], level_info.map_info[str($".".local_to_map($".".get_local_mouse_position()))][1])
						#level_info.map_info[key][3].set_unselected()
						
						#### and this
						#level_info.unit_selected = null
					
					###to work out the combat
					if level_info.map_info[str($".".local_to_map($".".get_local_mouse_position()))][3] is Object:
						level_info.map_info[key][3].conflict(level_info.map_info[str($".".local_to_map($".".get_local_mouse_position()))][3])
"""
