extends Node

###var for weapons, i was thinking of doing all the enums like, 101, 102 for weapons, 201, for armour and
###301, for transport. giving them each their own 100 to be in allows us to expand the list of things we have
###in each catogory. If this doesnt work with networkign feel free to change it. the following dicts are just
###for reference. I dont beleive we'll actually use the dict itself.
##enum Weapons {HAND, CRICKET_BAT, SHOTGUN, SWORD, BOW, ARTILLERY, MACHINE_GUN, SNIPER}
#enum Clothes {RAGS, PLAID, POLICE, WINTER, SOILDER, LEATHER, SHELL}
#enum Vehicles {FOOT, HORSE, DONKEY, BIKE, BUS, JEAP}

###this is for the buildings
#enum Buildings {EMPTY, HOUSE, OUTPOST, FACTORY, HOSPITAL, FARM, SHOP, MINE, POWER_STATION, COURTHOUSE}
###creating one thats just called placeables, otherwise it doesnt really work
enum Placeables {HAND, CRICKET_BAT, SHOTGUN, SWORD, BOW, ARTILLERY, MACHINE_GUN, SNIPER, RAGS, PLAID, POLICE, WINTER, SOILDER, LEATHER, SHELL,
	FOOT, HORSE, DONKEY, BIKE, BUS, JEAP, EMPTY, HOUSE, OUTPOST, FACTORY, HOSPITAL, FARM, SHOP, MINE, POWER_STATION, COURTHOUSE}

###town name pool
var town_names = ["scunthorpe", "new hull", "mall town"]

###vars for the ui, probably doesnt need to be a different section
var fight : bool = false
var odds 
var unit_selected = null

###vars for the entire game
var turn : int = 1
var overall_population : int = 100
var shells : int = 0

###a dictionary containing each players stats, right now itll just include food gained
###player_stats = {12820482 : {"food": 0, "fuel: 0"}}
var player_stats : Dictionary = {}

var food_change : int = 0
var inventory = []
var inv_max : int = 10

###this is to work out if the ui is being interfeered with or not
var hover : bool = false

###a data structure that can record each tile and if that tile is passable, has a unit ect
###that can be preloaded and referenced in relevant scenes.
###this is an example of how itd look, the first two are for reference
### the list is for the values associated with the tile map_info.append([tile_pos.x + x, tile_pos.y + y, ["yes", the reference to the unit]])
###this could be used to save and load maps

var map_info : Dictionary = {}
