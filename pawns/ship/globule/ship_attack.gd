extends "res://pawns/_base/attack/base_attack.gd"

# Physics variables
var speed
var direction: Vector2

# Bounce variables
var boardSize
var disableBounceDuration = 0.1

func _ready() -> void:
	scale *= Vector2.ONE * randf_range(0.5, 1.0)

	# Flag as single-target attack
	areaAttack = false

	# Adjust projectile colors 
	$BaseSprite.modulate.r = 0
	$BaseSprite.modulate.g = randf_range(0.4, 0.6)
	$BaseSprite.modulate.b = randf_range(0.5, 0.8)

	# Set visibility order
	z_as_relative = false
	z_index = get_node("/root/main").layerAir

	# Start timers
	var maxDuration = get_parent().get_parent().projectileDuration
	var minDuration = maxDuration / 2
	$FizzleTimer.start(randf_range(minDuration, maxDuration))

func _process(_delta: float) -> void:
	if $FizzleTimer.get_time_left() < 0.25:
		$BaseSprite.modulate.a = $FizzleTimer.get_time_left() * 4

# Move projectile forward
func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	
	if position.distance_to(get_parent().get_parent().get_parent().center) > get_parent().get_parent().get_parent().boardRadius:
		if $BounceCooldownTimer.is_stopped():
			$BounceCooldownTimer.start()
			globule_bounce()
			direction = position.direction_to(get_parent().get_parent().get_parent().center).rotated(randf_range(-1.0, 1.0))

# Clean up
func _on_fizzle_timer_timeout() -> void:
	self.queue_free()

# Bounce
func _on_area_exited(area: Area2D) -> void:
	if area.get_collision_layer_value(6):#areaType == "board":
		globule_bounce()
		direction = position.direction_to(get_parent().get_parent().get_parent().center) + direction

func globule_bounce() -> void:
	var bounceColor = randf_range(0.6, 0.8)
	$BaseSprite.modulate.r = bounceColor
	$BaseSprite.modulate.g = bounceColor
	$BaseSprite.modulate.b = bounceColor
	dmg /= 2
