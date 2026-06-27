extends Node

@export var intro_audio : AudioStreamPlayer
@export var audio_player : AudioStreamPlayer

func _ready() -> void:
	if !SceneManager.intro_complete:
		return
	
	intro_audio.play()
	intro_audio.finished.connect(_on_intro_finished)

func _on_intro_finished() -> void:
	audio_player.play()
