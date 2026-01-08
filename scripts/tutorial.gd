extends Node
class_name Tutorial

static var tut_finished : bool

const player_comp = preload("uid://y2kx1fl6aftx")

enum Stage {Dig, Move, Gather, Buy, Dive}

@export var stage_to_ui: Dictionary[Stage, Control]

@onready var qapur_amount: Label = $TutNotifs/Gather/QapurAmount

var player: Player
var world: WorldInstance
var current_stage := Stage.Dig

var fade_tween : Tween

func _begin_tutorial(scene_manager: SceneManager) -> void:
	player = scene_manager.player
	player.get_node("GUI/FuelDisplay").hide()
	world = scene_manager.world
	
	# We gotta wait a frame.
	await get_tree().physics_frame
	
	for x in range(-world.size.x, world.size.x+1):
		var pos = Vector2i(x, 10)
		WorldInstance.blocks.erase(pos)
		pos += Vector2i.DOWN
		WorldInstance.blocks.erase(pos)
	
	_change_stage(Stage.Dig)
	

func _process(_delta: float) -> void:
	match current_stage:
		Stage.Dig:
			if player.current_grid_position.y >= 5:
				_change_stage(Stage.Move)
		Stage.Move:
			if player.current_grid_position.x >= 2 or player.current_grid_position.x <= -2:
				_change_stage(Stage.Gather)
		Stage.Gather:
			if Inventory.ores.has("Qapur"):
				if Inventory.ores["Qapur"] >= 4:
					_change_stage(Stage.Buy)
		Stage.Buy:
			if Shop.fuel_eff >= 1:
				tut_finished = true
				_change_stage(Stage.Dive)
	
	if Inventory.ores.has("Qapur"):
		qapur_amount.text = str(Inventory.ores["Qapur"], "/4")
	else:
		qapur_amount.text = "0/4"

func _physics_process(_delta: float) -> void:
	if current_stage <= Stage.Gather:
		player.fuel = 15
	else:
		player.fuel = 0

func _change_stage(new_stage: Stage) -> void:
	current_stage = new_stage
	
	if fade_tween:
		fade_tween.kill()
	
	fade_tween = create_tween()
	fade_tween.tween_property($TutNotifs, "modulate", Color.TRANSPARENT, .5)
	await fade_tween.finished
	
	for stage in stage_to_ui:
		stage_to_ui[stage].hide()
	
	stage_to_ui[new_stage].show()
	
	if fade_tween:
		fade_tween.kill()
	
	fade_tween = create_tween()
	fade_tween.tween_property($TutNotifs, "modulate", Color.WHITE, .5)
	
