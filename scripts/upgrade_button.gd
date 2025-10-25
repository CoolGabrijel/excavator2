extends Button
class_name UpgradeButton

@export var cost : Dictionary[String, int]
@onready var shop: Control = $"../../../.."

var type: StatUpgrade.UpgradeType:
	get:
		return $"..".type

func _physics_process(_delta: float) -> void:
	if get_upgrade_index() > get_child_index():
		update_tooltip(null)
		disable_button(shop.style_bought)
		return
	
	var total_cost := get_total_cost()
	update_tooltip(total_cost)
	
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

func _pressed() -> void:
	var index = get_child_index()+1
	
	match type:
		StatUpgrade.UpgradeType.Fuel:
			Shop.fuel_eff = index
		StatUpgrade.UpgradeType.Fortune_Freq:
			Shop.fortune_freq = index
		StatUpgrade.UpgradeType.Fortune_Amount:
			Shop.fortune_amount = index
		StatUpgrade.UpgradeType.Scanner:
			Shop.scan_radius = index
		StatUpgrade.UpgradeType.Radar:
			Shop.radar_radius = index
	
	Inventory.remove_ores(cost)
	update_tooltip(cost)
	
	if PinDisplay.current_upgrade_name == $"../Label".text:
		PinDisplay.instance.remove_pin()
	

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
	if type == StatUpgrade.UpgradeType.Fuel:
		return Shop.fuel_eff
	if type == StatUpgrade.UpgradeType.Fortune_Freq:
		return Shop.fortune_freq
	if type == StatUpgrade.UpgradeType.Fortune_Amount:
		return Shop.fortune_amount
	if type == StatUpgrade.UpgradeType.Radar:
		return Shop.radar_radius
	if type == StatUpgrade.UpgradeType.Scanner:
		return Shop.scan_radius
	return 0

func update_tooltip(total_cost) -> void:
	if get_upgrade_index() > get_child_index():
		tooltip_text = "BOUGHT"
		return
	
	tooltip_text = "Cost: \n"
	for ingredient in total_cost:
		tooltip_text += ingredient + " "
		var amount_in_inv : int = 0
		if Inventory.ores.has(ingredient):
			amount_in_inv = Inventory.ores[ingredient]
		tooltip_text += str(amount_in_inv) + "/" + str(total_cost[ingredient]) + "\n"

func disable_button(style : StyleBoxFlat) -> void:
	disabled = true
	mouse_default_cursor_shape = Control.CURSOR_ARROW
	add_theme_stylebox_override("disabled", style)

func get_child_index() -> int:
	var index : int = 0
	for child in get_parent().get_children():
		if child is UpgradeButton:
			if child == self:
				return index
			index += 1
	printerr("Upgrade_Button :: No child found")
	return 0
