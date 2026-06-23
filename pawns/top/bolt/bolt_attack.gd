extends "res://pawns/_base/attack/base_attack.gd"

var basePawn
var direction
var speed

func _ready() -> void:
	areaAttack = false
	basePawn = get_parent().get_parent()
	scale = Vector2.ONE * randf_range(0.75, 1.0)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	if position.distance_to(basePawn.center) > basePawn.get_parent().boardRadius:
		queue_free()
