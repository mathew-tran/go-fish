extends Node2D

signal CardClicked(card: Card)
signal CardUnclicked(card : Card)

var bIsHoldingCard = false

var PlayerRaycast : RayCast2D
var CastCollider = null
func _ready():
	global_position = Vector2.ZERO
	CardClicked.connect(OnCardClicked)
	CardUnclicked.connect(OnCardUnclicked)
	PlayerRaycast = RayCast2D.new()
	PlayerRaycast.collide_with_areas = true
	PlayerRaycast.set_collision_mask_value(2, true)
	PlayerRaycast.set_collision_mask_value(1, false)
	PlayerRaycast.enabled = true
	PlayerRaycast.exclude_parent = true

	add_child(PlayerRaycast)


func _physics_process(delta):
	var localPosition = get_global_mouse_position()
	#PlayerRaycast.global_position = localPosition
	PlayerRaycast.target_position = localPosition
	PlayerRaycast.force_raycast_update()
	if PlayerRaycast.is_colliding():
		var newCollider = PlayerRaycast.get_collider().get_parent()
		CastCollider = newCollider
		print(CastCollider.name)
	else:
		CastCollider = null


func GetLastCollidedCard():
	return CastCollider

func CanBeClicked():
	return bIsHoldingCard == false

func OnCardClicked(card: Card):
	bIsHoldingCard = true

func OnCardUnclicked(card: Card):
	bIsHoldingCard = false
