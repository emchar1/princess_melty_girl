@tool
extends StaticBody3D
class_name Platform

# PROPERTIES

enum TerrainType {
	GRASS, MARSH, ICE, SAND, LAVA, RAINBOW
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

@onready var mesh = $MeshInstance3D
@onready var collision = $CollisionShape3D

var player_max_speed: float
var player_max_jump_speed: float
var player_acceleration: float
var player_deceleration: float


# FUNCTIONS

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_configure()


func _configure():
	if mesh == null or collision == null:
		return
	
	var material = mesh.get_surface_override_material(0) as StandardMaterial3D
	var box_mesh = mesh.mesh as BoxMesh
	var collision_shape = collision.shape as BoxShape3D
	
	box_mesh.size = Vector3(length, HEIGHT, DEPTH)
	collision_shape.size = box_mesh.size
	
	match terrain_type:
		TerrainType.GRASS:
			material.albedo_color = Color.LIME_GREEN
			player_max_speed = 10.0
			player_max_jump_speed = 25.0
			player_acceleration = 40.0
			player_deceleration = 50.0
		TerrainType.MARSH:
			material.albedo_color = Color.WEB_PURPLE
			player_max_speed = 5.0
			player_max_jump_speed = 15.0
			player_acceleration = 20.0
			player_deceleration = 100.0
		TerrainType.ICE:
			material.albedo_color = Color.LIGHT_CYAN
			player_max_speed = 15.0
			player_max_jump_speed = 30.0
			player_acceleration = 10.0
			player_deceleration = 20.0
		TerrainType.SAND:
			material.albedo_color = Color.GOLD
			player_max_speed = 10.0
			player_max_jump_speed = 25.0
			player_acceleration = 30.0
			player_deceleration = 60.0
		TerrainType.LAVA:
			material.albedo_color = Color.ORANGE_RED
			player_max_speed = 10.0
			player_max_jump_speed = 25.0
			player_acceleration = 40.0
			player_deceleration = 50.0
		TerrainType.RAINBOW:
			material.albedo_color = Color.BLACK
			player_max_speed = 20.0
			player_max_jump_speed = 25.0
			player_acceleration = 40.0
			player_deceleration = 50.0
