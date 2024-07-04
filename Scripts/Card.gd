@tool

extends Sprite2D

class_name Card

@export var bShowBack = false


func _ready():
	UpdateUI()


func UpdateUI():
	$Content.visible = bShowBack == false
	if bShowBack:
		texture = load("res://Art/CardBack.svg")
	else:
		texture = load("res://Art/CardFront.svg")

