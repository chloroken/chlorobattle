extends Node2D

# Load Boards into inspector
@export var lobby: PackedScene
@export var arena: PackedScene
@export var score: PackedScene

# Load Pawns into inspector
@export var candle: PackedScene
@export var chair: PackedScene
@export var cyclone: PackedScene
@export var grouper: PackedScene
@export var pirate: PackedScene
@export var ship: PackedScene
@export var slug: PackedScene
@export var top: PackedScene

# Data structures for passing data between scenes
var pawnList = []
var scoreList = []
class Pawn:
	var username = ""
	var type = ""
	var style = ""
	var item = ""
	var damageTaken = 0
	var damageDealt = 0
	var killCount = 0

# Drawing layers
var layerArena = 1
var layerGround = 2
var layerPawnBehind = 4
var layerPawn = 5
var layerPawnFront = 6
var layerAir = 8
var layerSky = 9

var cameraFollowMouse = false

# First code of game to run
func _ready() -> void:
	randomize()
	switch_board("lobby")

# Observer controls
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Speed Engine Time"):
		Engine.set_time_scale(min(Engine.get_time_scale() * 2, 16.0))
	if event.is_action_pressed("Slow Engine Time"):
		Engine.set_time_scale(max(Engine.get_time_scale() / 2, 0.25))
	if event.is_action_pressed("Pause Engine Time"):
		if Engine.get_time_scale() == 0:
			Engine.set_time_scale(1)
			get_tree().paused = false
		else:
			Engine.set_time_scale(0)
			get_tree().paused = true
	if event.is_action_pressed("Toggle Zoom"):
		pass

func switch_board(board: String) -> void:
	free_children()
	var newBoard = lobby
	match board:
		"lobby": newBoard = lobby
		"arena": newBoard = arena
		"score": newBoard = score
	print("[Board Loaded]: " + board)
	add_child(newBoard.instantiate())

func free_children() -> void:
	var children = get_children()
	for child in children:
		if child != $Camera2D:
			child.queue_free()
