extends Control

@onready var level_info = get_node("/root/GameVars")
####ive done the narrative events through a json file as that seems like a light weight way of doing things
###its got a dictionary, with the name of the event. Then it has a dictionary, first it has the description
###if the quest has been done yet. then the options. its a list of lists, [0] contains the option description#
###[1] contains the contents. Im not totally sure how this will work. Right now ive just put inds there and ill
###figure out how how to do something more advanced later
var json_story : String = "res://scripts/tales.json"
var json = JSON.new()

###this determins what the will be shown for the narative events
###if its a "pop transfer" it will bring up a slider, if its a "story" itll bring up choice buttons
var purpose : String = "story"
var fired : bool = false
###unit or settlment thats triggering the transfer, rel value can be used to put a number like
###units that have been captured and put it in function for a relevant story
var started_event
var story_name = null
var relevant_value 
###this is used to turn off buttons for the amount of options a quest has
@onready var button_list = [$"option buttons/option 1", $"option buttons/option 2", $"option buttons/option 3", $"option buttons/option 4"]
var results_list = [0, 0, 0, 0]
###for the pop transfer, whoes getting the units
var target 

func _ready() -> void:
	$".".position = Vector2(get_viewport_rect().size[0]/2, get_viewport_rect().size[1]/2)

func _process(delta: float) -> void:
	###it doesnt need to be here doing this every second
	if purpose == "pop transfer":
		unit_transfer(started_event)
	
	if purpose == "story" and fired == false:
		story_event(story_name)
		fired = true
	
func unit_transfer(lose_pop):
	$"option buttons".visible = false
	$"unit transfers".visible = true
	if lose_pop.has_method("conflict"):
		$"unit transfers/HSlider".max_value = (lose_pop.percent_ready + lose_pop.percent_injured)
		$"event box".text = "[center]How many will you transfer? {amount}[center]".format({"amount": $"unit transfers/HSlider".value})
		
	if lose_pop.has_method("build"):
		if lose_pop.population > 100:
			$"unit transfers/HSlider".max_value = 100
		else:
			$"unit transfers/HSlider".max_value = lose_pop.population
	
func story_event(story_key):
	###this function turns the unit slider invisible, turns the options menu visible
	###it then returns a story event from the json file. right now it just does one
	###if its null. I havnt quite figured out how best to do the results of quests without
	###writting unique code for each quest. I initially thought about writting lambda functions
	###and storing them in the json file. But turns out godot doesnt support that
	
	$"unit transfers".visible = false
	$"option buttons".visible = true
	###this has got to be file access
	var file = FileAccess.open(json_story, FileAccess.READ)
	var content = json.parse_string(file.get_as_text())
	
	###first we turn all the buttons off based 
	for b in range(len(button_list)):
		button_list[b].visible = false

	$"event box".text = content[story_name]["quest info"]
	for c in range(len(content[story_name]["choices"])):
		button_list[c].text = content[story_name]["choices"][c][0]
		results_list[c] = content[story_name]["choices"][c][1]
		button_list[c].visible = true
				
	


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

func _on_option_1_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_left"):
		call(results_list[0])
		queue_free()

func _on_option_2_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_left"):
		call(results_list[1])
		queue_free()

func _on_option_3_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_left"):
		call(results_list[2])
		queue_free()

func _on_option_4_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_left"):
		call(results_list[3])
		queue_free()

func test():
	###this function was just to see if it can be called by the result of a quest action
	print("testing")

func cannibalism():
	level_info.player_stats["player one"][0] += relevant_value

func recruitment():
	for key in level_info.map_info.keys():
		if level_info.map_info[key][8] is Object:
			level_info.map_info[key][8].population += relevant_value
			return
