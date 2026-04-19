extends Area2D

# Pawn properties
var username: String
var type: String
var style: String
var item: String

# Pawn stats
var size = 1.0
@export var hp: float
@export var dmg: float
var asp = 1.0
@export var pen: float
@export var def: float
@export var spd: float

# Item scenes
@export var tombstone: PackedScene
@export var killbot: PackedScene
@export var diceEffect: PackedScene
@export var mapEffect: PackedScene
@export var mapFlickerEffect: PackedScene
@export var milkshakeEffect: PackedScene
@export var tireAttack: PackedScene

# Back end Pawn properties & variables
var center: Vector2
var nameCharLimit = 9
var attackObjects = []
var hitList = []
var attacksDisabled = false
var destination: Vector2
var baseHp
var baseAttackCooldown
var isCursed = false
var cursePassDuration = 5.0
var mummyGlyphRange = 64
var curseReturnDuration = 10.0

# Score variables
var damageTaken = 0
var damageDealt = 0
var killCount = 0

# Movement variables
var normalSpeed = 1.0
var sprintActive
var sprintSpeed = 2.0
var slowActive
var slowSpeed = 0.5
var stuckActive
var stuckSpeed = 0.0

##################
# INITIALIZATION #
##################

func _ready() -> void:
	
	# Snapshot some variables and set Pawn's initial destination
	z_index = get_node("/root/main").layerPawn
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
		$gui.get_node("HitpointLabel").visible = false
		$gui.get_node("HitpointLabelBlack").visible = false
		$gui.get_node("HitpointLabelRed").visible = false
		$gui.get_node("HitpointLabelGreen").visible = false

	elif !attacksDisabled:
		# Check for Pawn items that require action now
		if item == "antimatter":
			$Items.get_node("AntimatterCooldownTimer").start(randf_range($Items.get_node("AntimatterCooldownTimer").get_wait_time() / $Items.antimatterRandomizer, $Items.antimatterCooldown))
		elif item == "tire":
			$Items.get_node("TireAttackTimer").start(randf_range($Items.tireCooldownMin, $Items.tireCooldownMax))
		elif item == "killbot":
			$Items.item_spawn_killbot()

		# Start style timers
		if style == "berserk":
			$Styles.get_node("BerserkResetTimer").set_wait_time($Styles.berserkTimerDuration)
			$Styles.get_node("BerserkResetTimer").start()
		elif style == "mighty":
			$Styles.get_node("MightyChargeTimer").set_wait_time($Styles.mightyChargeDuration)
			$Styles.get_node("MightyChargeTimer").start()

		# Start attacking
		$AttackCooldownTimer.start(baseAttackCooldown)

#######
# GUI #
#######

func _process(_delta: float) -> void:
	
	# Update Pawn name
	$gui.get_node("NameLabel").text = username.substr(0, nameCharLimit)

	# Update Pawn hp bar
	$gui.get_node("HitpointLabel").text = str(int(ceil(hp)))
	$gui.get_node("HitpointLabelGreen").scale.x = hp / baseHp
	
	# Update style indicators
	var styleIndicator = ""
	if style == "berserk":
		for i in int($Styles.berserkHitCount):
			styleIndicator += "•"
		$gui.get_node("StyleLabel").add_theme_color_override("default_color", Color(0.0, 1.0, 0.5, 1.0))
	elif style == "mighty":
		for i in int($Styles.mightyChargeCount):
			styleIndicator += "•"
		$gui.get_node("StyleLabel").add_theme_color_override("default_color", Color.RED)
	elif style == "slayer":
		styleIndicator += "•"
		for i in int(killCount):
			styleIndicator += "•"
		$gui.get_node("StyleLabel").add_theme_color_override("default_color", Color(0.0, 0.5, 1.0, 1.0))
		#styleIndicator = str(killCount + 1)
	$gui.get_node("StyleLabel").text = styleIndicator
	
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

	# Adjust speed based on status effects (slow, sprint, stuck)
	if $Status.get_node("SprintStatusTimer").is_stopped():
		sprintActive = normalSpeed
	else: sprintActive = sprintSpeed
	if $Status.get_node("SlowStatusTimer").is_stopped():
		slowActive = normalSpeed
	else: slowActive = slowSpeed
	if $Status.get_node("StuckStatusTimer").is_stopped():
		stuckActive = normalSpeed
	else: stuckActive = stuckSpeed

	# Move Pawn
	var statusSpdMod = sprintActive * slowActive * stuckActive
	global_position = global_position.move_toward(destination, spd * statusSpdMod * delta)

