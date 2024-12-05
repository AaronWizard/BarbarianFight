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
## without hitting anything.[br]
## The animation is run [i]after[/i] the actor's origin cell is updated.
@export var anim_shove_no_collision: ActorSpriteAnimation

## The animation the shoved actor's sprite plays when the actor is shoved
## into an obstacle.[br]
## The animation is run [i]after[/i] the actor's origin cell is updated.
@export var anim_shove_collision: ActorSpriteAnimation

## The name of the frame for collision in [member anim_shove_collision].
@export var collision_frame_name := ""


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
	var damage := source_actor.definition.attack

	target_actor.take_damage(damage, Vector2.ZERO, false)

	var shove_cell := _shove_destination(target_actor, direction)
	var travel_diff := shove_cell - target_actor.origin_cell

	target_actor.origin_cell = shove_cell

	var is_collision \
			:= travel_diff.length_squared() < (max_distance * max_distance)
	if is_collision:
		await _shove_into_obstacle(target_actor, damage, travel_diff, direction)
	else:
		await target_actor.sprite.anim_player.animate(
				anim_shove_no_collision, travel_diff)


	if not target_actor.stamina.is_alive:
		await target_actor.sprite.dissolve()
		target_actor.map.remove_actor(target_actor)
	else:
		target_actor.origin_cell = shove_cell
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


func _shove_into_obstacle(target_actor: Actor, damage: int,
		travel_diff: Vector2i, direction: Vector2i) -> void:
	if travel_diff.length_squared() == 0:
		target_actor.take_damage(damage, Vector2.ZERO, false)
		await target_actor.sprite.anim_player.animate(
				StandardActorSpriteAnims.HIT, direction)
	else:
		var on_named_step_finished := func (
				animation: ActorSpriteAnimation, step_name: String) -> void:
			if (animation == anim_shove_collision) \
					and (step_name == collision_frame_name):
				target_actor.take_damage(damage, Vector2.ZERO, false)

		@warning_ignore("return_value_discarded")
		target_actor.sprite.anim_player.named_step_finished.connect(
				on_named_step_finished)

		await target_actor.sprite.anim_player.animate(
				anim_shove_collision, travel_diff)

		target_actor.sprite.anim_player.named_step_finished.disconnect(
				on_named_step_finished)

		# on_named_step_finished was not called
		if collision_frame_name.is_empty():
			target_actor.take_damage(damage, Vector2.ZERO, false)
