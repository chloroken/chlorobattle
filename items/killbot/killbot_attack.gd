extends CollisionObject2D

var areaAttack = false
var speed = 75
var direction: Vector2
var dmg = 10
var pen = 0

func _ready() -> void:
	direction = Vector2.RIGHT.rotated(randf_range(0, TAU))

# Move bullet forward
func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta;

# Clean up
func _on_fizzle_timer_timeout() -> void:
	self.queue_free()
