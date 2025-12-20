extends Control
class_name ShopScreen

static var Instance : ShopScreen

@export var style_bought : StyleBoxFlat
@export var style_afford : StyleBoxFlat
@export var style_unaffordable : StyleBoxFlat

@export_category("Upgrades")
@export var stat_upgrades : Array[StatUpgrade]

func _ready() -> void:
	Instance = self
	pass

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
