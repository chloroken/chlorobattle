extends Node2D

var basePawn

# Disable most of GUI in Lobby (for show purposes)
func _ready() -> void:
	basePawn = get_parent()
	if basePawn.attacksDisabled:
		$HitpointLabel.visible = false
		$HitpointLabelBlack.visible = false
		$HitpointLabelRed.visible = false
		$HitpointLabelGreen.visible = false

# Update Pawn name & hp bar
func _process(_delta: float) -> void:
	
	var main = get_parent().get_parent().get_parent()
	var nameColor = Color.BURLYWOOD
	if main.teamsEnabled:
		if basePawn.team == "blue": nameColor = Color.DEEP_SKY_BLUE
		elif basePawn.team == "gold": nameColor = Color.DARK_GOLDENROD
	else:
		var xp = main.get_xp(basePawn.username, basePawn.type)
		if xp >= 100: nameColor = Color.GOLD
		elif xp >= 25: nameColor = Color.LIGHT_GRAY
		elif xp >= 9: nameColor = Color.SADDLE_BROWN
	$NameLabel.set("theme_override_colors/font_color", nameColor)
	
	$NameLabel.text = basePawn.username.substr(0, basePawn.nameCharLimit)
	$HitpointLabel.text = str(int(ceil(basePawn.hp)))
	
	$HitpointLabelGreen.scale.x = basePawn.hp / basePawn.baseHp
	if basePawn.team == "blue": $HitpointLabelGreen.color = Color.DEEP_SKY_BLUE
	elif basePawn.team == "gold": $HitpointLabelGreen.color = Color.DARK_GOLDENROD
