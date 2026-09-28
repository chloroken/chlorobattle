extends Node2D

var pawn
var spd

func _ready() -> void:
	# Set visibility order
	z_as_relative = false
	z_index = get_node("/root/main").layerAir

func _process(delta: float) -> void:
	position += position.direction_to(pawn.position) * max(spd, position.distance_to(pawn.position)) * delta
	if position.distance_to(pawn.position) < 5:

		if !pawn.demonFormActive:
			var demonTimer = pawn.get_node("DemonCooldownTimer")
			var timeLeft = demonTimer.get_time_left()
			var cooldownReduction = pawn.demonSoulCooldownReduction
			if timeLeft < cooldownReduction: demonTimer.start(0.01)
			else: demonTimer.start(timeLeft - cooldownReduction)

		var amountToHeal = min(pawn.baseHp - pawn.hp, pawn.soulReturnHeal)
		pawn.hp += amountToHeal
		pawn.damageHealed += amountToHeal
		var logOutput = "[[color=#FDFD97]" + str(pawn.username) + "[/color]] healed for " + str("%0.2f" % amountToHeal) + " ([color=#9EE09E]Reaper[/color])"
		pawn.get_parent().combat_log(logOutput)

		queue_free()
