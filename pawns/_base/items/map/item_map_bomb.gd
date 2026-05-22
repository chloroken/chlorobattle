extends Node2D

@export var itemMapExplosion: Resource
var duration
var dmg
var explosionDuration

func _ready() -> void:
	$FizzleTimer.start(duration)

func _on_fizzle_timer_timeout() -> void:
	
	var newExplosion = itemMapExplosion.instantiate()
	newExplosion.position = position
	newExplosion.duration = explosionDuration
	newExplosion.dmg = dmg
	add_sibling(newExplosion)
	queue_free()
