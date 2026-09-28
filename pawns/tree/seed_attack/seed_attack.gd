extends Node2D

var seedSpeed
var seedSpinSpeed = 10.0
var seedSpinDirs = [-1, 1]
var seedSpinDir = seedSpinDirs.pick_random()
var destination
var attackName = "Seed"


var particleTimer = 0.1
@export var particleScene: Resource

func _ready() -> void:
	$ParticleTimer.start(particleTimer)

func _physics_process(delta: float) -> void:
	position += position.direction_to(destination) * seedSpeed * delta
	if position.distance_to(destination) < 8:
		get_parent().get_parent().seed_relocate(destination)
		queue_free()
	rotation += seedSpinSpeed * seedSpinDir * delta

func _on_particle_timer_timeout() -> void:
	var newParticle = particleScene.instantiate()
	newParticle.position = position
	add_sibling(newParticle)
