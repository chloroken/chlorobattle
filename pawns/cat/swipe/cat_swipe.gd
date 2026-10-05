extends "res://pawns/_base/base_attack.gd"

var redSwipe = false
var swipeDir
var extraPaw = false

func _ready() -> void:
	super()

	$FizzleTimer.start(basePawn.swipeDuration)
	z_index = get_node("/root/main").layerAir
	$BaseSprite.scale.x *= swipeDir

func _process(_delta: float) -> void:
	swipe_physics()
	if redSwipe:
		$BaseSprite.modulate = Color.INDIAN_RED

func swipe_physics() -> void:
	var swipeDistance = calculate_swipe_distance()
	var swipeTimer = $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	position = basePawn.position + swipeDistance.rotated(swipeTimer * TAU)
	$BaseSprite.rotation = swipeTimer * TAU

func calculate_swipe_distance() -> Vector2:
	var rotDist = Vector2.ZERO
	var rotateBase = basePawn.swipeRotateDistance * swipeDir
	if extraPaw:
		rotDist = Vector2.UP * rotateBase
	else:
		rotDist = Vector2.LEFT * rotateBase
	return(rotDist)

func _on_fizzle_timer_timeout() -> void:
	queue_free()
