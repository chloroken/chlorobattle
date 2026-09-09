extends "res://pawns/_base/base_pawn.gd"

# Spark variables
@export var topAttack: PackedScene
var sparkOffset = 15
var sparkSpeedRatio = 5
var sparkCooldown = 0.25
var sparkScaleMin = 0.9
var sparkScaleMax = 1.0
var sparkScaleFloor = 0.25
var sparkDuration = 2.5
var sparkDurVariance = 0.5

# Bounce variables
var topBounceDuration = 3.0
var sprintSpdBonus = 0.5

# Bolt variables
@export var boltAttack: PackedScene
var boltCountMin = 3
var boltCountMax = 5
var boltArc = 0.75
var boltSpeedMin = 200
var boltSpeedMax = 300
var boltCooldown = 1.0

func _ready() -> void:
	super()

	# Start attack cycle
	if !attacksDisabled:
		$BoltCooldown.one_shot = true
		start_attack_cooldown()

func start_attack_cooldown() -> void:
	
	# Increase attack speed while sprinting
	var atkSpdMod = 1.0
	var isSprinting = $Status.get_node("SprintStatusTimer")
	if !isSprinting.is_stopped(): atkSpdMod = sprintSpdBonus
	
	var sparkCd = asp * aspMod * sparkCooldown * atkSpdMod
	$AttackCooldownTimer.start(sparkCd)
	
func _on_attack_cooldown_timer_timeout() -> void:
	start_attack_cooldown()
	if disarm_check(): return

	# Prevent attacks if stuck
	var stuckSource = $Status.stuckPawnSource
	if !$Status.get_node("StuckStatusTimer").is_stopped() && stuckSource != self:
		$AttackCooldownTimer.start(asp * aspMod * sparkCooldown)
		return

	# Attack with a spark
	var newAttack = topAttack.instantiate()
	newAttack.position = self.position + Vector2(0, sparkOffset)
	newAttack.dmg = self.dmg
	newAttack.attackName = "Spark"

	# Grant spark random physics
	newAttack.direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	newAttack.rotation = randf_range(0, TAU)

	# Grant spark speed based on Top's speed
	newAttack.speed += spd / sparkSpeedRatio

	# Add to containers
	$AttackContainer.add_child(newAttack)

func stay_in_bounds() -> void:
	if position.distance_to(center) > get_parent().boardRadius:
		direction = new_direction()
		if !attacksDisabled:
			top_hit_wall()
		
# Change directions when hitting edge of board
func _on_area_exited(area: Area2D) -> void:
	if self.is_queued_for_deletion(): return
	if area.get_collision_layer_value(6):#areaType == "board":
		direction = new_direction()
		if !attacksDisabled:
			top_hit_wall()

# Bounce mechanic
func top_hit_wall() -> void:
	if self.is_queued_for_deletion(): return
	$Status.start_sprint(topBounceDuration)

	if $BoltCooldown.is_stopped():
		var boltCount = randi_range(boltCountMin, boltCountMax)
		for i in boltCount:
			var newAttack = boltAttack.instantiate()
			newAttack.position = self.position
			newAttack.dmg = self.dmg
			newAttack.attackName = "Bolt"
			newAttack.speed = randf_range(boltSpeedMin, boltSpeedMax)
			newAttack.direction = position.direction_to(center).rotated(randf_range(-boltArc, boltArc))
			newAttack.rotation = newAttack.direction.angle()
			$AttackContainer.add_child(newAttack)
		$BoltCooldown.start(boltCooldown)
