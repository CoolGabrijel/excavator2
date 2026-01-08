extends Node
class_name SceneManager

static var intro_complete: bool

const player_component = preload("res://components/player.tscn")
const tutorial_scene = preload("uid://dey3vc245pjee")

@onready var shop: Control = $"../CanvasLayer/Shop"
@onready var game: Node2D = $"../Game"
@onready var world: WorldInstance = $"../Game/World"

var player : Player

func _ready() -> void:
	if !intro_complete:
		return
	
	player = player_component.instantiate()
	game.add_child(player)
	
	if !Tutorial.tut_finished:
		var tut_instance: Tutorial = tutorial_scene.instantiate()
		$"../CanvasLayer".add_child(tut_instance)
		tut_instance._begin_tutorial(self)

func _physics_process(_delta: float) -> void:
	if !player:
		return
	
	if player.fuel <= 0 and !shop.visible:
		shop.show()
