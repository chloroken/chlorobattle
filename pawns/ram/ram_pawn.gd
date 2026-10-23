extends "res://pawns/_base/base_pawn.gd"

@export var hornScene: Resource

var channelDelayTimer = 3.0
var channelSpeedBoost = 20.0

var isCharging = false
var chargeSpeedIncreaseInterval = 0.1
var chargeSpeedMultiplier = 1.05
var chargeSpeedMax = 120.0
var chargeMovespeedModifier = 1.0
var chargeSpeedMin = 1.0

var activeHorns
var hornDisarmDamageMultiplier = 0.5

func _ready() -> void:
	super()

	# Start attack cycle
	if not inLobby:
		redirectImmunity = true
		$HornChargeTimer.stop()
		$HornChargeTimer.one_shot = true
		$HornSpeedIntervalTimer.stop()
		$HornSpeedIntervalTimer.one_shot = true
		new_direction()
		#$HornChargeTimer.start()
	else:
		spd = channelSpeedBoost

func _physics_process(delta: float) -> void:
	statusSpdMod = normalSpeed
	if !$Status.get_node("SprintStatusTimer").is_stopped(): statusSpdMod *= sprintSpeed
	if !$Status.get_node("SlowStatusTimer").is_stopped(): statusSpdMod *= slowSpeed
	if !$Status.get_node("StuckStatusTimer").is_stopped(): statusSpdMod *= stuckSpeed
	if style == "parkour":
			statusSpdMod *= 1.0 + $Styles.parkourSpeedPerCharge * $Styles.parkourChargeCount
	position += direction * chargeMovespeedModifier * spd * statusSpdMod * delta
	stay_in_bounds()
	if (!isCharging && activeHorns != null):
		activeHorns.queue_free()
		activeHorns = null

	if isCharging:
		$HornChargeLabel.text = str(int(max(dmg, min(chargeSpeedMax, chargeMovespeedModifier * spd * statusSpdMod))))
		if ((activeHorns.get_node("HornRainbowTimer").is_stopped()) && (chargeSpeedMax <= (chargeMovespeedModifier * spd * statusSpdMod))):
			activeHorns.get_node("HornRainbowTimer").start(activeHorns.hornColorInterval)
	else:
		$HornChargeLabel.text = ""

func new_direction() -> Vector2:
	$Styles.style_parkour_add_charge()

	if not inLobby:
		$Status.stop_tanky()
		isCharging = false
		$HornChargeTimer.start(channelDelayTimer * asp)
		$HornSpeedIntervalTimer.stop()
		chargeMovespeedModifier = chargeSpeedMin

	return(position.direction_to(center).rotated(randf_range(-wanderRadians, wanderRadians)))

func _on_horn_charge_timer_timeout() -> void:
	isCharging = true
	$Status.start_tanky(999)
	$HornSpeedIntervalTimer.start(chargeSpeedIncreaseInterval)
	var newHorns = hornScene.instantiate()
	newHorns.position = self.position
	newHorns.dmg = self.dmg
	newHorns.rotation = direction.angle()
	$AttackContainer.add_child(newHorns)
	activeHorns = newHorns
	chargeMovespeedModifier = channelSpeedBoost

func _on_horn_speed_interval_timer_timeout() -> void:

	if $Status.get_node("StuckStatusTimer").is_stopped():
		chargeMovespeedModifier *= chargeSpeedMultiplier

	$HornSpeedIntervalTimer.start(chargeSpeedIncreaseInterval)
