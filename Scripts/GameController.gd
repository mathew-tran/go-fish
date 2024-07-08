extends Node

class_name GameController

var DeckReference : Deck
var PlayerReference : Hand
var EnemyReference : Hand
var PromptReference : PromptArea
var CoinReference : Coin
var CoinTossPanelReference : CoinTossPanel
var EnemyScoreBoard : ScoreBoard
var PlayerScoreBoard : ScoreBoard

var PlayerChoice : CoinTossPanel.CHOICE
var EnemyAIReference : EnemyAI

var MatchedCards : Array[Card]

var GameSpeed = 1.0

var CurrentPlayer : Hand
var OtherPlayer : Hand

func _ready():
	Engine.time_scale = GameSpeed
	DeckReference = get_tree().get_nodes_in_group("Deck")[0]
	PlayerReference = get_tree().get_nodes_in_group("Player")[0]
	EnemyReference = get_tree().get_nodes_in_group("Enemy")[0]
	PromptReference = get_tree().get_nodes_in_group("Prompt")[0]
	CoinReference = get_tree().get_nodes_in_group("Coin")[0]
	CoinTossPanelReference = get_tree().get_nodes_in_group("CoinTossPanel")[0]
	EnemyAIReference = get_tree().get_nodes_in_group("EnemyAI")[0]

	PlayerScoreBoard = get_tree().get_nodes_in_group("PlayerScore")[0]
	EnemyScoreBoard = get_tree().get_nodes_in_group("EnemyScore")[0]

	PlayerScoreBoard.SetPlayer(PlayerReference)
	EnemyScoreBoard.SetPlayer(EnemyReference)

	PromptReference.SetText("Deciding who goes first")
	CoinTossPanelReference.Show()

	CoinTossPanelReference.ChoiceMade.connect(OnChoiceMade)
	await CoinTossPanelReference.ChoiceMade

	await CoinReference.MoveToPosition(PromptReference.GetMarkerPosition())

	CoinReference.OnCoinTossed.connect(OnCoinTossed)
	await CoinReference.Flip()

	SetPrompt(CurrentPlayer.GetFirstPrompt())

	$TellTimer.start()
	await $TellTimer.timeout

	CoinReference.ForceHeads()

	await CoinReference.MoveToPosition(CurrentPlayer.GetCoinPlacementPosition())



	SetPrompt("Shuffling ...")
	await DeckReference.GenerateCards()
	PromptReference.SetText("")
	$StartTimer.start()

func SetPrompt(newText):
	PromptReference.SetText(newText)

func DeterminePlayersTurn():
	await CoinReference.MoveToPosition(CurrentPlayer.GetCoinPlacementPosition())
	EventManager.CurrentPlayerTurnStart.emit(CurrentPlayer)


func OnChoiceMade(choice : CoinTossPanel.CHOICE):
	PlayerChoice = choice

func OnCoinTossed(choice : CoinTossPanel.CHOICE):
	var result = choice == PlayerChoice
	if result:
		CurrentPlayer = PlayerReference
		OtherPlayer = EnemyReference
	else:
		CurrentPlayer = EnemyReference
		OtherPlayer = PlayerReference

func Setup():
	PromptReference.SetText("Dealing Cards ...")
	var amountOfCardsToDraw = 5

	for x in range(0, amountOfCardsToDraw):
		await DeckReference.GiveCard(PlayerReference)
		await DeckReference.GiveCard(EnemyReference)

	EventManager.EnemyMove.connect(OnEnemyMove)
	EventManager.PlayerMove.connect(OnPlayerMove)

	while IsGameOver() == false:
		await CurrentPlayer.ResolveHand(self)
		EnemyAIReference.ClearData()
		var bIsSuccessful = true
		while bIsSuccessful and DeckReference.IsEmpty() == false:
			var bCanPlay = true
			await DeterminePlayersTurn()

			if CurrentPlayer.HasCards() == false:
					SetPrompt(CurrentPlayer.GetOutOfCardPrompt())
					await DeckReference.GiveCard(CurrentPlayer)

			if OtherPlayer.HasCards() == false:
				bCanPlay = false
				SetPrompt(OtherPlayer.GetOutOfCardPrompt())

			if bCanPlay:
				SetPrompt(CurrentPlayer.GetPlayerPrompt())
				if CurrentPlayer.bIsPlayerHand:
					await EventManager.PlayerMove
				else:
					EnemyAIReference.DoAI(self)
					await EventManager.EnemyMove
					$PostMoveTimer.start()
					await $PostMoveTimer.timeout

			if bCanPlay:
				if len(MatchedCards) != 0:
					SetPrompt("Taking Cards...")
					for card in MatchedCards:
						CurrentPlayer.TakeCardFromHand(card)
						$TakeTimer.start()
						await $TakeTimer.timeout
				else:
					bIsSuccessful = false
					SetPrompt(CurrentPlayer.GetUnsuccessfulPrompt())
					$FailTimer.start()
					await $FailTimer.timeout
					SetPrompt("Go fish")
					await DeckReference.GiveCard(CurrentPlayer)
			else:
				bIsSuccessful = false
			await CurrentPlayer.ResolveHand(self)

			$PostRoundTimer.start()
			await $PostRoundTimer.timeout
		RotatePlayer()

	var PlayerScore = PlayerScoreBoard.GetScore()
	var EnemyScore = EnemyScoreBoard.GetScore()

	if PlayerScore == EnemyScore:
		print("TIE")
		SetPrompt("TIE")
	elif PlayerScore > EnemyScore:
		print("YOU WIN")
		SetPrompt("YOU WIN")
	else:
		print("YOU LOSE")
		SetPrompt("YOU LOSE")

	EventManager.GameOver.emit()

func RotatePlayer():
	if CurrentPlayer == PlayerReference:
		CurrentPlayer = EnemyReference
		OtherPlayer = PlayerReference
	else:
		CurrentPlayer = PlayerReference
		OtherPlayer = EnemyReference
func OnEnemyMove(value : Card.VALUE):
	MatchedCards = EnemyReference.QueryOtherHand(PlayerReference, value)

func OnPlayerMove(value : Card.VALUE):
	MatchedCards = PlayerReference.QueryOtherHand(EnemyReference, value)

func IsGameOver():
	return DeckReference.IsEmpty()

func _on_start_timer_timeout():
	Setup()
