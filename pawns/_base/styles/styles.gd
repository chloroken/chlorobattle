extends Node

@export var styleCharge: Resource
var activeStyleCharges = []
var basePawn

func _ready() -> void:
	basePawn = get_parent()
	if !basePawn.inLobby:
		set_style_timers()

func set_style_timers() -> void:
	if basePawn.style == "berserk":
		$BerserkResetTimer.one_shot = true
		$BerserkResetTimer.start(berserkTimerDuration)
	elif basePawn.style == "bully":
		$BullyCircle.modulate.a = 0.9
		$BullyResetTimer.one_shot = true
		$BullyResetTimer.start(bullyStackDuration)
		bully_set_pawn_size()
	elif basePawn.style == "burnout":
		$BurnoutDamageTimer.start(burnoutTimerInterval)
	elif basePawn.style == "mighty":
		$MightyChargeTimer.one_shot = true
		$MightyChargeTimer.start(mightyChargeDuration)
	elif basePawn.style == "parkour":
		$ParkourResetTimer.one_shot = true
		$ParkourResetTimer.start(parkourChargeLossTime)
	elif basePawn.style == "slayer":
		$SlayerChargeTimer.one_shot = true
		$SlayerDamageTimer.one_shot = true
	elif basePawn.style == "snowball":
		$SnowballCooldownTimer.one_shot = true
		$SnowballFreeChargeTimer.start(snowballFreeChargeCooldown)

#region BERSERK

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

#endregion

#region BULLY

var bullyColor = Color.HOT_PINK
var bullyDmgPct = 0.02
var bullyStackDuration = 15.0 
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
	#if !victim.get_collision_layer_value(1) || get_parent().style != "bully": return
	#if victim.username == get_parent().username: return
	#if !victim.get_node("Status").get_node("VoidStatusTimer").is_stopped(): return
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
	$BullyCircle.scale = bullyScale
	get_parent().get_node("Combat/Style/BullyArea").scale = bullyScale

#endregion

#region BURNOUT

var burnoutColor = Color.ORANGE
var burnoutChargeCount = 0
var burnoutChargeCap = 5
var burnoutTimerInterval = 1.0
var burnoutHealthThreshold = 0.75
var burnoutHealthInterval = 5.0
var burnoutDamagePercent = 0.15
var burnoutSelfDamagePercent = 0.01

func burnout_update_charges() -> void:
	if basePawn.style != "burnout":
		return
	burnout_set_charges()

func burnout_set_charges() -> void:
	var curHpPercent = basePawn.hp / basePawn.baseHp
	if curHpPercent <= 0.5:
		burnoutChargeCount = 5
	elif curHpPercent <= 0.6:
		burnoutChargeCount = 4
	elif curHpPercent <= 0.7:
		burnoutChargeCount = 3
	elif curHpPercent <= 0.8:
		burnoutChargeCount = 2
	elif curHpPercent <= 0.9:
		burnoutChargeCount = 1
	else:
		burnoutChargeCount = 0
	adjust_charge_orbs(burnoutChargeCount)

func adjust_charge_orbs(count) -> void:
	var curOrbs = activeStyleCharges.size()
	if count > curOrbs:
		for i in count - curOrbs:
			var newCharge = styleCharge.instantiate()
			newCharge.particleColor = burnoutColor
			get_parent().get_node("AttackContainer").add_child(newCharge)
			activeStyleCharges.append(newCharge)
			newCharge.get_node("StyleChargeSprite").modulate = burnoutColor
	if curOrbs > count:
		for i in curOrbs - count:
			var charge = activeStyleCharges.pop_front()
			charge.queue_free()

func _on_burnout_damage_timer_timeout() -> void:
	burnout_update_charges()
	var curHealthPercent = basePawn.hp / basePawn.baseHp
	if curHealthPercent > burnoutHealthThreshold:
		burnout_damage_self()

func burnout_damage_self() -> void:
	var damageToTake = basePawn.hp * burnoutSelfDamagePercent
	basePawn.hp -= damageToTake
	basePawn.board.combat_log("[[color=#FDFD97]" + str(basePawn.username) + "[/color]] took " + str("%0.2f" % damageToTake) + " ([color=#CC99C9]Burnout[/color])")

#endregion

#region PARKOUR

var parkourColor = Color.CORNFLOWER_BLUE
var parkourChargeCount = 0
var parkourChargeCap = 5
var parkourDamagePerCharge = 4
var parkourChargeLossTime = 5.0
var parkourSpeedPerCharge = 0.1
func style_parkour_trigger(attacker) -> float:
	if attacker.style != "parkour": return(0)
	return(attacker.get_node("Styles").parkourChargeCount * attacker.get_node("Styles").parkourDamagePerCharge)
