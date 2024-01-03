@tool
class_name ScreenFade
extends CanvasLayer

const _ANIM_FADE_IN := "fade_in"
const _ANIM_FADE_OUT := "fade_out"

const _SHADER_DISSOLVE_PARAM := "dissolve_value"


@export var faded_in := false:
	set(value):
		faded_in = value

		var dissolve_value := 0.0
		if faded_in:
			dissolve_value = 1.0

		var shader_material := _color_rect.material as ShaderMaterial
		shader_material.set_shader_parameter(
				_SHADER_DISSOLVE_PARAM, dissolve_value)


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
