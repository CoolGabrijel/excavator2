class_name PinDisplay
extends Control

static var instance: PinDisplay
static var current_recipe: Dictionary[String, int]
static var current_upgrade_name: String

@onready var header: Label = $Panel/Header
@onready var costs: RichTextLabel = $Panel/Costs

func _ready() -> void:
	instance = self
	update_display()

func _process(_delta: float) -> void:
	update_display()

func pin_recipe(upgrade_name: String, recipe: Dictionary[String, int]):
	current_recipe = recipe
	current_upgrade_name = upgrade_name
	update_display()

func update_display():
	if current_recipe == null || current_recipe.is_empty():
		hide()
		return
	else:
		show()
	
	header.text = current_upgrade_name
	
	costs.text = ""
	for ore in current_recipe:
		var amount_in_inv: int = 0
		if Inventory.ores.has(ore):
			amount_in_inv = Inventory.ores[ore]
		
		var line: String = str(amount_in_inv, "/", current_recipe[ore], " ", ore, "\n")
		
		if amount_in_inv >= current_recipe[ore]:
			costs.push_color(Color.GREEN)
			costs.append_text(line)
			costs.pop()
		else:
			costs.append_text(line)
