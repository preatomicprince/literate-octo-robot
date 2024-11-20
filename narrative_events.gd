extends Control

@onready var level_info = get_node("/root/GameVars")

###this determins what the will be shown for the narative events
###if its a "pop transfer" it will bring up a slider, if its a "story" itll bring up choice buttons
var purpose : String

###unit or settlment thats triggering the transfer
var started_event
###for the pop transfer, whoes getting the units
var target 

func _ready() -> void:
	$".".position = Vector2(get_viewport_rect().size[0]/2, get_viewport_rect().size[1]/2)

func _process(delta: float) -> void:
	###it doesnt need to be here doing this every second
	if purpose == "pop transfer":
		unit_transfer(started_event)
	
	if purpose == "story":
		story_event()
	
func unit_transfer(lose_pop):
	if lose_pop.has_method("conflict"):
		$"unit transfers/HSlider".max_value = (lose_pop.percent_ready + lose_pop.percent_injured)
		$"event box".text = "[center]How many will you transfer? {amount}[center]".format({"amount": $"unit transfers/HSlider".value})
		
	if lose_pop.has_method("build"):
		if lose_pop.population > 100:
			$"unit transfers/HSlider".max_value = 100
		else:
			$"unit transfers/HSlider".max_value = lose_pop.population
	
func story_event():
	pass

###these are for transfering between the population and units
func _on_accept_button_up() -> void:
	###works out what is giving pop, or what is losing it
	if started_event.has_method("conflict"):
		if $"unit transfers/HSlider".value >= 1:
			target[7] = "has settlement"
			self.get_parent().get_parent().get_node("ground map").generate_settlement(started_event.position, $"unit transfers/HSlider".value)
			started_event.percent_ready -= $"unit transfers/HSlider".value
			started_event.change_health()
			queue_free()
		else:
			queue_free()
			
	if started_event.has_method("build"):
		if $"unit transfers/HSlider".value >= 1:
			if level_info.map_info[str(self.get_parent().get_parent().get_node("ground map").local_to_map(self.position))][3] is not Object:
				self.get_parent().get_parent().get_node("ground map").generate_unit(Vector2(level_info.map_info[str(self.get_parent().get_parent().get_node("ground map").local_to_map(started_event.position))][0], level_info.map_info[str(self.get_parent().get_parent().get_node("ground map").local_to_map(started_event.position))][1]), $"unit transfers/HSlider".value)
				for key in level_info.map_info.keys():
					if level_info.map_info[key][3] is Object:
						level_info.map_info[key][3].set_unselected()
				started_event.population -= $"unit transfers/HSlider".value
			queue_free()
		else:
			queue_free()

func _on_close_button_up() -> void:
	queue_free()


