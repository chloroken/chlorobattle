extends Node

###############
# STYLE RULES #
###############

var basePawn
var styles
var status
var items
func _ready() -> void:
	basePawn = get_parent().get_parent()
	styles = basePawn.get_node("Styles")
	status = basePawn.get_node("Status")
	items = basePawn.get_node("Items")

###############
# BULLY TOUCH #
###############

func bully_hit(victim) -> void:
	#if basePawn.attacksDisabled: return
	#if basePawn.style != "bully": return
	#if !victim.get_collision_layer_value(1): return
	#if victim.username == basePawn.username: return
	#if !victim.get_node("Status").get_node("VoidStatusTimer").is_stopped(): return
	#var mainBoard = get_parent().get_parent().get_parent().get_parent()
	#if mainBoard.teamsEnabled && victim.team == basePawn.team: return
	styles.style_bully_trigger(victim)
	status.start_sprint(styles.bullyStackCount * styles.bullySprintDuration)
	victim.get_node("Status").start_slow(styles.bullyStackCount * styles.bullySlowDuration)
	if victim.style != "bully":
		victim.get_node("Status").start_weak(styles.bullyStackCount * styles.bullyWeakDuration)
	var bullyDmg = get_parent().get_parent().hp * styles.bullyDmgPct * styles.bullyStackCount
	var finalHit = bullyDmg * (get_parent().get_parent().get_parent().globalDmgMod / get_parent().get_parent().get_parent().dmgModDuration)
	victim.hp -= finalHit
	victim.damageTaken += finalHit
	get_parent().get_parent().damageDealt += finalHit
	get_parent().get_parent().get_node("Combat").combat_log("[" + str(get_parent().get_parent().username) + "] hit [" + str(victim.username) + "] for " +  str("%0.2f" % finalHit) + " (Bully)")
	get_parent().clean_up_pawn(victim)
	victim.get_node("Combat").clean_up_pawn(basePawn)
