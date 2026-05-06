extends Node

var basePawn
var styles
var status
var items

func _ready() -> void:
	basePawn = get_parent().get_parent()
	status = basePawn.get_node("Status")
	items = basePawn.get_node("Items")
func combat_item(attack, pawn) -> void:
	if !status.get_node("VoidStatusTimer").is_stopped(): return
	if attack.get_collision_layer_value(3):
		var attacker = attack.get_parent().get_parent()
		var attackerUsername = attacker.username
		if attackerUsername != pawn.username && !pawn.hitList.has(attack):
			predamage_effects_phase()
			damage_phase(attacker, attackerUsername, attack, pawn)
			effects_phase(attacker, attack)
			get_parent().clean_up_attack(attack)
			get_parent().clean_up_pawn(attacker)
func predamage_effects_phase() -> void:
	pass
func damage_phase(attacker, attackerUsername, area, pawn) -> void:
	var baseHit = area.dmg
	var board = get_parent().get_parent().get_parent()
	var finalDmg = baseHit * (board.globalDmgMod / board.dmgModDuration)
	pawn.hp -= finalDmg
	pawn.damageTaken += finalDmg
	attacker.damageDealt += finalDmg
	pawn.get_node("Combat").combat_log("[" + str(attackerUsername) + "] hit [" + str(pawn.username) + "] for " + "%0.2f" % finalDmg + " (" + str(area.attackName) + ")")
func effects_phase(attacker, attack) -> void:
	items.item_try_killbot_stack(attacker, attack)
	items.try_tire_stuck(attack)
	items.try_potion_effect(attack, attacker)
	status.try_scared(attack)
	items.try_skate_blade(attacker, attack)
