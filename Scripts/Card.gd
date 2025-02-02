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

static func GetValueString(val : VALUE):
	if val == VALUE.ACE:
		return "A"
	if val == VALUE.TWO:
		return "2"
	if val == VALUE.THREE:
		return "3"
	if val == VALUE.FOUR:
		return "4"
	if val == VALUE.FIVE:
		return "5"
	if val == VALUE.SIX:
		return "6"
	if val == VALUE.SEVEN:
		return "7"
	if val == VALUE.EIGHT:
		return "8"
	if val == VALUE.NINE:
		return "9"
	if val == VALUE.TEN:
		return "10"
	if val == VALUE.JACK:
		return "J"
	if val == VALUE.QUEEN:
		return "Q"
	if val == VALUE.KING:
		return "K"

	return str(val) +  "NOT DEFINED"

@export var Value : VALUE
@export var Suit : SUIT

var SuitImages = []
var ValueImages = []
@onready var CardArt = $Content/Art

var bIsDragging = false
var OriginalPosition = Vector2.ZERO
var FollowSpeed = 3000
var OriginalZIndex = -1
var bIsFromDeck = true
var bFlaggedToMove = false
var bIsDying = false
var ContentColor : Color

var HoverTween = null

enum HOVERSTATE {
	UNPLACED,
	UP,
	DOWN
}
var TargetUpPosition = Vector2.ZERO
var TargetDownPosition = Vector2.ZERO

var HoverState = HOVERSTATE.UNPLACED

signal MovedOutOfDeck

func _ready():
	SuitImages.append($Content/Suit1)
	ValueImages.append($Content/Value1)

	UpdateUI()

	if Engine.is_editor_hint() == false:
		name = VALUE.keys()[Value] + "-" + SUIT.keys()[Suit]

func UpdateUI():
	$Content.visible = bShowBack == false
	if bShowBack:
		texture = load("res://Art/CardBack.svg")
	else:
		texture = load("res://Art/CardFront.svg")
		SetSuitImage()
		SetValueImage()


func MoveToPosition(newPos, duration = .05):
	HoverState = HOVERSTATE.DOWN
	TargetDownPosition = newPos
	TargetUpPosition = newPos + Vector2.UP * 60
	if is_instance_valid(HoverTween):
		HoverTween.kill()
		HoverTween = null

	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", newPos, duration)
	tween.set_trans(Tween.TRANS_SPRING)
	OriginalPosition = newPos
	await tween.finished

func FlipFacing():
	if bShowBack:
		$AnimationPlayer.play("FlipUp")
		await $AnimationPlayer.animation_finished

func FlipToBack():
	if bShowBack == false:
		$AnimationPlayer.play_backwards("FlipUp")
		await $AnimationPlayer.animation_finished

func SetSuitImage():
	var suitImage : Texture
	if Suit == SUIT.DIAMONDS:
		suitImage = load("res://Art/Card_Diamond.svg")
		ContentColor = "f98868ff"
	elif Suit == SUIT.HEARTS:
		suitImage = load("res://Art/Card_Heart.svg")
		ContentColor = "f98868ff"
	elif Suit == SUIT.CLUBS:
		suitImage = load("res://Art/Card_Club.svg")
		ContentColor = "5f8d94ff"
	elif Suit == SUIT.SPADES:
		suitImage = load("res://Art/Card_Spade.svg")
		ContentColor = "5f8d94ff"

	for image in SuitImages:
		image.texture = suitImage
		image.modulate = ContentColor
