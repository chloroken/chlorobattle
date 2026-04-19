extends "res://pawns/base/base_pawn.gd"

@export var mummyAttack: Resource
var attackDur = 4.0
var attackVariation = 4.0

func _ready() -> void:
	super()
	isCursed = true
	$Status.get_node("WeakStatusTimer").start(curseReturnDuration)
	$Status.get_node("WeakParticleTimer").start()

func _on_attack_cooldown_timer_timeout() -> void:
	var newAttack = mummyAttack.instantiate()
	newAttack.position = self.position
	newAttack.dmg = self.dmg
	attackObjects.append(newAttack)
	$AttackContainer.add_child(newAttack)
	$AttackCooldownTimer.start(asp * baseAttackCooldown + randf_range(0.0, attackVariation) + random_variance())
	
	$Status.get_node("StuckStatusTimer").start(attackDur-1)
	$Status.get_node("StuckParticleTimer").start(attackDur-1)
	$Status.phase_out_pawn(attackDur-1)

func _on_cursed_reset_timer_timeout() -> void:
	isCursed = true
	$Status.get_node("WeakStatusTimer").start(curseReturnDuration)
	$Status.get_node("WeakParticleTimer").start()
