extends Node

var basePawn
var styles
var status
var items

func _ready() -> void:
	basePawn = get_parent().get_parent()
	styles = basePawn.get_node("Styles")
	status = basePawn.get_node("Status")
	items = basePawn.get_node("Items")

func combat_pawn(attack) -> void:

	# Validate attack
	if !basePawn.get_node("Status/VoidStatusTimer").is_stopped(): return
	if !attack.get_collision_layer_value(2): return
	var attacker = attack.get_parent().get_parent()
	var attackerUsername = attacker.username
	if attackerUsername == basePawn.username || basePawn.hitList.has(attack): return
	if attacker.team == basePawn.team: return

	# Combat procedure
	guaranteed_effects(attack, attacker)
	if accuracy_check(attacker):
		precombat_effects(attack)
		var damage = damage_mitigation(attacker, attack)
		damage = calculate_multipliers(damage, attacker)
		damage_phase(damage, attacker, attack)
		postcombat_effects(attacker, attack)
	get_parent().clean_up_attack(attack)
	get_parent().clean_up_pawn(attacker)

func guaranteed_effects(area, attacker) -> void:
	styles.style_berserk_trigger(attacker)
	if attacker.type == "mummy" && area.mummyCenter == true:
		status.start_disarmed(attacker.glyphDisarmDuration)
func accuracy_check(attacker) -> bool:	
	var hitChance = 100
	# Drunk miss mechanic
	var drunkTimer = attacker.get_node("Status").get_node("DrunkStatusTimer")
	if !drunkTimer.is_stopped(): hitChance -= status.drunkMissChance
	var hitRoll = randi_range(1, 100)
	if hitRoll > hitChance:
		attacker.direction = attacker.new_direction()
		basePawn.get_node("Combat").combat_log("[" + str(attacker.username) + "] missed an attack (Drunk)")
		return(false)
	return(true)
func precombat_effects(attack) -> void:
	if attack.isSoulAttack: attack.return_to_pawn()
func damage_mitigation(attacker, attack) -> float:
	var baseHit = attack.dmg
	var baseDefendedHit = baseHit * basePawn.def
	var actualDefended = baseDefendedHit * (1.0 - attacker.pen)
	var realHit = (baseHit - actualDefended)
	return(realHit)
func calculate_multipliers(baseHit, attacker) -> float:
	if !attacker.get_node("Status").get_node("WeakStatusTimer").is_stopped(): baseHit /= 2
	baseHit += items.item_check_dice(attacker, baseHit)
	baseHit += styles.style_mighty_trigger(attacker, baseHit)
	baseHit *= status.tanky_reduce_damage()
	baseHit += styles.style_slayer_trigger(attacker)
	var board = get_parent().get_parent().get_parent()
	var finalHit = baseHit * (board.globalDmgMod / board.dmgModDuration)
	return(finalHit)
func damage_phase(damage, attacker, attack) -> void:
	basePawn.hp -= damage
	basePawn.damageTaken += damage
	attacker.damageDealt += damage
	basePawn.get_node("Combat").combat_log("[" + str(attacker.username) + "] hit [" + str(basePawn.username) + "] for " + "%0.2f" % damage + " (" + str(attack.attackName) + ")")
func postcombat_effects(attacker, attack) -> void:
	status.try_scared(attack)
	items.item_try_skating()
	if attacker.item == "glue": items.item_try_glue(attacker)
	if basePawn.type == "mummy":
		var attackerStatus = attacker.get_node("Status")
		if basePawn.isCursed:
			basePawn.isCursed = false
			status.stop_weak()
			basePawn.get_node("CursedResetTimer").start(basePawn.curseResetTimer)
			attackerStatus.start_weak(basePawn.cursePassDuration)
	if attack.isSlugAttack:
		var durationRemaining = attack.get_node("FizzleTimer").get_time_left()
		status.start_dot(durationRemaining, attacker)
	if attack.isEmberAttack:
		if randi_range(1, 100) < 70:
			status.start_dot(attack.get_parent().get_parent().emberBurnDuration, attacker)
	items.item_try_map()
