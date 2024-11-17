extends Node

###var for weapons, i was thinking of doing all the enums like, 101, 102 for weapons, 201, for armour and
###301, for transport. giving them each their own 100 to be in allows us to expand the list of things we have
###in each catogory. If this doesnt work with networkign feel free to change it. the following dicts are just
###for reference. I dont beleive we'll actually use the dict itself.
var weapons_dict = {"hand" : 100, "cricket bat" : 101, "shotgun" : 102, "sword" : 103, "bow" : 104, "artillery" : 105, "machine gun" : 106}
var clothing_dict = {"rags" : 200, "plaid" : 201, "police" : 202, "winter" : 203, "soilder" : 204, "leather" : 205, "shell" : 206}
var transport_dict = {"foot" : 300, "horse" : 301, "donkey" : 302, "bike" : 303, "bus" : 304, "jeap" : 305}

###vars for the ui, probably doesnt need to be a different section
var fight : bool = false
var odds 
var unit_selected = null

###vars for the entire game
var turn : int = 1

###a dictionary containing each players stats, right now itll just include food gained
var player_stats : Dictionary = {"player one" : [10]}


###a data structure that can record each tile and if that tile is passable, has a unit ect
###that can be preloaded and referenced in relevant scenes.
###this is an example of how itd look, the first two are for reference
### the list is for the values associated with the tile map_info.append([tile_pos.x + x, tile_pos.y + y, ["yes", the reference to the unit]])
###this could be used to save and load maps

var map_info : Dictionary = {}
