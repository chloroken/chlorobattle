extends Node2D

var boardRadius
var center

# Load Pawns into inspector
@export var candle: PackedScene
@export var chair: PackedScene
@export var cyclone: PackedScene
@export var flicker: PackedScene
@export var grouper: PackedScene
@export var meta: PackedScene
@export var mummy: PackedScene
@export var pirate: PackedScene
@export var ship: PackedScene
@export var slug: PackedScene
@export var top: PackedScene

var activePawns = []
class Pawn:
	var username = ""
	var type = ""
	var style = ""
	var item = ""
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

func register_pawn(username: String, type: String, style = "random", item = "random") -> Pawn:
	var newPawn = Pawn.new()
	var pawnList = get_parent().pawnList
	newPawn.username = username
	newPawn.type = type
	newPawn.style = style
	newPawn.item = item
	newPawn.team = ""
	pawnList.append(newPawn)
	return(newPawn)
func spawn_pawn(pawn, attacksDisabled) -> void:
	var pawnType
	if pawn.type == "candle": pawnType = candle
	elif pawn.type == "chair": pawnType = chair
	elif pawn.type == "cyclone": pawnType = cyclone
	elif pawn.type == "flicker": pawnType = flicker
	elif pawn.type == "grouper": pawnType = grouper
	elif pawn.type == "meta": pawnType = meta
	elif pawn.type == "mummy": pawnType = mummy
	elif pawn.type == "pirate": pawnType = pirate
	elif pawn.type == "ship": pawnType = ship
	elif pawn.type == "slug": pawnType = slug
	elif pawn.type == "top": pawnType = top

	# Instantiate Pawn
	var newPawn = pawnType.instantiate()
	newPawn.position = center + evenly_spaced_position(get_parent().pawnList.find(pawn))
	newPawn.name = pawn.username
	newPawn.username = pawn.username
	newPawn.type = pawn.type
	newPawn.style = pawn.style
	newPawn.item = pawn.item
	newPawn.team = pawn.team
	activePawns.append(newPawn)
	if attacksDisabled: newPawn.attacksDisabled = true

	#activePlayers.append(newPawn)
	add_child(newPawn)
	#update_combat_log("Spawned " + newPawn.type + " (" + newPawn.style + ") [" + newPawn.item + "] for " + newPawn.username)
func evenly_spaced_position(i: int) -> Vector2:
	var rot = 2 * PI * i / get_parent().pawnList.size()
	var vec = ((Vector2.RIGHT * boardRadius) * 0.9).rotated(rot)
	return(vec)

func get_pawn_type(message: String):
	if "candle" in message: return("candle")
	elif "chair" in message: return("chair")
	elif "cyclone" in message: return("cyclone")
	elif "flicker" in message: return("flicker")
	elif "grouper" in message: return("grouper")
	elif "meta" in message: return("meta")
	elif "mummy" in message: return("mummy")
	elif "pirate" in message: return("pirate")
	elif "ship" in message: return("ship")
	elif "slug" in message: return("slug")
	elif "top" in message: return("top")
	else: return(choose_random_pawn())
func choose_random_pawn() -> String:
	var allPawnTypes = ["candle", "chair", "cyclone", "flicker", "grouper", "meta", "mummy", "pirate", "ship", "slug", "top"]
	var i = randi_range(0, allPawnTypes.size() - 1)
	return(allPawnTypes[i])
func get_pawn_style(message: String):
	if "berserk" in message: return("berserk")
	elif "berserker" in message: return("berserk") # alias
	elif "bully" in message: return("bully")
	elif "mighty" in message: return("mighty")
	elif "slayer" in message: return("slayer")
	else: return(choose_random_style())
func choose_random_style() -> String:
	var allStyleTypes = ["berserk", "bully", "mighty", "slayer"]
	var i = randi_range(0, allStyleTypes.size() - 1)
	return(allStyleTypes[i])
func get_pawn_item(message: String):
	#if "antimatter" in message: return("antimatter")
	if "dice" in message: return("dice")
	elif "flask" in message: return("flask")
	elif "glue" in message: return("glue")
	elif "killbot" in message: return("killbot")
	elif "map" in message: return("map")
	#elif "milkshake" in message: return("milkshake")
	elif "skates" in message: return("skates")
	elif "smoke" in message: return("smoke")
	elif "tire" in message: return("tire")
	elif "tyre" in message: return("tire")
	else: return(choose_random_item())
func choose_random_item() -> String:
	var allItemTypes = ["dice", "flask", "glue", "killbot", "map", "skates", "smoke", "tire"]
	var i = randi_range(0, allItemTypes.size() - 1)
	return(allItemTypes[i])
