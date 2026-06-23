extends Node2D

var boardRadius
var center

# Load Pawns into inspector
@export var candle: PackedScene
@export var cat: PackedScene
@export var chair: PackedScene
@export var demon: PackedScene
@export var fish: PackedScene
@export var ghost: PackedScene
@export var mecha: PackedScene
@export var mummy: PackedScene
@export var pirate: PackedScene
@export var ship: PackedScene
@export var slug: PackedScene
@export var top: PackedScene
@export var witch: PackedScene

var activePawns = []
class Pawn:
	var username = ""
	var type = ""
	var style = ""
	var item = ""
	var costume = 0
	var team = ""
	var damageTaken = 0
	var damageDealt = 0
	var damageHealed = 0
	var killCount = 0

func _ready() -> void:
	boardRadius = $Collider.get_node("Shape").shape.get_radius()
	center = get_parent().position
	$Sounds.get_node("BoardChime").panning_strength = 0.0
	$Sounds.get_node("BoardChime").play()

func register_pawn(username: String, type: String, style = "random", item = "random", costume = 1) -> Pawn:
	var newPawn = Pawn.new()
	var pawnList = get_parent().pawnList
	newPawn.username = username
	newPawn.type = type
	newPawn.style = style
	newPawn.item = item
	newPawn.team = ""

	var pawnXp = get_parent().get_xp(username, type)
	if pawnXp >= 100: newPawn.costume = costume
	else: newPawn.costume = 1

	pawnList.append(newPawn)
	return(newPawn)
func spawn_pawn(pawn, attacksDisabled) -> void:
	var pawnType
	if pawn.type == "candle": pawnType = candle
	elif pawn.type == "cat": pawnType = cat
	elif pawn.type == "chair": pawnType = chair
	elif pawn.type == "demon": pawnType = demon
	elif pawn.type == "fish": pawnType = fish
	elif pawn.type == "ghost": pawnType = ghost
	elif pawn.type == "mecha": pawnType = mecha
	elif pawn.type == "mummy": pawnType = mummy
	elif pawn.type == "pirate": pawnType = pirate
	elif pawn.type == "ship": pawnType = ship
	elif pawn.type == "slug": pawnType = slug
	elif pawn.type == "top": pawnType = top
	elif pawn.type == "witch": pawnType = witch

	# Instantiate Pawn
	var newPawn = pawnType.instantiate()
	newPawn.position = center + evenly_spaced_position(get_parent().pawnList.find(pawn))
	newPawn.name = pawn.username
	newPawn.username = pawn.username
	newPawn.type = pawn.type
	newPawn.style = pawn.style
	newPawn.item = pawn.item
	newPawn.team = pawn.team
	newPawn.costume = pawn.costume
	newPawn.board = self
	activePawns.append(newPawn)
	if attacksDisabled: newPawn.attacksDisabled = true

	add_child(newPawn)

func evenly_spaced_position(i: int) -> Vector2:
	var rot = 2 * PI * i / get_parent().pawnList.size()
	var vec = ((Vector2.RIGHT * boardRadius) * 0.9).rotated(rot)
	return(vec)

func get_pawn_type(message: String):
	if "candle" in message: return("candle")
	elif "cat" in message: return("cat")
	elif "chair" in message: return("chair")
	elif "demon" in message: return("demon")
	elif "meta" in message: return("demon") # ALIAS
	elif "fish" in message: return("fish")
	elif "grouper" in message: return("fish") # ALIAS
	elif "ghost" in message: return("ghost")
	elif "mecha" in message: return("mecha")
	elif "cyclone" in message: return("mecha") # ALIAS
	elif "mummy" in message: return("mummy")
	elif "pirate" in message: return("pirate")
	elif "ship" in message: return("ship")
	elif "slug" in message: return("slug")
	elif "top" in message: return("top")
	elif "witch" in message: return("witch")
	elif "flicker" in message: return("witch") # ALIAS
	else: return(choose_random_pawn())
func choose_random_pawn() -> String:
	var allPawnTypes = ["candle", "cat", "chair", "demon", "fish", "ghost", "mecha", "mummy", "pirate", "ship", "slug", "top", "witch"]
	var i = randi_range(0, allPawnTypes.size() - 1)
	return(allPawnTypes[i])
func get_pawn_style(message: String):
	if "berserk" in message: return("berserk")
	elif "berserker" in message: return("berserk") # ALIAS
	elif "bully" in message: return("bully")
	elif "mighty" in message: return("mighty")
	elif "parkour" in message: return("parkour")
	elif "slayer" in message: return("slayer")
	else: return(choose_random_style())
func choose_random_style() -> String:
	var allStyleTypes = ["berserk", "bully", "parkour", "mighty", "slayer"]
	var i = randi_range(0, allStyleTypes.size() - 1)
	return(allStyleTypes[i])
func get_pawn_item(message: String):
	if "antimatter" in message: return("antimatter")
	elif "dice" in message: return("dice")
	elif "flask" in message: return("flask")
	elif "glue" in message: return("glue")
	elif "killbot" in message: return("killbot")
	elif "map" in message: return("map")
	elif "milkshake" in message: return("milkshake")
	elif "skates" in message: return("skates")
	elif "smoke" in message: return("smoke")
	elif "vial" in message: return("smoke") # ALIAS
	elif "tire" in message: return("tire")
	elif "tyre" in message: return("tire") # ALIAS
	else: return(choose_random_item())
func choose_random_item() -> String:
	var allItemTypes = ["antimatter", "dice", "flask", "glue", "killbot", "map", "milkshake", "skates", "smoke", "tire"]
	var i = randi_range(0, allItemTypes.size() - 1)
	return(allItemTypes[i])
func get_pawn_costume(message: String) -> int:
	if "1" in message: return(1)
	elif "2" in message: return(2)
	elif "3" in message: return(3)
	elif "4" in message: return(4)
	elif "5" in message: return(5)
	elif "6" in message: return(6)
	elif "7" in message: return(7)
	elif "8" in message: return(8)
	elif "9" in message: return(9)
	else: return(0)
