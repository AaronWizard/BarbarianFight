class_name PlayerStamina
extends Control

@onready var _stamina_bar := $HBoxContainer/StaminaBar as ActorStamina


func set_player(actor: Actor) -> void:
	_stamina_bar.set_actor(actor)
