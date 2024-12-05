extends TextureButton

@onready var level_info = get_node("/root/GameVars")

###preload all the image sheets
var building_im = preload("res://assets/building icons.png")
var weapons_im = preload("res://assets/weapon icons.png")
var clothing_im = preload("res://assets/clothing.png")
var vehicles_im = preload("res://assets/vehicle icons.png")
var player_id

@onready var selection = null
var saved_selection

func _ready() -> void:
	
	player_id = $".."/"..".player_id
	
	if selection == null:
		selection = level_info.Placeables.EMPTY
	saved_selection = selection
	var im_data = return_icon(selection)
	$"icon im".texture = im_data[0]
	$"icon im".hframes = im_data[1]
	$"icon im".frame = im_data[2]
	
func _process(delta: float) -> void:
	if saved_selection != selection:
		if selection == null:
			selection = level_info.Placeables.EMPTY
		var im_data = return_icon(selection)
		$"icon im".texture = im_data[0]
		$"icon im".hframes = im_data[1]
		$"icon im".frame = im_data[2]
		saved_selection = selection

func return_icon(item):
	###this function returns the infomation to return the right sprite sheet and image
	###a list that contains which sheet to use, how many frames the sheet has, and what ind 
	###the specific item is at
	match item:
		###for the weapons
		level_info.Placeables.HAND:
			#hand
			return [weapons_im, 7, 0]
		level_info.Placeables.CRICKET_BAT:
			#cricket bat
			return [weapons_im, 7, 1]
		level_info.Placeables.SHOTGUN:
			#shotgun
			return [weapons_im, 7, 2]
		level_info.Placeables.SWORD:
			#sword
			return [weapons_im, 7, 3]
		level_info.Placeables.BOW:
			#bow
			return [weapons_im, 7, 4]
		level_info.Placeables.ARTILLERY:
			#artillery
			return [weapons_im, 7, 5]
		level_info.Placeables.MACHINE_GUN:
			
			return [weapons_im, 7, 6]
		###add the sniper later
		level_info.Placeables.SNIPER:
			#sniper
			return [weapons_im, 7, 6]
			
		###for the clothes
		level_info.Placeables.RAGS:
			#rags
			return [clothing_im, 7, 0]
		level_info.Placeables.PLAID:
			#plaid
			return [clothing_im, 7, 1]
		level_info.Placeables.POLICE:
			#police
			return [clothing_im, 7, 2]
		level_info.Placeables.WINTER:
			#winter coat
			return [clothing_im, 7, 3]
		level_info.Placeables.SOILDER:
			#soilder outfit
			return [clothing_im, 7, 4]
		level_info.Placeables.LEATHER:
			#leather jacket
			return [clothing_im, 7, 5]
		level_info.Placeables.SHELL:
			#shell suit
			return [clothing_im, 7, 6]
			
		##for the vehicles
		level_info.Placeables.FOOT:
			return [vehicles_im, 7, 0]
		level_info.Placeables.HORSE:
			return [vehicles_im, 7, 1]
		level_info.Placeables.DONKEY:
			return [vehicles_im, 7, 2]
		level_info.Placeables.BIKE:
			return [vehicles_im, 7, 3]
		level_info.Placeables.BUS:
			return [vehicles_im, 7, 4]
		level_info.Placeables.JEAP:
			return [vehicles_im, 7, 5]
			
		###for the buildings
		level_info.Placeables.EMPTY:
			return [building_im, 10, 0]
		level_info.Placeables.HOUSE:
			return [building_im, 10, 1]
		level_info.Placeables.OUTPOST:
			return [building_im, 10, 2]
		level_info.Placeables.FACTORY:
			return [building_im, 10, 3]
		level_info.Placeables.HOSPITAL:
			return [building_im, 10, 4]
		level_info.Placeables.FARM: 
			return [building_im, 10, 5]
		level_info.Placeables.SHOP:
			return [building_im, 10, 6]
		level_info.Placeables.MINE: 
			return [building_im, 10, 7]
		level_info.Placeables.POWER_STATION: 
			return [building_im, 10, 8]
		level_info.Placeables.COURTHOUSE:
			return [building_im, 10, 9]

###this is to avoid interfeering with the map whilst doing ui stuff
func _on_mouse_entered() -> void:
	level_info.hover = true

func _on_mouse_exited() -> void:
	level_info.hover = false


func _on_gui_input(event: InputEvent) -> void:
	###this function works out if the button is pressed, if the button is pressed and has an item
	###assocciated with it, and you are currently selecting a unit; itll change out the item.
	if event.is_action_pressed("mouse_left"):
		print($".."/".."/".."/"..".selected_unit)
		if $".."/".."/".."/"..".selected_unit != null:
			print("its probably deselcting")

			###this is working out whether the thing selected is a unit or a town
			if $".."/".."/".."/"..".selected_unit.has_method("conflict"):
				print("after method")
				###this works because if the method cant find the icon within its 
				###function it returns a null. else it replaces the inventory slot
				if $".."/".."/".."/"..".selected_unit.weapon_affects(selection) != null:
					remove_from_inv("unit","weapon")
					
				if $".."/".."/".."/"..".selected_unit.clothing_affects(selection) != null:
					remove_from_inv("unit","clothing")
					
				if $".."/".."/".."/"..".selected_unit.transport_affects(selection) != null:
					remove_from_inv("unit","transport")
			
			if $".."/".."/".."/"..".selected_unit.has_method("build"):
				if $".."/".."/".."/"..".selected_unit.buildings_effects(selection, 1) != null:
					remove_from_inv("town", "")
		print("in the button at least")

func remove_from_inv(set_or_unit, inv_type):
	###the point of this function is to get rid of the item thats been used from the 
	###overall inventory. and to add the appropriate stuff to the units space
	if set_or_unit == "unit":
		$".."/".."/".."/"..".selected_unit.inventory[inv_type] = selection
		###this is to change the damage of the units after their equipment has been changed.
		if inv_type == "weapon":
			$".."/".."/".."/"..".selected_unit.attack = $".."/".."/".."/"..".selected_unit.percent_ready + $".."/".."/".."/"..".selected_unit.weapon_affects($".."/".."/".."/"..".selected_unit.inventory["weapon"])[0]
		if inv_type == "clothing":
			$".."/".."/".."/"..".selected_unit.defence = $".."/".."/".."/"..".selected_unit.percent_ready + $".."/".."/".."/"..".selected_unit.clothing_affects($".."/".."/".."/"..".selected_unit.inventory["clothing"])
		
		level_info.inventory.erase(selection)
		
	else:
		for key in $".."/".."/".."/"..".selected_unit.constructed.keys():
			if $".."/".."/".."/"..".selected_unit.constructed[key] == level_info.Placeables.EMPTY:
				$".."/".."/".."/"..".selected_unit.constructed[key] = selection
				$".."/".."/".."/"..".selected_unit.erase(selection)
				return
