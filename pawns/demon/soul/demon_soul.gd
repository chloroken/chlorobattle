extends "res://pawns/_base/attacks/base_attack.gd"

@export var soulCharge: Resource

var spd
var direction
var center
var isAssumeSoul = false

func _ready() -> void:
	rotation = randf_range(0, TAU)
	center = basePawn.center
	direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	z_index = get_node("/root/main").layerAir
	$FizzleTimer.start(randf_range(basePawn.soulDurationMin, basePawn.soulDurationMax))
	$DirectionChangeTimer.one_shot = true
	$DirectionChangeTimer.start(randf_range(basePawn.soulDirChangeMin, basePawn.soulDirChangeMax))

func _physics_process(delta: float) -> void:
	position += direction * spd * delta
	if position.distance_to(center) > basePawn.get_parent().boardRadius:
		direction = position.direction_to(center).rotated(randf_range(-1.0, 1.0))
		$DirectionChangeTimer.start(randf_range(basePawn.soulDirChangeMin, basePawn.soulDirChangeMax))

func _on_direction_change_timer_timeout() -> void:
	direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	$DirectionChangeTimer.start(randf_range(basePawn.soulDirChangeMin, basePawn.soulDirChangeMax))

func _on_fizzle_timer_timeout() -> void:
	if isAssumeSoul: return
	queue_free()

func return_to_pawn() -> void:
	var newCharge = soulCharge.instantiate()
	newCharge.position = position
	newCharge.basePawn = basePawn
	newCharge.spd = spd * 2
	add_sibling(newCharge)
	queue_free()

func _on_tree_exiting() -> void:
	basePawn.assumeSoulArray.erase(self)
