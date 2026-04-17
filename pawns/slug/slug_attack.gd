extends "res://pawns/base/base_attack.gd"

var baseDmg

func _ready() -> void:
	z_index = get_node("/root/main").layerGround
	areaAttack = false
	self.scale.x = 0.0
	self.scale.y = 0.0
	baseDmg = $FizzleTimer.get_wait_time() / 2

func _physics_process(_delta: float) -> void:
	var decayRatio = $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	
	# Scale trail damage and color based on duration # 
	dmg = ceil(baseDmg * decayRatio)
	$DamageLabel.text = str(int(dmg))
	$BaseSprite.modulate.b = 1 - decayRatio
	
	# Grow size for effect
	var newScale = 0.25 * (1 + decayRatio)
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
