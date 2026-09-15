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
	pass
