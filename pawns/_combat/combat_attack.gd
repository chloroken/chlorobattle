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
func combat_attack(attack) -> void:
	get_parent().add_attack_to_hitlist(attack)
	var attacker = attack.get_parent().get_parent()
	guaranteed_effects(attack, attacker)
	if accuracy_check(attacker):
		var damage = on_hit_effects(attacker)
		damage = mitigation_phase(damage, attack, attacker)
		damage = modifier_phase(attack, damage, attacker)
		damage_phase(damage, attacker, attack)
		damage_effects(attack, attacker)
	get_parent().clean_up_attack(attack)
	get_parent().clean_up_pawn(attacker)

##########
# PHASES #
##########

func guaranteed_effects(attack, attacker) -> void:
	styles.style_berserk_trigger(attacker)

	if attack.isRamAttack:
		var par = attack.get_parent().get_parent()
		attack.dmg = max(par.dmg, min(par.chargeSpeedMax, par.chargeMovespeedModifier * par.spd * par.statusSpdMod))
		if !attacker.get_node("Status").get_node("DisarmedStatusTimer").is_stopped():
			attack.dmg *= attacker.hornDisarmDamageMultiplier

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
		if basePawn.type != "ram":
			attacker.direction = attacker.new_direction()
			basePawn.board.combat_log("[[color=#FDFD97]" + str(attacker.username) + "[/color]] missed an attack.")
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

func modifier_phase(attack, baseHit, attacker) -> float:
	if !attacker.get_node("Status").get_node("WeakStatusTimer").is_stopped(): baseHit /= 2
	if !attacker.get_node("Status").get_node("DrunkStatusTimer").is_stopped(): baseHit *= attacker.get_node("Status").drunkDamageMod
	baseHit += items.item_check_dice(attacker, baseHit)
	baseHit += styles.style_mighty_trigger(attacker, baseHit)
	baseHit += styles.style_snowball_trigger(baseHit, attacker)
	baseHit *= status.tanky_reduce_damage()
	baseHit += styles.style_slayer_trigger(attacker)
	var finalHit = baseHit
	if !board.get_parent().duelMode:
		finalHit = baseHit * (board.globalDmgMod / board.dmgModDuration)
	return(finalHit)

func damage_phase(damage, attacker, attack) -> void:
	basePawn.hp -= damage
	basePawn.damageTaken += damage
	attacker.damageDealt += damage
	
	if basePawn.hp > 0:
		if attacker.style == "slayer":
			attacker.get_node("Styles").add_slayer_charge()
	else:
		if attacker.style == "slayer":
			attacker.get_node("Styles").slayer_discharge(attacker)
		elif attacker.style == "snowball":
			attacker.get_node("Styles").add_snowball_charge()

	basePawn.board.combat_log("[[color=#FDFD97]" + str(attacker.username) + "[/color]] hit [[color=#FEB144]" + str(basePawn.username) + "[/color]] for " + "%0.2f" % damage + " ([color=#FF6663]" + str(attack.attackName) + "[/color])")

func damage_effects(attack, attacker) -> void:

	# Item/status effects
	status.try_scared(attack)
	items.item_try_skating()
	items.item_try_glue(attacker)
	#items.item_try_killbot(attacker)
	items.item_try_map()

	# Meta reaper passive
	if attack.isSoulAttack: attack.return_to_pawn()

	# Slug ooze dot
	if attack.isSlugAttack:
		status.start_sick(attacker.slimeSickDuration, attacker)

	# Cat swipe bleed
	if attack.isRedSwipeAttack:
		status.start_bleed(attacker.swipeBleedDuration, attacker)

	# Cat yarn lazy
	if attack.isYarnAttack:
		status.start_lazy(attacker.yarnLazyDuration)

	if attack.isHauntAttack:
		basePawn.isHaunted = true
		attacker.hauntTarget = basePawn
		attacker.get_node("Status").start_void(attacker.possessDuration)
		attacker.get_node("PossessDurationTimer").start(attacker.possessDuration)

	if attack.isBooAttack:
		status.start_scared(attacker.booScareDuration)

	if attack.isEmpAttack:
		var disarmDuration = attacker.empDisarmDuration
		status.start_disarmed(disarmDuration)

	if attack.isCauldronAttack:
		var lazyDuration = attacker.cauldronLazyDuration
		status.start_lazy(lazyDuration)

	if attack.isPurpleFrogAttack:
		status.start_weak(attacker.purpleFrogWeakDuration)

	if attack.isInfernoAttack:
		var disarmDuration = attacker.infernoDisarmDuration
		status.start_hazy(disarmDuration)

	# Mummy glyph disarm
	if attack.isGlyphAttack:
		status.start_disarmed(attacker.glyphDisarmDuration)

	# Mummy swarm weak + sick
	if attack.isSwarmAttack:
		status.start_weak(attacker.swarmWeakDuration)
		status.start_sick(attacker.swarmSickDuration, attacker)

	if basePawn.type == "slug":
		basePawn.get_node("SlugShellTimer").start(basePawn.shellCooldown)
		basePawn.get_node("PawnSprite").texture = basePawn.normalSpriteScene
		if basePawn.shellActive:
			status.stop_tanky()
			basePawn.shellActive = false

	if attack.isSpiderAttack:
		status.start_bleed(attacker.spiderBleedDuration, attacker)
		status.start_sick(attacker.spiderSickDuration, attacker)
		
