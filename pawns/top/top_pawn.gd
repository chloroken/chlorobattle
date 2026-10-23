extends "res://pawns/_base/base_pawn.gd"

@export var sparkAttackScene: PackedScene
var sparkOffset = 15
var sparkSpeedRatio = 5
var sparkCooldown = 0.25
var sparkScaleMin = 0.9
var sparkScaleMax = 1.0
var sparkScaleFloor = 0.25
var sparkDuration = 2.5
var sparkDurVariance = 0.5

@export var boltAttack: PackedScene
var boltCountMin = 3
var boltCountMax = 5 #7
var boltArc = 0.75
var boltSpeedMin = 200
var boltSpeedMax = 300
var boltCooldown = 1.0

var topBounceDuration = 3.0
var sprintAtkSpdMultiplier = 0.5

func _ready() -> void:
	super()
	if not inLobby:
		$BoltCooldown.one_shot = true
		start_attack_cooldown()
func start_attack_cooldown() -> void:
	var atkSpdMod = 1.0
	var isSprinting = $Status.get_node("SprintStatusTimer")
	if !isSprinting.is_stopped():
		atkSpdMod = sprintAtkSpdMultiplier
	var sparkCd = asp * aspMod * sparkCooldown * atkSpdMod
	$AttackCooldownTimer.start(sparkCd)
func _on_attack_cooldown_timer_timeout() -> void:
	start_attack_cooldown()
	if disarm_check(): return
	if not check_for_stuck():
		new_spark_attack()
func check_for_stuck() -> bool:
	var stuckSource = $Status.stuckPawnSource
	if !$Status.get_node("StuckStatusTimer").is_stopped() && stuckSource != self:
		$AttackCooldownTimer.start(asp * aspMod * sparkCooldown)
		return(true)
	return(false)
func new_spark_attack() -> void:
	var newAttack = sparkAttackScene.instantiate()
	newAttack.position = self.position + Vector2(0, sparkOffset)
	newAttack.dmg = self.dmg
	newAttack.attackName = "Spark"
	newAttack.direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	newAttack.rotation = randf_range(0, TAU)
	newAttack.speed += spd / sparkSpeedRatio
	$AttackContainer.add_child(newAttack)
func stay_in_bounds() -> void:
	if position.distance_to(center) > get_parent().boardRadius:
		direction = new_direction()
		if !inLobby:
			top_hit_wall()
func _on_area_exited(area: Area2D) -> void:
	if self.is_queued_for_deletion(): return
	if area.get_collision_layer_value(6):
		direction = new_direction()
		if !inLobby:
			top_hit_wall()
func top_hit_wall() -> void:
	if self.is_queued_for_deletion(): return
	$Status.start_sprint(topBounceDuration)
	if $BoltCooldown.is_stopped():
		new_bolt_attack()
func new_bolt_attack() -> void:
	var boltCount = randi_range(boltCountMin, boltCountMax)
	for i in boltCount:
		var newAttack = boltAttack.instantiate()
		newAttack.position = self.position
		newAttack.dmg = self.dmg
		newAttack.attackName = "Bolt"
		newAttack.speed = randf_range(boltSpeedMin, boltSpeedMax)
		newAttack.direction = position.direction_to(center).rotated(randf_range(-boltArc, boltArc))
		newAttack.rotation = newAttack.direction.angle()
		$AttackContainer.add_child(newAttack)
	$BoltCooldown.start(boltCooldown)
