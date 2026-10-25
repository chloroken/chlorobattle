extends "res://pawns/_base/attacks/base_attack.gd"

var speed
var direction
var duration
var center
var boardGrace

func _ready() -> void:
	super()
	center = basePawn.center
	z_index = get_node("/root/main").layerAir
	$FizzleTimer.start(duration)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	if position.distance_to(basePawn.center) > basePawn.board.boardRadius * boardGrace:
		basePawn.make_explosion(self.position)
		self.queue_free()

func _on_fizzle_timer_timeout() -> void:
	basePawn.make_explosion(self.position)
	self.queue_free()
