extends Panel

class_name ScoreBoard

var OwningPlayer : Hand

@onready var OwnedSet = preload("res://Prefab/OwnedSet.tscn")

func SetPlayer(hand : Hand):
	OwningPlayer = hand

func _ready():
	EventManager.ValueCleared.connect(OnValueCleared)
	for child in $HBoxContainer.get_children():
		child.queue_free()

func OnValueCleared(player : Hand, rank : Card.VALUE):
	if player.bIsPlayerHand == OwningPlayer.bIsPlayerHand:
		var instance = OwnedSet.instantiate()
		instance.text = Card.GetValueString(rank)
		$HBoxContainer.add_child(instance)

func GetScore():
	return $HBoxContainer.get_child_count()
