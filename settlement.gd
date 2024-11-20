extends Node2D

@onready var level_info = get_node("/root/GameVars")

###pre load the unit so it can spawn new ones
@onready var unit = preload("res://scenes/unit.tscn")
@onready var highlight = $highlight
var rand_n = RandomNumberGenerator.new()

var selected = false

###a population pool that you take from to spawn units
var settlement_name : String = "New Hull"
var population : int = 100

###a dcitionary for all the buildings that have been constructed
@onready var constructed : Dictionary = {
	"slot 1": level_info.Buildings.HOUSE,
	"slot 2": level_info.Buildings.HOUSE,
	"slot 3": level_info.Buildings.HOUSE
}

###a settlement when it reaches a certain size will start to take up tiles
###as its territory

func _ready() -> void:
	settlement_name = level_info.town_names[rand_n.randi_range(0, len(level_info.town_names)-1)]
	$"town name".text = "[center] {name}   :   {pop} ".format({"name": settlement_name, "pop": population})

func set_selected() -> void:
	selected = true
	self.highlight.visible = true
	
func set_unselected() -> void:
	selected = false
	self.highlight.visible = false

func build():
	###right now this is just used by the ui to work out if the settlement is selected
	###but the settlement probably needs a build function later on so ill name it this
	pass

func new_turn():
	###this function triggers at the end of the turn to add whatever variables need to be added
	###or taken away
	level_info.player_stats["player one"][0] += 100

