extends Control

@onready var level_info = get_node("/root/GameVars")

@onready var info_list = [$"res counter/food", $"res counter/turn", $"res counter/pop"]

@onready var slot_list = [$"bottom bar/item holder/slot 1", $"bottom bar/item holder/slot 2", $"bottom bar/item holder/slot 3"]

###turn these off or on depending on if there is a settlement selected or a unit
@onready var unit_slot_list = [$"bottom bar/item holder/slot 1/WeaponIcons", $"bottom bar/item holder/slot 2/Clothing", $"bottom bar/item holder/slot 3/VehicleIcons"]
@onready var building_slot_list = [$"bottom bar/item holder/slot 1/BuildingIcons", $"bottom bar/item holder/slot 2/BuildingIcons2", $"bottom bar/item holder/slot 3/BuildingIcons3"]

###this list helps to change the inventory dynamically
@onready var icon_list = [$"GridContainer/icon buttons", $"GridContainer/icon buttons2", $"GridContainer/icon buttons3", $"GridContainer/icon buttons4", $"GridContainer/icon buttons5",
	$"GridContainer/icon buttons6", $"GridContainer/icon buttons7", $"GridContainer/icon buttons8", $"GridContainer/icon buttons9", $"GridContainer/icon buttons10", $"GridContainer/icon buttons11",
	$"GridContainer/icon buttons12", $"GridContainer/icon buttons13", $"GridContainer/icon buttons14", $"GridContainer/icon buttons15", $"GridContainer/icon buttons16", $"GridContainer/icon buttons17",
	$"GridContainer/icon buttons18", $"GridContainer/icon buttons19", $"GridContainer/icon buttons20"]
var saved_len

var combat_stat_barks = ["big defeat", "defeat", "draw", "small victory", "great success"]

@onready var player_id 

func _ready() -> void:
	#print($".".get_global_position())
	$".".size = get_viewport_rect().size
	$"res counter".size.x = get_viewport_rect().size[0]*2#/get_parent().get_parent().zoom[1]
	$"tempbar".size.x = get_viewport_rect().size[0]*2
	for i in range(len(info_list)):
		info_list[i].position.x =  get_viewport_rect().size[0] / len(info_list)*i+1 
	
	###to make the bottom control node strech relative to the screen
	$"bottom bar".size.x = get_viewport_rect().size[0]*2
	
	###its not doing exaclt what i want but its not the most pressing issue so ill leave it for now
	$"bottom bar".position.y = (get_viewport_rect().size[1] / 0.5) - 100
	
	$"bottom bar/end turn".position.x = $"bottom bar".size.x - $"bottom bar/end turn".size.x -200# - $"bottom bar/Button".size.x
	$"bottom bar/inventory but".position.x = 100
	
	###related to the inventory
	saved_len = 0
	###so that your inventory can be filled
	level_info.inv_max = len(icon_list)
	#print(len(level_info.inventory)-1)
	
func _process(delta: float) -> void:
	####need to make the ui change deynamically at some point
	change_stats($".."/"..".peer_id)

	
func change_stats(player_id):
	
	$"res counter/food".text = "{number} + {change}".format({"number": $".."/".."/"..".player[player_id].food, "change": $".."/".."/"..".player[player_id].food})
	if saved_len != len($".."/".."/"..".player[player_id].items):
		print("what ya doin")
		for i in range(len(icon_list)):
			print("you here")
			icon_list[i].selection = null
		for i in range(len($".."/".."/"..".player[player_id].items)):
			print(i)
			icon_list[i].selection = $".."/".."/"..".player[player_id].items[i]
		saved_len = len($".."/".."/"..".player[player_id].items)
	
