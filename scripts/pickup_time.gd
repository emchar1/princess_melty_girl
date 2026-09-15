extends Area3D

# PROPERTIES

signal picked_up_time(add: int)

@export var add_time: int = 10


# FUNCTIONS

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		picked_up_time.emit(add_time)
		queue_free()
