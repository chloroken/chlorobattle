extends "res://pawns/base/base_pawn.gd"

# Spark variables
@export var topAttack: PackedScene
var sparkOffset = 15
var sparkSpeedRatio = 5
var sparkCooldown = 0.25
var sparkScaleMin = 0.5
var sparkScaleMax = 1.0
var sparkScaleFloor = 0.25
var sparkDuration = 5.0
var sparkDurVariance = 0.5

# Bounce variables
var topBounceDuration = 3.0
var sprintSpdBonus = 0.5

func _ready() -> void:
	super()

	# Start attack cycle
	if !attacksDisabled:
		$AttackCooldownTimer.start(asp * sparkCooldown + random_variance())

func _physics_process(delta: float) -> void:
	super(delta)
	
	# Check if bounce should occur
	if global_position.distance_to(center) > get_parent().boardRadius:
		top_hit_wall()

# Bounce mechanic
func top_hit_wall() -> void:
	destination = new_destination()
	$Status.start_sprint(topBounceDuration)

func _on_attack_cooldown_timer_timeout() -> void:

	# Prevent attacks if timid/stuck
	if !$Status.get_node("TimidStatusTimer").is_stopped():
		$AttackCooldownTimer.start(asp * sparkCooldown)
		return
	elif !$Status.get_node("StuckStatusTimer").is_stopped():
		$AttackCooldownTimer.start(asp * sparkCooldown)
		return
		
	# Attack with a spark
	var newAttack = topAttack.instantiate()
	newAttack.position = self.position + Vector2(0, sparkOffset)
	newAttack.dmg = self.dmg

	# Grant spark random physics
	newAttack.direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	newAttack.rotation = randf_range(0, TAU)

	# Grant spark speed based on Top's speed
	newAttack.speed += spd / sparkSpeedRatio

	# Add to containers
	attackObjects.append(newAttack)
	$AttackContainer.add_child(newAttack)

	# Increase attack speed while sprinting
	var atkSpdMod = 1.0
	var isSprinting = $Status.get_node("SprintStatusTimer")
	if !isSprinting.is_stopped(): atkSpdMod = sprintSpdBonus
	$AttackCooldownTimer.start(asp * sparkCooldown * atkSpdMod)
