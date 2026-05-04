extends Node

var baseMonster
var hitList

func _ready() -> void:
	baseMonster = get_parent()
	hitList = baseMonster.hitList

func monster_hit(area) -> void:
	# Hit validation
	if !area.get_collision_layer_value(2): return
	if hitList.has(area): return
	if !area.areaAttack: area.queue_free()
	else: hitList.append(area)

	# Monster damage formula
	var attackingPawn = area.get_parent().get_parent()
	var dmgTaken = area.dmg
	if dmgTaken > baseMonster.hp: dmgTaken = baseMonster.hp
	baseMonster.hp -= dmgTaken
	attackingPawn.damageDealt += dmgTaken
	attackingPawn.get_node("Combat").combat_log("[" + str(attackingPawn.username) + "] hit [" + str(baseMonster.monsterName) + "] for " + str("%0.2f" % dmgTaken) + " (" + str(area.attackName) + ")")

	#Monster death procedure
	if baseMonster.hp <= 0:
		var hpToHeal = min(attackingPawn.baseHp - attackingPawn.hp, attackingPawn.baseHp * baseMonster.healPercent)
		if hpToHeal > 0:
			attackingPawn.hp += hpToHeal
			attackingPawn.damageHealed += hpToHeal
			attackingPawn.get_node("Combat").combat_log("[" + str(attackingPawn.username) + "] healed for " + str("%0.2f" % hpToHeal) + " (" + str(baseMonster.monsterName) + ")")
		baseMonster.queue_free()
