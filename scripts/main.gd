extends Node3D

# PROPERTIES

@onready var player = $Players/Player
@onready var game_over_timer = $GameOverTimer
@onready var hud_time_label = $Hud/Label


# FUNCTIONS

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for pickup_timer in $LevelMap/Pickups.get_children():
		pickup_timer.picked_up_time.connect(_did_pick_up_time)
	
	player.dead.connect(_on_player_died)
	
	AudioManager.stop_all_music()
	AudioManager.play_music(AudioData.Music.BGM)


func _process(_delta: float) -> void:
	hud_time_label.text = str(int(ceil(game_over_timer.time_left)))


# SIGNAL CALLBACKS

func _on_player_died():
	get_tree().reload_current_scene()


func _did_pick_up_time(add: int):
	game_over_timer.start(game_over_timer.time_left + add)


func _on_game_over_timer_timeout() -> void:
	get_tree().reload_current_scene()
