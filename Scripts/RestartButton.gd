extends Button


func _ready():
	EventManager.GameOver.connect(OnGameOver)

func OnGameOver():
	visible = true


func _on_button_up():
	get_tree().paused = false
	get_tree().reload_current_scene()

