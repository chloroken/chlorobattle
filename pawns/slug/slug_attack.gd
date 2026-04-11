extends "res://pawns/base/base_attack.gd"

func _ready() -> void:
	areaAttack = false
	self.scale.x = 0.0
	self.scale.y = 0.0

# Scale goo damage and color based on duration
func _process(_delta: float) -> void:
	dmg = 1 + 0.5 * ($FizzleTimer.get_wait_time() - $FizzleTimer.get_time_left())
	$DamageLabel.text = str(int(dmg))
	$BaseSprite.modulate.b = $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()

# Grow size for effect
func _physics_process(_delta: float) -> void:
	var newScale = 0.25 * (1 + ( 1 - $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()))
	self.scale.x = newScale
	self.scale.y = newScale

# Clean up
func _on_fizzle_timer_timeout() -> void:
	self.queue_free()
