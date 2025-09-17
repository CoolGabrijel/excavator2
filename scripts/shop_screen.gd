extends Control

@export var style_bought : StyleBoxFlat
@export var style_afford : StyleBoxFlat
@export var style_unaffordable : StyleBoxFlat

@export_category("Upgrades")
@export var upgrade_fuel : HBoxContainer
@export var upgrade_fuel_buttons : Array[Button]

func _ready() -> void:
	#update_upgrades()
	pass

func dive_again() -> void:
	get_tree().reload_current_scene()

func update_upgrades() -> void:
	var buttons : Array[Button]
	
	buttons = get_buttons(upgrade_fuel)
	for button in buttons:
		button.disabled = true
	for upgrade_index in Shop.fuel_eff:
		buttons[upgrade_index].add_theme_stylebox_override("normal", style_bought)
		buttons[upgrade_index].disabled = false

func get_buttons(target: Control) -> Array[Button]:
	var buttons : Array[Button]
	
	for child in upgrade_fuel.get_children():
		if child is Button:
			buttons.append(child)
	
	return buttons
