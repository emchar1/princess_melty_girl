extends CharacterBody3D
class_name Player

# PROPERTIES

signal dead

const RUN_MULTIPLIER_MIN = 0.85
const RUN_MULTIPLIER_MAX = 1.25

enum MoveState {
	IDLE, JUMP, RUN, SKID
}

@export var coyote_hang_time: float = 0.18
@onready var anim_sprite = $AnimatedSprite3D

var speed: float = 10
var jump_speed: float = 25
var run_multiplier: float = RUN_MULTIPLIER_MIN
var acceleration: float = 40.0
var deceleration: float = 50.0

var current_platform: Platform
var coyote_time: Timer

var is_running: bool = false
var is_jumping: bool = false
var is_falling: bool = false

var move_state: MoveState = MoveState.IDLE


# FUNCTIONS

func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_check_running()
	_move_player(delta)
	_process_jumping()
	_update_moves()
	_get_current_platform()
	move_and_slide()
	
	# Comment to disable coyote time.
	_add_coyote_time()
	
	if global_position.y <= -20:
		_die()


# HELPER FUNCTIONS

func _apply_gravity(delta: float):
	if not is_on_floor():
		velocity.y += get_gravity().y * delta


func _check_running():
	is_running = Input.is_action_pressed("action_run")
	
	if is_running:
		run_multiplier = RUN_MULTIPLIER_MAX
	else:
		run_multiplier = RUN_MULTIPLIER_MIN


func _move_player(delta: float):
	var move_dir := Input.get_axis("move_left", "move_right")
	
	if move_dir != 0:
		velocity.x = move_toward(
			velocity.x,
			move_dir * speed * run_multiplier,
			acceleration * delta
		)
		
		anim_sprite.flip_h = move_dir < 0
	else:
		velocity.x = move_toward(
			velocity.x,
			0.0,
			deceleration * delta
		)


func _process_jumping():
	var jump_pressed = Input.is_action_just_pressed("action_jump")
	var can_jump = is_on_floor() or coyote_time != null
	
	if is_on_floor():
		is_jumping = false
	
	if jump_pressed and can_jump and not is_jumping:
		velocity.y = jump_speed
		is_jumping = true
		_update_moves_helper(MoveState.JUMP)
		
		AudioManager.play(AudioData.AudioKey.JUMP)


func _update_moves():
	if is_on_floor():
		if velocity.x == 0:
			_update_moves_helper(MoveState.IDLE)
		else:
			if (velocity.x < 0 and not anim_sprite.flip_h) or \
			(velocity.x > 0 and anim_sprite.flip_h):
				_update_moves_helper(MoveState.SKID)
			else:
				_update_moves_helper(MoveState.RUN, run_multiplier)
	else:
		_update_moves_helper(MoveState.JUMP)


func _update_moves_helper(state: MoveState, speed_scale: float = 1.0):
	if move_state == state:
		return
	
	move_state = state
	
	match state:
		MoveState.IDLE:
			anim_sprite.play("idle")
		MoveState.JUMP:
			anim_sprite.play("jump")
		MoveState.RUN:
			anim_sprite.play("run")
		MoveState.SKID:
			anim_sprite.play("skid")
	
	anim_sprite.speed_scale = speed_scale


func _get_current_platform():
	if not is_on_floor():
		current_platform = null
		return
	
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		
		# Ignores walls and only sets current platform if standing on floor.
		if collision.get_normal().dot(Vector3.UP) > 0.7:
			var platform = collision.get_collider() as Platform
			
			if current_platform == platform:
				break
			
			current_platform = platform
			
			speed = current_platform.player_max_speed
			jump_speed = current_platform.player_max_jump_speed
			acceleration = current_platform.player_acceleration
			deceleration = current_platform.player_deceleration
			
			break


func _add_coyote_time():
	if is_on_floor():
		if coyote_time:
			coyote_time.queue_free()
			coyote_time = null
		
		is_falling = false
	else:
		if is_falling:
			return
		
		is_falling = true
		
		if coyote_time == null:
			coyote_time = Timer.new()
			coyote_time.wait_time = coyote_hang_time
			coyote_time.one_shot = true
			coyote_time.timeout.connect(_on_coyote_time_timeout)
			add_child(coyote_time)
			coyote_time.start()


func _die():
	dead.emit()


# SIGNAL CALLBACK FUNCTIONS

func _on_coyote_time_timeout():
	coyote_time.queue_free()
	coyote_time = null
