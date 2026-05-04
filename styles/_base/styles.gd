extends Node

@export var styleCharge: Resource
var activeStyleCharges = []
var basePawn
func _ready() -> void:
	basePawn = get_parent()
	if !basePawn.attacksDisabled:
		# Start style timers
		if basePawn.style == "berserk":
			$BerserkResetTimer.one_shot = true
			$BerserkResetTimer.start(berserkTimerDuration)
		elif basePawn.style == "bully":
			get_parent().get_node("BullyCircle").modulate.a = 0.9
			$BullyResetTimer.one_shot = true
			$BullyResetTimer.start(bullyStackDuration)
			bully_set_pawn_size()
		elif basePawn.style == "mighty":
			$MightyChargeTimer.one_shot = true
			$MightyChargeTimer.start(mightyChargeDuration)
		elif basePawn.style == "slayer":
			add_slayer_charge()

###########
# BERSERK #
###########

var berserkColor = Color.SPRING_GREEN
var berserkHitCount = 0
var berserkHitCap = 5
var berserkSpeedIncrement = 0.1
var berserkTimerDuration = 3.0
func style_berserk_trigger(attackingPawn) -> void:
	var pawn = attackingPawn
	if pawn.style == "berserk":
		var attacker = pawn.get_node("Styles")
		if attacker.berserkHitCount < attacker.berserkHitCap:
			attacker.berserkHitCount += 1
			var newCharge = styleCharge.instantiate()
			newCharge.position = get_parent().position
			newCharge.particleColor = berserkColor
			attacker.get_parent().get_node("AttackContainer").add_child(newCharge)
			attacker.activeStyleCharges.append(newCharge)
			newCharge.get_node("StyleChargeSprite").modulate = berserkColor
		attacker.get_node("BerserkResetTimer").start(attacker.berserkTimerDuration)
		pawn.asp = 1 - attacker.berserkHitCount * attacker.berserkSpeedIncrement
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
var bullyDmgPct = 0.02
var bullyStackDuration = 10
var bullyStackCount = 0
var bullyHitCap = 5
var bullyScaleMod = 0.2
var bullySprintDuration = 1.0
var bullySlowDuration = 1.0
var bullyWeakDuration = 1.0
func add_bully_charge() -> void:
	var newCharge = styleCharge.instantiate()
	newCharge.position = get_parent().position
	newCharge.particleColor = bullyColor
	get_parent().get_node("AttackContainer").add_child(newCharge)
	activeStyleCharges.append(newCharge)
	newCharge.get_node("StyleChargeSprite").modulate = bullyColor
func style_bully_trigger(victim) -> void:
	if !victim.get_collision_layer_value(1) || get_parent().style != "bully": return
	if victim.username == get_parent().username: return
	if !victim.get_node("Status").get_node("VoidStatusTimer").is_stopped(): return
	if bullyStackCount < bullyHitCap:
		bullyStackCount += 1
		var newCharge = styleCharge.instantiate()
		newCharge.particleColor = bullyColor
		get_parent().get_node("AttackContainer").add_child(newCharge)
		activeStyleCharges.append(newCharge)
		newCharge.get_node("StyleChargeSprite").modulate = bullyColor
	bully_set_pawn_size()
	$BullyResetTimer.start(bullyStackDuration)
func _on_bully_reset_timer_timeout() -> void:
	bullyStackCount = 0
	if activeStyleCharges.size() > bullyStackCount:
		for i in activeStyleCharges.size() - bullyStackCount:
			var chargeToDelete = activeStyleCharges.pop_front()
			chargeToDelete.queue_free()
	bully_set_pawn_size()
func bully_set_pawn_size() -> void:
	var bullyScale = Vector2.ONE * (1.0 + bullyScaleMod * bullyStackCount) * 0.5
	get_parent().get_node("BullyCircle").scale = bullyScale
	get_parent().get_node("BullyArea").scale = bullyScale

##########
# MIGHTY #
##########

var mightyColor = Color.RED
var mightyChargeCount = 0
var mightyChargeCap = 5
var mightyChargeAmount = 0.2
var mightyChargeDuration = 2.0
func style_mighty_trigger(attackingPawn, baseHit) -> float:
	var mightyMod = 1
	if attackingPawn.style == "mighty":
		var attacker = attackingPawn.get_node("Styles")
		if attacker.mightyChargeCount > 0:
			mightyMod += attacker.mightyChargeCount * mightyChargeAmount
			attacker.mightyChargeCount = 0
			attacker.get_node("MightyChargeTimer").start(mightyChargeDuration)
		if attacker.activeStyleCharges.size() > 0:
			for i in attacker.activeStyleCharges.size():
				var chargeToDelete = attacker.activeStyleCharges.pop_front()
				chargeToDelete.queue_free()
	var mightyAmt = baseHit * mightyMod - baseHit
	if mightyAmt > 0:
		attackingPawn.get_node("Combat").combat_log("[" + str(attackingPawn.username) + "] gained " + str("%0.2f" % mightyAmt) + " bonus damage (Mighty)")
	return(mightyAmt)
func _on_mighty_charge_timer_timeout() -> void:
	if mightyChargeCount < mightyChargeCap:
		mightyChargeCount += 1
		var newCharge = styleCharge.instantiate()
		newCharge.position = get_parent().position
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
	newCharge.position = get_parent().position
	newCharge.particleColor = slayerColor
	get_parent().get_node("AttackContainer").add_child(newCharge)
	activeStyleCharges.append(newCharge)
	newCharge.get_node("StyleChargeSprite").modulate = slayerColor
func style_slayer_trigger(attackingPawn) -> float:
	#if body.isPersistentSummon == false:
	if attackingPawn.style == "slayer":
		var slayerAmount = (get_parent().baseHp - get_parent().hp) * slayerMultiplier * (attackingPawn.killCount + 1)
		if slayerAmount > 0:
			attackingPawn.get_node("Combat").combat_log("[" + str(attackingPawn.username) + "] gained " + str("%0.2f" % slayerAmount) + " bonus damage (Slayer)")
			return(slayerAmount)
	return(0)
