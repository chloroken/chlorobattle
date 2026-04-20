extends "res://pawns/base/base_pawn.gd"

@export var shipAttack: PackedScene
@export var shipRing: PackedScene
var attackConeArc = 0.5
var shipBulletOffset = 20
var overheatDuration = 2.0
var burstDuration = 2.0

func _ready() -> void:
	super()
	if !attacksDisabled:
		$AttackCooldownTimer.one_shot = true
		$AttackCooldownTimer.start(asp * baseAttackCooldown)
		$BurstDurationTimer.start()
		$Status.start_slow(burstDuration)

# Turn ship to face direction for effect
func _process(_delta: float) -> void:
	super(_delta)
	$PawnSprite.look_at(destination)

# Launch bullets
func _on_attack_cooldown_timer_timeout() -> void:
	var newAttack = shipAttack.instantiate()
	newAttack.position = self.position + (Vector2.RIGHT * shipBulletOffset).rotated($PawnSprite.rotation)
	newAttack.dmg = self.dmg
	$AttackContainer.add_child(newAttack)
	attackObjects.append(newAttack)
	
	# Aim bullet in arc based on ship direction
	var newDir = self.position.direction_to(self.destination)
	newDir = newDir.rotated(randf_range(-attackConeArc, attackConeArc))
	newAttack.direction = newDir
	$AttackCooldownTimer.start(asp * baseAttackCooldown)

# Drop rings behind ship for effect
func _on_ring_timer_timeout() -> void:
	var newRing = shipRing.instantiate()
	$AttackContainer.add_child(newRing)
	newRing.position = self.position

# Stop firing
func _on_burst_duration_timer_timeout() -> void:
	#spd *= 2
	$BurstDurationTimer.stop()
	$OverheatDurationTimer.start(overheatDuration + random_variance())
	$AttackCooldownTimer.stop()
	
# Stop overheating
func _on_overheat_duration_timer_timeout() -> void:
	$AttackCooldownTimer.start(asp * baseAttackCooldown)
	$OverheatDurationTimer.stop()
	$BurstDurationTimer.start(burstDuration)
	$Status.start_slow(burstDuration)
	#spd /= 2
