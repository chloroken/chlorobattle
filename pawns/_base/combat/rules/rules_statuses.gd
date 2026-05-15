extends Node
var basePawn
var pawnStatus
var arenaBoard

################
# STATUS RULES #
################
func _ready() -> void:
	basePawn = get_parent().get_parent()
	pawnStatus = basePawn.get_node("Status")
	arenaBoard = basePawn.get_parent()

func bleed_damage() -> void:
	var globalDmgMod = arenaBoard.globalDmgMod / arenaBoard.dmgModDuration
	var bleedDamage = basePawn.hp * pawnStatus.bleedPercentDamage * globalDmgMod
	var damageCap = basePawn.hp - pawnStatus.bleedMinimumHp
	var finalBleedDamage = min(bleedDamage, damageCap)
	if finalBleedDamage <= 0: return
	apply_status_damage(finalBleedDamage, pawnStatus.bleedPawnSource, basePawn, "Bleed")

func sick_damage() -> void:
	var globalDmgMod = arenaBoard.globalDmgMod / arenaBoard.dmgModDuration
	var missingHp = basePawn.baseHp - basePawn.hp
	var sickDamage = missingHp * pawnStatus.sickPercentDamage * globalDmgMod
	var damageCap = basePawn.hp
	var finalSickDamage = min(sickDamage, damageCap)
	if finalSickDamage <= 0: return
	apply_status_damage(finalSickDamage, pawnStatus.bleedPawnSource, basePawn, "Sick")

func apply_status_damage(damage, source, victim, dotName) -> void:
	victim.hp -= damage
	var combatLogMsg = ""
	if is_instance_valid(source):
		source.damageDealt += damage
		combatLogMsg = "[" + str(source.username) + "] hit [" + str(victim.username) + "] for " + str("%0.2f" % damage) + " (" + str(dotName) + ")"
	else:
		combatLogMsg = "[" + str(victim.username) + "] took " + str("%0.2f" % damage) + " damage (" + str(dotName) + ")"
	victim.board.combat_log(combatLogMsg)
