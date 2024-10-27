class_name ActorSpriteAnimationStep
extends Resource

## A single step of an animation for an actor sprite.
##
## A single step of an animation for an actor sprite. Describes a position to
## move the sprite to, which is relative to the actor's origin cell and a
## target cell.


## Sets whether the sprite moves at a constant speed or if the animation runs
## for a constant duration.
enum TimeType {
	## The sprite moves from its original position to the step's new position
	## at a certain speed.[br]
	## Measured in cells per second.
	SPEED,
	## The animation lasts for a set duration, regardless of distance between
	## the sprite's current position and the step's new position.[br]
	## Measured in seconds.
	DURATION
}

## The name of the step. This is the return value of [method animate].
@export var step_name: String

## Positions the sprite at the interpolated point between the actor's origin
## cell and the animation's target cell. e.g. If this value is 0.5, the sprite
## is moved to halfway between the actor's origin cell and the target cell. Can
## be negative.[br]
## Combined with [member cell_distance].
@export var interpolated_distance := 0.0

## Positions the sprite along the vector from the actor's origin cell to the
## animation's target cell, at this value away from the origin cell. e.g. If
## this value is 2, the sprite is moved to a position along the vector 2 cells
## away from the actor's origin cell. Measured in cells. Can be negative.[br]
## Combined with [member interpolated_distance].
@export var cell_distance := 0.0

## The amount of time it takes to move the sprite from its current position to
## the step's new position.[br]
## If this is zero, the sprite's position is updated instantly.
@export var speed_or_duration := 0.0

## Sets whether the sprite moves at a constant speed or if the animation runs
## for a constant duration.
@export var time_type := TimeType.DURATION

## The animation's transition type.
@export var trans_type := Tween.TRANS_LINEAR

## The animation's easing type.
@export var ease_type := Tween.EASE_IN_OUT


## Animates an actor's sprite. Returns [member step_name] when finished.[br]
## [param target_vector] is relative to the actor's origin cell. [param tile_size]
## is in pixels.
func animate(sprite: Sprite2D, target_vector: Vector2, tile_size: Vector2i) \
		-> String:
	var final_cell_position := _get_final_cell_position(target_vector)
	var final_pixel_position := final_cell_position * Vector2(tile_size)

	var final_duration := _get_final_duration(
			final_cell_position, sprite.position, tile_size)

	if final_duration == 0.0:
		sprite.position = final_pixel_position
	else:
		var tween := sprite.create_tween()

		@warning_ignore("return_value_discarded")
		tween.set_trans(trans_type)
		@warning_ignore("return_value_discarded")
		tween.set_ease(ease_type)
		@warning_ignore("return_value_discarded")
		tween.tween_property(
				sprite, "position", final_pixel_position, final_duration)

		if tween.is_running():
			await tween.finished

	return step_name


func _get_final_cell_position(target_vector: Vector2) -> Vector2:
	var interpolated_position := target_vector * interpolated_distance
	var cell_position := target_vector.normalized() * cell_distance
	return interpolated_position + cell_position


func _get_final_duration(final_cell_position: Vector2, sprite_position: Vector2,
		tile_size: Vector2) -> float:
	var result := speed_or_duration

	if (speed_or_duration > 0) and (time_type == TimeType.SPEED):
		var sprite_cell_position := sprite_position / tile_size
		var dist := (final_cell_position - sprite_cell_position).length()
		result = dist / speed_or_duration
		if absf(result) <= 0.01:
			result = 0.0

	return result
