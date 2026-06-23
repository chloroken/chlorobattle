extends "res://pawns/_base/attack/base_attack.gd"

var basePawn
var duration
var startScale = 0.5
var frogSpawnRate = 2.0

func _ready() -> void:
	basePawn = get_parent().get_parent()
	#areaAttack = false
	isCauldronAttack = true
	$FizzleTimer.start(duration)
	scale = Vector2.ONE * startScale
	
	$FrogSpawn.one_shot = true
	$FrogSpawn.start(frogSpawnRate)

func _on_fizzle_timer_timeout() -> void:
	queue_free()

func _physics_process(delta: float) -> void:
	scale = Vector2.ONE * (startScale + (1 - $FizzleTimer.get_time_left() / duration) / 2)
	if position.distance_to(basePawn.center) > basePawn.get_parent().boardRadius:
		queue_free()

func _on_frog_spawn_timeout() -> void:
	var basePawn = get_parent().get_parent()
	var newFrog = basePawn.frogAttack.instantiate()
	newFrog.position = position
	newFrog.dmg = basePawn.dmg
	newFrog.attackName = "Frog"
	newFrog.cauldronJump = true
	basePawn.get_node("AttackContainer").add_child(newFrog)
	$FrogSpawn.start(frogSpawnRate)
