extends Node

@export var tombstone: PackedScene
var basePawn

func _ready() -> void:
	basePawn = get_parent().get_parent()

func add_attack_to_hitlist(attack) -> void:
	if attack.areaAttack:
		basePawn.hitList.append(attack)

func clean_up_attack(attack) -> void:
	if !basePawn.get_node("Status/VoidStatusTimer").is_stopped():
		return
	if !attack.areaAttack:
		attack.queue_free()

func clean_up_pawn(attacker) -> void:
	var pawns = basePawn.get_parent().get_parent().pawnList
	if basePawn.hp <= 0:
		if check_for_revives():
			return
		play_pawn_death_sound()
		if attacker == null:
			pawn_death_no_source(basePawn)
			return
		give_kill_credit(pawns, attacker)
		attacker.get_node("Items").try_scythe()

func play_pawn_death_sound() -> void:
	basePawn.get_parent().get_node("DeathSound").play()

func give_kill_credit(pawns, attacker) -> void:
	for i in range(0, pawns.size()):
		if pawns[i].username == basePawn.username:
			attacker.killCount += 1
			if attacker.style == "snowball":
				attacker.get_node("Styles").add_snowball_charge()
			pawn_death(basePawn, attacker, attacker.username, i)
			break

func check_for_revives() -> bool:
	if basePawn.type == "slug":
		if basePawn.try_revive():
			return(true)
	return(false)

func pawn_death(pawn, attackingPawn, killer: String, pawnIndex: int) -> void:
	var board = get_parent().get_parent().get_parent()
	var main = board.get_parent()
	make_tombstone(pawn)
	update_scoreboard(board, pawn)
	main.pawnList.remove_at(pawnIndex)
	board.kill_feed("[[color=#FDFD97]" + str(killer) + "[/color]] ☠ [[color=#FEB144]" + str(pawn.username) + "[/color]]")
	board.activePawns.erase(pawn)
	pawn.queue_free()

	# If this is the last pawn, end game
	if main.testingMode: return
	if main.pawnList.size() <= 1:
		update_scoreboard(board, attackingPawn)
		for event in board.combatLogText:
			main.finalEvents.append(event)
		main.switch_board("score")

func pawn_death_no_source(pawn) -> void:
	var board = get_parent().get_parent()
	var main = board.get_parent()
	var pawns = basePawn.get_parent().get_parent().pawnList
	make_tombstone(pawn)
	update_scoreboard(board, pawn)
	var pawnIndex = 0
	for i in range(0, pawns.size()):
		if pawns[i].username == pawn.username:
			pawnIndex = i
	main.pawnList.remove_at(pawnIndex)
	board.kill_feed("[[color=#FEB144]" + str(pawn.username) + "[/color]] was eliminated")
	board.activePawns.erase(pawn)
	pawn.queue_free()

	# If this is the last pawn, end game
	if main.testingMode: return
	if main.pawnList.size() <= 1:
		main.switch_board("score")

func make_tombstone(pawn) -> void:
	var newTombstone = tombstone.instantiate()
	newTombstone.global_position = get_parent().global_position
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
	#newScore.team = pawn.team
	newScore.damageTaken = pawn.damageTaken
	newScore.damageDealt = pawn.damageDealt
	newScore.damageHealed = pawn.damageHealed
	newScore.killCount = pawn.killCount
	board.get_parent().scoreList.push_front(newScore)
