extends Node2D

signal CardClicked(card: Card)
signal CardBeginUnclicked(card: Card)
signal CardUnclicked(card : Card)
signal HoverCardToHand(card: Card)
var bIsHoldingCard = false

var LastCollidedCard = null
var CurrentPlayer : Hand
signal PlayerMove(rank)
signal EnemyMove(rank)

signal CurrentPlayerTurnStart(hand)
signal ValueCleared(player, rank)

func _ready():
	global_position = Vector2.ZERO
	CardClicked.connect(OnCardClicked)
	CardUnclicked.connect(OnCardUnclicked)
	CurrentPlayerTurnStart.connect(OnCurrentPlayerTurnStart)

func OnCurrentPlayerTurnStart(hand : Hand):
	CurrentPlayer = hand


func OnHoveredObject(obj):
	LastCollidedCard = obj

func GetLastCollidedCard():
	return LastCollidedCard

func CanBeClicked():
	return is_instance_valid(CurrentPlayer) and bIsHoldingCard == false

func OnCardClicked(card: Card):
	bIsHoldingCard = true

func OnCardUnclicked(card: Card):
	bIsHoldingCard = false
