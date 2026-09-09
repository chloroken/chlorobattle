extends "res://pawns/_base/attack/base_attack.gd"

var basePawn
var direction
var speed
var startPos
var fizzleRatio = 0.8

func _ready() -> void:
	startPos = position
	areaAttack = false
	basePawn = get_parent().get_parent()
	scale = Vector2.ONE * randf_range(0.75, 1.0)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	var fizzleDistance = basePawn.get_parent().boardRadius * fizzleRatio
	if position.distance_to(startPos) > fizzleDistance:
		queue_free()
