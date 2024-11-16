extends Control

@onready var level_info = get_node("/root/GameVars")

@onready var info_list = [$"res counter/food", $"res counter/turn"]

func _ready() -> void:
	$"res counter".size.x = get_viewport_rect().size[0]
	$"tempbar".size.x = get_viewport_rect().size[0]*2
	for i in range(len(info_list)):
		info_list[i].position.x =  get_viewport_rect().size[0] / len(info_list)*i+1 

func _process(delta: float) -> void:
	change_stats()
	
func change_stats():
	###this line is just for reference in how to change text dynamically
	#$BattleCard/slavers.text = "[center] A Confederate {action} was {result} [/center]".format({"action": event_list[save_e], "result": success_chance[save_s]})
	$"res counter/food".text = "[center] Food: {number} ".format({"number":level_info.player_stats["player one"][0]})
	$"res counter/turn".text = "[center] Turn: {number} ".format({"number":level_info.turn})
