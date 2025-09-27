@icon("res://textures/dirt.png")
extends Resource
class_name BlockTemplate

@export var Name := "Unnamed Block"
@export var BlockTexture := load("res://textures/dirt.png")
@export var BlockAnimation: SpriteFrames
@export var BacksideTexture: Texture2D = load("res://textures/stone.png")
