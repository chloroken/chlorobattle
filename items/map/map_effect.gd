extends Node2D

var mapScaleMod = 1.5
var l
@export var mapLineTexture: Resource
var mapLineAlpha = 0.5
var mapLineMinAlpha = 0.1

func _ready() -> void:
	l = Line2D.new()
	get_parent().get_parent().get_node("AttackContainer").add_child(l)
	l.width = 2
	l.z_index = -2

func add_line(pos) -> void:
	l.add_point(pos)

# Grow map sprite
func _process(_delta: float) -> void:
	var mapScale = mapScaleMod * (1 - $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time())
	$MapSprite.scale.x = mapScale
	$MapSprite.scale.y = mapScale
	l.default_color = Color(0, 0, 0, max(mapLineMinAlpha, mapLineAlpha * $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()))

# Clean up
func _on_fizzle_timer_timeout() -> void:
	l.queue_free()
	queue_free()
