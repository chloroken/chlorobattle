extends "res://pawns/_base/base_pawn.gd"

@export var slimeAttackScene: PackedScene
var slimeAttackName = "Slime"
var slimeCooldown = 1.0
var slimeDuration = 20.0
var slimeOffset = 3
var slimeSickDuration = 10.0

var absorbLogName = "Absorb"
var absorbHealthRegen = 1.0

var reviveLifeCount = 2
var reviveLivesRemaining = reviveLifeCount
var reviveDelayTimer = 5.0

@export var normalSpriteScene: Texture
@export var shellSpriteScene: Texture
var shellCooldown = 10.0
var shellActive = false

func _ready() -> void:
	super()
	if not inLobby:
		initialize_timers()
		new_attack_cycle(slimeCooldown, slimeCooldown)
func initialize_timers() -> void:
	$SlugRespawnTimer.one_shot = true
	$SlugShellTimer.one_shot = true
	$SlugShellTimer.start(shellCooldown)
func _on_attack_cooldown_timer_timeout() -> void:
	new_attack_cycle(slimeCooldown, slimeCooldown)
	if disarm_check(): return
	new_slime_attack()
func new_slime_attack() -> void:
	var newSlime = slimeAttackScene.instantiate()
	newSlime.position = self.position + new_slime_offset()
	newSlime.baseDmg = self.dmg
	newSlime.attackName = slimeAttackName
	newSlime.areaAttack = false
	newSlime.isSlugAttack = true
	newSlime.duration = slimeDuration
	$AttackContainer.add_child(newSlime)
func new_slime_offset() -> Vector2:
	var ranX = randi_range(-slimeOffset, slimeOffset)
	var ranY = randi_range(-slimeOffset, slimeOffset)
	return(Vector2(ranX, ranY))
func slug_regen() -> void:
	var healthToRegen = min(baseHp - hp, absorbHealthRegen)
	if healthToRegen > 0:
		hp += healthToRegen
		damageHealed += healthToRegen
		board.combat_log("[[color=#FDFD97]" + str(username) + "[/color]] healed for " + str("%0.2f" % healthToRegen) + " ([color=#9EE09E]" + str(absorbLogName) + "[/color])")
func _on_slug_respawn_timer_timeout() -> void:
	hp = baseHp
	$GUI.visible = true
func try_revive() -> bool:
	if reviveLivesRemaining > 0 && $SlugRespawnTimer.is_stopped():
		revive_slug()
		return(true)
	else: return(false)
func revive_slug() -> void:
	$Status.start_stuck(reviveDelayTimer, self)
	$Status.start_disarmed(reviveDelayTimer)
	$Status.start_void(reviveDelayTimer)
	hp = baseHp
	$GUI.visible = false
	reviveLivesRemaining -= 1
	$SlugRespawnTimer.start(reviveDelayTimer)
func _on_slug_shell_timer_timeout() -> void:
	$PawnSprite.texture = shellSpriteScene
	shellActive = true
	$Status.start_tanky(999)
