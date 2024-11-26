extends Node2D

@onready var level_info = get_node("/root/GameVars")

var unit = preload("res://scenes/tile.tscn")
var saved_turn = 1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if saved_turn != level_info.turn:
		###this makes the towns do eveything they need to do once per turn
		for key in level_info.map_info.keys():
			if level_info.map_info[key][8] is Object:
				level_info.map_info[key][8].new_turn()
		
		###this is to work out the starvation
		if level_info.player_stats["player one"][0] < 0:
			###this will go through the list of units, kill off all the injured units
			###then turn a percentaage of the ready units into injured units
			for key in level_info.map_info.keys():
				if level_info.map_info[key][3] is Object:
					if level_info.map_info[key][3].percent_ready > 0:
						level_info.map_info[key][3].percent_injured = 0
						var percent_of = ceil(level_info.map_info[key][3].percent_ready/4)
						if percent_of == 0:
							percent_of = 1
						level_info.map_info[key][3].percent_ready -= percent_of
						level_info.map_info[key][3].percent_injured += percent_of
						level_info.map_info[key][3].change_health()
					else:
						level_info.map_info[key][3].percent_injured = 0
						level_info.map_info[key][3].change_health()
				
				###this will go through all of the towns and kill off a certain percentage of the population
				if level_info.map_info[key][8] is Object:
					var percent_of = ceil(level_info.map_info[key][8].population/4)
					if percent_of == 0:
						percent_of = 1
					level_info.map_info[key][8].population -= percent_of
		
		###to add the food reduction
		###this is a very rough calculation
		###im thinking that population in cities should consume half the food of those that are working
		level_info.player_stats["player one"][0] -= level_info.overall_population
		
		###this is just a fail state
		if level_info.overall_population < 1:
			print("you didnt survive, they say its grim up north!")
		
		saved_turn += 1
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("key_esc"):
		get_tree().quit() 
