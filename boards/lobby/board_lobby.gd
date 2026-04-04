extends Node2D
var currentPlayers = []
var boardRadius = 240

# Intiate twitch functions
func _ready() -> void:
	#VerySimpleTwitch.get_token_and_login_chat()
	#VerySimpleTwitch.chat_message_received.connect(print_chatter_message)
	print("Scraping Twitch chat")
	
	# random test bots
	for i in 8:
		register_pawn("Bot " + str(i+1), choose_random_pawn(), choose_random_style(), choose_random_item())

	# specific test bots
	#register_pawn("fibbo", "chair", "nimble", "dice")
	#register_pawn("faoble", "pirate", "giant", "milkshake")

# Display lobby labels
func _process(_delta: float) -> void:
	$BoardSprite1.rotation += 0.00025
	$BoardSprite2.rotation -= 0.00025
	get_node("TimerLabel").text = "Starting in " + str(int($LobbyTimer.time_left)) + " "
	#var displayString = "========== C H L O R O B A T T L E =========="
	#displayString += "\n\nType !join <pawn> <style> <item> in Twitch Chat to play!"
	#displayString += "\n\nPawns — chair, grouper, pirate, ship, slug, top"
	#displayString += "\nStyles — berserk, giant, insane, nimble, sturdy"
	#displayString += "\nItems — antimatter, dice, killbot, milkshake, skates"
	#displayString += "\n\nContestants: "
	#for i in get_parent().pawnList:
		#displayString += i.username + ", "
	#$PlayersLabel.text = displayString.substr(0, displayString.length() - 2)

func _on_lobby_timer_timeout() -> void:
	get_parent().switch_board("early")

# Process Twitch Chat join requests
func print_chatter_message(chatter: VSTChatter):
	var username = chatter.tags.display_name
	var message = chatter.message.to_lower()
	if "!join" not in message:
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
	spawn_pawn(newPawn)
	print(newPawn.username + " joined as " + newPawn.type + " (" + newPawn.style + ") [" + newPawn.item + "]")

func get_pawn_type(message: String):
	if "chair" in message: return("chair")
	elif "grouper" in message: return("grouper")
	elif "pirate" in message: return("pirate")
	elif "ship" in message: return("ship")
	elif "slug" in message: return("slug")
	elif "top" in message: return("top")
	else: return(choose_random_pawn())

func get_pawn_style(message: String):
	if "berserk" in message: return("berserk")
	elif "giant" in message: return("giant")
	elif "insane" in message: return("insane")
	elif "nimble" in message: return("nimble")
	elif "sturdy" in message: return("sturdy")
	else: return(choose_random_style())

func get_pawn_item(message: String):
	if "antimatter" in message: return("antimatter")
	elif "dice" in message: return("dice")
	elif "killbot" in message: return("killbot")
	elif "milkshake" in message: return("milkshake")
	elif "skates" in message: return("skates")
	else: return(choose_random_item())
	
func choose_random_pawn() -> String:
	var allPawnTypes = ["chair", "grouper", "pirate", "ship", "slug", "top"]
	var i = randi_range(0, allPawnTypes.size() - 1)
	return(allPawnTypes[i])
	
func choose_random_style() -> String:
	var allStyleTypes = ["berserk", "giant", "insane", "nimble", "sturdy"]
	var i = randi_range(0, allStyleTypes.size() - 1)
	return(allStyleTypes[i])
	
func choose_random_item() -> String:
	var allItemTypes = ["antimatter", "dice", "killbot", "milkshake", "skates"]
	var i = randi_range(0, allItemTypes.size() - 1)
	return(allItemTypes[i])

func spawn_pawn(pawn) -> void:
	var pawnType
	if pawn.type == "chair": pawnType = get_parent().chair
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
	print("Spawned " + newPawn.type + " (" + newPawn.style + ") [" + newPawn.item + "] for " + newPawn.username)
