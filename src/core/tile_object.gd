@tool
class_name TileObject
extends Node2D

## A node that aligns itself along a grid.
##
## A node that aligns itself along a grid. Tile objects have an origin cell for
## positioning using tile coordinates, defined as the lower left cell of the
## tile objects. Tile objects also have a width and height in cells, allowing
## a tile object to cover multiple cells in a rectangle.


## The size in pixels of the grid cells the tile object aligns itself with.
@export var tile_size := Vector2i(16, 16):
	set(value):
		var old_size := tile_size

		# Preserve origin_cell, whose pixel position will change
		var oc := origin_cell
		tile_size = value
		origin_cell = oc

		if old_size != tile_size:
			_tile_size_changed(old_size)


## The tile object's origin cell. Sets the node's pixel position to its lower
## left corner. Is the lower left cell if the tile object covers multiple cells.
@export var origin_cell := Vector2i.ZERO:
	get:
		return (Vector2i(position) / tile_size) + Vector2i.UP
	set(value):
		var old_cell := origin_cell

		position = (value - Vector2i.UP) * tile_size
		queue_redraw()

		if old_cell != origin_cell:
			_origin_cell_changed(old_cell)


## The width and height in cells of the tile object.
@export var cell_size := Vector2i.ONE:
	set(value):
		var old_size := cell_size

		cell_size = value
		queue_redraw()

		if old_size != cell_size:
			_cell_size_changed(old_size)


## The cells currently covered by the tile object.
var covered_cells: Array[Vector2i]:
	get:
		return covered_cells_at_cell(origin_cell)


func _draw() -> void:
	if Engine.is_editor_hint():
		for c in covered_cells:
			var rect_pos := (c - origin_cell + Vector2i.UP) * tile_size
			var rect := Rect2i(rect_pos, tile_size)
			var colour: Color
			if c == origin_cell:
				colour = Color.DARK_TURQUOISE
			else:
				colour = Color.MAROON
			draw_rect(rect, colour, false, 0.5)


## Returns true if the tile object covers [param cell], false otherwise.
func covers_cell(cell: Vector2i) -> bool:
	var rect := Rect2i(_top_left_cell(origin_cell), cell_size)
	return rect.has_point(cell)


## The cells the tile object would cover if its origin_cell was [param cell].
func covered_cells_at_cell(cell: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []

	var top_left := _top_left_cell(cell)
	for x in range(cell_size.x):
		for y in range(cell_size.y):
			var covered_cell := Vector2i(x, y) + top_left
			result.append(covered_cell)

	return result


## Called after tile_size is changed. Can be overriden.
func _tile_size_changed(_old_size: Vector2i) -> void:
	pass


## Called after origin_cell is changed. Can be overriden.
func _origin_cell_changed(_old_cell: Vector2i) -> void:
	pass


## Called after cell_size is changed. Can be overriden.
func _cell_size_changed(_old_size: Vector2i) -> void:
	pass


func _top_left_cell(cell: Vector2i) -> Vector2i:
	return cell + (Vector2i.UP * (cell_size.y - 1))
