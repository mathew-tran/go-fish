extends Node

var DeckReference : Deck
var PlayerReference : Hand
var EnemyReference : Hand
var PromptReference : PromptArea
var CoinReference : Coin
var CoinTossPanelReference : CoinTossPanel

var PlayerChoice : CoinTossPanel.CHOICE

var bIsPlayerFirst = false

func _ready():
	DeckReference = get_tree().get_nodes_in_group("Deck")[0]
	PlayerReference = get_tree().get_nodes_in_group("Player")[0]
	EnemyReference = get_tree().get_nodes_in_group("Enemy")[0]
	PromptReference = get_tree().get_nodes_in_group("Prompt")[0]
	CoinReference = get_tree().get_nodes_in_group("Coin")[0]
	CoinTossPanelReference = get_tree().get_nodes_in_group("CoinTossPanel")[0]

	PromptReference.SetText("Deciding who goes first")
	CoinTossPanelReference.Show()

	CoinTossPanelReference.ChoiceMade.connect(OnChoiceMade)
	await CoinTossPanelReference.ChoiceMade

	await CoinReference.MoveToPosition(PromptReference.GetMarkerPosition())

	CoinReference.OnCoinTossed.connect(OnCoinTossed)
	await CoinReference.Flip()

	if bIsPlayerFirst:
		PromptReference.SetText("You go first!")
	else:
		PromptReference.SetText("Opponent goes first")

	$TellTimer.start()
	await $TellTimer.timeout

	await CoinReference.MoveToPosition(Vector2(-1000, -1000))



	PromptReference.SetText("Shuffling ...")
	await DeckReference.GenerateCards()
	$StartTimer.start()

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



func _on_start_timer_timeout():
	Setup()
