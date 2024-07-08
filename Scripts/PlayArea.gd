extends Area2D

var LastCard : Card
var bEnabled = false

func _ready():
	EventManager.CardBeginUnclicked.connect(OnPlayerCardUnClicked)
	EventManager.CardClicked.connect(OnPlayerClicked)
	EventManager.CurrentPlayerTurnStart.connect(OnCurrentPlayerStart)
	_on_area_exited(null)

func OnCurrentPlayerStart(hand : Hand):
	if hand.bIsPlayerHand:
		bEnabled = true
	else:
		bEnabled = false
		_on_area_exited(null)

func OnPlayerClicked(card: Card):
	if bEnabled:
		modulate = Color.GREEN_YELLOW
	else:
		modulate = Color.WHITE
		modulate.a = 0

func OnPlayerCardUnClicked(card: Card):
	print(LastCard)
	modulate.a = 0
	if card == LastCard:
		EventManager.PlayerMove.emit(card.Value)
		print("emit" + str(card.Value))

func _on_area_exited(area):
	LastCard = null
	modulate.a = 0


func _on_area_entered(area):
	if bEnabled:
		if area.get_parent().bIsDragging:
			LastCard = area.get_parent()
			print(LastCard)
			modulate.a = 1
