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
			$AntimatterCooldownTimer.one_shot = true
			$AntimatterCooldownTimer.start(randf_range(antimatterCooldownMin, antimatterCooldownMin))
		elif basePawn.item == "flask":
			$FlaskCooldownTimer.start(randf_range(flaskCooldownMin, flaskCooldownMax))
		elif basePawn.item == "killbot":
			item_spawn_killbot()
		elif basePawn.item == "potion":
			$PotionAttackTimer.start(randf_range(potionThrowCooldownMin, potionThrowCooldownMax))
		elif basePawn.item == "tire":
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

	var antiMatterCooldown = randf_range(antimatterCooldownMin, antimatterCooldownMax)
	$AntimatterCooldownTimer.start(antiMatterCooldown)

	basePawn.combat_log("[" + basePawn.username + "] entered the void (Antimatter)")

########
# DICE #
########

@export var diceEffect: PackedScene
var diceSides = 6
var diceDuration = 3.0

func item_check_dice(attackingPawn, baseHit, body) -> float:
	var dmgToAdd = 0
	if body.isPersistentSummon == true: return(dmgToAdd)
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
	basePawn.combat_log("[" + str(attackingPawn.username) + "] multiplied damage by " + str(diceMod) + " (Dice)")
	return(baseHit * diceMod - baseHit)

#########
# FLASK #
#########

var flaskDrunkDuration = 5.0
var flaskCooldownMin = 5.0
var flaskCooldownMax = 10.0

func _on_flask_cooldown_timer_timeout() -> void:
	var pawnStatus = basePawn.get_node("Status")
	pawnStatus.start_drunk(flaskDrunkDuration)
	pawnStatus.start_slow(flaskDrunkDuration)
	var flaskCooldown = randf_range(flaskCooldownMin, flaskCooldownMax)
	$FlaskCooldownTimer.start(flaskCooldown)

########
# GLUE #
########

var glueSlowDuration = 1.0
var glueStuckChance = 10
var glueStuckDuration = 5.0

func item_try_glue(attackingPawn, body) -> void:

	# Disqualify ineligible candidates
	if body.isPersistentSummon == true: return
	if attackingPawn.item != "glue": return
	if !$GlueDurationTimer.is_stopped(): return

	# Apply slow
	var status = basePawn.get_node("Status")
	status.start_slow(glueSlowDuration)

	# Chance to apply stuck
	var diceRoll = randi_range(1, glueStuckChance)
	if diceRoll == 1: status.start_stuck(glueStuckDuration)

	basePawn.combat_log("[" + str(attackingPawn.username) + "] stuck [" + str(basePawn.username) + "] (Glue)")

###########
# KILLBOT #
###########

@export var killbot: PackedScene
var killbotDamage = 10
var killbotCooldown = 0.5
var killbotSpeed = 75
var killbotBulletSpeed = 100
var killbotStackMax = 3
var killbotStackSize = 0.5
var killbotStackDamage = 5
var killbotStackAttackSpeed = 25
var killbotStackResetTimer = 5.0
var killbotFollowMin = 20
var killbotFollowMax = 100

func item_spawn_killbot() -> void:
	var newBot = killbot.instantiate()
	newBot.global_position = basePawn.global_position
	newBot.follow = basePawn
	newBot.destination = basePawn.global_position
	newBot.dmgBase = killbotDamage
	newBot.attackCooldown = killbotCooldown
	newBot.spd = killbotSpeed
	newBot.bulletSpd = killbotBulletSpeed
	newBot.killbotMaxStacks = killbotStackMax
	newBot.sizePerStack = killbotStackSize
	newBot.dmgPerStack = killbotStackDamage
	newBot.attackSpeedPerStack = killbotStackAttackSpeed
	newBot.killbotStackTimer = killbotStackResetTimer
	newBot.followDistanceMin = killbotFollowMin
	newBot.followDistanceMax = killbotFollowMax
	basePawn.get_node("AttackContainer").add_child(newBot)

	basePawn.combat_log("[" + basePawn.username + "] brought a friend (Killbot)")

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
var mapCooldownMin = 4.0
var mapCooldownMax = 6.0
var mapFlickerRange = 2

func item_try_map() -> void:
	if basePawn.item == "map" && $MapCooldownTimer.is_stopped():

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

		basePawn.combat_log("[" + str(basePawn.username) + "] teleported away (Map)")

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

