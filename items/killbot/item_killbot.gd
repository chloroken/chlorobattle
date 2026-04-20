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

# State-based chasing behavior
func _physics_process(delta: float) -> void:
	var distFromPawn = position.distance_to(follow.position)
	var newDestination = position.move_toward(destination, spd * delta)
	if follow != null: destination = follow.position	
	if !following && distFromPawn > followDistanceMax: following = true
	if following: position = newDestination
	if following && distFromPawn < followDistanceMin: following = false

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
