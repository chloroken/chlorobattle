extends Area2D

# Pawn properties
@export var username: String
@export var type: String
@export var style: String
@export var item: String

# Pawn stats
@export var size: float
@export var hp: float
@export var dmg: float
@export var asp: float
@export var pen: float
@export var def: float
@export var spd: float

# Item scenes
@export var tombstone: PackedScene
@export var killbot: PackedScene
@export var glueEffect: PackedScene
@export var diceEffect: PackedScene
@export var mapEffect: PackedScene
@export var milkshakeEffect: PackedScene
@export var skateEffect: PackedScene

# Back end Pawn properties & variables
var center: Vector2
var nameCharLimit = 9
var attackObjects = []
var hitList = []
var attacksDisabled = false
var destination: Vector2
var baseHp
var damageTaken = 0
var damageDealt = 0
var killCount = 0
var baseAttackCooldown

# Style properties
var berserkHitCount = 0
var berserkHitCap = 5
var berserkSpeedIncrement = 0.1
var berserkTimerDuration = 3.0
var mightyChargeCount = 0
var mightyChargeCap = 5
var mightyChargeAmount = 0.2
var mightyChargeDuration = 2.0
var slayerMultiplier = 0.01

# Item properties
var antimatterCooldown = 20.0
var antimatterRandomizer = 1.5
var antimatterDuration = 3.0
var diceSides = 6
var milkshakeUsed = false
var milkshakeDelay = 5.0
var milkshakeThreshold = 0.10
var milkshakePercent = 0.50
var skateSpeed = 2.0

##################
# INITIALIZATION #
##################

func _ready() -> void:
	
	# Snapshot some variables and set Pawn's initial destination
	center = get_viewport_rect().size / 2.0
	baseHp = hp
	baseAttackCooldown = $AttackCooldownTimer.get_wait_time()

	# Adjust sprite dimensions
	$PawnSprite.scale *= size
	$PawnCollider.scale *= size

	# Pawn startup procedure
	destination = new_destination()
	if attacksDisabled:
		# Disable attacks in Lobby for show purposes
		$AttackCooldownTimer.stop()
		$HitpointLabel.visible = false
		$HitpointLabelBlack.visible = false
		$HitpointLabelRed.visible = false
		$HitpointLabelGreen.visible = false
		
	elif !attacksDisabled:
		# Check for Pawn items that require action now
		if item == "antimatter":
			$AntimatterCooldownTimer.start(randf_range($AntimatterCooldownTimer.get_wait_time() / antimatterRandomizer, antimatterCooldown))
		elif item == "killbot":
			item_spawn_killbot()

		# Start style timers
		if style == "berserk":
			$BerserkResetTimer.set_wait_time(berserkTimerDuration)
			$BerserkResetTimer.start()
		elif style == "mighty":
			$MightyChargeTimer.set_wait_time(mightyChargeDuration)
			$MightyChargeTimer.start()

		# Start attacking
		$AttackCooldownTimer.start(baseAttackCooldown)

#######
# GUI #
#######

func _process(_delta: float) -> void:
	
	# Update Pawn name
	$NameLabel.text = username.substr(0, nameCharLimit)

	# Update Pawn hp bar
	$HitpointLabel.text = str(int(ceil(hp)))
	$HitpointLabelGreen.scale.x = hp / baseHp
	
	# Update style indicators
	var styleIndicator = ""
	if style == "berserk":
		for i in int(berserkHitCount):
			styleIndicator += "•"
		$StyleLabel.add_theme_color_override("default_color", Color(0.0, 1.0, 0.5, 1.0))
	elif style == "mighty":
		for i in int(mightyChargeCount):
			styleIndicator += "•"
		$StyleLabel.add_theme_color_override("default_color", Color.RED)
	elif style == "slayer":
		styleIndicator += "•"
		for i in int(killCount):
			styleIndicator += "•"
		$StyleLabel.add_theme_color_override("default_color", Color(0.0, 0.5, 1.0, 1.0))
		#styleIndicator = str(killCount + 1)
	$StyleLabel.text = styleIndicator
	
