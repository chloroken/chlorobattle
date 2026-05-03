extends "res://monsters/base/monster_base.gd"

func _ready() -> void:
	super()
	monsterName = "Snake"
	baseHp = 125.0
	hp = 125.0
	healPercent = 0.05

func _on_tree_exiting() -> void:
	get_parent().snakeArray.pop_front()
