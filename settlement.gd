extends Node2D

@onready var level_info = get_node("/root/GameVars")

###pre load the unit so it can spawn new ones
@onready var unit = preload("res://scenes/unit.tscn")
@onready var highlight = $highlight
var rand_n = RandomNumberGenerator.new()

var selected = false

###a population pool that you take from to spawn units
var settlement_name : String = "New Hull"
var population : int = 10

###this is to determine how many tiles a settlement has, maybe you get a tile per 10 pop atm
@onready var territory_tile = preload("res://assets/territory.png")
var number_tiles : int = 1

###a dcitionary for all the buildings that have been constructed
@onready var constructed : Dictionary = {
	"slot 1": level_info.Placeables.FARM,
	"slot 2": level_info.Placeables.EMPTY,
	"slot 3": level_info.Placeables.EMPTY
}

###a settlement when it reaches a certain size will start to take up tiles
###as its territory

func _ready() -> void:
	settlement_name = level_info.town_names[rand_n.randi_range(0, len(level_info.town_names)-1)]
	$"town name".text = "[center] {name}   :   {pop} ".format({"name": settlement_name, "pop": population})

func _process(delta: float) -> void:
	###doesnt need to be every frame, can just check when the pop changes then makes a change then
	$"town name".text = "[center] {name}   :   {pop} ".format({"name": settlement_name, "pop": population})
	
	###this is probably a jacked way of doing this
	if population /10 >= number_tiles*2:
		add_tile()
	
	###this is to get rid of the town if it doesnt have the people
	if population == 0:
		disestablish()

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
	#level_info.player_stats["player one"][0] += 100
	for key in constructed.keys():
		buildings_effects(constructed[key], 1)
		
	###for the population, right now itll just simply add population every turn
	###but we'll want to add something more complex at some point
	if population < 10:
		population += 1
	else:
		population *= 1.10
	print(population)

func add_tile():
	print("add new tile")
	var new_t = Sprite2D.new()
	new_t.texture = territory_tile
	self.add_child(new_t)
	###this isnt placing the territory tile in the right place
	###its just staking tiles on top of each other
	###even though im just trying to make it place a tile where my mouse is
	###i need it to work out what tiles are around it. maybe i can create a list idk
	###ima leave it for now cause i cant figure out exactly what i need
	new_t.position = self.get_parent().get_parent().local_to_map(self.get_parent().get_parent().get_global_mouse_position())#Vector2(100*number_tiles, 100*number_tiles)
	
	number_tiles += 1

func disestablish():
	###this function kills the town
	level_info.map_info[str(get_parent().get_parent().local_to_map($".".position))][7] = "no settlement"
	level_info.map_info[str(get_parent().get_parent().local_to_map($".".position))][8] = null
	queue_free()


func buildings_effects(buildings, lv):
	match buildings:
		level_info.Placeables.HOUSE:
			return 1
		level_info.Placeables.OUTPOST:
			return 1
		level_info.Placeables.FACTORY:
			return 1
		level_info.Placeables.HOSPITAL:
			return 1
		level_info.Placeables.FARM:
			###farms add food to your total
			level_info.player_stats["player one"][0] += 10*lv
			return 1
		level_info.Placeables.SHOP:
			return 1
		level_info.Placeables.MINE:
			return 1
		level_info.Placeables.POWER_STATION:
			return 1
		level_info.Placeables.COURTHOUSE:
			return 1

