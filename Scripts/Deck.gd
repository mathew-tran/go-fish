extends Sprite2D

class_name Deck

# Called when the node enters the scene tree for the first time.
var DeckOfCards : Array[Card]

func GenerateCards():
	var data = []
	for x in Card.VALUE:
		for y in Card.SUIT:
			data.append({
				"Value" : x,
				"Suit" : y
			})
	data.shuffle()

	for x in range(0, len(data)):
		var card = load("res://Prefab/Card.tscn").instantiate() as Card
		var currentData = data[x]
		card.Suit = Card.SUIT[currentData["Suit"]]
		card.Value = Card.VALUE[currentData["Value"]]
		card.bShowBack = true

		add_child(card)
		card.global_position = Vector2(1920, 500 + randi_range(-200, 200))
		await card.MoveToPosition(global_position + Vector2.ONE * x * -.9, .02 )
		card.MovedOutOfDeck.connect(OnCardMovedOutOfDeck)
		card.SetEnable(false)
		DeckOfCards.append(card)

func GiveCard(hand : Hand):
	var card = DeckOfCards[len(DeckOfCards) - 1]
	await card.MoveToPosition(hand.GetHandGainPosition(), .2)
	hand.GainCard(card)
	card.bFlaggedToMove = false


func OnCardMovedOutOfDeck():
	DeckOfCards.pop_back()

func _on_child_order_changed():
	await get_tree().create_timer(.15).timeout
	$Label.text = str(get_child_count() - 1)
	pass # Replace with function body.
