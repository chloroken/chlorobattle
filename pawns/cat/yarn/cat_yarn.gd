extends "res://pawns/_base/attacks/base_attack.gd"

@export var yarnCircleObject: Resource
var yarnCircle

func _ready() -> void:
	super()

	var newYarnCircle = yarnCircleObject.instantiate()
	newYarnCircle.position = position
	add_sibling(newYarnCircle)
	yarnCircle = newYarnCircle
	$FizzleTimer.start(basePawn.yarnDuration)

func _physics_process(_delta: float) -> void:
	if position.distance_to(basePawn.center) > basePawn.get_parent().boardRadius:
		queue_free()

func _on_fizzle_timer_timeout() -> void:
	queue_free()

func _on_tree_exiting() -> void:
	yarnCircle.queue_free()
