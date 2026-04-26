extends "res://pawns/base/base_attack.gd"

# Physics variables
var speed
var direction: Vector2

# Bounce variables
var center
var boardSize
var disableBounceDuration = 0.1

func _ready() -> void:

	# Flag as single-target attack
	areaAttack = false

	# Fetch center of board
	center = get_viewport_rect().size / 2.0

	# Adjust projectile colors 
	$BaseSprite.modulate.r = 0
	$BaseSprite.modulate.g = randf_range(0.4, 1.0)
	$BaseSprite.modulate.b = randf_range(0.5, 0.8)

	# Set visibility order
	z_as_relative = false
	z_index = get_node("/root/main").layerPawnBehind

	# Start timers
	$FizzleTimer.start(get_parent().get_parent().projectileDuration)

# Move projectile forward
func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	
	if position.distance_to(center) > get_parent().get_parent().get_parent().boardRadius:
		if $BounceCooldownTimer.is_stopped():
			$BounceCooldownTimer.start()
			globule_bounce()
			direction = position.direction_to(center).rotated(randf_range(-1.0, 1.0))

# Clean up
func _on_fizzle_timer_timeout() -> void:
	self.queue_free()

# Bounce
func _on_area_exited(area: Area2D) -> void:
	if area.areaType == "board":
		globule_bounce()
		direction = position.direction_to(center) + direction

func globule_bounce() -> void:
	var bounceColor = randf_range(0.6, 0.8)
	$BaseSprite.modulate.r = bounceColor
	$BaseSprite.modulate.g = bounceColor
	$BaseSprite.modulate.b = bounceColor
	dmg /= 2
