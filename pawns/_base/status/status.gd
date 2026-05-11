extends Node


################
# STATUS SETUP #
################

@export var statusIcon: Resource
var statusContainer
var basePawn
func _ready() -> void:
	basePawn = get_parent()
	# Get container for status icons
	statusContainer = basePawn.get_node("GUI").get_node("StatusFlowContainer")
	# Set up status timers
	for child in self.get_children():
		child.one_shot = true
func enable_status_icon(timer, icon) -> void:
	var statusName = str(icon.resource_path)
	var longestCurrentStatus = 0 
	for status in statusContainer.get_children():
		if status.statusName == statusName:
			var timeLeft = status.get_node("FizzleTimer").get_wait_time()
			if timeLeft > longestCurrentStatus: longestCurrentStatus = timeLeft
			if timeLeft < timer:
				status.queue_free()
	if longestCurrentStatus < timer:
		var newIcon = statusIcon.instantiate()
		newIcon.statusDuration = timer
		newIcon.statusTexture = icon
		newIcon.statusName = statusName
		statusContainer.add_child(newIcon)
func disable_status_icon(icon) -> void:
	var statusName = str(icon.resource_path)
	for status in statusContainer.get_children():
		if status.statusName == statusName:
			status.queue_free()

#########
# BLEED #
#########
@export var bleedIcon: Resource
var bleedMinimumHp = 0.1
var bleedPercentDamage = 0.1
var bleedDamageInterval = 1.0
var bleedPawnSource
func start_bleed(timer: float, source) -> void:
	if $BleedStatusTimer.get_time_left() > timer: return
	bleedPawnSource = source
	$BleedStatusTimer.start(timer)
	$BleedDamageTimer.start(bleedDamageInterval)
	enable_status_icon(timer, bleedIcon)
func _on_bleed_status_timer_timeout() -> void:
	$BleedDamageTimer.stop()
func _on_bleed_damage_timer_timeout() -> void:
	get_parent().status_damage("Bleed")
	$BleedDamageTimer.start(bleedDamageInterval)
func stop_bleed() -> void:
	disable_status_icon(bleedIcon)
	$BleedStatusTimer.stop()
	$BleedDamageTimer.stop()

############
# DISARMED #
############

@export var disarmedIcon: Resource
func start_disarmed(timer: float) -> void:
	if $DisarmedStatusTimer.get_time_left() > timer: return
	$DisarmedStatusTimer.start(timer)
	enable_status_icon(timer, disarmedIcon)
func stop_disarmed() -> void:
	disable_status_icon(disarmedIcon)
	$DisarmedStatusTimer.stop()

#########
# DRUNK #
#########

@export var drunkIcon: Resource
@export var drunkEffect: Resource
var drunkMissChance = 20
var drunkDamageMod = 1.5
var drunkTurnTimerMin = 3.0
var drunkTurnTimerMax = 5.0
func start_drunk(timer: float) -> void:
	if $DrunkStatusTimer.get_time_left() > timer: return
	$DrunkStatusTimer.start(timer)
	var newDrunkEffect = drunkEffect.instantiate()
	newDrunkEffect.position = basePawn.position + Vector2.UP * 55
	basePawn.get_node("AttackContainer").add_child(newDrunkEffect)
	enable_status_icon(timer, drunkIcon)
func stop_drunk() -> void:
	disable_status_icon(drunkIcon)
	$DrunkStatusTimer.stop()

########
# HAZY #
########
@export var hazyIcon: Resource
var hazyMissChance = 0.5
func start_hazy(timer: float) -> void:
	if $HazyStatusTimer.get_time_left() > timer: return
	$HazyStatusTimer.start(timer)
	enable_status_icon(timer, hazyIcon)
func stop_hazy() -> void:
	disable_status_icon(hazyIcon)
	$HazyStatusTimer.stop()
func try_hazy() -> float:
	var hazyChance = 1.0
	if !$HazyStatusTimer.is_stopped():
		hazyChance = hazyMissChance
	return(hazyChance)

########
# LAZY #
########
@export var lazyIcon: Resource
var lazyAspMod = 1.5
func start_lazy(timer: float) -> void:
	if $LazyStatusTimer.get_time_left() > timer: return
	$LazyStatusTimer.start(timer)
	enable_status_icon(timer, lazyIcon)
	basePawn.aspMod = lazyAspMod
func _on_lazy_status_timer_timeout() -> void:
	basePawn.aspMod = 1.0
func stop_lazy() -> void:
	disable_status_icon(lazyIcon)
	$LazyStatusTimer.stop()
	basePawn.aspMod = 1.0

##########
# SCARED #
##########

