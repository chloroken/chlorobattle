extends Area2D

var basePawn

func _ready() -> void:
	basePawn = get_parent().get_parent()

func _on_area_entered(area: Area2D) -> void:
	if area.username == basePawn.username: return
	area.direction = area.position.direction_to(position)
