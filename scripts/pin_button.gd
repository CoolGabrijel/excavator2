extends Button

var label: Label

@onready var hover_sfx: AudioStreamPlayer = $Hover
@onready var click_sfx: AudioStreamPlayer = $Click

func _ready() -> void:
	label = get_parent().get_node_or_null("Label")
	mouse_entered.connect(_on_hover)

func _pressed() -> void:
	var parent := get_parent()
	
	if click_sfx:
		click_sfx.play()
	
	for child in parent.get_children():
		if child is UpgradeButton:
			if child.tooltip_text != "BOUGHT":
				PinDisplay.instance.pin_recipe(label.text, child.cost)
				return
		elif child is UpgradeAug:
			PinDisplay.instance.pin_recipe(child.text, child.cost)
			return
	


func _on_hover() -> void:
	if !hover_sfx:
		return
	hover_sfx.play()
