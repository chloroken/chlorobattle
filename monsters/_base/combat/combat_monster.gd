extends Node

var baseMonster
var hitList
var board

func _ready() -> void:
	baseMonster = get_parent()
	board = baseMonster.get_parent().get_parent()
	hitList = baseMonster.hitList

func monster_hit(area) -> void:
	# Hit validation
	if !area.get_collision_layer_value(2): return #only pawn attacks
	if hitList.has(area): return
	if !area.areaAttack: area.queue_free()
	else: hitList.append(area)

	# Monster damage formula
	var attackingPawn = area.get_parent().get_parent()
	var dmgTaken = area.dmg
	if dmgTaken > baseMonster.hp: dmgTaken = baseMonster.hp
	baseMonster.hp -= dmgTaken
	#attackingPawn.damageDealt += dmgTaken
	board.combat_log("[[color=#FDFD97]" + str(attackingPawn.username) + "[/color]] hit [[color=#FEB144]" + str(baseMonster.monsterName) + "[/color]] for " + str("%0.2f" % dmgTaken) + " ([color=#FF6663]" + str(area.attackName) + "[/color])")

	#Monster death procedure
	if baseMonster.hp <= 0:
		var hpToHeal = min(attackingPawn.baseHp - attackingPawn.hp, attackingPawn.baseHp * baseMonster.healPercent)
		if hpToHeal > 0:
			attackingPawn.hp += hpToHeal
			attackingPawn.damageHealed += hpToHeal
			board.combat_log("[[color=#FDFD97]" + str(attackingPawn.username) + "[/color]] healed for " + str("%0.2f" % hpToHeal) + " ([color=#9EE09E]" + str(baseMonster.monsterName) + "[/color])")
		if attackingPawn.item == "treat":
			attackingPawn.get_node("Items").activate_treat(baseMonster.monsterName)
		
		baseMonster.queue_free()
