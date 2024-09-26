extends Node2D

################################################
## Declarations, constants and node variables ##
################################################
var index : int
var has_units : bool = false

# Used in map::update_highlighted_tile()
var highlight

var input

func spawn_unit() -> void:
	if has_units == false:
		var new_unit = load("res://scenes/unit.tscn")
		var unit_instance = new_unit.instantiate()
		unit_instance.tile_index = index
		unit_instance.map = get_parent()
		unit_instance.input = input
		self.add_child(unit_instance)
		has_units = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	highlight = get_node("highlight")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
