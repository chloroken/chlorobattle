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
	apply_status_damage(finalSickDamage, pawnStatus.sickPawnSource, basePawn, "Sick")

func apply_status_damage(damage, attacker, victim, dotName) -> void:
	victim.hp -= damage
	var combatLogMsg = ""
	if is_instance_valid(attacker):
		attacker.damageDealt += damage
		combatLogMsg = "[[color=#FDFD97]" + str(attacker.username) + "[/color]] hit [[color=#FEB144]" + str(victim.username) + "[/color]] for " + str("%0.2f" % damage) + " ([color=#FF6663]" + str(dotName) + "[/color])"
	else:
		combatLogMsg = "[[color=#FEB144]" + str(victim.username) + "[/color]] took " + str("%0.2f" % damage) + " damage ([color=#FF6663]" + str(dotName) + "[/color])"
	victim.board.combat_log(combatLogMsg)
	victim.get_node("Combat").clean_up_pawn(attacker)
