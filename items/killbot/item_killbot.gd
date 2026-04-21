extends CharacterBody2D

# Attack variables
@export var killbotAttack: PackedScene
var dmgBase = 10
var attackSpeedBase = 75
var attackCooldown = 0.5

# Stack variables
var killbotStacks = 1
var killbotMaxStacks = 3
var sizePerStack = 0.5
var dmgPerStack = 5
var attackSpeedPerStack = 25
var killbotStackTimer = 5.0

# Physics variables
var destination
var spd = 75
var follow = null
var following = false
var followDistanceMin = 20
var followDistanceMax = 100

# Special flags
var isPersistentSummon = true

func _ready() -> void:
	
	# Set visibility ordering
	z_as_relative = false
	z_index = get_node("/root/main").layerPawnBehind
	
	# Start timers
	$AttackCooldownTimer.start(attackCooldown)
	$KillbotStackTimer.start(killbotStackTimer)

# Set scale based on Killbot Stacks
func _process(_delta: float) -> void:
	scale.x = sizePerStack + (sizePerStack * killbotStacks)
	scale.y = sizePerStack + (sizePerStack * killbotStacks)

func _physics_process(delta: float) -> void:

	# Setting desination to the location of "follow" body
	var distFromPawn = position.distance_to(follow.position)
	#if follow != null: destination = follow.position

	# State-based chasing behavior
	
	# Start following when too far from Pawn
	if !following && distFromPawn > followDistanceMax:
		following = true
		destination = get_good_destination(follow.position)#follow.position # + add offset
		# set new destination new pawn
	# If following, move towards Pawn center
	if following: position = position.move_toward(destination, spd * delta)
	# If near Pawn, stop following
	if following && position.distance_to(destination) < followDistanceMin: following = false

func get_good_destination(pawnPos) -> Vector2:
	var offsetPos
	var offsetAmount = 100
	var center = get_viewport_rect().size / 2.0
	var maxRadius = get_parent().get_parent().get_parent().boardRadius
	
	# Choose a spot and verify it
	var workingPos = pawnPos
	offsetPos = Vector2(randf_range(-offsetAmount, offsetAmount), randf_range(-offsetAmount, offsetAmount))
	workingPos += offsetPos
	var maxLoops = 100
	var curLoops = 0
	while workingPos.distance_to(center) > maxRadius && curLoops < maxLoops:	
		offsetPos = Vector2(randf_range(-offsetAmount, offsetAmount), randf_range(-offsetAmount, offsetAmount))
		workingPos = pawnPos + offsetPos
		curLoops += 1

	return(workingPos)

func _on_attack_cooldown_timer_timeout() -> void:
	var newBullet = killbotAttack.instantiate()
	add_sibling(newBullet)
	newBullet.killbotParent = self
	newBullet.position = self.position
	newBullet.scale.x = sizePerStack + (sizePerStack * killbotStacks)
	newBullet.scale.y = sizePerStack + (sizePerStack * killbotStacks)
	newBullet.dmg = dmgBase + (dmgPerStack * killbotStacks)
	newBullet.speed = attackSpeedBase + (attackSpeedPerStack * killbotStacks)

func _on_killbot_stack_timer_timeout() -> void:
	killbotStacks = 1
