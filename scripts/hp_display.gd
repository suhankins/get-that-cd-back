extends Label


func _ready() -> void:
	_on_player_health_updated(4)


func _on_player_health_updated(health: int) -> void:
	text = str(health + 1) + "/5"
