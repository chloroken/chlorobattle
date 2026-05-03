extends Node2D

var boardRadius
var center

func _ready() -> void:
	boardRadius = $Collider.get_node("Shape").shape.get_radius()
	center = get_tree().get_root().get_node("main").position
	$Sounds.get_node("BoardChime").panning_strength = 0.0
	$Sounds.get_node("BoardChime").play()

func _process(_delta: float) -> void:
	pass
