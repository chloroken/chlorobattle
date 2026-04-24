extends Area2D

var healthwormHp = 1
var healthwormHealPercent = 0.01

var wormSpeed = 5
var wormDirection: Vector2
var wormRotation

func _ready() -> void:
	wormRotation = randf_range(0, TAU)
	wormDirection = Vector2.RIGHT.rotated(wormRotation)
	
	# Set visibility order
	z_as_relative = false
	z_index = get_node("/root/main").layerPawnBehind

func _process(_delta: float) -> void:
	$HealthwormSprite.rotation = wormRotation

func _physics_process(delta: float) -> void:
	var center = get_viewport_rect().size / 2.0
	position += wormDirection * wormSpeed * delta
	if position.distance_to(center) > get_parent().boardRadius:
		queue_free()

func _on_body_entered(body: Node2D) -> void:

	if !body.areaAttack && !body.isTireAttack:
		body.queue_free()

	healthwormHp -= body.dmg
	if healthwormHp <= 0:
		var attackingPawn = body.get_parent().get_parent()
		attackingPawn.hp += attackingPawn.baseHp * healthwormHealPercent
		if attackingPawn.hp > attackingPawn.baseHp:
			attackingPawn.hp = attackingPawn.baseHp

		get_parent().update_combat_log("[" + str(attackingPawn.username) + "] healed for [" + str(attackingPawn.baseHp * healthwormHealPercent) + "] (Healthworm)")
		get_parent().healthwormArray.pop_front()
		queue_free()

func _on_worm_direction_timer_timeout() -> void:
	wormRotation = randf_range(0, TAU)
	wormDirection = Vector2.RIGHT.rotated(wormRotation)
