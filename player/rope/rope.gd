extends Node3D
class_name Rope

# PROPERTIES

const MIN_SEGMENT_COUNT = 1
const MAX_SEGMENT_COUNT = 20
const REPEAT_DELAY = 0.25
const REPEAT_INTERVAL = 0.05

@export var rope_segment_scene: PackedScene
@export var anchor0: Node3D
@export var anchor1: Node3D

var segments: Array[Node3D]
var rope_segment_count: int
var add_rope_held := false
var subtract_rope_held := false
var repeat_delay_timer := 0.0
var repeat_interval_timer := 0.0


# INIT FUNCTIONS

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
		_adjust_segment_helper(true)
	elif event.is_action_pressed("subtract_rope_segment"):
		_adjust_segment_helper(false)


func _physics_process(delta: float) -> void:
	# Adjusts rope length when holding button (no mouse scroll):
	if Input.is_action_just_pressed("add_rope_segment"):
		add_rope_held = true
	elif Input.is_action_just_pressed("subtract_rope_segment"):
		subtract_rope_held = true
	
	if Input.is_action_just_released("add_rope_segment"):
		add_rope_held = false
		repeat_delay_timer = 0
		repeat_interval_timer = 0
	elif Input.is_action_just_released("subtract_rope_segment"):
		subtract_rope_held = false
		repeat_delay_timer = 0
		repeat_interval_timer = 0
	
	if not add_rope_held and not subtract_rope_held:
		return
	
	repeat_delay_timer += delta
	
	if repeat_delay_timer < REPEAT_DELAY:
		repeat_interval_timer = 0
		return
	
	repeat_interval_timer += delta
	
	if repeat_interval_timer < REPEAT_INTERVAL:
		return
	
	repeat_interval_timer = 0
	
	if add_rope_held:
		_adjust_segment_helper(true)
	elif subtract_rope_held:
		_adjust_segment_helper(false)


# PUBLIC FUNCTIONS

func get_rope_length() -> float:
	return rope_segment_count * $S0.segment_length


func add_segments(amount: int = 1):
	if rope_segment_count + amount > MAX_SEGMENT_COUNT:
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
	_set_rope_segment_count()


func subtract_segments(amount: int = 1):
	if rope_segment_count - amount < MIN_SEGMENT_COUNT:
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
	_set_rope_segment_count()


func _adjust_segment_helper(should_add: bool):
	if should_add:
		if rope_segment_count + 1 <= MAX_SEGMENT_COUNT:
			add_segments()
			AudioManager.play(AudioData.AudioKey.MOUSE_WHEEL)
	else:
		if rope_segment_count - 1 >= MIN_SEGMENT_COUNT:
			subtract_segments()
			AudioManager.play(AudioData.AudioKey.MOUSE_WHEEL)


func update_anchor1():
	var sn := segments[-2] as RopeSegment
	
	if sn == null or anchor1 == null:
		print("Can't find anchor1 or last rope segment!")
		return
	
	$JN.global_position = anchor1.global_position
	sn.global_position = $JN.global_position - sn.end_point


# HELPER FUNCTIONS

func _set_rope_segment_count():
	rope_segment_count = int(floor(segments.size() / 2.0))


func _join_segments(s0: RopeSegment, j1: PinJoint3D, s1: RopeSegment):
	j1.position = s0.position + s0.end_point
	s1.position = j1.position - s1.start_point
	
	j1.node_a = j1.get_path_to(s0)
	j1.node_b = j1.get_path_to(s1)


func _join_anchor1():
	var sn := segments[-2] as RopeSegment
	
	if sn == null or anchor1 == null:
		print("Can't find anchor1 or last rope segment!")
		return
	
	update_anchor1()
	
	$JN.node_a = $JN.get_path_to(sn)
	$JN.node_b = $JN.get_path_to(anchor1)
