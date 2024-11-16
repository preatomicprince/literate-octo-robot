extends Node2D

var peer_id: int
var units = []
# Dict containing all tilesw as a key. Stores true if tile has had fog of war lifted
var tile_is_visible = {}

@rpc("reliable")
func sync_units(auth_units):
	units = auth_units
	
func _process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	rpc_id(peer_id, "sync_units", units)
