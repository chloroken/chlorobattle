extends Node2D

var direction: Vector2
var speed = 50

# Assign random physics
func _ready() -> void:
	z_as_relative = false
	z_index = get_node("/root/main").layerPawnBehind
	direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	
	var webScale = randf_range(0.1, 1.0)
	$SlowSprite.scale.x = webScale
	$SlowSprite.scale.y = webScale
	
	var webSpeed = randf_range(0.5, 1.0)
	speed *= webSpeed

# Move webs
func _process(delta: float) -> void:
	position += direction * speed * delta;

# Clean up
func _on_fizzle_timer_timeout() -> void:
	queue_free()
