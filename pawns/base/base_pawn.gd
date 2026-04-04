extends Area2D

# Pawn properties
@export var username: String
@export var type: String
@export var style: String
@export var item: String
@export var size: float
@export var hp: float
@export var dmg: float
@export var asp: float
@export var pen: float
@export var def: float
@export var spd: float
@export var tombstone: PackedScene
@export var killbot: PackedScene
@export var diceEffect: PackedScene
@export var milkshakeEffect: PackedScene
@export var skateEffect: PackedScene

var attacksDisabled = false
var nameCharLimit = 9
var destination: Vector2
var attackObjects = []
var baseHp
var damageTaken = 0
var damageDealt = 0
var killCount = 0
var placeEarned = 0
var antimatterCooldown = 10.0
var antimatterRandomizer = 2.0
var antimatterDuration = 2.0
var diceSides = 6
var milkshakeUsed = false
var milkshakeDelay = 3
var milkshakeThreshold = 0.25
var milkshakePercent = 0.25
var skateSpeed = 2.0

# enable aoe
var hitList = []

func _ready() -> void:
	if attacksDisabled:
		$AttackCooldownTimer.stop()
		#$NameLabel.visible = false
		$HitpointLabel.visible = false
		$HitpointLabelBlack.visible = false
		$HitpointLabelRed.visible = false
		$HitpointLabelGreen.visible = false
	else:
		# Initial check for items
		if item == "antimatter":
			$AntimatterCooldownTimer.start(antimatterDuration)
		elif item == "killbot":
			item_spawn_killbot()
		
	destination = new_destination()
	
	# Save hp for modifying/checking max
	baseHp = hp
	
	# Update attack speed
	$AttackCooldownTimer.set_wait_time((1.0 - asp) * $AttackCooldownTimer.get_wait_time())	
	
	# Adjust sprite dimensions
	$PawnSprite.scale *= size
	$PawnCollider.scale *= size
	

func _process(_delta: float) -> void:
	# Update Pawn name
	if $NameLabel.text != username:
		$NameLabel.text = username.substr(0, nameCharLimit)
	
	# Update Pawn hp bar
	$HitpointLabel.text = str(int(ceil(hp)))
	$HitpointLabelGreen.scale.x = hp / baseHp
	
	# Check for milkshake thresholds
	item_check_milkshake()

# Pawn movement
func _physics_process(delta: float) -> void:
	if global_position.distance_to(destination) < 10:
		destination = new_destination()
	else:
		global_position = global_position.move_toward(destination, spd * delta)

# When a Pawn gets hit by an attack
func _on_body_entered(body: Node2D) -> void:
	var attackingPawn = body.get_parent().get_parent()
	var attackerUsername = attackingPawn.username
	# Disable self-hits & multiple hits from area attacks
	if attackerUsername != username && !hitList.has(body):
		calculate_damage(attackingPawn, attackerUsername, body)
		if !body.areaAttack: body.queue_free()
		else: hitList.append(body)
		item_try_skating()
	if hp <= 0:
		var pawns = get_parent().get_parent().pawnList
		for i in range(0, pawns.size()):
			if pawns[i].username == username:
				attackingPawn.killCount += 1
				pawn_death(attackingPawn, attackerUsername, i)
				break
	item_skate_effect()

# Cleaning up Pawn attacks after death
func _on_tree_exiting() -> void:
	for attack in attackObjects:
		if attack != null:
			attack.queue_free()

# Calculate a new place for Pawn to go
func new_destination() -> Vector2:
	var center = get_viewport_rect().size / 2.0
	var radius = get_parent().boardRadius
	var rando = ((Vector2.RIGHT * radius).rotated(randf_range(0, TAU)))
	var desto = center + rando
	while global_position.distance_to(desto) < radius:
		desto = new_destination()
	return(desto)

# Logic performed when Pawn dies
func pawn_death(attackingPawn, killer: String, pawnIndex: int) -> void:
	var mainBoard = get_parent().get_parent()
	var newTombstone = tombstone.instantiate()
	newTombstone.global_position = global_position
	newTombstone.username = username
	mainBoard.add_sibling(newTombstone)
	print("[" + str(username) + "] was killed by [" + str(killer) + "]")
	update_scoreboard(mainBoard, self, pawnIndex, false)
	self.queue_free()
	if mainBoard.pawnList.size() <= 1:
		update_scoreboard(mainBoard, attackingPawn, pawnIndex, true)

func update_scoreboard(mainBoard, pawn, pawnIndex, last) -> void:
	var newScore = mainBoard.Pawn.new()
	newScore.username = pawn.username
	newScore.type = pawn.type
	newScore.style = pawn.style
	newScore.item = pawn.item
	newScore.damageTaken = pawn.damageTaken
	newScore.damageDealt = pawn.damageDealt
	newScore.killCount = pawn.killCount
	mainBoard.scoreList.push_front(newScore)
	if !last: mainBoard.pawnList.remove_at(pawnIndex)

