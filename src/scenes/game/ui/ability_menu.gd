class_name AbilityMenu
extends Node2D

const _START_ANGLE := (PI / 2.0) * 3
const _OPEN_TIME := 0.25
const _ANIM_EASING := Tween.EASE_OUT
const _ANIM_TRANS := Tween.TRANS_QUINT

signal ability_clicked(index: int)

@export var max_radius := 20


func _ready() -> void:
	visible = false


func set_icons(icons: Array[Texture2D]) -> void:
	_clear()
	for i in range(icons.size()):
		_create_button(i, icons[i])


func open() -> void:
	visible = true
	@warning_ignore("redundant_await")
	var tween := get_tree().create_tween() \
		.tween_method(_set_button_position, 0, max_radius, _OPEN_TIME) \
		.set_ease(_ANIM_EASING).set_trans(_ANIM_TRANS)
	await tween.finished


func close() -> void:
	@warning_ignore("redundant_await")
	var tween := get_tree().create_tween() \
		.tween_method(_set_button_position, max_radius, 0, _OPEN_TIME) \
		.set_ease(_ANIM_EASING).set_trans(_ANIM_TRANS)
	await tween.finished
	visible = false


func _clear() -> void:
	while get_child_count() > 0:
		var button_pos := get_child(0)
		remove_child(button_pos)
		button_pos.free()


func _create_button(index: int, icon: Texture2D) -> void:
	var pivot := Node2D.new()
	add_child(pivot)

	var button := Button.new()
	pivot.add_child(button)

	button.icon = icon
	button.set_anchors_and_offsets_preset(
			Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)

	@warning_ignore("return_value_discarded")
	button.pressed.connect(ability_clicked.emit.bind(index))


func _set_button_position(radius: float) -> void:
	if get_child_count() > 0:
		var angle_size := TAU / get_child_count()

		for i in range(get_child_count()):
			var angle := _START_ANGLE + (angle_size * i)
			var pivot_pos := Vector2.from_angle(angle) * radius
			var pivot := get_child(i) as Node2D
			pivot.position = pivot_pos
