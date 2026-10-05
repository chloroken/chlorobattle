extends "res://pawns/_base/base_attack.gd"

var speed
var tetherDistance
var direction
var board
var wanderCooldown
var scaleMod

func _ready() -> void:
	super()
	set_swarm_visual_effects()
	get_new_direction()
	$SwarmWanderTimer.start(wanderCooldown)
func get_new_direction():
	direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
func set_swarm_visual_effects() -> void:
	scale = Vector2.ONE * scaleMod
	rotation = randf_range(0, TAU)
	modulate.r = randf_range(0.5, 0.6)
	modulate.b = randf_range(0.5, 0.6)
	modulate.g = randf_range(0.9, 1.0)

func _physics_process(delta: float) -> void:
	tether_swarm_to_mummy()
	move_swarm(delta)
func tether_swarm_to_mummy() -> void:
	if position.distance_to(basePawn.position) > tetherDistance:
		direction = position.direction_to(basePawn.position)
func move_swarm(delta) -> void:
	position += direction * speed * delta
func _on_tree_exiting() -> void:
	basePawn.swarmCurrentCount -= 1
	if basePawn.swarmCurrentCount < 0: basePawn.swarmCurrentCount = 0
func _on_wander_timer_timeout() -> void:
	get_new_direction()
