extends Node

@export var sprintEffect: Resource
@export var slowEffect: Resource

func phase_out_pawn(timer: float) -> void:
	var pawnSprite = get_parent().get_node("PawnSprite")
	pawnSprite.modulate.a = 0.5
	pawnSprite.modulate.r = 0.0
	pawnSprite.modulate.b = 0.0
	pawnSprite.modulate.g = 0.0
	get_parent().set_collision_mask_value(1, false)
	$PhaseDurationTimer.start(timer)
func _on_phase_duration_timer_timeout() -> void:
	var pawnSprite = get_parent().get_node("PawnSprite")
	pawnSprite.modulate.a = 1.0
	pawnSprite.modulate.r = 1.0
	pawnSprite.modulate.b = 1.0
	pawnSprite.modulate.g = 1.0
	get_parent().set_collision_mask_value(1, true)

func start_sprinting(timer: float) -> void:
	$SprintDurationTimer.start(timer)
	$SprintEffectTimer.start()
func _on_sprint_effect_timer_timeout() -> void:
	var newFlake = sprintEffect.instantiate()
	add_child(newFlake)
	newFlake.position = get_parent().position
func _on_sprint_duration_timer_timeout() -> void:
	$SprintEffectTimer.stop()

func _on_slow_duration_timer_timeout() -> void:
	$SlowEffectTimer.stop()
func _on_slow_effect_timer_timeout() -> void:
	var newWeb = slowEffect.instantiate()
	add_child(newWeb)
	newWeb.position = get_parent().position
