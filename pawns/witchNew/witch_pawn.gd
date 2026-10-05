extends "res://pawns/_base/base_pawn.gd"

var familiarCooldownMin = 2.0
var familiarCooldownMax = 3.0
var familiarDurationMin = 20.0
var familiarDurationMax = 30.0
var familiarTetherDistance

@export var frogAttackScene: PackedScene
var frogAttackName = "Frog"
var greenFrogSickChancePercent = 50
var greenFrogSickDuration = 8.0
var purpleFrogChancePercent = 50
var purpleFrogDamageMultiplier = 0.5
var purpleFrogWeakDuration = 8.0

@export var spiderAttackScene: PackedScene
var spiderAttackName = "Spider"
var spiderFamiliarChancePercent = 20
var spiderMoveSpeed
var spiderDamageMultiplier = 0.1
var spiderBleedDuration = 5.0
var spiderSickDuration = 5.0

func _ready() -> void:
	super()
	if !attacksDisabled:
		familiarTetherDistance = board.boardRadius / 4
		new_attack_cycle(familiarCooldownMin, familiarCooldownMax)

func _on_attack_cooldown_timer_timeout() -> void:
	new_attack_cycle(familiarCooldownMin, familiarCooldownMax)
	if disarm_check(): return
	pick_famililar_to_summon()
	
func pick_famililar_to_summon() -> void:
	if randi_range(1, 100) <= spiderFamiliarChancePercent:
		new_spider_attack()
	else:
		new_frog_attack()
func new_spider_attack() -> void:
	var newSpider = spiderAttackScene.instantiate()
	newSpider.isSpiderAttack = true
	newSpider.position = position
	newSpider.areaAttack = true
	newSpider.direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	newSpider.dmg = self.dmg * spiderDamageMultiplier
	newSpider.attackName = spiderAttackName
	newSpider.duration = randf_range(familiarDurationMin, familiarDurationMax)
	$AttackContainer.add_child(newSpider)
func new_frog_attack() -> void:
	var newFrog = frogAttackScene.instantiate()
	newFrog.position = position
	newFrog.areaAttack = false
	newFrog.direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	newFrog.dmg = self.dmg
	newFrog.attackName = frogAttackName
	newFrog.duration = randf_range(familiarDurationMin, familiarDurationMax)
	try_purple_frog(newFrog)
	$AttackContainer.add_child(newFrog)
func try_purple_frog(newFrog) -> void:
	var purpleFrogRoll = randi_range(1, 100)
	if purpleFrogRoll >= purpleFrogChancePercent:
		newFrog.dmg = self.dmg * purpleFrogDamageMultiplier
		newFrog.isPurpleFrogAttack = true
