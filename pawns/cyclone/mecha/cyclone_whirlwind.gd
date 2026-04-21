extends "res://pawns/base/base_attack.gd"

var direction
var rotationSpeed = 10
var speed = 50

func _ready() -> void:

	# Lock scaling to grow from
	scale.x = 0
	scale.y = 0

	# Set visibility order
	z_as_relative = false
	z_index = get_node("/root/main").layerPawnBehind

func _process(delta: float) -> void:
	$BaseSprite.modulate.a = $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	scale.x = 1.5 - $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	scale.y = 1.5 - $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	rotation += rotationSpeed * delta

func _physics_process(delta: float) -> void:
	#position = get_parent().get_parent().position
	position += Vector2.RIGHT.rotated(direction) * speed * delta

# Clean up
func _on_fizzle_timer_timeout() -> void:
	self.queue_free()
