extends "res://pawns/base/base_attack.gd"

var parentPawn
var direction: Vector2
var baseDmg
var birdSpeed
var returning = false

func _ready() -> void:
	
	# Grab Pawn
	parentPawn = get_parent().get_parent()

	# Set bird physics
	set_bird_size()
	direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	$BaseSprite.modulate.r = randf_range(0.0, 0.8)
	$BaseSprite.modulate.b = randf_range(0.0, 0.8)
	$BaseSprite.modulate.g = randf_range(0.8, 1.0)
	
	# Set visibility order
	z_as_relative = false
	z_index = get_node("/root/main").layerAir

func _physics_process(delta: float) -> void:

	# Bird movement logic
	if returning:
		birdSpeed = position.distance_to(parentPawn.position) * parentPawn.birdReturnSpeed
		direction = position.direction_to(parentPawn.position)
	position += direction * parentPawn.birdSpeed * delta
	$BaseSprite.rotation = direction.angle()

	# Scale bird size based on distance
	set_bird_size()
	var birdDist = position.distance_to(parentPawn.position)

	# Set bird damage based on distance
	var birdDmgRatio = birdDist / parentPawn.birdMaxDist / 2
	var birdDmgMin = baseDmg * parentPawn.minDmgRatio
	dmg = min(baseDmg, max(birdDmgMin, baseDmg * birdDmgRatio))

# Clean up
func _on_fizzle_timer_timeout() -> void:
	self.queue_free()

# Recall bird
func _on_direction_timer_timeout() -> void:
	returning = true

# Scale bird size based on distance, up to a cap
func set_bird_size() -> void:
	var birdScale = parentPawn.birdSizeMax * max(parentPawn.birdSizeMin, position.distance_to(parentPawn.position) / parentPawn.birdMaxDist)
	scale.x = birdScale
	scale.y = birdScale
