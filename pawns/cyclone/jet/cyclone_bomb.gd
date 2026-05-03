extends "res://pawns/base/attack/base_attack.gd"

@export var cycloneExplosion: PackedScene
var speed
var direction
var duration
var center

func _ready() -> void:
	center = get_parent().get_parent().get_parent().center

	# Set visibility order
	z_as_relative = false
	z_index = get_node("/root/main").layerAir

	# Start timer
	$FizzleTimer.start(duration)

# Move forward
func _physics_process(delta: float) -> void:
	position += direction * speed * delta

	# Explode any bomb that's out of the arena
	if position.distance_to(center) > get_parent().get_parent().get_parent().boardRadius:
		get_parent().get_parent().make_explosion(self.position)
		self.queue_free()

# Make an explosion
func _on_fizzle_timer_timeout() -> void:
	get_parent().get_parent().make_explosion(self.position)
	self.queue_free()
