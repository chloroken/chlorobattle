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
	$BaseSprite.modulate.r = 0#randf_range(0.6, 1.0)
	$BaseSprite.modulate.g = randf_range(0.4, 1.0)
	$BaseSprite.modulate.b = randf_range(0.5, 0.8)

	# Set visibility order
	z_as_relative = false
	z_index = get_node("/root/main").layerAir

	# Start timers
	$DisableBounceTimer.one_shot = true
	$FizzleTimer.start(get_parent().get_parent().projectileDuration)

# Move projectile forward
func _physics_process(delta: float) -> void:

	# Bouncing off walls
	var distFromCenter = global_position.distance_to(center)
	var boardRadius = get_parent().get_parent().get_parent().boardRadius

	# Ensure we bounce at the right location
	if distFromCenter > boardRadius:

		# Make sure we don't bounce multiple times rapidly
		if $DisableBounceTimer.is_stopped():
			$DisableBounceTimer.start(disableBounceDuration)

			# Bounce
			direction = position.direction_to(center) + direction

			# Adjust projectile colors 
			var bounceColor = randf_range(0.6, 0.8)
			$BaseSprite.modulate.r = bounceColor
			$BaseSprite.modulate.g = bounceColor
			$BaseSprite.modulate.b = bounceColor
			dmg /= 2

	# Move projectile
	position += direction * speed * delta

# Clean up
func _on_fizzle_timer_timeout() -> void:
	self.queue_free()
