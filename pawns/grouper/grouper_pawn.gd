extends "res://pawns/base/base_pawn.gd"

@export var grouperAttack: PackedScene
@export var grouperBubble: PackedScene

var diveSpeedModifier = 10
var bubbleOffset = 10

# Dive splash attack
func _on_attack_cooldown_timer_timeout() -> void:
	var newAttack = grouperAttack.instantiate()
	newAttack.position = self.position
	newAttack.dmg = self.dmg
	attackObjects.append(newAttack)
	$AttackContainer.add_child(newAttack)
	$AttackDurationTimer.start()
	$AttackCooldownTimer.start()
	
	# Hide pawn
	spd *= diveSpeedModifier
	set_collision_mask_value(1, false)
	$PawnSprite.visible = false
	$NameLabel.visible = false
	$BubbleTimer.start()

# Emerge splash attack
func _on_attack_duration_timer_timeout() -> void:
	var newAttack = grouperAttack.instantiate()
	newAttack.position = self.position
	newAttack.dmg = self.dmg
	$AttackContainer.add_child(newAttack)
	attackObjects.append(newAttack)

	# Reveal pawn
	spd /= diveSpeedModifier
	set_collision_mask_value(1, true)
	$PawnSprite.visible = true
	$NameLabel.visible = true
	$BubbleTimer.stop()
	
	# Reset cycle
	$AttackCooldownTimer.start($AttackCooldownTimer.get_wait_time() + random_variance())

# Drop bubbles while underwater for effect
func _on_bubble_timer_timeout() -> void:
	var newBubble = grouperBubble.instantiate()
	var ranX = randi_range(-bubbleOffset, bubbleOffset)
	var ranY = randi_range(-bubbleOffset, bubbleOffset)
	newBubble.position = self.position + Vector2(ranX, ranY)
	$AttackContainer.add_child(newBubble)
