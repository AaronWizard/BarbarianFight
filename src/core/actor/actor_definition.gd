class_name ActorDefinition
extends Resource

## Define the stats and skills for a type of actor.

enum _Columns
{
	NAME,
	STAMINA,
	ATTACK
}

## The actor's name
@export var name: String

## The path to the CSV file containing the stats of all actors.
@export_file("*.csv") var stats_file := ""
## The name labelling the row in the actor stats CSV file containing the stats
## for this actor.
@export var stats_name := ""


## The actor's maximum stamina.
var stamina: int:
	get:
		_load_stats()
		return _stamina


## The actor's base attack power.
var attack: int:
	get:
		_load_stats()
		return _attack


var _stamina: int
var _attack: int

var _have_stats := false


func _load_stats() -> void:
	if _have_stats:
		return

	if stats_file.is_empty():
		push_error("'%s': stats_file required")
	elif stats_name.is_empty():
		push_error("'%s': stats_name required" % self.resource_path)
	else:
		var file := FileAccess.open(stats_file, FileAccess.READ)
		var found_stats := false
		while file.get_position() < file.get_length():
			var row := file.get_csv_line()
			if row[_Columns.NAME] == stats_name:
				_stamina = int(row[_Columns.STAMINA])
				_attack = int(row[_Columns.ATTACK])
				found_stats = true
				break
		if not found_stats:
			push_error("'%s': Could not find row with name '%s' in '%s'."
					% [self.resource_path, stats_name, stats_file])

		_have_stats = true
