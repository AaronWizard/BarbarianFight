class_name BossStamina
extends VBoxContainer


var boss_name: String:
	set(value):
		_boss_name.text = value


var max_stamina: int:
	set(value):
		_stamina_bar.max_value = value


var current_stamina: int:
	set(value):
		_stamina_bar.value = value


@onready var _boss_name := $BossName as Label
@onready var _stamina_bar := $StaminaBar as Range


func show_boss(actor: Actor) -> void:
	assert(actor.actor_name and not actor.actor_name.is_empty())
	assert(actor.stamina.is_alive)

	boss_name = actor.actor_name
	max_stamina = actor.stamina.max_stamina
	current_stamina = actor.stamina.current_stamina

	@warning_ignore("return_value_discarded")
	actor.stamina.stamina_changed.connect(
			_on_actor_stamina_changed.bind(actor.stamina))
	@warning_ignore("return_value_discarded")
	actor.stamina.max_stamina_changed.connect(
			_on_actor_max_stamina_changed.bind(actor.stamina))


func _on_actor_stamina_changed(_delta: int, stamina: Stamina) -> void:
	current_stamina = stamina.current_stamina


func _on_actor_max_stamina_changed(_old_max: int, stamina: Stamina) -> void:
	max_stamina = stamina.max_stamina
