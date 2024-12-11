class_name ActorStamina
extends TextureProgressBar


var _tracked_actor: Actor


func set_actor(actor: Actor) -> void:
	unset_actor()
	_tracked_actor = actor

	max_value = _tracked_actor.stamina.max_stamina
	value = _tracked_actor.stamina.current_stamina

	@warning_ignore("return_value_discarded")
	_tracked_actor.stamina.stamina_changed.connect(
			_on_actor_stamina_changed.bind(_tracked_actor.stamina))
	@warning_ignore("return_value_discarded")
	_tracked_actor.stamina.max_stamina_changed.connect(
			_on_actor_max_stamina_changed.bind(_tracked_actor.stamina))


func unset_actor() -> void:
	if _tracked_actor:
		_tracked_actor.stamina.stamina_changed.disconnect(
				_on_actor_stamina_changed.bind(_tracked_actor.stamina))
		_tracked_actor.stamina.max_stamina_changed.disconnect(
				_on_actor_max_stamina_changed.bind(_tracked_actor.stamina))
		_tracked_actor = null


func _on_actor_stamina_changed(_delta: int, stamina: Stamina) -> void:
	value = stamina.current_stamina


func _on_actor_max_stamina_changed(_old_max: int, stamina: Stamina) -> void:
	max_value = stamina.max_stamina
