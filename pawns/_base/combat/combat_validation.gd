extends Node2D

var basePawn
func _ready() -> void:
	basePawn = get_parent()

func _on_base_pawn_area_entered(attack: Area2D) -> void:
	if valid_attack_or_item_hit(attack):
		attack_hit(attack)
		item_hit(attack)
func valid_attack_or_item_hit(attack) -> bool:
	var attackLayer = attack.get_collision_layer_value(2)
	var itemLayer = attack.get_collision_layer_value(3)
	if not attackLayer && not itemLayer:
		return(false)
	if basePawn.inLobby:
		return(false)
	if !basePawn.get_node("Status").get_node("VoidStatusTimer").is_stopped():
		return(false)
	if basePawn.hitList.has(attack):
		return(false)
	var attacker = attack.get_parent().get_parent()
	if attacker.username == basePawn.username:
		return(false)
	return(true)
func attack_hit(attack) -> void:
	if attack.get_collision_layer_value(2):
		$Attack.combat_attack(attack)
func item_hit(attack) -> void:
	if attack.get_collision_layer_value(3):
		$Item.combat_item(attack, basePawn)

func _on_bully_area_area_entered(victim: Area2D) -> void:
	if valid_style_hit(victim):
		style_touch(victim)
func valid_style_hit(victim) -> bool:
	if basePawn.inLobby:
		return(false)
	if basePawn.style != "bully":
		return(false)
	if !victim.get_node("Status").get_node("VoidStatusTimer").is_stopped():
		return(false)
	if !victim.get_collision_layer_value(1):
		return(false)
	if victim.username == basePawn.username:
		return(false)
	return(true)
func style_touch(victim) -> void:
	$Style.bully_touch(victim)

func status_damage(statusType) -> void:
	match statusType:
		"Bleed": $Status.bleed_damage()
		"Sick": $Status.sick_damage()
