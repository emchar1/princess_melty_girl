extends Node3D

# PROPERTIES

signal did_melt(speed: float)
signal did_unmelt

@export var melt_speed: float = 2.0


# FUNCTIONS

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# SIGNAL

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		did_melt.emit(melt_speed)


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		did_unmelt.emit()
