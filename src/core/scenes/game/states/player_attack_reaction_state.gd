class_name PlayerAttackReactionState
extends State

signal attack_reaction_chosen

@export var target_display: TargetDisplay

var _player: Actor
var _aoe: Array[Vector2i] = []
var _dodge_range: Array[Vector2i] = []

func enter(data := {}) -> void:
	_player = data.player
	_aoe = data.aoe
	#var attack_power = data.attack_power
	#var source_rect = data.source_rect

	@warning_ignore("return_value_discarded")
	_player.map.mouse_clicked.connect(_map_clicked)

	_dodge_range.clear()
	@warning_ignore("untyped_declaration")
	for d in [Vector2i.UP, Vector2i.LEFT, Vector2i.DOWN, Vector2i.RIGHT]:
		@warning_ignore("unsafe_call_argument")
		var next_cell := _player.origin_cell + Vector2i(d)
		if _player.map.actor_can_enter_cell(_player, next_cell):
			_dodge_range.append(next_cell)
	target_display._map_target_range.set_target_range(_dodge_range, _dodge_range)

	target_display._map_target_range.set_aoe(_aoe)


func exit() -> void:
	target_display.clear()
	_player.map.mouse_clicked.disconnect(_map_clicked)
	_player = null
	_aoe.clear()
	_dodge_range.clear()


func _map_clicked(cell: Vector2i) -> void:
	if _player.covers_cell(cell):
		attack_reaction_chosen.emit()
	elif cell in _dodge_range:
		await _player.move_step(cell)
		attack_reaction_chosen.emit()
