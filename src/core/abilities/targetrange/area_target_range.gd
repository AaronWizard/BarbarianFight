class_name AreaTargetRange
extends TargetRange

## A target range that is all cells between a min and max distance of the source
## square.
##
## A target range that is all cells between a min and max distance of the source
## square. Distance is measured using
## [url=https://en.wikipedia.org/wiki/Taxicab_geometry]Taxicab geometry[/url].

## The minimum range.[br]
## With a value of 0, the range starts with the cells inside the source square.
## [br]
## With a value of 1, the range starts at the cells adjacent to the source.
@export_range(0, 1, 1, "or_greater") var range_start_dist := 1

## The distance to extend the range past [member range_start_dist].[br]
## The maximum distance is ([member range_start_dist] + [member range_extend]).
@export_range(0, 1, 1, "or_greater") var range_extend := 0

## If true, use the whole source square as the source of the target range. If
## false, only use the single cell at the source's position (its top left cell).
## [br][br]
## Setting this to false is appropriate for abilities whose targeting only uses
## the source actor's origin cell, such as movement abilities.
@export var use_source_size := true

## If true, scale the maximum range by the source's size.
@export var scale_extend := true


## The type of cells within the full range that are valid.
@export var target_type := AbilityRangeUtilities.TargetType.ANY

## If true, terrain that blocks the source actor's movement blocks line-of-sight.
@export var movement_blocking_los := false

## Whether other actors block line-of-sight.
@export var actor_blocking := AbilityRangeUtilities.LOSActorBlocking.NONE

## Ignores terrain that blocks ranged abilities if true.
@export var ignore_range_blocking := false


func _get_target_range(source_actor: Actor) -> Array[Vector2i]:
	var source_rect := source_actor.rect
	if not use_source_size:
		source_rect.size = Vector2i.ONE

	var real_range_extend := range_extend
	if scale_extend:
		real_range_extend = ((range_extend + 1) * source_actor.cell_size) - 1

	var base_range := TileGeometry.cells_in_range(
			source_rect, range_start_dist, real_range_extend)

	var los_start_cell_func := func (cell: Vector2i) -> Vector2i:
		return _los_start_cell(cell, source_actor)
	var is_los_blocking_cell_func := func (cell: Vector2i) -> bool:
		return AbilityRangeUtilities.is_los_blocking_cell(
			cell, source_actor,
			movement_blocking_los, actor_blocking, ignore_range_blocking
		)

	return AbilityRangeUtilities.get_visible_range(
			base_range, los_start_cell_func, is_los_blocking_cell_func)


func _get_targets(target_range: Array[Vector2i], source_actor: Actor) \
		-> Array[Rect2i]:
	return AbilityRangeUtilities.get_targets_in_range(
			target_range, target_type, source_actor)


func _range_post_processing(target_range: Array[Vector2i],
		source_actor: Actor) -> void:
	if target_type == AbilityRangeUtilities.TargetType.ENTERABLE:
		AbilityRangeUtilities.extend_visible_range_by_size(
				target_range, source_actor.cell_size)


func _los_start_cell(target_cell: Vector2i, source_actor: Actor) -> Vector2i:
	var result: Vector2i
	if target_type == AbilityRangeUtilities.TargetType.ENTERABLE:
		result = source_actor.origin_cell
	else:
		result = TileGeometry.rect_center_cell_closest_to_target(
				source_actor.rect, target_cell)
	return result
