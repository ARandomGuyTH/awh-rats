extends Node

var player := AudioStreamPlayer.new()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE   # keeps playing while paused
	player.bus = "Music"                      # remove this line if you have no Music bus
	add_child(player)

func play_track(stream: AudioStream) -> void:
	if player.stream == stream and player.playing:
		return                                # same track already playing, don't restart
	player.stream = stream
	player.play()

func stop() -> void:
	player.stop()
