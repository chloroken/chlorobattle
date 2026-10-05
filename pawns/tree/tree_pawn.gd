extends "res://pawns/_base/base_pawn.gd"

var seasonCurrentSeason = 0
var seasonMaxSeasons = 4
var seasonBaseAttackCooldownMin = 1.0
var seasonBaseAttackCooldownMax = 2.0

@export var seedAttack: Resource
var seedCooldownMin = 10.0
var seedCooldownMax = 15.0
var seedBoardMinDistRatio = 0.2
var seedBoardBufferDist = 0.8
var seedTravelSpeed = 100.0

@export var seasonSpringSkin: Resource
@export var flowerAttackScene: Resource
var springAttackSpeedMultiplier = 1.0
var springDamageMultiplier = 2.0
var springFlowerDurationMin = 8.0
var springFlowerDurationMax = 12.0
var springFlowerSpeedMin = 10
var springFlowerSpeedMax = 20

@export var seasonSummerSkin: Resource
@export var fruitAttackScene: Resource
var summerAttackSpeedMultiplier = 1.5
var summerDamageMultiplier = 4.0
var summerFruitDurationMin = 18.0
var summerFruitDurationMax = 24.0
var summerFruitOffsetDistance = 32

@export var seasonFallSkin: Resource
@export var leafAttackScene: Resource
var fallAttackSpeedMultiplier = 0.5
var fallDamageMultiplier = 1.0
var fallLeafSpeedMin = 1
var fallLeafSpeedMax = 2
var fallLeafDurationMin = 12.0
var fallLeafDurationMax = 16.0
var fallLeafSpeed = 5.0
var fallLeafList = []

@export var seasonWinterSkin: Resource

func _ready() -> void:
	super()
	if !attacksDisabled:
		new_attack_cycle(seasonBaseAttackCooldownMin * get_seasonal_attack_speed(), seasonBaseAttackCooldownMax * get_seasonal_attack_speed())
		start_seed_cooldown()

func advance_season() -> void:
	seasonCurrentSeason += 1
	if seasonCurrentSeason >= seasonMaxSeasons:
		seasonCurrentSeason = 0
	match seasonCurrentSeason:
		0:
			$Status.stop_void()
			$PawnSprite.texture = seasonSpringSkin
		1: $PawnSprite.texture = seasonSummerSkin
		2: $PawnSprite.texture = seasonFallSkin
		3:
			$Status.start_void(999)
			$PawnSprite.texture = seasonWinterSkin
func get_seasonal_attack_speed() -> float:
	match seasonCurrentSeason:
		0: return(springAttackSpeedMultiplier)
		1: return(summerAttackSpeedMultiplier)
		2: return(fallAttackSpeedMultiplier)
		3: return(0)
	return(1.0)

func _on_attack_cooldown_timer_timeout() -> void:
	new_attack_cycle(seasonBaseAttackCooldownMin * get_seasonal_attack_speed(), seasonBaseAttackCooldownMax * get_seasonal_attack_speed())
	if disarm_check(): return
	match seasonCurrentSeason:
		0: spring_flower_attack()
		1: summer_fruit_attack()
		2: fall_leaf_attack()
		3: pass

func spring_flower_attack() -> void:
	var newFlower = flowerAttackScene.instantiate()
	newFlower.position = self.position
	newFlower.attackName = "Flower"
	newFlower.areaAttack = true
	newFlower.dmg = self.dmg * springDamageMultiplier
	newFlower.duration = randf_range(springFlowerDurationMin, springFlowerDurationMax)
	newFlower.speed = randf_range(springFlowerSpeedMin, springFlowerSpeedMax)
	newFlower.direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	newFlower.rotation = randf_range(0, TAU)
	$AttackContainer.add_child(newFlower)
func summer_fruit_attack() -> void:
	var newFruit = fruitAttackScene.instantiate()
	newFruit.position = self.position + (Vector2.RIGHT * summerFruitOffsetDistance).rotated(randf_range(0, TAU))
	newFruit.attackName = "Fruit"
	newFruit.areaAttack = false
	newFruit.dmg = self.dmg * summerDamageMultiplier
	newFruit.duration = randf_range(summerFruitDurationMin, summerFruitDurationMax)
	newFruit.rotation = randf_range(0, TAU)
	$AttackContainer.add_child(newFruit)
func fall_leaf_attack() -> void:
	var newLeaf = leafAttackScene.instantiate()
	newLeaf.position = self.position
	newLeaf.attackName = "Leaf"
	newLeaf.areaAttack = false
	newLeaf.dmg = self.dmg * fallDamageMultiplier
	newLeaf.orbitSpeed = randf_range(fallLeafSpeedMin, fallLeafSpeedMax)
	newLeaf.dur = randf_range(fallLeafDurationMin, fallLeafDurationMax)
	newLeaf.orbitDriftSpeed = fallLeafSpeed
	$AttackContainer.add_child(newLeaf)
	fallLeafList.append(newLeaf)

# Seed
func start_seed_cooldown() -> void:
	var seedCooldown = randf_range(seedCooldownMin, seedCooldownMax)
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
	for leaf in fallLeafList:
		if leaf == null: continue
		leaf.get_node("LeafChaseTimer").start(leaf.chaseTimer)
	advance_season()
