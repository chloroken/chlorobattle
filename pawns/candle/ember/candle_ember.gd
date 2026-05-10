extends "res://pawns/_base/attack/base_attack.gd"

@export var emberAttack: PackedScene
var destination
var speed = 250
var basePawn

func _ready() -> void:
	attackName = "Ember"
	areaAttack = false
	basePawn = get_parent().get_parent()
	$FizzleTimer.start(randf_range(basePawn.emberDurationMin, basePawn.emberDurationMax))
	scale = Vector2.ONE * basePawn.emberScale
	set_collision_layer_value(2, false)

func _process(delta: float) -> void:
	if position.distance_to(destination) > 10:
		position += position.direction_to(destination) * speed * delta
	else:
		set_collision_layer_value(2, true)
		scale = Vector2.ONE * basePawn.emberScale * max(0.5, $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time())

func _on_fizzle_timer_timeout() -> void:
	if randi_range(1, 2) == 1:
		new_ember()
		if randi_range(1, 3) == 1:
			new_ember()
			if randi_range(1, 4) == 1:
				new_ember()
	queue_free()

func new_ember() -> void:
	var newAttack = get_parent().get_parent().emberAttack.instantiate()
	newAttack.position = position
	newAttack.destination = good_ember_position()
	newAttack.dmg = self.dmg
	newAttack.attackName = "Ember"
	add_sibling(newAttack)

func good_ember_position() -> Vector2:
	var boardRadius = get_parent().get_parent().get_parent().boardRadius
	var center = get_parent().get_parent().center
	var newPos = try_ember_position()
	var maxTries = 0

	# Try to find a position
	while maxTries < 10 && newPos.distance_to(center) > boardRadius:
		newPos = try_ember_position()
		maxTries += 1

	# Otherwise find a position around Candle
	if newPos.distance_to(center) > boardRadius:
		while newPos.distance_to(center) > boardRadius:
			newPos = try_ember_position()

	return(newPos)

func try_ember_position() -> Vector2:
	var offset = 25
	var offsetX = randf_range(-offset, offset)
	var offsetY = randf_range(-offset, offset)
	return(position + Vector2(offsetX, offsetY))
