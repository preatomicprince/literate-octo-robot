extends Node

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
