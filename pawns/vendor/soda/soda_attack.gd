extends "res://pawns/_base/attacks/base_attack.gd"

var duration
var speed
var direction

var spinSpeed = 5.0
var dirs = [-1, 1]
var dir = dirs.pick_random()

func _ready() -> void:
	super()
	modulate.r = randf_range(0.5, 1.0)
	modulate.b = randf_range(0.5, 1.0)
	modulate.g = randf_range(0.5, 1.0)
	z_index = get_node("/root/main").layerAir

func _physics_process(delta: float) -> void:
	rotation += dir * spinSpeed * delta
	position += direction * speed * delta

	var boardRadius = basePawn.board.boardRadius
	var boardCenter = basePawn.center
	var distToCenter = position.distance_to(boardCenter)
	if distToCenter > boardRadius:
		queue_free()
