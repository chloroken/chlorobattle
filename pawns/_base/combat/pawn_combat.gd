extends Node2D
@export var tombstone: PackedScene
var basePawn
func _ready() -> void:
	basePawn = get_parent()

##################
# DAMAGE SOURCES #
##################
func _on_base_pawn_area_entered(attack: Area2D) -> void:
	attack_hit(attack)
	item_hit(attack)
func _on_bully_area_area_entered(victim: Area2D) -> void:
	style_touch(victim)
func status_damage(statusType) -> void:
	match statusType:
		"Bleed": $Status.bleed_damage()
		"Sick": $Status.sick_damage()

##################
# HIT VALIDATION #
##################

func attack_hit(attack) -> void:
	if !basePawn.get_node("Status/VoidStatusTimer").is_stopped():
		basePawn.voidHitList.append(attack)
		return
	if !attack.get_collision_layer_value(2): return
	if basePawn.hitList.has(attack): return
	var attacker = attack.get_parent().get_parent()
	if attacker.username == basePawn.username: return
	var mainBoard = get_parent().get_parent().get_parent()
	if mainBoard.teamsEnabled && basePawn.team == attacker.team: return
	$Pawn.combat_pawn(attack)
func item_hit(attack) -> void:
	if !basePawn.get_node("Status/VoidStatusTimer").is_stopped():
		basePawn.voidHitList.append(attack)
		return
	if !attack.get_collision_layer_value(3): return
	if basePawn.hitList.has(attack): return
	var attacker = attack.get_parent().get_parent()
	if attacker.username == basePawn.username: return
	var mainBoard = get_parent().get_parent().get_parent()
	if mainBoard.teamsEnabled && basePawn.team == attacker.team: return
	$Item.combat_item(attack, basePawn)
func style_touch(victim) -> void:
	if basePawn.attacksDisabled: return
	if basePawn.style != "bully": return
	if !victim.get_node("Status").get_node("VoidStatusTimer").is_stopped(): return
	if !victim.get_collision_layer_value(1): return
	if victim.username == basePawn.username: return
	var mainBoard = get_parent().get_parent().get_parent()
	if mainBoard.teamsEnabled && basePawn.team == victim.team: return
	$Style.bully_touch(victim)

#######################
# CLEAN UP PROCEDURES #
#######################

func clean_up_attack(attack) -> void:
	if !basePawn.get_node("Status/VoidStatusTimer").is_stopped(): return
	if !attack.areaAttack: attack.queue_free()
	else: basePawn.hitList.append(attack)
func clean_up_pawn(attacker) -> void:
	var pawns = basePawn.get_parent().get_parent().pawnList
	if basePawn.hp <= 0:
		basePawn.get_parent().get_node("DeathSound").play()# tie to board
		if attacker == null:
			pawn_death_no_source(basePawn)
			return
		for i in range(0, pawns.size()):
			if pawns[i].username == basePawn.username:
				attacker.killCount += 1
				if attacker.style == "slayer":
					attacker.get_node("Styles").add_slayer_charge()
				pawn_death(basePawn, attacker, attacker.username, i)
				break
func pawn_death(pawn, attackingPawn, killer: String, pawnIndex: int) -> void:
	var board = get_parent().get_parent()
	var mainBoard = board.get_parent()
	make_tombstone(pawn)
	update_scoreboard(board, pawn)
	mainBoard.pawnList.remove_at(pawnIndex)
	board.kill_feed("[" + str(killer) + "] eliminated [" + str(pawn.username) + "]")
	board.activePawns.erase(pawn)
	pawn.queue_free()
	
	# If this is the last pawn, end game
	if mainBoard.testingMode: return
	if mainBoard.pawnList.size() <= 1:
		update_scoreboard(board, attackingPawn)
		mainBoard.switch_board("score")
	# Or if teams are enabled, and only one is left, end game
	elif mainBoard.teamsEnabled:
		var oneTeamLeft = true
		var pawnTeam = mainBoard.pawnList[0].team
		for p in mainBoard.pawnList:
			if pawnTeam != p.team:
				oneTeamLeft = false
				break
		if oneTeamLeft:
			for p in board.activePawns:
				update_scoreboard(board, p)
			mainBoard.switch_board("score")
func pawn_death_no_source(pawn) -> void:
	var board = get_parent().get_parent()
	var mainBoard = board.get_parent()
	var pawns = basePawn.get_parent().get_parent().pawnList
	make_tombstone(pawn)
	update_scoreboard(board, pawn)
	var pawnIndex = 0
	for i in range(0, pawns.size()):
		if pawns[i].username == pawn.username:
			pawnIndex = i
	mainBoard.pawnList.remove_at(pawnIndex)
	board.kill_feed("[" + str(pawn.username) + "] was eliminated")
	board.activePawns.erase(pawn)
	pawn.queue_free()

	# If this is the last pawn, end game
	if mainBoard.testingMode: return
	if mainBoard.pawnList.size() <= 1:
		mainBoard.switch_board("score")
	# Or if teams are enabled, and only one is left, end game
	elif mainBoard.teamsEnabled:
		var oneTeamLeft = true
		var pawnTeam = mainBoard.pawnList[0].team
		for p in mainBoard.pawnList:
			if pawnTeam != p.team:
				oneTeamLeft = false
				break
		if oneTeamLeft:
			for p in board.activePawns:
				update_scoreboard(board, p)
			mainBoard.switch_board("score")
	
func make_tombstone(pawn) -> void:
	var newTombstone = tombstone.instantiate()
	newTombstone.global_position = global_position
	newTombstone.name = "Tombstone (" + pawn.username + ")"
	newTombstone.username = pawn.username
	var theBoard = get_parent().get_parent()
	theBoard.add_child(newTombstone)
func update_scoreboard(board, pawn) -> void:
	var newScore = board.Pawn.new()
	newScore.username = pawn.username
	newScore.type = pawn.type
	newScore.style = pawn.style
	newScore.item = pawn.item
	newScore.team = pawn.team
	newScore.damageTaken = pawn.damageTaken
	newScore.damageDealt = pawn.damageDealt
	newScore.damageHealed = pawn.damageHealed
	newScore.killCount = pawn.killCount
	board.get_parent().scoreList.push_front(newScore)
