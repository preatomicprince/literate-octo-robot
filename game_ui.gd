extends Control

@onready var level_info = get_node("/root/GameVars")

@onready var info_list = [$"res counter/food", $"res counter/turn"]

var combat_stat_barks = ["big defeat", "defeat", "draw", "small victory", "great success"]

func _ready() -> void:
	#print($".".get_global_position())
	$".".size = get_viewport_rect().size
	$"res counter".size.x = get_viewport_rect().size[0]
	$"tempbar".size.x = get_viewport_rect().size[0]*2
	for i in range(len(info_list)):
		info_list[i].position.x =  get_viewport_rect().size[0] / len(info_list)*i+1 
	
	###to make the bottom control node strech relative to the screen
	$"bottom bar".size.x = get_viewport_rect().size[0]
	print($"bottom bar".size)
	###its not doing exaclt what i want but its not the most pressing issue so ill leave it for now
	$"bottom bar".position.y = get_viewport_rect().size[1] - $"bottom bar".size.y
	$"bottom bar/Button".position.x = $"bottom bar".size.x# - $"bottom bar/Button".size.x
	
func _process(delta: float) -> void:
	change_stats()
	
func change_stats():
	###this line is just for reference in how to change text dynamically
	#$BattleCard/slavers.text = "[center] A Confederate {action} was {result} [/center]".format({"action": event_list[save_e], "result": success_chance[save_s]})
	$"res counter/food".text = "[center] Food: {number} ".format({"number":level_info.player_stats["player one"][0]})
	$"res counter/turn".text = "[center] Turn: {number} ".format({"number":level_info.turn})
	
	###for showing whats items a current unit has selected
	if level_info.unit_selected != null:
		$"bottom bar/item holder".visible = true
		$"bottom bar/item holder/weapon holder/WeaponIcons".frame = return_icon(level_info.unit_selected.inventory["weapon"])
		$"bottom bar/item holder/armour holder/Clothing".frame = return_icon(level_info.unit_selected.inventory["clothing"])
		$"bottom bar/item holder/transport holder/VehicleIcons".frame = return_icon(level_info.unit_selected.inventory["transport"])
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

func return_icon(num):
	###this function will take the enum fed to it and return the correct frame for the weapon,
	###by getting the last number of the enum. This was quicker to write than a big old switch case
	return int(str(num)[-1])
		
