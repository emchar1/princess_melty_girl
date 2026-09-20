extends RigidBody3D
class_name Princess

# PROPERTIES

signal dragging_changed(drag: bool)
signal gamepad_toggled(active: bool)
signal mouse_moved(active: bool)

@export var player: Player
@export var rope: Rope

@onready var timer_label = $TimerHUD/TimerLabel
@onready var add_time_label = $TimerHUD/AddTimeLabel

var add_time_tween: Tween
var timer_color := Color.WHITE
var last_mouse_active: float = 0
var was_dragging := false

var is_dragging := false:
	set(value):
		if is_dragging == value:
			return
		
		is_dragging = value
		dragging_changed.emit(value)

var gamepad_aiming := false:
	set(value):
		if gamepad_aiming == value:
			return
		
		gamepad_aiming = value
		gamepad_toggled.emit(value)


# FUNCTIONS

func _ready() -> void:
	_reset_add_time_label()


func _physics_process(delta: float) -> void:
	last_mouse_active += delta
	
	if Input.is_action_pressed("action_drag_weight"):
		last_mouse_active = 0
	
	if last_mouse_active > 1.0:
		mouse_moved.emit(false)
	
	if is_dragging:
		_drag_princess(delta)
	else:
		was_dragging = true
	
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
		last_mouse_active = 0
		mouse_moved.emit(true)

	
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
	
	var camera := get_viewport().get_camera_3d()
	var player_pos := camera.unproject_position(player.global_position)
	var mouse_pos := get_viewport().get_mouse_position()
	
	if gamepad_stick_direction.length() > 0.1:
		# Gamepad aiming
		gamepad_aiming = true
		direction = gamepad_stick_direction
	else:
		# Mouse aiming
		direction = Vector2(
			mouse_pos.x - player_pos.x,
			player_pos.y - mouse_pos.y
		).normalized()
	
	var player_dist := player.global_position
	var rope_dist := GameState.map_2d_to_3d(direction) * rope.get_rope_length()
	var target_pos := player_dist + rope_dist
	
	global_position = target_pos
	rope.update_anchor1()
	
	# One time mouse warp
	if was_dragging:
		was_dragging = false
		
		var target_screen_pos = camera.unproject_position(target_pos)
		var viewport_size := get_viewport().get_visible_rect().size
		var window_size := DisplayServer.window_get_size()
		var window_scale := Vector2(window_size) / viewport_size
		var adapted_mouse_pos = target_screen_pos * window_scale
		
		Input.warp_mouse(adapted_mouse_pos)
