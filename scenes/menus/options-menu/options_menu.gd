extends Control
## Attach to the root Control of options_menu.tscn.
## Every node below needs "Access as Unique Name" (%) ticked in the Scene dock.

const MAIN_MENU_PATH := "res://scenes/menus/main-menu/mainMenu.tscn"
const FPS_VALUES := [30, 60, 120, 0]  # same order as FpsOption items (0 = uncapped)

# Names shown on the rebind buttons' labels
const ACTION_LABELS := {
	"p1_left": "Left", "p1_right": "Right", "p1_up": "Jump", "p1_interact": "Interact",
	"p2_left": "Left", "p2_right": "Right", "p2_up": "Jump", "p2_interact": "Interact",
}

# Video
@onready var fullscreen_check: CheckButton = %FullscreenCheck
@onready var borderless_check: CheckButton = %BorderlessCheck
@onready var resolution_option: OptionButton = %ResolutionOption
@onready var fps_option: OptionButton = %FpsOption

# Audio
@onready var master_slider: HSlider = %MasterSlider
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SfxSlider
@onready var master_label: Label = %MasterLabel
@onready var music_label: Label = %MusicLabel
@onready var sfx_label: Label = %SfxLabel
@onready var mute_check: CheckButton = %MuteCheck

# Controls
@onready var p1_device_option: OptionButton = %P1DeviceOption
@onready var p2_device_option: OptionButton = %P2DeviceOption
@onready var p1_binds_grid: GridContainer = %P1BindsGrid
@onready var p2_binds_grid: GridContainer = %P2BindsGrid

# Accessibility
@onready var shake_check: CheckButton = %ShakeCheck
@onready var indicators_check: CheckButton = %IndicatorsCheck
@onready var jump_slider: HSlider = %JumpSlider
@onready var jump_label: Label = %JumpLabel

# Bottom buttons
@onready var back_button: Button = %BackButton
@onready var reset_button: Button = %ResetButton
@onready var save_button: Button = %SaveButton

# Rebinding state
var _rebind_button: Button = null
var _rebind_player := ""   # "p1_binds" / "p2_binds"
var _rebind_action := ""


func _ready() -> void:
	_build_bind_buttons(p1_binds_grid, "p1_binds")
	_build_bind_buttons(p2_binds_grid, "p2_binds")
	_refresh_ui()
	_connect_signals()
	fullscreen_check.grab_focus()  # keyboard/gamepad navigation


# ---------- Show current settings in the widgets ----------

func _refresh_ui() -> void:
	# *_no_signal avoids firing change signals while we load values
	fullscreen_check.set_pressed_no_signal(Settings.get_setting("video", "fullscreen"))
	borderless_check.set_pressed_no_signal(Settings.get_setting("video", "borderless"))
	resolution_option.select(Settings.get_setting("video", "resolution_index"))
	fps_option.select(maxi(0, FPS_VALUES.find(Settings.get_setting("video", "target_fps"))))
	resolution_option.disabled = fullscreen_check.button_pressed

	master_slider.set_value_no_signal(Settings.get_setting("audio", "master_volume"))
	music_slider.set_value_no_signal(Settings.get_setting("audio", "music_volume"))
	sfx_slider.set_value_no_signal(Settings.get_setting("audio", "sfx_volume"))
	mute_check.set_pressed_no_signal(Settings.get_setting("audio", "mute"))
	_update_volume_labels()

	p1_device_option.select(Settings.get_setting("controls", "p1_device"))
	p2_device_option.select(Settings.get_setting("controls", "p2_device"))
	_refresh_bind_buttons()

	shake_check.set_pressed_no_signal(Settings.get_setting("accessibility", "screen_shake_enabled"))
	indicators_check.set_pressed_no_signal(Settings.get_setting("accessibility", "player_indicators_visible"))
	jump_slider.set_value_no_signal(Settings.get_setting("accessibility", "jump_window_multiplier"))
	_update_jump_label()


# ---------- Hook widgets up to Settings ----------