# A small float for breaking ties
func random_variance() -> float:
	return(randf_range(0.0001, 0.001))

func _on_antimatter_cooldown_timer_timeout() -> void:
	set_collision_mask_value(1, false)
	$PawnSprite.modulate.a = 0.5
	$PawnSprite.modulate.r = 0.0
	$PawnSprite.modulate.b = 0.0
	$PawnSprite.modulate.g = 0.0
	$NameLabel.visible = false
	$AntimatterDurationTimer.start(antimatterDuration)
	print("[" + username + "] used [antimatter]")

func _on_antimatter_duration_timer_timeout() -> void:
	set_collision_mask_value(1, true)
	$PawnSprite.modulate.a = 1.0
	$PawnSprite.modulate.r = 1.0
	$PawnSprite.modulate.b = 1.0
	$PawnSprite.modulate.g = 1.0
	$NameLabel.visible = true
	$AntimatterCooldownTimer.start(randf_range($AntimatterCooldownTimer.get_wait_time() / antimatterRandomizer, antimatterCooldown))

func _on_milkshake_delay_timer_timeout() -> void:
	hp += milkshakePercent * baseHp
	print("[" + str(username) + "] finished [milkshake]")

func _on_skate_duration_timer_timeout() -> void:
	$PawnSprite.modulate.a = 1.0
	$PawnSprite.modulate.r = 1.0
	$PawnSprite.modulate.b = 1.0
	$PawnSprite.modulate.g = 1.0
	spd /= skateSpeed
	$SkateSnowflakeTimer.stop()

func _on_skate_snowflake_timer_timeout() -> void:
	var newFlake = skateEffect.instantiate()
	add_child(newFlake)

func calculate_damage(attackingPawn, attackerUsername, body) -> void:
	var baseHit = body.dmg
	var hitText = "hit"
	if attackingPawn.item == "dice":
		if randi_range(1, 4) == 1:
			hitText = "crit"
			baseHit = item_roll_dice(baseHit, attackingPawn)
	var mitigated = baseHit * self.def
	var penetrated = mitigated * (1.0 - attackingPawn.pen)
	var realHit = baseHit - penetrated
	self.hp -= realHit
	damageTaken += realHit
	attackingPawn.damageDealt += realHit
	print("[" + str(attackerUsername) + "] " + str(hitText) + " [" + str(self.username) + "] for " + "%0.2f" % realHit + " dmg — [" + "%0.2f" % baseHit + " - " + "%0.2f" % mitigated + " + " + "%0.2f" % (mitigated - penetrated) + "]")

func item_spawn_killbot() -> void:
	var newBot = killbot.instantiate()
	$AttackContainer.add_child(newBot)
	newBot.global_position = self.global_position
	newBot.follow = self
	newBot.destination = self.global_position
	print("[" + username + "] used [killbot]")

func item_try_skating() -> void:
	if item == "skates" && $SkateDurationTimer.is_stopped():
		print("[" + str(username) + "] used [skates]")
		$SkateDurationTimer.start()
		spd *= skateSpeed

func item_skate_effect() -> void:
	if $SkateDurationTimer.get_time_left() > 0:
		$SkateSnowflakeTimer.start()
		var newFlake = skateEffect.instantiate()
		add_child(newFlake)

func item_roll_dice(baseHit, attackingPawn) -> float:				
	var die1 = randi_range(1, diceSides)
	var die2 = randi_range(1, diceSides)
	var die3 = randi_range(1, diceSides)
	var newDie1 = diceEffect.instantiate()
	var newDie2 = diceEffect.instantiate()
	var newDie3 = diceEffect.instantiate()
	newDie1.global_position = attackingPawn.global_position
	newDie2.global_position = attackingPawn.global_position
	newDie3.global_position = attackingPawn.global_position
	newDie1.diceChoice = die1
	newDie2.diceChoice = die2
	newDie3.diceChoice = die3
	add_sibling(newDie1)
	add_sibling(newDie2)
	add_sibling(newDie3)
	#diceEffect
	baseHit *= 1 + (die1 + die2 + die3) * 0.1
	print("[" + str(attackingPawn.username) + "] used [dice]: " + str(1.0 + 0.1 * (die1 + die2 + die3)) + "x (" + str(die1) + "+" + str(die2) + "+" + str(die3) + ")")
	return(baseHit)

func item_check_milkshake() -> void:
	if item == "milkshake" && hp < milkshakeThreshold * baseHp && !milkshakeUsed:
		print("[" + str(username) + "] started [milkshake]")
		milkshakeUsed = true
		$MilkshakeDelayTimer.start(milkshakeDelay)
		var newMilkshake = milkshakeEffect.instantiate()
		add_child(newMilkshake)
