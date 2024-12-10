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
## into an obstacle, before it recovers from the collision.[br]
## The animation is run [i]after[/i] the actor's origin cell is updated.
@export var anim_shove_collision: ActorSpriteAnimation
## The animation the shoved actor's sprite plays when it recovers from being
## shoved into an obstacle.[br]
## The animation is run [i]after[/i] the actor's origin cell is updated.
@export var anim_shove_collision_reccover: ActorSpriteAnimation


func apply(data: AbilityData) -> void:
	var target_actor := data.map.actor_map.get_actor_on_cell(
			data.target)

	if not target_actor:
		push_error("No actor to push")
		return
	if target_actor == data.source_actor:
		push_error("Actor '%s' can't push itself" % data.source_actor)
		return

	var direction := TileGeometry.cardinal_dir_from_rect_to_cell(
			data.source_actor.rect, data.target)
	var damage := data.source_actor.definition.attack

	target_actor.take_damage(damage, Vector2.ZERO, false)

	var shove_cell := _shove_destination(target_actor, data.map, direction)
	var travel_diff := shove_cell - target_actor.origin_cell

	target_actor.origin_cell = shove_cell

	var is_collision \
			:= travel_diff.length_squared() < (max_distance * max_distance)
	if is_collision:
		await _shove_into_obstacle(target_actor, damage, travel_diff, direction)
	else:
		await target_actor.sprite.anim_player.animate(
				anim_shove_no_collision, travel_diff)


func _shove_destination(actor: Actor, map: Map, direction: Vector2i) \
		-> Vector2i:
	var result := actor.origin_cell
	for i in range(1, max_distance + 1):
		var cell := actor.origin_cell + (direction * i)
		if map.actor_can_enter_cell(actor, cell):
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
		await target_actor.sprite.anim_player.animate(
				anim_shove_collision, travel_diff)
		target_actor.take_damage(damage, Vector2.ZERO, false)
		await target_actor.sprite.anim_player.animate(
				anim_shove_collision_reccover, travel_diff)
