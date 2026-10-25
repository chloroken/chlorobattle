extends Area2D

# References
var basePawn

# Attack properties
var dmg

# Attack flags
var attackName = "baseAttack"
var areaAttack = true
var killbotParent = null

# Special triggers
var isGlyphAttack = false
var isSwarmAttack = false
var isSlugAttack = false
var isSoulAttack = false
var isRedSwipeAttack = false
var isYarnAttack = false
var isYellowBirdAttack = false
var isHauntAttack = false
var isBooAttack = false
var isEmpAttack = false
var isCauldronAttack = false
var isPurpleFrogAttack = false
var isRamAttack = false
var isInfernoAttack = false
var isSpiderAttack = false

func _ready() -> void:
	basePawn = get_parent().get_parent()
	z_as_relative = false
	z_index = get_node("/root/main").layerPawnBehind
