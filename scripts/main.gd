extends Node3D

# PROPERTIES

@export var camera_mode: CameraController.CameraMode

@onready var player = $Players/Player
@onready var princess = $Players/Princess
@onready var melt_timer = $MeltTimer
@onready var hud = $Hud
@onready var camera = $CameraController

# FUNCTIONS

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for pickup_timer in get_tree().get_nodes_in_group("pickup"):
		pickup_timer.picked_up_time.connect(_did_pick_up_time)
	
	for melt_zone in get_tree().get_nodes_in_group("melt_zone"):
		melt_zone.did_melt.connect(_did_enter_melt_zone)
		melt_zone.did_unmelt.connect(_did_enter_unmelt_zone)
	
	$Players.position = GameState.checkpoint
	
	player.dead.connect(_on_player_died)
	melt_timer.timed_out.connect(_on_melt_timer_timeout)
	
	camera.mode = camera_mode
	
	princess.dragging_changed.connect(_on_princess_dragged)
	princess.gamepad_toggled.connect(_on_gamepad_toggled)
	princess.mouse_moved.connect(_on_mouse_moved)
	
	AudioManager.stop_all_music()
	await get_tree().create_timer(1.0).timeout #prevents intro+loop sync issues
	AudioManager.play_music(AudioData.Music.BGM)


func _process(_delta: float) -> void:
	princess.update_timer_label(melt_timer.current_time)


# SIGNAL CALLBACKS

func _handle_player_died():
	# TODO: - Need game over screen or something
	get_tree().reload_current_scene()


func _on_player_died():
	_handle_player_died()


func _on_princess_dragged(dragged: bool):
	hud.did_drag_dummy = dragged


func _on_gamepad_toggled(active: bool):
	hud.point_sprite.visible = not active


func _on_mouse_moved(active: bool):
	hud.point_sprite.visible = active


func _did_pick_up_time(time: int):
	melt_timer.add_time(time)
	princess.show_add_time_label(time)


func _did_enter_melt_zone(state: MeltZone.State, speed: float):
	melt_timer.update_melt_speed(state, speed)
	
	if state == MeltZone.State.MELT:
		princess.update_timer_color(Color.YELLOW)
	else:
		princess.update_timer_color(Color.CYAN)


func _did_enter_unmelt_zone(state: MeltZone.State, speed: float):
	melt_timer.update_melt_speed(state, speed)
	princess.update_timer_color(Color.WHITE)


func _on_melt_timer_timeout() -> void:
	_handle_player_died()
	pass
