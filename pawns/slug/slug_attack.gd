extends "res://pawns/base/base_attack.gd"

func _ready() -> void:
	areaAttack = false
	self.scale.x = 0.0
	self.scale.y = 0.0

func _physics_process(_delta: float) -> void:
	# Scale trail damage and color based on duration
	dmg = 1 + 0.5 * ($FizzleTimer.get_wait_time() - $FizzleTimer.get_time_left())
	$DamageLabel.text = str(int(dmg))
	$BaseSprite.modulate.b = $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	
	# Grow size for effect
	var newScale = 0.25 * (1 + ( 1 - $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()))
	self.scale.x = newScale
	self.scale.y = newScale
	
	# Destroy any trails outside of the board area
	var center = get_viewport_rect().size / 2.0
	var radius = get_parent().get_parent().get_parent().boardRadius
	if global_position.distance_to(center) > radius * 1:
		queue_free()

# Clean up
func _on_fizzle_timer_timeout() -> void:
	self.queue_free()
