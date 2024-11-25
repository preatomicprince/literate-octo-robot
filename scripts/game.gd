extends Node2D

@onready var level_info = get_node("/root/GameVars")

var unit = preload("res://scenes/tile.tscn")
var saved_turn = 1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if saved_turn != level_info.turn:
		###this makes the towns do eveything they need to do once per turn
		for key in level_info.map_info.keys():
			if level_info.map_info[key][8] is Object:
				level_info.map_info[key][8].new_turn()
				
		###to add the food reduction
		###this is a very rough calculation
		###im thinking that population in cities should consume half the food of those that are working
		level_info.player_stats["player one"][0] -= level_info.overall_population
		
		saved_turn += 1
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("key_esc"):
		get_tree().quit() 
