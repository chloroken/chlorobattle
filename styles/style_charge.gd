extends Node2D

@export var styleParticle: Resource

var orbitDirs = [-1, 1]
var orbitDir = orbitDirs.pick_random()
var orbitDistance = 15
var orbitSpeed = 2
var orbitRotation = 0.0
var parentPawn
var particleColor

func _ready() -> void:
	z_as_relative = false
	z_index = get_node("/root/main").layerAir
	
	parentPawn = get_parent().get_parent()
	orbitSpeed *= randf_range(1.0, 1.5)
	orbitDistance *= randf_range(0.75, 1.0)
	scale *= randf_range(1, 1.5)

func _physics_process(delta: float) -> void:
	
	orbitRotation += orbitSpeed * delta
	if orbitRotation > 360: orbitRotation = 0
	position = parentPawn.position + (Vector2.ONE * orbitDistance).rotated(orbitDir * orbitRotation)
	
	var newParticle = styleParticle.instantiate()
	newParticle.position = position
	add_sibling(newParticle)
	newParticle.get_node("StyleParticleSprite").modulate = particleColor
