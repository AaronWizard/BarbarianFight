class_name AbilityDisplay
extends HBoxContainer

signal cancelled

@onready var _ability_name := $Name as Label


func set_ability_name(ability_name: String) -> void:
	_ability_name.text = ability_name


func _on_cancel_pressed() -> void:
	cancelled.emit()
