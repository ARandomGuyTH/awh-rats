extends Node
## Autoload (Project Settings -> Globals -> Autoload, Node Name: "Settings")

signal settings_changed

const SAVE_PATH := "user://settings.cfg"

# Same order as the ResolutionOption items in the options menu
const RESOLUTIONS := [
	Vector2i(1920, 1080),
	Vector2i(1600, 900),
	Vector2i(1280, 720),
]

var settings := {
	"video": {
		"fullscreen": true,
		"borderless": false,
		"resolution_index": 0,
		"target_fps": 60	# 30, 60, 120, 0 (uncapped)
	},
	"audio": {
		"master_volume": 1.0,
		"music_volume": 0.8,
		"sfx_volume": 1.0,
		"mute": false
	},
	"controls": {
		"p1_device": 0,	# 0 - Keyboard, 1 - Joystick
		"p2_device": 0,
		"p1_binds": {
			"p1_left": KEY_A,
			"p1_right": KEY_D,
			"p1_up": KEY_W,
			"p1_interact": KEY_E
		},
		"p2_binds": {
			"p2_left": KEY_LEFT,
			"p2_right": KEY_RIGHT,
			"p2_up": KEY_UP,
			"p2_interact": KEY_SLASH
		}
	},
	"accessibility": {
		"screen_shake_enabled": true,
		"player_indicators_visible": true,
		"jump_window_multiplier": 1.0	# 1.0 - normal, 1.5 - +50% jump tolerance
	}
}

# Pristine copy for "Reset to Defaults"
var _defaults := {}


func _ready() -> void:
	_defaults = settings.duplicate(true)
	load_settings()
	apply_settings()


# ---------- Save / Load ----------

func save_settings() -> void:
	var cfg := ConfigFile.new()
	for section in settings:
		for key in settings[section]:
			cfg.set_value(section, key, settings[section][key])
	var err := cfg.save(SAVE_PATH)
	if err != OK:
		push_warning("Could not save settings: %s" % error_string(err))


func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return  # first launch: keep defaults
	for section in settings:
		for key in settings[section]:
			# Falls back to the current value if the key is missing
			settings[section][key] = cfg.get_value(section, key, settings[section][key])


func reset_to_defaults() -> void:
	settings = _defaults.duplicate(true)
	apply_settings()
	save_settings()


# ---------- Apply ----------

func apply_settings() -> void:
	_apply_video()
	_apply_audio()
	_apply_controls()
	settings_changed.emit()


# Apply only one section (avoids resetting the window while dragging a slider)
func apply_section(section: String) -> void:
	match section:
		"video": _apply_video()
		"audio": _apply_audio()
		"controls": _apply_controls()
	settings_changed.emit()


func _apply_video() -> void:
	var v: Dictionary = settings["video"]
	var window := get_window()

	window.borderless = v["borderless"]
	if v["fullscreen"]:
		window.mode = Window.MODE_EXCLUSIVE_FULLSCREEN
	else:
		window.mode = Window.MODE_WINDOWED
		var res: Vector2i = RESOLUTIONS[clampi(v["resolution_index"], 0, RESOLUTIONS.size() - 1)]
		window.size = res
		var screen := DisplayServer.screen_get_size()
		window.position = (screen - res) / 2

	Engine.max_fps = v["target_fps"]  # 0 = uncapped


func _apply_audio() -> void:
	var a: Dictionary = settings["audio"]
	_set_bus_volume("Master", a["master_volume"])
	_set_bus_volume("Music", a["music_volume"])
	_set_bus_volume("SFX", a["sfx_volume"])
	var master := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(master, a["mute"])


func _set_bus_volume(bus_name: String, linear: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx == -1:
		return  # bus doesn't exist (create it in the Audio panel)
	AudioServer.set_bus_volume_db(idx, linear_to_db(linear))


func _apply_controls() -> void:
	for player in ["p1_binds", "p2_binds"]:
		var binds: Dictionary = settings["controls"][player]
		for action in binds:
			_rebind_key(action, binds[action])


func _rebind_key(action: String, keycode: int) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	# Only remove keyboard events so gamepad events set in the Input Map survive
	for e in InputMap.action_get_events(action):
		if e is InputEventKey:
			InputMap.action_erase_event(action, e)
	var ev := InputEventKey.new()
	ev.physical_keycode = keycode as Key
	InputMap.action_add_event(action, ev)


# ---------- Used by the options menu and gameplay ----------

func set_setting(section: String, key: String, value) -> void:
	settings[section][key] = value
	apply_section(section)
	save_settings()


func get_setting(section: String, key: String):
	return settings[section][key]
