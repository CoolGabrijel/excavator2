extends Node
class_name Inventory

static var ores : Dictionary[String, int]

static func add_ore(ore: String, amount: int) -> void:
	if !ores.has(ore):
		ores[ore] = 0
	
	ores[ore] += amount
	print("Inventory :: Added " + str(amount) + " " + ore)

static func can_afford(cost: Dictionary[String,int]) -> bool:
	for ingredient in cost:
		if !ores.has(ingredient):
			return false
		elif ores[ingredient] < cost[ingredient]:
			return false
	
	return true