func SetValueImage():
	var valueImage : Texture
	if Value == VALUE.ACE:
		valueImage = load("res://Art/Card_A.svg")
		CardArt.texture = load("res://Art/Card_1_Art.svg")
	elif Value == VALUE.TWO:
		valueImage = load("res://Art/Card_2.svg")
		CardArt.texture = load("res://Art/Card_2_Art.svg")
	elif Value == VALUE.THREE:
		valueImage = load("res://Art/Card_3.svg")
		CardArt.texture = load("res://Art/Card_3_Art.svg")
	elif Value == VALUE.FOUR:
		valueImage = load("res://Art/Card_4.svg")
		CardArt.texture = load("res://Art/Card_4_Art.svg")
	elif Value == VALUE.FIVE:
		valueImage = load("res://Art/Card_5.svg")
		CardArt.texture = load("res://Art/Card_5_Art.svg")
	elif Value == VALUE.SIX:
		valueImage = load("res://Art/Card_6.svg")
		CardArt.texture = load("res://Art/Card_6_Art.svg")
	elif Value == VALUE.SEVEN:
		valueImage = load("res://Art/Card_7.svg")
		CardArt.texture = load("res://Art/Card_7_Art.svg")
	elif Value == VALUE.EIGHT:
		valueImage = load("res://Art/Card_8.svg")
		CardArt.texture = load("res://Art/Card_8_Art.svg")
	elif Value == VALUE.NINE:
		valueImage = load("res://Art/Card_9.svg")
		CardArt.texture = load("res://Art/Card_9_Art.svg")
	elif Value == VALUE.TEN:
		valueImage = load("res://Art/Card_10.svg")
		CardArt.texture = load("res://Art/Card_10_Art.svg")
	elif Value == VALUE.JACK:
		valueImage = load("res://Art/Card_J.svg")
		CardArt.texture = load("res://Art/Card_J_Art.svg")
	elif Value == VALUE.QUEEN:
		valueImage = load("res://Art/Card_Q.svg")
		CardArt.texture = load("res://Art/Card_Q_Art.svg")
	elif Value == VALUE.KING:
		valueImage = load("res://Art/Card_K.svg")
		CardArt.texture = load("res://Art/Card_K_Art.svg")
	for image in ValueImages:
		image.texture = valueImage
		image.modulate = ContentColor

func _process(delta):
	if bIsDragging:
		global_position = get_global_mouse_position()

func SetEnable(bEnable):
	$Button.disabled = !bEnable

func CanBeInteracted():
	return EventManager.CanBeClicked() and $Button.disabled == false and bIsDying == false

func RemoveFromDeck():
	bIsFromDeck = false
	MovedOutOfDeck.emit()

func _on_control_mouse_entered():
	if CanBeInteracted() == false:
		return
	$CardHighlight.visible = true
	$Button.grab_focus()

	if bIsFromDeck:
		return

	if HoverState == HOVERSTATE.UNPLACED:
		return

	if is_instance_valid(HoverTween):
		HoverTween.kill()
		HoverTween = null

	if HoverState == HOVERSTATE.DOWN:
		HoverState = HOVERSTATE.UP

		HoverTween = get_tree().create_tween()
		HoverTween.tween_property(self, "global_position", TargetUpPosition, .1)



func TurnOffHighlight():
	$CardHighlight.visible = false

func _on_control_mouse_exited():
	if CanBeInteracted() == false:
		return

	TurnOffHighlight()

	if HoverState == HOVERSTATE.UNPLACED:
		return

	if bIsFromDeck:
		return


	if is_instance_valid(HoverTween):
		HoverTween.kill()
		HoverTween = null


	if HoverState == HOVERSTATE.UP:
		HoverState = HOVERSTATE.DOWN
		HoverTween = get_tree().create_tween()
		HoverTween.tween_property(self, "global_position", TargetDownPosition, .2)

func SetCardToMoveToHand(hand : Hand):
	_on_button_button_down()
	bFlaggedToMove = true
	_on_button_button_up()

func _on_button_button_down():
	if EventManager.CanBeClicked() == false:
		return


	if is_instance_valid(HoverTween):
		HoverTween.kill()
		HoverTween = null
	OriginalZIndex = z_index
	z_index = 300
	bIsDragging = true
	TurnOffHighlight()
	EventManager.CardClicked.emit(self)

func SetShowBack(bShow : bool):
	bShowBack = bShow
	UpdateUI()

func _on_button_button_up():
	if OriginalZIndex == -1 or bIsDragging == false:
		return

	EventManager.CardBeginUnclicked.emit(self)
	z_index = OriginalZIndex
	OriginalZIndex = -1

	if bFlaggedToMove == false:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "global_position", OriginalPosition, .05).set_trans(Tween.TRANS_QUAD)
		await tween.finished

	bFlaggedToMove = false
	EventManager.CardUnclicked.emit(self)
	bIsDragging = false
