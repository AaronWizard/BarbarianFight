class_name PlayerStamina
extends Control


var max_stamina: int:
	set(value):
		_stamina_bar.max_value = value


var current_stamina: int:
	set(value):
		_stamina_bar.value = value
		_stamina_text.text = str(value)


@onready var _stamina_bar := $HBoxContainer/StaminaBar as Range
@onready var _stamina_text := $StaminaText as Label
