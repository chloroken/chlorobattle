extends Node2D

# Item initialization
var basePawn
var center: Vector2
func _ready() -> void:

	# Useful shortcuts
	basePawn = get_parent()
	center = basePawn.get_parent().center

	# If an Item needs action at start of game, do it here
	if !basePawn.attacksDisabled:
		if basePawn.item == "antimatter":
			$AntimatterDurationTimer.one_shot = true
			$AntimatterCooldownTimer.one_shot = true
			$AntimatterCooldownTimer.start(randf_range(antimatterCooldownMin, antimatterCooldownMin))
		elif basePawn.item == "flask":
			$FlaskCooldownTimer.one_shot = true
			$FlaskCooldownTimer.start(randf_range(flaskCooldownMin, flaskCooldownMax))
		elif basePawn.item == "killbot":
			item_spawn_killbot()
		elif basePawn.item == "milkshake":
			$MilkshakeCooldownTimer.one_shot = true
			$MilkshakeCooldownTimer.start(randf_range(milkshakeCooldownMin, milkshakeCooldownMax))
		elif basePawn.item == "skates":
			$SkateCooldownTimer.one_shot = true
		elif basePawn.item == "smoke":
			$SmokeAttackTimer.one_shot = true
			$SmokeAttackTimer.start(randf_range(smokeThrowCooldownMin, smokeThrowCooldownMax))
		elif basePawn.item == "tire":
			$TireAttackTimer.one_shot = true
			$TireAttackTimer.start(randf_range(tireCooldownMin, tireCooldownMax)) 

##############
# ANTIMATTER #
##############

var antimatterDuration = 3.0
var antimatterCooldownMin = 15.0
var antimatterCooldownMax = 20.0

func _on_antimatter_cooldown_timer_timeout() -> void:
	var pawnVoidTimer = basePawn.get_node("Status").get_node("VoidStatusTimer")
	if pawnVoidTimer.get_time_left() < antimatterDuration:
		basePawn.get_node("Status").start_void(antimatterDuration)
		$AntimatterDurationTimer.start(antimatterDuration)

	var antiMatterCooldown = randf_range(antimatterCooldownMin, antimatterCooldownMax)
	$AntimatterCooldownTimer.start(antiMatterCooldown)

	basePawn.board.combat_log("[" + basePawn.username + "] entered the void (Antimatter)")

func _on_antimatter_duration_timer_timeout() -> void:
	var statusDuration = $AntimatterCooldownTimer.get_time_left()
	var statusChoice = randi_range(1, 5)
	match statusChoice:
		1: basePawn.get_node("Status").start_hazy(statusDuration)
		2: basePawn.get_node("Status").start_lazy(statusDuration)
		3: basePawn.get_node("Status").start_scared(statusDuration)
		4: basePawn.get_node("Status").start_slow(statusDuration)
		5: basePawn.get_node("Status").start_weak(statusDuration)

########
# DICE #
########

@export var diceEffect: PackedScene
var diceSides = 6
var diceDuration = 3.0

func item_check_dice(attackingPawn, baseHit) -> float:
	var dmgToAdd = 0
	#if body.isPersistentSummon == true: return(dmgToAdd)
	if attackingPawn.item != "dice": return(dmgToAdd)
	if randi_range(1, 4) == 1:
		dmgToAdd = item_roll_dice(baseHit, attackingPawn)
	return(dmgToAdd)
	
func item_roll_dice(baseHit, attackingPawn) -> float:
	var hitMod = 0
	for i in 3:
		var dieRoll = randi_range(1, diceSides)
		var newDie = diceEffect.instantiate()
		newDie.diceDuration = diceDuration
		attackingPawn.add_child(newDie)
		newDie.global_position = attackingPawn.global_position
		newDie.diceChoice = dieRoll
		hitMod += dieRoll
	var diceMod = 1.0 + hitMod * 0.1
	basePawn.board.combat_log("[" + str(attackingPawn.username) + "] multiplied damage by " + str(diceMod) + " (Dice)")
	return(baseHit * diceMod - baseHit)

#########
# FLASK #
#########

var flaskDrunkDuration = 5.0
var flaskCooldownMin = 5.0
var flaskCooldownMax = 10.0

@export var flaskThrowEffect: Resource
var flaskThrowDmg = 35
var flaskThrowSpeed = 100

