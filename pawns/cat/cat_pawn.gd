extends "res://pawns/_base/base_pawn.gd"

@export var catSwipe: Resource
@export var catMeow: Resource
@export var catYarn: Resource

var catSwipeCooldownMin = 2.0
var catSwipeCooldownMax = 3.0
var catSwipeDuration = 1.0
var catRotateDistance = 32

var catSwipeBleedDuration = 5.0
var catMeowDuration = 2.5
var catStaggerDuration = 0.1
var catYarnLazyDuration = 10.0
var catMeowDamage = 25

var catGemRedCooldownMin = 4
var catGemRedCooldownMax = 5
var catGemRedReady = false # causes bleed
var catGemBlueCooldownMin = 8
var catGemBlueCooldownMax = 10
var catGemBlueReady = false # jumps away
var catGemYellowCooldownMin = 12
var catGemYellowCooldownMax = 15
var catGemYellowReady = false # meow cone

func _ready() -> void:
	super()
	if !attacksDisabled:
		start_attack_cooldown()
		$SwipeTimer.one_shot = true
		$Gem1Timer.one_shot = true
		$Gem2Timer.one_shot = true
		$Gem3Timer.one_shot = true
		$Gem1Timer.start(randf_range(catGemRedCooldownMin, catGemRedCooldownMax))
		$Gem2Timer.start(randf_range(catGemBlueCooldownMin, catGemBlueCooldownMax))
		$Gem3Timer.start(randf_range(catGemYellowCooldownMin, catGemYellowCooldownMax))
		$MeowStaggerTimer.one_shot = true
		$MeowDurationTimer.one_shot = true

func _process(_delta: float) -> void:
	if !attacksDisabled:
		if $Gem1Timer.is_stopped(): $Gem1Sprite.modulate = Color.INDIAN_RED
		else: $Gem1Sprite.modulate = Color.WHITE
		if $Gem2Timer.is_stopped(): $Gem2Sprite.modulate = Color.GOLD
		else: $Gem2Sprite.modulate = Color.WHITE
		if $Gem3Timer.is_stopped(): $Gem3Sprite.modulate = Color.MEDIUM_PURPLE
		else: $Gem3Sprite.modulate = Color.WHITE

func _physics_process(delta: float) -> void:
	super(delta)
	if !$SwipeTimer.is_stopped():
		var ratio = $SwipeTimer.get_time_left() / $SwipeTimer.get_wait_time()
		$PawnSprite.rotation = ratio * 2 * PI

func start_attack_cooldown() -> void:
	var swipeCooldown = asp * aspMod * randf_range(catSwipeCooldownMin, catSwipeCooldownMax)
	$AttackCooldownTimer.start(swipeCooldown)

func _on_attack_cooldown_timer_timeout() -> void:
	if disarm_check():
		start_attack_cooldown()
		return
	
	if $Gem3Timer.is_stopped() && $MeowDurationTimer.is_stopped():
		$MeowDurationTimer.start(catMeowDuration)
		$MeowStaggerTimer.start(catStaggerDuration)
		$Status.start_stuck(catMeowDuration, self)
	else:
		if $Gem2Timer.is_stopped():
			var newAttack = catYarn.instantiate()
			newAttack.position = good_yarn_position() + position
			newAttack.dmg = self.dmg
			$Gem2Timer.start(randf_range(catGemBlueCooldownMin, catGemBlueCooldownMax))
			$AttackContainer.add_child(newAttack)
			start_attack_cooldown()
		else:
			var newAttack = catSwipe.instantiate()
			newAttack.position = position + Vector2.LEFT * catRotateDistance
			newAttack.dmg = self.dmg
			newAttack.swipeDir = 1

			var newAttack2 = catSwipe.instantiate()
			newAttack2.position = position + Vector2.LEFT * catRotateDistance
			newAttack2.dmg = self.dmg
			newAttack2.swipeDir = -1

			if $Gem1Timer.is_stopped():
				newAttack.redSwipe = true
				newAttack.scale *= 2
				newAttack2.redSwipe = true
				newAttack2.scale *= 2
				$Gem1Timer.start(randf_range(catGemRedCooldownMin, catGemRedCooldownMax))

			$AttackContainer.add_child(newAttack)
			$AttackContainer.add_child(newAttack2)
			$SwipeTimer.start(catSwipeDuration)
			start_attack_cooldown()

func good_yarn_position() -> Vector2:
	var boardRadius = board.boardRadius
	var newPos = try_yarn_position()
	while newPos.distance_to(center) > boardRadius:
		newPos = try_yarn_position()
	return(newPos)

func try_yarn_position() -> Vector2:
	var offset = 16
	return(Vector2(randf_range(-offset, offset), randf_range(-offset, offset)))

func _on_meow_stagger_timer_timeout() -> void:
	var newAttack = catMeow.instantiate()
	newAttack.position = position
	newAttack.dmg = catMeowDamage
	newAttack.direction = direction.rotated(randf_range(-0.75, 0.75))
	newAttack.rotation = randf_range(0, TAU)
	$AttackContainer.add_child(newAttack)
	$MeowStaggerTimer.start(catStaggerDuration)

func _on_meow_duration_timer_timeout() -> void:
	$MeowStaggerTimer.stop()
	$Gem3Timer.start(randf_range(catGemYellowCooldownMin, catGemYellowCooldownMax))
	start_attack_cooldown()
