extends Node3D

# PROPERTIES

const MIN_LENGTH: int = 4
const MAX_LENGTH: int = 20

@export var rope_segment_scene: PackedScene
@export var body_anchor: Node3D

var segments: Array[Node3D]
var rope_length: int


# FUNCTIONS

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	segments = [
		$BodyAnchor, $S0, $J0, $S1, $J1, $S2, $J2, $S3
	]
	
	if body_anchor:
		$BodyAnchor.global_position = body_anchor.global_position
		$S0.global_position = $BodyAnchor.global_position - $S0.start_point
		
		$BodyAnchor.node_a = $BodyAnchor.get_path_to(body_anchor)
		$BodyAnchor.node_b = $BodyAnchor.get_path_to($S0)
	else:
		print("Can't find body_anchor. Unable to attach rope!")
	
	_join_segments($S0, $J0, $S1)
	_join_segments($S1, $J1, $S2)
	_join_segments($S2, $J2, $S3)
	
	_set_rope_length()
	add_segments(16)


func add_segments(amount: int = 1):
	if rope_length + amount > MAX_LENGTH:
		return
	
	for i in range(amount):
		var prev_segment = segments.back() as RopeSegment
		var joint = PinJoint3D.new()
		var next_segment = rope_segment_scene.instantiate() as RopeSegment
		
		if not prev_segment or not next_segment:
			return
		
		add_child(joint)
		add_child(next_segment)
		
		segments.append(joint)
		segments.append(next_segment)
		
		_join_segments(prev_segment, joint, next_segment)
	
	_set_rope_length()


func subtract_segments(_amount: int = 1):
	pass


# HELPER FUNCTIONS

func _set_rope_length():
	rope_length = int(ceil(segments.size() / 2.0))


func _join_segments(s0: RopeSegment, j0: PinJoint3D, s1: RopeSegment):
	j0.position = s0.position + s0.end_point
	s1.position = j0.position - s1.start_point
	
	j0.node_a = j0.get_path_to(s0)
	j0.node_b = j0.get_path_to(s1)
