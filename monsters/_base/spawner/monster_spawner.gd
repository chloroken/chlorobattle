extends Node

var spawnCooldown = 30.0

@export var wormNpc: Resource
var wormArray = []
@export var snakeNpc: Resource
var snakeArray = []
@export var fiendNpc: Resource

var pawnList

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pawnList = get_parent().get_parent().pawnList
	
	$SpawnTimer.one_shot = true
	$SpawnTimer.start(spawnCooldown / pawnList.size())

func _on_spawn_timer_timeout() -> void:
	var newWorm = wormNpc.instantiate()
	add_child(newWorm)
	wormArray.append(newWorm)

	#convert to snakes
	if wormArray.size() >= 3:
		for worm in wormArray:
			if worm != null: worm.queue_free()
		wormArray.clear()
		var newSnake = snakeNpc.instantiate()
		add_child(newSnake)
		snakeArray.append(newSnake)

		# convert to fiends
		if snakeArray.size() >= 3:
			for snake in snakeArray:
				if snake != null: snake.queue_free()
			snakeArray.clear()
			var newFiend = fiendNpc.instantiate()
			add_child(newFiend)

	$SpawnTimer.start(spawnCooldown / pawnList.size())
