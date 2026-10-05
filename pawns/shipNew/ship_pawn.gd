extends "res://pawns/_base/base_pawn.gd"

@export var ringAttackScene: PackedScene
var ringAttackName = "Ring"
var ringCooldownMin = 3.0
var ringCooldownMax = 4.0
var ringDurationMin = 10.0
var ringDurationMax = 12.0
var ringSpeed = 500
var ringSpeedDecay = 0.999

@export var empAttackScene: PackedScene
var empAttackName = "Ring"
var empCooldownMin = 8.0
var empCooldownMax = 10.0
var empDuration = 1.0
var empDisarmDuration = 3.0

@export var warpParticleScene: PackedScene
var warpActive = false
var warpVoidTimer = 999
var warpCooldown = 10
var warpTravelSpeed = 100
var warpParticleRate = 0.05

func _ready() -> void:
	super()
	if !attacksDisabled:
		new_attack_cycle(ringCooldownMin, ringCooldownMax)
		start_emp_cooldown()
		$WarpCooldownTimer.one_shot = true
		$WarpParticleTimer.one_shot = true

# Ring
func _on_attack_cooldown_timer_timeout() -> void:
	new_attack_cycle(ringCooldownMin, ringCooldownMax)
	if disarm_check(): return
	if !warpActive: new_ring_attack()
	
func new_ring_attack() -> void:
	var newRing = ringAttackScene.instantiate()
	newRing.areaAttack = false
	newRing.attackName = ringAttackName
	newRing.position = self.position
	newRing.duration = randf_range(ringDurationMin, ringDurationMax)
	newRing.baseSpeed = ringSpeed
	newRing.speedDecay = ringSpeedDecay
	newRing.direction = self.direction
	newRing.dmg = self.dmg
	$AttackContainer.add_child(newRing)

# EMP
func start_emp_cooldown() -> void:
	var empCooldownRange = randf_range (empCooldownMin, empCooldownMax)
	var empCooldown = asp * aspMod * empCooldownRange
	$EmpCooldownTimer.start(empCooldown)
func _on_emp_cooldown_timer_timeout() -> void:
	if disarm_check(): return
	if warpActive: return
	var newEmp = empAttackScene.instantiate()
	newEmp.isEmpAttack = true
	newEmp.areaAttack = true
	newEmp.position = self.position
	newEmp.duration = empDuration
	newEmp.dmg = self.dmg
	$AttackContainer.add_child(newEmp)
	start_emp_cooldown()

# Warp
func _on_area_exited(area: Area2D) -> void:
	if self.is_queued_for_deletion(): return
	if !area.get_collision_layer_value(6): return
	if attacksDisabled: return
	trigger_warp()
func trigger_warp() -> void:
	if !warpActive && $WarpCooldownTimer.is_stopped():
		warpActive = true
		$WarpParticleTimer.start(warpParticleRate)
		$Status.start_void(warpVoidTimer)
		direction = position.direction_to(center)
		$GUI.visible = false
	elif warpActive:
		warpActive = false
		$WarpParticleTimer.stop()
		$WarpCooldownTimer.start(warpCooldown)
		$Status.stop_void()
		$Status.start_void(0.1)
		direction = new_direction()
		$GUI.visible = true
func _physics_process(delta: float) -> void:
	super(delta)
	$PawnSprite.rotation = direction.angle()
	if attacksDisabled: return
	if position.distance_to(center) > board.boardRadius:
		warp_from_out_of_bounds()
	if warpActive:
		var dist = get_parent().boardRadius - position.distance_to(center)
		position += direction * max(warpTravelSpeed, dist) * delta
func warp_from_out_of_bounds() -> void:
	if self.is_queued_for_deletion(): return
	if attacksDisabled: return
	trigger_warp()
func _on_warp_particle_timer_timeout() -> void:
	var newParticle = warpParticleScene.instantiate()
	newParticle.position = position
	$AttackContainer.add_child(newParticle)
	$WarpParticleTimer.start(warpParticleRate)