@export var scaredIcon: Resource
func start_scared(timer: float) -> void:
	if $ScaredStatusTimer.get_time_left() > timer: return
	$ScaredStatusTimer.start(timer)
	enable_status_icon(timer, scaredIcon)
func stop_scared() -> void:
	disable_status_icon(scaredIcon)
	$ScaredStatusTimer.stop()
func try_scared(body) -> void:
	if !$ScaredStatusTimer.is_stopped():
		basePawn.new_direction() # to trigger parkour/styles
		basePawn.direction = -basePawn.position.direction_to(body.position)

########
# SICK #
########

@export var sickIcon: Resource
var sickMinimumHp = 0.1
var sickPercentDamage = 0.01
var sickDamageInterval = 3.0
var sickPawnSource
func start_sick(timer: float, source) -> void:
	if $SickStatusTimer.get_time_left() > timer: return
	sickPawnSource = source
	$SickDamageTimer.start(sickDamageInterval)
	$SickStatusTimer.start(timer)
	enable_status_icon(timer, sickIcon)
func _on_sick_status_timer_timeout() -> void:
	$SickDamageTimer.stop()
func _on_sick_damage_timer_timeout() -> void:
	get_parent().status_damage("Sick")
	$SickDamageTimer.start(sickDamageInterval)
func stop_sick() -> void:
	disable_status_icon(sickIcon)
	$SickStatusTimer.stop()
	$SickDamageTimer.stop()

########
# SLOW #
########

@export var slowIcon: Resource
func start_slow(timer: float) -> void:
	if $SlowStatusTimer.get_time_left() > timer: return
	$SlowStatusTimer.start(timer)
	enable_status_icon(timer, slowIcon)
func stop_slow() -> void:
	disable_status_icon(slowIcon)
	$StuckStatusTimer.stop()

##########
# SPRINT #
##########

@export var sprintIcon: Resource
func start_sprint(timer: float) -> void:
	get_parent().get_node("Styles").style_parkour_add_charge()
	if $SprintStatusTimer.get_time_left() > timer: return
	$SprintStatusTimer.start(timer)
	enable_status_icon(timer, sprintIcon)
func stop_sprint() -> void:
	disable_status_icon(sprintIcon)
	$SprintStatusTimer.stop()

#########
# STUCK #
#########

@export var stuckIcon: Resource
func start_stuck(timer: float) -> void:
	basePawn.get_node("Styles").style_parkour_reset_charges()
	if $StuckStatusTimer.get_time_left() > timer: return
	$StuckStatusTimer.start(timer)
	enable_status_icon(timer, stuckIcon)
func stop_stuck() -> void:
	disable_status_icon(stuckIcon)
	$StuckStatusTimer.stop()

#########
# TANKY #
#########

@export var tankyIcon: Resource
var tankyDamageReduction = 0.50
func start_tanky(timer: float) -> void:
	if $TankyStatusTimer.get_time_left() > timer: return
	$TankyStatusTimer.start(timer)
	enable_status_icon(timer, tankyIcon)
func stop_tanky() -> void:
	disable_status_icon(tankyIcon)
	$TankyStatusTimer.stop()
func tanky_reduce_damage() -> float:
	if $TankyStatusTimer.is_stopped(): return(1.0)
	return(1.0 - tankyDamageReduction)

########
# VOID #
########

@export var voidIcon: Resource
func start_void(timer: float) -> void:
	var pawnSprite = get_parent().get_node("PawnSprite")
	pawnSprite.modulate.a = 0.5
	pawnSprite.modulate.r = 0.0
	pawnSprite.modulate.b = 0.0
	pawnSprite.modulate.g = 0.0
	$VoidStatusTimer.start(timer)
	enable_status_icon(timer, voidIcon)
func _on_void_status_timer_timeout() -> void:
	var pawnSprite = get_parent().get_node("PawnSprite")
	pawnSprite.modulate.a = 1.0
	pawnSprite.modulate.r = 1.0
	pawnSprite.modulate.b = 1.0
	pawnSprite.modulate.g = 1.0

	# run through the attacks that would have
	# hit us and see if they're still colliding
	for attack in basePawn.voidHitList:
		if attack == null: continue
		if attack.get_overlapping_areas().has(basePawn):
			basePawn._on_area_entered(attack)
	basePawn.voidHitList.clear()

func stop_void() -> void:
	disable_status_icon(voidIcon)
	$VoidStatusTimer.stop()

########
# WEAK #
########

@export var weakIcon: Resource
func start_weak(timer: float) -> void:
	if $WeakStatusTimer.get_time_left() > timer: return
	$WeakStatusTimer.start(timer)
	enable_status_icon(timer, weakIcon)
func stop_weak() -> void:
	disable_status_icon(weakIcon)
	$WeakStatusTimer.stop()
