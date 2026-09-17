extends RigidBody3D
class_name Princess

# PROPERTIES

@export var player: Player
@export var rope: Rope

@onready var timer_label = $TimerHUD/TimerLabel
@onready var add_time_label = $TimerHUD/AddTimeLabel

var add_time_tween: Tween
var timer_color := Color.WHITE
var is_dragging := false
var gamepad_aiming := false
var gamepad_aim_pressed := false


# FUNCTIONS

func _ready() -> void:
	_reset_add_time_label()


func _physics_process(delta: float) -> void:
	if is_dragging:
		_drag_princess(delta)
	
	if player:
		$Sprite3D.flip_h = player.global_position.x > global_position.x
		
		# Reel in rope if princess gets too far away from player.
		var dist_to_player := global_position.distance_to(
			player.global_position
		)
		
		if dist_to_player <= 25:
			return
		
		for i in range(0, Rope.MAX_SEGMENT_COUNT):
			if rope.rope_segment_count <= 1:
				break
			
			var temp_timer = get_tree().create_timer(0.05)
			
			rope.subtract_segments()
			AudioManager.play(AudioData.AudioKey.MOUSE_WHEEL)
			
			global_position = global_position.move_toward(
				player.global_position,
				dist_to_player * delta
			)
			
			await temp_timer.timeout
		
		rope.update_anchor1()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventMouseMotion:
		gamepad_aiming = false
	
	if event.is_action_pressed("action_drag_weight") or \
	event.is_action_pressed("action_drag_up") or \
	event.is_action_pressed("action_drag_left") or \
	event.is_action_pressed("action_drag_down") or \
	event.is_action_pressed("action_drag_right"):
		is_dragging = true
	elif event.is_action_released("action_drag_weight") or \
	event.is_action_released("action_drag_up") or \
	event.is_action_released("action_drag_left") or \
	event.is_action_released("action_drag_down") or \
	event.is_action_released("action_drag_right"):
		is_dragging = false


# TIMER LABEL FUNCTIONS

func update_timer_label(time: float):
	if time <= 5.0:
		timer_label.modulate = Color.RED
	else:
		timer_label.modulate = timer_color
	
	timer_label.text = str(int(ceil(time)))


func update_timer_color(color: Color):
	timer_color = color
	timer_label.modulate = color


func _reset_add_time_label():
	add_time_label.modulate.a = 0.0
	add_time_label.position.y = 0.0


func show_add_time_label(time: int):
	add_time_label.text = "+" + str(time)
	add_time_label.modulate.a = 1.0
	
	if add_time_tween:
		add_time_tween.kill()
	
	add_time_tween = create_tween()
	add_time_tween.set_parallel()
	add_time_tween.tween_property(add_time_label, "position:y", 1.0, 1.0)
	add_time_tween.tween_property(add_time_label, "modulate:a", 0.0, 1.0)
	
	await add_time_tween.finished
	_reset_add_time_label()


# HELPER FUNCTIONS

func _drag_princess(_delta: float):
	if player == null or rope == null:
		print("Player or Rope not assigned!")
		return
	
	var direction: Vector2
	var gamepad_stick_direction := Input.get_vector(
		"action_drag_left",
		"action_drag_right",
		"action_drag_down",
		"action_drag_up"
	)
	
	gamepad_aim_pressed = false
	
	if gamepad_stick_direction.length() > 0.1:
		# Gamepad aiming
		gamepad_aiming = true
		gamepad_aim_pressed = true
		direction = gamepad_stick_direction
	else:
		# Mouse aiming
		var camera := get_viewport().get_camera_3d()
		var player_pos := camera.unproject_position(player.global_position)
		var mouse_pos := get_viewport().get_mouse_position()
		direction = Vector2(
			mouse_pos.x - player_pos.x,
			player_pos.y - mouse_pos.y
		).normalized()
	
	var player_dist := player.global_position
	var rope_dist := GameState.map_2d_to_3d(direction) * rope.get_rope_length()
	var target_pos := player_dist + rope_dist
	
	global_position = target_pos
	rope.update_anchor1()
