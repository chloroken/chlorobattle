extends Node2D

var username = ""

func _ready() -> void:
	z_as_relative = false
	z_index = get_node("/root/main").layerPawnBehind

# Update Tombstone's username label
func _process(_delta: float) -> void:
	if $NameLabel.text != username:
		$NameLabel.text = username.substr(0, 6)
		
	# Destroy any tombstones outside of the board area
	var radius = get_parent().get_parent().boardRadius
	if global_position.distance_to(get_parent().get_parent().center) > radius * 1:
		queue_free()
