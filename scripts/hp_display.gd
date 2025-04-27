extends Label


func _on_player_health_updated(health: int) -> void:
	text = str(health) + "/4"
