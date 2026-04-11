extends "res://pawns/base/base_attack.gd"

var rotationSpeed = 10

func _ready() -> void:
	areaAttack = true
	scale.x = 0
	scale.y = 0

func _process(delta: float) -> void:
	$BaseSprite.modulate.a = $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	scale.x = 2 - $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	scale.y = 2 - $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	rotation += rotationSpeed * delta

func _physics_process(_delta: float) -> void:
	position = get_parent().get_parent().position

# Clean up
func _on_fizzle_timer_timeout() -> void:
	self.queue_free()
