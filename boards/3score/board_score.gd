extends "res://boards/_base/board_base.gd"

var maxPawnScores = 16

func _ready() -> void:
	super()

	# Change "scoreboard" to "top 16" for large audiences
	var pawnCount = get_parent().scoreList.size()
	if pawnCount < 16:
		$UI.get_node("TitleLabel").text = "~ scoreboard ~"

	# Fix camera zoom
	get_parent().get_node("cam").zoom.x = 1
	get_parent().get_node("cam").zoom.y = 1

	# Spawn disarmed winning Pawn to show off
	for pawn in get_parent().pawnList:
		spawn_pawn(pawn, true)

	if get_parent().repeatPlay:
		$AutoplayTimer.start(get_parent().repeatTime)

	# Calculate scores for scoreboard
	call_pawn_scores()

# Send data to Score Container to display labels in columns
func call_pawn_scores() -> void:
	var i = 1
	for pawn in get_parent().scoreList:
		if !get_parent().testingMode:
			var xpToAdd = 1
			if i == 1: xpToAdd += int(floor(sqrt(get_parent().scoreList.size())))
			get_parent().add_xp(pawn.username, pawn.type, xpToAdd)
		
		$UI.get_node("ScoreContainer/PlacementLabel").text += str(i) + "\n"
		#$UI.get_node("ScoreContainer/UsernameLabel").text += str(pawn.username) + "\n"
		if pawn.team == "blue": $UI.get_node("ScoreContainer/UsernameLabel").push_color(Color.DEEP_SKY_BLUE)
		elif pawn.team == "gold": $UI.get_node("ScoreContainer/UsernameLabel").push_color(Color.DARK_GOLDENROD)
		else: $UI.get_node("ScoreContainer/UsernameLabel").push_color(Color("white"))
		$UI.get_node("ScoreContainer/UsernameLabel").add_text(str(pawn.username + "\n"))
		$UI.get_node("ScoreContainer/UsernameLabel").pop()
		$UI.get_node("ScoreContainer/LevelLabel").text += str(int(floor(sqrt(get_parent().get_xp(pawn.username, pawn.type))))) + "\n"
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

func _on_autoplay_timer_timeout() -> void:
	get_tree().reload_current_scene()
