extends Area2D

var LastCard : Card
func _ready():
	EventManager.CardUnclicked.connect(OnPlayerCardUnClicked)

func OnPlayerCardUnClicked(card: Card):
	if card == LastCard:
		EventManager.PlayerMove.emit(card.Value)

func _on_area_exited(area):
	LastCard = null


func _on_area_entered(area):
	LastCard = area.get_parent()