func _on_flask_cooldown_timer_timeout() -> void:
	var pawnStatus = basePawn.get_node("Status")
	pawnStatus.start_drunk(flaskDrunkDuration)
	pawnStatus.start_slow(flaskDrunkDuration)
	var flaskCooldown = randf_range(flaskCooldownMin, flaskCooldownMax)
	$FlaskCooldownTimer.start(flaskCooldown)

	var newFlask = flaskThrowEffect.instantiate()
	newFlask.position = basePawn.position
	newFlask.direction = Vector2.ONE.rotated(randf_range(0, TAU))
	newFlask.speed = flaskThrowSpeed
	newFlask.dmg = flaskThrowDmg
	basePawn.get_node("AttackContainer").add_child(newFlask)
	

########
# GLUE #
########

var glueSlowDuration = 1.0
var glueStuckChance = 10
var glueStuckDuration = 5.0
var glueStuckDamage = 25

func item_try_glue(attackingPawn) -> void:
	if attackingPawn.item != "glue": return

	# Apply slow
	var status = basePawn.get_node("Status")
	status.start_slow(glueSlowDuration)
	basePawn.board.combat_log("[" + str(attackingPawn.username) + "] slowed [" + str(basePawn.username) + "] (Glue)")

	# Chance to apply stuck
	var diceRoll = randi_range(1, glueStuckChance)
	if diceRoll == 1:
		status.start_stuck(glueStuckDuration, attackingPawn)
		var stuckDamage = min(basePawn.hp, glueStuckDamage)
		basePawn.hp -= stuckDamage
		attackingPawn.damageDealt += stuckDamage
		basePawn.board.combat_log("[" + str(attackingPawn.username) + "] stuck [" + str(basePawn.username) + "] for " + str(stuckDamage) + " (Glue)")
	

###########
# KILLBOT #
###########

@export var killbot: PackedScene
var killbotDamage = 10 
var killbotCooldownMin = 2.0
var killbotCooldownMax = 3.0
var killbotSpeed = 50
var killbotStackMax = 3
var killbotStackSize = 0.25 
var killbotStackDamage = 5
var killbotStackAttackSpeed = 25
var killbotStackResetTimer = 10.0
var killbotFollowMin = 20
var killbotFollowMax = 100
var killbotSawDuration = 1.0

func item_spawn_killbot() -> void:
	var newBot = killbot.instantiate()
	newBot.global_position = basePawn.global_position
	newBot.follow = basePawn
	#newBot.destination = basePawn.global_position
	newBot.dmgBase = killbotDamage
	newBot.attackCooldownMin = killbotCooldownMin
	newBot.attackCooldownMax = killbotCooldownMax
	newBot.spd = killbotSpeed
	#newBot.bulletSpd = killbotBulletSpeed
	newBot.killbotMaxStacks = killbotStackMax
	newBot.sizePerStack = killbotStackSize
	newBot.dmgPerStack = killbotStackDamage
	newBot.attackSpeedPerStack = killbotStackAttackSpeed
	newBot.killbotStackTimer = killbotStackResetTimer
	newBot.followDistanceMin = killbotFollowMin
	newBot.followDistanceMax = killbotFollowMax
	basePawn.get_node("AttackContainer").add_child(newBot)

	basePawn.board.combat_log("[" + basePawn.username + "] brought a friend (Killbot)")

func item_try_killbot_stack(attackingPawn, body) -> void:
	if attackingPawn.item != "killbot": return
	if body.killbotParent == null: return
	var dadbot = body.killbotParent
	dadbot.killbotStacks += 1
	dadbot.get_node("KillbotStackTimer").start(dadbot.killbotStackTimer)
	if dadbot.killbotStacks > dadbot.killbotMaxStacks:
		dadbot.killbotStacks = dadbot.killbotMaxStacks

#######
# MAP #
#######

@export var mapBlinkEffect: PackedScene
var mapCooldownMin = 8.0
var mapCooldownMax = 10.0
var mapFlickerRange = 2

@export var mapBombEffect: Resource
var mapBombDuration = 0.1
var mapExplosionDuration = 1.0
var mapExplosionDamage = 25

