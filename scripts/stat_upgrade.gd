class_name StatUpgrade
extends Control

enum UpgradeType {Fuel, Scanner, Fortune_Amount, Fortune_Freq, Radar}

@export var type : UpgradeType
@export var pin_button : Button

var fully_upgraded : bool:
	get:
		return get_bought_upgrades() >= get_max_upgrade()

func _ready() -> void:
	for child in get_children():
		if child == pin_button:
			break
		elif child is UpgradeButton:
			child.queue_free()
	
	move_child(pin_button, get_child_count())

func _process(_delta: float) -> void:
	match type:
		UpgradeType.Fortune_Amount:
			visible = Shop.fortune_bought
		UpgradeType.Fortune_Freq:
			visible = Shop.fortune_bought
		UpgradeType.Radar:
			visible = Shop.radar_bought
		_:
			show()

func get_bought_upgrades() -> int:
	var buttons : int = 0
	for child in get_children():
		if child is UpgradeButton:
			if child.bought:
				buttons +=1
	
	return buttons

func get_max_upgrade() -> int:
	var buttons : int = 0
	for child in get_children():
		if child is UpgradeButton:
			buttons += 1
	
	# Subtract 4 base buttons from the prefab
	buttons -= 4
	return buttons
	
