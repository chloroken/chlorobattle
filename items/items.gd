extends Node2D

var basePawn
var center: Vector2

# Item properties
var antimatterCooldown = 20.0
var antimatterRandomizer = 1.5
var antimatterDuration = 3.0
var diceSides = 6
var glueSlowDuration = 2.0
var glueStuckChance = 10 # one in x
var glueStuckDuration = 5.0
var glueStuckCooldown = 15.0
var mapCooldownDuration = 10.0
var mapFlickerMaxRange = 100.0
var mapFlickerRadius = 100.0
var milkshakeUsed = false
var milkshakeDelay = 5.0
var milkshakeThreshold = 0.10
var milkshakePercent = 0.50
var skateSpeed = 2.0
var skateCooldown = 6.0
var skateDuration = 3.0

func _ready() -> void:
	basePawn = get_parent()
	center = get_viewport_rect().size / 2.0

##################
# ITEM FUNCTIONS #
##################

func _on_antimatter_cooldown_timer_timeout() -> void:
	#var pawnSprite = basePawn.get_node("PawnSprite")
	#pawnSprite.modulate.a = 0.5
	#pawnSprite.modulate.r = 0.0
	#pawnSprite.modulate.b = 0.0
	#pawnSprite.modulate.g = 0.0
	#$AntimatterDurationTimer.start(antimatterDuration)
	var pawnPhaseTimer = basePawn.get_node("Status").get_node("PhaseDurationTimer")
	if pawnPhaseTimer.get_time_left() < antimatterDuration:
		basePawn.get_node("Status").phase_out_pawn(antimatterDuration)
	print("[" + basePawn.username + "] used [antimatter]")

#func _on_antimatter_duration_timer_timeout() -> void:
	#var pawnSprite = basePawn.get_node("PawnSprite")
	#pawnSprite.modulate.a = 1.0
	#pawnSprite.modulate.r = 1.0
	#pawnSprite.modulate.b = 1.0
	#pawnSprite.modulate.g = 1.0
	#$AntimatterCooldownTimer.start(randf_range($AntimatterCooldownTimer.get_wait_time() / antimatterRandomizer, antimatterCooldown))

func item_check_dice(attackingPawn, baseHit) -> float:
	if attackingPawn.item == "dice":
		if randi_range(1, 4) == 1:
			baseHit = item_roll_dice(baseHit, attackingPawn)
	return(baseHit)

func item_roll_dice(baseHit, attackingPawn) -> float:
	var hitMod = 0
	for i in 3:
		var dieRoll = randi_range(1, diceSides)
		var newDie = attackingPawn.diceEffect.instantiate()
		attackingPawn.add_child(newDie)
		newDie.global_position = attackingPawn.global_position
		newDie.diceChoice = dieRoll
		hitMod += dieRoll
	baseHit *= 1 + hitMod * 0.1
	print("[" + str(attackingPawn.username) + "] used [dice]: " + str(1.0 + 0.1 * hitMod))
	return(baseHit)

func item_try_glue(attackingPawn, body) -> void:
	
	# Disqualify ineligible candidates
	if body.isPersistentSummon == true: return
	if attackingPawn.item != "glue": return
	if !$GlueDurationTimer.is_stopped(): return

	# Start up timers
	var status = basePawn.get_node("Status")
	status.get_node("SlowDurationTimer").start(glueSlowDuration)
	status.get_node("SlowEffectTimer").start()
	
	# Stuck mechanic
	if status.get_node("StuckCooldownTimer").is_stopped():
		var diceRoll = randi_range(1, glueStuckChance)
		if diceRoll == 1:
			status.get_node("StuckDurationTimer").start(glueStuckDuration)
			status.get_node("StuckCooldownTimer").start(glueStuckCooldown)
	print("[" + str(attackingPawn.username) + "] used [glue] on [" + str(basePawn.username) + "]")

func item_spawn_killbot() -> void:
	var newBot = basePawn.killbot.instantiate()
	basePawn.get_node("AttackContainer").add_child(newBot)
	newBot.global_position = basePawn.global_position
	newBot.follow = basePawn
	newBot.destination = basePawn.global_position
	print("[" + basePawn.username + "] used [killbot]")

func item_try_map() -> void:
	if basePawn.item == "map" && $MapCooldownTimer.is_stopped():
		var flickerPos = item_map_flicker()
		while flickerPos.distance_to(center) > get_parent().get_parent().boardRadius:
			flickerPos = item_map_flicker()
		var newMapX = basePawn.mapFlickerEffect.instantiate()
		newMapX.position = basePawn.position
		basePawn.get_node("AttackContainer").add_child(newMapX)
		basePawn.position = flickerPos
		$MapCooldownTimer.start(mapCooldownDuration)
		var newMapEffect = basePawn.mapEffect.instantiate()
		add_child(newMapEffect)
		print("[" + str(basePawn.username) + "] used [map]")
		
		newMapEffect.add_line(basePawn.position)
		newMapEffect.add_line(newMapX.position)

		var newMapX2 = basePawn.mapFlickerEffect.instantiate()
		newMapX2.position = basePawn.position
		basePawn.get_node("AttackContainer").add_child(newMapX2)
		
		get_parent().new_destination()

func item_map_flicker() -> Vector2:
	var newPos = basePawn.position
	while basePawn.position.distance_to(newPos) < mapFlickerRadius:
		var ranX = randf_range(-mapFlickerMaxRange, mapFlickerMaxRange)
		var ranY = randf_range(-mapFlickerMaxRange, mapFlickerMaxRange)
		newPos = basePawn.position + Vector2(ranX, ranY)
	return(newPos)

func item_check_milkshake() -> void:
	if basePawn.item == "milkshake" && basePawn.hp < milkshakeThreshold * basePawn.baseHp && !milkshakeUsed:
		print("[" + str(basePawn.username) + "] used [milkshake]")
		milkshakeUsed = true
		$MilkshakeDelayTimer.start(milkshakeDelay)
		var newMilkshake = basePawn.milkshakeEffect.instantiate()
		add_child(newMilkshake)

func _on_milkshake_delay_timer_timeout() -> void:
	basePawn.hp += milkshakePercent * basePawn.baseHp
	print("[" + str(basePawn.username) + "] finished [milkshake]")

func item_try_skating() -> void:
	var status = get_parent().get_node("Status")
	if basePawn.item == "skates" && status.get_node("SprintDurationTimer").get_time_left() < skateDuration && $SkateCooldownTimer.is_stopped():

		status.start_sprinting(skateDuration)
		$SkateCooldownTimer.start(skateCooldown)
		
		#basePawn.spd *= skateSpeed
		basePawn.destination = center - (center + basePawn.destination)
		print("[" + str(basePawn.username) + "] used [skates]")
