extends "res://pawns/_base/base_pawn.gd"

@export var hornScene: Resource
var isCharging = false
var hornChargeTimerDuration = 3.0
var hornChargeSpeedInterval = 0.1
var hornChargeSpeedMultiplier = 1.05
var hornChargeInitialBoost = 20.0
var hornChargeMax = 120.0
var hornChargeSpeedModifier = 1.0
var hornChargeSpeedBase = 1.0
var hornDisarmMultiplier = 0.5
var activeHorns

func _ready() -> void:
	super()
	print("what")

	# Start attack cycle
	if !attacksDisabled:
		$HornChargeTimer.stop()
		$HornChargeTimer.one_shot = true
		$HornSpeedIntervalTimer.stop()
		$HornSpeedIntervalTimer.one_shot = true
		new_direction()
		#$HornChargeTimer.start()
	else:
		spd = 20

func _physics_process(delta: float) -> void:
	statusSpdMod = normalSpeed
	if !$Status.get_node("SprintStatusTimer").is_stopped(): statusSpdMod *= sprintSpeed
	if !$Status.get_node("SlowStatusTimer").is_stopped(): statusSpdMod *= slowSpeed
	if !$Status.get_node("StuckStatusTimer").is_stopped(): statusSpdMod *= stuckSpeed
	if style == "parkour":
			statusSpdMod *= 1.0 + $Styles.parkourSpeedPerCharge * $Styles.parkourChargeCount
	position += direction * hornChargeSpeedModifier * spd * statusSpdMod * delta
	stay_in_bounds()
	if (!isCharging && activeHorns != null):
		activeHorns.queue_free()
		activeHorns = null

	if isCharging:
		$HornChargeLabel.text = str(int(max(dmg, min(hornChargeMax, hornChargeSpeedModifier * spd * statusSpdMod))))
		if ((activeHorns.get_node("HornRainbowTimer").is_stopped()) && (hornChargeMax <= (hornChargeSpeedModifier * spd * statusSpdMod))):
			activeHorns.get_node("HornRainbowTimer").start(activeHorns.hornColorInterval)
	else:
		$HornChargeLabel.text = ""

func new_direction() -> Vector2:
	$Styles.style_parkour_add_charge()

	if !attacksDisabled:
		$Status.stop_tanky()
		isCharging = false
		$HornChargeTimer.start(hornChargeTimerDuration * asp)
		$HornSpeedIntervalTimer.stop()
		hornChargeSpeedModifier = hornChargeSpeedBase

	return(position.direction_to(center).rotated(randf_range(-wanderRadians, wanderRadians)))

func _on_horn_charge_timer_timeout() -> void:
	isCharging = true
	$Status.start_tanky(999)
	$HornSpeedIntervalTimer.start(hornChargeSpeedInterval)
	var newHorns = hornScene.instantiate()
	newHorns.position = self.position
	newHorns.dmg = self.dmg
	newHorns.rotation = direction.angle()
	$AttackContainer.add_child(newHorns)
	activeHorns = newHorns
	hornChargeSpeedModifier = hornChargeInitialBoost

func _on_horn_speed_interval_timer_timeout() -> void:

	if $Status.get_node("StuckStatusTimer").is_stopped():
		hornChargeSpeedModifier *= hornChargeSpeedMultiplier

	$HornSpeedIntervalTimer.start(hornChargeSpeedInterval)
