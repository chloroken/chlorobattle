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
	
	# Start attack routine
	$BubbleTimer.one_shot = true
	if !attacksDisabled:
		$AttackCooldownTimer.one_shot = true
		$AttackCooldownTimer.start(asp * randf_range(splashCooldownMin, splashCooldownMax) + random_variance())

func _on_attack_cooldown_timer_timeout() -> void:
	
	# Create splash attack for "dive"
	var newAttack = grouperAttack.instantiate()
	newAttack.position = self.position
	newAttack.dmg = self.dmg
	newAttack.scaleMod = randf_range(splashScaleMin, splashScaleMax)
	attackObjects.append(newAttack)
	$AttackContainer.add_child(newAttack)

	# Hide pawn & sprint
	$Status.start_phase(diveSpeedDuration)
	$Status.start_sprint(diveSpeedDuration)

	# Start timers
	$BubbleTimer.start(bubbleTimer)
	$AttackDurationTimer.start(diveSpeedDuration)
	$AttackCooldownTimer.start(asp * randf_range(splashCooldownMin, splashCooldownMax) + random_variance())

func _on_attack_duration_timer_timeout() -> void:

	# Create splash attack for "resurface"
	var newAttack = grouperAttack.instantiate()
	newAttack.position = self.position
	newAttack.dmg = self.dmg
	newAttack.scaleMod = randf_range(splashScaleMin, splashScaleMax)
	$AttackContainer.add_child(newAttack)
	attackObjects.append(newAttack)

	# Stop bubbles
	$BubbleTimer.stop()

# Drop bubbles while underwater for visual clarity
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
