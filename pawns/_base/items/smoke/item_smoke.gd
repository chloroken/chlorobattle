extends Node2D

@export var smokeCloud: Resource
var speed
var direction
var destination = Vector2.ZERO
var destReachedDist = 2

func _ready() -> void:

	# Set visibility order
	z_as_relative = false
	z_index = get_node("/root/main").layerAir

func _physics_process(delta: float) -> void:
	position += position.direction_to(destination) * speed * position.distance_to(destination) * delta

	if position.distance_to(destination) < destReachedDist:
		var newCloud = smokeCloud.instantiate()
		newCloud.position = position
		get_parent().add_child(newCloud)
		queue_free()
