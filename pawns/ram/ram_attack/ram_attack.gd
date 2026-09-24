extends "res://pawns/_base/attack/base_attack.gd"

# make them flash rainbow colors
# make them potentially grow as the charge goes on?
# make them do more damage as charge extends

var dir
var hornScaleDivider = 10
var hornColorInterval = 0.1

func _ready() -> void:
	attackName = "Charge"
	isRamAttack = true
	#$HornRainbowTimer.start(hornColorInterval)
	
	# Set visibility order
	z_as_relative = false
	z_index = get_node("/root/main").layerPawnFront

func _physics_process(_delta: float) -> void:
	var par = get_parent().get_parent()
	position = par.position
	rotation = par.direction.angle()
	scale = Vector2.ONE * max(1.0, sqrt(par.hornChargeSpeedModifier) / hornScaleDivider)

func _on_horn_rainbow_timer_timeout() -> void:
	modulate.r = randf_range(0, 1.0)
	modulate.b = randf_range(0, 1.0)
	modulate.g = randf_range(0, 1.0)
	modulate.lightened(0.5)
