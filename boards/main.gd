extends Node2D

@export var lobby: PackedScene
@export var early: PackedScene
@export var end: PackedScene
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
	var placeEarned = 0

func _ready() -> void:
	switch_board("lobby")

func _physics_process(_delta: float) -> void:
	#if Input.is_key_pressed(KEY_KP_ADD): Engine.max_fps = 120
	#if Input.is_key_pressed(KEY_KP_SUBTRACT): Engine.max_fps = 30
	#if Input.is_key_pressed(KEY_KP_0): Engine.max_fps = 60
	#var SPEED = 500
	#var vec = get_viewport().get_mouse_position() - self.position # getting the vector from self to the mouse
	#vec = vec.normalized() * delta * SPEED # normalize it and multiply by time and speed
	#position += vec # move by that vector
	pass

func switch_board(board: String) -> void:
	free_children()
	var newBoard = lobby
	match board:
		"lobby": newBoard = lobby
		"early": newBoard = early
		"end": newBoard = end
	print("[Board Loaded]: " + board)
	add_child(newBoard.instantiate())
	
func free_children() -> void:
	var children = get_children()
	for child in children:
		if child.name != "Camera2D":
			child.queue_free()
