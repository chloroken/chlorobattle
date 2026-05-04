extends "res://boards/_base/board_base.gd"

var arenaCloseTimer = 240.0
var minimumRadiusRatio = 0.25

var dmgModDuration = 30
var globalDmgMod = 30
var globalDmgReciprocal = 3.34 # globalDmgMod * this = 100

var pawnType
var pawnSpawnIndex = 0
var killFeedText = []
var killFeedLineCount = 60
var combatLogText = []
var combatLogLineCount = 60

var startingPlayerCount

@export var monsterSpawner: Resource

func _ready() -> void:
	super()
	
	Engine.set_time_scale(1)
	startingPlayerCount = get_parent().pawnList.size()

	# Start timers
	$Timers.get_node("ArenaCloseTimer").one_shot = true
	$Timers.get_node("ArenaCloseTimer").start(arenaCloseTimer)

	$Sprites.get_node("Wheel1").modulate.a = 0.0
	$Sprites.get_node("Wheel2").modulate.a = 0.0
	
	for i in get_parent().pawnList.size():
		spawn_pawns(i)
	
	var newSpawner = monsterSpawner.instantiate()
	#newSpawner.position = position
	add_child(newSpawner)

func _process(_delta: float) -> void:
	close_arena()
	
	# When only one Pawn remains, proceed to next board
	if get_parent().pawnList.size() <= 1:
		get_parent().switch_board("score")

	# Label showing "global damage modifer" (to delay instakills at start)
	globalDmgMod = min(dmgModDuration, $Timers.get_node("ArenaCloseTimer").get_wait_time() - $Timers.get_node("ArenaCloseTimer").get_time_left())
	$UI.get_node("DamageModTimer").text =  " " + str(int(globalDmgMod * globalDmgReciprocal)) + "%"#str(int(globalDmgMod / dmgModDuration * 100)) + "%"
	if globalDmgMod >= dmgModDuration:
		$UI.get_node("DamageModTimer").modulate.a *= 0.99

	# Label showing match duration timer (only after global damage mod is gone)
	var timeElapsed = int($Timers.get_node("ArenaCloseTimer").get_wait_time() - $Timers.get_node("ArenaCloseTimer").get_time_left())
	if timeElapsed > dmgModDuration:
		$UI.get_node("DurationTimer").modulate.a = min(1.0, (timeElapsed - dmgModDuration) * 0.1)
		$UI.get_node("DurationTimer").text = str(timeElapsed)

	# Label showing players remaining in the game
	var playersRemainingString = str(int(get_parent().pawnList.size()))
	playersRemainingString += "/" + str(startingPlayerCount)
	$UI.get_node("PlayersRemainingLabel").text = playersRemainingString

	# Rotate wheel graphics for visual effect
	$Sprites.get_node("Wheel1").rotation += 0.00025
	$Sprites.get_node("Wheel2").rotation -= 0.00025
	
func close_arena() -> void:

	var ratio = $Timers.get_node("ArenaCloseTimer").get_time_left() / $Timers.get_node("ArenaCloseTimer").get_wait_time()
	var newRatio = max(minimumRadiusRatio, ratio)
	$Collider.scale = Vector2.ONE * newRatio
	$Sprites.get_node("Wheel1").scale = Vector2.ONE * newRatio * 0.9
	$Sprites.get_node("Wheel2").scale = Vector2.ONE * newRatio * 0.9
	boardRadius = $Collider.get_node("Shape").shape.get_radius() * newRatio

	get_parent().get_node("cam").zoom.x = 2 - ratio
	get_parent().get_node("cam").zoom.y = 2 - ratio

	# Fade in arena circle
	$Sprites.get_node("Wheel1").modulate.a = min(0.5, ($Timers.get_node("ArenaCloseTimer").get_wait_time() - $Timers.get_node("ArenaCloseTimer").get_time_left()) / dmgModDuration * 0.5)
	$Sprites.get_node("Wheel2").modulate.a = min(0.5, ($Timers.get_node("ArenaCloseTimer").get_wait_time() - $Timers.get_node("ArenaCloseTimer").get_time_left()) / dmgModDuration * 0.5)

func spawn_pawns(i: int) -> void:
	# Get Pawn type
	var pawn = get_parent().pawnList[i]
	if pawn.type == "candle": pawnType = get_parent().candle
	elif pawn.type == "chair": pawnType = get_parent().chair
	elif pawn.type == "cyclone": pawnType = get_parent().cyclone
	elif pawn.type == "flicker": pawnType = get_parent().flicker
	elif pawn.type == "grouper": pawnType = get_parent().grouper
	elif pawn.type == "meta": pawnType = get_parent().meta
	elif pawn.type == "mummy": pawnType = get_parent().mummy
	elif pawn.type == "pirate": pawnType = get_parent().pirate
	elif pawn.type == "ship": pawnType = get_parent().ship
	elif pawn.type == "slug": pawnType = get_parent().slug
	elif pawn.type == "top": pawnType = get_parent().top

	# Instantiate Pawn
	var newPawn = pawnType.instantiate()
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
	$UI.get_node("KillFeedLabel").text = newString

func update_combat_log(msg: String) -> void:
	combatLogText.push_front(msg)
	var newString = ""
	# Iterate backwards
	for i in range(min(combatLogLineCount - 1, combatLogText.size() - 1), -1, -1):
		newString += "\n" + combatLogText[i]
	$UI.get_node("CombatLogLabel").text = newString
