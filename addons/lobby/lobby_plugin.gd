@tool
extends EditorPlugin

func _enter_tree():
	add_autoload_singleton("Lobby", "res://addons/lobby/lobby.gd")
	var setting = _Lobby._proj_sett

	var temp_texture: Texture2D = PlaceholderTexture2D.new()
	add_custom_project_setting(setting["root"] + setting["address"], "127.0.0.1", TYPE_STRING, PROPERTY_HINT_PLACEHOLDER_TEXT, "LocalHost")
	add_custom_project_setting(setting["root"] + setting["port"], 12345, TYPE_INT, PROPERTY_HINT_RANGE, "1024, 49151")
	add_custom_project_setting(setting["root"] + setting["max_players"], 20, TYPE_INT, PROPERTY_HINT_RANGE, "2,50,or_greater")
	add_custom_project_setting(setting["root"] + setting["icon_dim"], 192, TYPE_INT, PROPERTY_HINT_RANGE, "32,512,or_greater")
	add_custom_project_setting(setting["root"] + setting["upnp"], true, TYPE_BOOL)
	add_custom_project_setting(setting["root"] + setting["data_path"], "lobby.cfg", TYPE_STRING, PROPERTY_HINT_PLACEHOLDER_TEXT, "Relative to user://[root_name]/")
	add_custom_project_setting(setting["root"] + setting["data"], true, TYPE_BOOL)
	add_custom_project_setting(setting["root"] + setting["user_data"], {"name" = "", "color" = Color.WHITE, "icon" = null}, TYPE_DICTIONARY)


func _exit_tree():
	remove_autoload_singleton("Lobby")
	for setting in _Lobby._proj_sett.values():
		ProjectSettings.set_setting(_Lobby._proj_sett["root"] + setting, null)


func add_custom_project_setting(name: String, default_value, type: int, hint: int = PROPERTY_HINT_NONE, hint_string: String = "") -> void:
	if ProjectSettings.has_setting(name): return

	var setting_info: Dictionary = {
		"name": name,
		"type": type,
		"hint": hint,
		"hint_string": hint_string
	}

	ProjectSettings.set_setting(name, default_value)
	ProjectSettings.add_property_info(setting_info)
#	ProjectSettings.set_initial_value(name, default_value)
	ProjectSettings.set_as_basic(name, true)
