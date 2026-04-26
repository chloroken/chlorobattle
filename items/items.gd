extends Node2D

# Initialization
var basePawn
var center: Vector2
@export var killbot: PackedScene
@export var diceEffect: PackedScene
@export var mapBlinkEffect: PackedScene
@export var tireAttack: PackedScene
func _ready() -> void:
	basePawn = get_parent()
	center = get_viewport_rect().size / 2.0

	# Check for Pawn items that require action at start of game
	if !basePawn.attacksDisabled:
		if basePawn.item == "antimatter":
			$AntimatterCooldownTimer.one_shot = true
			$AntimatterCooldownTimer.start(randf_range(antimatterCooldownMin, antimatterCooldownMin))
		elif basePawn.item == "flask":
			$FlaskCooldownTimer.start(randf_range(flaskCooldownMin, flaskCooldownMax))
		elif basePawn.item == "tire":
			$TireAttackTimer.start(randf_range(tireCooldownMin, tireCooldownMax))
		elif basePawn.item == "killbot":
			item_spawn_killbot()

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
	print("[" + basePawn.username + "] used [antimatter]")

########
# DICE #
########

var diceSides = 6
func item_check_dice(attackingPawn, baseHit, body) -> float:
	if body.isPersistentSummon == true: return(baseHit)
	if attackingPawn.item != "dice": return(baseHit)
	if randi_range(1, 4) == 1:
		baseHit = item_roll_dice(baseHit, attackingPawn)
	return(baseHit)
func item_roll_dice(baseHit, attackingPawn) -> float:
	var hitMod = 0
	for i in 3:
		var dieRoll = randi_range(1, diceSides)
		var newDie = diceEffect.instantiate()
		attackingPawn.add_child(newDie)
		newDie.global_position = attackingPawn.global_position
		newDie.diceChoice = dieRoll
		hitMod += dieRoll
	baseHit *= 1 + hitMod * 0.1
	print("[" + str(attackingPawn.username) + "] used [dice]: " + str(1.0 + 0.1 * hitMod))
	return(baseHit)

#########
# FLASK #
#########

var flaskDrunkDuration = 5.0
var flaskCooldownMin = 5.0
var flaskCooldownMax = 10.0

func _on_flask_cooldown_timer_timeout() -> void:
	get_parent().get_node("Status").start_drunk(flaskDrunkDuration)
	get_parent().get_node("Status").start_slow(flaskDrunkDuration)
	$FlaskCooldownTimer.start(randf_range(flaskCooldownMin, flaskCooldownMax))

########
# GLUE #
########

var glueSlowDuration = 1.0
var glueStuckChance = 10 # one in x
var glueStuckDuration = 3.0
var glueStuckCooldown = 15.0
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

	print("[" + str(attackingPawn.username) + "] used [glue] on [" + str(basePawn.username) + "]")

###########
# KILLBOT #
###########

func item_spawn_killbot() -> void:
	var newBot = killbot.instantiate()
	basePawn.get_node("AttackContainer").add_child(newBot)
	newBot.global_position = basePawn.global_position
	newBot.follow = basePawn
	newBot.destination = basePawn.global_position
	print("[" + basePawn.username + "] used [killbot]")
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

var mapCooldownMin = 5.0
var mapCooldownMax = 10.0
var mapFlickerMaxRange = 200.0
var mapFlickerRadius = 100.0
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

		# Move Pawn to blink spot
		basePawn.position = blinkPos

		# Get a new destination
		#basePawn.destination = basePawn.new_destination()
		basePawn.direction = basePawn.new_direction()

		# Clear slow and stuck
		get_parent().get_node("Status").stop_slow()
		get_parent().get_node("Status").stop_stuck()

		# Start cooldown
		var mapCooldown = randf_range(mapCooldownMin, mapCooldownMax)
		$MapCooldownTimer.start(mapCooldown)
		newMap.get_node("FizzleTimer").start(mapCooldown)

		# Combat log output
		print("[" + str(basePawn.username) + "] used [map]")
func item_map_blink() -> Vector2:
	var newPos = basePawn.position
	while basePawn.position.distance_to(newPos) < mapFlickerRadius:
		var ranX = randf_range(-mapFlickerMaxRange, mapFlickerMaxRange)
		var ranY = randf_range(-mapFlickerMaxRange, mapFlickerMaxRange)
		newPos = basePawn.position + Vector2(ranX, ranY)
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
		print("[" + str(basePawn.username) + "] used [milkshake]")
		milkshakeUsed = true
		$MilkshakeDelayTimer.start(milkshakeDelay)
		var newMilkshake = basePawn.milkshakeEffect.instantiate()
		add_child(newMilkshake)
		newMilkshake.get_node("FizzleTimer").start(milkshakeDelay)
func _on_milkshake_delay_timer_timeout() -> void:
	basePawn.hp += milkshakePercent * basePawn.baseHp
	print("[" + str(basePawn.username) + "] finished [milkshake]")

##########
# SKATES #
##########

var skateCooldown = 6.0
var skateDuration = 3.0
func item_try_skating() -> void:
	var status = get_parent().get_node("Status")
	if basePawn.item == "skates" && $SkateCooldownTimer.is_stopped():

		status.start_sprint(skateDuration)
		$SkateCooldownTimer.start(skateCooldown)

		# Redirect to "mirror" of destination
		basePawn.direction = -basePawn.position.direction_to(center)
		print("[" + str(basePawn.username) + "] used [skates]")

########
# TIRE #
########

var tireCooldownMin = 5.0
var tireCooldownMax = 10.0
var tireBaseSpeed = 200
var tireBounceCap = 3
var tireSpeedMod = 0.75
var tireDmgBase = 50
var tireDmgMod = 10
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
	get_parent().attackObjects.append(newAttack)
