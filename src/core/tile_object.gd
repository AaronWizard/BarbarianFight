@tool
class_name TileObject
extends Node2D

## A node that aligns itself along a grid.
##
## A node that aligns itself along a grid.
## [br][br]
## Tile objects have an origin cell for positioning using tile coordinates.
## A tile object's actual pixel position is its [b]bottom left[/b] corner for
## the sake of y-sorting.[br]
## Tile objects also have a cell size, allowing a tile object to cover multiple
## cells in a square. If a tile object is larger than one cell, its origin cell
## is its [b]top left[/b] cell.


## The size in pixels of the grid cells the tile object aligns itself with.
@export var tile_size := Vector2i(16, 16):
	set(value):
		var old_size := tile_size
		# Preserve origin_cell, whose pixel position will change
		var oc := origin_cell

		tile_size = Vector2i(
			maxi(value.x, 1),
			maxi(value.y, 1)
		)

		origin_cell = oc
		if old_size != tile_size:
			_tile_size_changed(old_size)


## The tile object's origin cell. Sets the node's pixel position to its
## [b]bottom left[/b] corner. Is the [b]top left[/b] cell if the tile object
## covers multiple cells.
@export var origin_cell := Vector2i.ZERO:
	get:
		return (Vector2i(position) / tile_size) - Vector2i(0, cell_size)
	set(value):
		var old_cell := origin_cell

		_set_position(value)
		queue_redraw()

		if old_cell != origin_cell:
			_origin_cell_changed(old_cell)


## The width and height in cells of the tile object.
@export var cell_size := 1:
	set(value):
		var old_size := cell_size
		var current_origin_cell := origin_cell

		cell_size = maxi(value, 1)
		queue_redraw()

		if old_size != cell_size:
			# Pixel position depends on cell size
			_set_position(current_origin_cell)
			_cell_size_changed(old_size)


@export_group("Editor Settings")

## The colour of the grid lines used in the editor.
@export_color_no_alpha var grid_colour := Color.MAROON:
	set(value):
		grid_colour = value
		queue_redraw()


## The colour of the origin cell outline used in the editor.
@export_color_no_alpha var origin_colour := Color.DARK_TURQUOISE:
	set(value):
		origin_colour = value
		queue_redraw()


## Show the editor grid lines in-game if true.
@export var show_grid_in_game := false:
	set(value):
		show_grid_in_game = value
		queue_redraw()


## The cells currently covered by the tile object.
var covered_cells: Array[Vector2i]:
	get:
		return covered_cells_at_cell(origin_cell)


## A rect covering the tile object's cells.
var rect: Rect2i:
	get:
		return TileObject.object_rect(origin_cell, cell_size)


func _draw() -> void:
	if Engine.is_editor_hint() or show_grid_in_game:
		for x in range(cell_size + 1):
			var line_x := x * tile_size.x
			var line_y_end := -cell_size * tile_size.y
			draw_line(Vector2(line_x, 0), Vector2(line_x, line_y_end),
					grid_colour, 1)
		for y in range(cell_size + 1):
			var line_x_end := cell_size * tile_size.x
			var line_y := (y - cell_size) * tile_size.y
			draw_line(Vector2(0, line_y), Vector2(line_x_end, line_y),
					grid_colour, 1)

		var origin_rect := Rect2(
			Vector2(0, -cell_size * tile_size.y),
			tile_size
		)
		draw_rect(origin_rect, origin_colour, false, 1)


## Gets the rectangle that covers a tile object whose origin is
## [param tile_object_origin_cell] and cell size is
## [param tile_object_cell_size].
static func object_rect( \
		tile_object_origin_cell: Vector2i,
		tile_object_cell_size: int) -> Rect2i:
	return Rect2i(
		tile_object_origin_cell,
		Vector2i(tile_object_cell_size, tile_object_cell_size)
	)


## Returns true if the tile object covers [param cell], false otherwise.
func covers_cell(cell: Vector2i) -> bool:
	return rect.has_point(cell)


## The cells the tile object would cover if its origin_cell was [param cell].
func covered_cells_at_cell(cell: Vector2i) -> Array[Vector2i]:
	return TileGeometry.cells_in_rect(
		TileObject.object_rect(cell, cell_size)
	)


func _set_position(new_origin_cell: Vector2i) -> void:
	position = (new_origin_cell + Vector2i(0, cell_size)) * tile_size


## Called after tile_size is changed. Can be overriden.
func _tile_size_changed(_old_size: Vector2i) -> void:
	pass


## Called after origin_cell is changed. Can be overriden.
func _origin_cell_changed(_old_cell: Vector2i) -> void:
	pass


## Called after cell_size is changed. Can be overriden.
func _cell_size_changed(_old_size: int) -> void:
	pass
