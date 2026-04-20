extends "res://pawns/base/base_pawn.gd"

@export var grouperAttack: PackedScene
@export var grouperBubble: PackedScene

var diveSpeedModifier = 20
var bubbleOffset = 5
var bubbleTimer = 0.1
var diveSpeedDuration = 1.5

func _ready() -> void:
	super()
	if !attacksDisabled:
		$AttackCooldownTimer.one_shot = true
		$AttackCooldownTimer.start(asp * baseAttackCooldown + random_variance())

# Dive splash attack
func _on_attack_cooldown_timer_timeout() -> void:
	var newAttack = grouperAttack.instantiate()
	newAttack.position = self.position
	newAttack.dmg = self.dmg
	attackObjects.append(newAttack)
	$AttackContainer.add_child(newAttack)
	$AttackDurationTimer.start(diveSpeedDuration)
	$AttackCooldownTimer.start(asp * baseAttackCooldown + random_variance())

	# Hide pawn & sprint
	$Status.start_phase(diveSpeedDuration)
	$Status.start_sprint(diveSpeedDuration)

	$BubbleTimer.start(bubbleTimer)#(asp * bubbleTimer)
	#$AttackCooldownTimer.start($AttackCooldownTimer.get_wait_time() + random_variance())

# Emerge splash attack
func _on_attack_duration_timer_timeout() -> void:
	var newAttack = grouperAttack.instantiate()
	newAttack.position = self.position
	newAttack.dmg = self.dmg
	$AttackContainer.add_child(newAttack)
	attackObjects.append(newAttack)

	# Reveal pawn
	$BubbleTimer.stop()

# Drop bubbles while underwater for effect
func _on_bubble_timer_timeout() -> void:
	var newBubble = grouperBubble.instantiate()
	var ranX = randi_range(-bubbleOffset, bubbleOffset)
	var ranY = randi_range(-bubbleOffset, bubbleOffset)
	newBubble.position = self.position + Vector2(ranX, ranY)
	#newBubble.dmg = self.dmg / 10
	$AttackContainer.add_child(newBubble)
	$BubbleTimer.start(bubbleTimer)#(asp * bubbleTimer)
