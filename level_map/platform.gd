@tool
extends StaticBody3D
class_name Platform

# PROPERTIES

enum TerrainType {
	GRASS, GRASS2, MARSH, ICE, SAND, LAVA, RAINBOW
}

const HEIGHT = 1.0
const DEPTH = 5.0

@export var terrain_type: TerrainType = TerrainType.GRASS:
	set(value):
		terrain_type = value
		_configure()

@export var length: float = 1.0:
	set(value):
		length = value
		_configure()

@onready var grid_map = $GridMap
@onready var collision = $CollisionShape3D

var player_max_speed: float
var player_max_jump_speed: float
var player_acceleration: float
var player_deceleration: float

var tile_index: int


# FUNCTIONS

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_configure()
	_paint_platform()


func _configure():
	if collision == null:
		return
	
	var collision_shape = collision.shape as BoxShape3D
	collision_shape.size = Vector3(length, HEIGHT, DEPTH)
	
	match terrain_type:
		TerrainType.GRASS:
			tile_index = 41
			player_max_speed = 10.0
			player_max_jump_speed = 25.0
			player_acceleration = 40.0
			player_deceleration = 50.0
		TerrainType.GRASS2:
			tile_index = 41
			player_max_speed = 10.0
			player_max_jump_speed = 25.0
			player_acceleration = 40.0
			player_deceleration = 50.0
		TerrainType.MARSH:
			tile_index = 41
			player_max_speed = 5.0
			player_max_jump_speed = 20.0
			player_acceleration = 20.0
			player_deceleration = 100.0
			
			GameState._apply_kenney_variation_texture(grid_map, tile_index)
		TerrainType.ICE:
			tile_index = 83
			player_max_speed = 12.0
			player_max_jump_speed = 25.0
			player_acceleration = 10.0
			player_deceleration = 10.0
		TerrainType.SAND:
			tile_index = 41
			player_max_speed = 10.0
			player_max_jump_speed = 25.0
			player_acceleration = 30.0
			player_deceleration = 60.0
		TerrainType.LAVA:
			tile_index = 41
			player_max_speed = 10.0
			player_max_jump_speed = 25.0
			player_acceleration = 40.0
			player_deceleration = 50.0
		TerrainType.RAINBOW:
			tile_index = 41
			player_max_speed = 20.0
			player_max_jump_speed = 25.0
			player_acceleration = 40.0
			player_deceleration = 50.0


func _paint_platform():
	grid_map.clear()
	
	grid_map.position.x = -length / 2
	grid_map.position.z = -DEPTH / 2
	
	for x in range(length * 2):
		for y in range(HEIGHT):
			for z in range(DEPTH * 2):
				grid_map.set_cell_item(Vector3i(x, y, z), tile_index)
