extends Node2D

@export var vialPool: Resource
var speed
var direction

func _ready() -> void:
	
	# Set random direction
	direction = Vector2.RIGHT.rotated(randf_range(0, TAU))

	# Set visibility order
	z_as_relative = false
	z_index = get_node("/root/main").layerAir

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_vial_duration_timeout() -> void:
	var newVial = vialPool.instantiate()
	newVial.position = position
	get_parent().add_child(newVial)
	queue_free()