func update_scoreboard(mainBoard, pawn, pawnIndex, last) -> void:
	var newScore = mainBoard.Pawn.new()
	newScore.username = pawn.username
	newScore.type = pawn.type
	newScore.style = pawn.style
	newScore.item = pawn.item
	newScore.damageTaken = pawn.damageTaken
	newScore.damageDealt = pawn.damageDealt
	newScore.killCount = pawn.killCount
	mainBoard.scoreList.push_front(newScore)
	if !last: mainBoard.pawnList.remove_at(pawnIndex)

###########
# PHYSICS #
###########

func _physics_process(delta: float) -> void:
	
	# Pawn movement
	var distFromDesto = global_position.distance_to(destination)
	var distFromCenter = global_position.distance_to(center)
	var boardRadius = get_parent().boardRadius
	if distFromDesto < 10 || distFromCenter >= boardRadius:
		destination = new_destination()
	global_position = global_position.move_toward(destination, spd * delta)
	
	# Disable Phasing
	if !$PhaseOutTimer.is_stopped():
		set_collision_mask_value(1, false)

# Calculate a new place for Pawn to go
func new_destination() -> Vector2:
	var radius = get_parent().boardRadius
	var rando = ((Vector2.RIGHT * radius).rotated(randf_range(0, TAU)))
	var desto = center + rando

	# Avoid picking a location too close
	while global_position.distance_to(desto) < radius:
		desto = new_destination()
	return(desto)

# Turn collision back on after phasing in
func _on_phase_out_timer_timeout() -> void:
	set_collision_mask_value(1, true)

####################
# COMBAT MECHANICS #
####################

# When a Pawn gets hit by an attack
func _on_body_entered(body: Node2D) -> void:
	
	# Get information about the aggressor
	var attackingPawn = body.get_parent().get_parent()
	var attackerUsername = attackingPawn.username
	
	# Avoid self-hits & subsequent hits from area attacks
	if attackerUsername != username && !hitList.has(body):

		# Berserk attack speed ramping mechanic
		style_berserk_trigger(body, attackingPawn)

		# Hit procedure
		calculate_damage(attackingPawn, attackerUsername, body)
		if !body.areaAttack: body.queue_free()
		else: hitList.append(body)
		item_try_skating()
		item_try_map()
		item_try_glue(attackingPawn)

	# Check for Pawn death
	if hp <= 0:
		var pawns = get_parent().get_parent().pawnList
		for i in range(0, pawns.size()):
			if pawns[i].username == username:
				attackingPawn.killCount += 1
				pawn_death(attackingPawn, attackerUsername, i)
				break

	# Check for item triggers
	item_check_milkshake()
	item_skate_effect()
	item_glue_effect()

func calculate_damage(attackingPawn, attackerUsername, body) -> void:
	
	# Set up default hit
	var baseHit = body.dmg
	var hitText = "hit"

	# Crit mechanics
	var diceHit = item_check_dice(attackingPawn, baseHit)
	if diceHit > baseHit: hitText = "crit"
	baseHit = diceHit
 
	# Adjust hit if Mighty goes off
	baseHit = style_mighty_trigger(body, attackingPawn, baseHit)
	
	# Damage formula
	var baseDefendedHit = baseHit * self.def
	var actualDefended = baseDefendedHit * (1.0 - attackingPawn.pen)
	var realHit = (baseHit - actualDefended)

	# Slayer defence-bypassing percentage-damage mechanic
	realHit = style_slayer_trigger(body, attackingPawn, realHit)

	# Calculate global ramp-up damage reduction
	var finalHit = realHit * (get_parent().globalDmgMod / get_parent().dmgModDuration)
	
	# Apply damage
	self.hp -= finalHit
	
	# Update score
	damageTaken += finalHit
	attackingPawn.damageDealt += finalHit
	get_parent().update_combat_log("[" + str(attackerUsername) + "] " + str(hitText) + " [" + str(self.username) + "] for " + "%0.2f" % finalHit + " dmg") #— [" + "%0.2f" % baseHit + " - " + "%0.2f" % mitigated + " + " + "%0.2f" % (mitigated - penetrated) + "]")
	
	# Combat log backend
	print("[" + str(attackerUsername) + "] " + str(hitText) + " [" + str(self.username) + "] for " + "%0.2f" % finalHit + " dmg")

