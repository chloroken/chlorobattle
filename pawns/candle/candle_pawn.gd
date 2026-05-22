extends "res://pawns/_base/base_pawn.gd"

@export var emberAttack: PackedScene
var emberCooldownMin = 0.1
var emberCooldownMax = 1.0
var emberScaleMax = 1.0
var emberScaleMin = 0.5
var emberDurationMin = 2.0
var emberDurationMax = 3.0
var emberPositionOffset = 50
var emberThrowDistMod = 1
var emberThrowSpeed = 250
var emberBurnDuration = 5.0
var emberSpreadOffset = 25

func _ready() -> void:
	super()
	if !attacksDisabled:
		start_attack_cooldown()

func start_attack_cooldown() -> void:
	var emberCooldown = asp * aspMod * randf_range(emberCooldownMin, emberCooldownMax)
	$AttackCooldownTimer.start(emberCooldown)

func _on_attack_cooldown_timer_timeout() -> void:
	start_attack_cooldown()
	if disarm_check(): return
	new_ember_attack()

func new_ember_attack() -> void:
	var newAttack = emberAttack.instantiate()
	newAttack.position = position
	newAttack.destination = good_ember_position()
	newAttack.dmg = self.dmg
	newAttack.speed = emberThrowSpeed
	newAttack.emberScale = Vector2.ONE * randf_range(emberScaleMin, emberScaleMax)
	$AttackContainer.add_child(newAttack)

func good_ember_position() -> Vector2:
	var newPos = try_ember_forward(position)
	if newPos.distance_to(center) > board.boardRadius:
		newPos = get_ember_centered(position)
	return(newPos)

func try_ember_forward(origin) -> Vector2:
	var mod = direction * spd * statusSpdMod * emberThrowDistMod
	return(origin + mod + random_vector2())

func get_ember_centered(origin) -> Vector2:
	var newPos = origin + random_vector2()
	while newPos.distance_to(center) > board.boardRadius:
		newPos = origin + random_vector2() 
	return(newPos)

func random_vector2() -> Vector2:
	var offsetX = randf_range(-emberPositionOffset, emberPositionOffset)
	var offsetY = randf_range(-emberPositionOffset, emberPositionOffset)
	return(Vector2(offsetX, offsetY))
