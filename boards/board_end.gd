extends Node2D
var pawnType
var boardRadius = 180

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#var labelText = "Winner: " + get_parent().pawnList[0].username
	#labelText += " — " + get_parent().pawnList[0].type
	#labelText += " (" + get_parent().pawnList[0].style + ")"
	#labelText += " [" + get_parent().pawnList[0].item + "]"
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
	$WinnerLabel.text = call_pawn_scores()

func call_pawn_scores() -> String:
	var place
	var user
	var type
	var style
	var item
	var kills
	var dmgDealt
	var dmgTaken
	var dmgRatio 
	var i = 1
	var outputString = "Scoreboard:\n"
	for pawn in get_parent().scoreList:
		place = "[" + str(i) + "] "
		user = str(pawn.username) + " — "
		type = str(pawn.type) + " ("
		style = str(pawn.style) + ") ["
		item = str(pawn.item) + "] — "
		kills = str(pawn.killCount) + " kills, "
		dmgDealt = str(int(pawn.damageDealt)) + " dealt, "
		dmgTaken = str(int(pawn.damageTaken)) + " taken — "
		dmgRatio = "(" + "%0.2f" % float(pawn.damageDealt/pawn.damageTaken) + " ratio)"
		i += 1
		outputString += place + user + type + style + item + kills + dmgDealt + dmgTaken + dmgRatio + "\n"
	return(outputString)
