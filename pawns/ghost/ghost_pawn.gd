extends "res://pawns/_base/base_pawn.gd"

@export var booAttackScene: Resource
var booAttackName = "Boo"
var booCooldownMin = 2.0
var booCooldownMax = 4.0
var booMoveSpeed = 20.0
var booMaxCount = 12
var booCurrentCount = 0
var booScareDuration = 3.0
var booOrbitDistance = 25
var booOrbitSpeed = 2
var booOrbitVariation = 0.2

@export var baseGhostSprite: Resource
@export var baseHauntSprite: Resource
var hauntAttackName = "Haunt"
var hauntCooldown = 10.0
var hauntDuration = 3.0
var hauntMaxHpDamage = 0.1
var hauntTarget = self
var hauntSprintDuration = 2.0
var hauntTankyDuration = 2.0

func _ready() -> void:
	super()
	if !attacksDisabled:
		$AttackCooldownTimer.one_shot = true
		$HauntDurationTimer.one_shot = true
		$HauntCooldownTimer.one_shot = true
		$HauntCooldownTimer.start(hauntCooldown)
		new_attack_cycle(booCooldownMin, booCooldownMax)

# Boo
func _on_attack_cooldown_timer_timeout() -> void:
	new_attack_cycle(booCooldownMin, booCooldownMax)
	if disarm_check(): return
	if !boo_max_reached():
		new_boo_attack()
func boo_max_reached() -> bool:
	if booCurrentCount >= booMaxCount:
		return(true)
	booCurrentCount += 1
	return(false)
func new_boo_attack() -> void:
	var newAttack = booAttackScene.instantiate()
	newAttack.position = self.position
	newAttack.dmg = self.dmg
	newAttack.modulate.a = 0.0 # give it a frame to find its orbit
	newAttack.attackName = booAttackName
	newAttack.areaAttack = false
	newAttack.isBooAttack = true
	newAttack.orbitDistance = booOrbitDistance
	newAttack.orbitSpeed = booOrbitSpeed
	newAttack.orbitVariation = booOrbitVariation
	$AttackContainer.add_child(newAttack)

# Haunt
func _physics_process(delta: float) -> void:
	super(delta)
	check_haunt_for_issues()
	haunt_enable()
	update_ghost_haunt_sprite()
func check_haunt_for_issues() -> void:
	if hauntTarget == null: stop_haunt()
	if hauntTarget.is_queued_for_deletion(): stop_haunt()
func haunt_enable() -> void:
	if !$HauntDurationTimer.is_stopped():
		$GUI.visible = false
		position = hauntTarget.position
func stop_haunt() -> void:
	$HauntDurationTimer.stop()
	hauntTarget = self
	$GUI.visible = true
func _on_haunt_cooldown_timer_timeout() -> void:
	hauntTarget = self
func _on_haunt_duration_timer_timeout() -> void:
	haunt_conclusion_procedure()
	$HauntCooldownTimer.start(hauntCooldown)
func haunt_conclusion_procedure() -> void:
	var hauntDamage = calculate_haunt_damage()
	haunt_apply_damage(hauntDamage)
	haunt_apply_heal(hauntDamage)
	haunt_custom_combat_log(hauntDamage)
	haunt_custom_clean_up_step()
	stop_haunt()
	haunt_apply_buffs()
func calculate_haunt_damage() -> float:
	var globalDmgMod = board.globalDmgMod / board.dmgModDuration
	var hpToDeal = min(hauntTarget.hp, hauntTarget.baseHp * hauntMaxHpDamage * globalDmgMod)
	return(hpToDeal)
func haunt_apply_damage(hauntDamage) -> void:
	hauntTarget.hp -= hauntDamage
func haunt_apply_heal(hauntHeal) -> void:
	var healAmount = min(baseHp - hp, hauntHeal)
	hp += healAmount
func haunt_custom_combat_log(hauntDamage) -> void:
	damageDealt += hauntDamage
	damageHealed += hauntDamage
	board.combat_log("[[color=#FDFD97]" + str(username) + "[/color]] hit [[color=#FEB144]" + str(hauntTarget.username) + "[/color]] for " + str(int(hauntDamage)) + " ([color=#FEB144]" + str(hauntAttackName) + "[/color])")
	board.combat_log("[[color=#FDFD97]" + str(username) + "[/color]] healed for " + str(int(hauntDamage)) + " ([color=#9EE09E]" + str(hauntAttackName) + "[/color])")
func haunt_custom_clean_up_step() -> void:
	hauntTarget.isHaunted = false
	hauntTarget.get_node("Combat").clean_up_pawn(self)
func haunt_apply_buffs() -> void:
	$Status.start_sprint(hauntSprintDuration)
	$Status.start_tanky(hauntTankyDuration)
func update_ghost_haunt_sprite():
	var hauntingNow = $HauntCooldownTimer.is_stopped()
	var curSprite = $PawnSprite.texture
	if hauntingNow && curSprite != baseHauntSprite:
		$PawnSprite.texture = baseHauntSprite
	elif !hauntingNow && curSprite != baseGhostSprite:
		$PawnSprite.texture = baseGhostSprite
