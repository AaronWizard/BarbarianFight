class_name PlayerSelectAbilityState
extends State

## Player control state where the player is selecting an ability.

## The state for targeting an action.
@export var target_state: PlayerTargetState
## The state for standard player movement and attacks.
@export var movement_state: PlayerMovementState

var _player: Actor

@onready var _ability_menu := $AbilityMenu as AbilityMenu


func _ready() -> void:
	@warning_ignore("return_value_discarded")
	_ability_menu.ability_clicked.connect(_ability_selected)
	_ability_menu.visible = false


func enter() -> void:
	_player = data.player

	var icons: Array[Texture2D] = []
	for a in _player.abilities:
		icons.append(a.icon)

	_ability_menu.position = _player.position + (
		Vector2(_player.tile_size * _player.cell_size)
		* Vector2(0.5, -0.5)
	)
	_ability_menu.set_icons(icons)

	_ability_menu.open()


func _ability_selected(index: int) -> void:
	await _ability_menu.close()

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


func handle_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("click"):
		var cell := _player.map.mouse_cell
		if cell in _player.covered_cells:
			await _ability_menu.close()
			request_state_change(movement_state, { player = _player })
