class_name StatUpgrade
extends Control

enum UpgradeType {Fuel, Scanner, Fortune_Amount, Fortune_Freq, Radar}

@export var type : UpgradeType
@export var pin_button : Button

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
