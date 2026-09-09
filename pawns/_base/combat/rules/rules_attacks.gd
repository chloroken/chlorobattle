extends Node
var basePawn
var board
var styles
var status
var items

################
# ATTACK RULES #
################

func _ready() -> void:
	basePawn = get_parent().get_parent()
	board = basePawn.get_parent()
	styles = basePawn.get_node("Styles")
	status = basePawn.get_node("Status")
	items = basePawn.get_node("Items")
func combat_pawn(attack) -> void:
	get_parent().add_attack_to_hitlist(attack)
	var attacker = attack.get_parent().get_parent()
	guaranteed_effects(attacker)
	if accuracy_check(attacker):
		var damage = on_hit_effects(attacker)
		damage = mitigation_phase(damage, attack, attacker)
		damage = modifier_phase(damage, attacker)
		damage_phase(damage, attacker, attack)
		damage_effects(attack, attacker)
	get_parent().clean_up_attack(attack)
	get_parent().clean_up_pawn(attacker)

##########
# PHASES #
##########

func guaranteed_effects(attacker) -> void:
	styles.style_berserk_trigger(attacker)

func accuracy_check(attacker) -> bool:	
	var hitChance = 100

	# Drunk miss mechanic
	var drunkTimer = attacker.get_node("Status").get_node("DrunkStatusTimer")
	if attacker.type != "pirate" && !drunkTimer.is_stopped():
		hitChance -= status.drunkMissChance

	# Hazy hit chance reduction
	hitChance *= attacker.get_node("Status").try_hazy()

	var hitRoll = randi_range(1, 100)
	if hitRoll > hitChance:
		attacker.direction = attacker.new_direction()
		basePawn.board.combat_log("[" + str(attacker.username) + "] missed an attack.")
		return(false)

	return(true)

func on_hit_effects(attacker) -> float:
	var onHit = 0
	onHit += styles.style_parkour_trigger(attacker)
	return(onHit)

func mitigation_phase(onHitDamage, attack, attacker) -> float:
	var baseHit = onHitDamage + attack.dmg
	var baseDefendedHit = baseHit * basePawn.def
	var actualDefended = baseDefendedHit * (1.0 - attacker.pen)
	var realHit = (baseHit - actualDefended)
	return(realHit)

func modifier_phase(baseHit, attacker) -> float:
	if !attacker.get_node("Status").get_node("WeakStatusTimer").is_stopped(): baseHit /= 2
	baseHit += items.item_check_dice(attacker, baseHit)
	baseHit += styles.style_mighty_trigger(attacker, baseHit)
	baseHit *= status.tanky_reduce_damage()
	baseHit += styles.style_slayer_trigger(attacker)
	#var board = get_parent().get_parent().get_parent()
	var finalHit = baseHit * (board.globalDmgMod / board.dmgModDuration)
	return(finalHit)

func damage_phase(damage, attacker, attack) -> void:
	basePawn.hp -= damage
	basePawn.damageTaken += damage
	attacker.damageDealt += damage
	basePawn.board.combat_log("[" + str(attacker.username) + "] hit [" + str(basePawn.username) + "] for " + "%0.2f" % damage + " (" + str(attack.attackName) + ")")

func damage_effects(attack, attacker) -> void:

	# Item/status effects
	status.try_scared(attack)
	items.item_try_skating()
	items.item_try_glue(attacker)
	items.item_try_map()

	# Meta reaper passive
	if attack.isSoulAttack: attack.return_to_pawn()

	# Slug ooze dot
	if attack.isSlugAttack:
		status.start_sick(attacker.oozeSickDuration, attacker)

	# Mummy glyph disarm
	if attacker.type == "mummy" && attack.mummyCenter == true:
		status.start_disarmed(attacker.glyphDisarmDuration)

	# Mummy curse transfer
	if basePawn.type == "mummy":
		var attackerStatus = attacker.get_node("Status")
		if basePawn.isCursed:
			basePawn.isCursed = false
			status.stop_weak()
			basePawn.get_node("CursedResetTimer").start(basePawn.curseResetTimer)
			attackerStatus.start_weak(basePawn.cursePassDuration)

	# Cat bleed
	if attack.isSwipeAttack:
		if attack.redSwipe:
			basePawn.get_node("Status").start_bleed(attacker.catSwipeBleedDuration, attacker)

	# Cat yarn
	if attack.isYarnAttack:
		basePawn.get_node("Status").start_lazy(attacker.catYarnLazyDuration)

	if attack.isYellowBirdAttack:
		basePawn.get_node("Status").start_sick(attack.yellowBirdSickDuration, attacker)

	if attack.isPossessAttack:
		basePawn.isPossessed = true
		attacker.possessTarget = basePawn
		attacker.get_node("Status").start_void(attacker.possessDuration)
		attacker.get_node("PossessDurationTimer").start(attacker.possessDuration)

	if attack.isBooAttack:
		basePawn.get_node("Status").start_scared(attacker.booScareDuration)

	if attack.isEmpAttack:
		var disarmDuration = attacker.empDisarmDuration
		basePawn.get_node("Status").start_disarmed(disarmDuration)

	if attack.isCauldronAttack:
		var lazyDuration = attacker.cauldronLazyDuration
		basePawn.get_node("Status").start_lazy(lazyDuration)

	if attack.isFrogAttack:
		attack.create_splat()
