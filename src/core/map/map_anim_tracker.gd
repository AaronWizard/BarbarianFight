class_name MapAnimTracker

## An object that keeps track of what animations are running on a map.
##
## An object that keeps track of what animations are running on a map.
## Animations are either from actors or from effects. Notifies when all
## animations are finished.

## Emitted when all running animations are finished.
signal animations_finished


## Returns true if animations are running, false otherwise.
var animations_playing: bool:
	get:
		return _anim_count > 0


var _anim_count := 0


## Keep track of when the actor is animating.
func observe_actor(actor: Actor) -> void:
	assert(not actor.sprite.animation_started.is_connected(
			_on_actor_sprite_animation_started))
	assert(not actor.sprite.animation_finished.is_connected(
			_on_actor_sprite_animation_finished))

	@warning_ignore("return_value_discarded")
	actor.sprite.animation_started.connect(_on_actor_sprite_animation_started)
	@warning_ignore("return_value_discarded")
	actor.sprite.animation_finished.connect(_on_actor_sprite_animation_finished)


## Stop tracking when an actor is animating.
func unobserve_actor(actor: Actor) -> void:
	assert(actor.sprite.animation_started.is_connected(
			_on_actor_sprite_animation_started))
	assert(actor.sprite.animation_finished.is_connected(
			_on_actor_sprite_animation_finished))

	actor.sprite.animation_started.disconnect(
			_on_actor_sprite_animation_started)
	actor.sprite.animation_finished.disconnect(
			_on_actor_sprite_animation_finished)


func _on_actor_sprite_animation_started() -> void:
	_anim_count += 1


func _on_actor_sprite_animation_finished() -> void:
	_anim_count -= 1
	if not animations_playing:
		animations_finished.emit()
