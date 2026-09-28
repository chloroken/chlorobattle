extends "res://pawns/_base/attack/base_attack.gd"

var basePawn
var duration
var wanderCooldownMin = 1.0
var wanderCooldownMax = 2.0
var jumpDuration = 0.1
var direction
var speed = 200
#var cauldronJump = false

var decayStart = 0.25
var decayRate = 10.0

#@export var splatScene: Resource

func _ready() -> void:
	areaAttack = false
	basePawn = get_parent().get_parent()
	$FizzleTimer.start(duration)
	direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	$DirectionChange.one_shot = true
	$JumpDuration.one_shot = true
	#if cauldronJump: $DirectionChange.start(0.1)
	#else:
	$DirectionChange.start(randf_range(wanderCooldownMin, wanderCooldownMax))
	
	if isPurpleFrogAttack:
		modulate = Color.MEDIUM_PURPLE
	else:
		modulate = Color.LIME_GREEN

	z_as_relative = false
	z_index = get_node("/root/main").layerPawnBehind

func _process(delta: float) -> void:
	if $FizzleTimer.get_time_left() < $FizzleTimer.get_wait_time() * decayStart:
		modulate.a -= delta * decayRate

func _physics_process(delta: float) -> void:
	if !$JumpDuration.is_stopped():	position += direction * speed * delta
	if position.distance_to(basePawn.center) > basePawn.get_parent().boardRadius:
		queue_free()

func _on_fizzle_timer_timeout() -> void:
	queue_free()

func _on_direction_change_timeout() -> void:
	direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	$DirectionChange.start(randf_range(wanderCooldownMin, wanderCooldownMax))
	$JumpDuration.start(jumpDuration)

#func create_splat():
	#var newSplat = splatScene.instantiate()
	#newSplat.position = position
	#add_sibling(newSplat)
