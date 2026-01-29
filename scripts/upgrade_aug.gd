class_name UpgradeAug
extends Button

enum AugType {Radar, Fortune, SweetDrill}

@export var type : AugType
@export var cost : Dictionary[String, int]

@onready var shop: Control = $"../../../../../.."
@onready var hover_sfx: AudioStreamPlayer = $Hover
@onready var click_sfx: AudioStreamPlayer = $Click

var bought: bool:
	get:
		match type:
			AugType.Radar:
				return Shop.radar_bought
			AugType.Fortune:
				return Shop.fortune_bought
			AugType.SweetDrill:
				return Shop.sweet_drilling_bought
			_:
				return true

func _ready() -> void:
	mouse_entered.connect(_on_hover)

func _process(_delta: float) -> void:
	get_parent().visible = !bought
	
	update_tooltip(cost)
	
	for ingredient in cost:
		if !Inventory.ores.has(ingredient):
			disable_button(shop.style_unaffordable)
		else:
			if Inventory.can_afford(cost):
				add_theme_stylebox_override("normal", shop.style_afford)
				disabled = false
				mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
				add_theme_color_override("font_color", Color.BLACK)
				break
			else:
				disable_button(shop.style_unaffordable)

func _pressed() -> void:
	match type:
		AugType.Radar:
			Shop.radar_bought = true
		AugType.Fortune:
			Shop.fortune_bought = true
		AugType.SweetDrill:
			Shop.sweet_drilling_bought = true
	
	Inventory.remove_ores(cost)
	
	if PinDisplay.current_upgrade_name == text:
		PinDisplay.instance.remove_pin()
	
	if click_sfx:
		click_sfx.play()

func update_tooltip(total_cost) -> void:
	tooltip_text = ""
	
	match type:
		AugType.Radar:
			tooltip_text += "Attach a radar which allows you to reveal ores in a radius.\n\n"
			tooltip_text += "Use the Mouse to aim and Left click to Scan\n"
		AugType.Fortune:
			tooltip_text += "Drillhead is more precise. Grants a chance to get more yield.\n"
		AugType.SweetDrill:
			tooltip_text += "Find and exploit Ore weakspots.\n\n"
			tooltip_text += "When mining there is a chance for a bar to appear. When you let go\n"
			tooltip_text += "as soon as the bar reaches the 'sweet spot', you mine in a radius.\n"
	
	tooltip_text += "\n"
	tooltip_text += "Cost: \n"
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
	add_theme_color_override("font_color", Color.WHITE)

func _on_hover() -> void:
	if hover_sfx:
		hover_sfx.play()
