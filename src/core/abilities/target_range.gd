class_name TargetRange
extends Resource

## Class for getting the target range of an actor's ability.

## Class for getting the target range of an actor's ability. Returns a
## [TargetingData] object containing the set of possible targets.


## The type of cells within the full range that are valid.
@export var target_type := AbilityRangeUtilities.TargetType.ANY

## What cell within the source actor is used as the start of the line of sight
## to a cell inside the target range.
@export var los_origin := AbilityRangeUtilities.LOSSourceOrigin.CENTER


## If true, line of sight blocked by enemy actors.
@export var los_blocked_by_enemies := false


## If true, line of sight blocked by allied actors.
@export var los_blocked_by_allies := false


## If true, line of sight blocked by cells that block movement.
@export var los_blocked_by_move_blocking := false


## If true, line of sight ignores cells that block ranged abilities.
@export var los_ignores_ranged_blocking := false


## Gets the targets for an abilith whose source is [param source_actor].
func get_target_range(source_actor: Actor) -> TargetingData:
	var full_range := _get_full_range(source_actor.square)
	var visible_range := _get_visible_range(full_range, source_actor)
	var targets := _get_targets(visible_range, source_actor)

	_post_processing(visible_range, targets, source_actor.square)

	return TargetingData.new(visible_range, targets)


## Get the set of cells representing the full unfiltered target range.[br]
## Can be overriden.
func _get_full_range(_source: Square) -> Array[Vector2i]:
	push_warning("TargetRange._get_full_range not implemented")
	return []


## Post-processing of visible range and targets.[br]
## Can be overriden.
func _post_processing(_visible_range: Array[Vector2i],
		_targets: Array[Square], _source: Square) -> void:
	pass


func _get_visible_range(full_range: Array[Vector2i], source_actor: Actor) \
		-> Array[Vector2i]:
	return AbilityRangeUtilities.get_cells_in_line_of_sight(
		full_range,
		source_actor.square, los_origin,
		source_actor,
		los_blocked_by_enemies,
		los_blocked_by_allies,
		los_blocked_by_move_blocking,
		los_ignores_ranged_blocking
	)


func _get_targets(visible_range: Array[Vector2i], source_actor: Actor) \
		-> Array[Square]:
	return AbilityRangeUtilities.get_targets_in_range(
		visible_range, target_type, source_actor
	)
