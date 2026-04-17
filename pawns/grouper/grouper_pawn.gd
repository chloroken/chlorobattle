extends "res://pawns/base/base_pawn.gd"

@export var grouperAttack: PackedScene
@export var grouperBubble: PackedScene

var diveSpeedModifier = 20
var bubbleOffset = 5
var bubbleTimer = 0.25
var diveSpeedDuration = 2.0

# Dive splash attack
func _on_attack_cooldown_timer_timeout() -> void:
	var newAttack = grouperAttack.instantiate()
	newAttack.position = self.position
	newAttack.dmg = self.dmg
	attackObjects.append(newAttack)
	$AttackContainer.add_child(newAttack)
	$AttackDurationTimer.start(diveSpeedDuration)
	$AttackCooldownTimer.start(asp * baseAttackCooldown)

	# Hide pawn & sprint
	$Status.phase_out_pawn(diveSpeedDuration)
	$Status.start_sprinting(diveSpeedDuration)

	$BubbleTimer.start(asp * bubbleTimer)
	$AttackCooldownTimer.start($AttackCooldownTimer.get_wait_time() + random_variance())

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
	newBubble.dmg = self.dmg / 10
	$AttackContainer.add_child(newBubble)
	$BubbleTimer.start(asp * bubbleTimer)
