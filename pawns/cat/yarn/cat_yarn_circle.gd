extends Area2D

func _on_area_entered(area: Area2D) -> void:
	if area.redirectImmunity: return
	var basePawn = get_parent().get_parent()
	if area.username == basePawn.username: return
	area.direction = area.position.direction_to(position)
