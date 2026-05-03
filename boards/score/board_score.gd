extends "res://boards/base/board_base.gd"

var pawnType
var maxPawnScores = 16

func _ready() -> void:
	super()

	var pawnCount = get_parent().pawnList.size()
	if pawnCount < 16:
		$UI.get_node("TitleLabel").text = "~ scoreboard ~"

	# Fix camera zoom
	get_parent().get_node("cam").zoom.x = 1
	get_parent().get_node("cam").zoom.y = 1

	# Spawn disarmed winning Pawn to show off
	for pawn in get_parent().pawnList:
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
		var newPawn = pawnType.instantiate()
		var pawnOffset = Vector2(randf_range(-10, 10), randf_range(-10, 10))
		newPawn.position = center + pawnOffset
		newPawn.name = pawn.username
		newPawn.username = pawn.username # str(randf()) # 
		newPawn.type = pawn.type
		add_child(newPawn)

	# Calculate scores for scoreboard
	call_pawn_scores()

# Send data to Score Container to display labels in columns
func call_pawn_scores() -> void:
	var i = 1
	for pawn in get_parent().scoreList:
		$UI.get_node("ScoreContainer/PlacementLabel").text += str(i) + "\n"
		$UI.get_node("ScoreContainer/UsernameLabel").text += str(pawn.username) + "\n"
		$UI.get_node("ScoreContainer/PawnLabel").text += str(pawn.type) + "\n"
		$UI.get_node("ScoreContainer/StyleLabel").text += str(pawn.style) + "\n"
		$UI.get_node("ScoreContainer/ItemLabel").text += str(pawn.item) + "\n"
		$UI.get_node("ScoreContainer/KillsLabel").text += str(pawn.killCount) + "\n"
		$UI.get_node("ScoreContainer/DealtLabel").text += str(int(pawn.damageDealt)) + "\n"
		$UI.get_node("ScoreContainer/HealedLabel").text += str(int(pawn.damageHealed)) + "\n"
		$UI.get_node("ScoreContainer/TakenLabel").text += str(int(pawn.damageTaken)) + "\n"
		#var dmgRatio = float(pawn.damageDealt/max(0, pawn.damageTaken-pawn.damageHealed))
		#get_node("ScoreContainer/RatioLabel").text += str("%0.1f" % dmgRatio) + "\n"
		i += 1
		if i > maxPawnScores: break
