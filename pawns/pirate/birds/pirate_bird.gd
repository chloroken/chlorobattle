extends "res://pawns/_base/attack/base_attack.gd"

var birdType
var direction
var speed
var returning = false
var growDistance = 64

var basePawn
var center
var boardRadius

@export var birdFeather: Resource
var returnDistance = 5
var greenFeathers = 50
var greenColor = Color.SEA_GREEN

func _ready() -> void:
	scale = Vector2.ZERO
	areaAttack = false
	direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	basePawn = get_parent().get_parent()
	center = basePawn.center
	boardRadius = basePawn.get_parent().boardRadius
	$BaseSprite.modulate = greenColor

	# Set visibility order
	z_as_relative = false
	z_index = get_node("/root/main").layerAir

func _physics_process(delta: float) -> void:
	scale = Vector2.ONE * 0.75 * lerp(0, 1, min(1.0, position.distance_to(basePawn.position) / growDistance))

	if !returning && position.distance_to(center) > boardRadius:
		direction = position.direction_to(basePawn.position)
		returning = true
	elif returning && position.distance_to(basePawn.position) < returnDistance:
		make_feathers(greenFeathers, greenColor)
		queue_free()

	if !returning:
		if position.distance_to(center) > boardRadius: returning = true
	elif returning:
		direction = position.direction_to(basePawn.position)
		if position.distance_to(basePawn.position) < returnDistance:
			make_feathers(greenFeathers, greenColor)
			queue_free()

	rotation = direction.angle()
	position += direction * speed * delta

func _on_fizzle_timer_timeout() -> void:
	make_feathers(greenFeathers, greenColor)
	queue_free()

func make_feathers(amt, col) -> void:
	for i in amt:
		var newFeather = birdFeather.instantiate()
		newFeather.position = position
		newFeather.color = col
		add_sibling(newFeather)
