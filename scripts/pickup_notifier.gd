extends Control

@export var pickup_template: PackedScene

func spawn_pickup(ore: String, amount: int):
	var pickup_instance := pickup_template.instantiate()
	pickup_instance.ore_amount = amount
	add_child(pickup_instance)
	var label: Label = pickup_instance.get_node("Label")
	label.text = str("+", amount, " ", ore)
