extends Area2D

#@export var tombstone: PackedScene

# Pawn properties
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
var nameCharLimit = 9
var damageTaken = 0
var damageDealt = 0
var damageHealed = 0
var killCount = 0

# Movement variables
var normalSpeed = 1.0
var sprintSpeed = 2.0
var slowSpeed = 0.5
var stuckSpeed = 0.0

var team

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
	statusSpdMod = normalSpeed
	if !$Status.get_node("SprintStatusTimer").is_stopped(): statusSpdMod *= sprintSpeed
	if !$Status.get_node("SlowStatusTimer").is_stopped(): statusSpdMod *= slowSpeed
	if !$Status.get_node("StuckStatusTimer").is_stopped(): statusSpdMod *= stuckSpeed
	position += direction * spd * statusSpdMod * delta
	stay_in_bounds()

func stay_in_bounds() -> void:
	if position.distance_to(center) > get_parent().boardRadius:
		direction = new_direction()
func _on_area_exited(area: Area2D) -> void:
	if area.get_collision_layer_value(6):#areaType == "board":
		direction = new_direction()
func new_direction() -> Vector2:
	return(position.direction_to(center).rotated(randf_range(-1.0, 1.0)))

#################
# HIT DETECTION #
#################

func _on_area_entered(area: Area2D) -> void:
	$Combat.get_node("Pawn").combat_pawn(area)
	$Combat.get_node("Item").combat_item(area, self)
func _on_bully_area_area_entered(area: Area2D) -> void:
	$Combat.get_node("Style").bully_hit(area)
func status_damage(statusType) -> void:
	match statusType:
		"dot": $Combat.get_node("Status").dot_damage()
