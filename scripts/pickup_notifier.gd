extends Control

@export var pickup_template: PackedScene

var queue : Dictionary[String, int]
var last_pickup := 0

func on_ore_mined(ore: String, amount: int):
	#spawn_pickup(ore, amount)
	add_to_queue(ore, amount)

func _process(_delta: float) -> void:
	if queue.size() <= 0:
		return
	
	if Time.get_ticks_msec() - last_pickup >= 1000:
		last_pickup = Time.get_ticks_msec()
		var ores := queue.keys()
		var ore = ores[0]
		var amount := queue[ore]
		spawn_pickup(ore, amount)
		queue.erase(ore)

func spawn_pickup(ore: String, amount: int):
	var pickup_instance := pickup_template.instantiate()
	pickup_instance.ore_amount = amount
	add_child(pickup_instance)
	var label: Label = pickup_instance.get_node("Label")
	label.text = str("+", amount, " ", ore)

func add_to_queue(ore: String, amount: int):
	if queue.has(ore):
		queue[ore] += amount
	else:
		queue[ore] = amount
