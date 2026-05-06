extends "res://items/_base/_attack/item_attack.gd"

var duration
var spinSpeed = 5

func _ready() -> void:
	$FizzleTimer.start(duration)

func _process(delta: float) -> void:
	rotation += spinSpeed * delta
	
func _physics_process(_delta: float) -> void:
	position = killbotParent.position

func _on_fizzle_timer_timeout() -> void:
	queue_free()
