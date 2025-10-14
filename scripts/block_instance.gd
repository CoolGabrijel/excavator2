@tool
extends Node2D
class_name BlockInstance

@export var template: BlockTemplate

@onready var front: Sprite2D = $Front
@onready var back: Sprite2D = $Back
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

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
	animated_sprite.hide()
	
	#reveal()

func set_template(new_template: BlockTemplate) -> void:
	template = new_template
	
	if template.BlockTexture:
		front.texture = template.BlockTexture
	if template.BacksideTexture:
		back.texture = template.BacksideTexture
	
	if new_template.BlockAnimation:
		animated_sprite.sprite_frames = new_template.BlockAnimation
		animated_sprite.show()
		animated_sprite.play("default")
	else:
		animated_sprite.hide()

func mine(amount: int) -> void:
	mined = true
	
	if template is OreGen:
		Inventory.add_ore(template.Name, amount)
	
	front.hide()
	animated_sprite.hide()

func reveal() -> void:
	if curtainTween:
		curtainTween.kill()
	
	curtainTween = create_tween()
	curtainTween.tween_property(self, "modulate", Color.WHITE, 0.5)

func can_mine() -> bool:
	return true
