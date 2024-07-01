class_name Terrain

const _PROPERTY_BLOCK_MOVE := "block_move"
const _PROPERTY_BLOCK_SIGHT := "block_sight"
const _PROPERTY_BLOCK_RANGED := "block_ranged"

var _tilemap: TileMap


func _init(tilemap: TileMap) -> void:
	_tilemap = tilemap


func blocks_move(cell: Vector2i) -> bool:
	return _get_bool_property(cell, _PROPERTY_BLOCK_MOVE, true)


func blocks_sight(cell: Vector2i) -> bool:
	return _get_bool_property(cell, _PROPERTY_BLOCK_SIGHT, true)


func blocks_ranged(cell: Vector2i) -> bool:
	return _get_bool_property(cell, _PROPERTY_BLOCK_RANGED, true)


func tile_object_can_enter_cell(tile_object: TileObject, cell: Vector2i) \
		-> bool:
	var result := true

	for covered in tile_object.covered_cells_at_cell(cell):
		if blocks_move(covered):
			result = false
			break

	return result


func _get_bool_property(cell: Vector2i, property: String,
		value_if_outside_map: bool) -> bool:
	var result := false

	if _tilemap.get_used_rect().has_point(cell):
		var tile_data := _get_top_cell_tile_data(cell)
		if tile_data:
			result = tile_data.get_custom_data(property)
	else:
		result = value_if_outside_map

	return result


func _get_top_cell_tile_data(cell: Vector2i) -> TileData:
	var result: TileData = null

	for i in range(_tilemap.get_layers_count() - 1, -1, -1):
		var base_data := _tilemap.get_cell_tile_data(0, cell)
		if base_data:
			result = base_data
			break

	return result
