extends "res://pawns/base/base_attack.gd"

var startingPos
var speed = 25
var random_direction: Vector2
var direction: Vector2
var fizzleTime = 3.0

var center
var boardSize
var disableBounceDuration = 0.1

func _ready() -> void:
	center = get_viewport_rect().size / 2.0
	startingPos = position

	areaAttack = false

	speed *= randf_range(0.75, 1.25)
	scale *= randf_range(0.5, 1.0)

	# Adjust projectile speed by Ship speed
	speed += get_parent().get_parent().spd

	# Adjust projectile colors 
	$BaseSprite.modulate.r = 1
	$BaseSprite.modulate.b = randf_range(0.1, 0.5)
	$BaseSprite.modulate.g = randf_range(0.1, 0.5)

	# Set visibility order
	z_as_relative = false
	z_index = get_node("/root/main").layerAir

	# Start timers
	$FizzleTimer.start(fizzleTime)

# Move projectile forward
func _physics_process(delta: float) -> void:

	# Bouncing off walls
	var distFromCenter = global_position.distance_to(center)
	var boardRadius = get_parent().get_parent().get_parent().boardRadius
	if $DisableBounceTimer.is_stopped():

		# Ensure we bounce at the right location
		if distFromCenter > boardRadius:
			direction = position.direction_to(center) + 0.5 * position.direction_to(position + direction)

			# Make sure we don't bounce multiple times rapidly
			$DisableBounceTimer.start(disableBounceDuration)

	# Move projectile
	position += direction * speed * delta

# Clean up
func _on_fizzle_timer_timeout() -> void:
	self.queue_free()
