extends "res://pawns/base/base_attack.gd"

var swingDirs = [-1, 1]
var swingDir = swingDirs.pick_random()
var swingDuration
var swingSpd
var scaleMultiplier

# Choose a direction to swing
func _ready() -> void:
	z_index = get_node("/root/main").layerPawnFront
	swingDuration = randf_range(0.75, 1.0)
	swingSpd = randf_range(10.0, 20.0)
	if randi_range(1, 10) != 1:
		scaleMultiplier = randf_range(0.75, 1.0)
	else:
		scaleMultiplier = 2.0
		$BaseSprite.modulate.b = 0.25
		$BaseSprite.modulate.g = 0.25
	
	$FizzleTimer.start(swingDuration)
	get_parent().get_parent().get_node("AttackStutterTimer").start(swingDuration)
	
	
	scale.x = 0.0
	scale.y = 0.0
	rotation = randf_range(0, TAU)

# Swing attack
func _physics_process(delta: float) -> void:
	rotation += swingDir * swingSpd * delta
	var scaleAmt = $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	scale.x = scaleMultiplier - scaleAmt * scaleMultiplier
	scale.y = scaleMultiplier - scaleAmt * scaleMultiplier

# Clean up
func _on_fizzle_timer_timeout() -> void:
	self.queue_free()