# Calculate a new place for Pawn to go
func new_destination() -> Vector2:
	var radius = get_parent().boardRadius
	var rando = ((Vector2.RIGHT * radius).rotated(randf_range(0, TAU)))
	var desto = center + rando

	# Avoid picking a location too close
	while global_position.distance_to(desto) < radius:
		desto = new_destination()
	return(desto)

##########
# COMBAT #
##########

# When a Pawn gets hit by an attack
func _on_body_entered(body: Node2D) -> void:

	# Get information about the aggressor
	var pawns = get_parent().get_parent().pawnList
	var attackingPawn = body.get_parent().get_parent()
	var attackerUsername = attackingPawn.username
	
	# Avoid self-hits & subsequent hits from area attacks
	if attackerUsername != username && !hitList.has(body):

		# Berserk attack speed ramping mechanic
		$Styles.style_berserk_trigger(body, attackingPawn)

		# Hit procedure
		calculate_damage(attackingPawn, attackerUsername, body)

		# Post-damage item triggers
		$Items.item_try_killbot_stack(attackingPawn, body)
		$Items.item_try_skating()
		$Items.item_try_map()
		$Items.item_try_glue(attackingPawn, body)

		# Mummy curse transfer check
		if type == "mummy" && !body.isPersistentSummon && attackingPawn.username != username:
			var attackerStatus = attackingPawn.get_node("Status")
			if attackerStatus.get_node("WeakStatusTimer").get_time_left() < cursePassDuration:
				if isCursed:
					isCursed = false
					$Status.get_node("WeakStatusTimer").stop()
					$Status.get_node("WeakParticleTimer").stop()
					$CursedResetTimer.start(curseReturnDuration)
					attackerStatus.get_node("WeakStatusTimer").start(cursePassDuration)
					attackerStatus.get_node("WeakParticleTimer").start()

		# Finalize attack
		if !body.areaAttack: body.queue_free()
		else: hitList.append(body)

	# Check for Pawn death
	if hp <= 0:
		# kill cam
		for i in range(0, pawns.size()):
			if pawns[i].username == username:
				attackingPawn.killCount += 1
				pawn_death(attackingPawn, attackerUsername, i)
				break

	# Check for post-deathcheck item triggers
	$Items.item_check_milkshake()

func calculate_damage(attackingPawn, attackerUsername, body) -> void:
	
	# Set up default hit
	var baseHit = body.dmg
	var hitText = "hit"
		
	# Mummy stuck distance check
	if attackingPawn.type == "mummy" && body.mummyCenter == true:
		if $Status.get_node("StuckCooldownTimer").is_stopped():
			$Status.get_node("StuckStatusTimer").start(5.0)
			$Status.get_node("StuckCooldownTimer").start()
			$Status.get_node("StuckParticleTimer").start()
	
	# Weakness check
	var weakTimer = attackingPawn.get_node("Status").get_node("WeakStatusTimer")
	if !weakTimer.is_stopped():
		baseHit /= 2

	# Crit mechanics
	var diceHit = $Items.item_check_dice(attackingPawn, baseHit, body)
	if diceHit > baseHit: hitText = "crit"
	baseHit = diceHit
 
	# Adjust hit if Mighty goes off
	baseHit = $Styles.style_mighty_trigger(body, attackingPawn, baseHit)
	
	# Damage formula
	var baseDefendedHit = baseHit * self.def
	var actualDefended = baseDefendedHit * (1.0 - attackingPawn.pen)
	var realHit = (baseHit - actualDefended)

	# Slayer defence-bypassing percentage-damage mechanic
	realHit = $Styles.style_slayer_trigger(body, attackingPawn, realHit)

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

func pawn_respawn(pawnIndex: int) -> void:
	get_parent().spawn_sandbox_pawn(get_parent().get_parent().pawnList[pawnIndex])

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
