extends Area3D

# PROPERTIES

signal picked_up_time(add: int)

@export var add_time: int = 10


# FUNCTIONS

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		picked_up_time.emit(add_time)
		AudioManager.play(AudioData.AudioKey.PICKUP_TIME)
		
		var tween_speed := 0.25
		var tween_scale := 2.5
		var tween = create_tween()
		tween.tween_property(
			$Sprite3D,
			"scale",
			Vector3(tween_scale, tween_scale, tween_scale),
			tween_speed
		)
		tween.parallel().tween_property(
			$Sprite3D,
			"modulate:a",
			0.0,
			tween_speed
		)
		await tween.finished
		queue_free()
