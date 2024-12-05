extends CharacterBody2D

################################################
## Declarations, constants and node variables ##
################################################
@onready var level_info = get_node("/root/GameVars")

# peer_id of owner
var player_id: int
###stats for the unit in combat.
###these numbers will need tweeking, especially the defence
var attack : int = 10
var defence : int = 10
var rang : int = 1
var percent_ready : int = 10
var percent_injured : int = 0

###could remove one move when entering a new tile, when its entered a new tile, but then has no moves
###make the curent_target its current tile, and make the end point the saved_tile. at the begining of the 
###new round. the saved tile becomes the target again
var moves = 2
var saved_tile 
var saved_target
var saved_turn

###this is for the health bar, to allow it to shrink relative to the amount of damage taken
var one_percent_of_bar : float

###random to test out the equipment stuff
var rand_i = RandomNumberGenerator.new()

###an inventory with enum for the weapons and such, i've written a dict in the game var for the
###relevant dict numbers
@onready var inventory : Dictionary = {
	"weapon" : level_info.Placeables.HAND,
	"clothing" : level_info.Placeables.RAGS,
	"transport" : level_info.Placeables.FOOT
}

# Enum to store current direction
enum Direction {
	ur = 0,
	dr = 1,
	dl = 2,
	ul = 3
}
var unit_id: int

var accel = 7

@export var speed = 100
var _speed_y :float = speed
var _speed_x :float = _speed_y*(sqrt(3))

var velo = Vector2(0, 0)

var prev_pos: Vector2 = Vector2(-1, -1) 
var direction : Direction = 0

# Index in map tile list for current location (parent)
var tile_index : Vector2
var target_tile : Vector2
# Unique names dont work moving up the tree here, so these variables point to key nodes
var map
var input

@export var max_moves = 5
@onready var moves_remaining = max_moves
# 1 if currently selected
var selected : bool = false
var is_moving : bool = false
var distance : Vector2 = Vector2(0, 0)
var move_target_tile_index : Vector2 

var nav_path = []

@rpc("reliable")
func sync_select(select: bool) -> void:
	self.selected = select
	$Highlight.visible = select
	$"health bar".visible = select
	
func set_selected(select: bool) -> void:
	self.selected = select
	$Highlight.visible = select
	$"health bar".visible = select
	
	if is_multiplayer_authority():
		rpc_id(player_id, "sync_select", select)
	
func set_unselected() -> void:
	selected = false
	$Highlight.visible = false

func _ready() -> void:
	$".".position = get_parent().get_parent().map_to_local(tile_index)
	$".."/"..".objects[str($".."/"..".tiles[0])] = true
	#print(tile_index)
	tile_index = target_tile
	
	###to set the health bar
	###not doing it just yet
	
	one_percent_of_bar = $"health bar".get_node("healthy").size.x /10
	change_health()
	
	###to set the attack, range values of the unit,
	###based on what weapon the units have
	attack = percent_ready + weapon_affects(inventory["weapon"])[0]
	rang = weapon_affects(inventory["weapon"])[1]
	defence = percent_ready + clothing_affects(inventory["clothing"])

########################
## _process functions ##
########################


func _set_direction() -> void:
	var target_pos = self.nav_path.front()
	if tile_index.y > target_pos.y && tile_index.x == target_pos.x:
		direction = Direction.ur
	elif tile_index.x < target_pos.x && tile_index.y == target_pos.y:
		direction = Direction.dr
	elif tile_index.y < target_pos.y && tile_index.x == target_pos.x:
		direction = Direction.dl
	elif tile_index.x > target_pos.x && tile_index.y == target_pos.y:
		direction = Direction.ul


func _set_animation() -> void:
	if direction == 2 or direction == 3:
		$Sprite.flip_h = true
	else:
		$Sprite.flip_h = false
		
	if is_moving:
		if direction == 0 or direction == 3:
			$Sprite.play("run_u")
		else:
			$Sprite.play("run_d")
		
	else:
		if direction == 0 or direction == 3:
			$Sprite.play("idle_u")
		else:
			$Sprite.play("idle_d")
		
func check_reached_target():
	if distance.x >= map.HALF_TILE_W or distance.y >= map.HALF_TILE_H:
		
		self.position.x = 0
		self.position.y = map.HALF_TILE_H
		self.distance = Vector2(0, 0)
		is_moving = false
		#self.tile_index = move_target_tile_index
		move_target_tile_index = Vector2(1, 1)
		_set_animation()

