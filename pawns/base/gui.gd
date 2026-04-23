extends Node2D

var basePawn

func _ready() -> void:
	
	basePawn = get_parent()
	
	# Disable attacks in Lobby for show purposes
	if basePawn.attacksDisabled:
		$HitpointLabel.visible = false
		$HitpointLabelBlack.visible = false
		$HitpointLabelRed.visible = false
		$HitpointLabelGreen.visible = false

func _process(_delta: float) -> void:
	
	# Update Pawn name
	$NameLabel.text = basePawn.username.substr(0, basePawn.nameCharLimit)

	# Update Pawn hp bar
	$HitpointLabel.text = str(int(ceil(basePawn.hp)))
	$HitpointLabelGreen.scale.x = basePawn.hp / basePawn.baseHp
