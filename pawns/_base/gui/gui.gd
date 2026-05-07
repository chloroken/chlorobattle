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
	$NameLabel.text = basePawn.username.substr(0, basePawn.nameCharLimit)
	$HitpointLabel.text = str(int(ceil(basePawn.hp)))
	$HitpointLabelGreen.scale.x = basePawn.hp / basePawn.baseHp
	var pawnTeam = get_parent().team
	if pawnTeam == "blue": $HitpointLabelGreen.color = Color.DEEP_SKY_BLUE
	elif pawnTeam == "gold": $HitpointLabelGreen.color = Color.DARK_GOLDENROD