func _handle_movement(delta) -> void:
	if move_target_tile_index != Vector2(0, 0):
		return
		
	var unit_tile_position = map.index_to_tile_pos(tile_index)
	var target_tile_position = map.index_to_tile_pos(move_target_tile_index)
	
	# Temp. Check if tile is next to it
	var next_on_x = (target_tile_position.x == unit_tile_position.x + 1 or target_tile_position.x == unit_tile_position.x - 1)
	var next_on_y = (target_tile_position.y == unit_tile_position.y + 1 or target_tile_position.y == unit_tile_position.y - 1)
	
	# If can move to tile
	if  next_on_x != next_on_y: # != functions as XOR here
		is_moving = true

		_set_animation()
	else:
		# TODO:- Find why this stops the input making any more selections, but left clicking doesn't 
		input.handle_deselection()
		return
		
	if is_moving:
		position += velocity*delta
		distance.x += abs(velocity.x)*delta
		distance.y += abs(velocity.y)*delta
		check_reached_target()
			


###these three functions relate to combat and changing the health of units, working out the odds of
### an encounter
func conflict(target):
	var damage_value = odds_combat(target)[1]
	var selected_val = odds_combat(target)[0]
	
	###works out if the unit has the numbers to attack
	if percent_ready > 0:
		###this works out if the target has more than 0 healthy people in a unit
		if target.percent_ready > 0:
			###first i work out the damage to the enemy then the unit selected
			###this is probably a bad system for many reasons, but ill do it like this for 
			###now, for the sake of speed
			if target.percent_ready - damage_value < 0:
				
				target.percent_injured += rand_i.randi_range(0, percent_ready/1.5)
				target.percent_ready = 0
				target.change_health()
			
			else:
				target.percent_ready -= damage_value
				target.percent_injured += rand_i.randi_range(0, damage_value/1.5)
				target.change_health()
			
			if percent_ready - selected_val < 0:
				percent_injured += rand_i.randi_range(0, percent_ready/1.5)
				percent_ready = 0
				change_health()
			
			else:
				percent_ready -= selected_val
				percent_injured += rand_i.randi_range(0, selected_val/1.5)
				change_health()
			
		else:
			###this just brings up the pop up for capturing units.
			print("you capture the remains")
			var pop_up = self.get_parent().get_parent().narrative_box.instantiate()
			pop_up.purpose = "story"
			pop_up.story_name = "captured"
			pop_up.started_event = level_info.unit_selected
			pop_up.target = level_info.map_info[str(self.get_parent().get_parent().local_to_map(self.position))]
			self.get_parent().get_parent().get_parent().get_node("narrative layer").add_child(pop_up)
			target.kill_unit()


###what is everything we need to take into account during an attack
###how much attack each side has, how much health each side has
###whether theyre surrounded on multiple sides. these can all work as attack multipliers
func odds_combat(target):
	###this returns a list of damage_value, which is the attacking units damage to the opposing units health
	###and vice versa for the selected val. this list is then used in the game_ui for the pop up
	var damage_value
	
	###this is for working out what damage the player will do to its target
	if attack - target.defence > 1:
		###i want this to also take into account how badly the units been damaged overall as well
		###it doesnt do that just yet
		damage_value = attack - target.defence
	else:
		damage_value = 1
		
	var selected_val
	
	###this is for working out what damage the player will do to its target
	if target.attack - defence > 1:
		selected_val = target.attack - defence
	else:
		selected_val = 1
		
	return [selected_val, damage_value]

func change_health():
	###this function changes the size for the health bars depending on the result of combat
	$"health bar".get_node("healthy").size.x = one_percent_of_bar * percent_ready
	
	###the percent injured follows on from your healthy bar
	$"health bar".get_node("injured").size.x = one_percent_of_bar * percent_injured
	$"health bar".get_node("injured").position.x = $"health bar".get_node("healthy").position.x + $"health bar".get_node("healthy").size.x

func kill_unit():
	###if there are no injured or active pop in the unit, right now itll just 
	###quew free, but later well want animation
	print("to free", level_info.map_info[str(get_parent().get_parent().local_to_map($".".position))])
	#level_info.map_info[str(get_parent().get_parent().local_to_map($".".position))][3] = null
	level_info.map_info[str(get_parent().get_parent().local_to_map($".".position))][3] = 0
	level_info.map_info[str(get_parent().get_parent().local_to_map($".".position))][2] = "no unit"
	if level_info.unit_selected == self:
		level_info.unit_selected = null
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _procjess(delta: float) -> void:
	
		
	###for showing combat odds
	if level_info.hover == false:
		if selected == true:
			###first it works out if your hovering over the unit you have selected
			if level_info.map_info[str(get_parent().get_parent().local_to_map(get_parent().get_parent().get_local_mouse_position()))] != level_info.map_info[str(get_parent().get_parent().local_to_map($".".position))]:
				###if not, it works out if the theres unit on the hovered over tile
				if level_info.map_info[str(get_parent().get_parent().local_to_map(get_parent().get_parent().get_local_mouse_position()))][3] is Object:
					###if so, it sets the level info fight to true, triggering the ui overlay in the game_ui node
					level_info.odds = odds_combat(level_info.map_info[str(get_parent().get_parent().local_to_map(get_parent().get_parent().get_local_mouse_position()))][3])
					level_info.fight = true
				else:
					level_info.fight = false
			else:
				level_info.fight = false
	
	
	var direction = Vector3()
	###this bit works out whats being explored
	level_info.map_info[str(get_parent().get_parent().local_to_map($".".position))][6] = true
	
	###this deletes the current saved unit, used to remove tiles its no longer on before it moves tile
	level_info.map_info[str(get_parent().get_parent().local_to_map($".".position))][3] = 0
	
	
	###this sets the current position of the unit to have a unit
	level_info.map_info[str(get_parent().get_parent().local_to_map($".".position))][3] = $"."
	
	if get_parent().get_parent().map_to_local(target_tile) == round($".".position):
		tile_index = target_tile
		
		###gonna need to set both tiles to no unit, has unit respectfully
		
	###this is to get rid of the unit if it doesnt have the people
	if percent_ready <= 0 and percent_injured <= 0:
		kill_unit()



