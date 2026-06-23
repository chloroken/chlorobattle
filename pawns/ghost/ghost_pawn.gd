extends "res://pawns/_base/base_pawn.gd"

@export var booAttack: Resource
var booCooldownMin = 2.0
var booCooldownMax = 3.0
var booMoveSpeed = 50.0
var booMaxCount = 10
var booCount = 0
var booScareDuration = 3.0

var possessCooldown = 10.0
var possessDuration = 3.0
var possessMaxHpDamage = 0.1
var possessTarget = self
var possessSprintDuration = 2.0
var possessTankyDuration = 2.0

@export var costumeSprite: Resource
@export var baseSprite: Resource
@export var basePossess: Resource
@export var costumePossess: Resource

@export var hauntArray: Array[Resource]

func _ready() -> void:
	super()

	$AttackCooldownTimer.one_shot = true
	$PossessCooldownTimer.one_shot = true
	$PossessDurationTimer.one_shot = true
	if !attacksDisabled:
		$PossessCooldownTimer.start(possessCooldown)
		start_attack_cooldown()

func start_attack_cooldown() -> void:
	var booCooldown = asp * aspMod * randf_range(booCooldownMin, booCooldownMax)
	$AttackCooldownTimer.start(booCooldown)

func _on_attack_cooldown_timer_timeout() -> void:
	start_attack_cooldown()
	if disarm_check(): return

	if booCount >= booMaxCount: return
	booCount += 1

	var newAttack = booAttack.instantiate()
	newAttack.position = self.position
	newAttack.dmg = self.dmg
	newAttack.modulate.a = 0.0
	$AttackContainer.add_child(newAttack)

func _process(_delta: float) -> void:
	if $PossessCooldownTimer.is_stopped():
		$PawnSprite.texture = spriteArray[costume-1]
	else: $PawnSprite.texture = hauntArray[costume-1]

func _physics_process(delta: float) -> void:
	super(delta)
	#check if posses target is dead, stop possess
	if possessTarget == null: stop_possess()
	if possessTarget.is_queued_for_deletion(): stop_possess()
	if !$PossessDurationTimer.is_stopped():
		$GUI.visible = false
		position = possessTarget.position

func stop_possess() -> void:
	$PossessDurationTimer.stop()
	possessTarget = self
	$GUI.visible = true

func _on_possess_cooldown_timer_timeout() -> void:
	possessTarget = self

func _on_possess_duration_timer_timeout() -> void:
	var globalDmgMod = board.globalDmgMod / board.dmgModDuration
	var hpToDeal = min(possessTarget.hp, possessTarget.baseHp * possessMaxHpDamage * globalDmgMod)
	possessTarget.hp -= hpToDeal
	damageDealt += hpToDeal
	var hpToHeal = min(baseHp - hp, hpToDeal)
	hp += hpToHeal
	damageHealed += hpToHeal
	board.combat_log("[" + str(username) + "] hit [" + str(possessTarget.username) + "] for " + str(int(hpToDeal)) + " (Purge)")
	board.combat_log("[" + str(username) + "] healed for " + str(int(hpToHeal)) + " (Purge)")
	possessTarget.isPossessed = false
	possessTarget.get_node("Combat").clean_up_pawn(self)
	possessTarget = self
	$GUI.visible = true
	$Status.start_sprint(possessSprintDuration)
	$Status.start_tanky(possessTankyDuration)
	$PossessCooldownTimer.start(possessCooldown)
