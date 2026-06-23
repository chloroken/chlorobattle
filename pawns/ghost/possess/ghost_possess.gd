extends Area2D

var basePawn

func _ready() -> void:

	basePawn = get_parent()
	modulate.a = 0.0

func _on_area_entered(area: Area2D) -> void:
	if basePawn.attacksDisabled: return
	if area == self: return
	if area.type == "ghost": return
	if area.isPossessed: return
	if area.team == basePawn.team: return
	if !basePawn.get_node("PossessDurationTimer").is_stopped(): return
	if !basePawn.get_node("PossessCooldownTimer").is_stopped(): return
	
	basePawn.get_node("PossessDurationTimer").start(basePawn.possessDuration)
	basePawn.get_node("Status").start_void(basePawn.possessDuration)
	basePawn.possessTarget = area
	area.isPossessed = true
