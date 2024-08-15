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


func _get_target_range(source_actor: Actor) -> Array[Vector2i]:
	var source_rect := source_actor.rect
	if not use_source_size:
		source_rect.size = Vector2i.ONE

	var real_range_extend := range_extend
	if scale_extend:
		real_range_extend = ((range_extend + 1) * source_actor.cell_size) - 1

	return TileGeometry.cells_in_range(
			source_rect, range_start_dist, real_range_extend)


func _get_targets(target_range: Array[Vector2i], source_actor: Actor) \
		-> Array[Rect2i]:
	var result: Array[Rect2i] = []

	for cell in target_range:
		pass

	return []


func _los_start_cell(cell: Vector2i, ability_source: Rect2i) -> Vector2i:
	var result: Vector2i
	if target_type == AbilityRangeUtilities.TargetType.ENTERABLE:
		result = ability_source.position
	else:
		result = super(cell, ability_source)
	return result


func _target_at_cell(cell: Vector2i, source_actor: Actor) -> Square:
	return AbilityRangeUtilities.target_at_cell(cell, target_type, source_actor)


func _range_post_processing(target_range: Array[Vector2i],
		source_actor: Actor) -> void:
	if target_type == AbilityRangeUtilities.TargetType.ENTERABLE:
		AbilityRangeUtilities.extend_visible_range_by_size(
				target_range, source_actor.cell_size)
