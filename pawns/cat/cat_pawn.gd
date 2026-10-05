extends "res://pawns/_base/base_pawn.gd"

@export var swipeAttackScene: Resource
var swipeAttackName = "Swipe"
var swipeCooldownMin = 2.0
var swipeCooldownMax = 3.0
var swipeDuration = 1.0
var swipeRotateDistance = 48
var gemRedCooldownMin = 4.0
var gemRedCooldownMax = 6.0
var gemRedReady = false
var swipeBleedDuration = 5.0
var swipeRedScale = 2.0

@export var yarnAttackScene: Resource
var yarnAttackName = "Yarn"
var yarnIsAreaAttack = false
var gemYellowCooldownMin = 12.0
var gemYellowCooldownMax = 15.0
var gemYellowReady = false
var yarnDuration = 10.0
var yarnLazyDuration = 10.0
var yarnOffset = 16

@export var meowAttackScene: Resource
var meowAttackName = "Meow"
var meowIsAreaAttack = false
var gemPurpleCooldownMin = 8.0
var gemPurpleCooldownMax = 10.0
var gemPurpleReady = false
var meowDamageMultiplier = 0.5
var meowArcWidth = 0.75
var meowDurationMin = 2.5
var meowDurationMax = 5.0
var meowSpeedMin = 50
var meowSpeedMax = 100
var meowPeriodDuration = 2.5
var meowStaggerInterval = 0.1

func _ready() -> void:
	super()
	if !attacksDisabled:
		new_attack_cycle(swipeCooldownMin, swipeCooldownMax)
		start_cat_timers()
func start_cat_timers() -> void:
	$SwipeTimer.one_shot = true
	$Gem1Timer.one_shot = true
	$Gem2Timer.one_shot = true
	$Gem3Timer.one_shot = true
	$MeowStaggerTimer.one_shot = true
	$MeowDurationTimer.one_shot = true
	$Gem1Timer.start(randf_range(gemRedCooldownMin, gemRedCooldownMax))
	$Gem2Timer.start(randf_range(gemPurpleCooldownMin, gemPurpleCooldownMax))
	$Gem3Timer.start(randf_range(gemYellowCooldownMin, gemYellowCooldownMax))
func _process(_delta: float) -> void:
	if !attacksDisabled:
		update_cat_gem_sprites()
func _physics_process(delta: float) -> void:
	super(delta)
	swipe_rotation_physics()
func update_cat_gem_sprites() -> void:
		if $Gem1Timer.is_stopped():
			$Gem1Sprite.modulate = Color.INDIAN_RED
			$Gem1Sprite.modulate.a = 1.0
		else:
			$Gem1Sprite.modulate.a = 0.0
		if $Gem2Timer.is_stopped():
			$Gem2Sprite.modulate = Color.GOLD
			$Gem2Sprite.modulate.a = 1.0
		else:
			$Gem2Sprite.modulate.a = 0.0
		if $Gem3Timer.is_stopped():
			$Gem3Sprite.modulate = Color.MEDIUM_PURPLE
			$Gem3Sprite.modulate.a = 1.0
		else:
			$Gem3Sprite.modulate.a = 0.0
func swipe_rotation_physics() -> void:
	if !$SwipeTimer.is_stopped():
		var ratio = $SwipeTimer.get_time_left() / $SwipeTimer.get_wait_time()
		$PawnSprite.rotation = ratio * 2 * PI

# Attack routine
func _on_attack_cooldown_timer_timeout() -> void:
	new_attack_cycle(swipeCooldownMin, swipeCooldownMax)
	if disarm_check(): return
	if !try_meow_attack():
		if !try_yarn_attack():
			swipe_attack()

# Swipe attack
func swipe_attack() -> void:
	$SwipeTimer.start(swipeDuration)
	var swipes = []

	# Paw 1
	var newAttack1 = swipeAttackScene.instantiate()
	newAttack1.swipeDir = 1
	swipes.append(newAttack1)
	$AttackContainer.add_child(newAttack1)

	# Paw 2
	var newAttack2 = swipeAttackScene.instantiate()
	swipes.append(newAttack2)
	newAttack2.swipeDir = -1
	$AttackContainer.add_child(newAttack2)

	# Red swipe check
	if $Gem1Timer.is_stopped():
		$Gem1Timer.start(randf_range(gemRedCooldownMin, gemRedCooldownMax))
		var redSwipes = []
		redSwipes.append(newAttack1)
		redSwipes.append(newAttack2)

		# Paw 3
		var newAttack3 = swipeAttackScene.instantiate()
		swipes.append(newAttack3)
		redSwipes.append(newAttack3)
		newAttack3.extraPaw = true
		newAttack3.swipeDir = 1
		$AttackContainer.add_child(newAttack3)

		# Paw 4
		var newAttack4 = swipeAttackScene.instantiate()
		swipes.append(newAttack4)
		redSwipes.append(newAttack4)
		newAttack4.extraPaw = true
		newAttack4.swipeDir = -1
		$AttackContainer.add_child(newAttack4)

		# Convert to red paws
		for redPaw in redSwipes:
			redPaw.redSwipe = true
			redPaw.scale *= swipeRedScale
			redPaw.isRedSwipeAttack = true

	# Finalize paws
	for paw in swipes:
		paw.dmg = self.dmg
		paw.position = self.position
		paw.attackName = swipeAttackName

# Yarn attack
func try_yarn_attack() -> bool:
	if $Gem2Timer.is_stopped():
		var newAttack = yarnAttackScene.instantiate()
		newAttack.attackName = yarnAttackName
		newAttack.isYarnAttack = true
		newAttack.areaAttack = yarnIsAreaAttack
		newAttack.position = good_yarn_position() + position
		newAttack.dmg = self.dmg
		$Gem2Timer.start(randf_range(gemPurpleCooldownMin, gemPurpleCooldownMax))
		$AttackContainer.add_child(newAttack)
		return(true)
	return(false)
func good_yarn_position() -> Vector2:
	var boardRadius = board.boardRadius
	var newPos = try_yarn_position()
	while newPos.distance_to(center) > boardRadius:
		newPos = try_yarn_position()
	return(newPos)
func try_yarn_position() -> Vector2:
	var offset = yarnOffset
	return(Vector2(randf_range(-offset, offset), randf_range(-offset, offset)))

# Meow attack
func try_meow_attack() -> bool:
	if $Gem3Timer.is_stopped() && $MeowDurationTimer.is_stopped():
		$MeowDurationTimer.start(meowPeriodDuration)
		$MeowStaggerTimer.start(meowStaggerInterval)
		$Status.start_stuck(meowPeriodDuration, self)
		return(true)
	return(false)
func _on_meow_stagger_timer_timeout() -> void:
	var newAttack = meowAttackScene.instantiate()
	newAttack.position = position
	newAttack.attackName = meowAttackName
	newAttack.areaAttack = meowIsAreaAttack
	newAttack.dmg = self.dmg * meowDamageMultiplier
	newAttack.speed = randf_range(meowSpeedMin, meowSpeedMax)
	newAttack.duration = randf_range(meowDurationMin, meowDurationMax)
	newAttack.direction = direction.rotated(randf_range(-meowArcWidth, meowArcWidth))
	newAttack.rotation = randf_range(0, TAU)
	$AttackContainer.add_child(newAttack)
	$MeowStaggerTimer.start(meowStaggerInterval)
func _on_meow_duration_timer_timeout() -> void:
	$MeowStaggerTimer.stop()
	$Gem3Timer.start(randf_range(gemYellowCooldownMin, gemYellowCooldownMax))
