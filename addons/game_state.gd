extends Node


# PROPERTIES

const KENNEY_VARIATION_A = preload(
	"res://assets/kenney_platformer-kit/Models/Textures/variation-a.png"
)

# Collision Layers/Masks
const COLLISION_WORLD = 1
const COLLISION_PLAYER = 2
const COLLISION_ENEMY = 3
const COLLISION_PICKUP = 4

var music_volume: float = 1.0
var sfx_volume: float = 1.0

var checkpoint: Vector3 = Vector3(-10, 0, 0)


# FUNCTIONS

func map_2d_to_3d(vector2: Vector2) -> Vector3:
	return Vector3(vector2.x, vector2.y, 0.0)


func map_3d_to_2d(vector3: Vector3) -> Vector2:
	return Vector2(vector3.x, vector3.y)


func set_checkpoint(spawn_point: Vector3):
	checkpoint = spawn_point


func _apply_kenney_variation_texture(grid_map: GridMap, tile_index: int):
	var mesh_library = grid_map.mesh_library.duplicate()
	var mesh = mesh_library.get_item_mesh(tile_index).duplicate()
	var mat = mesh.surface_get_material(0).duplicate() as StandardMaterial3D
	
	mat.albedo_texture = KENNEY_VARIATION_A
	mesh.surface_set_material(0, mat)
	mesh_library.set_item_mesh(tile_index, mesh)
	grid_map.mesh_library = mesh_library