func pawn_death(attackingPawn, killer: String, pawnIndex: int) -> void:
	
	# Create a tombstone
	var mainBoard = get_parent().get_parent()
	var newTombstone = tombstone.instantiate()
	newTombstone.global_position = global_position
	newTombstone.username = username
	get_parent().add_child(newTombstone)
	print("[" + str(username) + "] was killed by [" + str(killer) + "]")

	# Save progress & destroy self
	update_scoreboard(mainBoard, self, pawnIndex, false)
	get_parent().update_kill_feed("[" + str(killer) + "] eliminated [" + str(username) + "]")
	self.queue_free()

	# For last Pawn, make order exception to transition to scoreboard
	if mainBoard.pawnList.size() <= 1:
		update_scoreboard(mainBoard, attackingPawn, pawnIndex, true)

# Clean up Pawn attacks & effects after death
func _on_tree_exiting() -> void:
	for attack in attackObjects:
		if attack != null:
			attack.queue_free()

# A small float for breaking timing ties
func random_variance() -> float:
	return(randf_range(0.0001, 0.001))

###################
# STYLE MECHANICS #
###################

func style_berserk_trigger(body, attackingPawn) -> void:
	if body.isPersistentSummon == false:
		if attackingPawn.style == "berserk":
			attackingPawn.berserkHitCount += 1
			if attackingPawn.berserkHitCount > attackingPawn.berserkHitCap:
				attackingPawn.berserkHitCount = attackingPawn.berserkHitCap
			$BerserkResetTimer.start(berserkTimerDuration)
			attackingPawn.asp = 1 - attackingPawn.berserkHitCount * attackingPawn.berserkSpeedIncrement
			attackingPawn.get_node("AttackCooldownTimer").set_wait_time(attackingPawn.baseAttackCooldown * attackingPawn.asp)	

func _on_berserk_reset_timer_timeout() -> void:
	berserkHitCount = 0
	asp = 1
	
func style_mighty_trigger(body, attackingPawn, baseHit) -> float:
	if body.isPersistentSummon == false:
		if attackingPawn.style == "mighty":
			if attackingPawn.mightyChargeCount > 0:
				baseHit *= 1 + attackingPawn.mightyChargeCount * attackingPawn.mightyChargeAmount
				attackingPawn.mightyChargeCount = 0
				attackingPawn.get_node("MightyChargeTimer").start(attackingPawn.mightyChargeDuration)
	return(baseHit)

func _on_mighty_charge_timer_timeout() -> void:
	mightyChargeCount += 1
	if mightyChargeCount > mightyChargeCap:
		mightyChargeCount = mightyChargeCap

func style_slayer_trigger(body, attackingPawn, realHit) -> float:
	if body.isPersistentSummon == false:
		if attackingPawn.style == "slayer":
			var slayerAmount = baseHp * slayerMultiplier * (attackingPawn.killCount + 1)
			realHit += slayerAmount
	return(realHit)

##################
# ITEM FUNCTIONS #
##################

func _on_antimatter_cooldown_timer_timeout() -> void:
	$PawnSprite.modulate.a = 0.5
	$PawnSprite.modulate.r = 0.0
	$PawnSprite.modulate.b = 0.0
	$PawnSprite.modulate.g = 0.0
	$AntimatterDurationTimer.start(antimatterDuration)
	if $PhaseOutTimer.get_time_left() < antimatterDuration:
		$PhaseOutTimer.start(antimatterDuration)
	print("[" + username + "] used [antimatter]")

