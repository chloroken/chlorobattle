extends Area2D

@export var tombstone: PackedScene

# Pawn properties
var areaType = "pawn"
var username: String
var type: String
var style: String
var item: String

# Pawn stats
@export var hp: float
@export var def: float
@export var dmg: float
@export var pen: float
@export var spd: float
var asp = 1.0
var baseHp

# Combat variables
var attacksDisabled = false
var attackObjects = []
var hitList = []
var isCursed = false

# Movement variables
var center: Vector2
var direction
var statusSpdMod = 1

# Score variables
var nameCharLimit = 6
var damageTaken = 0
var damageDealt = 0
var killCount = 0

# Movement variables
var normalSpeed = 1.0
var sprintSpeed = 2.0
var slowSpeed = 0.5
var stuckSpeed = 0.0

func _ready() -> void:

	# Initial setup
	center = get_viewport_rect().size / 2.0
	baseHp = hp
	direction = new_direction()
	$AttackCooldownTimer.one_shot = true

	# Set visibility order
	z_as_relative = false
	z_index = get_node("/root/main").layerPawn

func disarm_check() -> bool:
	if $Status.get_node("DisarmedStatusTimer").is_stopped(): return(false)
	return(true)

############
# MOVEMENT #
############

func _physics_process(delta: float) -> void:

	# Adjust speed based on statuses
	statusSpdMod = normalSpeed
	if !$Status.get_node("SprintStatusTimer").is_stopped(): statusSpdMod *= sprintSpeed
	if !$Status.get_node("SlowStatusTimer").is_stopped(): statusSpdMod *= slowSpeed
	if !$Status.get_node("StuckStatusTimer").is_stopped(): statusSpdMod *= stuckSpeed

	# Move Pawn
	position += direction * spd * statusSpdMod * delta

# Change directions when hitting edge of board
func _on_area_exited(area: Area2D) -> void:
	if area.areaType == "board":
		direction = new_direction()

func new_direction() -> Vector2:
	return(position.direction_to(center).rotated(randf_range(-1.0, 1.0)))

#################
# HIT DETECTION #
#################

func _on_area_entered(area: Area2D) -> void:
	if area.areaType == "board": return
	if area.areaType == "pawn" && style == "bully":
		$Styles.style_bully_trigger(area)
	if area.areaType == "attack":
		var attackingPawn = area.get_parent().get_parent()
		var attackerUsername = attackingPawn.username
		if attackerUsername != username && !hitList.has(area):
			pre_accuracy_phase(area, attackingPawn)
			if accuracy_phase(attackingPawn, attackerUsername):
				var damage = defense_phase(attackingPawn, area)
				damage = modifier_phase(damage, attackingPawn, area)
				damage_phase(damage, attackingPawn, attackerUsername, area)
				effects_phase(attackingPawn, area)
			clean_up_phase(area, attackingPawn, attackerUsername)

##################
# ACCURACY PHASE #
##################

# These effects will happen regardless of it the attack hits
func pre_accuracy_phase(body, attackingPawn) -> void:
	$Styles.style_berserk_trigger(body, attackingPawn)
	if attackingPawn.type == "mummy" && body.mummyCenter == true:
		$Status.start_stuck(attackingPawn.glyphStuckDuration)

# Determine if this attack will hit
func accuracy_phase(attackingPawn, attackerUsername) -> bool:
	var hitChance = 100

	# Drunk miss mechanic
	var drunkTimer = attackingPawn.get_node("Status").get_node("DrunkStatusTimer")
	if !drunkTimer.is_stopped(): hitChance -= $Status.drunkMissChance
	var hitRoll = randi_range(1, 100)
	if hitRoll > hitChance:
		attackingPawn.direction = attackingPawn.new_direction()
		print("[" + str(attackerUsername) + "] drunkenly missed [" + str(self.username) + "]")
		get_parent().update_combat_log("[" + str(attackerUsername) + "] missed [" + str(self.username) + "]")
		return(false)

	return(true)

#################
# DEFENSE PHASE #
#################

# Calculate the base damage of this hit
func defense_phase(attackingPawn, body) -> float:
	var baseHit = body.dmg
	var baseDefendedHit = baseHit * self.def
	var actualDefended = baseDefendedHit * (1.0 - attackingPawn.pen)
	var realHit = (baseHit - actualDefended)
	return(realHit)

##################
# MODIFIER PHASE #
##################

