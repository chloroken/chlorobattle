extends Node2D

# Dice roll variables
@export var diceSprites: Array[Resource] = []
var diceChoice = 0

# Physics variables
var direction: Vector2
var speed = 20
var speedVariance = 0.5

# Rotation variables
var rotDirArray = [-1, 1]
var rotSpeed = 2
var rotDirection

# Timer variables
var diceDuration = 3.0

func _ready() -> void:
	
	# Randomize physics
	speed *= randf_range(speedVariance, 1.0)
	rotDirection = rotDirArray.pick_random()
	direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	
	# Set visibility ordering
	z_as_relative = false
	z_index = get_node("/root/main").layerPawnBehind
	
	# Start timers
	$FizzleTimer.start(diceDuration)

func _process(_delta: float) -> void:
	
	# Assign proper sprite & scale
	if $DiceSprite.texture != diceSprites[diceChoice - 1]:
		$DiceSprite.texture = diceSprites[diceChoice - 1]
		$DiceSprite.scale.x *= 0.5 + (diceChoice * 0.05)
		$DiceSprite.scale.y *= 0.5 + (diceChoice * 0.05)

	# Adjust alpha based on remaining duration
	$DiceSprite.modulate.a = $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()

# Move dice
func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	rotation += rotDirection * rotSpeed * delta

# Clean up
func _on_fizzle_timer_timeout() -> void:
	queue_free()
