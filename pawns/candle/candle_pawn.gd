extends "res://pawns/_base/base_pawn.gd"

@export var emberAttackScene: PackedScene
var emberAttackName = "Ember"
var emberAreaAttack = false
var emberCooldownMin = 0.1
var emberCooldownMax = 1.0
var emberDurationMin = 3.0
var emberDurationMax = 5.0
var emberThrowOffsetDistance = 50
var emberThrowDistMultiplier = 1.0
var emberThrowSpeed = 250

var infernoAttackName = "Inferno"
var infernoAreaAttack = true
var infernoActivationChance = 10
var infernoDamageMultiplier = 2.0
var infernoDisarmDuration = 3.0
var infernoArsonMultiplier = 10.0

var arsonSpreadOffsetDistance = 25
var arsonReplicateChance = 20
var arsonDuplicateChance = 10
var arsonTriplicateChance = 5

func _ready() -> void:
	super()
	if !inLobby:
		new_attack_cycle(emberCooldownMin, emberCooldownMax)
func _on_attack_cooldown_timer_timeout() -> void:
	new_attack_cycle(emberCooldownMin, emberCooldownMax)
	if disarm_check(): return
	new_ember_attack(self.position)
func new_ember_attack(origin) -> Variant:
	var newEmber = emberAttackScene.instantiate()
	newEmber.speed = emberThrowSpeed
	newEmber.position = origin
	newEmber.destination = calculate_ember_destination(origin)
	determine_if_inferno(newEmber)
	$AttackContainer.add_child(newEmber)
	return(newEmber)

# Ember
func calculate_ember_destination(origin) -> Vector2:
	if origin != self.position:
		return(good_arson_position(origin))
	else:
		return(good_ember_position(origin))
func good_ember_position(origin) -> Vector2:
	var newPos = try_ember_forward(origin)
	if newPos.distance_to(center) > board.boardRadius:
		newPos = good_ember_centered(origin)
	return(newPos)
func try_ember_forward(origin) -> Vector2:
	var mod = direction * spd * statusSpdMod * emberThrowDistMultiplier
	return(origin + mod + ember_offset())
func good_ember_centered(origin) -> Vector2:
	var newPos = origin + ember_offset()
	while newPos.distance_to(center) > board.boardRadius:
		newPos = origin + ember_offset() 
	return(newPos)
func ember_offset() -> Vector2:
	var offsetX = randf_range(-emberThrowOffsetDistance, emberThrowOffsetDistance)
	var offsetY = randf_range(-emberThrowOffsetDistance, emberThrowOffsetDistance)
	return(Vector2(offsetX, offsetY))

# Inferno
func determine_if_inferno(ember) -> void:
	try_inferno_ember(ember)
	if ember.isInfernoAttack:
		ember.attackName = infernoAttackName
		ember.areaAttack = infernoAreaAttack
		ember.dmg = self.dmg * infernoDamageMultiplier
	else:
		ember.attackName = emberAttackName
		ember.areaAttack = emberAreaAttack
		ember.dmg = self.dmg
func try_inferno_ember(ember) -> bool:
	var infernoRoll = randi_range(1, 100)
	if infernoRoll <= infernoActivationChance:
		ember.isInfernoAttack = true
	return(!ember.isInfernoAttack)

# Arson
func good_arson_position(origin) -> Vector2:
	var newPos = try_arson_position(origin)
	while newPos.distance_to(center) > board.boardRadius:
		newPos = try_arson_position(origin)
	return(newPos)
func try_arson_position(origin) -> Vector2:
	var offset = arsonSpreadOffsetDistance
	var offsetX = randf_range(-offset, offset)
	var offsetY = randf_range(-offset, offset)
	return(origin + Vector2(offsetX, offsetY))
