extends "res://pawns/_base/attack/base_attack.gd"

#@export var emberAttack: PackedScene
var destination
var speed
var basePawn
var decayStart = 0.25
var decayRate = 10.0

@export var blueEmberSprite: Resource
@export var blueLightSprite: Resource

func _ready() -> void:
	attackName = "Ember"
	areaAttack = false
	basePawn = get_parent().get_parent()

	if isBlueEmberAttack:
		$BaseSprite.texture = blueEmberSprite
		$EmberLightSprite.texture = blueLightSprite
		$FizzleTimer.start(basePawn.blueEmberDurMod * randf_range(basePawn.emberDurationMin, basePawn.emberDurationMax))
	else:
		$FizzleTimer.start(randf_range(basePawn.emberDurationMin, basePawn.emberDurationMax))

	# Prevent hits until ember lands
	set_collision_layer_value(2, false)

	# Set visibility layer
	z_as_relative = false
	z_index = get_node("/root/main").layerPawnBehind

func _process(delta: float) -> void:

	# Move towards landing spot
	if position.distance_to(destination) > 10:
		position += position.direction_to(destination) * speed * delta

	# Re-enable hits & shrink size
	else:
		set_collision_layer_value(2, true)

	if $FizzleTimer.get_time_left() < $FizzleTimer.get_wait_time() * decayStart:
		modulate.a -= delta * decayRate

# Arson spread mechanic
func _on_fizzle_timer_timeout() -> void:
	if randi_range(1, 2) == 1:
		new_ember()
		if randi_range(1, 3) == 1:
			new_ember()
			if randi_range(1, 4) == 1:
				new_ember()
	queue_free()

func new_ember() -> void:
	var newAttack = basePawn.emberAttack.instantiate()
	newAttack.position = position
	newAttack.destination = good_ember_position()
	newAttack.dmg = self.dmg
	newAttack.speed = speed
	if isBlueEmberAttack: newAttack.isBlueEmberAttack = true
	add_sibling(newAttack)

func good_ember_position() -> Vector2:
	var newPos = try_ember_position()
	while newPos.distance_to(basePawn.center) > basePawn.board.boardRadius:
		newPos = try_ember_position()
	return(newPos)

func try_ember_position() -> Vector2:
	var offset = basePawn.emberSpreadOffset
	var offsetX = randf_range(-offset, offset)
	var offsetY = randf_range(-offset, offset)
	return(position + Vector2(offsetX, offsetY))
