extends "res://pawns/_base/attack/base_attack.gd"

var yarnDuration = 10.0
var yarnCircle
@export var yarnCircleObject: Resource
var basePawn

func _ready() -> void:
	var newYarnCircle = yarnCircleObject.instantiate()
	newYarnCircle.position = position
	add_sibling(newYarnCircle)
	yarnCircle = newYarnCircle
	
	basePawn = get_parent().get_parent()
	attackName = "Yarn"
	isYarnAttack = true
	areaAttack = false
	$FizzleTimer.start(yarnDuration)

func _physics_process(_delta: float) -> void:
	if position.distance_to(basePawn.center) > basePawn.get_parent().boardRadius:
		queue_free()

func _on_fizzle_timer_timeout() -> void:
	queue_free()

func _on_tree_exiting() -> void:
	yarnCircle.queue_free()
