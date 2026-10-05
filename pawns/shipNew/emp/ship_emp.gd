extends "res://pawns/_base/base_attack.gd"

var duration

func _ready() -> void:
	super()
	scale = Vector2.ZERO
	
	# Set visibility order
	
	z_index = get_node("/root/main").layerGround
	
	isEmpAttack = true
	attackName = "EMP"
	$FizzleTimer.start(duration)

func _process(_delta) -> void:
	var ratio = $FizzleTimer.get_time_left() / duration
	scale = Vector2.ONE * (1 - ratio)
	modulate.a = ratio

func _physics_process(_delta) -> void:
	position = basePawn.position
	
func _on_fizzle_timer_timeout() -> void:
	queue_free()
