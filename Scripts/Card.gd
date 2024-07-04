@tool

extends Sprite2D

class_name Card

@export var bShowBack = false

enum VALUE {
	ACE,
	TWO,
	THREE,
	FOUR,
	FIVE,
	SIX,
	SEVEN,
	EIGHT,
	NINE,
	TEN,
	JACK,
	QUEEN,
	KING
	}

enum SUIT {
	HEARTS,
	DIAMONDS,
	CLUBS,
	SPADES
}

@export var Value : VALUE
@export var Suit : SUIT

var SuitImages = []
var ValueImages = []

var bIsDragging = false
var OriginalPosition = Vector2.ZERO
var FollowSpeed = 2200

func _ready():
	SuitImages.append($Content/Suit1)
	ValueImages.append($Content/Value1)

	UpdateUI()


func UpdateUI():
	$Content.visible = bShowBack == false
	if bShowBack:
		texture = load("res://Art/CardBack.svg")
	else:
		texture = load("res://Art/CardFront.svg")
		SetValueImage()
		SetSuitImage()

func SetSuitImage():
	var suitImage : Texture
	if Suit == SUIT.DIAMONDS:
		suitImage = load("res://Art/Card_Diamond.svg")
	elif Suit == SUIT.HEARTS:
		suitImage = load("res://Art/Card_Heart.svg")
	elif Suit == SUIT.CLUBS:
		suitImage = load("res://Art/Card_Club.svg")
	elif Suit == SUIT.SPADES:
		suitImage = load("res://Art/Card_Spade.svg")

	for image in SuitImages:
		image.texture = suitImage
func SetValueImage():
	var valueImage : Texture
	if Value == VALUE.ACE:
		valueImage = load("res://Art/Card_A.svg")
	elif Value == VALUE.TWO:
		valueImage = load("res://Art/Card_2.svg")
	elif Value == VALUE.THREE:
		valueImage = load("res://Art/Card_3.svg")
	elif Value == VALUE.FOUR:
		valueImage = load("res://Art/Card_4.svg")
	elif Value == VALUE.FIVE:
		valueImage = load("res://Art/Card_5.svg")
	elif Value == VALUE.SIX:
		valueImage = load("res://Art/Card_6.svg")
	elif Value == VALUE.SEVEN:
		valueImage = load("res://Art/Card_7.svg")
	elif Value == VALUE.EIGHT:
		valueImage = load("res://Art/Card_8.svg")
	elif Value == VALUE.NINE:
		valueImage = load("res://Art/Card_9.svg")
	elif Value == VALUE.TEN:
		valueImage = load("res://Art/Card_10.svg")
	elif Value == VALUE.JACK:
		valueImage = load("res://Art/Card_J.svg")
	elif Value == VALUE.QUEEN:
		valueImage = load("res://Art/Card_Q.svg")
	elif Value == VALUE.KING:
		valueImage = load("res://Art/Card_K.svg")
	for image in ValueImages:
		image.texture = valueImage

func _process(delta):
	if bIsDragging:
		var currentPosition = global_position
		var targetPosition = get_global_mouse_position()
		if currentPosition.distance_to(targetPosition) < 10:
			return
		var direction = (targetPosition - currentPosition).normalized()

		global_position = currentPosition + direction * FollowSpeed * delta

func _on_control_mouse_entered():
	$CardHighlight.visible = true

func _on_control_mouse_exited():
	$CardHighlight.visible = false


func _on_button_button_down():
	OriginalPosition = global_position
	bIsDragging = true
	$CardHighlight.visible = false



func _on_button_button_up():
	bIsDragging = false
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", OriginalPosition, .3).set_trans(Tween.TRANS_QUAD)
