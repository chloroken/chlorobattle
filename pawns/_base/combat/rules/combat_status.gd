extends Node

func dot_damage() -> void:
	var basePawn = get_parent().get_parent()
	var pawnStatus = basePawn.get_node("Status")
	var arenaBoard = basePawn.get_parent()
	var globalDmgMod = arenaBoard.globalDmgMod / arenaBoard.dmgModDuration
	var dotDamageAmount = min(basePawn.hp - pawnStatus.dotMinimumHp, basePawn.baseHp * pawnStatus.dotPercentDamage * globalDmgMod)
	if dotDamageAmount <= 0: return
	basePawn.hp -= dotDamageAmount
	if is_instance_valid(pawnStatus.dotPawnSource):
		pawnStatus.dotPawnSource.damageDealt += dotDamageAmount
		basePawn.get_node("Combat").combat_log("[" + str(pawnStatus.dotPawnSource.username) + "] hit [" + str(basePawn.username) + "] for " + str("%0.2f" % dotDamageAmount) + " (Dot)")
	else:
		basePawn.get_node("Combat").combat_log("[" + str(basePawn.username) + "] took " + str("%0.2f" % dotDamageAmount) + " damage (Dot)")
