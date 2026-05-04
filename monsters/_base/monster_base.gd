extends Area2D

var monsterName = ""
var baseHp
var hp 
var healPercent

var spd = 5
var dir: Vector2
var rot

var hitList = []
var center

func _ready() -> void:
	center = get_parent().get_parent().center
	rot = randf_range(0, TAU)
	dir = Vector2.RIGHT.rotated(rot)
	position = get_parent().get_parent().center

	# Set visibility order
	z_as_relative = false
	z_index = get_node("/root/main").layerPawnBehind

func _process(_delta: float) -> void:
	$MonsterSprite.rotation = rot
	$MonsterHpFront.scale.x = hp / baseHp

func _physics_process(delta: float) -> void:
	position += dir * spd * delta
	if position.distance_to(center) > get_parent().get_parent().boardRadius:
		dir = position.direction_to(center)
		rot = dir.angle()

func _on_direction_timer_timeout() -> void:
	rot = randf_range(0, TAU)
	dir = Vector2.RIGHT.rotated(rot)

func _on_area_entered(area: Area2D) -> void:
	$Combat.monster_hit(area)
