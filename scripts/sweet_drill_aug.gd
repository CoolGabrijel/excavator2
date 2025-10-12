extends Control

@export var progress_bar_normal_style: StyleBoxFlat
@export var progress_bar_miss_style: StyleBoxFlat

@onready var player: Player = $".."
@onready var progress_bar: ProgressBar = $Bar/ProgressBar
@onready var detail: TextureRect = $Bar/Detail
@onready var hitGraphic: ColorRect = $ColorRect

var ores_tested : Dictionary[Vector2i, bool]
var ores_missed : Array[Vector2i]
var rng := RandomNumberGenerator.new()
var forgiveness := 1.5

var miss_tween: Tween

func _physics_process(_delta: float) -> void:
	handle_sweet_spot()

func handle_sweet_spot() -> void:
	if !Shop.sweet_drilling_bought:
		return
	
	if !WorldInstance.blocks.has(player.target_grid_position):
		return
	
	var target_block := WorldInstance.blocks[player.target_grid_position]
	var movement_input := player.movement_input
	
	if target_block.template is not OreGen:
		hide()
		return
	
	if target_block.mined or ores_missed.has(player.target_grid_position):
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
		progress_bar.add_theme_stylebox_override("fill", progress_bar_normal_style)
		if miss_tween:
			miss_tween.kill()
		scale = Vector2.ONE
		modulate = Color.WHITE
		rotation_degrees = 0
		show()
	
	var filled = progress_bar.value / progress_bar.max_value
	var spot = filled * progress_bar.size.y
	
	progress_bar.value = player.movement_progress
	
	#if movement_input.y > 0:
		#progress_bar.value = (grid_to_world_space(current_grid_position) - player.position).y
	#elif movement_input.y < 0:
		#progress_bar.value = (player.position - grid_to_world_space(current_grid_position)).y
	#elif movement_input.x > 0:
		#progress_bar.value = (player.position - grid_to_world_space(current_grid_position)).x
	#elif movement_input.x < 0:
		#progress_bar.value = (grid_to_world_space(current_grid_position) - player.position).x
	if movement_input.length() == 0:
		if spot > $SweetSpot.position.y + forgiveness and spot < $SweetSpot.position.y + $SweetSpot.size.y + forgiveness:
			#current_grid_position = target_grid_position
			sweet_spot_hit(player.target_grid_position)
		else:
			sweet_spot_miss(player.target_grid_position)
	
	detail.position.y = spot - detail.size.y
	hitGraphic.position.y = spot - hitGraphic.size.y

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

func sweet_spot_miss(target_pos: Vector2i):
	if miss_tween:
		miss_tween.kill()
	
	progress_bar.add_theme_stylebox_override("fill", progress_bar_miss_style)
	
	miss_tween = create_tween()
	miss_tween.set_ease(Tween.EASE_OUT)
	miss_tween.set_trans(Tween.TRANS_QUART)
	miss_tween.set_parallel()
	miss_tween.tween_property(self, "scale", Vector2.ONE * 2, 1)
	miss_tween.tween_property(self, "modulate", Color.TRANSPARENT, 1)
	miss_tween.tween_property(self, "rotation_degrees", 35, 1)
	ores_tested[target_pos] = false
	ores_missed.append(target_pos)

func grid_to_world_space(grid_pos: Vector2i) -> Vector2:
	return player.grid_to_world_space(grid_pos)
