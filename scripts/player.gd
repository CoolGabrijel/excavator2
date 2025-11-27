extends Node2D
class_name Player

signal block_mined(block)
signal ore_mined(ore, amount)

@onready var gfx: Node2D = $Gfx
@onready var sprite: AnimatedSprite2D = $Gfx/AnimatedSprite2D
@onready var sparks: GPUParticles2D = $Gfx/Sparks
@onready var freefall_sfx: AudioStreamPlayer = $Freefall
@onready var pickup_sfx: AudioStreamPlayer = $Pickup
@onready var engine_idle_sfx: AudioStreamPlayer = $EngineIdle
@onready var engine_hum_sfx: AudioStreamPlayer = $EngineHum

@export var speed: float = 1
@export var speed_mined_modifier: float = 4

var current_grid_position : Vector2i
var target_grid_position : Vector2i
var is_moving : bool
var movement_input : Vector2
var last_input : Vector2
var movement_progress : float
var movement_position_target : Vector2
var fuel : int = 15
var locked := true
var rng := RandomNumberGenerator.new()
var moveTween : Tween
var sfxTween : Tween

func _ready() -> void:
	current_grid_position = Vector2i(0,0)
	fuel = 15 + 5 * Shop.fuel_eff
	sparks.emitting = false
	CameraController.camera_shake_amount = 1
	
	gfx.position.y -= 500
	var intro_tween: Tween = create_tween()
	intro_tween.set_ease(Tween.EASE_IN)
	intro_tween.set_trans(Tween.TRANS_EXPO)
	intro_tween.tween_property(gfx, "position", Vector2(0, -16), 1)
	intro_tween.parallel().tween_method(func(val): CameraController.camera_shake_amount = val, 1,0,1)
	intro_tween.parallel().tween_property(freefall_sfx, "volume_linear", 0, 1)
	intro_tween.tween_property(gfx, "position", Vector2.ZERO, 0.75).set_ease(Tween.EASE_OUT)
	intro_tween.finished.connect(func(): locked = false)
	intro_tween.finished.connect(func(): WorldInstance.blocks[Vector2i.ZERO].mine(roll_fortune()))
	intro_tween.finished.connect(func(): CameraController.camera_shake_amount = 0)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("CheatFuel"):
		fuel += 10

func _physics_process(_delta: float) -> void:
	_capture_movement()
	handle_movement()
	position = lerp(position, movement_position_target, 0.1)
	$CurrentPos.global_position = grid_to_world_space(current_grid_position)
	$TargetPos.global_position = grid_to_world_space(target_grid_position)

func handle_movement() -> void:
	if locked or fuel <= 0:
		return
	
	var dir := Vector2.ZERO
	
	if movement_input.x > 0:
		target_grid_position = current_grid_position + Vector2i(1,0)
		dir = Vector2.RIGHT
		gfx.rotation_degrees = -90
	elif movement_input.x < 0:
		target_grid_position = current_grid_position + Vector2i(-1,0)
		dir = Vector2.LEFT
		gfx.rotation_degrees = 90
	elif movement_input.y > 0:
		if target_grid_position.y > 0: #Make sure the player doesn't start flying
			target_grid_position = current_grid_position + Vector2i(0,-1)
			dir = Vector2.UP
			gfx.rotation_degrees = 180
	elif movement_input.y < 0:
		target_grid_position = current_grid_position + Vector2i(0,1)
		dir = Vector2.DOWN
		gfx.rotation_degrees = 0
	
	# For Animation and Audio
	if movement_input.length() > 0:
		if !sprite.is_playing():
			sprite.play("default")
		
		is_moving = true
	else:
		sprite.stop()
		
		is_moving = false
	
	if !WorldInstance.blocks.has(target_grid_position):
		return
	
	var target_block := WorldInstance.blocks[target_grid_position]
	
	# Checks if player changed input
	# To combat players holding one key, then the next and the progress carrying over
	# Also to stop mining when player lets go of the keys
	if !is_input_same() || movement_input == Vector2.ZERO || !target_block.can_mine():
		movement_progress = 0
		last_input = movement_input
		movement_position_target = grid_to_world_space(current_grid_position)
		sparks.emitting = false
		CameraController.camera_shake_amount = 0
		return
	
	if !target_block.mined:
		if target_block.template is OreGen:
			movement_progress += speed / 3
			CameraController.camera_shake_amount = .25
		else:
			movement_progress += speed
		sparks.emitting = true
	else:
		movement_progress += speed * speed_mined_modifier
		sparks.emitting = false
		CameraController.camera_shake_amount = 0
	
	if movement_progress > 0.5:
		movement_progress -= 1
		current_grid_position = target_grid_position
		WorldInstance.reveal_radius(current_grid_position, 2 + Shop.scan_radius)
		if target_block.can_mine() and !target_block.mined:
			var fortune := roll_fortune()
			target_block.mine(fortune)
			fuel -=1
			block_mined.emit(target_block)
			if target_block.template is OreGen:
				ore_mined.emit(target_block.template.Name, fortune)
				pickup_sfx.play()
	
	movement_position_target = lerp(grid_to_world_space(current_grid_position), grid_to_world_space(target_grid_position), movement_progress)
	
	last_input = movement_input

func roll_fortune() -> int:
	var val := rng.randf()
	var fortune_chance : float = 0.1 * Shop.fortune_freq
	if fortune_chance > val:
		return Shop.fortune_amount + 2
	return 1

func _capture_movement() -> void:
	movement_input = Input.get_vector("Left","Right","Down","Up")

func is_input_same() -> bool:
	if movement_input.x > 0 and last_input.x <= 0:
		return false
	if movement_input.x < 0 and last_input.x >= 0:
		return false
	if movement_input.x == 0 and last_input.x != 0:
		return false
	if movement_input.y > 0 and last_input.y <= 0:
		return false
	if movement_input.y < 0 and last_input.y >= 0:
		return false
	if movement_input.y == 0 and last_input.y != 0:
		return false
	return true

func world_to_grid_space(world_pos: Vector2) -> Vector2i:
	var rounded_pos = world_pos.round()
	if rounded_pos.x >= 0:
		rounded_pos.x += 8
	else:
		rounded_pos.x -= 8
	rounded_pos += Vector2.DOWN * 8
	return rounded_pos / 16

func grid_to_world_space(grid_pos: Vector2i) -> Vector2:
	return Vector2(grid_pos.x * 16, grid_pos.y * 16)
