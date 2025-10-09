extends Button

@onready var label: Label = $"../Label"

func _pressed() -> void:
	var parent := get_parent()
	
	for child in parent.get_children():
		if child is UpgradeButton:
			if child.tooltip_text != "BOUGHT":
				PinDisplay.instance.pin_recipe(label.text, child.cost)
				return
