class_name AreaOfEffect
extends Resource

## Class for getting the area of effect around an ability target.
##
## Class for getting the area of effect around an ability target. This is
## represented by a set of target squares contained in a [TargetingData] object.

## The type of cells within the full range that are valid.
@export var target_type := AbilityRangeUtilities.TargetType.ANY


## If true, line of sight blocked by enemy actors.
@export var los_blocked_by_enemies := false


## If true, line of sight blocked by allied actors.
@export var los_blocked_by_allies := false


## If true, line of sight blocked by cells that block movement.
@export var los_blocked_by_move_blocking := false


## If true, line of sight ignores cells that block ranged abilities.
@export var los_ignores_ranged_blocking := false


## Get the area of effect at [param ability_target] for the ability targeted
## from [param ability_source].[br]
## [param ability_source] does not have to match the size and position of
## [param source_actor].
func get_aoe(ability_target: Square, ability_source: Square,
		source_actor: Actor) -> TargetingData:
	var full_range := _get_full_range(ability_target, ability_source)
	var visible_range := _get_visible_range(
			full_range, ability_target, ability_source, source_actor)
	var targets := _get_targets(visible_range, source_actor)

	return TargetingData.new(visible_range, targets)


## Get the set of cells representing the full unfiltered area of effect.[br]
## Can be overriden.
func _get_full_range(_ability_target: Square, _ability_source: Square) \
		-> Array[Vector2i]:
	push_warning("AreaOfEffect._get_full_range not implemented")
	return []


## Get the cell to use as the start when checking line-of-sight to
## [param cell].[br]
## Defaults to the centermost cell within [param ability_target] that is closest
## to [param cell].[br]
## Can be overriden.
func _los_start_cell(cell: Vector2i, ability_target: Square,
		_ability_source: Square) -> Vector2i:
	return TileGeometry.rect_center_cell_closest_to_target(
			ability_target.rect, cell)


## Returns the target if any that covers [param cell].[br]
## The position of the target may be different from [param cell].[br]
## Can be overriden.
func _target_at_cell(_cell: Vector2i, _source_actor: Actor) -> Square:
	push_warning("TargetRange._target_at_cell not implemented")
	return null


## Returns true if [param source_actor] blocks line-of-sight to [param cell] for
## ability targeting.[br]
## Default implementation checks if the cell blocks sight and ranged abilities.
## [br]
## Can be overriden.
func _cell_blocks_los(cell: Vector2i, source_actor: Actor) -> bool:
	return source_actor.map.terrain.blocks_sight(cell) \
			and source_actor.map.terrain.blocks_ranged(cell)


func _get_visible_range(
		full_range: Array[Vector2i],
		ability_target: Square, ability_source: Square,
		source_actor: Actor) -> Array[Vector2i]:
	var los_start_cell_func := func (cell: Vector2i) -> Vector2i:
		return _los_start_cell(cell, ability_target, ability_source)
	var block_check_func := func(cell: Vector2i) -> bool:
		return _cell_blocks_los(cell, source_actor)

	return AbilityRangeUtilities.get_visible_range(
		full_range, los_start_cell_func,  block_check_func
	)


func _get_targets(visible_range: Array[Vector2i], source_actor: Actor) \
		-> Array[Square]:
	var target_at_cell_func := func (cell: Vector2i) -> Square:
		return _target_at_cell(cell, source_actor)

	return AbilityRangeUtilities.get_targets_in_range(
			visible_range, target_at_cell_func)
