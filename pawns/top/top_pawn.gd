extends "res://pawns/base/base_pawn.gd"

@export var topAttack: PackedScene
var topBounceSpeed = 2
var sparkOffset = 15
var baseSpd
#var baseAttackTimer
var sparkDir = Vector2.RIGHT

func _ready() -> void:
	baseSpd = 75
	#baseAttackTimer = $AttackCooldownTimer.get_wait_time()
	super()

func _physics_process(delta: float) -> void:
	if global_position.distance_to(destination) < 10:
		destination = new_destination()
		if $BounceDurationTimer.is_stopped():
			top_hit_wall()
		else:
			spd /= 2
			$BounceDurationTimer.stop()
			top_hit_wall()
	else:
		global_position = global_position.move_toward(destination, spd * delta)

func top_hit_wall() -> void:
	$BounceDurationTimer.start()
	spd *= 2

func _on_attack_cooldown_timer_timeout() -> void:
	var newAttack = topAttack.instantiate()
	newAttack.position = self.position + Vector2(0, sparkOffset)
	newAttack.dmg = self.dmg
	
	sparkDir *= -1
	newAttack.direction = sparkDir.rotated(randf_range(-0.1, 0.1))
	newAttack.direction += position.direction_to(destination)
	newAttack.rotation = randf_range(0, TAU)
	newAttack.speed += spd
	
	attackObjects.append(newAttack)
	$AttackContainer.add_child(newAttack)
	var attackTimerSpeedMod = min(4.0, baseSpd / spd)
	$AttackCooldownTimer.start(asp * max(baseAttackCooldown / 4, attackTimerSpeedMod * baseAttackCooldown) + random_variance())

func _on_bounce_duration_timer_timeout() -> void:
	$BounceDurationTimer.stop()
	spd /= 2

func _on_bounce_decay_timer_timeout() -> void:
	pass # Replace with function body.
