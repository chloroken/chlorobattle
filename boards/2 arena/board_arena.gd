extends Node2D

# Board variables
var baseRadius
var boardRadius = 400
var minimumRadius = 0.5
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

# Snapshot board radius to accurately scale everything
func _ready() -> void:
	baseRadius = boardRadius
	$BoardSprite.modulate.a = 0.0
	$BoardSprite2.modulate.a = 0.0

func _process(_delta: float) -> void:
	# Gradually reduce size of board to force battle royale gameplay
	var ratio = $BoardDurationTimer.get_time_left() / $BoardDurationTimer.get_wait_time()
	boardRadius = baseRadius * ratio #max(minimumRadius, 
	var newRatio = max(minimumRadius, boardRadius / baseRadius)
	boardRadius = baseRadius * newRatio
	$BoardSprite.scale.x = newRatio
	$BoardSprite.scale.y = newRatio
	$BoardSprite2.scale.x = newRatio
	$BoardSprite2.scale.y = newRatio
	#print(str($BoardSprite.scale.x))

	# When only one Pawn remains, proceed to next board
	if get_parent().pawnList.size() <= 1:
		get_parent().switch_board("score")

	# Label showing "global damage modifer" (to delay instakills at start)
	globalDmgMod = min(dmgModDuration, $BoardDurationTimer.get_wait_time() - $BoardDurationTimer.get_time_left())
	$DamageModTimer.text = str(int(globalDmgMod * globalDmgReciprocal)) + "%"#str(int(globalDmgMod / dmgModDuration * 100)) + "%"
	if globalDmgMod >= dmgModDuration:
		$DamageModTimer.modulate.a *= 0.99

	# Label showing match duration timer (only after global damage mod is gone)
	var timeElapsed = int($BoardDurationTimer.get_wait_time() - $BoardDurationTimer.get_time_left())
	if timeElapsed > dmgModDuration:
		$DurationTimer.modulate.a = min(1.0, (timeElapsed - dmgModDuration) * 0.1)
		$DurationTimer.text = str(timeElapsed)

	# Fade in arena circle
	$BoardSprite.modulate.a = min(0.5, ($BoardDurationTimer.get_wait_time() - $BoardDurationTimer.get_time_left()) / dmgModDuration * 0.5)
	$BoardSprite2.modulate.a = min(0.5, ($BoardDurationTimer.get_wait_time() - $BoardDurationTimer.get_time_left()) / dmgModDuration * 0.5)
	#$BoardSprite.modulate.a = min(0.5, $BoardSprite.modulate.a)
	#$BoardSprite2.modulate.a = min(0.5, $BoardSprite2.modulate.a)

	# Label showing players remaining in the game
	var playersRemainingString = str(int(get_parent().pawnList.size()))
	playersRemainingString += " players left"
	$PlayersRemainingLabel.text = playersRemainingString

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
	elif pawn.type == "grouper": pawnType = get_parent().grouper
	elif pawn.type == "pirate": pawnType = get_parent().pirate
	elif pawn.type == "ship": pawnType = get_parent().ship
	elif pawn.type == "slug": pawnType = get_parent().slug
	elif pawn.type == "top": pawnType = get_parent().top

	# Instantiate Pawn
	var newPawn = pawnType.instantiate()
	var center = get_viewport_rect().size / 2.0
	newPawn.position = center + evenly_spaced_position(i)
	newPawn.username = pawn.username # str(randf()) # 
	newPawn.type = pawn.type

	# Set Pawn style (function call is unreadable, refactor this)
	if pawn.style == "berserk":
		adjust_pawn_stats(newPawn, 0.75, 1.0, 1.0, 1.25, 1.0, 1.0, 1.0)
	elif pawn.style == "giant":
		adjust_pawn_stats(newPawn, 1.25, 1.0, max(0, newPawn.asp - 0.2), 1.25, 1.0, 0.75, 1.5)
	elif pawn.style == "insane":
		adjust_pawn_stats(newPawn, 1.0, max(0, newPawn.def - 0.5), min(1, newPawn.asp + 0.2), 1.1, 1.0, 1.0, 1.0)
	elif pawn.style == "nimble":
		adjust_pawn_stats(newPawn, 0.9, 1.0, 1.0, 1.0, min(1, newPawn.pen + 0.5), 1.25, 0.75)
	elif pawn.style == "sturdy":
		adjust_pawn_stats(newPawn, 1.1, min(1, newPawn.def + 0.2), 1.0, 0.5, 1.0, 1.0, 1.0)
	newPawn.style = pawn.style

	# Set Pawn items
	if pawn.item == "antimatter": newPawn.item = "antimatter"
	elif pawn.item == "dice": newPawn.item = "dice"
	elif pawn.item == "killbot": newPawn.item = "killbot"
	elif pawn.item == "milkshake": newPawn.item = "milkshake"
	elif pawn.item == "skates": newPawn.item = "skates"

	add_child(newPawn)
	print("Spawned " + newPawn.type + " (" + newPawn.style + ") [" + newPawn.item + "] for " + newPawn.username)

func adjust_pawn_stats(pawnToMod, hpMod: float, defMod: float, aspMod: float, dmgMod: float, penMod: float, spdMod: float, sizeMod: float) -> void:
	pawnToMod.hp *= hpMod
	pawnToMod.def *= defMod
	pawnToMod.asp *= aspMod
	pawnToMod.dmg *= dmgMod
	pawnToMod.pen *= penMod
	pawnToMod.spd *= spdMod
	pawnToMod.size *= sizeMod

func evenly_spaced_position(i: int) -> Vector2:
	var rot = 2 * PI * i / get_parent().pawnList.size()
	var vec = ((Vector2.RIGHT * boardRadius) * 0.9).rotated(rot)
	return(vec)

func update_kill_feed(msg: String) -> void:
	killFeedText.push_front(msg)
	var newString = ""
	for i in killFeedText.size():
		newString += "\n" + killFeedText[i]
		if i >= killFeedLineCount - 1:
			break
	$KillFeedLabel.text = newString

func update_combat_log(msg: String) -> void:
	combatLogText.push_front(msg)
	var newString = ""
	# Iterate backwards
	for i in range(min(combatLogLineCount - 1, combatLogText.size() - 1), -1, -1):
		newString += "\n" + combatLogText[i]
	$CombatLogLabel.text = newString
