extends Node2D

# Load Boards into inspector
@export var lobby: PackedScene
@export var arena: PackedScene
@export var score: PackedScene

## Load Pawns into inspector

# Data structures for passing data between boards
var currentBoard = "lobby"
var pawnList = []
var scoreList = []

# Mode flags
var testingMode = true # disables end-of-game, xp
var repeatPlay = false # starts new game after scoreboard
var repeatTime = 30
var teamsEnabled = false # splits players into two random teams
var maxPlayers = 99

# Drawing layers
var layerArena = 1
var layerGround = 2
var layerPawnBehind = 4
var layerPawn = 5
var layerPawnFront = 6
var layerAir = 8
var layerSky = 9

# Board switching
func _ready() -> void:
	print(str(OS.get_user_data_dir()))
	randomize()
	$cam.make_current()
	switch_board("lobby")
func switch_board(board: String) -> void:
	free_children()
	var boardChoice = lobby
	match board:
		"lobby": boardChoice = lobby
		"arena": boardChoice = arena
		"score": boardChoice = score
	currentBoard = board
	print("[===== Board Loaded =====]: " + currentBoard)
	var newBoard = boardChoice.instantiate()
	newBoard.position = position
	add_child(newBoard)
func free_children() -> void:
	var children = get_children()
	for child in children:
		if child != $cam:
			child.queue_free()

############
# OBSERVER #
############

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Speed Engine Time"):
		Engine.set_time_scale(min(Engine.get_time_scale() * 2, 16.0))
	if event.is_action_pressed("Slow Engine Time"):
		Engine.set_time_scale(max(Engine.get_time_scale() / 2, 0.25))
	if event.is_action_pressed("Pause Engine Time"):
		if Engine.get_time_scale() == 0: Engine.set_time_scale(1)
		else: Engine.set_time_scale(0)

###############
# SAVE SYSTEM #
###############
var savePath = "user://xp.sav"
func add_xp(username, pawn, amount):
	var config = ConfigFile.new()
	config.load(savePath)
	var currentXp = config.get_value(username, pawn, 0)
	config.set_value(username, pawn, currentXp + amount)
	config.save(savePath)
	print(str(username) + " gained " + str(amount) + " xp with " + str(pawn))
func get_xp(username, pawn):
	var config = ConfigFile.new()
	config.load(savePath)
	var currentXp = config.get_value(username, pawn, 0)
	return(currentXp)
