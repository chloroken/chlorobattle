extends Node2D

# Load Boards into inspector
@export var lobby: PackedScene
@export var arena: PackedScene
@export var score: PackedScene

# Load Pawns into inspector
@export var candle: PackedScene
@export var chair: PackedScene
@export var flicker: PackedScene
@export var cyclone: PackedScene
@export var grouper: PackedScene
@export var meta: PackedScene
@export var mummy: PackedScene
@export var pirate: PackedScene
@export var ship: PackedScene
@export var slug: PackedScene
@export var top: PackedScene

# Data structures for passing data between boards
var currentBoard = "lobby"
var pawnList = []
var scoreList = []
class Pawn:
	var username = ""
	var type = ""
	var style = ""
	var item = ""
	var team = ""
	var damageTaken = 0
	var damageDealt = 0
	var damageHealed = 0
	var killCount = 0

# Mode flags
var teamsEnabled = true
var maxPlayers = 8

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

# Observer controls
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Speed Engine Time"):
		Engine.set_time_scale(min(Engine.get_time_scale() * 2, 16.0))
	if event.is_action_pressed("Slow Engine Time"):
		Engine.set_time_scale(max(Engine.get_time_scale() / 2, 0.25))
	if event.is_action_pressed("Pause Engine Time"):
		if Engine.get_time_scale() == 0: Engine.set_time_scale(1)
		else: Engine.set_time_scale(0)
