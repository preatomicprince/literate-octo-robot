extends TileMapLayer

###this refers to the data structure
@onready var level_info = get_node("/root/GameVars")
@onready var unit = preload("res://scenes/unit.tscn")
@onready var settlement = preload("res://scenes/settlement.tscn")
@onready var narrative_box = preload("res://user interface/narrative_events.tscn")
@onready var highlight = $test_highlight
var width : int = 20
var height : int = 50

var rand_i = RandomNumberGenerator.new()

###to save the tile between clicks
var selected_ground_tile

func _ready() -> void:
	
	generate_map()
	$"map objects".generate_points_of_interest()
	$"fog of war".generate_fog()
	
	##to generate your first unit upon loading the game
	#if level_info.map_info[str($".".local_to_map($".".get_local_mouse_position()))][3] is not Object:
	generate_unit(Vector2(level_info.map_info[str($".".local_to_map($".".get_local_mouse_position()))][0], level_info.map_info[str($".".local_to_map($".".get_local_mouse_position()))][1]), 10)


func _process(delta: float) -> void:
	
	var tile_pos = $".".local_to_map($".".get_local_mouse_position())
	#print($".".local_to_map($".".get_local_mouse_position()))
	###dont need this tile data function right now, but could be usful later on
	#var tile_data = $".".get_cell_tile_data(tile_pos)
	#print(tile_data)
	var tile_world_pos = $".".map_to_local(tile_pos) 
	#print("Tile world position: ", tile_world_pos)
	if level_info.hover == false:
		highlight.visible = true
		highlight.position = tile_world_pos
	else:
		highlight.visible = false



func generate_map():
	###this function generates the tile map upon load
	var tile_pos = local_to_map(Vector2(10, 10))

	for x in range(width):
		for y in range(height):
			
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
