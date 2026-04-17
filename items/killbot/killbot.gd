extends CharacterBody2D

@export var killbotAttack: PackedScene

var destination
var follow = null
var spd = 50
var following = false
var isPersistentSummon = true
var killbotStacks = 1
var killbotMaxStacks = 3

func _ready() -> void:
	z_index = get_node("/root/main").layerPawn

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
		
	scale.x = 0.5 + (0.5 * killbotStacks)
	scale.y = 0.5 + (0.5 * killbotStacks)

# Use Killbot Attack
func _on_attack_cooldown_timer_timeout() -> void:
	var newBullet = killbotAttack.instantiate()
	add_sibling(newBullet)
	newBullet.killbotParent = self
	newBullet.position = self.position
	newBullet.scale.x = 0.5 + (0.5 * killbotStacks)
	newBullet.scale.y = 0.5 + (0.5 * killbotStacks)
	newBullet.dmg = 10 + (5 * killbotStacks)
	newBullet.speed = 75 + (25 * killbotStacks)

func _on_killbot_stack_timer_timeout() -> void:
	killbotStacks = 1
