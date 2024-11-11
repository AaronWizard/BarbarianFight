class_name BossStamina
extends VBoxContainer

@onready var _boss_name := $MarginContainer/BossName as Label
@onready var _stamina_bar := $StaminaBar as ActorStamina


func show_boss(actor: Actor) -> void:
	assert(actor.actor_name and not actor.actor_name.is_empty())
	assert(actor.stamina.is_alive)

	_boss_name.text = actor.actor_name
	_stamina_bar.set_actor(actor)
