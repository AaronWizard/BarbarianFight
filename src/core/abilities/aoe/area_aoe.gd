class_name AreaAOE
extends AreaOfEffect

## An AOE that is all cells between a min and max distance of the target square.
##
## A target range that is all cells between a min and max distance of the target
## square. Distance is measured using
## [url=https://en.wikipedia.org/wiki/Taxicab_geometry]Taxicab geometry[/url].

## The minimum range.[br]
## With a value of 0, the range starts with the cells inside the target square.
## [br]
## With a value of 1, the range starts at the cells adjacent to the target.
@export_range(0, 1, 1, "or_greater") var range_start_dist := 1

## The distance to extend the range past [member range_start_dist].[br]
## The maximum distance is ([member range_start_dist] + [member range_extend]).
@export_range(0, 1, 1, "or_greater") var range_extend := 0


func _get_full_range(target: Square, _source: Square) -> Array[Vector2i]:
	return TileGeometry.cells_in_range(
			target.rect, range_start_dist, range_extend)
