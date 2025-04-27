extends AnimationObject

@export var text: String
@export var stream: AudioStream
@export var theme: Theme
@export var stay_on_screen_for: float = 0.5
@onready var label: RichTextLabel = $RichTextLabel
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

func play_animation():
	label.theme = theme
	label.text = text
	audio_player.stream = stream
	await get_tree().create_timer(delay).timeout
	audio_player.playing = true
	label.show()
	await audio_player.finished
	await get_tree().create_timer(stay_on_screen_for).timeout
	label.hide()
	queue_free()
