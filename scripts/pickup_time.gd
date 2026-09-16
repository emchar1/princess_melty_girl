extends Area3D

# PROPERTIES

signal picked_up_time(add: int)

@export var add_time: int = 10
@onready var sprite = $Sprite3D


# FUNCTIONS

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") or body.is_in_group("princess"):
		var speed := 0.25
		var tween = create_tween()
		
		tween.set_parallel()
		tween.tween_property(sprite, "scale", Vector3(2.5, 2.5, 2.5), speed)
		tween.tween_property(sprite, "position:z", 12.0, speed)
		tween.tween_property(sprite, "modulate:a", 0.0, speed)
		
		picked_up_time.emit(add_time)
		AudioManager.play(AudioData.AudioKey.PICKUP_TIME)
		
		await tween.finished
		queue_free()
