extends Node2D

var styles
var status
var items

func _ready() -> void:
	styles = get_parent().get_node("Styles")
	status = get_parent().get_node("Status")
	items = get_parent().get_node("Items")
#################
# HIT DETECTION #
#################

func combat_pawn(area, pawn) -> void:
	#if area.get_collision_layer_bit(1): return
	if area.get_collision_layer_value(6): return#areaType == "board": return
	if area.get_collision_layer_value(2):#areaType == "attack":
		var attackingPawn = area.get_parent().get_parent()
		var attackerUsername = attackingPawn.username
		if attackerUsername != pawn.username && !pawn.hitList.has(area):
			pre_accuracy_phase(area, attackingPawn)
			if accuracy_phase(attackingPawn, attackerUsername, pawn):
				predamage_effects_phase(area)
				var damage = defense_phase(attackingPawn, area, pawn)
				damage = modifier_phase(damage, attackingPawn, area)
				damage_phase(damage, attackingPawn, attackerUsername, area, pawn)
				effects_phase(attackingPawn, area, pawn)
			clean_up_phase(area, attackingPawn, attackerUsername, pawn)
func _on_bully_area_area_entered(area, pawn) -> void:
	if area.get_collision_layer_value(4) && pawn.style == "bully":
		if area.get_node("Status").get_node("VoidStatusTimer").is_stopped():
			styles.style_bully_trigger(area)

##################
# ACCURACY PHASE #
##################

# These effects will happen regardless of it the attack hits
func pre_accuracy_phase(area, attackingPawn) -> void:
	styles.style_berserk_trigger(area, attackingPawn)
	if attackingPawn.type == "mummy" && area.mummyCenter == true:
		status.start_disarmed(attackingPawn.glyphDisarmDuration)

# Determine if this attack will hit
func accuracy_phase(attackingPawn, attackerUsername, pawn) -> bool:	
	var hitChance = 100

	# Drunk miss mechanic
	var drunkTimer = attackingPawn.get_node("Status").get_node("DrunkStatusTimer")
	if !drunkTimer.is_stopped(): hitChance -= status.drunkMissChance
	var hitRoll = randi_range(1, 100)
	if hitRoll > hitChance:
		attackingPawn.direction = attackingPawn.new_direction()
		pawn.combat_log("[" + str(attackerUsername) + "] missed an attack (Drunk)")
		return(false)

	return(true)

###########################
# PREDAMAGE EFFECTS PHASE #
###########################

func predamage_effects_phase(body) -> bool:
	if body.isSoulAttack:
		body.return_to_pawn()
		#if attackingPawn.demonFormActive: return
		#var demonTimer = attackingPawn.get_node("DemonCooldownTimer")
		#var timeLeft = demonTimer.get_time_left()
		#var cooldownReduction = attackingPawn.demonSoulCooldownReduction
		#if timeLeft < cooldownReduction: demonTimer.start(0.01)
		#else: demonTimer.start(timeLeft - cooldownReduction)
	return(true)

#################
# DEFENSE PHASE #
#################

# Calculate the base damage of this hit
func defense_phase(attackingPawn, body, pawn) -> float:
	var baseHit = body.dmg
	var baseDefendedHit = baseHit * pawn.def
	var actualDefended = baseDefendedHit * (1.0 - attackingPawn.pen)
	var realHit = (baseHit - actualDefended)
	return(realHit)

##################
# MODIFIER PHASE #
##################

# Modify the base damage by effects
func modifier_phase(baseHit, attackingPawn, body) -> float:
	if !attackingPawn.get_node("Status").get_node("WeakStatusTimer").is_stopped(): baseHit /= 2
	baseHit += items.item_check_dice(attackingPawn, baseHit, body)
	baseHit += styles.style_mighty_trigger(body, attackingPawn, baseHit)
	baseHit *= status.tanky_reduce_damage()
	baseHit += styles.style_slayer_trigger(body, attackingPawn)
	var finalHit = baseHit * (get_parent().get_parent().globalDmgMod / get_parent().get_parent().dmgModDuration)
	return(finalHit)

################
# DAMAGE PHASE #
################

# Apply damage, record stats, output to combat log
func damage_phase(finalDmg, attackingPawn, attackerUsername, body, pawn) -> void:

	# Apply damage
	pawn.hp -= finalDmg

	# Update score
	pawn.damageTaken += finalDmg
	attackingPawn.damageDealt += finalDmg
	pawn.combat_log("[" + str(attackerUsername) + "] hit [" + str(pawn.username) + "] for " + "%0.2f" % finalDmg + " (" + str(body.attackName) + ")")

#####################
# EFFECTS PHASE #
#####################

# Apply on-hit effects after doing damage
func effects_phase(attackingPawn, body, pawn) -> void:
	status.try_scared(body)
	items.item_try_killbot_stack(attackingPawn, body)
	items.item_try_skating()
	items.item_try_glue(attackingPawn, body)
	if pawn.type == "mummy" && !body.isPersistentSummon:
		var attackerStatus = attackingPawn.get_node("Status")
		if pawn.isCursed:
			pawn.isCursed = false
			status.stop_weak()
			pawn.get_node("CursedResetTimer").start(pawn.curseResetTimer)
			attackerStatus.start_weak(pawn.cursePassDuration)
	if body.isSlugAttack:
		var durationRemaining = body.get_node("FizzleTimer").get_time_left()
		status.start_dot(durationRemaining, attackingPawn)
	items.try_tire_stuck(body)
	if body.isEmberAttack:
		if randi_range(1, 100) < 70:
			status.start_dot(body.get_parent().get_parent().emberBurnDuration, attackingPawn)
	items.item_try_map()
	items.try_potion_effect(body, attackingPawn)

##################
# CLEAN-UP PHASE #
##################

# Mark attack as hit or remove it, clean up dead Pawns
func clean_up_phase(body, attackingPawn, attackerUsername, pawn) -> void:
	if !body.areaAttack: body.queue_free()
	else: pawn.hitList.append(body)
	var pawns = get_parent().get_parent().get_parent().pawnList
	if pawn.hp <= 0:
		for i in range(0, pawns.size()):
			if pawns[i].username == pawn.username:
				attackingPawn.killCount += 1
				if attackingPawn.style == "slayer":
					attackingPawn.get_node("Styles").add_slayer_charge()
				pawn.pawn_death(attackingPawn, attackerUsername, i)
				break

###############
# BULLY TOUCH #
###############

func bully_hit(victim) -> void:
	
	# Hit victim for damage
	var bullyDmg = get_parent().hp * styles.bullyDmgPct * styles.bullyStackCount

	# Reduce damage for global dmg mod
	var finalHit = bullyDmg * (get_parent().get_parent().globalDmgMod / get_parent().get_parent().dmgModDuration)

	victim.hp -= finalHit
	victim.damageTaken += finalHit
	get_parent().damageDealt += finalHit
	get_parent().combat_log("[" + str(get_parent().username) + "] hit [" + str(victim.username) + "] for " +  str("%0.2f" % finalHit) + " (Bully)")
