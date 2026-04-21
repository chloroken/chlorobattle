extends "res://pawns/base/base_pawn.gd"

# Form variables
@export var jetFormSprite: Resource
@export var mechaFormSprite: Resource
var mechaForm = false
var formSwapTimer = 10.0
var formSwapVariance = 2.0

# Jet variables
@export var bombAttack: PackedScene
@export var bombExplosion: PackedScene
var bombCooldownMin = 2.0
var bombCooldownMax = 3.0
var bombConeArc = .25
var bombConeMin = .10
var bombSpeedMod = 8
var bombDuration = 0.5

# Melee variables
@export var whirlwindAttack: PackedScene
var whirlwindCooldownMin = 3.0
var whirlwindCooldownMax = 4.0
var whirlwindDmgMod = 2.0

func _ready() -> void:
	super()

	# Pick a random form to start in
	if randi_range(0, 1) == 1: mechaForm = true
	else: mechaForm = false
	$FormSwapTimer.one_shot = true
	$FormSwapTimer.start(0.1)

	# Start attack cycle
	if !attacksDisabled:
		$AttackCooldownTimer.one_shot = true
		$AttackCooldownTimer.start(asp * randf_range(bombCooldownMin, bombCooldownMax) + random_variance())

func _process(_delta: float) -> void:
	super(_delta)

	# Turn to face direction in Jet form
	if !mechaForm:
		$PawnSprite.look_at(destination)
		$PawnSprite.texture = jetFormSprite
	else:
		$PawnSprite.rotation = 0.0
		$PawnSprite.texture = mechaFormSprite

func _on_attack_cooldown_timer_timeout() -> void:

	# Melee attack
	if mechaForm:
		var newAttack = whirlwindAttack.instantiate()
		newAttack.position = self.position
		newAttack.dmg = self.dmg * whirlwindDmgMod
		newAttack.direction = randf_range(0, TAU)
		attackObjects.append(newAttack)
		$AttackContainer.add_child(newAttack)
		
		
		$AttackCooldownTimer.start(asp * randf_range(whirlwindCooldownMin, whirlwindCooldownMax) + random_variance())

	# Jet attack
	else:
		var newAtkArc = randf_range(bombConeMin, bombConeArc)

		# Guided bomb 1
		var newAttack = bombAttack.instantiate()
		newAttack.position = self.position
		newAttack.dmg = self.dmg
		newAttack.direction = self.position.direction_to(self.destination).rotated(newAtkArc)
		newAttack.speed = self.spd * bombSpeedMod
		newAttack.duration = bombDuration
		attackObjects.append(newAttack)
		$AttackContainer.add_child(newAttack)

		# Guided bomb 2
		var newAttack2 = bombAttack.instantiate()
		newAttack2.position = self.position
		newAttack2.dmg = self.dmg
		newAttack2.direction = self.position.direction_to(self.destination).rotated(-newAtkArc)
		newAttack2.speed = self.spd * bombSpeedMod
		newAttack2.duration = bombDuration
		attackObjects.append(newAttack2)
		$AttackContainer.add_child(newAttack2)
		
		$AttackCooldownTimer.start(asp * randf_range(bombCooldownMin, bombCooldownMax) + random_variance())

# Called by bombs when they expire
func make_explosion(loc: Vector2) -> void:
	var newAttack = bombExplosion.instantiate()
	newAttack.position = loc
	newAttack.dmg = self.dmg
	newAttack.areaAttack = true
	attackObjects.append(newAttack)
	$AttackContainer.add_child(newAttack)

func _on_form_swap_timer_timeout() -> void:
	
	# Calculate next form duration
	var form_offset_variance = randf_range(-formSwapVariance, formSwapVariance)
	$FormSwapTimer.start(formSwapTimer + form_offset_variance + random_variance())
	
	# Flip forms
	if mechaForm:
		if !attacksDisabled: $AttackCooldownTimer.start(random_variance())
		$Status.start_sprint(formSwapTimer + form_offset_variance)
	else:
		if !attacksDisabled: $AttackCooldownTimer.start(random_variance())
		$Status.start_slow(formSwapTimer + form_offset_variance)
	mechaForm = !mechaForm
