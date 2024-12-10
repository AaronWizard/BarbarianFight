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

	var direction := TileGeometry.cardinal_dir_between_rects(
			data.source_rect, target_actor.rect)

	# Damage from initial kick

	var attack := Attack.new(data.source_actor.definition.attack)
	attack.set_source_rect(data.source_rect)
	Combat.attack_single_actor(target_actor, attack, false)

	# Target sent to new cell

	var shove_cell := _shove_destination(target_actor, data.map, direction)
	var travel_diff := shove_cell - target_actor.origin_cell

	target_actor.origin_cell = shove_cell

	# Animate and resolve collisions

	var is_collision \
			:= travel_diff.length_squared() < (max_distance * max_distance)

	if is_collision:
		await _shove_into_obstacle(target_actor, attack, travel_diff, direction)
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


func _shove_into_obstacle(target_actor: Actor, attack: Attack,
		travel_diff: Vector2i, direction: Vector2i) -> void:
	var new_source_rect := TileGeometry.adjacent_edge_rect(
			target_actor.rect, direction)
	attack.set_source_rect(new_source_rect)

	if travel_diff.length_squared() == 0:
		# Target actor did not leave its current tile.
		Combat.attack_single_actor(target_actor, attack, false)
		await target_actor.sprite.anim_player.animate(
				StandardActorSpriteAnims.HIT, direction)
	else:
		# Target was sent flying.
		await target_actor.sprite.anim_player.animate(
				anim_shove_collision, travel_diff)
		Combat.attack_single_actor(target_actor, attack, false)
		await target_actor.sprite.anim_player.animate(
				anim_shove_collision_reccover, travel_diff)
