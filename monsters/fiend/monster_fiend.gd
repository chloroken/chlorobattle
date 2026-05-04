extends "res://monsters/_base/monster_base.gd"

func _ready() -> void:
	super()
	monsterName = "Fiend"
	baseHp = 500.0
	hp = 500.0
	healPercent = 0.25
