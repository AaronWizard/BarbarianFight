class_name TargetRange
extends Resource

## Class for getting the target range of an ability.


## Gets the target range around [param source_rect].[br]
## Can be overriden.
func get_target_range(_source_rect: Rect2i) -> TargetRangeData:
	push_warning("TargetRange.get_target_range not implemented")
	return TargetRangeData.new([], [], {}, {})
