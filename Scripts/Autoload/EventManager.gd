extends Node2D

signal CardClicked(card: Card)
signal CardBeginUnclicked(card: Card)
signal CardUnclicked(card : Card)
signal HoverCardToHand(card: Card)
var bIsHoldingCard = false

var LastCollidedCard = null

func _ready():
	global_position = Vector2.ZERO
	CardClicked.connect(OnCardClicked)
	CardUnclicked.connect(OnCardUnclicked)


func OnHoveredObject(obj):
	LastCollidedCard = obj

func GetLastCollidedCard():
	return LastCollidedCard

func CanBeClicked():
	return bIsHoldingCard == false

func OnCardClicked(card: Card):
	bIsHoldingCard = true

func OnCardUnclicked(card: Card):
	bIsHoldingCard = false
