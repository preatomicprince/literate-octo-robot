extends Node2D

var peer_id: int
var units: Array = []
# Dict containing all tilesw as a key. Stores true if tile has had fog of war lifted
var tile_is_visible: Dictionary = {}

# Vector2i(-1, -1) if null
var selected_tile: Vector2i = Vector2i(-1, -1)
var selected_unit: Node

func _ready() -> void:
	for tile in $".."/Map.tiles:
		tile_is_visible[tile] = false

@rpc
func sync_units(auth_units):
	units = auth_units
	
@rpc
func sync_tile_visible(auth_tile_visible: Dictionary):
	##
	## todo:- Optimise. Setting every tile several times a second can get expensive,
	## as can sending whole Dicts
	## 

	tile_is_visible = auth_tile_visible
	$".."/Map/Fog_Of_War.set_all_tiles_fow()
#		tile_is_visible = auth_tile_visible

	
	
	
func _process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	rpc_id(peer_id, "sync_units", units)
	

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	rpc_id(peer_id, "sync_tile_visible", tile_is_visible)
