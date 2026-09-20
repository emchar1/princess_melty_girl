extends Control

# PROPERTIES

@onready var timer_label = $TimerLabel
@onready var add_time_label = $AddTimeLabel
@onready var point_sprite = $PointSprite2D

var add_time_tween: Tween
var did_drag_dummy: bool = false


# FUNCTIONS

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_reset_add_time_label()
	
	# Uncomment to hide mouse cursor. Requires Godot restart
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func _physics_process(_delta: float) -> void:
	var mouse_offset: Vector2
	
	if did_drag_dummy:
		point_sprite.play("pinch")
		mouse_offset = Vector2(-280, -415) * point_sprite.scale
	else:
		point_sprite.play("idle")
		mouse_offset = Vector2.ZERO
	
	point_sprite.position = get_viewport().get_mouse_position() + mouse_offset


func update_timer_label(time: float):
	if time <= 5.0:
		timer_label.modulate = Color.RED
	else:
		timer_label.modulate = Color.WHITE
	
	timer_label.text = str(int(ceil(time)))


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
	add_time_tween.tween_property(add_time_label, "position:y", -20.0, 1.0)
	add_time_tween.tween_property(add_time_label, "modulate:a", 0.0, 1.0)
	
	await add_time_tween.finished
	_reset_add_time_label()
