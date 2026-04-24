extends "res://pawns/base/base_pawn.gd"

@export var blinkScene: Resource
var blinkCooldownMin = 3.0
var blinkCooldownMax = 5.0
var blinkChainPercent = 50
var blinkDistMin = 50
var blinkBox = 50


@export var baseSprite: Resource
@export var warpSprite: Resource
var warpActive = false
var warpVoidTimer = 100
var warpCooldown = 10
var warpTravelSpeed = 5

func _ready() -> void:
	super()

	if !attacksDisabled:
		start_attack_cooldown()
		$WarpCooldownTimer.one_shot = true

func _physics_process(delta: float) -> void:
	#super(delta) 
	
	# Pawn movement
	var boardRadius = get_parent().boardRadius
	var distFromCenter = global_position.distance_to(center)
	if distFromCenter >= boardRadius && $DirectionDelayTimer.is_stopped():
		if !attacksDisabled && !warpActive && $WarpCooldownTimer.is_stopped():
			$WarpCooldownTimer.start(warpCooldown)
			warpActive = true
			$AttackCooldownTimer.stop()
			$BlinkDelayTimer.stop()
			$Status.start_void(warpVoidTimer)
			#spd *= 5
			$PawnSprite.texture = warpSprite
			direction = position.direction_to(center)
			$DirectionDelayTimer.start()
		else:
			if warpActive:
				warpActive = false
				start_attack_cooldown()
				#spd /= 5
				$PawnSprite.texture = baseSprite
				$Status.stop_void()
				$Status.start_void(0.01)
			direction = new_direction()
			$DirectionDelayTimer.start()

	# Move Pawn with movement speed modifiers in mind
	var statusSpdMod = 1
	var warpMod = 0
	if warpActive: warpMod = warpTravelSpeed * (get_parent().boardRadius - position.distance_to(center))
	else:
		if !$Status.get_node("SprintStatusTimer").is_stopped(): statusSpdMod *= sprintSpeed
		if !$Status.get_node("SlowStatusTimer").is_stopped(): statusSpdMod *= slowSpeed
		if !$Status.get_node("StuckStatusTimer").is_stopped(): statusSpdMod *= stuckSpeed
	position += direction * (spd + warpMod) * statusSpdMod * delta
#func new_warpion() -> Vector2:

func _on_attack_cooldown_timer_timeout() -> void:
	start_attack_cooldown()
	if disarm_check(): return
	
	var newBlink = blinkScene.instantiate()
	newBlink.position = position
	newBlink.dmg = self.dmg
	newBlink.attackName = "Blink"
	$AttackContainer.add_child(newBlink)
	attackObjects.append(newBlink)
	recursive_attack_routine()

func start_attack_cooldown() -> void:
	var blinkCooldown = randf_range(blinkCooldownMin, blinkCooldownMax)
	if blinkCooldown > $AttackCooldownTimer.get_time_left():
		$AttackCooldownTimer.start(asp * blinkCooldown)

func recursive_attack_routine() -> void:

	var newBlink = blinkScene.instantiate()
	newBlink.position = position
	newBlink.dmg = self.dmg
	newBlink.attackName = "Blink"
	$AttackContainer.add_child(newBlink)
	attackObjects.append(newBlink)

	position = find_eligible_location()
	if randi_range(0, 1) == 0: $BlinkDelayTimer.start()
	else:
		var newBlink2 = blinkScene.instantiate()
		newBlink2.position = position
		newBlink2.dmg = self.dmg
		newBlink2.attackName = "Blink"
		$AttackContainer.add_child(newBlink2)
		attackObjects.append(newBlink2)

func _on_blink_delay_timer_timeout() -> void:
	direction = new_direction()
	recursive_attack_routine()

func find_eligible_location() -> Vector2:
	var newOffset = Vector2(randf_range(-blinkBox, blinkBox), randf_range(-blinkBox, blinkBox))
	var newPos = position + newOffset
	while newPos.distance_to(center) > get_parent().boardRadius || position.distance_to(newPos) < blinkDistMin:
		newOffset = Vector2(randf_range(-blinkBox, blinkBox), randf_range(-blinkBox, blinkBox))
		newPos = position + newOffset
	return(newPos)