func _connect_signals() -> void:
	# Video
	fullscreen_check.toggled.connect(func(on: bool):
		Settings.set_setting("video", "fullscreen", on)
		resolution_option.disabled = on)
	borderless_check.toggled.connect(func(on: bool): Settings.set_setting("video", "borderless", on))
	resolution_option.item_selected.connect(func(i: int): Settings.set_setting("video", "resolution_index", i))
	fps_option.item_selected.connect(func(i: int): Settings.set_setting("video", "target_fps", FPS_VALUES[i]))

	# Audio: apply live while dragging, save to disk when released
	master_slider.value_changed.connect(func(v: float): _on_volume_changed("master_volume", v))
	music_slider.value_changed.connect(func(v: float): _on_volume_changed("music_volume", v))
	sfx_slider.value_changed.connect(func(v: float): _on_volume_changed("sfx_volume", v))
	for s in [master_slider, music_slider, sfx_slider, jump_slider]:
		s.drag_ended.connect(func(_changed: bool): Settings.save_settings())
	mute_check.toggled.connect(func(on: bool): Settings.set_setting("audio", "mute", on))

	# Controls
	p1_device_option.item_selected.connect(func(i: int): Settings.set_setting("controls", "p1_device", i))
	p2_device_option.item_selected.connect(func(i: int): Settings.set_setting("controls", "p2_device", i))

	# Accessibility
	shake_check.toggled.connect(func(on: bool): Settings.set_setting("accessibility", "screen_shake_enabled", on))
	indicators_check.toggled.connect(func(on: bool): Settings.set_setting("accessibility", "player_indicators_visible", on))
	jump_slider.value_changed.connect(func(v: float):
		Settings.settings["accessibility"]["jump_window_multiplier"] = v
		_update_jump_label())

	# Bottom buttons
	back_button.pressed.connect(_on_back_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	save_button.pressed.connect(_on_save_pressed)


func _on_volume_changed(key: String, value: float) -> void:
	Settings.settings["audio"][key] = value
	Settings.apply_section("audio")
	_update_volume_labels()


func _update_volume_labels() -> void:
	master_label.text = "%d%%" % roundi(master_slider.value * 100)
	music_label.text = "%d%%" % roundi(music_slider.value * 100)
	sfx_label.text = "%d%%" % roundi(sfx_slider.value * 100)


func _update_jump_label() -> void:
	jump_label.text = "%.1fx" % jump_slider.value


# ---------- Save / Back / Reset ----------

func _on_save_pressed() -> void:
	Settings.save_settings()
	# Brief visual confirmation
	save_button.text = "Saved!"
	await get_tree().create_timer(1.0).timeout
	save_button.text = "Save settings"


func _on_back_pressed() -> void:
	Settings.save_settings()
	Global.game_controller.change_ui_scene(MAIN_MENU_PATH)


func _on_reset_pressed() -> void:
	Settings.reset_to_defaults()
	_refresh_ui()


# ---------- Key rebinding ----------

func _build_bind_buttons(grid: GridContainer, player: String) -> void:
	for action in Settings.settings["controls"][player]:
		var label := Label.new()
		label.text = ACTION_LABELS.get(action, action)
		grid.add_child(label)

		var button := Button.new()
		button.name = action  # used by _refresh_bind_buttons
		button.custom_minimum_size.x = 160
		button.pressed.connect(_start_rebind.bind(button, player, action))
		grid.add_child(button)


func _refresh_bind_buttons() -> void:
	for pair in [[p1_binds_grid, "p1_binds"], [p2_binds_grid, "p2_binds"]]:
		var grid: GridContainer = pair[0]
		var binds: Dictionary = Settings.settings["controls"][pair[1]]
		for action in binds:
			var button: Button = grid.get_node(NodePath(action))
			button.text = OS.get_keycode_string(binds[action])


func _start_rebind(button: Button, player: String, action: String) -> void:
	if _rebind_button:  # cancel any previous pending rebind
		_refresh_bind_buttons()
	_rebind_button = button
	_rebind_player = player
	_rebind_action = action
	button.text = "Press a key..."


func _input(event: InputEvent) -> void:
	if _rebind_button == null:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		get_viewport().set_input_as_handled()
		if event.physical_keycode != KEY_ESCAPE:  # Escape cancels
			Settings.settings["controls"][_rebind_player][_rebind_action] = event.physical_keycode
			Settings.apply_section("controls")
			Settings.save_settings()
		_rebind_button = null
		_refresh_bind_buttons()
