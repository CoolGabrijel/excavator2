extends Node
class_name SceneManager

const player_component = preload("res://components/player.tscn")
@onready var shop: Control = $"../CanvasLayer/Shop"
@onready var game: Node2D = $"../Game"

var player : Player

func _ready() -> void:
	player = player_component.instantiate()
	game.add_child(player)

func _physics_process(_delta: float) -> void:
	if !player:
		return
	
	if player.fuel <= 0 and !shop.visible:
		shop.show()
