extends ScriptedSpawnsTrigger

@export var required_kills: Array[Enemy]
var count: int = 0

func _ready() -> void:
	for enemy in required_kills:
		enemy.died.connect(enemy_died)

func enemy_died() -> void:
	count += 1
	if (count >= required_kills.size()):
		_on_elevator_button_off_broke()
