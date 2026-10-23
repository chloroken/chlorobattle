extends "res://pawns/_base/base_pawn.gd"

@export var jetFormSprite: Texture
@export var glaiveAttackScene: PackedScene
var glaiveCooldownMin = 4.0
var glaiveCooldownMax = 5.0
var glaiveDmgMod = 3.0
var glaiveRotationSpeed = 10.0

@export var walkerFormSprite: Texture
var mechaWalkerFormActive = false
var mechaFormSwapTimer = 7.0
var mechaFormSwapVariance = 1.0

@export var missileAttackScene: PackedScene
@export var missileExplosionScene: PackedScene
var missileCooldownMin = 2.0
var missileCooldownMax = 3.0
var missileSpeedMin = 50
var missileSpeedMax = 100
var missileDurationMin = 1.0
var missileDurationMax = 2.0
var missileCount = 5
var missileBoardGrace = 1.05

func _ready() -> void:
	super()
	choose_initial_form()
	if !inLobby:
		enable_form_cycling()
		mecha_form_specific_attack_cycle()

# Forms
func choose_initial_form() -> void:
	if randi_range(0, 1) == 1:
		$PawnSprite.texture = walkerFormSprite
		mechaWalkerFormActive = true
	else:
		$PawnSprite.texture = jetFormSprite
		mechaWalkerFormActive = false
func enable_form_cycling() -> void:
	$FormSwapTimer.one_shot = true
	$FormSwapTimer.start(0.1)
func _on_form_swap_timer_timeout() -> void:
	var cooldownVariance = randf_range(-mechaFormSwapVariance, mechaFormSwapVariance)
	apply_form_switching_status(cooldownVariance)
	form_switch_attack_cycle_reset()
	mechaWalkerFormActive = !mechaWalkerFormActive
	$FormSwapTimer.start(mechaFormSwapTimer + cooldownVariance)
func form_switch_attack_cycle_reset() -> void:
	if !inLobby:
		$AttackCooldownTimer.start(.01)
func apply_form_switching_status(cooldownVariance) -> void:
	if mechaWalkerFormActive:
		$Status.start_sprint(mechaFormSwapTimer + cooldownVariance)
	else:
		$Status.start_slow(mechaFormSwapTimer + cooldownVariance)
func _physics_process(delta: float) -> void:
	super(delta)
	set_proper_form_sprite()
func set_proper_form_sprite() -> void:
	if !mechaWalkerFormActive:
		$PawnSprite.rotation = direction.angle()
		$PawnSprite.texture = jetFormSprite
	else:
		$PawnSprite.texture = walkerFormSprite
		$PawnSprite.rotation = 0.0

# Attacks
func mecha_form_specific_attack_cycle() -> void:
	if mechaWalkerFormActive:
		new_attack_cycle(missileCooldownMin, missileCooldownMax)
	elif !mechaWalkerFormActive:
		new_attack_cycle(glaiveCooldownMin, glaiveCooldownMax)
func _on_attack_cooldown_timer_timeout() -> void:
	mecha_form_specific_attack_cycle()
	if disarm_check(): return
	determine_attack_to_use()
func determine_attack_to_use() -> void:
	if !mechaWalkerFormActive:
		new_glaive_attack()
	elif mechaWalkerFormActive:
		new_missile_volley()
func new_glaive_attack() -> void:
	var newAttack = glaiveAttackScene.instantiate()
	newAttack.position = self.position
	newAttack.dmg = self.dmg * glaiveDmgMod
	newAttack.attackName = "Glaive"
	newAttack.rotationSpeed = glaiveRotationSpeed
	$AttackContainer.add_child(newAttack)
func new_missile_volley() -> void:
	for i in missileCount:
		var newAttack = missileAttackScene.instantiate()
		newAttack.position = self.position
		newAttack.dmg = self.dmg
		newAttack.direction = Vector2.RIGHT.rotated(randf_range(0, TAU))#self.direction.rotated(newAtkArc)
		newAttack.speed = randf_range(missileSpeedMin, missileSpeedMax)
		newAttack.duration = randf_range(missileDurationMin, missileDurationMax)
		newAttack.boardGrace = missileBoardGrace
		$AttackContainer.add_child(newAttack)
func make_explosion(loc: Vector2) -> void:
	var newAttack = missileExplosionScene.instantiate()
	newAttack.position = loc
	newAttack.dmg = self.dmg
	newAttack.attackName = "Missile"
	newAttack.areaAttack = true
	$AttackContainer.add_child(newAttack)
