class_name AreaOfEffect
extends Resource

## Class for getting the area of effect around an ability target.
##
## Class for getting the area of effect around an ability target. This is
## represented by a set of target squares contained in a [TargetingData] object.

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


## Get the area of effect at [param target] for the ability targeted from
## [param source].[br]
## [param source] does not have to match the size and position of
## [param source_actor].
func get_aoe(target: Square, source: Square, source_actor: Actor) \
		-> TargetingData:
	var full_range := _get_full_range(target, source)
	var visible_range := _get_visible_range(full_range, source_actor)
	var targets := _get_targets(visible_range, source_actor)

	return TargetingData.new(visible_range, targets)


## Get the set of cells representing the full unfiltered area of effect.[br]
## Can be overriden.
func _get_full_range(_target: Square, _source: Square) -> Array[Vector2i]:
	push_warning("AreaOfEffect._get_full_range not implemented")
	return []


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
