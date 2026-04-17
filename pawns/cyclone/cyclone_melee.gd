extends "res://pawns/base/base_attack.gd"

var direction
var rotationSpeed = 10
var speed = 25

func _ready() -> void:
	position = get_parent().get_parent().position
	direction = randf_range(0, TAU)
	z_index = get_node("/root/main").layerPawnBehind
	areaAttack = true
	scale.x = 0
	scale.y = 0

func _process(delta: float) -> void:
	$BaseSprite.modulate.a = $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	scale.x = 2 - $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	scale.y = 2 - $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	rotation += rotationSpeed * delta

func _physics_process(delta: float) -> void:
	#position = get_parent().get_parent().position
	position += Vector2.RIGHT.rotated(direction) * speed * delta

# Clean up
func _on_fizzle_timer_timeout() -> void:
	self.queue_free()
