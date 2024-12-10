class_name Attack

var attack_power := 0

var has_source_rect := false
var source_rect := Rect2i()


func _init(new_attack_power: int) -> void:
	attack_power = new_attack_power


func set_source_rect(rect: Rect2i) -> void:
	has_source_rect = true
	source_rect = rect
