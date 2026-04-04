extends Node2D
var pawnType
var boardRadius = 300

func _ready() -> void:
	# Spawn disarmed winning Pawn to show off
	for pawn in get_parent().pawnList:
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
		add_child(newPawn)
	
	# Calculate scores for scoreboard
	call_pawn_scores()

# Concatenate scoreboard string
func call_pawn_scores() -> void:#String:
	#var place
	#var user
	#var type
	#var style
	#var item
	#var kills
	#var dmgDealt
	#var dmgTaken
	#var dmgRatio 
	var i = 1
	#var outputString = ""
	for pawn in get_parent().scoreList:
		get_node("ScoreContainer/PlacementLabel").text += str(i) + "\n"
		get_node("ScoreContainer/UsernameLabel").text += str(pawn.username) + "\n"
		get_node("ScoreContainer/PawnLabel").text += str(pawn.type) + "\n"
		get_node("ScoreContainer/StyleLabel").text += str(pawn.style) + "\n"
		get_node("ScoreContainer/ItemLabel").text += str(pawn.item) + "\n"
		get_node("ScoreContainer/KillsLabel").text += str(pawn.killCount) + "\n"
		get_node("ScoreContainer/DealtLabel").text += str(int(pawn.damageDealt)) + "\n"
		get_node("ScoreContainer/TakenLabel").text += str(int(pawn.damageTaken)) + "\n"
		get_node("ScoreContainer/RatioLabel").text += "%0.2f" % float(pawn.damageDealt/pawn.damageTaken) + "\n"
		#place = "#" + str(i) + " "
		#user = str(pawn.username) + " — "
		#type = str(pawn.type) + " ("
		#style = str(pawn.style) + ") ["
		#item = str(pawn.item) + "] — "
		#kills = str(pawn.killCount) + " kills, "
		#dmgDealt = str(int(pawn.damageDealt)) + " dealt, "
		#dmgTaken = str(int(pawn.damageTaken)) + " taken — "
		#dmgRatio = "(" + "%0.2f" % float(pawn.damageDealt/pawn.damageTaken) + " ratio)"
		i += 1
		#outputString += place + user + type + style + item + kills + dmgDealt + dmgTaken + dmgRatio + "\n"
	#return(outputString)
