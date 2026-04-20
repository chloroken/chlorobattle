extends "res://pawns/base/base_attack.gd"

# Board variables
var center
var boardSize
var items

# Physics variables
var destination = Vector2(0, 0)
var direction: Vector2
var speed

# Bounce variables
var bounceCount = 0
var disableBounceDuration = 0.1

func _ready() -> void:
	
	# Fetch item data
	items = get_parent().get_parent().get_node("Items")
	
	# Make this a single-target attack
	areaAttack = false
	
	# Snapshot center of board
	center = get_viewport_rect().size / 2.0
	
	# Assign a random direction
	direction = Vector2.RIGHT.rotated(randf_range(0, TAU))

	# Set visibility order
	z_as_relative = false
	z_index = get_node("/root/main").layerGround
	
	# Set timers
	$DisableBounceTimer.one_shot = true

# Reduce damage based on bounces
func _process(_delta: float) -> void:
	dmg = items.tireDmgBase - bounceCount * items.tireDmgMod

func _physics_process(delta: float) -> void:
	
	# Bouncing off walls
	var distFromCenter = global_position.distance_to(center)
	var boardRadius = get_parent().get_parent().get_parent().boardRadius
	if $DisableBounceTimer.is_stopped():
		
		# Ensure we bounce at the right location
		if position.distance_to(destination) < 10 || distFromCenter > boardRadius:
			
			# Update destination & speed
			destination = new_destination()
			speed *= items.tireSpeedMod
			
			# Adjust bounce count
			bounceCount += 1
			if bounceCount > items.tireBounceCap:
				tire_has_expired()

			# Make sure we don't bounce multiple times rapidly
			$DisableBounceTimer.start(disableBounceDuration)

	# Move tire 
	$TireSprite.look_at(destination)
	global_position += global_position.direction_to(destination) * speed * delta

func new_destination() -> Vector2:

	# Calculate a new place to go
	boardSize = get_parent().get_parent().get_parent().boardRadius
	var radius = boardSize
	var rando = ((Vector2.RIGHT * radius).rotated(randf_range(0, TAU)))
	var desto = center + rando

	# Avoid picking a location too close
	while global_position.distance_to(desto) < radius:
		desto = new_destination()
	return(desto)

# Start cooldown process
func tire_has_expired() -> void:
	if items != null:
		var randomCooldown = randf_range(items.tireCooldownMin, items.tireCooldownMax)
		items.get_node("TireAttackTimer").start(randomCooldown)
	queue_free()
