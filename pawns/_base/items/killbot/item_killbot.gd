extends CharacterBody2D

@export var killbotSaw: Resource
@export var killbotAttack: PackedScene
var destination
var follow = null
var killbotStacks = 1
var following = false
var dmgBase
var attackCooldownMin
var attackCooldownMax
var spd
#var bulletSpd
var killbotMaxStacks
var sizePerStack
var dmgPerStack
var attackSpeedPerStack
var killbotStackTimer
var followDistanceMin
var followDistanceMax

# Special flags
#var isPersistentSummon = true

func _ready() -> void:
	
	destination = get_good_destination(follow.position)

	# Set visibility ordering
	z_as_relative = false
	z_index = get_node("/root/main").layerPawnBehind

	# Start timers
	$AttackCooldownTimer.one_shot = true
	$AttackCooldownTimer.start(randf_range(attackCooldownMin, attackCooldownMax))
	$KillbotStackTimer.start(killbotStackTimer)

# Set scale based on Killbot Stacks
func _process(_delta: float) -> void:
	scale.x = 1.0 + (sizePerStack * killbotStacks)
	scale.y = 1.0 + (sizePerStack * killbotStacks)

func _physics_process(delta: float) -> void:

	# Setting desination to the location of "follow" body
	var distFromDest = position.distance_to(destination)
	#print(distFromDest)

	# Start following when too far from Pawn
	if distFromDest < 2: #!following && 
		#following = true
		destination = get_good_destination(follow.position)
		
	# If following, move towards Pawn center
	#if following: position = 
	position = position.move_toward(destination, spd * delta)
	#position += position.direction_to(destination) * spd * delta
	
	# If near Pawn, stop following
	#if following && position.distance_to(destination) < followDistanceMin: following = false

func get_good_destination(pawnPos) -> Vector2:
	var offsetPos
	var offsetAmount = 100
	var maxRadius = get_parent().get_parent().get_parent().boardRadius

	var workingPos = pawnPos
	offsetPos = Vector2(randf_range(-offsetAmount, offsetAmount), randf_range(-offsetAmount, offsetAmount))
	workingPos += offsetPos

	var maxLoops = 100
	var curLoops = 0
	while workingPos.distance_to(get_parent().get_parent().center) > maxRadius && curLoops < maxLoops:	
		offsetPos = Vector2(randf_range(-offsetAmount, offsetAmount), randf_range(-offsetAmount, offsetAmount))
		workingPos = pawnPos + offsetPos
		curLoops += 1
	return(workingPos)

func _on_attack_cooldown_timer_timeout() -> void:
	var newSaw = killbotSaw.instantiate()
	newSaw.killbotParent = self
	newSaw.position = self.position
	newSaw.scale.x = 1.0 + (sizePerStack * killbotStacks)
	newSaw.scale.y = 1.0 + (sizePerStack * killbotStacks)
	newSaw.dmg = dmgBase + (dmgPerStack * killbotStacks)
	newSaw.attackName = "Killbot"
	newSaw.duration = get_parent().get_parent().get_node("Items").killbotSawDuration
	add_sibling(newSaw)
	$AttackCooldownTimer.start(randf_range(attackCooldownMin, attackCooldownMax))
	#var newBullet = killbotAttack.instantiate()
	#add_sibling(newBullet)
	#newBullet.killbotParent = self
	#newBullet.position = self.position
	#newBullet.scale.x = sizePerStack + (sizePerStack * killbotStacks)
	#newBullet.scale.y = sizePerStack + (sizePerStack * killbotStacks)
	#newBullet.dmg = dmgBase + (dmgPerStack * killbotStacks)
	#newBullet.attackName = "Killbot"
	#newBullet.speed = bulletSpd + (attackSpeedPerStack * killbotStacks)

func _on_killbot_stack_timer_timeout() -> void:
	killbotStacks = 1