func style_parkour_add_charge() -> void:
	if basePawn.inLobby: return
	if basePawn.style != "parkour": return
	
	# Dont add charges while stuck from an enemy
	if !basePawn.get_node("Status/StuckStatusTimer").is_stopped():
		if basePawn.get_node("Status").stuckPawnSource == get_parent().username:
			return

	parkourChargeCount += 1
	if parkourChargeCount > parkourChargeCap:
		parkourChargeCount = parkourChargeCap
		$ParkourResetTimer.start(parkourChargeLossTime)
		return
	$ParkourResetTimer.start(parkourChargeLossTime)

	var newCharge = styleCharge.instantiate()
	newCharge.position = get_parent().position
	newCharge.particleColor = parkourColor
	get_parent().get_node("AttackContainer").add_child(newCharge)
	activeStyleCharges.append(newCharge)
	newCharge.get_node("StyleChargeSprite").modulate = parkourColor
func style_parkour_remove_charge() -> void:
	if parkourChargeCount > 0:
		parkourChargeCount -= 1
		var chargeToDestroy = activeStyleCharges.pop_front()
		chargeToDestroy.queue_free()
	$ParkourResetTimer.start(parkourChargeLossTime)
func _on_parkour_reset_timer_timeout() -> void:
	style_parkour_remove_charge()
func style_parkour_reset_charges() -> void:
	if basePawn.style != "parkour": return
	parkourChargeCount = 0
	if activeStyleCharges.size() > 0:
		for i in activeStyleCharges.size():
			var chargeToDelete = activeStyleCharges.pop_front()
			chargeToDelete.queue_free()

#endregion

#region MIGHTY

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
		attackingPawn.board.combat_log("[[color=#FDFD97]" + str(attackingPawn.username) + "[/color]] gained " + str("%0.2f" % mightyAmt) + " bonus damage ([color=#CC99C9]Mighty[/color])")
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

#endregion

#region SLAYER

var slayerColor = Color.MEDIUM_PURPLE
var slayerMultiplier = 0.05
var slayerChargeCooldown = 5.0
var slayerChargeMax = 5
var slayerDamageCooldown = 5.0

func add_slayer_charge() -> void:
	if basePawn.style != "slayer":
		return
	if activeStyleCharges.size() >= 5:
		return
	if $SlayerChargeTimer.is_stopped():
		var newCharge = styleCharge.instantiate()
		newCharge.position = get_parent().position
		newCharge.particleColor = slayerColor
		get_parent().get_node("AttackContainer").add_child(newCharge)
		activeStyleCharges.append(newCharge)
		newCharge.get_node("StyleChargeSprite").modulate = slayerColor
		$SlayerChargeTimer.start(slayerChargeCooldown)
	
func style_slayer_trigger(attacker) -> float:
	if attacker.get_node("Styles").get_node("SlayerDamageTimer").is_stopped():
		if attacker.style == "slayer":
			attacker.get_node("Styles").get_node("SlayerDamageTimer").start(slayerDamageCooldown)
			var curHp = get_parent().baseHp - get_parent().hp
			var slayerAmount = curHp * attacker.get_node("Styles").activeStyleCharges.size() * attacker.get_node("Styles").slayerMultiplier
			if slayerAmount > 0:
				attacker.board.combat_log("[[color=#FDFD97]" + str(attacker.username) + "[/color]] gained " + str("%0.2f" % slayerAmount) + " bonus damage ([color=#CC99C9]Slayer[/color])")
				return(slayerAmount)
	return(0)

func slayer_discharge(attacker) -> void:
	if attacker.get_node("Styles").activeStyleCharges.size() > 0:
		for i in attacker.get_node("Styles").activeStyleCharges.size():
			var chargeToDelete = attacker.get_node("Styles").activeStyleCharges.pop_front()
			chargeToDelete.queue_free()

#endregion

#region SNOWBALL

var snowballColor = Color.WHITE
var snowballMultiplier = 0.3
var snowballCooldown = 1.0
var snowballFreeChargeCooldown = 60.0
func add_snowball_charge() -> void:
	if $SnowballCooldownTimer.is_stopped():
		var newCharge = styleCharge.instantiate()
		newCharge.position = get_parent().position
		newCharge.particleColor = snowballColor
		get_parent().get_node("AttackContainer").add_child(newCharge)
		activeStyleCharges.append(newCharge)
		newCharge.get_node("StyleChargeSprite").modulate = snowballColor
		$SnowballCooldownTimer.start(snowballCooldown)
func style_snowball_trigger(baseHit, attacker) -> float:
	if attacker.style == "snowball":
		var bonusDmg = baseHit * attacker.get_node("Styles").activeStyleCharges.size() * attacker.get_node("Styles").snowballMultiplier
		if bonusDmg > 0:
			attacker.board.combat_log("[[color=#FDFD97]" + str(attacker.username) + "[/color]] gained " + str("%0.2f" % bonusDmg) + " bonus damage ([color=#CC99C9]Snowball[/color])")
			return(bonusDmg)
	return(0)
func _on_snowball_free_charge_timer_timeout() -> void:
	var newCharge = styleCharge.instantiate()
	newCharge.position = get_parent().position
	newCharge.particleColor = snowballColor
	get_parent().get_node("AttackContainer").add_child(newCharge)
	activeStyleCharges.append(newCharge)
	newCharge.get_node("StyleChargeSprite").modulate = snowballColor

#endregion
