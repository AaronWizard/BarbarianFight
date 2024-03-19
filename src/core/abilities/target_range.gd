class_name TargetRange
extends Resource

## Class for getting the target range of an ability.


## Gets the target range around [param source_rect].
func get_target_range(_source_rect: Rect2i) -> TargetRangeData:
	return TargetRangeData.new()
