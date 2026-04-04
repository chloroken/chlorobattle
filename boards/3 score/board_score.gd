extends Node2D
var pawnType
var boardRadius = 300

func _ready() -> void:
	# Spawn disarmed winning Pawn to show off
	for pawn in get_parent().pawnList:
		if pawn.type == "candle": pawnType = get_parent().candle
		elif pawn.type == "chair": pawnType = get_parent().chair
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

# Send data to Score Container to display labels in columns
func call_pawn_scores() -> void:
	var i = 1
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
		i += 1
