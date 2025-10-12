extends Button

var label: Label

func _ready() -> void:
	label = get_parent().get_node_or_null("Label")

func _pressed() -> void:
	var parent := get_parent()
	
	for child in parent.get_children():
		if child is UpgradeButton:
			if child.tooltip_text != "BOUGHT":
				PinDisplay.instance.pin_recipe(label.text, child.cost)
				return
		elif child is UpgradeAug:
			PinDisplay.instance.pin_recipe(child.text, child.cost)
			return
	
	
