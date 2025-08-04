extends Node2D
class_name Player

@export var speed: float = 1

var current_grid_position : Vector2i
var target_grid_position : Vector2i
var movement_input : Vector2
var last_input : Vector2
var fuel : int = 15
var locked := true
var rng := RandomNumberGenerator.new()
var moveTween : Tween

func _ready() -> void:
	current_grid_position = Vector2i(0,0)
	fuel = 15 + 5 * Shop.fuel_eff
	locked = false

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("CheatFuel"):
		fuel += 10

func _physics_process(delta: float) -> void:
	handle_movement(delta)

func handle_movement(delta: float) -> void:
	if locked or fuel <= 0:
		return
	
	var xDir = Input.get_axis("Left", "Right")
	var yDir = Input.get_axis("Down", "Up")
	var dir := Vector2.ZERO
	movement_input = Vector2(xDir, yDir)
	
	if xDir > 0:
		target_grid_position = current_grid_position + Vector2i(1,0)
		dir = Vector2.RIGHT
		$Sprite2D.frame = 0
	elif xDir < 0:
		target_grid_position = current_grid_position + Vector2i(-1,0)
		dir = Vector2.LEFT
		$Sprite2D.frame = 1
	elif yDir > 0:
		if target_grid_position.y > 0: #Make sure the player doesn't start flying
			target_grid_position = current_grid_position + Vector2i(0,-1)
			dir = Vector2.UP
			$Sprite2D.frame = 3
	elif yDir < 0:
		target_grid_position = current_grid_position + Vector2i(0,1)
		dir = Vector2.DOWN
		$Sprite2D.frame = 2
	
	if !WorldInstance.blocks.has(target_grid_position):
		return
	
	var target_block := WorldInstance.blocks[target_grid_position]
	
	if is_input_same():
		if target_block.template is not OreGen or target_block.mined:
			position = position + dir * delta * speed
		else:
			position = position + dir * delta * speed / 3
	
	if (world_to_grid_space(position) - current_grid_position).length() > 0:
		current_grid_position = target_grid_position
		WorldInstance.reveal_radius(current_grid_position, 2 + Shop.scan_radius)
		if target_block.can_mine() and !target_block.mined:
			target_block.mine(roll_fortune())
			fuel -=1
	
	if movement_input.length() == 0 and !target_block.mined:
		# Player let go of movement keys. Bring him back
		position = lerp(position, grid_to_world_space(current_grid_position), delta * speed)
	
	$CurrentPos.global_position = grid_to_world_space(world_to_grid_space(position))
	$TargetPos.global_position = grid_to_world_space(target_grid_position)
	last_input = movement_input

func roll_fortune() -> int:
	var val := rng.randf()
	var fortune_chance : float = 0.1 * Shop.fortune_freq
	if fortune_chance > val:
		return Shop.fortune_amount + 2
	return 1

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
