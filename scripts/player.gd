extends Node2D

var peer_id: int
var units = []
# Dict containing all tilesw as a key. Stores true if tile has had fog of war lifted
var tile_is_visible = {}

@rpc
func sync_units(auth_units):
	units = auth_units
	
@rpc
func sync_tile_visible(auth_tile_visible: Dictionary):
	tile_is_visible = auth_tile_visible
	
func _process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	rpc_id(peer_id, "sync_units", units)
	rpc_id(peer_id, "sync_tile_visible", tile_is_visible)
