extends Node2D
var currentPlayers = []
var boardRadius = 360
var lobbyTimer = 60.0

func _ready() -> void:

	# Play chime
	$ChimeSound.panning_strength = 0.0
	$ChimeSound.play()

	# LET TWITCH COOK
	#VerySimpleTwitch.get_token_and_login_chat()
	#VerySimpleTwitch.chat_message_received.connect(print_chatter_message)

	# Create random bots to test with
	for i in 2:
		register_pawn("Bot " + str(i+1), "flicker", choose_random_style(), "flask")
		#register_pawn("Bot " + str(i+1), choose_random_pawn(), choose_random_style(), choose_random_item())

	# Create specific test bots
	#  register_pawn("chloroken", "flicker", "berserk", "skates")
	#register_pawn("ceph", choose_random_pawn(), choose_random_style(), choose_random_item())
	#register_pawn("misashi", choose_random_pawn(), choose_random_style(), choose_random_item())
	#register_pawn("chlebastian", "pirate", "bully", "antimatter")
	#register_pawn("gabe", "top", "bully", "antimatter")
	#register_pawn("inverse", "cyclone", "berserk", "tire")
	#register_pawn("zeno", "mummy", "mighty", "tire")
	#register_pawn("gravy", choose_random_pawn(), choose_random_style(), choose_random_item())
	#register_pawn("del", "slug", "slayer", "killbot")

	# Start lobby timer
	$LobbyTimer.one_shot = true
	$LobbyTimer.set_wait_time(lobbyTimer)
	$LobbyTimer.start()

# Update lobby countdown timer
func _process(_delta: float) -> void:
	$TimerLabel.text = str(int($LobbyTimer.time_left))

# Transition to next board
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
	elif "flicker" in message: return("flicker")
	elif "grouper" in message: return("grouper")
	elif "mummy" in message: return("mummy")
	elif "pirate" in message: return("pirate")
	elif "ship" in message: return("ship")
	elif "slug" in message: return("slug")
	elif "top" in message: return("top")
	else: return(choose_random_pawn())
func choose_random_pawn() -> String:
	var allPawnTypes = ["candle", "chair", "cyclone", "flicker", "grouper", "mummy", "pirate", "ship", "slug", "top"]
	var i = randi_range(0, allPawnTypes.size() - 1)
	return(allPawnTypes[i])

func get_pawn_style(message: String):
	if "berserk" in message: return("berserk")
	elif "berserker" in message: return("berserk") # alias
	elif "bully" in message: return("bully")
	elif "mighty" in message: return("mighty")
	elif "slayer" in message: return("slayer")
	else: return(choose_random_style())
func choose_random_style() -> String:
	var allStyleTypes = ["berserk", "bully", "mighty", "slayer"]
	var i = randi_range(0, allStyleTypes.size() - 1)
	return(allStyleTypes[i])

func get_pawn_item(message: String):
	if "antimatter" in message: return("antimatter")
	elif "dice" in message: return("dice")
	elif "flask" in message: return("flask")
	elif "glue" in message: return("glue")
	elif "killbot" in message: return("killbot")
	elif "map" in message: return("map")
	#elif "milkshake" in message: return("milkshake")
	elif "skates" in message: return("skates")
	elif "tire" in message: return("tire")
	elif "tyre" in message: return("tire")
	else: return(choose_random_item())
func choose_random_item() -> String:
	var allItemTypes = ["antimatter", "dice", "flask", "glue", "killbot", "map", "skates", "tire"]
	var i = randi_range(0, allItemTypes.size() - 1)
	return(allItemTypes[i])

# Spawn disarmed Pawns in lobby while players wait
func spawn_lobby_pawn(pawn) -> void:
	var pawnType
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
	var newPawn = pawnType.instantiate()
	var center = get_viewport_rect().size / 2.0
	var pawnOffset = Vector2(randf_range(-10, 10), randf_range(-10, 10))
	newPawn.position = center + pawnOffset
	newPawn.username = pawn.username # str(randf()) # 
	newPawn.type = pawn.type
	newPawn.attacksDisabled = true
	add_child(newPawn)
