class_name TileGeometry

## A set of geometry methods related to tiles/cells.


## Get the [url=https://en.wikipedia.org/wiki/Taxicab_geometry]manhattan
## distance[/url] between two tile cells (number of cells needed to move from
## [param start] to [param end] while only moving in four cardinal directions).
static func manhattan_distance(start: Vector2i, end: Vector2i) -> int:
	var diff := (end - start).abs()
	return int(diff.x + diff.y)


## Get an array of cells forming a line from [param start] to [param end].[br]
## [code]line(start, end)[/code] is not guaranteed to return the same values as
## [code]line(end, start)[/code].
static func line(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	# Bresenham algorithm based on https://zingl.github.io/bresenham.html
	# (because somehow every web site has a different implementation of the
	# Bresenham algorithm with subtly different results).
	var result: Array[Vector2i] = [start]

	if end != start:
		var delta := Vector2i(
			absi(end.x - start.x),
			-absi(end.y - start.y)
		)
		var line_sign := (end - start).sign()
		var err := delta.x + delta.y

		var pos := start
		while pos != end:
			var e2 := 2 * err

			if e2 >= delta.y:
				err += delta.y
				pos.x += line_sign.x
			if e2 <= delta.x:
				err += delta.x
				pos.y += line_sign.y

			result.append(pos)

	return result


## Get an array of cells forming a line starting at [param start] and heading
## towards [param end]. Line can be cut short based on the
## [param is_blocking_cell_func] function. Last cell is either [param end] or
## first blocking cell.[br]
## Uses [method TileGeometry.line]. If [code]line(start, end)[/code] has
## different results from [code]line(end, start)[/code], the result with the
## greater number of cells is returned.[br]
## [code]is_blocking_cell_func(cell: Vector2i) -> bool[/code]: Return true if
## the cell is a blocking cell.
static func unblocked_line(start: Vector2i, end: Vector2i,
		is_blocking_cell_func: Callable) -> Array[Vector2i]:
	var line_start2end := line(start, end)
	var unblocked_line_start2end := _unblocked_line_from_line(
			line_start2end, is_blocking_cell_func)

	var result := unblocked_line_start2end

	if (unblocked_line_start2end[unblocked_line_start2end.size() - 1] != end) \
			and (start.x != end.x) and (start.y != end.y):
		var line_end2start := line(end, start)
		line_end2start.reverse()
		var unblocked_line_end2start := _unblocked_line_from_line(
				line_end2start, is_blocking_cell_func)

		if unblocked_line_end2start.size() > unblocked_line_start2end.size():
			result = unblocked_line_end2start

	return result


## Get the cells covered by [param rect].
static func cells_in_rect(rect: Rect2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []

	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			result.append(Vector2i(x, y))

	return result


## Get the cells surrounding [param source_rect] where each cell is between
## [param range_start_dist]
## and ([param range_start_dist] + [param range_extend]) cells in manhattan
## distances to the closest cell covered by [param source_rect].[br]
## A [param range_start_dist] of 1 starts at the cells adjacent to
## [param source_rect]. A [param range_start_dist] of 0 starts at the cells
## covered by [param source_rect].[br]
## A [param range_extend] of 0 only gets the cells that are at a distance of
## [param range_start_dist].
static func cells_in_range(source_rect: Rect2i, range_start_dist: int,
		range_extend: int, include_diagonals := true) -> Array[Vector2i]:
	assert(source_rect.size.x > 0)
	assert(source_rect.size.y > 0)
	assert(range_start_dist >= 0)
	assert(range_extend >= 0)

	var result: Array[Vector2i] = []

	var max_dist := range_start_dist + range_extend
	var range_length := max_dist - maxi(range_start_dist, 1) + 1

	var range_north := Rect2i(
		source_rect.position + Vector2i(0, -max_dist),
		Vector2i(source_rect.size.x, range_length)
	)
	var range_south := Rect2i(
		source_rect.position \
				+ Vector2i(0, source_rect.size.y + maxi(range_start_dist, 1) - 1),
		Vector2i(source_rect.size.x, range_length)
	)
	var range_west := Rect2i(
		source_rect.position + Vector2i(-max_dist, 0),
		Vector2i(range_length, source_rect.size.y)
	)
	var range_east := Rect2i(
		source_rect.position \
				+ Vector2i(source_rect.size.x + maxi(range_start_dist, 1) - 1, 0),
		Vector2i(range_length, source_rect.size.y)
	)

	if range_start_dist == 0:
		result.append_array(cells_in_rect(source_rect))

	result.append_array(cells_in_rect(range_north))
	result.append_array(cells_in_rect(range_east))
	result.append_array(cells_in_rect(range_south))
	result.append_array(cells_in_rect(range_west))

	if include_diagonals and max_dist > 1:
		var corner_range_size := Vector2i(max_dist, max_dist)

		var corner_nw := source_rect.position
		var range_pos_nw := corner_nw - corner_range_size

		var corner_ne := Vector2i(source_rect.end.x - 1, source_rect.position.y)
		var range_pos_ne := corner_ne + Vector2i(1, -max_dist)

		var corner_se := source_rect.end - Vector2i.ONE
		var range_pos_se := corner_se + Vector2i.ONE

		var corner_sw := Vector2i(source_rect.position.x, source_rect.end.y - 1)
		var range_pos_sw := corner_sw + Vector2i(-max_dist, 1)

		for x in range(0, max_dist):
			for y in range(0, max_dist):
				var cell := Vector2i(x, y)

				var cell_ne := cell + range_pos_ne
				var dist_ne := manhattan_distance(corner_ne, cell_ne)
				if (dist_ne >= range_start_dist) and (dist_ne <= max_dist):
					result.append(cell_ne)

				var cell_nw := cell + range_pos_nw
				var dist_nw := manhattan_distance(corner_nw, cell_nw)
				if (dist_nw >= range_start_dist) and (dist_nw <= max_dist):
					result.append(cell_nw)

				var cell_sw := cell + range_pos_sw
				var dist_sw := manhattan_distance(corner_sw, cell_sw)
				if (dist_sw >= range_start_dist) and (dist_sw <= max_dist):
					result.append(cell_sw)

				var cell_se := cell + range_pos_se
				var dist_se := manhattan_distance(corner_se, cell_se)
				if (dist_se >= range_start_dist) and (dist_se <= max_dist):
					result.append(cell_se)

	return result


## Find the vector in [param cells] that is closest in distance to
## [param target].
static func closest_cell_to_target(cells: Array[Vector2i], target: Vector2i) \
		-> Vector2i:
	var result: Vector2i
	var min_distance_sqr := -1

	for c in cells:
		var current_distance_sqr := (target - c).length_squared()
		if (min_distance_sqr < 0) or (current_distance_sqr < min_distance_sqr):
			result = c
			min_distance_sqr = current_distance_sqr
			if min_distance_sqr == 0:
				break

	return result


static func _unblocked_line_from_line(ln: Array[Vector2i],
		is_blocking_cell_func: Callable) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for cell in ln:
		result.append(cell)
		if (cell != ln[0]) and (cell != ln[ln.size() - 1]):
			var is_blocking := is_blocking_cell_func.call(cell) as bool
			if is_blocking:
				break
	return result
