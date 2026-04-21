extends "res://pawns/base/base_attack.gd"

@export var cycloneExplosion: PackedScene
var speed
var direction
var duration

func _ready() -> void:
	
	# Set visibility order
	z_as_relative = false
	z_index = get_node("/root/main").layerAir
	
	# Start timer
	$FizzleTimer.start(duration)
	
# Move forward
func _physics_process(delta: float) -> void:
	position += direction * speed * delta

# Make an explosion
func _on_fizzle_timer_timeout() -> void:
	get_parent().get_parent().make_explosion(self.position)
	self.queue_free()
