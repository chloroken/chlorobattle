extends Node2D

var basePawn
var spd
var minDist = 5

func _ready() -> void:
	z_index = get_node("/root/main").layerAir

func _physics_process(delta: float) -> void:
	position += position.direction_to(basePawn.position) * max(spd, position.distance_to(basePawn.position)) * delta
	if position.distance_to(basePawn.position) < minDist:
		reaper_cooldown_reduction_effect()
		reaper_heal_effect()
		queue_free()

func reaper_cooldown_reduction_effect() -> void:
	if !basePawn.unleashFormActive:
		var demonTimer = basePawn.get_node("UnleashCooldownTimer")
		var timeLeft = demonTimer.get_time_left()
		var cooldownReduction = basePawn.unleashSoulCooldownReduction
		if timeLeft < cooldownReduction: demonTimer.start(0.01)
		else: demonTimer.start(timeLeft - cooldownReduction)

func reaper_heal_effect() -> void:
	var amountToHeal = min(basePawn.baseHp - basePawn.hp, basePawn.soulReturnHeal)
	basePawn.hp += amountToHeal
	basePawn.damageHealed += amountToHeal
	var logOutput = "[[color=#FDFD97]" + str(basePawn.username) + "[/color]] healed for " + str("%0.2f" % amountToHeal) + " ([color=#9EE09E]Reaper[/color])"
	basePawn.get_parent().combat_log(logOutput)
