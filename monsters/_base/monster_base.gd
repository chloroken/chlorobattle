extends Area2D

var monsterName = ""
var baseHp
var hp 
var healPercent

var spd = 5
var dir: Vector2
var rot

var hitList = []
var center

func _ready() -> void:
	center = get_parent().get_parent().center
	rot = randf_range(0, TAU)
	dir = Vector2.RIGHT.rotated(rot)
	position = get_parent().get_parent().center

	# Set visibility order
	z_as_relative = false
	z_index = get_node("/root/main").layerPawn

func _process(_delta: float) -> void:
	$MonsterSprite.rotation = rot
	$MonsterHpFront.scale.x = hp / baseHp

func _physics_process(delta: float) -> void:
	position += dir * spd * delta
	if position.distance_to(center) > get_parent().get_parent().boardRadius:
		dir = position.direction_to(center)
		rot = dir.angle()

func _on_direction_timer_timeout() -> void:
	rot = randf_range(0, TAU)
	dir = Vector2.RIGHT.rotated(rot)

func _on_area_entered(area: Area2D) -> void:

	# Hit validation
	#if area.areaType != "attack": return
	#if !area.get_collision_layer_value(2): return
	if hitList.has(area): return
	if !area.areaAttack: area.queue_free()
	else: hitList.append(area)

	# Monster damage formula
	var attackingPawn = area.get_parent().get_parent()
	var dmgTaken = area.dmg
	if dmgTaken > hp: dmgTaken = hp
	hp -= dmgTaken
	attackingPawn.damageDealt += dmgTaken
	attackingPawn.combat_log("[" + str(attackingPawn.username) + "] hit [" + str(monsterName) + "] for " + str("%0.2f" % dmgTaken) + " (" + str(area.attackName) + ")")

	#Monster death procedure
	if hp <= 0:
		var hpToHeal = min(attackingPawn.baseHp - attackingPawn.hp, attackingPawn.baseHp * healPercent)
		if hpToHeal > 0:
			attackingPawn.hp += hpToHeal
			attackingPawn.damageHealed += hpToHeal
			attackingPawn.combat_log("[" + str(attackingPawn.username) + "] healed for " + str("%0.2f" % hpToHeal) + " (" + str(monsterName) + ")")
		queue_free()
