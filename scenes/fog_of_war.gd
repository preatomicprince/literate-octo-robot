extends TileMapLayer

@onready var level_info = $".."/".."/Game_State

func _processs(delta: float) -> void:
	for key in level_info.map_info.keys():
		if level_info.map_info[key][6] == true:
			map_reveal(1, key)

func generate_fog():
	for tile in $"..".tiles:
		set_cell(tile , 0, Vector2i(0, 0))

func map_reveal(peer_id, tile):
	tile = Vector2i(tile)
	var tiles_to_reveal = [tile, tile + Vector2i(0, 1), tile + Vector2i(-1, 0), 
	tile + Vector2i(1, 0), tile + Vector2i(0, -1), tile + Vector2i(0, -2), tile + Vector2i(0, 2)]
	
	###these take into account the fact that the numbers have different behaviour depending
	###on whether the unit is on and even tile or odd tile
	if tile.y % 2 == 0:
		tiles_to_reveal.append(tile + Vector2i(-1, -1))
		tiles_to_reveal.append(tile + Vector2i(-1, 1))
	
	else:
		
		tiles_to_reveal.append(tile + Vector2i(1, 1))
		tiles_to_reveal.append(tile + Vector2i(1, -1))
	
	for revealed_tile in tiles_to_reveal:
		set_cell(revealed_tile, 0, Vector2i(-1, -1))
		
		# Sets tiles visible for player, only on server
	if not is_multiplayer_authority():
		return
		
	for revealed_tile in tiles_to_reveal:
		$".."/"..".player[peer_id].tile_is_visible[str(revealed_tile)] = true
		$"..".spawn_existing_unit(peer_id, Vector2i(revealed_tile))
