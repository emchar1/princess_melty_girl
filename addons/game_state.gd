extends Node


# PROPERTIES

# Collision Layers/Masks
const COLLISION_WORLD = 1
const COLLISION_PLAYER = 2
const COLLISION_ENEMY = 3
const COLLISION_PICKUP = 4

var music_volume: float = 1.0
var sfx_volume: float = 1.0


# FUNCTIONS

func map_2d_to_3d(vector2: Vector2) -> Vector3:
	return Vector3(vector2.x, vector2.y, 0.0)


func map_3d_to_2d(vector3: Vector3) -> Vector2:
	return Vector2(vector3.x, vector3.y)
