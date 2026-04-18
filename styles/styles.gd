extends Node

# Style properties
var berserkHitCount = 0
var berserkHitCap = 5
var berserkSpeedIncrement = 0.1
var berserkTimerDuration = 3.0
var mightyChargeCount = 0
var mightyChargeCap = 5
var mightyChargeAmount = 0.1
var mightyChargeDuration = 1.0
var slayerMultiplier = 0.01

###################
# STYLE MECHANICS #
###################

func style_berserk_trigger(body, attackingPawn) -> void:
	var pawn = attackingPawn
	if body.isPersistentSummon == false:
		if pawn.style == "berserk":
			var attacker = pawn.get_node("Styles")
			attacker.berserkHitCount += 1
			if attacker.berserkHitCount > attacker.berserkHitCap:
				attacker.berserkHitCount = attacker.berserkHitCap
			attacker.get_node("BerserkResetTimer").start(attacker.berserkTimerDuration)
			pawn.asp = 1 - attacker.berserkHitCount * attacker.berserkSpeedIncrement
			pawn.get_node("AttackCooldownTimer").set_wait_time(pawn.baseAttackCooldown * pawn.asp)	

func _on_berserk_reset_timer_timeout() -> void:
	if berserkHitCount > 0:
		berserkHitCount -= 1
	get_parent().asp = 1 - berserkHitCount * berserkSpeedIncrement

func style_mighty_trigger(body, attackingPawn, baseHit) -> float:
	if body.isPersistentSummon == false:
		if attackingPawn.style == "mighty":
			var attacker = attackingPawn.get_node("Styles")
			if attacker.mightyChargeCount > 0:
				baseHit *= 1 + attacker.mightyChargeCount * mightyChargeAmount
				attacker.mightyChargeCount = 0
				attacker.get_node("MightyChargeTimer").start(mightyChargeDuration)
	return(baseHit)

func _on_mighty_charge_timer_timeout() -> void:
	mightyChargeCount += 1
	if mightyChargeCount > mightyChargeCap:
		mightyChargeCount = mightyChargeCap

func style_slayer_trigger(body, attackingPawn, realHit) -> float:
	if body.isPersistentSummon == false:
		if attackingPawn.style == "slayer":
			var slayerAmount = (get_parent().baseHp - get_parent().hp) * slayerMultiplier * (attackingPawn.killCount + 1)
			realHit += slayerAmount
	return(realHit)