func item_try_map() -> void:
	if basePawn.item == "map" && $MapCooldownTimer.is_stopped():
		
		# Create a bomb at previous position
		var newBomb = mapBombEffect.instantiate()
		newBomb.position = basePawn.position
		newBomb.duration = mapBombDuration
		newBomb.explosionDuration = mapExplosionDuration
		newBomb.dmg = mapExplosionDamage
		basePawn.get_node("AttackContainer").add_child(newBomb)

		# Get a spot to blink to
		var blinkPos = item_map_blink()
		while blinkPos.distance_to(center) > get_parent().get_parent().boardRadius:
			blinkPos = item_map_blink()

		# Create map effect at blink spot
		var newMap = mapBlinkEffect.instantiate()
		newMap.position = blinkPos
		basePawn.get_node("AttackContainer").add_child(newMap)
		newMap.new_line(basePawn.position)

		# Move Pawn to blink spot & get new direction
		basePawn.position = blinkPos
		basePawn.direction = basePawn.new_direction()

		# Clear slow and stuck
		get_parent().get_node("Status").stop_slow()
		get_parent().get_node("Status").stop_stuck()

		# Start cooldown
		var mapCooldown = randf_range(mapCooldownMin, mapCooldownMax)
		$MapCooldownTimer.start(mapCooldown)
		newMap.get_node("FizzleTimer").start(mapCooldown)

		basePawn.board.combat_log("[" + str(basePawn.username) + "] teleported away (Map)")

func item_map_blink() -> Vector2:
	var newPos = basePawn.position
	var boardRadius = get_parent().get_parent().boardRadius
	while basePawn.position.distance_to(newPos) < boardRadius / mapFlickerRange:
		var ranX = randf_range(-boardRadius, boardRadius)
		var ranY = randf_range(-boardRadius, boardRadius)
		newPos = basePawn.get_parent().center + Vector2(ranX, ranY)
	return(newPos)

#############
# MILKSHAKE #
#############

var milkshakeUsed = false
var milkshakeDelay = 5.0
var milkshakeThreshold = 0.10
var milkshakePercent = 0.25

@export var milkshakeEffect: Resource
@export var milkshakeLure: Resource
var milkshakeCooldownMin = 8.0
var milkshakeCooldownMax = 12.0
var milkshakeLureRange = 96
var milkshakeDuration = 3.0

func _on_milkshake_cooldown_timer_timeout() -> void:
	var newLure = milkshakeLure.instantiate()
	newLure.duration = milkshakeDuration
	newLure.basePawn = basePawn
	newLure.lureRadius = milkshakeLureRange
	newLure.position = basePawn.position
	get_parent().get_node("AttackContainer").add_child(newLure)
	var newEffect = milkshakeEffect.instantiate()
	newEffect.duration = milkshakeDuration
	newEffect.position = basePawn.position
	get_parent().get_node("AttackContainer").add_child(newEffect)
	get_parent().get_node("Status").start_stuck(milkshakeDuration, basePawn)
	get_parent().get_node("Status").start_tanky(milkshakeDuration)
	$MilkshakeCooldownTimer.start(randf_range(milkshakeCooldownMin, milkshakeCooldownMax))

func item_check_milkshake() -> void:
	pass
	if basePawn.item == "milkshake": pass
	#if basePawn.item == "milkshake" && basePawn.hp < milkshakeThreshold * basePawn.baseHp && !milkshakeUsed:
		#basePawn.board.combat_log("[" + str(basePawn.username) + "] used [Milkshake]")
		#milkshakeUsed = true
		#$MilkshakeDelayTimer.start(milkshakeDelay)
		#var newMilkshake = basePawn.milkshakeEffect.instantiate()
		#add_child(newMilkshake)
		#newMilkshake.get_node("FizzleTimer").start(milkshakeDelay)

func _on_milkshake_delay_timer_timeout() -> void:
	pass
	#basePawn.hp += milkshakePercent * basePawn.baseHp
	#basePawn.board.combat_log("[" + str(basePawn.username) + "] finished [Milkshake]")


##########
# SKATES #
##########

@export var skatesBlade: Resource
var skateCooldown = 5.0
var skateDuration = 5.0
var skateBladeDuration = 5.0
var skateDotDuration = 2.0
var skateBladeDamage = 5
var skateBladeCount = 2