###these functions change the attributes of the unit, and could be called when switching
###out inventory items

func weapon_affects(weapon):
	###this function takes what is in the dictionary of the unit and returns an appropriate
	###attack and range for the until. it returns it as a list to be fit into the relevant areas
	match weapon:
		level_info.Placeables.HAND:
			#hand
			return [0, 0]
		level_info.Placeables.CRICKET_BAT:
			#cricket bat
			return [10, 0]
		level_info.Placeables.SHOTGUN:
			#shotgun
			return [40, 1] 
		level_info.Placeables.SWORD:
			#sword
			return [30, 0]
		level_info.Placeables.BOW:
			#bow
			return [20, 2]
		level_info.Placeables.ARTILLERY:
			#artillery
			return [100, 3]
			
		level_info.Placeables.MACHINE_GUN:
			return [60, 1]
		
		level_info.Placeables.SNIPER:
			#sniper
			return [50, 2]
	
	
func clothing_affects(clothing):
	###this returns the armour rating of clothing, but also later, if we have enviromental damage to units
	###like cold. we could also return that. or maybe  certain types of clothing slows you down or speeds you up
	###like maybe the shell suit can add one speed, cause you look fly af.
	match clothing:
		level_info.Placeables.RAGS:
			#rags
			return 10
		level_info.Placeables.PLAID:
			#plaid
			return 20
		level_info.Placeables.POLICE:
			#police
			return 30
		level_info.Placeables.WINTER:
			#winter coat
			return 20
		level_info.Placeables.SOILDER:
			#soilder outfit
			return 40
		level_info.Placeables.LEATHER:
			#leather jacket
			return 35
		level_info.Placeables.SHELL:
			#shell suit
			return 10

func transport_affects(transport):
	###transport retruns the speed, but also the armour rating
	match transport:
		level_info.Placeables.FOOT:
			return 1
		level_info.Placeables.HORSE:
			return 1
		level_info.Placeables.DONKEY:
			return 1
		level_info.Placeables.BIKE:
			return 1
		level_info.Placeables.BUS:
			return 1
		level_info.Placeables.JEAP:
			return 1

@rpc
func sync_pos(auth_pos):
	prev_pos = position
	position = auth_pos
	velocity = position - prev_pos
	if $".."/".."/"..".player[$".."/".."/"..".peer_id].tile_is_visible[str($".."/"..".local_to_map(position))]:
		visible = true
	else:
		visible =  false

@rpc
func sync_dir(auth_dir, auth_is_moving):
	direction = auth_dir
	is_moving = auth_is_moving
	
func _process(delta: float) -> void:
	_set_animation()
	if not is_multiplayer_authority():
		return
		
	if nav_path.is_empty() or moves_remaining <= 0:
		is_moving = false
		return
	var target_pos = $".."/"..".map_to_local(self.nav_path.front())
	
	# Checks cost of move to next tile. Disallowed if higher than moves remaining
	if $".."/"..".nav_grid.get_point_weight_scale(self.nav_path.front()) > moves_remaining:
		return
		 
	if $".."/"..".units[str(self.nav_path.front())] != null:
		position = $".."/"..".map_to_local(tile_index)
		nav_path = []
		return
	
	is_moving = true
	prev_pos = position
	position = position.move_toward(target_pos, speed*delta)
	velocity = position - prev_pos
	_set_direction()
	if position == target_pos:
		moves_remaining -= 1;
		$".."/"..".units[str(tile_index)] = null
		tile_index = nav_path.pop_front()
		$".."/"..".units[str(tile_index)] = self
		$".."/".."/Fog_Of_War.map_reveal(player_id, tile_index)
		
		if $".."/"..".objects[str(tile_index)] == true:
			$".."/".."/Map_Objects.resource_collection(player_id)
			print("here")
		

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	"""for peer_id in $".."/".."/"..".connected_peers:
		print($".."/".."/"..".player[peer_id].tile_is_visible[str(tile_index)])
		if $".."/".."/"..".player[peer_id].tile_is_visible[str(tile_index)]:"""
	rpc("sync_pos", position)
	rpc("sync_dir", direction, is_moving)
	
