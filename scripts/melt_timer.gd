extends Node
class_name MeltTimer

# PROPERTIES

signal timed_out()

const ORIG_MELT_SPEED = 1.0

@export var current_time: float = 30.0

var melt_speed: float
var did_timeout: bool = false


# FUNCTIONS

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	melt_speed = ORIG_MELT_SPEED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if did_timeout:
		return
	
	current_time -= delta * melt_speed
	
	if current_time <= 0:
		did_timeout = true
		timed_out.emit()


func add_time(time: float):
	current_time += time


func update_melt_speed(speed: float = ORIG_MELT_SPEED):
	melt_speed = speed
