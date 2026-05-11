extends Node

###############
# STYLE RULES #
###############

var basePawn
var board
var styles
var status
var items
func _ready() -> void:
	basePawn = get_parent().get_parent()
	board = basePawn.get_parent()
	styles = basePawn.get_node("Styles")
	status = basePawn.get_node("Status")
	items = basePawn.get_node("Items")

###############
# BULLY TOUCH #
###############

func bully_touch(victim) -> void:
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
	board.combat_log("[" + str(get_parent().get_parent().username) + "] hit [" + str(victim.username) + "] for " +  str("%0.2f" % finalHit) + " (Bully)")
	get_parent().clean_up_pawn(victim)
	victim.get_node("Combat").clean_up_pawn(basePawn)

###############
# PARKOUR HIT #
###############
func parkour_hit(victim) -> void:
	pass
