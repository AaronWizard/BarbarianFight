class_name AreaTargetRange
extends TargetRange

## A target range that is all cells between a min and max distance of the source
## rectangle.
##
## A target range that is all cells between a min and max distance of the source
## rectangle. Distance is measured using
## [url=https://en.wikipedia.org/wiki/Taxicab_geometry]Taxicab geometry[/url].

@export var min_dist := 0
@export var max_dist := 1


func _get_full_range(source_rect: Rect2i) -> Array[Vector2i]:
	return TileGeometry.cells_in_range(source_rect, min_dist, max_dist)
