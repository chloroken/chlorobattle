extends Node

@export var styleCharge: Resource
var activeStyleCharges = []

###########
# BERSERK #
###########

var berserkColor = Color.SPRING_GREEN
var berserkHitCount = 0
var berserkHitCap = 5
var berserkSpeedIncrement = 0.1
var berserkTimerDuration = 3.0
func style_berserk_trigger(body, attackingPawn) -> void:
	var pawn = attackingPawn
	if body.isPersistentSummon == false:
		if pawn.style == "berserk":
			
			var attacker = pawn.get_node("Styles")
			if attacker.berserkHitCount < attacker.berserkHitCap:
				attacker.berserkHitCount += 1
				var newCharge = styleCharge.instantiate()
				newCharge.particleColor = berserkColor
				attacker.get_parent().get_node("AttackContainer").add_child(newCharge)
				attacker.activeStyleCharges.append(newCharge)
				newCharge.get_node("StyleChargeSprite").modulate = berserkColor
			attacker.get_node("BerserkResetTimer").start(attacker.berserkTimerDuration)
			pawn.asp = 1 - attacker.berserkHitCount * attacker.berserkSpeedIncrement
			pawn.get_node("AttackCooldownTimer").set_wait_time(pawn.baseAttackCooldown * pawn.asp)	
func _on_berserk_reset_timer_timeout() -> void:
	if berserkHitCount > 0:
		berserkHitCount -= 1
		var chargeToDestroy = activeStyleCharges.pop_front()
		chargeToDestroy.queue_free()
	get_parent().asp = 1 - berserkHitCount * berserkSpeedIncrement
	$BerserkResetTimer.start(berserkTimerDuration)


#########
# BULLY #
#########

var bullyColor = Color.HOT_PINK
var bullyDmgPct = 0.1
var bullyStackDuration = 10
var bullyStackCount = 1
var bullyHitCap = 5
var bullyScaleMod = 0.1
var bullyTimerDuration = 2.0
func add_bully_charge() -> void:
	var newCharge = styleCharge.instantiate()
	newCharge.particleColor = bullyColor
	get_parent().get_node("AttackContainer").add_child(newCharge)
	activeStyleCharges.append(newCharge)
	newCharge.get_node("StyleChargeSprite").modulate = bullyColor
func style_bully_trigger(victim) -> void:

	# Avoid hitting self
	if victim.username == get_parent().username: return

	# Sprint & increase size
	get_parent().get_node("Status").start_sprint(bullyStackCount * bullyTimerDuration)
	get_parent().get_node("PawnSprite").scale = Vector2.ONE * (1.0 + bullyScaleMod * bullyStackCount)
	get_parent().get_node("PawnCollider").scale = Vector2.ONE * (1.0 + bullyScaleMod * bullyStackCount)

	# Inflict slow
	victim.get_node("Status").start_slow(bullyStackCount * bullyTimerDuration)
	
	# Extra effects for non-bully victims
	if victim.style != "bully":

		# Hit victim for damage
		var bullyDmg = get_parent().hp * bullyDmgPct * bullyStackCount
		victim.hp -= bullyDmg

		# Inflict timid
		if victim.hp < 1: victim.hp = 1
		victim.get_node("Status").start_timid(bullyStackCount * bullyTimerDuration)

	# Increase stacks & start cooldown
	if bullyStackCount < bullyHitCap:
		bullyStackCount += 1
		var newCharge = styleCharge.instantiate()
		newCharge.particleColor = bullyColor
		get_parent().get_node("AttackContainer").add_child(newCharge)
		activeStyleCharges.append(newCharge)
		newCharge.get_node("StyleChargeSprite").modulate = bullyColor
	$BullyResetTimer.start(bullyStackDuration)
func _on_bully_reset_timer_timeout() -> void:
	bullyStackCount = 1
	if activeStyleCharges.size() > bullyStackCount:
		for i in activeStyleCharges.size() - bullyStackCount:
			var chargeToDelete = activeStyleCharges.pop_front()
			chargeToDelete.queue_free()

##########
# MIGHTY #
##########

var mightyColor = Color.RED
var mightyChargeCount = 0
var mightyChargeCap = 5
var mightyChargeAmount = 0.2
var mightyChargeDuration = 3.0
func style_mighty_trigger(body, attackingPawn, baseHit) -> float:
	
	if body.isPersistentSummon == false:
		if attackingPawn.style == "mighty":
			
			var attacker = attackingPawn.get_node("Styles")
			if attacker.mightyChargeCount > 0:
				baseHit *= 1 + attacker.mightyChargeCount * mightyChargeAmount
				attacker.mightyChargeCount = 0
				attacker.get_node("MightyChargeTimer").start(mightyChargeDuration)
				
			if attacker.activeStyleCharges.size() > 0:
				for i in attacker.activeStyleCharges.size():
					var chargeToDelete = attacker.activeStyleCharges.pop_front()
					chargeToDelete.queue_free()
					
	return(baseHit)
func _on_mighty_charge_timer_timeout() -> void:
	if mightyChargeCount < mightyChargeCap:
		mightyChargeCount += 1
		var newCharge = styleCharge.instantiate()
		newCharge.particleColor = mightyColor
		get_parent().get_node("AttackContainer").add_child(newCharge)
		activeStyleCharges.append(newCharge)
		newCharge.get_node("StyleChargeSprite").modulate = mightyColor
		$MightyChargeTimer.start(mightyChargeDuration)

##########
# SLAYER #
##########

var slayerColor = Color.MEDIUM_PURPLE
var slayerMultiplier = 0.01
func add_slayer_charge() -> void:
	var newCharge = styleCharge.instantiate()
	newCharge.particleColor = slayerColor
	get_parent().get_node("AttackContainer").add_child(newCharge)
	activeStyleCharges.append(newCharge)
	newCharge.get_node("StyleChargeSprite").modulate = slayerColor
func style_slayer_trigger(body, attackingPawn, realHit) -> float:
	if body.isPersistentSummon == false:
		if attackingPawn.style == "slayer":
			var slayerAmount = (get_parent().baseHp - get_parent().hp) * slayerMultiplier * (attackingPawn.killCount + 1)
			realHit += slayerAmount
	return(realHit)
