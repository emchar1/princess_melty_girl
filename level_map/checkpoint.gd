extends Area3D
class_name Checkpoint

# PROPERTIES

@onready var spawn_point = $Marker3D


# FUNCTION

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		var player = body as Player
		
		if player:
			GameState.set_checkpoint(spawn_point.global_position)
