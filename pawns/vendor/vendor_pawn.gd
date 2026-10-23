extends "res://pawns/_base/base_pawn.gd"

@export var sodaAttackScene: PackedScene
var sodaCooldownMin = 0.5
var sodaCooldownMax = 1.0
var sodaSpeed = 150.0

var wobbleDuration = 0.5
var wobbleDir = 1
var wobbleAmount = 0.2

func _ready() -> void:
	super()
	$WobbleTimer.start(wobbleDuration)
	if not inLobby:
		new_attack_cycle(sodaCooldownMin, sodaCooldownMax)
func _on_attack_cooldown_timer_timeout() -> void:
	new_attack_cycle(sodaCooldownMin, sodaCooldownMax)
	if disarm_check():
		return
	new_soda_attack()
func new_soda_attack() -> void:
	var newSoda = sodaAttackScene.instantiate()
	newSoda.dmg = self.dmg
	newSoda.attackName = "Soda"
	newSoda.areaAttack = false
	newSoda.speed = sodaSpeed
	newSoda.direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	newSoda.position = self.position
	$AttackContainer.add_child(newSoda)
func _physics_process(delta: float) -> void:
	super(delta)
	$PawnSprite.skew = lerp(-wobbleAmount*wobbleDir, wobbleAmount*wobbleDir, $WobbleTimer.get_time_left() / wobbleDuration)

func _on_wobble_timer_timeout() -> void:
	wobbleDir *= -1
