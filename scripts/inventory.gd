extends Node
class_name Inventory

static var ores : Dictionary[String, int]

static func add_ore(ore: String, amount: int) -> void:
	if !ores.has(ore):
		ores[ore] = 0
	
	ores[ore] += amount
	print("Inventory :: Added " + str(amount) + " " + ore)

static func remove_ores(ores_to_remove: Dictionary[String, int]) -> void:
	for ore in ores_to_remove:
		remove_ore(ore, ores_to_remove[ore])

static func remove_ore(ore: String, amount: int) -> void:
	if !ores.has(ore):
		printerr("Inventory :: Error : No Ore of type " + ore + " in Inventory.")
		return
	
	if ores[ore] < amount:
		printerr("Inventory :: Error : Not enough of " + ore + "in Inventory. (has " + str(ores[ore]) + "but needs " + str(amount) + ")")
		return
	
	ores[ore] -= amount
	print("Inventory :: Removed " + str(amount) + " " + ore)

static func can_afford(cost: Dictionary[String,int]) -> bool:
	for ingredient in cost:
		if !ores.has(ingredient):
			return false
		elif ores[ingredient] < cost[ingredient]:
			return false
	
	return true
