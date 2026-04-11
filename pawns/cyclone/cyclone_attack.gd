extends "res://pawns/base/base_attack.gd"

@export var cycloneExplosion: PackedScene

var speed = 100
var random_direction: Vector2
var direction: Vector2

func _ready() -> void:
	#areaAttack = false
	
	# Adjust speed by Ship speed
	speed += get_parent().get_parent().spd
	
	# Adjust colors 
	#$BaseSprite.modulate.r = randf_range(0.8, 1.0)
	#$BaseSprite.modulate.b = randf_range(0.0, 1.0)
	#$BaseSprite.modulate.g = randf_range(0.0, 1.0)

# Move forward
func _physics_process(delta: float) -> void:
	position += direction * speed * delta;

# Clean up
func _on_fizzle_timer_timeout() -> void:
	get_parent().get_parent().make_explosion(self.position)
	self.queue_free()
