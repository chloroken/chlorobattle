extends Node2D

@export var diceSprites: Array[Resource] = []
var diceChoice = 0
var direction: Vector2
var speed = 20
var speedVariance = 0.5
var rotDirs = [-1, 1]
var rotSpd = 2
var rotDir

# Randomize physics
func _ready() -> void:
	z_index = get_node("/root/main").layerPawnBehind
	speed *= randf_range(speedVariance, 1.0)
	rotDir = rotDirs.pick_random()
	direction = Vector2.RIGHT.rotated(randf_range(0, TAU))

func _process(_delta: float) -> void:
	# Assign proper sprite
	if $DiceSprite.texture != diceSprites[diceChoice - 1]:
		$DiceSprite.texture = diceSprites[diceChoice - 1]
		$DiceSprite.scale.x *= 0.5 + (diceChoice * 0.05)
		$DiceSprite.scale.y *= 0.5 + (diceChoice * 0.05)

	# Adjust alpha based on remaining duration
	$DiceSprite.modulate.a = $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()

# Move dice
func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	rotation += rotDir * rotSpd * delta

# Clean up
func _on_fizzle_timer_timeout() -> void:
	queue_free()
