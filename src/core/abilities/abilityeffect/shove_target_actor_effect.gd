class_name ShoveTargetActorEffect
extends AbilityEffect

## Shoves the target actor away from the source.
##
## Shoves the actor covering the target away from the ability effect's source.
## The direction of the shove is based on the direction from the source to the
## target.

const _SPEED := 8.0 # Tiles per second
const _END_TIME := 0.2

## The maximum number in cells the affected actor will be shoved.
@export_range(1, 1, 1, "or_greater") var max_distance := 1


func apply(target: Vector2i, _source: Rect2i, source_actor: Actor) -> void:
	var target_actor := source_actor.map.actor_map.get_actor_on_cell(target)
	assert(target_actor != source_actor)
	var direction := TileGeometry.cardinal_dir_from_rect_to_cell(
			source_actor.rect, target)

	var shove_cell := _shove_destination(target_actor, direction)
	var diff := target_actor.origin_cell - shove_cell
	var distance := diff.length()

	target_actor.origin_cell = shove_cell
	target_actor.sprite.sprite_offset_dir = diff
	target_actor.sprite.sprite_offset_distance = distance

	await _move_with_no_collision(target_actor, distance)
	#if distance < max_distance:
		#await _move_with_collision(target_actor, distance)
	#else:
		#await _move_with_no_collision(target_actor, distance)

	await source_actor.get_tree().create_timer(_END_TIME).timeout


func _shove_destination(actor: Actor, direction: Vector2i) -> Vector2i:
	var result := actor.origin_cell
	for i in range(1, max_distance + 1):
		var cell := actor.origin_cell + (direction * i)
		if actor.map.actor_can_enter_cell(actor, cell):
			result = cell
		else:
			break
	return result


#func _move_with_collision(actor: Actor, distance: float) -> void:
	#pass


func _move_with_no_collision(actor: Actor, distance: float) -> void:
	var tween := actor.sprite.create_tween()
	@warning_ignore("return_value_discarded")
	tween.set_ease(Tween.EASE_OUT)
	@warning_ignore("return_value_discarded")
	tween.set_trans(Tween.TRANS_QUAD)
	@warning_ignore("return_value_discarded")
	tween.tween_property(actor.sprite, "sprite_offset_distance", 0,
			distance / _SPEED)
	if tween.is_running():
		await tween.finished
