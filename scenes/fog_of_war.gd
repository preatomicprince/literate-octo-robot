extends TileMapLayer

@onready var level_info = $".."/".."/Game_State
var tiles = {}

func _processs(delta: float) -> void:
	for key in level_info.map_info.keys():
		if level_info.map_info[key][6] == true:
			map_reveal(1, key)

func generate_fog():
	for tile in $"..".tiles:
		set_cell(tile , 0, Vector2i(0, 0))

func map_reveal(peer_id, tile):
	if not is_multiplayer_authority():
		return
		
	tile = Vector2i(tile)
	var tiles_to_reveal = [tile + Vector2i(-1, -1), tile + Vector2i(0, -1), tile + Vector2i(1, -1),
						   tile + Vector2i(-1, 0),         tile,            tile + Vector2i(1, 0),
						   tile + Vector2i(-1, 1),  tile + Vector2i(0, 1),  tile + Vector2i(1, 1)]
	

	
	for revealed_tile in tiles_to_reveal:
		set_tile_fow(revealed_tile)
		
	for revealed_tile in tiles_to_reveal:
		if not $".."/"..".player[peer_id].tile_is_visible.has(str(revealed_tile)):
			continue
		if $".."/"..".player[peer_id].tile_is_visible[str(revealed_tile)] == true:
			continue
		$".."/"..".player[peer_id].tile_is_visible[str(revealed_tile)] = true
		$"..".spawn_existing_unit(peer_id, revealed_tile)
		$"..".spawn_existing_object(peer_id, revealed_tile)
		

func set_tile_fow(tile: Vector2):
	if is_multiplayer_authority():
		return
		
	if $".."/"..".player[$".."/"..".peer_id].tile_is_visible[str(tile)]:
		set_cell(tile, 0, Vector2i(-1, -1))
	else:
		set_cell(tile, 0, Vector2i(0, 0))
		
func set_all_tiles_fow():
	for tile in $"..".tiles:
		set_tile_fow(tile)
