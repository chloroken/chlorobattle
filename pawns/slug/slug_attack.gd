extends "res://pawns/base/base_attack.gd"

var baseDmg

func _ready() -> void:

	# Flag as single-target attack
	areaAttack = false
	isSlugAttack = true

	# Prepare for growth visual
	scale.x = 0.0
	scale.y = 0.0

	# Set visibility order
	z_as_relative = false
	z_index = get_node("/root/main").layerGround

	# Set timers
	$FizzleTimer.start(get_parent().get_parent().trailDuration)

func _physics_process(_delta: float) -> void:

	# Scale damage & color based on duration
	var decayRatio = $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	dmg = ceil(baseDmg * decayRatio)
	$DamageLabel.text = str(int(dmg))
	$BaseSprite.modulate.b = 1 - decayRatio

	# Grow size for effect
	var newScale = 0.15 * (1 + decayRatio)
	self.scale = Vector2.ONE * newScale

	# Destroy any trails outside of the board area
	var center = get_viewport_rect().size / 2.0
	var radius = get_parent().get_parent().get_parent().boardRadius
	if global_position.distance_to(center) > radius * 1:
		queue_free()

# Clean up
func _on_fizzle_timer_timeout() -> void:
	self.queue_free()
