class_name PlayerSelectAbilityState
extends PlayerState

## Player control state where the player is selecting an ability.

## The state for targeting an action.
@export var target_state: PlayerTargetState
## The state for standard player movement and attacks.
@export var movement_state: PlayerMovementState

@onready var _ability_menu := $AbilityMenu as AbilityMenu


func _ready() -> void:
	@warning_ignore("return_value_discarded")
	_ability_menu.ability_clicked.connect(_ability_selected)
	_ability_menu.visible = false


func enter() -> void:
	var icons: Array[Texture2D] = []
	for a in player_actor.abilities:
		icons.append(a.icon)

	_ability_menu.position = player_actor.position + (
		Vector2(player_actor.tile_size * player_actor.cell_size)
		* Vector2(0.5, -0.5)
	)
	_ability_menu.set_icons(icons)

	_ability_menu.open()


func _ability_selected(index: int) -> void:
	await _ability_menu.close()

	var ability := player_actor.abilities[index]

	game_control.set_ability_data(ability, player_actor.origin_cell)
	request_state_change(target_state)


func handle_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("click"):
		var cell := player_actor.map.mouse_cell
		if cell in player_actor.covered_cells:
			await _ability_menu.close()
			request_state_change(movement_state)
