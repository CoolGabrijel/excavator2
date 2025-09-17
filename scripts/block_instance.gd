@tool
extends Node2D
class_name BlockInstance

@export var template: BlockTemplate

@onready var front: Sprite2D = $Front
@onready var back: Sprite2D = $Back

var mined := false
var curtainTween : Tween

func _ready() -> void:
	modulate = Color.BLACK
	
	if !template:
		return
	
	if !template.BlockTexture or !template.BacksideTexture:
		return
	
	front.texture = template.BlockTexture
	back.texture = template.BacksideTexture
	
	#reveal()

func set_template(new_template: BlockTemplate) -> void:
	template = new_template
	front.texture = template.BlockTexture
	back.texture = template.BacksideTexture

func mine(amount: int) -> void:
	mined = true
	
	if template is OreGen:
		Inventory.add_ore(template.Name, amount)
	
	front.hide()

func reveal() -> void:
	if curtainTween:
		curtainTween.kill()
	
	curtainTween = create_tween()
	curtainTween.tween_property(self, "modulate", Color.WHITE, 1)

func can_mine() -> bool:
	return true
