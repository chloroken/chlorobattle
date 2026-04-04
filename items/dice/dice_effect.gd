extends Node2D

@export var diceSprites: Array[Resource] = []
var diceChoice = 0
var direction: Vector2
var speed = 20
var speedVariance = 0.5
var rotDirs = [-1, 1]
var rotSpd = 2
var rotDir

func _ready() -> void:
	speed *= randf_range(speedVariance, 1.0)
	rotDir = rotDirs.pick_random()
	direction = Vector2.RIGHT.rotated(randf_range(0, TAU))

func _process(_delta: float) -> void:
	if $DiceSprite.texture != diceSprites[diceChoice - 1]:
		$DiceSprite.texture = diceSprites[diceChoice - 1]
		$DiceSprite.scale.x *= 0.5 + (diceChoice * 0.05)
		$DiceSprite.scale.y *= 0.5 + (diceChoice * 0.05)
	$DiceSprite.modulate.a = $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	
func _physics_process(delta: float) -> void:
	position += direction * speed * delta;
	rotation += rotDir * rotSpd * delta
	#$DiceSprite.rotation 

func _on_fizzle_timer_timeout() -> void:
	queue_free()
