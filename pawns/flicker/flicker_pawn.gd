extends "res://pawns/base/base_pawn.gd"

@export var blinkScene: Resource
var blinkCooldownMin = 3.0
var blinkCooldownMax = 5.0
var blinkChainPercent = 50
var blinkDistMin = 50
var blinkBox = 50
var blinkDmgNormal = 1.0
var blinkDmgMod = 1.0
var blinkDecayMod = 0.9
var blinkDmgModFloor = 0.5
var blinkCount = 0

@export var baseSprite: Resource
@export var warpSprite: Resource
var warpActive = false
var warpVoidTimer = 100
var warpCooldown = 20
var warpTravelSpeed = 100

func _ready() -> void:
	super()

	if !attacksDisabled:
		start_attack_cooldown()
		$WarpCooldownTimer.one_shot = true

func _process(_delta: float) -> void:
	if $BlinkRevealTimer.is_stopped():
		$BlinkCountLabel.modulate.a = 0.0
	else:
		$BlinkCountLabel.modulate.a = max(0.5, $BlinkRevealTimer.get_time_left() / $BlinkRevealTimer.get_wait_time())

func _on_area_exited(area: Area2D) -> void:
	if area.areaType == "board":
		# Warp
		if !attacksDisabled:
			if !warpActive && $WarpCooldownTimer.is_stopped():
				$WarpCooldownTimer.start(warpCooldown)
				warpActive = true
				$Status.start_void(warpVoidTimer)
				$AttackCooldownTimer.stop()
				$BlinkDelayTimer.stop()
				$PawnSprite.texture = warpSprite
				direction = position.direction_to(center)
			elif warpActive:
				warpActive = false
				$Status.stop_void()
				$Status.start_void(0.1)
				start_attack_cooldown()
				$PawnSprite.texture = baseSprite
				direction = new_direction()
			else:
				direction = new_direction()
		else:
			direction = new_direction()

func _physics_process(delta: float) -> void:

	# Undo super() movement
	if warpActive:
		#var warpRatio = 1 - position.distance_to(center) / get_parent().boardRadius
		var dist = max(1, 0.1 * (get_parent().boardRadius - position.distance_to(center)))
		position += direction * warpTravelSpeed * dist * delta
	else:
		# Adjust speed based on statuses
		statusSpdMod = normalSpeed
		if !$Status.get_node("SprintStatusTimer").is_stopped(): statusSpdMod *= sprintSpeed
		if !$Status.get_node("SlowStatusTimer").is_stopped(): statusSpdMod *= slowSpeed
		if !$Status.get_node("StuckStatusTimer").is_stopped(): statusSpdMod *= stuckSpeed

		# Move Pawn
		position += direction * spd * statusSpdMod * delta

func _on_attack_cooldown_timer_timeout() -> void:
	if disarm_check(): return
	if !$Status.get_node("StuckStatusTimer").is_stopped(): return

	recursive_attack_routine()

func start_attack_cooldown() -> void:
	var blinkCooldown = randf_range(blinkCooldownMin, blinkCooldownMax)
	if blinkCooldown > $AttackCooldownTimer.get_time_left():
		$AttackCooldownTimer.start(asp * blinkCooldown)

func recursive_attack_routine() -> void:

	# Drop an attack at feet
	var newBlink = blinkScene.instantiate()
	newBlink.position = position
	newBlink.dmg = self.dmg * blinkDmgMod
	newBlink.scale = Vector2.ONE * blinkDmgMod
	newBlink.attackName = "Blink"
	$AttackContainer.add_child(newBlink)
	attackObjects.append(newBlink)
	blinkCount += 1

	# Teleport a short distance away
	position = find_eligible_location()
	
	blinkDmgMod = max(blinkDmgModFloor, blinkDmgMod * blinkDecayMod)

	# Chaining mechanic
	if randi_range(0, 1) == 0:
		$BlinkDelayTimer.start()

	# End the chain
	else:
		var newBlink2 = blinkScene.instantiate()
		newBlink2.position = position
		newBlink2.dmg = self.dmg * blinkDmgMod
		newBlink2.scale = Vector2.ONE * blinkDmgMod
		newBlink2.attackName = "Blink"
		$AttackContainer.add_child(newBlink2)
		attackObjects.append(newBlink2)

		# Show combo count
		if blinkCount > 1:
			$BlinkRevealTimer.start()
			$BlinkCountLabel.text = str(blinkCount) + "x"

		blinkCount = 0
		blinkDmgMod = blinkDmgNormal
		start_attack_cooldown()

func _on_blink_delay_timer_timeout() -> void:
	#direction = new_direction()
	recursive_attack_routine()

func find_eligible_location() -> Vector2:
	var newOffset = Vector2(randf_range(-blinkBox, blinkBox), randf_range(-blinkBox, blinkBox))
	var newPos = position + newOffset
	while newPos.distance_to(center) > get_parent().boardRadius && position.distance_to(newPos) > blinkDistMin:
		newOffset = Vector2(randf_range(-blinkBox, blinkBox), randf_range(-blinkBox, blinkBox))
		newPos = position + newOffset
	return(newPos)
