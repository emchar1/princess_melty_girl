extends Node

# PROPERTIES

enum AudioKey {
	BGM
}

enum Music {
	NONE, BGM
}

enum Type {
	SOUND, MUSIC_INTRO, MUSIC_LOOP
}

var music_map := {
	Music.BGM: {
		"intro": null,
		"loop": AudioKey.BGM
	}
}

var sounds := {
	AudioKey.BGM: {
		"type": Type.MUSIC_LOOP,
		"stream": preload("res://assets/sounds/bgm.ogg")
	}
}
