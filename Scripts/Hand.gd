extends Node2D

class_name Hand

var CardToGain = null

@onready var CardPlayArea = $PlayArea
@export var bIsPlayerHand = false

func _ready():
	EventManager.CardBeginUnclicked.connect(OnCardBeginUnclicked)

func OnCardBeginUnclicked(card: Card):
	if CardToGain != null:
		if bIsPlayerHand:
			CardToGain.FlipFacing()
		CardToGain.reparent(CardPlayArea)
		CardToGain.bIsFromDeck = false
		CardToGain = null


func _on_area_2d_area_entered(area):
	var card = area.get_parent()
	if card.bIsFromDeck == true:
		CardToGain = card
		card.bFlaggedToMove = true

func _on_area_2d_area_exited(area):
	var card = area.get_parent()
	if card.bIsFromDeck == true:
		CardToGain = null



func _on_play_area_child_order_changed():
	await get_tree().create_timer(.15).timeout
	var width = CardPlayArea.custom_minimum_size.x
	var cardAmount = CardPlayArea.get_child_count()
	var cardWidth = 180
	var minCardSpacing = 40
	var totalCardsWidth = cardWidth * cardAmount

	var actualSpacing = 0

	actualSpacing = cardWidth
	while actualSpacing * cardAmount > width - minCardSpacing * 1.2:
		actualSpacing -= 2
	if actualSpacing < minCardSpacing:
		actualSpacing = minCardSpacing

	var currentXPosition = $Marker2D.global_position.x + cardWidth/2

	if bIsPlayerHand == false:
		actualSpacing = -actualSpacing



	var yPosition = global_position.y -88
	for i in range(0, cardAmount):
		var card = CardPlayArea.get_child(i)
		card.MoveToPosition(Vector2(currentXPosition, yPosition))
		currentXPosition += actualSpacing

