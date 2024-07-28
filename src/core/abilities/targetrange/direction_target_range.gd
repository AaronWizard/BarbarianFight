class_name DirectionTargetRange
extends TargetRange

## A target range representing a target in one of the four cardinal directions
## from the source.


## The minimum distance.
## A value of 1 indicates the cells adjacent to the source cell/square.
@export_range(1, 2, 1, "or_greater") var range_start_dist := 1

## The distance to extend the range past [member range_start_dist].[br]
## The maximum distance is ([member range_start_dist] + [member range_extend]).
@export_range(0, 1, 1, "or_greater") var range_extend := 0


func _get_full_range(source: Square) \
		-> Array[Vector2i]:
	var result: Array[Vector2i] = []

	var north := _get_line(source.position + Vector2i.UP, Vector2i.UP)
	result.append_array(north)

	var east := _get_line(source.position + (Vector2i.RIGHT * source.size),
			Vector2i.RIGHT)
	result.append_array(east)

	var south := _get_line(source.position + (Vector2i.DOWN * source.size),
			Vector2i.DOWN)
	result.append_array(south)

	var west := _get_line(source.position + Vector2i.LEFT, Vector2i.LEFT)
	result.append_array(west)

	return result


func _get_line(start_cell: Vector2i, delta: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []

	for i in range(range_start_dist - 1, range_start_dist + range_extend):
		var cell := start_cell + (delta * i)
		result.append(cell)

	return result
