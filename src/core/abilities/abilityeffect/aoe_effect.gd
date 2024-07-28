class_name AOEEffect
extends AbilityEffect

## What cell is treated as the source cell of the child effect.
enum SourceCellType {
	## The target cell of the ability effect.
	TARGET_CELL,
	## The source cell of the ability effect.
	SOURCE_CELL
}

## The area of effect.
@export var aoe: AreaOfEffect

## The effect to apply at each AOE cell.
@export var child_effect: AbilityEffect

## The cell to use as the source cell of the child effect.
@export var source_cell_type := SourceCellType.TARGET_CELL


func apply(target_cell: Vector2i, source_cell: Vector2i,
		source_size: int, source_actor: Actor) -> void:
	var aoe_cells := aoe.get_aoe(
			target_cell, source_cell, source_size, source_actor)

	var child_effect_source := target_cell
	if source_cell_type == SourceCellType.SOURCE_CELL:
		child_effect_source = source_cell

	pass
