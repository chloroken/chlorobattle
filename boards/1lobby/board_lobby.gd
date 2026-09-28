extends "res://boards/_base/board_base.gd"

var lobbyTimer = 60.0
var lobbyJoiners = []
var titleStringChar = 0
var titleStringFlashReset = 3.0
var titleStringFlashSpeed = 0.1
var uiFadeSpeed = 0.005

func _ready() -> void:
	super()

	# LET TWITCH COOK
	#VerySimpleTwitch.get_token_and_login_chat()
	#VerySimpleTwitch.chat_message_received.connect(print_chatter_message)
	#register_pawn("YouTube", choose_random_pawn(), choose_random_style(), choose_random_item())

	# Create bot Pawns to test with
	#for i in 2:
		#register_pawn("Bot " + str(i+1), choose_random_pawn(), choose_random_style(), "treat")
	# Create specific test bots

	# 1v1s
	#register_pawn("dank_gr4vy", "chair", "mighty", "map")
	#register_pawn("themadzster", "mecha", "mighty", "milkshake")
	
	# All pawns for testing
	register_pawn("candle", "candle", choose_random_style(), choose_random_item())
	register_pawn("cat", "cat", choose_random_style(), choose_random_item())
	register_pawn("chair", "chair", choose_random_style(), choose_random_item())
	register_pawn("demon", "demon", choose_random_style(), choose_random_item())
	register_pawn("fish", "fish", choose_random_style(), choose_random_item())
	register_pawn("ghost", "ghost", choose_random_style(), choose_random_item())
	register_pawn("mecha", "mecha", choose_random_style(), choose_random_item())
	register_pawn("mummy", "mummy", choose_random_style(), choose_random_item())
	register_pawn("pirate", "pirate", choose_random_style(), choose_random_item())
	register_pawn("ram", "ram", choose_random_style(), choose_random_item())
	register_pawn("ship", "ship", choose_random_style(), choose_random_item())
	register_pawn("slug", "slug", choose_random_style(), choose_random_item())
	register_pawn("top", "top", choose_random_style(), choose_random_item())
	register_pawn("tree", "tree", choose_random_style(), choose_random_item())
	register_pawn("witch", "witch", choose_random_style(), choose_random_item())

	# Spawn Pawns made above
	for pawn in get_parent().pawnList:
		spawn_pawn(pawn, true)
		update_joined_pawn_label(pawn)

	# Start lobby timer
	$Timers.get_node("LobbyTimer").set_wait_time(lobbyTimer)
	$Timers.get_node("LobbyTimer").start()
	
	$UI.get_node("TitleColorTimer").start(titleStringFlashSpeed)
	$UI.get_node("TitleLabel").modulate.a = 0
	$UI.get_node("TimerLabel").modulate.a = 0
	$UI.get_node("JoinerCount").modulate.a = 0
	$UI.get_node("JoinLogRichLabel").modulate.a = 0
	$UI.get_node("CheatSheetLabel").modulate.a = 0
	$UI.get_node("CheatSheetLabel2").modulate.a = 0
	$UI.get_node("InstructionLabel").modulate.a = 0

func _process(_delta: float) -> void:

	$UI.get_node("TitleLabel").modulate.a += uiFadeSpeed
	if $UI.get_node("TitleLabel").modulate.a > 1.0:
		$UI.get_node("TitleLabel").modulate.a = 1.0
	$UI.get_node("TimerLabel").modulate.a += uiFadeSpeed
	if $UI.get_node("TimerLabel").modulate.a > 1.0:
		$UI.get_node("TimerLabel").modulate.a = 1.0
	$UI.get_node("JoinerCount").modulate.a += uiFadeSpeed
	if $UI.get_node("JoinerCount").modulate.a > 1.0:
		$UI.get_node("JoinerCount").modulate.a = 1.0
	$UI.get_node("JoinLogRichLabel").modulate.a += uiFadeSpeed
	if $UI.get_node("JoinLogRichLabel").modulate.a > 1.0:
		$UI.get_node("JoinLogRichLabel").modulate.a = 1.0
	$UI.get_node("CheatSheetLabel").modulate.a += uiFadeSpeed
	if $UI.get_node("CheatSheetLabel").modulate.a > 1.0:
		$UI.get_node("CheatSheetLabel").modulate.a = 1.0
	$UI.get_node("CheatSheetLabel2").modulate.a += uiFadeSpeed
	if $UI.get_node("CheatSheetLabel2").modulate.a > 1.0:
		$UI.get_node("CheatSheetLabel2").modulate.a = 1.0
	$UI.get_node("InstructionLabel").modulate.a += uiFadeSpeed
	if $UI.get_node("InstructionLabel").modulate.a > 1.0:
		$UI.get_node("InstructionLabel").modulate.a = 1.0

	# Update lobby UI labels
	var timeLeft = $Timers.get_node("LobbyTimer").time_left
	var timerColor = "#9EE09E"
	if timeLeft < 11:  timerColor = "#FF6663"
	elif timeLeft < 31: timerColor = "#FDFD97"
	$UI.get_node("TimerLabel").text = " [color=" + timerColor + "]" + str(int(timeLeft)) + "[/color] [color=dark_gray]seconds until battle[/color]"
	if get_parent().pawnList.size() > 0:
		$UI.get_node("JoinerCount").text = "\n " + str(int(get_parent().pawnList.size())) + " [color=dark_gray]players have joined[/color]"
		#if get_parent().teamsEnabled:
			#$UI.get_node("JoinerCount").text += "/" + str(get_parent().maxPlayers)

	# When lobby fills up
	#if get_parent().teamsEnabled:
		#if get_parent().pawnList.size() >= get_parent().maxPlayers:
			#proceed_to_arena()

