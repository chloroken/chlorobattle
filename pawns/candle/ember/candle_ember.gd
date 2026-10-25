extends "res://pawns/_base/attacks/base_attack.gd"

@export var infernoSprite: Texture
var destination
var speed
var destDistThreshold = 10.0
var attackCollisionLayer = 2

func _ready() -> void:
	super()
	set_inferno_sprite()
	toggle_ember_collision()
	set_ember_fizzle_timer()
func set_inferno_sprite() -> void:
	if isInfernoAttack:
		$BaseSprite.texture = infernoSprite
func toggle_ember_collision() -> void:
	set_collision_layer_value(attackCollisionLayer, !get_collision_layer_value(attackCollisionLayer))
func set_ember_fizzle_timer() -> void:
	$FizzleTimer.start(randf_range(basePawn.emberDurationMin, basePawn.emberDurationMax))

# Physics
func _process(delta: float) -> void:
	ember_movement(delta)
func ember_movement(delta) -> void:
	if position.distance_to(destination) > destDistThreshold:
		position += position.direction_to(destination) * speed * delta
	else:
		toggle_ember_collision()

# Replication mechanic
func _on_fizzle_timer_timeout() -> void:
	arson_mechanic()
	queue_free()
func arson_mechanic() -> void:
	var arsonChance = randf_range(1, 100)
	var arsonMod = 1.0
	if isInfernoAttack:
		arsonMod = basePawn.infernoArsonMultiplier
	if arsonChance <= basePawn.arsonTriplicateChance * arsonMod:
		basePawn.new_ember_attack(self.position)
	if arsonChance <= basePawn.arsonDuplicateChance * arsonMod:
		basePawn.new_ember_attack(self.position)
	if arsonChance <= basePawn.arsonReplicateChance * arsonMod:
		basePawn.new_ember_attack(self.position)
