extends Node

class_name EnemyAI

var RanksToNotAskFor = []
func ClearData():
	RanksToNotAskFor.clear()
	pass

func DoAI(controller : GameController):

	$ThinkTimer.wait_time = randf_range(.5, 1.2)
	$ThinkTimer.start()
	await $ThinkTimer.timeout
	controller.SetPrompt("Opponent is thinking ...")


	$ActionTimer.wait_time = randf_range(.5, 3.5)
	$ActionTimer.start()
	await $ActionTimer.timeout
	var card = controller.EnemyReference.GetRandomCardFromHand()
	card.FlipFacing()

	controller.SetPrompt("Opponent is asking for cards with value: " + Card.GetValueString(Card.VALUE.values()[card.Value]))

	$ShowTimer.start()
	await $ShowTimer.timeout
	card.FlipToBack()
	EventManager.EnemyMove.emit(card.Value)
