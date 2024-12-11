extends Scene

@export_file("*.tscn") var main_menu_scene_path: String

@onready var _screen_fade := $ScreenFade as ScreenFade


func _ready() -> void:
	_screen_fade.fade_in()


func _on_main_menu_pressed() -> void:
	await _screen_fade.fade_out()
	switch_scene(main_menu_scene_path)
