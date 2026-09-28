extends "res://pawns/_base/base_pawn.gd"

@export var slugAttack: PackedScene
var slugAttackSpeed = 1.0
var trailDuration = 10.0
var trailOffset = 3
var healthRegen = 1.0
var oozeSickDuration = 10.0

# revive
var maxExtraLives = 2
var extraLives
var reviveDelayTimer = 5.0

func _ready() -> void:
	super()
	extraLives = maxExtraLives

	# Start attack cycle
	if !attacksDisabled: start_attack_cooldown()
	$SlugRespawnTimer.one_shot = true

func start_attack_cooldown() -> void:
	var oozeCooldown = asp * aspMod * slugAttackSpeed
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

func slug_regen() -> void:
	
	# Regenerate health every time slug attacks
	var healthToRegen = min(baseHp - hp, healthRegen)
	if healthToRegen > 0:
		hp += healthToRegen
		damageHealed += healthToRegen
		board.combat_log("[[color=#FDFD97]" + str(username) + "[/color]] healed for " + str("%0.2f" % healthToRegen) + " ([color=#9EE09E]Regen[/color])")

func _on_slug_respawn_timer_timeout() -> void:
	hp = baseHp
	if extraLives == 1:
		$PawnSprite.modulate.r = 0.4
		$PawnSprite.modulate.g = 0.8
		$PawnSprite.modulate.b = 0.4
	elif extraLives == 0:
		$PawnSprite.modulate.r = 0.1
		$PawnSprite.modulate.g = 0.6
		$PawnSprite.modulate.b = 0.1
	$GUI.visible = true

func try_revive() -> bool:
	if extraLives > 0:
		if !$SlugRespawnTimer.is_stopped(): return(true)
		$Status.start_stuck(reviveDelayTimer, self)
		$Status.start_disarmed(reviveDelayTimer)
		$Status.start_void(reviveDelayTimer)
		hp = baseHp
		$GUI.visible = false
		extraLives -= 1
		$SlugRespawnTimer.start(reviveDelayTimer)
		return(true)
	else: return(false)
