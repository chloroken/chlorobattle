extends "res://pawns/_base/_attack/base_attack.gd"

@export var soulCharge: Resource

var basePawn
var spd
var direction
var center

func _ready() -> void:
	rotation = randf_range(0, TAU)
	basePawn = get_parent().get_parent()
	center = basePawn.center
	direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	attackName = "Soul"
	areaAttack = false
	isSoulAttack = true
	
	# Set visibility order
	z_as_relative = false
	z_index = get_node("/root/main").layerAir
	
	$FizzleTimer.start(randf_range(basePawn.soulDurationMin, basePawn.soulDurationMax))
	$DirectionChangeTimer.one_shot = true
	$DirectionChangeTimer.start(randf_range(basePawn.soulDirChangeMin, basePawn.soulDirChangeMax))

func _physics_process(delta: float) -> void:
	position += direction * spd * delta
	if position.distance_to(center) > get_parent().get_parent().get_parent().boardRadius:
		direction = position.direction_to(center).rotated(randf_range(-1.0, 1.0))
		$DirectionChangeTimer.start(randf_range(basePawn.soulDirChangeMin, basePawn.soulDirChangeMax))

func _on_direction_change_timer_timeout() -> void:
	direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	$DirectionChangeTimer.start(randf_range(basePawn.soulDirChangeMin, basePawn.soulDirChangeMax))

func _on_fizzle_timer_timeout() -> void:
	queue_free()

func return_to_pawn() -> void:
	var newCharge = soulCharge.instantiate()
	newCharge.position = position
	newCharge.pawn = basePawn
	newCharge.spd = spd * 2
	add_sibling(newCharge)
	queue_free()
