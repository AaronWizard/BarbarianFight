class_name MoveSourceActorToTargetEffect
extends AbilityEffect

## Moves the source actor to the target cell.

## Speed in tiles per second
@export var speed := 8.0


func apply(target_cell: Vector2i, _source_cell: Vector2i, _source_size: int,
		source_actor: Actor) -> void:
	if not source_actor.map.actor_can_enter_cell(source_actor, target_cell):
		push_warning("Actor '%s' could not enter cell at %v"
				% [source_actor, target_cell])
		return

	var diff := source_actor.origin_cell - target_cell
	var distance := diff.length()

	source_actor.origin_cell = target_cell
	source_actor.sprite.sprite_offset_dir = diff
	source_actor.sprite.sprite_offset_distance = distance

	var tween := source_actor.sprite.create_tween()
	@warning_ignore("return_value_discarded")
	tween.set_ease(Tween.EASE_OUT)
	@warning_ignore("return_value_discarded")
	tween.set_trans(Tween.TRANS_QUAD)
	@warning_ignore("return_value_discarded")
	tween.tween_property(source_actor.sprite, "sprite_offset_distance", 0,
			distance / speed)
	if tween.is_running():
		await tween.finished
