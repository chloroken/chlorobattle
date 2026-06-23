extends "res://pawns/_base/attack/base_attack.gd"

var direction
var speed
var bounces = 0
var maxBounces
var spinSpeed = 10
var particleInterval = 0.01
var particleContainer = []
var basePawn

@export var trickshotParticle: Resource

func _ready() -> void:
	areaAttack = false
	attackName = "Trickshot"
	basePawn = get_parent().get_parent()

	# Set visibility order
	z_as_relative = false
	z_index = get_node("/root/main").layerAir

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	rotation += spinSpeed * delta
	var newParticle = trickshotParticle.instantiate()
	newParticle.position = position
	newParticle.direction = Vector2.RIGHT.rotated(rotation)
	newParticle.duration = 3.0
	add_sibling(newParticle)
	particleContainer.append(newParticle)
	
	if position.distance_to(basePawn.center) > basePawn.get_parent().boardRadius:
		if $RedirectTimer.is_stopped():
			bounce_trickshot()
			$RedirectTimer.start()

# Bounce
func _on_area_exited(area: Area2D) -> void:
	if area.get_collision_layer_value(6):
		bounce_trickshot()

func bounce_trickshot() -> void:
	if !$RedirectTimer.is_stopped(): return
	var random_variance = randf_range(-1.0, 1.0)
	direction = position.direction_to(get_parent().get_parent().get_parent().center).rotated(random_variance)
	bounces += 1
	dmg += basePawn.trickshotDamageRamp
	$RedirectTimer.start()
	if bounces >= maxBounces:
		for particle in particleContainer:
			if particle != null: particle.queue_free()
		queue_free()
	

func _on_tree_exiting() -> void:
	for particle in particleContainer:
		if particle != null: particle.queue_free()
