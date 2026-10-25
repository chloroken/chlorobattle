extends "res://pawns/_base/attacks/base_attack.gd"

@export var absorbScene: PackedScene
var baseDmg
var duration

func _ready() -> void:
	super()
	scale = Vector2.ZERO
	z_index = get_node("/root/main").layerGround
	$FizzleTimer.start(duration)

func _physics_process(_delta: float) -> void:
	var fizzleRatio = $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	adjust_slime_damage(fizzleRatio)
	adjust_slime_alpha(fizzleRatio)
	adjust_slime_scale(fizzleRatio)
	destroy_out_of_bounds_slime()
func adjust_slime_damage(ratio) -> void:
	dmg = max(1, ceil(baseDmg * ratio))
func adjust_slime_alpha(ratio) -> void:
	$BaseSprite.modulate.a = max(0.5, ratio)
func adjust_slime_scale(ratio) -> void:
	var newScale = 0.15 * (1 + ratio)
	self.scale = Vector2.ONE * newScale

func destroy_out_of_bounds_slime() -> void:
	var radius = basePawn.board.boardRadius
	if global_position.distance_to(basePawn.center) > radius:
		queue_free()
func _on_fizzle_timer_timeout() -> void:
	if basePawn.get_node("SlugRespawnTimer").is_stopped():
		basePawn.slug_regen()
		var newAbsorb = absorbScene.instantiate()
		newAbsorb.position = basePawn.position
		add_sibling(newAbsorb)
	self.queue_free()
