extends Panel

func _ready():
	EventManager.OptionButtonPressed.connect(OnOptionButtonPressed)

func OnOptionButtonPressed():
	visible = !visible

func _on_resume_button_up():
	visible = false

func _on_restart_button_up():
	get_tree().reload_current_scene()


func _on_visibility_changed():
	if is_inside_tree():
		get_tree().paused = visible
