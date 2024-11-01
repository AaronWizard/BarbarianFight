class_name Terrain

## A [TileMap] wrapper for getting the properties of a map's terrain.

const _PROPERTY_BLOCK_MOVE := "block_move"
const _PROPERTY_BLOCK_SIGHT := "block_sight"
const _PROPERTY_BLOCK_RANGED := "block_ranged"

var _tilemap: TileMapLayer


func _init(tilemap: TileMapLayer) -> void:
	_tilemap = tilemap


## If true, the cell blockes movement.
func blocks_move(cell: Vector2i) -> bool:
	return _get_bool_property(cell, _PROPERTY_BLOCK_MOVE, true)


## If true, the cell blocks actor vision.
func blocks_sight(cell: Vector2i) -> bool:
	return _get_bool_property(cell, _PROPERTY_BLOCK_SIGHT, true)


## If true, the cell blockes ranged abilities.
func blocks_ranged(cell: Vector2i) -> bool:
	return _get_bool_property(cell, _PROPERTY_BLOCK_RANGED, true)


## Returns true if all cells covered by [param rect] allow movement.
func rect_allows_movement(rect: Rect2i) -> bool:
	var result := true

	for covered in TileGeometry.cells_in_rect(rect):
		if blocks_move(covered):
			result = false
			break

	return result


func _get_bool_property(cell: Vector2i, property: String,
		value_if_outside_map: bool) -> bool:
	var result := false

	if _tilemap.get_used_rect().has_point(cell):
		var tile_data := _tilemap.get_cell_tile_data(cell)
		if tile_data:
			result = tile_data.get_custom_data(property)
	else:
		result = value_if_outside_map

	return result
