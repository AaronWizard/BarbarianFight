class_name AttackData

## Represents an attack.
##
## Represents an attack. Contains the attack power, source rectangle if any,
## and source actor if any.

## The attack power. How much damage the attack does.
var attack_power := 1

## True if the attack has a source rectangle, which determines the direction of
## the attack.[br]
## If false, the attack has no direction.
var has_source_rect := false
## The source rectangle. Determines the direction of the attack.
var source_rect := Rect2i(0, 0, 0, 0)

## The actor that made the attack
var source_actor: Actor = null


func get_direction(target_rect: Rect2i) -> Vector2i:
	var result := Vector2i.ZERO
	if has_source_rect:
		result = TileGeometry.cardinal_dir_between_rects(
				source_rect, target_rect)
	return result