func _on_antimatter_duration_timer_timeout() -> void:
	$PawnSprite.modulate.a = 1.0
	$PawnSprite.modulate.r = 1.0
	$PawnSprite.modulate.b = 1.0
	$PawnSprite.modulate.g = 1.0
	$AntimatterCooldownTimer.start(randf_range($AntimatterCooldownTimer.get_wait_time() / antimatterRandomizer, antimatterCooldown))

func item_check_dice(attackingPawn, baseHit) -> float:
	if attackingPawn.item == "dice":
		if randi_range(1, 4) == 1:
			baseHit = item_roll_dice(baseHit, attackingPawn)
	return(baseHit)

func item_roll_dice(baseHit, attackingPawn) -> float:
	var hitMod = 0
	for i in 3:
		var dieRoll = randi_range(1, diceSides)
		var newDie = diceEffect.instantiate()
		newDie.global_position = attackingPawn.global_position
		newDie.diceChoice = dieRoll
		add_sibling(newDie)
		hitMod += dieRoll
	baseHit *= 1 + hitMod * 0.1
	print("[" + str(attackingPawn.username) + "] used [dice]: " + str(1.0 + 0.1 * hitMod))
	return(baseHit)

func item_try_glue(attackingPawn) -> void:
	if attackingPawn.item == "glue" && $GlueDurationTimer.is_stopped():
		spd /= 2
		$GlueDurationTimer.start()
		print("[" + str(attackingPawn.username) + "] used [glue] on [" + str(username) + "]")

func item_glue_effect() -> void:
	if $GlueDurationTimer.get_time_left() > 0:
		$GlueEffectTimer.start()
		var newWeb = glueEffect.instantiate()
		add_child(newWeb)

func _on_glue_effect_timer_timeout() -> void:
	var newWeb = glueEffect.instantiate()
	add_child(newWeb)

# Reset Pawn speed after slow expires
func _on_glue_duration_timer_timeout() -> void:
	$PawnSprite.modulate.a = 1.0
	$PawnSprite.modulate.r = 1.0
	$PawnSprite.modulate.b = 1.0
	$PawnSprite.modulate.g = 1.0
	spd *= 2
	$GlueEffectTimer.stop()

func item_spawn_killbot() -> void:
	var newBot = killbot.instantiate()
	$AttackContainer.add_child(newBot)
	newBot.global_position = self.global_position
	newBot.follow = self
	newBot.destination = self.global_position
	print("[" + username + "] used [killbot]")

func item_try_map() -> void:
	if item == "map" && $MapCooldownTimer.is_stopped():
		destination = new_destination()
		$MapCooldownTimer.start()
		var newMapEffect = mapEffect.instantiate()
		add_child(newMapEffect)
		print("[" + str(username) + "] used [map]")
		
func item_check_milkshake() -> void:
	if item == "milkshake" && hp < milkshakeThreshold * baseHp && !milkshakeUsed:
		print("[" + str(username) + "] used [milkshake]")
		milkshakeUsed = true
		$MilkshakeDelayTimer.start(milkshakeDelay)
		var newMilkshake = milkshakeEffect.instantiate()
		add_child(newMilkshake)

func _on_milkshake_delay_timer_timeout() -> void:
	hp += milkshakePercent * baseHp
	print("[" + str(username) + "] finished [milkshake]")

func item_try_skating() -> void:
	if item == "skates" && $SkateDurationTimer.is_stopped():
		print("[" + str(username) + "] used [skates]")
		$SkateDurationTimer.start()
		spd *= skateSpeed

func item_skate_effect() -> void:
	if $SkateDurationTimer.get_time_left() > 0:
		$SkateSnowflakeTimer.start()

func _on_skate_snowflake_timer_timeout() -> void:
	var newFlake = skateEffect.instantiate()
	add_child(newFlake)

func _on_skate_duration_timer_timeout() -> void:
	spd /= skateSpeed
	$SkateSnowflakeTimer.stop()
