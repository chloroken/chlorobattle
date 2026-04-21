extends TextureRect

var statusName
var statusDuration
var statusTexture

func _ready() -> void:

	# Set status properties
	texture = statusTexture
	$FizzleTimer.start(statusDuration)

func _on_fizzle_timer_timeout() -> void:
	queue_free()
