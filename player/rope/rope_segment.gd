extends RigidBody3D
class_name RopeSegment

# PROPERTIES

@export var joint_padding: float = 0.0
@export var segment_length: float = 0.4

var start_point: Vector3
var end_point: Vector3


# FUNCTIONS

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MeshInstance3D.mesh.height = segment_length
	$CollisionShape3D.shape.height = segment_length / 0.8
	
	start_point = Vector3(
		0.0,
		-$MeshInstance3D.mesh.height / 2.0 - joint_padding,
		0.0
	)
	
	end_point = -start_point
