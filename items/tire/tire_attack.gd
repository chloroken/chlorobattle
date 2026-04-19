extends CollisionObject2D

var destination = Vector2(0, 0)
var direction: Vector2
var pen = 0
var isPersistentSummon = true
var mummyCenter = false
var center
var boardSize

var areaAttack = false
var speed = 25
var baseSpeed = 100
var dmg = 25
var baseDmg = 25
var bounceCap = 3
var bounceCount = 0
var bounceModifier = 25

# Assign a random direction
func _ready() -> void:
	boardSize = get_parent().get_parent().get_parent().boardRadius
	z_index = get_node("/root/main").layerGround
	direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	center = get_viewport_rect().size / 2.0

func _process(_delta: float) -> void:
	
	dmg = baseDmg + bounceCount * bounceModifier
	scale.x = 1 + 0.25 * bounceCount
	scale.y = 1 + 0.25 * bounceCount

# Move arrow forward
func _physics_process(delta: float) -> void:
	speed = baseSpeed - bounceCount * bounceModifier
	
	# Bouncing off a wall
	#var distFromDesto = global_position.distance_to(destination)
	var distFromCenter = global_position.distance_to(center)
	var boardRadius = get_parent().get_parent().get_parent().boardRadius
	if distFromCenter >= boardRadius:
		destination = new_destination()
		bounceCount += 1
		if bounceCount > bounceCap:
			queue_free()
	global_position += global_position.direction_to(destination) * speed * delta
	
	$BaseSprite.look_at(destination)

# Calculate a new place for Pawn to go
func new_destination() -> Vector2:
	var radius = boardSize
	var rando = ((Vector2.RIGHT * radius).rotated(randf_range(0, TAU)))
	var desto = center + rando

	# Avoid picking a location too close
	while global_position.distance_to(desto) < radius:
		desto = new_destination()
	return(desto)

func _on_tree_exiting() -> void:
	var parentPawnItems = get_parent().get_parent().get_node("Items")
	parentPawnItems.get_node("TireAttackTimer").start(randf_range(parentPawnItems.tireCooldownMin, parentPawnItems.tireCooldownMax))
