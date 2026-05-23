extends "res://pawns/_base/base_pawn.gd"

# Ship variables
@export var shipRing: PackedScene
var antimatterCountMin = 1
var antimatterCountMax = 5
var projectileAttackSpeedMin = 3.0
var projectileAttackSpeedMax = 4.0
var antimatterSlowDuration = 1.0
var burstDuration = 2.0
var overheatDuration = 2.0
var ringDuration = 0.25

# Projectile variables
@export var shipAttack: PackedScene
var projectileArc = 0.5
var projectileOffset = 20
var projectileDuration = 2.0
var projectileSpdMin = 1.5
var projectileSpdMax = 2.5
var projectileScaleMin = 0.5
var projectileScaleMax = 1.0

@export var antimatterAttack: PackedScene

func _ready() -> void:
	super()
	
	$RingTimer.set_wait_time(ringDuration)
	$RingTimer.start()

	if !attacksDisabled:
		#$OverheatDurationTimer.one_shot = true
		#$BurstDurationTimer.one_shot = true
		#$BurstDurationTimer.start(burstDuration)
		start_attack_cooldown()

func start_attack_cooldown() -> void:
	var attackCooldown = randf_range (projectileAttackSpeedMin, projectileAttackSpeedMax)
	var antimatterCooldown = asp * aspMod * attackCooldown
	$AttackCooldownTimer.start(antimatterCooldown)

func _on_attack_cooldown_timer_timeout() -> void:
	start_attack_cooldown()
	if disarm_check(): return
	$Status.start_slow(antimatterSlowDuration)

	var antimatterCount = randf_range(antimatterCountMin, antimatterCountMax)
	for i in antimatterCount:
		var newAttack = antimatterAttack.instantiate()
		newAttack.position = self.position
		newAttack.baseSpeed = spd*2
		var newDir = self.direction
		newDir = newDir.rotated(randf_range(-projectileArc, projectileArc))
		newAttack.direction = newDir
		$AttackContainer.add_child(newAttack)
	
	# Launch projectile
	#var newAttack = shipAttack.instantiate()
	#newAttack.position = self.position + (Vector2.RIGHT * projectileOffset).rotated($PawnSprite.rotation)
	#newAttack.dmg = self.dmg
	#newAttack.attackName = "Globule"
	#newAttack.speed = self.spd * randf_range(projectileSpdMin, projectileSpdMax)
	#newAttack.scale = Vector2.ONE * randf_range(projectileScaleMin, projectileScaleMax)
	#$AttackContainer.add_child(newAttack)

	# Aim bullet in arc based on ship direction
	#var newDir = self.direction
	#newDir = newDir.rotated(randf_range(-projectileArc, projectileArc))
	#newAttack.direction = newDir

# Stop firing
#func _on_burst_duration_timer_timeout() -> void:
	#$BurstDurationTimer.stop()
	#$OverheatDurationTimer.start(overheatDuration)
	#$Status.start_disarmed(overheatDuration)
	
# Stop overheating
#func _on_overheat_duration_timer_timeout() -> void:
	#$OverheatDurationTimer.stop()
	#$BurstDurationTimer.start(burstDuration)
	#$Status.start_slow(burstDuration)

# Effects
func _process(_delta: float) -> void:
	$PawnSprite.rotation = direction.angle()
func _on_ring_timer_timeout() -> void:
	var newRing = shipRing.instantiate()
	newRing.position = self.global_position
	$AttackContainer.add_child(newRing)
