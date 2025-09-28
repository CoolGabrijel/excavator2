extends Control

@onready var player: Player = $".."

var ores_tested : Dictionary[Vector2i, bool]
var rng := RandomNumberGenerator.new()

func _physics_process(_delta: float) -> void:
	handle_sweet_spot()

func handle_sweet_spot() -> void:
	if !Shop.sweet_drilling_bought:
		return
	
	if !WorldInstance.blocks.has(player.target_grid_position):
		return
	
	var target_block := WorldInstance.blocks[player.target_grid_position]
	var movement_input := player.movement_input
	var current_grid_position := player.current_grid_position
	
	if target_block.template is not OreGen:
		hide()
		return
	
	if target_block.mined:
		return
	
	if !ores_tested.has(player.target_grid_position):
		var val := rng.randf()
		if val < 0.5:
			ores_tested[player.target_grid_position] = false
			hide()
			return
		else:
			ores_tested[player.target_grid_position] = true
	else:
		if !ores_tested[player.target_grid_position]:
			hide()
			return
	
	if !visible:
		$SweetSpot.size.y = 4 + (2 * Shop.sweet_drilling_size)
		$SweetSpot.position.y = randi_range(size.y / 2, size.y - $SweetSpot.size.y)
		show()
	
	if movement_input.y > 0:
		$ProgressBar.value = (grid_to_world_space(current_grid_position) - player.position).y
	elif movement_input.y < 0:
		$ProgressBar.value = (player.position - grid_to_world_space(current_grid_position)).y
	elif movement_input.x > 0:
		$ProgressBar.value = (player.position - grid_to_world_space(current_grid_position)).x
	elif movement_input.x < 0:
		$ProgressBar.value = (grid_to_world_space(current_grid_position) - player.position).x
	elif movement_input.length() == 0:
		var filled = $ProgressBar.value / $ProgressBar.max_value
		var spot = filled * $ProgressBar.size.y
		if spot > $SweetSpot.position.y and spot < $SweetSpot.position.y + $SweetSpot.size.y:
			#current_grid_position = target_grid_position
			sweet_spot_hit(player.target_grid_position)

func sweet_spot_hit(target_pos: Vector2i) -> void:
	#target_block.mine(2 * player.roll_fortune())
	
	var ore_mined : Dictionary[String, int]
	
	var blocks := WorldInstance.get_blocks_in_radius(target_pos, 2)
	for block in blocks:
		block.reveal()
		var fortune := player.roll_fortune()
		block.mine(fortune)
		
		if block.template is not OreGen:
			continue
		
		if ore_mined.has(block.template.Name):
			ore_mined[block.template.Name] += fortune
		else:
			ore_mined[block.template.Name] = fortune
	
	for ore in ore_mined:
		player.ore_mined.emit(ore, ore_mined[ore])
	
	hide()

func grid_to_world_space(grid_pos: Vector2i) -> Vector2:
	return player.grid_to_world_space(grid_pos)
