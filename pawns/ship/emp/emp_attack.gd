extends "res://pawns/_base/attack/base_attack.gd"

var duration
var basePawn

func _ready() -> void:
	scale = Vector2.ZERO
	
	# Set visibility order
	z_as_relative = false
	z_index = get_node("/root/main").layerGround
	
	isEmpAttack = true
	attackName = "EMP"
	basePawn = get_parent().get_parent()
	$FizzleTimer.start(duration)

func _process(_delta) -> void:
	var ratio = $FizzleTimer.get_time_left() / duration
	scale = Vector2.ONE * (1 - ratio)
	modulate.a = ratio

func _physics_process(_delta) -> void:
	position = basePawn.position
	
func _on_fizzle_timer_timeout() -> void:
	queue_free()
