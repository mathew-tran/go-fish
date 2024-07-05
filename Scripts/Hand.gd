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
	var width = CardPlayArea.custom_minimum_size.x * 2
	var cardAmount = CardPlayArea.get_child_count()
	var cardWidth = 200
	var minCardSpacing = 50
	var totalCardsWidth = cardWidth * cardAmount

	var actualSpacing = 0
	if totalCardsWidth > width:
		actualSpacing = minCardSpacing
		print("defaulted")
	else:
		actualSpacing = (width - totalCardsWidth) / (cardAmount -1)
		if actualSpacing < minCardSpacing:
			actualSpacing = minCardSpacing
		elif actualSpacing > cardWidth:
			actualSpacing = cardWidth


	var currentXPosition = $Marker2D.global_position.x + cardWidth/2
	var yPosition = global_position.y -88
	for i in range(0, cardAmount):
		var card = CardPlayArea.get_child(i)
		card.MoveToPosition(Vector2(currentXPosition, yPosition))
		currentXPosition += actualSpacing

