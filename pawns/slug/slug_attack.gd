extends "res://pawns/base/base_attack.gd"

var baseDmg = 0
var maxScale = 20
var growScale = 1.0005

func _ready() -> void:
	areaAttack = false

# Scale goo damage and color based on duration
func _process(_delta: float) -> void:
	dmg = ceil(baseDmg * min(maxScale, $FizzleTimer.get_wait_time() / $FizzleTimer.get_time_left()))
	$DamageLabel.text = str(dmg)
	$BaseSprite.modulate.g = $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()

# Grow size for effect
func _physics_process(_delta: float) -> void:
	self.scale *= growScale

# Clean up
func _on_fizzle_timer_timeout() -> void:
	self.queue_free()
