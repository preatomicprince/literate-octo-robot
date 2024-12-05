extends Node2D



var peer_id: int
var units: Array = []
var buildings: Array = []
var items: Array = []
var food : int = 0
var population : int = 0
# Dict containing all tilesw as a key. Stores true if tile has had fog of war lifted
var tile_is_visible: Dictionary = {}

# Vector2i(-1, -1) if null
var selected_tile: Vector2i = Vector2i(-1, -1)
var selected_unit: Node

func _ready() -> void:
	for tile in $".."/Map.tiles:
		tile_is_visible[str(tile)] = false

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

@rpc
func sync_stats(auth_items, auth_food):
	items = auth_items
	food = auth_food
	
	
func _process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	rpc_id(peer_id, "sync_units", units)
	rpc_id(peer_id, "sync_stats", items, food)
	

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	rpc_id(peer_id, "sync_tile_visible", tile_is_visible)
