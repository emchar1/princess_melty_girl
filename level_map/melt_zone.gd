extends Node3D
class_name MeltZone

# PROPERTIES

signal did_melt(state: State, speed: float)
signal did_unmelt(state: State, speed: float)

enum State {
	MELT, FREEZE
}

const ORIG_MELT_SPEED := 1.0

@export var current_state: State = State.MELT

@onready var melt_nodes = $MeltNodes
@onready var freeze_nodes = $FreezeNodes

var melt_speed: float


# FUNCTIONS

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match current_state:
		State.MELT:
			melt_speed = 2.0
			
			melt_nodes.show()
			freeze_nodes.hide()
		State.FREEZE:
			melt_speed = 0.0
			
			freeze_nodes.show()
			melt_nodes.hide()


# SIGNAL

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		did_melt.emit(current_state, melt_speed)


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		did_unmelt.emit(current_state, ORIG_MELT_SPEED)
