extends "res://monsters/_base/monster_base.gd"

func _ready() -> void:
	super()
	monsterName = "Worm"
	baseHp = 25.0
	hp = 25.0
	healPercent = 0.01

func _on_tree_exiting() -> void:
	get_parent().wormArray.pop_front()
