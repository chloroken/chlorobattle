extends "res://pawns/base/base_pawn.gd"

@export var shipAttack: PackedScene
@export var shipRing: PackedScene
var attackConeArc = 0.225

# Turn ship to face direction for effect
func _process(_delta: float) -> void:
	super(_delta)
	$PawnSprite.look_at(destination)

func _on_attack_cooldown_timer_timeout() -> void:
	# Launch bullets
	if $OverheatDurationTimer.is_stopped():
		var newAttack = shipAttack.instantiate()
		newAttack.position = self.position
		newAttack.dmg = self.dmg
		$AttackContainer.add_child(newAttack)
		attackObjects.append(newAttack)
		
		# Aim bullet in arc based on ship direction
		var newDir = self.position.direction_to(self.destination)
		newDir = newDir.rotated(randf_range(-attackConeArc, attackConeArc))
		newAttack.direction = newDir

# Drop rings behind ship for effect
func _on_ring_timer_timeout() -> void:
	var newRing = shipRing.instantiate()
	get_parent().add_sibling(newRing)
	newRing.position = self.position
	
func _on_burst_duration_timer_timeout() -> void:
	$BurstDurationTimer.stop()
	$OverheatDurationTimer.start($OverheatDurationTimer.get_wait_time() + random_variance())

func _on_overheat_duration_timer_timeout() -> void:
	$OverheatDurationTimer.stop()
	$BurstDurationTimer.start()
