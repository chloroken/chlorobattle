extends Node

var statusContainer

@export var dotIcon: Resource
@export var drunkIcon: Resource
@export var lazyIcon: Resource
@export var scaredIcon: Resource
@export var statusIcon: Resource
@export var slowIcon: Resource
@export var sprintIcon: Resource
@export var stuckIcon: Resource
@export var tankyIcon: Resource
@export var timidIcon: Resource
@export var voidIcon: Resource
@export var weakIcon: Resource

var stuckCooldown = 15.0

func _ready() -> void:
	statusContainer = get_parent().get_node("gui").get_node("StatusFlowContainer")
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

func start_slow(timer: float) -> void:
	if $SlowStatusTimer.get_time_left() > timer: return
	$SlowStatusTimer.start(timer)
	enable_status_icon(timer, slowIcon)
func stop_slow() -> void:
	disable_status_icon(slowIcon)
	$StuckStatusTimer.stop()

func start_sprint(timer: float) -> void:
	if $SprintStatusTimer.get_time_left() > timer: return
	$SprintStatusTimer.start(timer)
	enable_status_icon(timer, sprintIcon)
func stop_sprint() -> void:
	disable_status_icon(sprintIcon)
	$SprintStatusTimer.stop()

func start_stuck(timer: float) -> void:
	if $StuckStatusTimer.get_time_left() > timer: return
	$StuckStatusTimer.start(timer)
	enable_status_icon(timer, stuckIcon)
func stop_stuck() -> void:
	disable_status_icon(stuckIcon)
	$StuckStatusTimer.stop()

func start_timid(timer: float) -> void:
	if $TimidStatusTimer.get_time_left() > timer: return
	$TimidStatusTimer.start(timer)
	enable_status_icon(timer, timidIcon)
func stop_timid() -> void:
	disable_status_icon(timidIcon)
	$TimidStatusTimer.stop()

func start_void(timer: float) -> void:
	var pawnSprite = get_parent().get_node("PawnSprite")
	pawnSprite.modulate.a = 0.5
	pawnSprite.modulate.r = 0.0
	pawnSprite.modulate.b = 0.0
	pawnSprite.modulate.g = 0.0
	get_parent().set_collision_mask_value(1, false)
	$VoidStatusTimer.start(timer)
	enable_status_icon(timer, voidIcon)
func _on_void_status_timer_timeout() -> void:
	var pawnSprite = get_parent().get_node("PawnSprite")
	pawnSprite.modulate.a = 1.0
	pawnSprite.modulate.r = 1.0
	pawnSprite.modulate.b = 1.0
	pawnSprite.modulate.g = 1.0
	get_parent().set_collision_mask_value(1, true)
func stop_void() -> void:
	disable_status_icon(voidIcon)
	$VoidStatusTimer.stop()

func start_weak(timer: float) -> void:
	if $WeakStatusTimer.get_time_left() > timer: return
	$WeakStatusTimer.start(timer)
	enable_status_icon(timer, weakIcon)
func stop_weak() -> void:
	disable_status_icon(weakIcon)
	$WeakStatusTimer.stop()
	
# dot drunk lazy scared tanky
