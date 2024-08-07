class_name AreaTargetRange
extends TargetRange

## A target range that is all cells between a min and max distance of the source
## cell or rectangle.
##
## A target range that is all cells between a min and max distance of the source
## cell or rectangle. Distance is measured using
## [url=https://en.wikipedia.org/wiki/Taxicab_geometry]Taxicab geometry[/url].

## The minimum range.[br]
## A value of 1 includes the cells adjacent to the source cell/rectangle.[br]
## A value of 0 includes the source cell / cells covered by the source
## rectangle.
@export var range_start_dist := 1

## The distance to extend the range past [member range_start_dist].[br]
## The maximum distance is ([member range_start_dist] + [member range_extend]).
@export var range_extend := 0

## If true, the source is a square with the source cell at its [b]top left[/b]
## corner (see [TileObject]). If false, the source is a single cell.[br][br]
## Useful for actors larger than one cell to differentiate movement abilities
## (that only need the actor's origin cell) and attack actions (that would need
## the actor's whole square to get the right ranges).
@export var source_is_square := true

## Scales the maximum range by source size.
@export var scale_extend := true


func _get_full_range(source_cell: Vector2i, source_size: int) \
		-> Array[Vector2i]:
	var source_rect := Rect2i(source_cell, Vector2i.ONE)
	if source_is_square:
		source_rect = TileObject.object_rect(source_cell, source_size)

	var real_range_extend := range_extend
	if scale_extend:
		real_range_extend = ((range_extend + 1) * source_size) - 1

	return TileGeometry.cells_in_range(
			source_rect, range_start_dist, real_range_extend)
