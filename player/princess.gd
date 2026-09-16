extends RigidBody3D
class_name Princess

# PROPERTIES

signal slingshot(velocity: Vector3)

@export var player: Player
@export var rope: Rope

var is_dragging := false


# FUNCTIONS

func _ready() -> void:
	pass


func _physics_process(_delta: float) -> void:
	if is_dragging:
		_drag_princess()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("action_drag_weight"):
		is_dragging = true
	elif event.is_action_released("action_drag_weight"):
		is_dragging = false


# HELPER FUNCTIONS

func _drag_princess():
	if player == null or rope == null:
		print("Player or Rope not assigned!")
		return
	
	var camera := get_viewport().get_camera_3d()
	var player_screen_pos := camera.unproject_position(player.global_position)
	var mouse_pos := get_viewport().get_mouse_position()
	
	var direction := Vector2(
		mouse_pos.x - player_screen_pos.x,
		player_screen_pos.y - mouse_pos.y
	).normalized()
	
	var player_dist := player.global_position
	var rope_dist := GameState.map_2d_to_3d(direction) * rope.get_rope_length()
	var target_pos := player_dist + rope_dist
	
	global_position = global_position.lerp(target_pos, 0.2)
	rope.update_anchor1()
