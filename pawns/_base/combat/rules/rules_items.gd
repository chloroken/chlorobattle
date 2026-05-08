extends Node
var basePawn
var styles
var status
var items

##############
# ITEM RULES #
##############

func _ready() -> void:
	basePawn = get_parent().get_parent()
	status = basePawn.get_node("Status")
	items = basePawn.get_node("Items")
func combat_item(attack, pawn) -> void:
	var attacker = attack.get_parent().get_parent()
	var attackerUsername = attacker.username
	guaranteed_effects()
	damage_phase(attacker, attackerUsername, attack, pawn)
	damage_effects(attacker, attack)
	get_parent().clean_up_attack(attack)
	get_parent().clean_up_pawn(attacker)

##########
# PHASES #
##########

func guaranteed_effects() -> void:
	pass
func damage_phase(attacker, attackerUsername, area, pawn) -> void:
	var baseHit = area.dmg
	var board = get_parent().get_parent().get_parent()
	var finalDmg = baseHit * (board.globalDmgMod / board.dmgModDuration)
	pawn.hp -= finalDmg
	pawn.damageTaken += finalDmg
	attacker.damageDealt += finalDmg
	pawn.get_node("Combat").combat_log("[" + str(attackerUsername) + "] hit [" + str(pawn.username) + "] for " + "%0.2f" % finalDmg + " (" + str(area.attackName) + ")")
func damage_effects(attacker, attack) -> void:
	status.try_scared(attack)
	items.item_try_killbot_stack(attacker, attack)
	items.try_tire_stuck(attack)
	items.try_smoke_effect(attack, attacker)
	items.try_skate_blade(attacker, attack)
