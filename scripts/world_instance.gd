@tool
extends Node2D
class_name WorldInstance

@export var size := Vector2i(32,64)
@export var world_gen_parameter : WorldGenParameter
@export var ores : Array[OreGen]

const block_component = preload("res://components/block.tscn")
const stone_template = preload("res://blocks/Stone.tres")

static var blocks : Dictionary[Vector2i, BlockInstance]

var rng := RandomNumberGenerator.new()

func _ready() -> void:
	randomize_ore_seed()
	generate_base_terrain()
	reveal_top_layer(2)
	reveal_radius(Vector2i.ZERO, 2 + Shop.scan_radius)
	if Engine.is_editor_hint():
		reveal_all()
	call_deferred("test_gen")

func _unhandled_key_input(event: InputEvent) -> void:
	if !event.is_action_pressed("RevealAll"):
		return
	
	reveal_all()

func generate_base_terrain() -> void:
	blocks.clear()
	for y in size.y+1:
		for x in range(-size.x, size.x+1):
			var instance = block_component.instantiate()
			add_child(instance)
			instance.position = Vector2(x*16,y*16)
			blocks[Vector2i(x,y)] = instance
			if y == 2:
				if rng.randf() >= 0.5:
					instance.set_template(stone_template)
			elif y > 2:
				instance.set_template(stone_template)

func generate_block(pos: Vector2i):
	if pos.y == 0: # We are gonna divide with this. Can't be 0. Might as well skip it.
		return
	
	for ore in ores:
		var noise = ore.NoiseGen
		var ramp = ore.Ramp
		
		var val = ramp.sample(float(pos.y) / size.y).a
		# val is 0 when scarce, 1 when plentiful
		
		if val < rng.randf():
			continue
		
		val = noise.get_image().get_pixel(pos.x,pos.y).a
		
		if val > rng.randf():
			blocks[Vector2i(pos.x - size.x,pos.y)].set_template(ore)
			return

func randomize_ore_seed() -> void:
	for ore in ores:
		ore.NoiseGen.noise.seed = randi()

static func reveal_radius(pos:Vector2i, radius: int) -> void:
	for y in range(-radius, radius+1):
		for x in range(-radius, radius+1):
			if absi(x) + absi(y) > radius:
				continue
			var discover_pos : Vector2i = pos + Vector2i(x,y)
			if !blocks.has(discover_pos):
				continue
			
			blocks[discover_pos].reveal()

func reveal_top_layer(depth: int) -> void:
	for y in depth:
		for x in range(-size.x, size.x+1):
			blocks[Vector2i(x,y)].reveal()

func reveal_all() -> void:
	for block_pos in blocks:
		blocks[block_pos].reveal()

func test_gen() -> void:
	for y in size.y:
		for x in range(0, size.x * 2):
			generate_block(Vector2i(x,y))
