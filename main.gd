extends Node2D

@export var lobby: PackedScene
@export var arena: PackedScene
@export var score: PackedScene
@export var chair: PackedScene
@export var grouper: PackedScene
@export var pirate: PackedScene
@export var ship: PackedScene
@export var slug: PackedScene
@export var top: PackedScene
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

func _ready() -> void:
	switch_board("lobby")

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
		child.queue_free()
