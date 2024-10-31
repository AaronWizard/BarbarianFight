class_name ShoveTargetActorEffect
extends AbilityEffect

## Shoves the target actor away from the source.
##
## Shoves the actor covering the target away from the ability effect's source.
## The direction of the shove is based on the direction from the source to the
## target.

const _END_TIME := 0.2

## The maximum number in cells the affected actor will be shoved.
@export_range(1, 1, 1, "or_greater") var max_distance := 1

## The animation the shoved actor's sprite plays when the actor is shoved
## without hitting anything.
@export var anim_shove_no_collision: ActorSpriteAnimation

## The animation the shoved actor's sprite plays when the actor is shoved
## into an obstacle.
@export var anim_shove_collision: ActorSpriteAnimation


func apply(target: Vector2i, _source: Rect2i, source_actor: Actor) -> void:
	var target_actor := source_actor.map.actor_map.get_actor_on_cell(target)

	if not target_actor:
		push_error("No actor to push")
		return
	if target_actor == source_actor:
		push_error("Actor '%s' can't push itself" % source_actor)
		return

	var direction := TileGeometry.cardinal_dir_from_rect_to_cell(
			source_actor.rect, target)

	var shove_cell := _shove_destination(target_actor, direction)
	if shove_cell == target_actor.origin_cell:
		await target_actor.sprite.hit(direction)
	else:
		var diff := shove_cell - target_actor.origin_cell
		target_actor.origin_cell = shove_cell
		if diff.length_squared() < (max_distance * max_distance):
			await target_actor.sprite.play_animation(diff, anim_shove_collision)
		else:
			await target_actor.sprite.play_animation(
					diff, anim_shove_no_collision)

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
