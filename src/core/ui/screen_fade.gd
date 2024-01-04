@tool
class_name ScreenFade
extends CanvasLayer

const _ANIM_FADE_IN := "fade_in"
const _ANIM_FADE_OUT := "fade_out"

const _SHADER_DISSOLVE_PARAM := "dissolve_value"


@export var faded_in := true:
	set(value):
		faded_in = value

		if _color_rect:
			var shader_material := _color_rect.material as ShaderMaterial

			if faded_in:
				shader_material.set_shader_parameter(
						_SHADER_DISSOLVE_PARAM, 1.0)

				_color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			else:
				shader_material.set_shader_parameter(
						_SHADER_DISSOLVE_PARAM, 0.0)

				_color_rect.mouse_filter = Control.MOUSE_FILTER_STOP


@onready var _color_rect := $ColorRect as ColorRect
@onready var _animation_player := $AnimationPlayer as AnimationPlayer


func fade_in() -> void:
	faded_in = false
	_animation_player.play(_ANIM_FADE_IN)
	await _animation_player.animation_finished
	faded_in = true


func fade_out() -> void:
	faded_in = true
	_animation_player.play(_ANIM_FADE_OUT)
	await _animation_player.animation_finished
	faded_in = false
