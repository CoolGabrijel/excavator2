extends Button
class_name UpgradeButton

enum UpgradeType {Fuel, Scanner, Fortune_Amount, Fortune_Freq}

@export var type : UpgradeType
@export var cost : Dictionary[String, int]
@onready var shop: Control = $"../../../.."

func _physics_process(_delta: float) -> void:
	if get_upgrade_index() > get_child_index():
		disable_button(shop.style_bought)
		return
	
	var total_cost := get_total_cost()
	tooltip_text = "Cost: \n"
	for ingredient in total_cost:
		tooltip_text += ingredient + " " + str(total_cost[ingredient]) + "\n"
	
	for ingredient in total_cost:
		if !Inventory.ores.has(ingredient):
			disable_button(shop.style_unaffordable)
		else:
			if Inventory.can_afford(get_total_cost()):
				add_theme_stylebox_override("normal", shop.style_afford)
				disabled = false
				mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
				break
			else:
				disable_button(shop.style_unaffordable)

func get_total_cost() -> Dictionary[String, int]:
	var final_cost : Dictionary[String, int]
	var index : int = 0
	var buttons : Array[UpgradeButton]
	for child in get_parent().get_children():
		if child is UpgradeButton:
			buttons.append(child)
			if get_upgrade_index() > index:
				index += 1
				continue
			
			for ingredient in child.cost:
				if !final_cost.has(ingredient):
					final_cost[ingredient] = 0
				final_cost[ingredient] += child.cost[ingredient]
			if child == self:
				break
			index += 1
	return final_cost

func get_upgrade_index() -> int:
	if type == UpgradeType.Fuel:
		return Shop.fuel_eff
	if type == UpgradeType.Fortune_Freq:
		return Shop.fortune_freq
	if type == UpgradeType.Fortune_Amount:
		return Shop.fortune_amount
	return 0

func disable_button(style : StyleBoxFlat) -> void:
	disabled = true
	mouse_default_cursor_shape = Control.CURSOR_ARROW
	add_theme_stylebox_override("disabled", style)

func get_child_index() -> int:
	var index : int
	for child in get_parent().get_children():
		if child is Button:
			if child == self:
				return index
			index += 1
	printerr("Upgrade_Button :: No child found")
	return 0
