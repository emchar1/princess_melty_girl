extends RigidBody3D
class_name RopeSegment

# PROPERTIES

@export var joint_padding: float = 0.05

var start_point: Vector3
var end_point: Vector3


# FUNCTIONS

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_point = Vector3(
		0.0,
		-$MeshInstance3D.mesh.height / 2.0 - joint_padding,
		0.0
	)
	
	end_point = -start_point
