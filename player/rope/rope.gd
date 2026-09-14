extends Node3D

# PROPERTIES

const MIN_LENGTH: int = 4
const MAX_LENGTH: int = 20

@export var rope_segment_scene: PackedScene
@export var anchor0: Node3D
@export var anchor1: Node3D

var segments: Array[Node3D]
var rope_length: int


# FUNCTIONS

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	segments = [
		$J0, $S0, $J1, $S1, $J2, $S2, $J3, $S3, $JN
	]
	
	# Join player to beginning
	if anchor0:
		$J0.global_position = anchor0.global_position
		$S0.global_position = $J0.global_position - $S0.start_point
		
		$J0.node_a = $J0.get_path_to(anchor0)
		$J0.node_b = $J0.get_path_to($S0)
	else:
		print("Can't find anchor0. Unable to attach rope!")
	
	_join_segments($S0, $J1, $S1)
	_join_segments($S1, $J2, $S2)
	_join_segments($S2, $J3, $S3)
	
	add_segments(10)


func add_segments(amount: int = 1):
	if rope_length + amount > MAX_LENGTH:
		return
	
	var jn = segments.pop_back()
	
	remove_child(jn)
	
	for i in range(amount):
		var prev_segment = segments.back() as RopeSegment
		var joint = PinJoint3D.new()
		var next_segment = rope_segment_scene.instantiate() as RopeSegment
		
		if not prev_segment or not next_segment:
			print("Invalid rope segment!")
			return
		
		add_child(joint)
		add_child(next_segment)
		
		segments.append(joint)
		segments.append(next_segment)
		
		_join_segments(prev_segment, joint, next_segment)
	
	add_child(jn)
	segments.append(jn)
	_join_anchor1()
	_set_rope_length()


func subtract_segments(_amount: int = 1):
	pass


# HELPER FUNCTIONS

func _set_rope_length():
	rope_length = int(floor(segments.size() / 2.0))


func _join_segments(s0: RopeSegment, j1: PinJoint3D, s1: RopeSegment):
	j1.position = s0.position + s0.end_point
	s1.position = j1.position - s1.start_point
	
	j1.node_a = j1.get_path_to(s0)
	j1.node_b = j1.get_path_to(s1)


func _join_anchor1():
	if not anchor1:
		print("Can't find anchor1. Unable to attach rope!")
		return
	
	var sn = segments[-2]
	
	if sn == null:
		print("can't find last rope segment in _join_anchor1()")
		return
	
	$JN.global_position = anchor1.global_position
	sn.global_position = $JN.global_position - sn.start_point
	
	$JN.node_a = $JN.get_path_to(sn)
	$JN.node_b = $JN.get_path_to(anchor1)
