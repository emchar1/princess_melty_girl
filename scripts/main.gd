extends Node3D

# PROPERTIES

@onready var player = $Player


# FUNCTIONS

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.dead.connect(_on_player_died)
	
	AudioManager.stop_all_music()
	AudioManager.play_music(AudioData.Music.BGM)


# SIGNAL CALLBACKS

func _on_player_died():
	get_tree().reload_current_scene()
