class_name ActorStamina
extends TextureProgressBar


func set_actor(actor: Actor) -> void:
	max_value = actor.stamina.max_stamina
	value = actor.stamina.current_stamina

	@warning_ignore("return_value_discarded")
	actor.stamina.stamina_changed.connect(
			_on_actor_stamina_changed.bind(actor.stamina))
	@warning_ignore("return_value_discarded")
	actor.stamina.max_stamina_changed.connect(
			_on_actor_max_stamina_changed.bind(actor.stamina))


func _on_actor_stamina_changed(_delta: int, stamina: Stamina) -> void:
	value = stamina.current_stamina


func _on_actor_max_stamina_changed(_old_max: int, stamina: Stamina) -> void:
	max_value = stamina.max_stamina
