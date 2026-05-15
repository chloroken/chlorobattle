extends Area2D

# Pawn properties
var username: String
var type: String
var style: String
var item: String
var team: String

# Pawn stats
@export var hp: float
@export var def: float
@export var dmg: float
@export var pen: float
@export var spd: float
var asp = 1.0
var aspMod = 1.0
var baseHp

# Combat variables
var attacksDisabled = false
var hitList = []
var voidHitList = []
var isCursed = false

# Movement variables
var board
var main
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
var wanderRadians = 1.0

func _ready() -> void:
	board = get_parent()
	main = get_tree().get_root().get_node("main")
	center = get_tree().get_root().get_node("main").position
	baseHp = hp
	direction = position.direction_to(center).rotated(randf_range(-1.0, 1.0))
	$AttackCooldownTimer.one_shot = true
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
	if style == "parkour":
			statusSpdMod *= 1.0 + $Styles.parkourSpeedPerCharge * $Styles.parkourChargeCount
	position += direction * spd * statusSpdMod * delta
	stay_in_bounds()
func stay_in_bounds() -> void:
	pass
	#if position.distance_to(center) > get_parent().boardRadius:
		#position += position.direction_to(center) * get_parent().boardRadius - position.distance_to(center)
func _on_area_exited(area: Area2D) -> void:
	if area.get_collision_layer_value(6):
		direction = new_direction()
func new_direction() -> Vector2:
	$Styles.style_parkour_add_charge()
	return(position.direction_to(center).rotated(randf_range(-wanderRadians, wanderRadians)))
