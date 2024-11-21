extends TextureButton

@onready var level_info = get_node("/root/GameVars")

###preload all the image sheets
var building_im = preload("res://assets/building icons.png")
var weapons_im = preload("res://assets/weapon icons.png")
var clothing_im = preload("res://assets/clothing.png")
var vehicles_im = preload("res://assets/vehicle icons.png")

@onready var selection = null
var saved_selection
func _ready() -> void:
	
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
