extends Node2D

var username = ""

# Update Tombstone's username label
func _process(_delta: float) -> void:
	if $NameLabel.text != username:
		$NameLabel.text = username.substr(0, 6)
