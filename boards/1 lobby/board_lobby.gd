extends Node2D
var currentPlayers = []
var boardRadius = 360
var lobbyTimer = 60.0

func _ready() -> void:
	# Intiate twitch functionality
	#VerySimpleTwitch.get_token_and_login_chat()
	#VerySimpleTwitch.chat_message_received.connect(print_chatter_message)
	
	# Create random bots to test with
	for i in 24:
		register_pawn("Bot " + str(i+1), choose_random_pawn(), choose_random_style(), choose_random_item())

	# Create specific test bots
	register_pawn("chloro", "top", "berserk", "skates")
	#register_pawn("jonny", "cyclone", "mighty", "dice")
	#register_pawn("parody", "grouper", choose_random_style(), choose_random_item())
	#register_pawn("dank_gr4vy", "pirate", choose_random_style(), choose_random_item())
	#register_pawn("b4ngbiscuit", "ship", choose_random_style(), choose_random_item())
	#register_pawn("theone_fg", "slug", choose_random_style(), choose_random_item())
	#register_pawn("hasine", "top", choose_random_style(), choose_random_item())
	
	# Start lobby timer
	$LobbyTimer.one_shot = true
	$LobbyTimer.set_wait_time(lobbyTimer)
	$LobbyTimer.start()

# Update lobby countdown timer
func _process(_delta: float) -> void:
	$TimerLabel.text = str(int($LobbyTimer.time_left))

func _on_lobby_timer_timeout() -> void:
	get_parent().pawnList.shuffle()
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
	register_pawn(str(username), get_pawn_type(message), get_pawn_style(message), get_pawn_item(message))

func register_pawn(username: String, type: String, style = "random", item = "random"):
	var newPawn = get_parent().Pawn.new()
	newPawn.username = username
	newPawn.type = type
	newPawn.style = style
	newPawn.item = item
	get_parent().pawnList.append(newPawn)
	spawn_lobby_pawn(newPawn)
	print(newPawn.username + " joined as " + newPawn.type + " (" + newPawn.style + ") [" + newPawn.item + "]")

func get_pawn_type(message: String):
	if "candle" in message: return("candle")
	elif "chair" in message: return("chair")
	elif "cyclone" in message: return("cyclone")
	elif "grouper" in message: return("grouper")
	elif "pirate" in message: return("pirate")
	elif "ship" in message: return("ship")
	elif "slug" in message: return("slug")
	elif "top" in message: return("top")
	else: return(choose_random_pawn())

func get_pawn_style(message: String):
	if "berserk" in message: return("berserk")
	elif "mighty" in message: return("mighty")
	elif "slayer" in message: return("slayer")
	else: return(choose_random_style())

func get_pawn_item(message: String):
	if "antimatter" in message: return("antimatter")
	elif "dice" in message: return("dice")
	elif "glue" in message: return("glue")
	elif "killbot" in message: return("killbot")
	elif "map" in message: return("map")
	elif "milkshake" in message: return("milkshake")
	elif "skates" in message: return("skates")
	else: return(choose_random_item())

func choose_random_pawn() -> String:
	var allPawnTypes = ["candle", "chair", "cyclone", "grouper", "pirate", "ship", "slug", "top"]
	var i = randi_range(0, allPawnTypes.size() - 1)
	return(allPawnTypes[i])

func choose_random_style() -> String:
	var allStyleTypes = ["berserk", "mighty", "slayer"]
	var i = randi_range(0, allStyleTypes.size() - 1)
	return(allStyleTypes[i])

func choose_random_item() -> String:
	var allItemTypes = ["antimatter", "dice", "glue", "killbot", "map", "milkshake", "skates"]
	var i = randi_range(0, allItemTypes.size() - 1)
	return(allItemTypes[i])

# Spawn disarmed Pawns in lobby while players wait
func spawn_lobby_pawn(pawn) -> void:
	var pawnType
	if pawn.type == "candle": pawnType = get_parent().candle
	elif pawn.type == "chair": pawnType = get_parent().chair
	elif pawn.type == "cyclone": pawnType = get_parent().cyclone
	elif pawn.type == "grouper": pawnType = get_parent().grouper
	elif pawn.type == "pirate": pawnType = get_parent().pirate
	elif pawn.type == "ship": pawnType = get_parent().ship
	elif pawn.type == "slug": pawnType = get_parent().slug
	elif pawn.type == "top": pawnType = get_parent().top
	var newPawn = pawnType.instantiate()
	var center = get_viewport_rect().size / 2.0
	newPawn.position = center
	newPawn.username = pawn.username # str(randf()) # 
	newPawn.type = pawn.type
	newPawn.attacksDisabled = true
	add_child(newPawn)
