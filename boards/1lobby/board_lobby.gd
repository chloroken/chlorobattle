extends "res://boards/_base/board_base.gd"

var lobbyTimer = 60.0
var lobbyJoiners = []

func _ready() -> void:
	super()

	# LET TWITCH COOK
	VerySimpleTwitch.get_token_and_login_chat()
	VerySimpleTwitch.chat_message_received.connect(print_chatter_message)
	#register_pawn("YouTube", choose_random_pawn(), choose_random_style(), choose_random_item())

	# Create bot Pawns to test with
	#for i in 8:
		#register_pawn("Bot " + str(i+1), "fish", choose_random_style(), choose_random_item(), 0)
	# Create specific test bots

	# 1v1s
	#register_pawn("chloroken", "mummy", "mighty", "smoke", 0)
	#register_pawn("The_logs", "pirate", "mighty", "flask", 0)

	# Spawn Pawns made above
	for pawn in get_parent().pawnList:
		spawn_pawn(pawn, true)
		update_joined_pawn_label(pawn)

	# Start lobby timer
	$Timers.get_node("LobbyTimer").set_wait_time(lobbyTimer)
	$Timers.get_node("LobbyTimer").start()

func _process(_delta: float) -> void:

	# Update lobby UI labels
	$UI.get_node("TimerLabel").text = str(int($Timers.get_node("LobbyTimer").time_left)) + " "
	if get_parent().pawnList.size() > 0:
		$UI.get_node("JoinerCount").text = " " + str(int(get_parent().pawnList.size()))
		if get_parent().teamsEnabled:
			$UI.get_node("JoinerCount").text += "/" + str(get_parent().maxPlayers)

	# When lobby fills up
	if get_parent().teamsEnabled:
		if get_parent().pawnList.size() >= get_parent().maxPlayers:
			proceed_to_arena()

# When lobby times out
func _on_lobby_timer_timeout() -> void:
	proceed_to_arena()

# Finish lobby, assign teams
func proceed_to_arena() -> void:
	var pawns = get_parent().pawnList
	if get_parent().teamsEnabled && pawns.size() % 2 != 0:
		register_pawn("Phil", choose_random_pawn(), choose_random_style(), choose_random_item())
	pawns.shuffle()
	if get_parent().teamsEnabled:
		for i in pawns.size():
			if i % 2 == 0: pawns[i].team = "blue"
			else: pawns[i].team = "gold"
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
	var newPawn = register_pawn(str(username), get_pawn_type(message), get_pawn_style(message), get_pawn_item(message), get_pawn_costume(message))
	spawn_pawn(newPawn, true)
	update_joined_pawn_label(newPawn)
func update_joined_pawn_label(newPawn) -> void:
	var logMsg = newPawn.username + " — " + newPawn.type + "(" + str(get_parent().get_xp(newPawn.username, newPawn.type)) + ")" + " — " + newPawn.style + " — " + newPawn.item
	print(logMsg)
	lobbyJoiners.push_front(logMsg)
	$UI.get_node("JoinLogLabel").text = ""
	var maxJoinersToDisplay = 33
	var i = 0
	for joiner in lobbyJoiners:
		$UI.get_node("JoinLogLabel").text += "\n" + joiner
		i += 1
		if i > maxJoinersToDisplay: break
