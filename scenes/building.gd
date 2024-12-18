extends Node2D

# Building's owner
var player_id: int

# Type of building. Enujm stored in type.gd
@export var build_type: type.BUILD_TYPE
var build_level: type.BUILD_LEVEL = 0

# Population currently in building
var population: int
# Population cap for building
var max_pop: int

func _enter_tree() -> void:
	# Spritesheet contains each building type in sequential collumns, with each level of building in a new row
	$Map_Sprite.frame_coords = Vector2(build_type, build_level)
	match build_type:
		# Hull's population density is about 10k ppl per mile^2
		type.BUILD_TYPE.House:
			self.max_pop = 10000
		type.BUILD_TYPE.Factory:
			self.max_pop = 5000
		type.BUILD_TYPE.Shop:
			self.max_pop = 3000
