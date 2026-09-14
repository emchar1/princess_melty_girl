extends CharacterBody3D
class_name Player

# PROPERTIES

signal dead

@export var speed: float = 10
@export var jump_speed: float = 25
@export var coyote_hang_time: float = 0.18

var coyote_time: Timer
var is_jumping: bool = false
var is_falling: bool = false


# FUNCTIONS

func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_move_player()
	_process_jumping()
	move_and_slide()
	
	# Comment to disable coyote time.
	_add_coyote_time()
	
	if global_position.y <= -20:
		_die()


# HELPER FUNCTIONS

func _apply_gravity(delta: float):
	if not is_on_floor():
		velocity.y += get_gravity().y * delta


func _move_player():
	var move_dir := Input.get_axis("move_left", "move_right")
	
	velocity.x = move_dir * speed
	
	if move_dir != 0:
		$Sprite3D.flip_h = move_dir < 0


func _process_jumping():
	var jump_pressed = Input.is_action_just_pressed("action_jump")
	var can_jump = is_on_floor() or coyote_time != null
	
	if is_on_floor():
		is_jumping = false
	
	if jump_pressed and can_jump and not is_jumping:
		velocity.y = jump_speed
		is_jumping = true


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
