extends "res://pawns/_base/base_pawn.gd"

@export var glyphAttackScene: PackedScene
var glyphAttackName = "Glyph"
var glyphChannelDuration = 2.0
var glyphAttackDuration = 3.0
var glyphCooldownMin = 6.0
var glyphCooldownMax = 8.0
var glyphInnerRotationSpeed = 0.25
var glyphOuterRotationSpeed = 0.50
var glyphDisarmDuration = 3.0

@export var swarmAttackScene: Resource
var swarmAttackName = "Swarm"
var swarmCurrentCount = 0
var swarmMaxCount = 5
var swarmFixedCooldown = 5.0
var swarmDamageMultiplier = 0.25
var swarmWeakDuration = 5.0
var swarmSickDuration = 5.0
var swarmMaxDist = 64
var swarmScaleMin = 0.75
var swarmScaleMax = 1.25
var swarmSpeedMin = 50
var swarmSpeedMax = 100
var swarmWanderTimer = 3.0

func _ready() -> void:
	super()
	if !inLobby: 
		$SwarmTimer.one_shot = true
		$SwarmTimer.start(swarmFixedCooldown)
		new_attack_cycle(glyphCooldownMin, glyphCooldownMax)

# Glyph
func _on_attack_cooldown_timer_timeout() -> void:
	new_attack_cycle(glyphCooldownMin, glyphCooldownMax)
	if disarm_check(): return
	new_glyph_attack()
	set_glyph_channel_statuses()
func new_glyph_attack() -> void:
	var newAttack = glyphAttackScene.instantiate()
	newAttack.position = self.position
	newAttack.dmg = self.dmg
	newAttack.attackName = glyphAttackName
	newAttack.isGlyphAttack = true
	newAttack.channelDuration = glyphChannelDuration
	newAttack.glyphDuration = glyphAttackDuration
	$AttackContainer.add_child(newAttack)
func set_glyph_channel_statuses() -> void:
	$Status.start_stuck(glyphChannelDuration, self)
	$Status.start_void(glyphChannelDuration)

# Swarm
func _on_swarm_timer_timeout() -> void:
	$SwarmTimer.start(swarmFixedCooldown)
	if disarm_check(): return
	if swarmCurrentCount >= swarmMaxCount: return
	new_swarm_attack()
	increment_swarm_count()
func new_swarm_attack() -> void:
	var newSwarm = swarmAttackScene.instantiate()
	newSwarm.position = self.position
	newSwarm.dmg = self.dmg * swarmDamageMultiplier
	newSwarm.tetherDistance = swarmMaxDist
	newSwarm.speed = randf_range(swarmSpeedMin, swarmSpeedMax)
	newSwarm.wanderCooldown = swarmWanderTimer
	newSwarm.attackName = swarmAttackName
	newSwarm.areaAttack = false
	newSwarm.isSwarmAttack = true
	newSwarm.scaleMod = randf_range(swarmScaleMin, swarmScaleMax)
	$AttackContainer.add_child(newSwarm)
func increment_swarm_count() -> void:
	swarmCurrentCount += 1
	if swarmCurrentCount > swarmMaxCount: swarmCurrentCount = swarmMaxCount
