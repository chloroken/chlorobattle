extends "res://pawns/_base/attack/base_attack.gd"

var birdType
var direction
var speed = 30
var returning = false
var growDistance = 64

var basePawn
var center
var boardRadius

@export var birdFeather: Resource
var redColor = Color.RED
var redDuration = 3.0
var redFeathers = 50
var yellowColor = Color.GOLDENROD
var yellowFeathers = 50
var yellowReturnTime = 5.0
var yellowReturnSpeed = 10
var yellowBirdSickDuration = 10.0
var yellowDirectionTimer = 1.0
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
	match birdType:
		"red":
			$BaseSprite.modulate = redColor
			$FizzleTimer.start(redDuration)
			speed += basePawn.spd
			areaAttack = true
		"yellow":
			$BaseSprite.modulate = yellowColor
			$FizzleTimer.one_shot = true
			$FizzleTimer.start(yellowReturnTime)
			$YellowDirectionTimer.one_shot = true
			$YellowDirectionTimer.start(yellowDirectionTimer)
			speed += basePawn.spd * 2
			dmg = 25
			isYellowBirdAttack = true
		"green":
			$BaseSprite.modulate = greenColor
			dmg = 50

func _physics_process(delta: float) -> void:
	scale = Vector2.ONE * lerp(0, 1, min(1.0, position.distance_to(basePawn.position) / growDistance))
	
	rotation = direction.angle()
	match birdType:
		"red":
			position += direction * speed * delta
			if position.distance_to(center) > boardRadius:
				make_feathers(redFeathers, redColor)
				queue_free()
		"yellow":
			if !returning:
				position += direction * speed * delta
				if position.distance_to(center) > boardRadius:
					returning = true
			elif returning:
				speed = position.distance_to(basePawn.position) * yellowReturnSpeed
				position += position.direction_to(basePawn.position) * speed * delta
				if position.distance_to(basePawn.position) < returnDistance:
					make_feathers(yellowFeathers, yellowColor)
					queue_free()
		"green":
			position += direction * speed * delta
			if !returning && position.distance_to(center) > boardRadius:
				make_feathers(greenFeathers, greenColor)
				queue_free()

func _on_fizzle_timer_timeout() -> void:
	if birdType == "red":
		make_feathers(redFeathers, redColor)
		queue_free()
	elif birdType == "yellow":
		returning = true

func make_feathers(amt, col) -> void:
	for i in amt:
		var newFeather = birdFeather.instantiate()
		newFeather.position = position
		newFeather.color = col
		add_sibling(newFeather)

func _on_yellow_direction_timer_timeout() -> void:
	direction = direction.rotated(randf_range(-1.0, 1.0))
	$YellowDirectionTimer.start(yellowDirectionTimer)
