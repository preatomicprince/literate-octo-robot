extends Node2D

var highlight
func highlight_on() -> void:
	highlight.visible = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	highlight = get_node("highlight")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
