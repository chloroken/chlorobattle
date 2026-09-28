extends "res://pawns/_base/base_pawn.gd"

@export var leafAttack: Resource
var leafCooldownMin = 1.0
var leafCooldownMax = 2.0
var leafSpeedMin = 1
var leafSpeedMax = 2
var leafDurMin = 8.0
var leafDurMax = 12.0
var leafDriftSpeed = 5.0
var leafList = []

@export var seedAttack: Resource
var seedCooldownMin = 10.0
var seedCooldownMax = 15.0
var seedBoardMinDistRatio = 0.2
var seedBoardBufferDist = 0.8
var seedTravelSpeed = 100.0

func _ready() -> void:
	super()

	if !attacksDisabled:
		start_attack_cooldown()
		start_seed_cooldown()

func start_attack_cooldown() -> void:
	var leafCooldown = randf_range(leafCooldownMin, leafCooldownMax)
	leafCooldown *= asp * aspMod
	$AttackCooldownTimer.start(leafCooldown)

func _on_attack_cooldown_timer_timeout() -> void:
	var newLeaf = leafAttack.instantiate()
	newLeaf.position = self.position
	newLeaf.attackName = "Leaf"
	newLeaf.dmg = self.dmg
	newLeaf.orbitSpeed = randf_range(leafSpeedMin, leafSpeedMax)
	newLeaf.dur = randf_range(leafDurMin, leafDurMax)
	newLeaf.orbitDriftSpeed = leafDriftSpeed
	$AttackContainer.add_child(newLeaf)
	leafList.append(newLeaf)
	start_attack_cooldown()

func start_seed_cooldown() -> void:
	var seedCooldown = randf_range(seedCooldownMin, seedCooldownMax)
	seedCooldown *= asp * aspMod
	$SeedCooldownTimer.start(seedCooldown)

func _on_seed_cooldown_timer_timeout() -> void:
	var seedPos = try_seed_pos()
	while seedPos.distance_to(center) > get_parent().boardRadius * seedBoardBufferDist:
		seedPos = try_seed_pos()

	var newSeed = seedAttack.instantiate()
	newSeed.position = self.position
	newSeed.seedSpeed = seedTravelSpeed
	newSeed.destination = seedPos
	$AttackContainer.add_child(newSeed)

	start_seed_cooldown()

func try_seed_pos() -> Vector2:
	var newPos = position
	var boardRadius = get_parent().boardRadius
	while position.distance_to(newPos) < boardRadius * seedBoardMinDistRatio:
		var ranX = randf_range(-boardRadius, boardRadius)
		var ranY = randf_range(-boardRadius, boardRadius)
		newPos = get_parent().center + Vector2(ranX, ranY)
	return(newPos)

func seed_relocate(destination) -> void:
	position = destination
	for leaf in leafList:
		if leaf == null: continue
		if leaf.is_queued_for_deletion(): continue
		leaf.queue_free()