func item_try_skating() -> void:
	if basePawn.is_queued_for_deletion(): return
	if basePawn.item == "skates" && $SkateCooldownTimer.is_stopped():

		var status = get_parent().get_node("Status")
		status.start_sprint(skateDuration)
		$SkateCooldownTimer.start(skateCooldown)

		# Redirect to nearest wall
		basePawn.new_direction() # to trigger parkour/styles
		basePawn.direction = -basePawn.position.direction_to(center)
		basePawn.board.combat_log("[" + str(basePawn.username) + "] changed directions (Skates)")

		# Make blades
		for i in skateBladeCount:
			var newBlade = skatesBlade.instantiate()
			newBlade.position = position
			newBlade.duration = skateBladeDuration
			newBlade.dmg = skateBladeDamage
			get_parent().get_node("AttackContainer").add_child(newBlade)

func try_skate_blade(attacker, attack) -> void:
	if attack.isSkateAttack:
		basePawn.get_node("Status").start_bleed(skateDotDuration, attacker)

#########
# SMOKE #
#########

@export var smokeItem: Resource
var smokeDamage = 20
var smokeThrowCooldownMin = 5.0
var smokeThrowCooldownMax = 10.0
var smokeThrowSpeed = 5.0
var smokeThrowDuration = 1.0
var smokeFumeDuration = 5.0
var smokeCloudHazyDuration = 5.0
var smokeBoxLength = 50
var smokeMinLength = 50
var smokeScaleMax = 2.0
func _on_smoke_attack_timer_timeout() -> void:

	var newAttack = smokeItem.instantiate()
	newAttack.position = get_parent().position
	newAttack.destination = good_smoke_destination()
	newAttack.speed = smokeThrowSpeed
	
	get_parent().get_node("AttackContainer").add_child(newAttack)
	$SmokeAttackTimer.start(randf_range(smokeThrowCooldownMin, smokeThrowCooldownMax))

	basePawn.board.combat_log("[" + str(basePawn.username) + "] tossed some chemicals (Smoke)")
func good_smoke_destination() -> Vector2:
	var boardRadius = get_parent().get_parent().boardRadius
	var newOffset = Vector2(randf_range(-smokeBoxLength, smokeBoxLength), randf_range(-smokeBoxLength, smokeBoxLength))
	var newPos = basePawn.position + newOffset
	while center.distance_to(newPos) > boardRadius || basePawn.position.distance_to(newPos) < smokeMinLength:
		newOffset = Vector2(randf_range(-smokeBoxLength, smokeBoxLength), randf_range(-smokeBoxLength, smokeBoxLength))
		newPos = basePawn.position + newOffset
	return(newPos)
func try_smoke_effect(body, attackingPawn) -> bool:
	if body.isSmokeAttack:
		var pawnItems = body.get_parent().get_parent().get_node("Items")
		basePawn.get_node("Status").start_hazy(pawnItems.smokeCloudHazyDuration)
		#basePawn.get_node("Status").start_bleed(pawnItems.smokeCloudHazyDuration, attackingPawn)
	return(false)

########
# TIRE #
########

@export var tireAttack: PackedScene
var tireCooldownMin = 5.0
var tireCooldownMax = 10.0
var tireBaseSpeed = 200
var tireBounceCap = 3
var tireSpeedMod = 0.75
var tireDmgBase = 30
var tireDmgMod = 5
var tireStuckDuration = 3.0

func item_try_tire(attackingPawn) -> void:
	if attackingPawn.item != "tire": return
	else:
		attackingPawn.get_node("TireAttackTimer").start(randf_range(attackingPawn.tireCooldownMin, attackingPawn.tireCooldownMax))

func _on_tire_attack_timer_timeout() -> void:
	var newAttack = tireAttack.instantiate()
	newAttack.position = get_parent().position
	newAttack.speed = tireBaseSpeed
	newAttack.attackName = "Tire"
	newAttack.stuckDuration = tireStuckDuration
	get_parent().get_node("AttackContainer").add_child(newAttack)

	basePawn.board.combat_log("[" + str(basePawn.username) + "] lost a wheel (Tire)")

func try_tire_stuck(attack) -> void:
	if attack.isTireAttack:
		basePawn.get_node("Status").start_stuck(attack.stuckDuration, attack.get_parent().get_parent())
		var randomCooldown = randf_range(tireCooldownMin, tireCooldownMax)
		var attackingPawnItems = attack.get_parent().get_parent().get_node("Items")
		attackingPawnItems.get_node("TireAttackTimer").start(randomCooldown)
