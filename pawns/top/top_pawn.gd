extends "res://pawns/base/base_pawn.gd"

@export var topAttack: PackedScene
var topBounceSpeed = 2
var topBounceDuration = 3.0
var sparkOffset = 15
var baseSpd

func _ready() -> void:
	baseSpd = 50
	super()

func _physics_process(delta: float) -> void:
	super(delta)
	if global_position.distance_to(center) > get_parent().boardRadius:
		top_hit_wall()

func top_hit_wall() -> void:
	destination = new_destination()
	$Status.get_node("SprintStatusTimer").start(topBounceDuration)
	$Status.get_node("SprintParticleTimer").start()

func _on_attack_cooldown_timer_timeout() -> void:
	if $Status.get_node("StuckStatusTimer").is_stopped():
		var newAttack = topAttack.instantiate()
		newAttack.position = self.position + Vector2(0, sparkOffset)
		newAttack.dmg = self.dmg
		
		newAttack.direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
		newAttack.rotation = randf_range(0, TAU)
		newAttack.speed += spd / 5
		
		attackObjects.append(newAttack)
		$AttackContainer.add_child(newAttack)
	
	var atkSpdMod = 1.0
	var isSprinting = $Status.get_node("SprintStatusTimer")
	if !isSprinting.is_stopped(): atkSpdMod = 0.5
	$AttackCooldownTimer.start(asp * baseAttackCooldown * atkSpdMod)
