extends "res://pawns/_base/attack/base_attack.gd"

var parentPawn
var direction
var speed = 0
var baseScale
var discharge = false

func _ready() -> void:
	
	if discharge == true:
		$DischargeDirectionTimer.start()
		#$BaseSprite.modulate.r = randf_range(0.5, 1.0)
		#$BaseSprite.modulate.g = randf_range(0.5, 1.0)
		#$BaseSprite.modulate.b = 1.0
	#else:
	$BaseSprite.modulate.g = randf_range(0.75, 1.0)
	
	# Fetch parent
	parentPawn = get_parent().get_parent()
	
	# Flag as single-target attack
	areaAttack = false
	
	# Set up scaling
	baseScale = randf_range(parentPawn.sparkScaleMin, parentPawn.sparkScaleMax)
	scale = Vector2.ZERO

	# Randomize color

	# Set visibility order
	z_as_relative = false
	z_index = get_node("/root/main").layerGround
	
	# Start timers
	$FizzleTimer.start(randf_range(parentPawn.sparkDuration, parentPawn.sparkDuration * parentPawn.sparkDurVariance))

func _physics_process(delta: float) -> void:

	# Shrink spark over time
	scale.x = max(parentPawn.sparkScaleFloor, baseScale * $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time())
	scale.y = max(parentPawn.sparkScaleFloor, baseScale * $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time())

	#scale = Vector2.ONE * max(parentPawn.sparkScaleFloor, baseScale * (1-$FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()))

	# Move spark
	position += direction * speed * delta

func _on_fizzle_timer_timeout() -> void:
	queue_free()

func _on_discharge_direction_timer_timeout() -> void:
	direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
