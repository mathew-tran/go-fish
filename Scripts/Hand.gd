extends Node2D

class_name Hand

var CardToGain : Card

@onready var CardPlayArea = $PlayArea
@export var bIsPlayerHand = false

func GetFirstPrompt():
	if bIsPlayerHand:
		return "You go first"
	else:
		return "Opponent goes first"

func GetPlayerName():
	if bIsPlayerHand:
		return "Player"
	else:
		return "Opponent"

func GetPlayerPrompt():
	if bIsPlayerHand:
		return "It's your turn"
	else:
		return "It's the opponent's turn"

func GetOutOfCardPrompt():
	if bIsPlayerHand:
		return "You are out of cards!"
	else:
		return "Opponent was out of cards!"

func _ready():
	EventManager.CardBeginUnclicked.connect(OnCardBeginUnclicked)

func OnCardBeginUnclicked(card: Card):
	if CardToGain != null:
		if bIsPlayerHand:
			CardToGain.FlipFacing()
			CardToGain.SetEnable(true)
		else:
			CardToGain.FlipToBack()
			CardToGain.SetEnable(false)
		CardToGain.reparent(CardPlayArea)
		CardToGain.RemoveFromDeck()
		CardToGain = null

func GetCards():
	return $PlayArea.get_children()

func HasCards():
	return $PlayArea.get_child_count() > 0

func GetRandomCardFromHand():
	var cards = GetCards()
	return cards[randi() % len(cards)]

func QueryOtherHand(otherHand : Hand, queryValue:  Card.VALUE):
	var matchedCards : Array[Card]
	for card in otherHand.GetCards():
		if queryValue == card.Value:
			matchedCards.append(card)
	return matchedCards

func TakeCardFromHand(card : Card):
	CardToGain = card
	card.bIsDragging = false
	EventManager.bIsHoldingCard = false
	OnCardBeginUnclicked(card)
	card.TurnOffHighlight()


func ResolveHand(controller : GameController):
	var cardBuckets = {}
	for value in Card.VALUE:
		cardBuckets[value] = []
	for card in GetCards():
		cardBuckets[Card.VALUE.keys()[card.Value]].append(card)

	var index = 0
	for bucket in cardBuckets.keys():
		#print(len(cardBuckets[bucket]))
		if len(cardBuckets[bucket]) == 4:
			controller.SetPrompt("Clearing " + Card.GetValueString(Card.VALUE.values()[index]) + "'s")
			EventManager.ValueCleared.emit(controller.CurrentPlayer, Card.VALUE.values()[index])
			for card in cardBuckets[bucket]:
				card.bIsDying = true
				if bIsPlayerHand:
					await card.MoveToPosition(controller.PlayerReference.GetCoinPlacementPosition(),.3)
				else:
					await card.FlipFacing()
					await card.MoveToPosition(controller.EnemyReference.GetCoinPlacementPosition(),.3)
				card.queue_free()
		index += 1

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
	#await get_tree().create_timer(.05).timeout
	if is_inside_tree() == false:
		return

	var width = 1400
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

