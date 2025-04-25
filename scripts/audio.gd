extends Node

# Code adapted from KidsCanCode

var num_players = 12
var bus = "master"

var available = []  # The available players.
var queue = []  # The queue of sounds to play.

func _ready():
	for i in num_players:
		var p = AudioStreamPlayer.new()
		add_child(p)

		available.append(p)

		p.volume_db = -10
		p.finished.connect(_on_stream_finished.bind(p))
		p.bus = bus

func _on_stream_finished(stream):
	available.append(stream)

func play_stream(stream: AudioStream):
	queue.append(stream)

func play(sound_path: String):  # Path (or multiple, separated by commas)
	var sounds = sound_path.split(",")
	queue.append("res://" + sounds[randi() % sounds.size()].strip_edges())

func _process(_delta):
	if not queue.is_empty() and not available.is_empty():
		var next = queue.pop_front()
		if (next is AudioStream):
			available[0].stream = next
		else:
			available[0].stream = load(next)
		available[0].play()
		available[0].pitch_scale = randf_range(0.9, 1.1)

		available.pop_front()
