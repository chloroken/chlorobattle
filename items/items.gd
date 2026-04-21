extends Node2D

# Initialization
var basePawn
var center: Vector2
func _ready() -> void:
	basePawn = get_parent()
	center = get_viewport_rect().size / 2.0

##############
# ANTIMATTER #
##############


var antimatterDuration = 3.0
var antimatterCooldownMin = 15.0
var antimatterCooldownMax = 20.0

func _on_antimatter_cooldown_timer_timeout() -> void:
	var pawnPhaseTimer = basePawn.get_node("Status").get_node("PhaseStatusTimer")
	if pawnPhaseTimer.get_time_left() < antimatterDuration:
		basePawn.get_node("Status").start_phase(antimatterDuration)

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
		var newDie = attackingPawn.diceEffect.instantiate()
		attackingPawn.add_child(newDie)
		newDie.global_position = attackingPawn.global_position
		newDie.diceChoice = dieRoll
		hitMod += dieRoll
	baseHit *= 1 + hitMod * 0.1
	print("[" + str(attackingPawn.username) + "] used [dice]: " + str(1.0 + 0.1 * hitMod))
	return(baseHit)

########
# GLUE #
########

var glueSlowDuration = 2.0
var glueStuckChance = 10 # one in x
var glueStuckDuration = 5.0
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
	var newBot = basePawn.killbot.instantiate()
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

var mapCooldownDuration = 10.0
var mapFlickerMaxRange = 200.0
var mapFlickerRadius = 100.0
func item_try_map() -> void:
	if basePawn.item == "map" && $MapCooldownTimer.is_stopped():

		# Get a spot to blink to
		var blinkPos = item_map_blink()
		while blinkPos.distance_to(center) > get_parent().get_parent().boardRadius:
			blinkPos = item_map_blink()

		# Create map effect at blink spot
		var newMap = basePawn.mapBlinkEffect.instantiate()
		newMap.position = blinkPos
		basePawn.get_node("AttackContainer").add_child(newMap)
		newMap.new_line(basePawn.position)

		# Move Pawn to blink spot
		basePawn.position = blinkPos

		# Get a new destination
		basePawn.destination = basePawn.new_destination()

		# Start cooldown
		$MapCooldownTimer.start(mapCooldownDuration)
		newMap.get_node("FizzleTimer").start(mapCooldownDuration)

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

var skateSpeed = 2.0
var skateCooldown = 6.0
var skateDuration = 3.0
func item_try_skating() -> void:
	var status = get_parent().get_node("Status")
	if basePawn.item == "skates" && status.get_node("SprintStatusTimer").get_time_left() < skateDuration && $SkateCooldownTimer.is_stopped():

		status.start_sprint(skateDuration)
		$SkateCooldownTimer.start(skateCooldown)

		basePawn.destination = center - (center + basePawn.destination)
		print("[" + str(basePawn.username) + "] used [skates]")

########
# TIRE #
########

var tireCooldownMin = 5.0
var tireCooldownMax = 10.0
var tireBaseSpeed = 200
var tireBounceCap = 3
var tireSpeedMod = 0.75
var tireDmgBase = 100
var tireDmgMod = 25
func item_try_tire(attackingPawn) -> void:
	if attackingPawn.item != "tire": return
	else:
		attackingPawn.get_node("TireAttackTimer").start(randf_range(attackingPawn.tireCooldownMin, attackingPawn.tireCooldownMax))
func _on_tire_attack_timer_timeout() -> void:
	var newAttack = get_parent().tireAttack.instantiate()
	newAttack.position = get_parent().position
	newAttack.destination = get_parent().destination
	newAttack.speed = tireBaseSpeed
	get_parent().get_node("AttackContainer").add_child(newAttack)
	get_parent().attackObjects.append(newAttack)
