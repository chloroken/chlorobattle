extends "res://pawns/base/base_pawn.gd"

@export var slugAttack: PackedScene
var slugAttackSpeed = 1.0
var trailDuration = 10.0
var trailOffset = 3
var healthRegen = 0.5

func _ready() -> void:
	super()

	# Start attack cycle
	if !attacksDisabled: start_attack_cooldown()
	
func start_attack_cooldown() -> void:
	var oozeCooldown = asp * slugAttackSpeed + random_variance()
	$AttackCooldownTimer.start(oozeCooldown)

func _on_attack_cooldown_timer_timeout() -> void:
	start_attack_cooldown()
	if disarm_check(): return

	var newAttack = slugAttack.instantiate()
	var ranX = randi_range(-trailOffset, trailOffset)
	var ranY = randi_range(-trailOffset, trailOffset)
	newAttack.position = self.position + Vector2(ranX, ranY)
	newAttack.baseDmg = self.dmg
	newAttack.attackName = "Ooze"
	$AttackContainer.add_child(newAttack)

	# Regenerate health every time slug attacks
	var healthToRegen = min(baseHp - hp, healthRegen)
	if healthToRegen > 0:
		hp += healthToRegen
		damageHealed += healthToRegen
		combat_log("[" + str(username) + "] healed for " + str("%0.2f" % healthToRegen) + " (Regen)")
