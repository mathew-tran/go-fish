extends Node

class_name GameController

var DeckReference : Deck
var PlayerReference : Hand
var EnemyReference : Hand
var PromptReference : PromptArea
var CoinReference : Coin
var CoinTossPanelReference : CoinTossPanel

var PlayerChoice : CoinTossPanel.CHOICE
var EnemyAIReference : EnemyAI

var bIsPlayerFirst = false

var MatchedCards : Array[Card]

func _ready():
	DeckReference = get_tree().get_nodes_in_group("Deck")[0]
	PlayerReference = get_tree().get_nodes_in_group("Player")[0]
	EnemyReference = get_tree().get_nodes_in_group("Enemy")[0]
	PromptReference = get_tree().get_nodes_in_group("Prompt")[0]
	CoinReference = get_tree().get_nodes_in_group("Coin")[0]
	CoinTossPanelReference = get_tree().get_nodes_in_group("CoinTossPanel")[0]
	EnemyAIReference = get_tree().get_nodes_in_group("EnemyAI")[0]

	PromptReference.SetText("Deciding who goes first")
	CoinTossPanelReference.Show()

	CoinTossPanelReference.ChoiceMade.connect(OnChoiceMade)
	await CoinTossPanelReference.ChoiceMade

	await CoinReference.MoveToPosition(PromptReference.GetMarkerPosition())

	CoinReference.OnCoinTossed.connect(OnCoinTossed)
	await CoinReference.Flip()

	bIsPlayerFirst = false
	if bIsPlayerFirst:
		SetPrompt("You go first!")
	else:
		SetPrompt("Opponent goes first")

	$TellTimer.start()
	await $TellTimer.timeout

	CoinReference.ForceHeads()

	if bIsPlayerFirst == false:
		await CoinReference.MoveToPosition(EnemyReference.GetCoinPlacementPosition())
	else:
		await CoinReference.MoveToPosition(PlayerReference.GetCoinPlacementPosition())



	SetPrompt("Shuffling ...")
	await DeckReference.GenerateCards()
	PromptReference.SetText("")
	$StartTimer.start()

func SetPrompt(newText):
	PromptReference.SetText(newText)

func DeterminePlayersTurn():
	if bIsPlayerFirst:
		SetPrompt("Your turn, drag a card here")
	else:
		SetPrompt("Waiting for opponent...")

	if bIsPlayerFirst == false:
		CoinReference.MoveToPosition(EnemyReference.GetCoinPlacementPosition())
	else:
		CoinReference.MoveToPosition(PlayerReference.GetCoinPlacementPosition())

func OnChoiceMade(choice : CoinTossPanel.CHOICE):
	PlayerChoice = choice

func OnCoinTossed(choice : CoinTossPanel.CHOICE):
	bIsPlayerFirst = choice == PlayerChoice

func Setup():
	PromptReference.SetText("Dealing Cards ...")
	var amountOfCardsToDraw = 5

	for x in range(0, amountOfCardsToDraw):
		await DeckReference.GiveCard(PlayerReference)
		await DeckReference.GiveCard(EnemyReference)

	EventManager.EnemyMove.connect(OnEnemyMove)
	EventManager.PlayerMove.connect(OnPlayerMove)

	while IsGameOver() == false:
		DeterminePlayersTurn()
		EnemyAIReference.ClearData()
		var bIsSuccessful = true
		while bIsSuccessful:
			if bIsPlayerFirst:
				if EnemyReference.HasCards() == false:
					bIsSuccessful = false
					break
				if PlayerReference.HasCards() == false:
					await DeckReference.GiveCard(PlayerReference)
				await EventManager.PlayerMove
			else:
				if PlayerReference.HasCards() == false:
					bIsSuccessful = false
					break
				if EnemyReference.HasCards() == false:
					await DeckReference.GiveCard(EnemyReference)
				EnemyAIReference.DoAI(self)
				await EventManager.EnemyMove
				$PostMoveTimer.start()
				await $PostMoveTimer.timeout

			if len(MatchedCards) != 0:
				SetPrompt("Taking Cards...")
				for card in MatchedCards:
					if bIsPlayerFirst:
						PlayerReference.TakeCardFromHand(card)
					else:
						EnemyReference.TakeCardFromHand(card)
					$TakeTimer.start()
					await $TakeTimer.timeout
			else:
				bIsSuccessful = false
				SetPrompt("No cards were found ...")
				$FailTimer.start()
				await $FailTimer.timeout
				if bIsPlayerFirst:
					await DeckReference.GiveCard(PlayerReference)
				else:
					await DeckReference.GiveCard(EnemyReference)

			if bIsPlayerFirst:
				await PlayerReference.ResolveHand(self)
			else:
				await EnemyReference.ResolveHand(self)
		bIsPlayerFirst = !bIsPlayerFirst

func OnEnemyMove(value : Card.VALUE):
	MatchedCards = EnemyReference.QueryOtherHand(PlayerReference, value)

func OnPlayerMove(value : Card.VALUE):
	MatchedCards = PlayerReference.QueryOtherHand(EnemyReference, value)
	SetPrompt("You asked for cards with a value of:" + Card.VALUE.keys()[value])

func IsGameOver():
	return false

func _on_start_timer_timeout():
	Setup()
