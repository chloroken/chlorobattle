extends "res://pawns/base/base_pawn.gd"

@export var mummyAttack: Resource
var attackDur = 4.0
var attackVariation = 4.0
var curseDuration = 99999

func _ready() -> void:
	super()
	isCursed = true
	if !attacksDisabled:
		$Status.start_weak(curseDuration)
		$AttackCooldownTimer.one_shot = true
		$AttackCooldownTimer.start(asp * baseAttackCooldown + random_variance())

func _on_attack_cooldown_timer_timeout() -> void:
	var newAttack = mummyAttack.instantiate()
	newAttack.position = self.position
	newAttack.dmg = self.dmg
	attackObjects.append(newAttack)
	$AttackContainer.add_child(newAttack)
	$AttackCooldownTimer.start(asp * baseAttackCooldown + randf_range(0.0, attackVariation) + random_variance())
	
	$Status.start_stuck(attackDur-1)
	$Status.start_phase(attackDur-1)

func _on_cursed_reset_timer_timeout() -> void:
	isCursed = true
	$Status.start_weak(curseDuration)
	#$Status.get_node("WeakStatusTimer").start(curseReturnDuration)
	#$Status.get_node("WeakParticleTimer").start()
