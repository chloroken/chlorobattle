extends "res://pawns/_base/attack/base_attack.gd"

@export var emberAttack: PackedScene
var destination
var speed
var basePawn
var emberScale

func _ready() -> void:
	attackName = "Ember"
	areaAttack = false
	basePawn = get_parent().get_parent()
	scale = Vector2.ONE * emberScale
	
	# Prevent hits until ember lands
	set_collision_layer_value(2, false)

	# Start timer
	$FizzleTimer.start(randf_range(basePawn.emberDurationMin, basePawn.emberDurationMax))

	# Set visibility layer
	z_as_relative = false
	z_index = get_node("/root/main").layerPawnFront

func _process(delta: float) -> void:

	# Move towards landing spot
	if position.distance_to(destination) > 10:
		position += position.direction_to(destination) * speed * delta

	# Re-enable hits & shrink size
	else:
		set_collision_layer_value(2, true)
		scale = Vector2.ONE * emberScale * max(0.5, $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time())

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
	var randomScale = Vector2.ONE * randf_range(basePawn.emberScaleMin, basePawn.emberScaleMax)
	newAttack.emberScale = randomScale
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
