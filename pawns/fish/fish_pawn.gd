extends "res://pawns/_base/base_pawn.gd"

@export var splashAttackScene: PackedScene
var splashDiveDuration = 2.0

var splashCooldownMin = 5.0
var splashCooldownMax = 6.0
var splashScaleMin = 0.25
var splashScaleMax = 0.5
var splashDuration = 0.75

var flopChainChance = 0.75
var flopInitialDelay = 0.01
var flopChaining = false
var flopDiveDuration = 0.5
var flopThreshold = 0.8
var flopCurCount = 0
var flopMaxCount = 4

@export var grouperBubble: PackedScene
var bubbleOffset = 5
var bubbleTimer = 0.1
var bubbleSizeMin = 0.25
var bubbleSizeMax = 0.5

func _ready() -> void:
	super()
	if !attacksDisabled:
		$AttackCooldownTimer.one_shot = true
		$AttackDurationTimer.one_shot = true
		new_attack_cycle(splashCooldownMin, splashCooldownMax)
func _on_attack_cooldown_timer_timeout() -> void:
	if disarm_check(): 
		new_attack_cycle(splashCooldownMin, splashCooldownMax)
	else:
		dive_or_flop()

# Dive
func dive_or_flop() -> void:
	if flopChaining:
		dive_for_flop()
	else:
		dive_for_splash()
	$BubbleTimer.start(bubbleTimer)
func dive_for_splash() -> void:
	$Status.start_void(splashDiveDuration)
	$Status.start_sprint(splashDiveDuration)
	$AttackDurationTimer.start(splashDiveDuration)
func dive_for_flop() -> void:
	$Status.start_void(flopDiveDuration)
	$Status.start_sprint(flopDiveDuration)
	$AttackDurationTimer.start(flopDiveDuration)

# Splash
func _on_attack_duration_timer_timeout() -> void:
	splash_attack()
	try_to_flop()
func splash_attack() -> void:
	var newAttack = splashAttackScene.instantiate()
	newAttack.position = self.position
	newAttack.dmg = self.dmg
	newAttack.attackName = "Splash"
	newAttack.scaleMod = randf_range(splashScaleMin, splashScaleMax)
	newAttack.dur = splashDuration
	$AttackContainer.add_child(newAttack)

# Flop
func try_to_flop() -> void:
	var chainChance = randf_range(0, 1)
	if chainChance < flopChainChance && flopCurCount < flopMaxCount:
		flop_success()
	else:
		flop_conclusion()
func flop_success() -> void:
	flopChaining = true
	direction = get_flop_direction()
	flopCurCount += 1
	$AttackCooldownTimer.start(flopInitialDelay)
func flop_conclusion() -> void:
	flopChaining = false
	flopCurCount = 0
	$BubbleTimer.stop()
	$Status.start_stuck(1.0, self)
	new_attack_cycle(splashCooldownMin, splashCooldownMax)
func get_flop_direction() -> Vector2:
	var curDist = position.distance_to(center)
	if curDist > (flopThreshold * board.boardRadius):
		return(new_direction())
	else:
		return(Vector2.RIGHT.rotated(randf_range(0, TAU)))

# Bubbles
func _on_bubble_timer_timeout() -> void:
	var newBubble = grouperBubble.instantiate()
	var ranX = randi_range(-bubbleOffset, bubbleOffset)
	var ranY = randi_range(-bubbleOffset, bubbleOffset)
	newBubble.position = self.position + Vector2(ranX, ranY)
	var newScale = randf_range(bubbleSizeMin, bubbleSizeMax)
	newBubble.scale.x = newScale
	newBubble.scale.y = newScale
	$AttackContainer.add_child(newBubble)
	#$BubbleTimer.start(bubbleTimer)
