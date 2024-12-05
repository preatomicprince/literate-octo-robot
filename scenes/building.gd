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

func _ready() -> void:
	match build_type:
		type.BUILD_TYPE.House:
			self.resource = type.RESOURCE.Population
			self.max_pop = 1000	
