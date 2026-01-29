extends Control
class_name ShopScreen

static var Instance : ShopScreen

@export var style_bought : StyleBoxFlat
@export var style_afford : StyleBoxFlat
@export var style_unaffordable : StyleBoxFlat

@export_category("Upgrades")
@export var stat_upgrades : Array[StatUpgrade]

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	Instance = self
	pass

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("CheatShop"):
		visible = !visible
	

func _on_visibility_changed() -> void:
	if anim_player.is_playing():
		anim_player.stop()
	
	anim_player.play("open")
	

func check_win_con() -> bool:
	for upgrade in stat_upgrades:
		if !upgrade.fully_upgraded:
			return false
	return true

func dive_again() -> void:
	get_tree().reload_current_scene()

func get_buttons(target: Control) -> Array[Button]:
	var buttons : Array[Button]
	
	for child in target.get_children():
		if child is Button:
			buttons.append(child)
	
	return buttons
