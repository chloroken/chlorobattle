extends Node2D

@export var healthwormNpc: Resource
var healthwormCooldownMin = 2.0
var healthwormCooldownMax = 5.0
var healthwormArray = []

# Board variables
var baseRadius
var boardRadius = 400
var minimumRadiusRatio = 0.25
var arenaCloseTimer = 240.0
var spawnStaggerTimer = 0.01

# Global damage ramp variables
var dmgModDuration = 30
var globalDmgMod = 30
var globalDmgReciprocal = 3.34 # globalDmgMod * this = 100

# Variables used for spawning Pawns
var pawnType
var pawnSpawnIndex = 0

# Kill feed & combat log variables
var killFeedText = []
var killFeedLineCount = 5
var combatLogText = []
var combatLogLineCount = 6

func _ready() -> void:
	$HealthwormSpawnTimer.one_shot = true
	$HealthwormSpawnTimer.start(randf_range(healthwormCooldownMin, healthwormCooldownMax))
	
	$BellSound.panning_strength = 0.0
	$BellSound.play()
	Engine.set_time_scale(1)
	
	# Snapshot board radius to accurately scale everything
	baseRadius = boardRadius
	$BoardSprite.modulate.a = 0.0
	$BoardSprite2.modulate.a = 0.0

	# Start timers
	$ArenaCloseTimer.one_shot = true
	$ArenaCloseTimer.set_wait_time(arenaCloseTimer)
	$ArenaCloseTimer.start()
	$SpawnStaggerTimer.set_wait_time(spawnStaggerTimer)
	$SpawnStaggerTimer.start()

func _process(_delta: float) -> void:
	# Gradually reduce size of board to force battle royale gameplay
	var ratio = $ArenaCloseTimer.get_time_left() / $ArenaCloseTimer.get_wait_time()
	boardRadius = baseRadius * ratio

	# Ensure arena doesn't get too small
	var newRatio = max(minimumRadiusRatio, boardRadius / baseRadius)
	boardRadius = baseRadius * newRatio
	$BoardSprite.scale.x = newRatio
	$BoardSprite.scale.y = newRatio
	$BoardSprite2.scale.x = newRatio
	$BoardSprite2.scale.y = newRatio
	
	get_parent().get_node("Camera2D").zoom.x = 2 - ratio
	get_parent().get_node("Camera2D").zoom.y = 2 - ratio

	# Fade in arena circle
	$BoardSprite.modulate.a = min(0.5, ($ArenaCloseTimer.get_wait_time() - $ArenaCloseTimer.get_time_left()) / dmgModDuration * 0.5)
	$BoardSprite2.modulate.a = min(0.5, ($ArenaCloseTimer.get_wait_time() - $ArenaCloseTimer.get_time_left()) / dmgModDuration * 0.5)
	
	# When only one Pawn remains, proceed to next board
	if get_parent().pawnList.size() <= 1:
		get_parent().switch_board("score")

	# Label showing "global damage modifer" (to delay instakills at start)
	globalDmgMod = min(dmgModDuration, $ArenaCloseTimer.get_wait_time() - $ArenaCloseTimer.get_time_left())
	$DamageModTimer.text = str(int(globalDmgMod * globalDmgReciprocal)) + "%"#str(int(globalDmgMod / dmgModDuration * 100)) + "%"
	if globalDmgMod >= dmgModDuration:
		$DamageModTimer.modulate.a *= 0.99

	# Label showing match duration timer (only after global damage mod is gone)
	var timeElapsed = int($ArenaCloseTimer.get_wait_time() - $ArenaCloseTimer.get_time_left())
	if timeElapsed > dmgModDuration:
		$DurationTimer.modulate.a = min(1.0, (timeElapsed - dmgModDuration) * 0.1)
		$DurationTimer.text = str(timeElapsed)

	# Label showing players remaining in the game
	var playersRemainingString = str(int(get_parent().pawnList.size()))
	playersRemainingString += " players left"
	$ArenaCanvas.get_node("PlayersRemainingLabel").text = playersRemainingString

	# Rotate board graphics for visual effect
	$BoardSprite.rotation += 0.00025
	$BoardSprite2.rotation -= 0.00025

# Stagger Pawn spawning for visual effect
func _on_spawn_stagger_timer_timeout() -> void:
	spawn_pawns(pawnSpawnIndex)
	pawnSpawnIndex += 1
	if pawnSpawnIndex >= get_parent().pawnList.size():
		$SpawnStaggerTimer.stop()

func spawn_pawns(i: int) -> void:
	# Get Pawn type
	var pawn = get_parent().pawnList[i]
	if pawn.type == "candle": pawnType = get_parent().candle
	elif pawn.type == "chair": pawnType = get_parent().chair
	elif pawn.type == "cyclone": pawnType = get_parent().cyclone
	elif pawn.type == "flicker": pawnType = get_parent().flicker
	elif pawn.type == "grouper": pawnType = get_parent().grouper
	elif pawn.type == "mummy": pawnType = get_parent().mummy
	elif pawn.type == "pirate": pawnType = get_parent().pirate
	elif pawn.type == "ship": pawnType = get_parent().ship
	elif pawn.type == "slug": pawnType = get_parent().slug
	elif pawn.type == "top": pawnType = get_parent().top

	# Instantiate Pawn
	var newPawn = pawnType.instantiate()
	var center = get_viewport_rect().size / 2.0
	newPawn.position = center + evenly_spaced_position(i)
	newPawn.name = pawn.username
	newPawn.username = pawn.username # str(randf()) # 
	newPawn.type = pawn.type
	newPawn.style = pawn.style
	newPawn.item = pawn.item

	add_child(newPawn)
	print("Spawned " + newPawn.type + " (" + newPawn.style + ") [" + newPawn.item + "] for " + newPawn.username)

func evenly_spaced_position(i: int) -> Vector2:
	var rot = 2 * PI * i / get_parent().pawnList.size()
	var vec = ((Vector2.RIGHT * boardRadius) * 0.9).rotated(rot)
	return(vec)

func update_kill_feed(msg: String) -> void:
	killFeedText.push_front(msg)
	var newString = ""
	# Iterate backwards
	for i in range(min(killFeedLineCount - 1, killFeedText.size() - 1), -1, -1):
		newString += "\n" + killFeedText[i]
	$ArenaCanvas.get_node("KillFeedLabel").text = newString

func update_combat_log(msg: String) -> void:
	combatLogText.push_front(msg)
	var newString = ""
	# Iterate backwards
	for i in range(min(combatLogLineCount - 1, combatLogText.size() - 1), -1, -1):
		newString += "\n" + combatLogText[i]
	$ArenaCanvas.get_node("CombatLogLabel").text = newString

func _on_healthworm_spawn_timer_timeout() -> void:
	var newWorm = healthwormNpc.instantiate()
	var center = get_viewport_rect().size / 2.0
	newWorm.position = center
	add_child(newWorm)
	healthwormArray.append(newWorm)
	$HealthwormSpawnTimer.start(randf_range(healthwormCooldownMin, healthwormCooldownMax))
