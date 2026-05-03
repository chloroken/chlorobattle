extends Area2D

@export var tombstone: PackedScene

# Pawn properties
#var areaType = "pawn"
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
var damageHealed = 0
var killCount = 0

# Movement variables
var normalSpeed = 1.0
var sprintSpeed = 2.0
var slowSpeed = 0.5
var stuckSpeed = 0.0

func _ready() -> void:

	# Initial setup
	center = get_tree().get_root().get_node("main").position
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
	if position.distance_to(center) > get_parent().boardRadius:
		direction = new_direction()

func _on_area_exited(area: Area2D) -> void:
	if area.get_collision_layer_value(6):#areaType == "board":
		direction = new_direction()

func new_direction() -> Vector2:
	return(position.direction_to(center).rotated(randf_range(-1.0, 1.0)))

##########
# COMBAT #
##########

func _on_area_entered(area: Area2D) -> void:
	$Combat.combat_pawn(area, self)
func _on_bully_area_area_entered(area: Area2D) -> void:
	$Styles.style_bully_trigger(area)

##############
# PAWN DEATH #
##############

func pawn_death(attackingPawn, killer: String, pawnIndex: int) -> void:
	attackingPawn.get_node("KillSound").panning_strength = 0.0
	attackingPawn.get_node("KillSound").play()
	make_tombstone()

	# Save progress & clean up
	var mainBoard = get_parent().get_parent()
	update_scoreboard(mainBoard, self, pawnIndex, false)
	kill_log("[" + str(killer) + "] eliminated [" + str(username) + "]")
	self.queue_free()

	# For last Pawn, make order exception to transition to scoreboard
	if mainBoard.pawnList.size() <= 1:
		update_scoreboard(mainBoard, attackingPawn, pawnIndex, true)

func make_tombstone() -> void:
	var newTombstone = tombstone.instantiate()
	newTombstone.global_position = global_position
	newTombstone.name = "Tombstone (" + username + ")"
	newTombstone.username = username
	get_parent().add_child(newTombstone)

func update_scoreboard(mainBoard, pawn, pawnIndex, last) -> void:
	var newScore = mainBoard.Pawn.new()
	newScore.username = pawn.username
	newScore.type = pawn.type
	newScore.style = pawn.style
	newScore.item = pawn.item
	newScore.damageTaken = pawn.damageTaken
	newScore.damageDealt = pawn.damageDealt
	newScore.damageHealed = pawn.damageHealed
	newScore.killCount = pawn.killCount
	mainBoard.scoreList.push_front(newScore)
	if !last: mainBoard.pawnList.remove_at(pawnIndex)

#####################
# UTILITY FUNCTIONS #
#####################

# A small float for breaking timing ties
func random_variance() -> float:
	return(randf_range(0.0001, 0.001))

func combat_log(msg) -> void:
	get_parent().update_combat_log(msg)
	debug_log(msg)

func kill_log(msg) -> void:
	get_parent().update_kill_feed(msg)
	debug_log(msg)

func debug_log(msg) -> void:
	print(msg)
