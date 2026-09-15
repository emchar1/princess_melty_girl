extends Node

# PROPERTIES

enum AudioKey {
	BGM_INTRO,
	BGM_LOOP,
	JUMP,
	MOUSE_WHEEL,
	PICKUP_TIME
}

enum Music {
	NONE, BGM
}

enum Type {
	SOUND, MUSIC_INTRO, MUSIC_LOOP
}

var music_map := {
	Music.BGM: {
		"intro": AudioKey.BGM_INTRO,
		"loop": AudioKey.BGM_LOOP
	}
}

var sounds := {
	AudioKey.BGM_INTRO: {
		"type": Type.MUSIC_INTRO,
		"stream": preload("res://assets/sounds/bgm_intro.ogg")
	},
	AudioKey.BGM_LOOP: {
		"type": Type.MUSIC_LOOP,
		"stream": preload("res://assets/sounds/bgm_loop.ogg")
	},
	AudioKey.JUMP: {
		"type": Type.SOUND,
		"stream": preload("res://assets/sounds/jump.ogg")
	},
	AudioKey.MOUSE_WHEEL: {
		"type": Type.SOUND,
		"stream": preload("res://assets/sounds/mousewheel.ogg")
	},
	AudioKey.PICKUP_TIME: {
		"type": Type.SOUND,
		"stream": preload("res://assets/sounds/pickuptime.ogg")
	}
}
