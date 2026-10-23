extends Area2D

var basePawn

func _ready() -> void:
	basePawn = get_parent()
	modulate.a = 0.0

func _on_area_entered(area: Area2D) -> void:
	if basePawn.inLobby: return
	if haunt_on_cooldown_or_active(): return
	if haunt_target_ineligible(area): return
	start_haunting(area)

func haunt_on_cooldown_or_active() -> bool:
	if !basePawn.get_node("HauntCooldownTimer").is_stopped():
		return(true)
	elif !basePawn.get_node("HauntDurationTimer").is_stopped():
		return(true)
	return(false)
func haunt_target_ineligible(area) -> bool:
	if area == self:
		return(true)
	elif area.type == "ghost":
		return(true)
	elif area.isHaunted:
		return(true)
	elif area.type == "slug":
		if !area.get_node("SlugRespawnTimer").is_stopped():
			return(true)
	return(false)
func start_haunting(area) -> void:
	basePawn.get_node("HauntDurationTimer").start(basePawn.hauntDuration)
	basePawn.get_node("Status").start_void(basePawn.hauntDuration)
	basePawn.hauntTarget = area
	area.isHaunted = true
