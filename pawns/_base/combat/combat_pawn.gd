extends Node2D

@export var tombstone: PackedScene
var basePawn

func _ready() -> void:
	basePawn = get_parent()
func clean_up_attack(body) -> void:
	if !body.areaAttack: body.queue_free()
	else: basePawn.hitList.append(body)
func clean_up_pawn(attacker) -> void:
	var pawns = basePawn.get_parent().get_parent().pawnList
	if basePawn.hp <= 0:
		attacker.get_node("Combat/DeathSound").play()
		for i in range(0, pawns.size()):
			if pawns[i].username == basePawn.username:
				attacker.killCount += 1
				if attacker.style == "slayer":
					attacker.get_node("Styles").add_slayer_charge()
				basePawn.get_node("Combat").pawn_death(basePawn, attacker, attacker.username, i)
				break
func pawn_death(pawn, attackingPawn, killer: String, pawnIndex: int) -> void:
	make_tombstone(pawn)
	var mainBoard = get_parent().get_parent().get_parent()
	update_scoreboard(mainBoard, get_parent(), pawnIndex, false)
	kill_log("[" + str(killer) + "] eliminated [" + str(pawn.username) + "]")
	get_parent().queue_free()
	if mainBoard.pawnList.size() <= 1:
		update_scoreboard(mainBoard, attackingPawn, pawnIndex, true)
	else:
		var oneTeamRemains = true
		var pawnTeam = get_parent().get_parent().get_parent().pawnList[0].team
		for p in get_parent().get_parent().get_parent().pawnList:
			if p.team != pawnTeam:
				oneTeamRemains = false
				break
		if oneTeamRemains:
			update_scoreboard(mainBoard, attackingPawn, pawnIndex, true)
func make_tombstone(pawn) -> void:
	var newTombstone = tombstone.instantiate()
	newTombstone.global_position = global_position
	newTombstone.name = "Tombstone (" + pawn.username + ")"
	newTombstone.username = pawn.username
	var theBoard = get_parent().get_parent()
	theBoard.add_child(newTombstone)
func update_scoreboard(mainBoard, pawn, pawnIndex, last) -> void:
	var newScore = mainBoard.Pawn.new()
	newScore.username = pawn.username
	newScore.type = pawn.type
	newScore.style = pawn.style
	newScore.item = pawn.item
	newScore.team = pawn.team
	newScore.damageTaken = pawn.damageTaken
	newScore.damageDealt = pawn.damageDealt
	newScore.damageHealed = pawn.damageHealed
	newScore.killCount = pawn.killCount
	mainBoard.scoreList.push_front(newScore)
	if !last: mainBoard.pawnList.remove_at(pawnIndex)
func combat_log(msg) -> void:
	get_parent().get_parent().update_combat_log(msg)
	debug_log(msg)
func kill_log(msg) -> void:
	get_parent().get_parent().update_kill_feed(msg)
	debug_log(msg)
func debug_log(msg) -> void:
	print(msg)
