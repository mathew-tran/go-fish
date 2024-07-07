extends Node2D

class_name Hand

var CardToGain : Card

@onready var CardPlayArea = $PlayArea
@export var bIsPlayerHand = false

func _ready():
	EventManager.CardBeginUnclicked.connect(OnCardBeginUnclicked)

func OnCardBeginUnclicked(card: Card):
	if CardToGain != null:
		if bIsPlayerHand:
			CardToGain.FlipFacing()
			CardToGain.SetEnable(true)
		CardToGain.reparent(CardPlayArea)
		CardToGain.RemoveFromDeck()
		CardToGain = null

func GetHandGainPosition():
	return $HandGainPosition.global_position + Vector2(randi_range(-100, 100), randi_range(-100,100))

func GetCoinPlacementPosition():
	return $CoinPlacementPosition.global_position

func GainCard(card : Card):
	card.bFlaggedToMove = true
	CardToGain = card
	OnCardBeginUnclicked(CardToGain)

func _on_area_2d_area_entered(area):
	var card = area.get_parent()
	if card.bIsFromDeck == true:
		CardToGain = card
		card.bFlaggedToMove = true

func _on_area_2d_area_exited(area):
	var card = area.get_parent()
	if card.bIsFromDeck == true:
		CardToGain = null
		card.bFlaggedToMove = false



func _on_play_area_child_order_changed():
	await get_tree().create_timer(.05).timeout
	var width = 1350
	var cardAmount = CardPlayArea.get_child_count()
	var cardWidth = 180
	var minCardSpacing = 30
	var totalCardsWidth = cardWidth * cardAmount

	var actualSpacing = 0

	actualSpacing = cardWidth
	while actualSpacing * cardAmount > width - minCardSpacing * 1.2:
		actualSpacing -= 1
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

