extends "res://pawns/_base/base_attack.gd"

var direction
var speed
var startPos
var fizzleRatio = 0.8

func _ready() -> void:
	super()
	startPos = position
	areaAttack = false
	scale = Vector2.ONE * randf_range(0.75, 1.0)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	var fizzleDistance = basePawn.get_parent().boardRadius * fizzleRatio
	if position.distance_to(startPos) > fizzleDistance:
		queue_free()
