extends Sprite2D


# Called when the node enters the scene tree for the first time.
var Deck = []
func _ready():
	GenerateCards()

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
		card.MoveToPosition(global_position + Vector2.ONE * x * -.9 )
		card.MovedOutOfDeck.connect(OnCardMovedOutOfDeck)
		card.SetEnable(false)
		Deck.append(card)
	Deck[len(Deck) - 1].SetEnable(true)

func OnCardMovedOutOfDeck():
	Deck.pop_back()
	Deck[len(Deck) - 1].SetEnable(true)

func _on_child_order_changed():
	await get_tree().create_timer(.15).timeout
	$Label.text = str(get_child_count() - 1)
	pass # Replace with function body.