# Progress to next scene
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Skip Lobby"):
		proceed_to_arena()
func _on_lobby_timer_timeout() -> void:
	proceed_to_arena()

# Finish lobby, assign teams
func proceed_to_arena() -> void:
	var pawns = get_parent().pawnList
	#if get_parent().teamsEnabled && pawns.size() % 2 != 0:
		#register_pawn("Phil", choose_random_pawn(), choose_random_style(), choose_random_item())
	pawns.shuffle()
	#if get_parent().teamsEnabled:
		#for i in pawns.size():
			#if i % 2 == 0: pawns[i].team = "blue"
			#else: pawns[i].team = "gold"
	get_parent().switch_board("arena")

# Scrape Twitch chat & look for joiners
func print_chatter_message(chatter: VSTChatter):
	var username = chatter.tags.display_name
	var message = chatter.message.to_lower()
	if "!join" not in message && "!play" not in message:
		return
	for pawn in get_parent().pawnList:
		if pawn.username == username:
			print(username + " is already registered")
			return
	var newPawn = register_pawn(str(username), get_pawn_type(message), get_pawn_style(message), get_pawn_item(message))#, get_pawn_costume(message))
	spawn_pawn(newPawn, true)
	update_joined_pawn_label(newPawn)
func update_joined_pawn_label(newPawn) -> void:
	var logMsg = "[color=#FDFD97]" + newPawn.username + "[/color] — [color=#FF6663]" + newPawn.type + "[/color] — [color=#CC99C9]" + newPawn.style + "[/color] — [color=#9EC1CF]" + newPawn.item + "[/color]" #+ "(" + str(get_parent().get_xp(newPawn.username, newPawn.type)) + ")" 
	print(logMsg)
	lobbyJoiners.push_front(logMsg)
	$UI.get_node("JoinLogRichLabel").text = ""
	var maxJoinersToDisplay = 33
	var i = 0
	for joiner in lobbyJoiners:
		$UI.get_node("JoinLogRichLabel").text += "\n" + joiner
		i += 1
		if i > maxJoinersToDisplay: break

func _on_title_color_timer_timeout() -> void:
	# Title text effect
	var titleChars = ["c", "h", "l", "o", "r", "o", "b", "a", "t", "t", "l", "e"]
	var titleColors = ["#FF6663", "#FEB144", "#FDFD97", "#9EE09E", "#9EC1CF", "#CC99C9", "#FF6663", "#FEB144", "#FDFD97", "#9EE09E", "#9EC1CF", "#CC99C9"]

	var titleString = ""
	for i in titleChars.size():
		if i == titleStringChar:
			titleString += "[color=white]" + titleChars[i] + "[/color]"
		else:
			titleString += "[color=" + titleColors[i] + "]" + titleChars[i] + "[/color]"
			
	$UI.get_node("TitleLabel").text = "~ " + titleString + " ~"
	titleStringChar += 1
	if titleStringChar > titleChars.size():
		titleStringChar = 0
		$UI.get_node("TitleColorTimer").start(titleStringFlashReset)
	else:
		$UI.get_node("TitleColorTimer").start(titleStringFlashSpeed)
		
