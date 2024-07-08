extends Node

class_name EnemyAI

var RanksToNotAskFor = []
func ClearData():
	RanksToNotAskFor.clear()
	pass

func DoAI(controller : GameController):

	$ThinkTimer.start()
	await $ThinkTimer.timeout
	controller.SetPrompt("Opponent is thinking ...")


	$ActionTimer.start()
	await $ActionTimer.timeout
	var card = controller.EnemyReference.GetRandomCardFromHand()
	card.FlipFacing()

	controller.SetPrompt("Opponent is asking for cards with value: " + Card.VALUE.keys()[card.Value])

	$ActionTimer.start()
	await $ActionTimer.timeout
	card.FlipToBack()
	EventManager.EnemyMove.emit(card.Value)
