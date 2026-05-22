extends "res://pawns/_base/attack/base_attack.gd"

var basePawn
#var booReleased = false
#var booReleaseTimer = 5.0
#var direction = Vector2.ZERO
#var releaseSpeed = 25

# orbiting
var orbitDirs = [-1, 1]
var orbitDir = orbitDirs.pick_random()
var orbitDistance = 25
var orbitSpeed = 2
var orbitRotation = 0.0

func _ready() -> void:

	basePawn = get_parent().get_parent()
	attackName = "Boo"
	areaAttack = false
	isBooAttack = true
	modulate.a = 0.0
	orbitDistance *= randf_range(0.9, 1.1)
	orbitSpeed  *= randf_range(0.9, 1.1)

	# Set visibility order
	z_as_relative = false
	z_index = get_node("/root/main").layerAir

func _physics_process(delta: float) -> void:
	modulate.a = 1.0
	orbitRotation += orbitSpeed * delta
	if orbitRotation > 360: orbitRotation = 0
	position = basePawn.position + (Vector2.ONE * orbitDistance).rotated(orbitDir * orbitRotation)
	#elif booReleased && $FizzleTimer.is_stopped():
		#$FizzleTimer.start(booReleaseTimer)
		#direction = basePawn.position.direction_to(self.position)
	#elif booReleased:
		#position += direction * releaseSpeed * delta
		#modulate.a = $FizzleTimer.get_time_left() / booReleaseTimer
		#scale = Vector2.ONE + (Vector2.ONE * 3 * (1 - $FizzleTimer.get_time_left() / booReleaseTimer))

func _on_fizzle_timer_timeout() -> void:
	queue_free()

func _on_tree_exiting() -> void:
	basePawn.booCount -= 1
