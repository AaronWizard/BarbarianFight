class_name Terrain
extends TileMap


const _PROPERTY_BLOCKS_MOVE := "block_move"
const _PROPERTY_BLOCK_SIGHT := "block_sight"


func blocks_move(cell: Vector2i) -> bool:
	var result := not get_used_rect().has_point(cell)
	if not result:
		result = _get_bool_property(cell, _PROPERTY_BLOCKS_MOVE)
	return result


func blocks_sight(cell: Vector2i) -> bool:
	var result := not get_used_rect().has_point(cell)
	if not result:
		result = _get_bool_property(cell, _PROPERTY_BLOCK_SIGHT)
	return result


func tile_object_can_enter_cell(tile_object: TileObject, cell: Vector2i) \
		-> bool:
	var result := true

	for covered in tile_object.covered_cells_at_cell(cell):
		if blocks_move(covered):
			result = false
			break

	return result


func _get_bool_property(cell: Vector2i, property: String) -> bool:
	var result := false
	var tile_data := _get_top_cell_tile_data(cell)
	if tile_data:
		result = tile_data.get_custom_data(property)
	return result


func _get_top_cell_tile_data(cell: Vector2i) -> TileData:
	var result: TileData = null

	for i in range(get_layers_count() - 1, -1, -1):
		var base_data := get_cell_tile_data(0, cell)
		if base_data:
			result = base_data
			break

	return result
