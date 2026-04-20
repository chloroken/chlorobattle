extends "res://pawns/base/base_attack.gd"

var parentPawn
var direction: Vector2
var baseDmg
var minDmgRatio = 0.5
var birdSpeed = 75
var birdMaxDist = 100#75
var birdSizeMin = 0.5
var birdSizeMax = 0.75
var birdReturnSpeed = 5
var returning = false

func _ready() -> void:
	z_as_relative = false
	z_index = get_node("/root/main").layerAir
	parentPawn = get_parent().get_parent()
	set_bird_size()

	# Give bird a random direction & color	
	direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	$BaseSprite.modulate.r = randf_range(0.0, 0.8)
	$BaseSprite.modulate.b = randf_range(0.0, 0.8)
	$BaseSprite.modulate.g = randf_range(0.8, 1.0)

func _physics_process(delta: float) -> void:
	# Bird movement logic
	if returning:
		birdSpeed = position.distance_to(parentPawn.position) * birdReturnSpeed
		direction = position.direction_to(parentPawn.position)
	position += direction * birdSpeed * delta;
	$BaseSprite.rotation = direction.angle()

	# Scale bird size & damage based on distance from Pirate
	set_bird_size()
	var birdDist = position.distance_to(parentPawn.position)
	
	var birdDmgRatio = birdDist / birdMaxDist / 2
	var birdDmgMin = baseDmg * minDmgRatio
	dmg = min(baseDmg, max(birdDmgMin, baseDmg * birdDmgRatio))

# Clean up
func _on_fizzle_timer_timeout() -> void:
	self.queue_free()

# Recall bird
func _on_direction_timer_timeout() -> void:
	returning = true

# Scale bird size based on distance, up to a cap
func set_bird_size() -> void:
	var birdScale = birdSizeMax * max(birdSizeMin, position.distance_to(parentPawn.position) / birdMaxDist)
	scale.x = birdScale
	scale.y = birdScale
