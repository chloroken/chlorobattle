extends Node2D

var direction: Vector2
var speed = 50

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	var flakeScale = randf_range(0.1, 1.0)
	$SkateEffectSprite.scale.x = flakeScale
	$SkateEffectSprite.scale.y = flakeScale
	var flakeSpeed = randf_range(0.5, 1.0)
	speed *= flakeSpeed
	
	var flakeColor = randf_range(0.5, 1.0)
	$SkateEffectSprite.modulate.g = flakeColor
	
	$SkateEffectSprite.modulate.r = 0.5
	$SkateEffectSprite.modulate.b = 1.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += direction * speed * delta;

func _on_fizzle_timer_timeout() -> void:
	queue_free()
