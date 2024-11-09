@icon("res://assets/editor/icons/ability.png")
class_name Ability
extends Resource

## Class for an active ability an actor can perform.

@export var name := ""

## The ability's target range.
@export var target_range: TargetRange
## The ability's effect.
@export var effect: AbilityEffect
## If true, plays the source actor's attack animation when performing the
## ability.
@export var use_attack_anim := true


func get_target_data(source_actor: Actor) -> TargetingData:
	return target_range.get_target_data(source_actor)


## Performs the ability at [param target] for [param source_actor].[br]
## Assumes [param target] is a valid target.
func perform(target: Vector2i, source_actor: Actor) -> void:
	if use_attack_anim:
		var direction := TileGeometry.cardinal_dir_from_rect_to_cell(
				source_actor.rect, target)
		source_actor.sprite.attack(direction)
		if source_actor.sprite.animation_playing:
			await source_actor.sprite.attack_anim_hit

	@warning_ignore("redundant_await")
	await effect.apply(target, source_actor.rect, source_actor)

	await source_actor.sprite.wait_for_animation()
