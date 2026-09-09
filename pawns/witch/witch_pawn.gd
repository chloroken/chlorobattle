extends "res://pawns/_base/base_pawn.gd"

@export var blinkScene: Resource
var blinkCooldownMin = 3.0
var blinkCooldownMax = 5.0
var blinkChainPercent = 50
var blinkDistMin = 30
var blinkBox = 30
#var blinkDmgNormal = 1.0
#var blinkDecayMod = 0.9
#var blinkDmgModFloor = 0.5

# Active blink variables
var blinkDmgMod = 1.0
var blinkCount = 0

@export var costumeSprite: Resource
@export var baseSprite: Resource
@export var warpSprite: Resource
@export var warpParticle: Resource
var warpActive = false
var warpVoidTimer = 100
var warpCooldown = 10
var warpTravelSpeed = 100
var warpParticleRate = 0.05

# Cauldron attack variables
@export var cauldronAttack: Resource
var cauldronCooldownMin = 10.0
var cauldronCooldownMax = 15.0
var cauldronFizzleDuration = 10.0
var cauldronLazyDuration = 5.0

# Frog attack variables
@export var frogAttack: Resource

func _ready() -> void:
	super()

	if !attacksDisabled:
		start_attack_cooldown()
		start_cauldron_cooldown()
		$WarpCooldownTimer.one_shot = true
		$WarpParticleTimer.one_shot = true

func start_attack_cooldown() -> void:
	var blinkCooldown = asp * aspMod * randf_range(blinkCooldownMin, blinkCooldownMax)
	$AttackCooldownTimer.start(blinkCooldown)

func start_cauldron_cooldown() -> void:
	var cauldronCooldown = asp * aspMod * randf_range(cauldronCooldownMin, cauldronCooldownMax)
	$CauldronCooldownTimer.start(cauldronCooldown)

func _on_attack_cooldown_timer_timeout() -> void:
	if disarm_check():
		start_attack_cooldown()
		return
	if !$Status.get_node("StuckStatusTimer").is_stopped():
		start_attack_cooldown()
		return
	recursive_attack_routine()

func recursive_attack_routine() -> void:
	
	# Make a frog
	var newFrog = frogAttack.instantiate()
	newFrog.position = position
	newFrog.dmg = self.dmg
	newFrog.attackName = "Frog"
	$AttackContainer.add_child(newFrog)

	# Drop an attack at feet
	#var newBlink = blinkScene.instantiate()
	#newBlink.position = position
	#newBlink.dmg = self.dmg * blinkDmgMod
	#newBlink.scale = Vector2.ONE * blinkDmgMod
	#newBlink.attackName = "Blink"
	#$AttackContainer.add_child(newBlink)
	blinkCount += 1

	# Teleport a short distance away
	position = find_eligible_location()
	
	#blinkDmgMod = max(blinkDmgModFloor, blinkDmgMod * blinkDecayMod)

	# Chaining mechanic
	if randi_range(0, 1) == 0:
		$BlinkDelayTimer.start()
		$Status.start_void($BlinkDelayTimer.get_wait_time())

	# End the chain
	else:
		# Make a frog
		var newFrog2 = frogAttack.instantiate()
		newFrog2.position = position
		newFrog2.dmg = self.dmg * blinkDmgMod
		newFrog2.attackName = "Frog"
		$AttackContainer.add_child(newFrog2)
		
		#var newBlink2 = blinkScene.instantiate()
		#newBlink2.position = position
		#newBlink2.dmg = self.dmg * blinkDmgMod
		#newBlink2.scale = Vector2.ONE * blinkDmgMod
		#newBlink2.attackName = "Blink"
		#$AttackContainer.add_child(newBlink2)

		# Show combo count
		if blinkCount > 1:
			$BlinkRevealTimer.start()
			$BlinkCountLabel.text = str(blinkCount) + "x"

		blinkCount = 0
		#blinkDmgMod = blinkDmgNormal
		start_attack_cooldown()
		#direction = new_direction()

func _on_blink_delay_timer_timeout() -> void:
	recursive_attack_routine()

func find_eligible_location() -> Vector2:
	var newOffset = Vector2(randf_range(-blinkBox, blinkBox), randf_range(-blinkBox, blinkBox))
	var newPos = position + newOffset
	while newPos.distance_to(center) > get_parent().boardRadius || position.distance_to(newPos) < blinkDistMin:
		newOffset = Vector2(randf_range(-blinkBox, blinkBox), randf_range(-blinkBox, blinkBox))
		newPos = position + newOffset
	return(newPos)

func _process(_delta: float) -> void:
	if $BlinkRevealTimer.is_stopped():
		$BlinkCountLabel.modulate.a = 0.0
	else:
		$BlinkCountLabel.modulate.a = max(0.5, $BlinkRevealTimer.get_time_left() / $BlinkRevealTimer.get_wait_time())

########
# WARP #
########

func _on_area_exited(area: Area2D) -> void:
	if self.is_queued_for_deletion(): return
	if area.get_collision_layer_value(6):#areaType == "board":
		# Warp
		if !attacksDisabled:
			if !warpActive && $WarpCooldownTimer.is_stopped():
				warpActive = true
				$WarpParticleTimer.start(warpParticleRate)
				$Status.start_void(warpVoidTimer)
				$AttackCooldownTimer.stop()
				$BlinkDelayTimer.stop()
				$PawnSprite.texture = warpSprite
				direction = position.direction_to(center)
				$GUI.visible = false
			elif warpActive:
				warpActive = false
				$WarpParticleTimer.stop()
				$WarpCooldownTimer.start(warpCooldown)
				$Status.stop_void()
				$Status.start_void(0.1)
				start_attack_cooldown()
				$PawnSprite.texture = spriteArray[costume-1]
				direction = new_direction()
				$GUI.visible = true
			else:
				direction = new_direction()
		else:
			direction = new_direction()

func _physics_process(delta: float) -> void:

	# Undo super() movement
	if warpActive:
		#var warpRatio = 1 - position.distance_to(center) / get_parent().boardRadius
		var dist = get_parent().boardRadius - position.distance_to(center)
		position += direction * max(warpTravelSpeed, dist) * delta
		rotation = direction.angle()
	else:
		# Adjust speed based on statuses
		statusSpdMod = normalSpeed
		if !$Status.get_node("SprintStatusTimer").is_stopped(): statusSpdMod *= sprintSpeed
		if !$Status.get_node("SlowStatusTimer").is_stopped(): statusSpdMod *= slowSpeed
		if !$Status.get_node("StuckStatusTimer").is_stopped(): statusSpdMod *= stuckSpeed

		# Move Pawn
		position += direction * spd * statusSpdMod * delta
		rotation = Vector2.RIGHT.angle()

func _on_warp_particle_timer_timeout() -> void:
	var newParticle = warpParticle.instantiate()
	newParticle.position = position
	$AttackContainer.add_child(newParticle)
	$WarpParticleTimer.start(warpParticleRate)

############
# CAULDRON #
############

func _on_cauldron_cooldown_timer_timeout() -> void:
	var newCauldron = cauldronAttack.instantiate()
	newCauldron.position = position
	newCauldron.dmg = self.dmg
	newCauldron.attackName = "Cauldron"
	newCauldron.duration = cauldronFizzleDuration
	$AttackContainer.add_child(newCauldron)
