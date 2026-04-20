extends "res://pawns/base/base_attack.gd"

var swingDirs = [-1, 1]
var swingDir = swingDirs.pick_random()
var swingDuration
var swingDurMin = 0.75
var swingDurMax = 1.0
var swingSpd
var swingSpdMin = 10.0
var swingSpdMax = 20.0
var scaleMultiplier
var scaleMin = 0.75
var scaleMax = 1.0
var scaleRedwood = 2.0
var redwoodColor = Color(1.0, 0.25, 0.25, 1.0)
var critChance = 10

func _ready() -> void:
	
	# Randomize swing
	scale = Vector2.ZERO
	swingDuration = randf_range(swingDurMin, swingDurMax)
	swingSpd = randf_range(swingSpdMin, swingSpdMax)
	rotation = randf_range(0, TAU)

	# Red wood "crit" mechanic
	if randi_range(1, critChance) != 1:
		scaleMultiplier = randf_range(scaleMin, scaleMax)
	else:
		scaleMultiplier = scaleRedwood
		$BaseSprite.modulate = redwoodColor

	# Set visibility layer
	z_as_relative = false
	z_index = get_node("/root/main").layerPawnFront

	# Set timers
	$FizzleTimer.start(swingDuration)
	get_parent().get_parent().get_node("AttackStutterTimer").start(swingDuration)

# Swing attack
func _physics_process(delta: float) -> void:
	rotation += swingDir * swingSpd * delta
	var scaleAmt = $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	scale.x = scaleMultiplier - scaleAmt * scaleMultiplier
	scale.y = scaleMultiplier - scaleAmt * scaleMultiplier

# Clean up
func _on_fizzle_timer_timeout() -> void:
	self.queue_free()
