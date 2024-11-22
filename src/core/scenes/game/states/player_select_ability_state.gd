class_name PlayerSelectAbilityState
extends State

## Player control state where the player is selecting an ability.

## The state for targeting an action.
@export var target_state: PlayerTargetState
## The state for standard player movement and attacks.
@export var movement_state: PlayerMovementState

## The ability menu.
@export var ability_menu: AbilityMenu

var _player: Actor


func enter(data := {}) -> void:
	_player = data.player

	@warning_ignore("return_value_discarded")
	_player.map.mouse_clicked.connect(_map_clicked)

	var icons: Array[Texture2D] = []
	for a in _player.abilities:
		icons.append(a.icon)

	ability_menu.position = _player.position + (
		Vector2(_player.tile_size * _player.cell_size)
		* Vector2(0.5, -0.5)
	)
	ability_menu.set_icons(icons)
	@warning_ignore("return_value_discarded")
	ability_menu.ability_clicked.connect(_ability_selected)
	ability_menu.open()


func exit() -> void:
	_player.map.mouse_clicked.disconnect(_map_clicked)
	ability_menu.ability_clicked.disconnect(_ability_selected)


func _ability_selected(index: int) -> void:
	await ability_menu.close()

	var ability := _player.abilities[index]
	var targeting_data := ability.get_target_data(_player)
	var initial_target := Vector2i.ZERO
	if targeting_data.has_targets:
		initial_target = targeting_data.targets[0]

	var data := {
		player = _player,
		ability = ability,
		targeting_data = targeting_data,
		initial_target = initial_target
	}
	request_state_change(target_state, data)


func _map_clicked(cell: Vector2i) -> void:
	if cell in _player.covered_cells:
		await ability_menu.close()
		request_state_change(movement_state, { player = _player })