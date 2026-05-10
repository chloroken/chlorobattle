extends "res://pawns/_base/attack/base_attack.gd"

var redSwipe = false
var swipeDir

func _ready() -> void:
	isSwipeAttack = true
	$FizzleTimer.start(1.0)
	attackName = "Swipe"
	$BaseSprite.scale.x *= swipeDir
	
	if redSwipe:
		$BaseSprite.modulate = Color.INDIAN_RED

	# Set visibility order
	z_as_relative = false
	z_index = get_node("/root/main").layerAir

func _process(_delta: float) -> void:
	var ratio = $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	var basePawn = get_parent().get_parent()
	var pawnPos = basePawn.position
	var rotDist = Vector2.LEFT * basePawn.catRotateDistance * swipeDir
	position = pawnPos + rotDist.rotated(ratio * TAU)
	$BaseSprite.rotation = ratio * TAU

func _on_fizzle_timer_timeout() -> void:
	queue_free()