func item_check_milkshake() -> void:
	if basePawn.item == "milkshake" && basePawn.hp < milkshakeThreshold * basePawn.baseHp && !milkshakeUsed:
		basePawn.combat_log("[" + str(basePawn.username) + "] used [Milkshake]")
		milkshakeUsed = true
		$MilkshakeDelayTimer.start(milkshakeDelay)
		var newMilkshake = basePawn.milkshakeEffect.instantiate()
		add_child(newMilkshake)
		newMilkshake.get_node("FizzleTimer").start(milkshakeDelay)

func _on_milkshake_delay_timer_timeout() -> void:
	basePawn.hp += milkshakePercent * basePawn.baseHp
	basePawn.combat_log("[" + str(basePawn.username) + "] finished [Milkshake]")


##########
# POTION #
##########

@export var potionItem: Resource
var potionDamage = 10
var potionThrowCooldownMin = 5.0
var potionThrowCooldownMax = 10.0
var potionThrowSpeed = 5.0
var potionThrowDuration = 1.0
var potionFumeDuration = 10.0
var potionFumeDotDuration = 10.0
var potionFumeSlowDuration = 5.0
var potionFumeStuckDuration = 1.0
var potionBoxLength = 50
var potionMinLength = 50
var potionScaleMax = 2.0
func _on_potion_attack_timer_timeout() -> void:

	var newAttack = potionItem.instantiate()
	newAttack.position = get_parent().position
	newAttack.destination = good_potion_destination()
	newAttack.speed = potionThrowSpeed
	
	get_parent().get_node("AttackContainer").add_child(newAttack)
	$PotionAttackTimer.start(randf_range(potionThrowCooldownMin, potionThrowCooldownMax))

	basePawn.combat_log("[" + str(basePawn.username) + "] tossed some chemicals (Potion)")
func good_potion_destination() -> Vector2:
	var boardRadius = get_parent().get_parent().boardRadius
	var newOffset = Vector2(randf_range(-potionBoxLength, potionBoxLength), randf_range(-potionBoxLength, potionBoxLength))
	var newPos = basePawn.position + newOffset
	while center.distance_to(newPos) > boardRadius || basePawn.position.distance_to(newPos) < potionMinLength:
		newOffset = Vector2(randf_range(-potionBoxLength, potionBoxLength), randf_range(-potionBoxLength, potionBoxLength))
		newPos = basePawn.position + newOffset
	return(newPos)
func try_potion_effect(body, attackingPawn) -> bool:
	if body.isPotionAttack:
		var pawnItems = body.get_parent().get_parent().get_node("Items")
		if body.isMixedUp:
			var amountToHeal = min(basePawn.baseHp - basePawn.hp, basePawn.baseHp * 0.1)
			basePawn.hp += amountToHeal
			basePawn.damageHealed += amountToHeal

			var logOutput = "[" + str(attackingPawn.username) + "] healed [" + str(basePawn.username) + "] for " + str(int(amountToHeal)) + " (Vial)"
			basePawn.combat_log(logOutput)
			return(true)
		else:
			basePawn.get_node("Status").start_dot(pawnItems.potionFumeDotDuration, attackingPawn)
			basePawn.get_node("Status").start_slow(pawnItems.potionFumeSlowDuration)
			basePawn.get_node("Status").start_stuck(pawnItems.potionFumeStuckDuration)
	return(false)

##########
# SKATES #
##########

var skateCooldown = 5.0
var skateDuration = 5.0

func item_try_skating() -> void:
	var status = get_parent().get_node("Status")
	if basePawn.item == "skates" && $SkateCooldownTimer.is_stopped():

		status.start_sprint(skateDuration)
		$SkateCooldownTimer.start(skateCooldown)

		# Redirect to nearest wall
		basePawn.direction = -basePawn.position.direction_to(center)
		basePawn.combat_log("[" + str(basePawn.username) + "] changed directions (Skates)")

########
# TIRE #
########

@export var tireAttack: PackedScene
var tireCooldownMin = 5.0
var tireCooldownMax = 10.0
var tireBaseSpeed = 200
var tireBounceCap = 3
var tireSpeedMod = 0.75
var tireDmgBase = 25
var tireDmgMod = 5
var tireStuckDuration = 1.0

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

	basePawn.combat_log("[" + str(basePawn.username) + "] lost a wheel (Tire)")

func try_tire_stuck(body) -> void:
	if body.isTireAttack:
		basePawn.get_node("Status").start_stuck(body.stuckDuration)
