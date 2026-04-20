extends "res://pawns/base/base_attack.gd"

var speed = 75
var direction: Vector2
var attackDuration = 1.0

func _ready() -> void:
	
	# Assign a random direction
	direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	
	# Flag as a single-target attack
	areaAttack = true
	
	# Set visibility ordering
	z_as_relative = false
	z_index = get_node("/root/main").layerAir
	
	# Start timers
	$FizzleTimer.start(attackDuration)

# Move bullet forward
func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta;

# Clean up
func _on_fizzle_timer_timeout() -> void:
	self.queue_free()
