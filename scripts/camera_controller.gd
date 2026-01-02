class_name CameraController
extends Camera2D

static var camera_shake_amount := 0.0
var shake_target := Vector2.ZERO
var rng := RandomNumberGenerator.new()

func _process(_delta: float) -> void:
	var x = rng.randf_range(-camera_shake_amount, camera_shake_amount)
	var y = rng.randf_range(-camera_shake_amount, camera_shake_amount)
	shake_target = Vector2(x,y)
	position = lerp(position, shake_target, 1)
