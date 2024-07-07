extends Sprite2D

class_name Coin

var bIsHeads = true


signal OnCoinTossed (value : CoinTossPanel.CHOICE)

func MoveToPosition(newPosition):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", newPosition, .5)
	await tween.finished

func Flip():
	var flipTimes = 10 + randi() % 10
	$AnimationPlayer.speed_scale = 3
	while flipTimes > 0:
		$AnimationPlayer.speed_scale += .5
		if bIsHeads:
			$AnimationPlayer.play("FlipHead")
		else:
			$AnimationPlayer.play("FlipTails")

		await $AnimationPlayer.animation_finished
		bIsHeads = !bIsHeads
		flipTimes -= 1

	if bIsHeads:
		OnCoinTossed.emit(CoinTossPanel.CHOICE.HEADS)
	else:
		OnCoinTossed.emit(CoinTossPanel.CHOICE.TAILS)

func ForceHeads():
	if bIsHeads == false:
		$AnimationPlayer.play("FlipTails")
		bIsHeads = false