# Modify the base damage by effects
func modifier_phase(baseHit, attackingPawn, body) -> float:
	
	# Weak
	var weakTimer = attackingPawn.get_node("Status").get_node("WeakStatusTimer")
	if !weakTimer.is_stopped(): baseHit /= 2

	# Dice
	var diceHit = $Items.item_check_dice(attackingPawn, baseHit, body)
	baseHit = diceHit

	# Mighty
	baseHit = $Styles.style_mighty_trigger(body, attackingPawn, baseHit)

	# Slayer
	baseHit = $Styles.style_slayer_trigger(body, attackingPawn, baseHit)

	# Global damage reduction
	var finalHit = baseHit * (get_parent().globalDmgMod / get_parent().dmgModDuration)
	return(finalHit)

################
# DAMAGE PHASE #
################

# Apply damage, record stats, output to combat log
func damage_phase(finalDmg, attackingPawn, attackerUsername, body) -> void:

	# Apply damage
	self.hp -= finalDmg

	# Update score
	damageTaken += finalDmg
	attackingPawn.damageDealt += finalDmg
	get_parent().update_combat_log("[" + str(attackerUsername) + "] hit [" + str(self.username) + "] for " + "%0.2f" % finalDmg + " (" + str(body.attackName) + ")") 

	# Combat log backend
	print("[" + str(attackerUsername) + "] hit [" + str(self.username) + "] for " + "%0.2f" % finalDmg + " (" + str(body.attackName) + ")") 

#####################
# EFFECTS PHASE #
#####################

# Apply on-hit effects after doing damage
func effects_phase(attackingPawn, body) -> void:
	$Items.item_try_killbot_stack(attackingPawn, body)
	$Items.item_try_skating()
	$Items.item_try_glue(attackingPawn, body)
	if type == "mummy" && !body.isPersistentSummon:
		var attackerStatus = attackingPawn.get_node("Status")
		if isCursed:
			isCursed = false
			$Status.stop_weak()
			$CursedResetTimer.start(self.curseResetTimer)
			attackerStatus.start_weak(self.cursePassDuration)
	if body.isSlugAttack:
		var durationRemaining = body.get_node("FizzleTimer").get_time_left()
		$Status.start_dot(durationRemaining, attackingPawn)
	if body.isTireAttack:
		$Status.start_stuck(body.stuckDuration)
	if body.isEmberAttack:
		$Status.start_dot(body.get_parent().get_parent().emberBurnDuration, attackingPawn)
	$Items.item_try_map()

##################
# CLEAN-UP PHASE #
##################

# Mark attack as hit or remove it, clean up dead Pawns
func clean_up_phase(body, attackingPawn, attackerUsername) -> void:
	if !body.areaAttack: body.queue_free()
	else: hitList.append(body)
	var pawns = get_parent().get_parent().pawnList
	if hp <= 0:
		for i in range(0, pawns.size()):
			if pawns[i].username == username:
				attackingPawn.killCount += 1
				if attackingPawn.style == "slayer":
					attackingPawn.get_node("Styles").add_slayer_charge()
				pawn_death(attackingPawn, attackerUsername, i)
				break

func pawn_death(attackingPawn, killer: String, pawnIndex: int) -> void:
	attackingPawn.get_node("KillSound").panning_strength = 0.0
	attackingPawn.get_node("KillSound").play()
	make_tombstone(killer)

	# Save progress & clean up
	var mainBoard = get_parent().get_parent()
	update_scoreboard(mainBoard, self, pawnIndex, false)
	get_parent().update_kill_feed("[" + str(killer) + "] eliminated [" + str(username) + "]")
	self.queue_free()

	# For last Pawn, make order exception to transition to scoreboard
	if mainBoard.pawnList.size() <= 1:
		update_scoreboard(mainBoard, attackingPawn, pawnIndex, true)

func make_tombstone(killer) -> void:
	var newTombstone = tombstone.instantiate()
	newTombstone.global_position = global_position
	newTombstone.name = "Tombstone (" + username + ")"
	newTombstone.username = username
	get_parent().add_child(newTombstone)
	print("[" + str(username) + "] was killed by [" + str(killer) + "]")

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

# Clean up Pawn attacks & effects after death
func _on_tree_exiting() -> void:
	for attack in attackObjects:
		if attack != null:
			attack.queue_free()

#####################
# UTILITY FUNCTIONS #
#####################

# A small float for breaking timing ties
func random_variance() -> float:
	return(randf_range(0.0001, 0.001))
