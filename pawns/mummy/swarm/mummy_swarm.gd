extends "res://pawns/_base/attack/base_attack.gd"

var speed
var tetherDistance

var direction
var basePawn
var board

var wanderCooldown

func _ready() -> void:
	attackName = "Swarm"
	areaAttack = false
	basePawn = get_parent().get_parent()
	board = basePawn.get_parent()
	get_new_direction()
	$WanderTimer.start(wanderCooldown)
	
	var scaleMod = randf_range(0.5, 1.0)
	scale = Vector2.ONE * scaleMod
	rotation = randf_range(0, TAU)
	modulate.r = randf_range(0.5, 0.6)
	modulate.b = randf_range(0.5, 0.6)
	modulate.g = randf_range(0.9, 1.0)

func _physics_process(delta: float) -> void:
	if position.distance_to(basePawn.position) > tetherDistance:
		direction = position.direction_to(basePawn.position)
	position += direction * speed * delta

func get_new_direction():
	direction = Vector2.RIGHT.rotated(randf_range(0, TAU))

func _on_tree_exiting() -> void:
	basePawn.swarmCount -= 1
	if basePawn.swarmCount < 0: basePawn.swarmCount = 0

func _on_wander_timer_timeout() -> void:
	get_new_direction()
