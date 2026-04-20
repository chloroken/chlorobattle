extends Node2D

var direction: Vector2
var speed = 25

# Assign random physics and colors
func _ready() -> void:
	z_as_relative = false
	z_index = get_node("/root/main").layerPawnBehind
	direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	
	var flakeScale = randf_range(0.1, 0.8)
	$SprintSprite.scale.x = flakeScale
	$SprintSprite.scale.y = flakeScale
	
	var flakeSpeed = randf_range(0.5, 1.0)
	speed *= flakeSpeed
	
	#var flakeColor = randf_range(0.5, 1.0)
	#$SkateEffectSprite.modulate.g = flakeColor
	#$SkateEffectSprite.modulate.r = 0.5
	#$SkateEffectSprite.modulate.b = 1.0

# Move snowflakes
func _process(delta: float) -> void:
	position += direction * speed * delta;

# Clean up
func _on_fizzle_timer_timeout() -> void:
	queue_free()
