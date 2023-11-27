@tool
class_name MapMarkers
extends Node2D

## A container of TileObjects for annotating a map.


var markers: Array[TileObject]:
	get:
		var result: Array[TileObject] = []
		result.assign(get_children())
		return result


func _get_configuration_warnings() -> PackedStringArray:
	var result := []
	for c in get_children():
		if not c is TileObject:
			result.append("'%s' is not of type 'TileObject'" % c)
	return PackedStringArray(result)


func get_marker(marker_name: String) -> TileObject:
	return get_node(marker_name) as TileObject


func get_marker_names_at_cell(cell: Vector2i) -> Array[String]:
	var result: Array[String] = []
	for m in markers:
		if m.covers_cell(cell):
			result.append(m.name)
	return result