func chadnge_stats(player_id):
	###this is to change the inventory dynamically
	
	
	###this will change the pop stat dynamically
	level_info.overall_population = 0
	###this looks through the dictary and see what towns have units and their population
	for key in level_info.map_info.keys():
		if level_info.map_info[key][8] is Object:
			level_info.overall_population += level_info.map_info[key][8].population
	
	###this looks through your units and sees how many people they have
	for key in level_info.map_info.keys():
		if level_info.map_info[key][3] is Object:
			level_info.overall_population += (level_info.map_info[key][3].percent_ready + level_info.map_info[key][3].percent_injured)
	
	
	for i in unit_slot_list:
		i.visible = false
	
	for i in building_slot_list:
		i.visible = false

	###this is to work out how much food youll have dynamically
	var acum = 0
	for key in level_info.map_info.keys():
		if level_info.map_info[key][8] is Object:
			for build in level_info.map_info[key][8].constructed.keys():
				if level_info.map_info[key][8].constructed[build] == level_info.Placeables.FARM:
					acum += 10
	level_info.food_change = (acum - level_info.overall_population)
	#if level_info.food_change >= 0:
		#$"res counter/food".text = "{number} + {change}".format({"number":level_info.player_stats["player one"][0], "change":level_info.food_change})
	#else:
		#$"res counter/food".text = "{number} {change}".format({"number":level_info.player_stats["player one"][0], "change":level_info.food_change})
	
	###for shells
	$"res counter/shells".text = "{number}".format({"number":level_info.shells})
	$"res counter/turn".text = "{number}".format({"number":level_info.turn})
	$"res counter/pop".text = "{number}".format({"number":level_info.overall_population})
	###for showing whats items a current unit has selected
	if level_info.unit_selected != null:
		$"bottom bar/item holder".visible = true
		if level_info.unit_selected.has_method("conflict"):
			for i in unit_slot_list:
				i.visible = true
			$"bottom bar/item holder/slot 1/WeaponIcons".frame = return_icon(level_info.unit_selected.inventory["weapon"])
			$"bottom bar/item holder/slot 2/Clothing".frame = return_icon(level_info.unit_selected.inventory["clothing"])
			$"bottom bar/item holder/slot 3/VehicleIcons".frame = return_icon(level_info.unit_selected.inventory["transport"])
		if level_info.unit_selected.has_method("build"):
			for i in building_slot_list:
				i.visible = true
			$"bottom bar/item holder/slot 1/BuildingIcons".frame = return_icon(level_info.unit_selected.constructed["slot 1"])
			$"bottom bar/item holder/slot 2/BuildingIcons2".frame = return_icon(level_info.unit_selected.constructed["slot 2"])
			$"bottom bar/item holder/slot 3/BuildingIcons3".frame = return_icon(level_info.unit_selected.constructed["slot 3"])
			
	else:
		$"bottom bar/item holder".visible = false
	
	if level_info.fight == true:
		$"bottom bar/tool tip".visible = true
		$"bottom bar/tool tip".text = "[center]{bark} {p} vs {t}[center]".format({"bark": combat_stat_barks[0], "t" : level_info.odds[0], "p" : level_info.odds[1]})
		
	else:
		$"bottom bar/tool tip".visible = false


func _on_button_button_up() -> void:
	level_info.turn += 1
	print("new turn")

func return_icon(item):
	###this function takes what is in the dictionary of the unit and returns an appropriate
	###icon for the ui
	###the length of this is giving undertale vibes
	match item:
		###for the weapons
		level_info.Placeables.HAND:
			#hand
			return 0
		level_info.Placeables.CRICKET_BAT:
			#cricket bat
			return 1
		level_info.Placeables.SHOTGUN:
			#shotgun
			return 2
		level_info.Placeables.SWORD:
			#sword
			return 3
		level_info.Placeables.BOW:
			#bow
			return 4
		level_info.Placeables.ARTILLERY:
			#artillery
			return 5
		level_info.Placeables.MACHINE_GUN:
			
			return 6
		###add the sniper later
		level_info.Placeables.SNIPER:
			#sniper
			return 6
			
		###for the clothes
		level_info.Placeables.RAGS:
			#rags
			return 0
		level_info.Placeables.PLAID:
			#plaid
			return 1
		level_info.Placeables.POLICE:
			#police
			return 2
		level_info.Placeables.WINTER:
			#winter coat
			return 3
		level_info.Placeables.SOILDER:
			#soilder outfit
			return 4
		level_info.Placeables.LEATHER:
			#leather jacket
			return 5
		level_info.Placeables.SHELL:
			#shell suit
			return 6
			
		##for the vehicles
		level_info.Placeables.FOOT:
			return 0
		level_info.Placeables.HORSE:
			return 1
		level_info.Placeables.DONKEY:
			return 2
		level_info.Placeables.BIKE:
			return 3
		level_info.Placeables.BUS:
			return 4
		level_info.Placeables.JEAP:
			return 5
			
		###for the buildings
		level_info.Placeables.EMPTY:
			return 0
		level_info.Placeables.HOUSE:
			return 1
		level_info.Placeables.OUTPOST:
			return 2
		level_info.Placeables.FACTORY:
			return 3
		level_info.Placeables.HOSPITAL:
			return 4
		level_info.Placeables.FARM: 
			return 5
		level_info.Placeables.SHOP:
			return 6
		level_info.Placeables.MINE: 
			return 7
		level_info.Placeables.POWER_STATION: 
			return 8
		level_info.Placeables.COURTHOUSE:
			return 9

###this hover is to block the left clicks fucking with the map
func _on_end_turn_mouse_entered() -> void:
	level_info.hover = true

func _on_inventory_but_mouse_entered() -> void:
	level_info.hover = true

func _on_inventory_but_mouse_exited() -> void:
	level_info.hover = false

func _on_end_turn_mouse_exited() -> void:
	level_info.hover = false


func _on_grid_container_mouse_entered() -> void:
	level_info.hover = true


func _on_grid_container_mouse_exited() -> void:
	level_info.hover = false


func _on_inventory_but_gui_input(event: InputEvent) -> void:
	###this toggles the inventory on and off
	if event.is_action_pressed("mouse_left"):
		if $GridContainer.visible == false:
			$GridContainer.visible = true
		else:
			$GridContainer.visible = false


func _on_end_turn_gui_input(event: InputEvent) -> void:
	###ends the turn
	if event.is_action_pressed("mouse_left"):
		print("this works")
	#if event.is_action_pressed("mouse_left"):
		#level_info.turn += 1
