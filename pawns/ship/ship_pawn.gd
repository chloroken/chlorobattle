extends "res://pawns/base/base_pawn.gd"

# Ship variables
@export var shipRing: PackedScene
var burstDuration = 2.0
var overheatDuration = 2.0

# Projectile variables
@export var shipAttack: PackedScene
var projectileArc = 0.25
var projectileOffset = 20
var projectileDuration = 3.0
var projectileSpdMin = 1.5
var projectileSpdMax = 2.5
var projectileScaleMin = 0.5
var projectileScaleMax = 1.0

func _ready() -> void:
	super()
	
	# Start attack cycle
	if !attacksDisabled:
		$AttackCooldownTimer.one_shot = true
		$AttackCooldownTimer.start(asp * baseAttackCooldown)
		$BurstDurationTimer.start()
		$Status.start_slow(burstDuration)

func _process(_delta: float) -> void:
	super(_delta)
	
	# Turn ship to face direction for effect
	$PawnSprite.look_at(destination)

func _on_attack_cooldown_timer_timeout() -> void:
	
	# Launch projectile
	var newAttack = shipAttack.instantiate()
	newAttack.position = self.position + (Vector2.RIGHT * projectileOffset).rotated($PawnSprite.rotation)
	newAttack.dmg = self.dmg
	newAttack.speed = self.spd * randf_range(projectileSpdMin, projectileSpdMax)
	newAttack.scale = Vector2.ONE * randf_range(projectileScaleMin, projectileScaleMax)
	$AttackContainer.add_child(newAttack)
	attackObjects.append(newAttack)
	
	# Aim bullet in arc based on ship direction
	var newDir = self.position.direction_to(self.destination)
	newDir = newDir.rotated(randf_range(-projectileArc, projectileArc))
	newAttack.direction = newDir
	$AttackCooldownTimer.start(asp * baseAttackCooldown)

# Drop rings behind ship for effect
func _on_ring_timer_timeout() -> void:
	var newRing = shipRing.instantiate()
	$AttackContainer.add_child(newRing)
	newRing.position = self.position

# Stop firing
func _on_burst_duration_timer_timeout() -> void:
	$BurstDurationTimer.stop()
	$OverheatDurationTimer.start(overheatDuration + random_variance())
	$AttackCooldownTimer.stop()
	
# Stop overheating
func _on_overheat_duration_timer_timeout() -> void:
	$AttackCooldownTimer.start(asp * baseAttackCooldown)
	$OverheatDurationTimer.stop()
	$BurstDurationTimer.start(burstDuration)
	$Status.start_slow(burstDuration)
