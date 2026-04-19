extends Node2D

var direction: Vector2
var speed = 25

# Assign random physics and colors
func _ready() -> void:
	z_index = get_node("/root/main").layerPawnBehind
	direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	
	var weakScale = randf_range(1.0, 2.0)
	$WeakSprite.scale.x = weakScale
	$WeakSprite.scale.y = weakScale
	
	var weakSpeed = randf_range(0.5, 1.0)
	speed *= weakSpeed

# Move snowflakes
func _process(delta: float) -> void:
	position += direction * speed * delta;

# Clean up
func _on_fizzle_timer_timeout() -> void:
	queue_free()
