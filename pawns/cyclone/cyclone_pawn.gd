extends "res://pawns/base/base_pawn.gd"

@export var cycloneAttack: PackedScene
@export var cycloneExplosion: PackedScene
@export var cycloneMelee: PackedScene

@export var jetFormSprite: Resource
@export var meleeFormSprite: Resource

var attackConeArc = .25
var meleeForm = false
var jetAttackCooldown = 1.5
var meleeAttackCooldown = 3.0
var formSwapTimer = 10.0
var formSwapVariance = 2.0

# Turn to face direction for effect
func _process(_delta: float) -> void:
	super(_delta)
	if meleeForm:
		$PawnSprite.rotation = 0.0
		$PawnSprite.texture = meleeFormSprite
	else:
		$PawnSprite.look_at(destination)
		$PawnSprite.texture = jetFormSprite

func _on_attack_cooldown_timer_timeout() -> void:
	if !meleeForm:
		var newAttack = cycloneAttack.instantiate()
		newAttack.position = self.position
		newAttack.dmg = self.dmg
		newAttack.direction = self.position.direction_to(self.destination).rotated(randf_range(-attackConeArc, attackConeArc))
		attackObjects.append(newAttack)
		$AttackContainer.add_child(newAttack)
		$AttackCooldownTimer.start(asp * jetAttackCooldown + random_variance())
	else:
		var newAttack = cycloneMelee.instantiate()
		newAttack.position = self.position
		newAttack.dmg = self.dmg * 2
		attackObjects.append(newAttack)
		$AttackContainer.add_child(newAttack)
		$AttackCooldownTimer.start(asp * meleeAttackCooldown + random_variance())

func make_explosion(loc: Vector2) -> void:
	var newAttack = cycloneExplosion.instantiate()
	newAttack.position = loc
	newAttack.dmg = self.dmg
	newAttack.areaAttack = true
	attackObjects.append(newAttack)
	$AttackContainer.add_child(newAttack)

func _on_form_swap_timer_timeout() -> void:
	if meleeForm:
		if !attacksDisabled: $AttackCooldownTimer.start(jetAttackCooldown + random_variance())
		spd *= 4
	else:
		if !attacksDisabled: $AttackCooldownTimer.start(meleeAttackCooldown + random_variance())
		spd /= 4
	meleeForm = !meleeForm
	var form_offset_variance = randf_range(-formSwapVariance, formSwapVariance)
	$FormSwapTimer.start(formSwapTimer + form_offset_variance + random_variance())
