extends "res://pawns/base/base_pawn.gd"


# Splash variables
@export var grouperAttack: PackedScene
var diveSpeedDuration = 1.5
var splashCooldownMin = 4.0
var splashCooldownMax = 5.0
var splashScaleMin = 1.0
var splashScaleMax = 2.0

# Bubble variables
@export var grouperBubble: PackedScene
var bubbleOffset = 5
var bubbleTimer = 0.1
var bubbleSizeMin = 0.25
var bubbleSizeMax = 0.5

func _ready() -> void:
	super()
	
	$BubbleTimer.one_shot = true
	
	# Start attack routine
	if !attacksDisabled:
		$AttackCooldownTimer.one_shot = true
		$AttackDurationTimer.one_shot = true
		start_attack_cooldown()

func _on_attack_cooldown_timer_timeout() -> void:
	start_attack_cooldown()
	if disarm_check(): return
	
	splash_attack()

	# Hide pawn & sprint
	$Status.start_void(diveSpeedDuration)
	$Status.start_sprint(diveSpeedDuration)

	# Start timers
	$BubbleTimer.start(bubbleTimer)
	$AttackDurationTimer.start(diveSpeedDuration)

func _on_attack_duration_timer_timeout() -> void:
	splash_attack()
	$BubbleTimer.stop()

func start_attack_cooldown() -> void:
	$AttackCooldownTimer.start(asp * randf_range(splashCooldownMin, splashCooldownMax) + random_variance())

func splash_attack() -> void:
	var newAttack = grouperAttack.instantiate()
	newAttack.position = self.position
	newAttack.dmg = self.dmg
	newAttack.attackName = "Splash"
	newAttack.scaleMod = randf_range(splashScaleMin, splashScaleMax)
	attackObjects.append(newAttack)
	$AttackContainer.add_child(newAttack)

func _on_bubble_timer_timeout() -> void:
	var newBubble = grouperBubble.instantiate()
	var ranX = randi_range(-bubbleOffset, bubbleOffset)
	var ranY = randi_range(-bubbleOffset, bubbleOffset)
	newBubble.position = self.position + Vector2(ranX, ranY)
	var newScale = randf_range(bubbleSizeMin, bubbleSizeMax)
	newBubble.scale.x = newScale
	newBubble.scale.y = newScale
	$AttackContainer.add_child(newBubble)
	$BubbleTimer.start(bubbleTimer)
