extends "res://pawns/base/base_attack.gd"

var direction
var speed = 0

func _ready() -> void:
	areaAttack = false
	var randomScale = randf_range(0.75, 1.0)
	$TopAttackSprite.scale.x = randomScale
	$TopAttackSprite.scale.y = randomScale
	$TopAttackSprite.modulate.r = randf_range(0.8, 1.0)
	$TopAttackSprite.modulate.b = randf_range(0.8, 1.0)
	$TopAttackSprite.modulate.g = randf_range(0.8, 1.0)
	
func _physics_process(delta: float) -> void:
	$TopAttackSprite.scale *= 1.1
	position += direction * speed * delta

func _on_fizzle_timer_timeout() -> void:
	queue_free()
