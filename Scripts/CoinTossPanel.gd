extends Panel

class_name CoinTossPanel

enum CHOICE {
	HEADS,
	TAILS
}
signal ChoiceMade()

func Show():
	visible = true


func _on_button_button_up():
	ChoiceMade.emit(CHOICE.HEADS)
	visible = false
	get_tree().paused = false


func _on_button_2_button_up():
	ChoiceMade.emit(CHOICE.TAILS)
	visible = false
	get_tree().paused = false

