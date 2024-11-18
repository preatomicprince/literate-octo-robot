extends Node2D

###pre load the unit so it can spawn new ones
var unit = preload("res://scenes/unit.tscn")

###a population pool that you take from to spawn units
var population : int = 100

###a settlement when it reaches a certain size will start to take up tiles
###as its territory
