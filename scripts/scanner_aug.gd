extends Sprite2D

@onready var player: Player = $".."
@onready var label: Label = $"../GUI/ScannerDisplay/Label"

var mouse_world_coords: Vector2
var mouse_grid_coords: Vector2i
var cooldown: int = 0

func _ready() -> void:
	if !Shop.scan_bought:
		hide()
		label.text = ""
		return
	
	show()

func _process(_delta: float) -> void:
	if !Shop.scan_bought:
		return
	
	mouse_world_coords = get_viewport().get_camera_2d().get_global_mouse_position()
	mouse_grid_coords = player.world_to_grid_space(mouse_world_coords)
	position = player.grid_to_world_space(mouse_grid_coords)
	
	if mouse_grid_coords.y <= 0:
		hide()
		return
	else:
		show()

func _unhandled_input(event: InputEvent) -> void:
	if cooldown > 0:
		return
	
	if event is not InputEventMouseButton:
		return
	
	var mouse_input: InputEventMouseButton = event
	if mouse_input.button_index == MOUSE_BUTTON_LEFT and mouse_input.pressed:
		WorldInstance.reveal_radius(mouse_grid_coords, 2)
		get_viewport().set_input_as_handled()
		cooldown = 5
		label.text = str("Scanner Cooldown: ", cooldown)

func block_mined(_block: BlockInstance):
	if !Shop.scan_bought:
		label.text = ""
		return
	
	if cooldown > 0:
		cooldown -= 1
	
	label.text = str("Scanner Cooldown: ", cooldown)
