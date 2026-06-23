extends "res://pawns/_base/items/_attack/item_attack.gd"

var speed
var direction
var basePawn
var duration
var dirs = [-1, 1]
var rotationDir = dirs.pick_random()
var rotationSpeed = 10

func _ready() -> void:
	basePawn = get_parent().get_parent()
	areaAttack = false
	attackName = "Flask"
	
	
	# Set visibility layer
	z_as_relative = false
	z_index = get_node("/root/main").layerAir

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	rotation += rotationDir * rotationSpeed * delta

	if position.distance_to(basePawn.center) > basePawn.get_parent().boardRadius:
		queue_free()
