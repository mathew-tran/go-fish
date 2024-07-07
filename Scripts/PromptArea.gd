extends Panel

class_name PromptArea

func SetText(newText : String):
	$Label.text = newText

func GetMarkerPosition():
	return $Marker2D.global_position
