extends Node2D

var pawnType
var baseRadius
var minimumRadius
var boardRadius = 280
var pawnSpawnIndex = 0
var dmgModDuration = 10
var globalDmgMod = 10
var killFeedText = []
var killFeedLineCount = 5
var combatLogText = []
var combatLogLineCount = 6

# Snapshot board radius to accurate scale everything
func _ready() -> void:
	baseRadius = boardRadius
	minimumRadius = baseRadius/10

func _process(_delta: float) -> void:
	# Update global damage mod (to delay instakills at start)
	globalDmgMod = min(dmgModDuration, $BoardDurationTimer.get_wait_time() - $BoardDurationTimer.get_time_left())
	$DamageModTimer.text = str(int(globalDmgMod * 10)) + "%"#str(int(globalDmgMod / dmgModDuration * 100)) + "%"
	if globalDmgMod >= dmgModDuration:
		$DamageModTimer.modulate.a *= 0.99
	
	var timeElapsed = int($BoardDurationTimer.get_wait_time() - $BoardDurationTimer.get_time_left())
	if timeElapsed > 10:
		$DurationTimer.modulate.a = min(1.0, (timeElapsed - 10) * 0.1)
		$DurationTimer.text = str(timeElapsed)
	
	# Rotate board graphics
	$BoardSprite.rotation += 0.00025
	$BoardSprite2.rotation -= 0.00025

	# Board radius reduction mechanic
	var ratio = $BoardDurationTimer.get_time_left() / $BoardDurationTimer.get_wait_time()
	boardRadius = max(minimumRadius, baseRadius * ratio)
	$BoardSprite.scale.x = ratio * 0.9
	$BoardSprite.scale.y = ratio * 0.9
	$BoardSprite2.scale.x = ratio * 0.9
	$BoardSprite2.scale.y = ratio * 0.9
	
	# When only one Pawn remains, proceed to next board
	if get_parent().pawnList.size() <= 1:
		get_parent().switch_board("score")

# Using a timer, stagger Pawn spawning to avoid instadeaths
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

	# Set Pawn style
	if pawn.style == "berserk":
		newPawn.hp *= 0.75
		newPawn.dmg *= 1.25
	elif pawn.style == "giant":
		newPawn.hp *= 1.25
		newPawn.asp = max(0, newPawn.asp - 0.2)
		newPawn.spd *= 0.75
		newPawn.size *= 1.25
	elif pawn.style == "insane":
		newPawn.def = max(0, newPawn.def - 0.5)
		newPawn.asp = min(1, newPawn.asp + 0.2)
		newPawn.dmg *= 1.1
	elif pawn.style == "nimble":
		newPawn.hp *= 0.9
		newPawn.pen = min(1, newPawn.pen + 0.5)
		newPawn.spd *= 1.25
		newPawn.size *= 0.75
	elif pawn.style == "sturdy":
		newPawn.hp *= 1.1
		newPawn.def = min(1, newPawn.def + 0.2)
		newPawn.dmg *= 0.9
	newPawn.style = pawn.style
	
	# Set Pawn items
	if pawn.item == "antimatter": newPawn.item = "antimatter"
	elif pawn.item == "dice": newPawn.item = "dice"
	elif pawn.item == "killbot": newPawn.item = "killbot"
	elif pawn.item == "milkshake": newPawn.item = "milkshake"
	elif pawn.item == "skates": newPawn.item = "skates"
	
	add_child(newPawn)
	print("Spawned " + newPawn.type + " (" + newPawn.style + ") [" + newPawn.item + "] for " + newPawn.username)

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
	#while combatLogText.size() < combatLogLineCount:
		#combatLogText.push_front("")
		#if combatLogText.size() >= combatLogLineCount:
			#break
	combatLogText.push_front(msg)
	var newString = ""
	for i in range(min(combatLogLineCount - 1, combatLogText.size() - 1), -1, -1):
		newString += "\n" + combatLogText[i]
	$CombatLogLabel.text = newString
