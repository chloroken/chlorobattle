extends Node2D

var basePawn
var duration
var lureRadius

func _ready() -> void:
	$Area2D.get_node("CollisionShape2D").shape.set_radius(lureRadius)
	$FizzleTimer.start(duration)

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.username == basePawn.username: return
	area.direction = area.position.direction_to(position)

func _on_fizzle_timer_timeout() -> void:
	queue_free()
