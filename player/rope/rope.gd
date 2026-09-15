extends Node3D

# PROPERTIES

const MIN_LENGTH: int = 1
const MAX_LENGTH: int = 20

@export var rope_segment_scene: PackedScene
@export var anchor0: Node3D
@export var anchor1: Node3D

var segments: Array[Node3D]
var rope_length: int


# FUNCTIONS

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	segments = [$J0, $S0, $JN]
	
	# Join player to beginning
	if anchor0:
		$J0.global_position = anchor0.global_position
		$S0.global_position = $J0.global_position - $S0.start_point
		
		$J0.node_a = $J0.get_path_to(anchor0)
		$J0.node_b = $J0.get_path_to($S0)
	else:
		print("Can't find anchor0. Unable to attach rope!")
	
	add_segments(4)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("add_rope_segment"):
		if rope_length + 1 <= MAX_LENGTH:
			add_segments()
			AudioManager.play(AudioData.AudioKey.TICK)
	elif event.is_action_pressed("subtract_rope_segment"):
		if rope_length - 1 >= MIN_LENGTH:
			subtract_segments()
			AudioManager.play(AudioData.AudioKey.TICK)



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


func subtract_segments(amount: int = 1):
	if rope_length - amount < MIN_LENGTH:
		return
	
	var jn = segments.pop_back()
	
	remove_child(jn)
	
	for i in range(amount):
		var prev_segment = segments.pop_back() as RopeSegment
		var joint = segments.pop_back() as PinJoint3D
		
		if not prev_segment or not joint:
			print("Invalid rope segment and/or joint!")
			return
		
		remove_child(joint)
		remove_child(prev_segment)
	
	add_child(jn)
	segments.append(jn)
	_join_anchor1()
	_set_rope_length()


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
