extends Node

@export var slowEffect: Resource
@export var sprintEffect: Resource
@export var stuckEffect: Resource
@export var weakEffect: Resource

func phase_out_pawn(timer: float) -> void:
	var pawnSprite = get_parent().get_node("PawnSprite")
	pawnSprite.modulate.a = 0.5
	pawnSprite.modulate.r = 0.0
	pawnSprite.modulate.b = 0.0
	pawnSprite.modulate.g = 0.0
	get_parent().set_collision_mask_value(1, false)
	$PhaseStatusTimer.start(timer)
func _on_phase_status_timer_timeout() -> void:
	var pawnSprite = get_parent().get_node("PawnSprite")
	pawnSprite.modulate.a = 1.0
	pawnSprite.modulate.r = 1.0
	pawnSprite.modulate.b = 1.0
	pawnSprite.modulate.g = 1.0
	get_parent().set_collision_mask_value(1, true)

func _on_slow_status_timer_timeout() -> void:
	$SlowParticleTimer.stop()
func _on_slow_particle_timer_timeout() -> void:
	# Avoid making webs if the target is stuck (it's obv slowed too)
	if $StuckStatusTimer.is_stopped():
		var newWeb = slowEffect.instantiate()
		add_child(newWeb)
		newWeb.position = get_parent().position

func start_sprinting(timer: float) -> void:
	$SprintStatusTimer.start(timer)
	$SprintParticleTimer.start()
func _on_sprint_particle_timer_timeout() -> void:
	var newFlake = sprintEffect.instantiate()
	add_child(newFlake)
	newFlake.position = get_parent().position
func _on_sprint_status_timer_timeout() -> void:
	$SprintParticleTimer.stop()

func _on_stuck_status_timer_timeout() -> void:
	$StuckParticleTimer.stop()
func _on_stuck_particle_timer_timeout() -> void:
	var newStuck = stuckEffect.instantiate()
	add_child(newStuck)
	newStuck.position = get_parent().position

func _on_weak_status_timer_timeout() -> void:
	$WeakParticleTimer.stop()
func _on_weak_particle_timer_timeout() -> void:
	var newWeak = weakEffect.instantiate()
	add_child(newWeak)
	newWeak.position = get_parent().position
