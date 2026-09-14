extends Node3D

# PROPERTIES

enum CameraMode {
	LOOK_2D, LOOK_3D
}

@onready var camera = $Camera3D
@onready var player = get_tree().get_first_node_in_group("player")

# Camera Presets
@export var camera_distance: float = 15.0
@export var camera_height: float = 8.0
@export var tilt_deg: float = -14.0
@export_range(0.0, 1.0) var follow_smoothing = 0.05

var mode = CameraMode.LOOK_2D
var camera_follow_height: float = 10.0


# FUNCTIONS

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if mode == CameraMode.LOOK_2D:
		follow_player_2d()
	else:
		follow_player_3d()


func follow_player_2d():
	if player == null:
		return
	
	var target_height: float
	
	if player.global_position.y < camera_follow_height:
		target_height = camera_height
	else:
		target_height = player.global_position.y
	
	var target_position := Vector3(
		player.global_position.x,
		target_height,
		player.global_position.z + camera_distance
	)
	
	global_position = global_position.lerp(target_position, follow_smoothing)
	rotation.x = deg_to_rad(tilt_deg)


# TODO: - Incomplete implementation
func follow_player_3d():
	if player == null:
		return
	
	var target_position := Vector3(
		player.global_position.x + camera_distance,
		camera_height,
		player.global_position.z
	)
	
	global_position = global_position.lerp(target_position, follow_smoothing)
	rotation.z = deg_to_rad(tilt_deg)
