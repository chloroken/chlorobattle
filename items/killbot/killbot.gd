extends CharacterBody2D

@export var killbotAttack: PackedScene

var destination
var follow = null
var spd = 50
var following = false
var isPersistentSummon = true

# State-based chasing behavior
func _physics_process(delta: float) -> void:
	if follow != null:
		destination = follow.position	
	if !following && position.distance_to(follow.position) > 100:
		following = true
	if following:
		position = position.move_toward(destination, spd * delta)
	if following && position.distance_to(follow.position) < 20:
		following = false

# Use Killbot Attack
func _on_attack_cooldown_timer_timeout() -> void:
	var newBullet = killbotAttack.instantiate()
	add_sibling(newBullet)
	newBullet.position = self.position
