extends Node2D

var basePawn

@export var globuleAttack: Resource
var globuleCountMin = 10
var globuleCountMax = 10

var antimatterDuration = 3.0
var direction: Vector2
var baseSpeed = 25
var speed

func _ready() -> void:
	speed = baseSpeed
	basePawn = get_parent().get_parent()
	rotation = randf_range(0, TAU)
	$FizzleTimer.start(antimatterDuration)
	scale = Vector2.ZERO
	# Set visibility order
	z_as_relative = false
	z_index = get_node("/root/main").layerAir

func _process(_delta: float) -> void:
	scale = Vector2.ONE * 0.5 * (1 - $FizzleTimer.get_time_left() / antimatterDuration)
	speed = baseSpeed * $FizzleTimer.get_time_left() / antimatterDuration

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	if position.distance_to(get_parent().get_parent().get_parent().center) > get_parent().get_parent().get_parent().boardRadius:
		direction = position.direction_to(get_parent().get_parent().get_parent().center).rotated(randf_range(-1.0, 1.0))

func _on_fizzle_timer_timeout() -> void:
	var globCount = randf_range(globuleCountMin, globuleCountMax)
	for i in globCount:
		var newAttack = globuleAttack.instantiate()
		newAttack.dmg = basePawn.dmg
		newAttack.position = self.position
		newAttack.attackName = "Globule"
		newAttack.direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
		newAttack.speed = randf_range(25, 50)
		basePawn.get_node("AttackContainer").add_child(newAttack)
	queue_free()
