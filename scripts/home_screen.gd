extends Control

# Rustaccordion home screen — compatible with Godot 4.
const SNOW_COUNT := 150
const MENU_WIDTH := 300.0

var snow: Array[Dictionary] = []
var sound_on := true
var language := "EN"
var sound_button: Button
var language_button: Button


func _ready() -> void:
	set_process(true)
	randomize()
	_make_snow()
	_make_menu()
	resized.connect(queue_redraw)
	queue_redraw()


func _make_snow() -> void:
	for number in SNOW_COUNT:
		snow.append({
			"point": Vector2(randf_range(0.0, size.x), randf_range(0.0, size.y)),
			"speed": randf_range(12.0, 36.0),
			"drift": randf_range(-7.0, 7.0),
			"radius": randf_range(0.4, 1.2),
			"wave": randf_range(0.0, TAU)
		})


func _make_menu() -> void:
	var menu := VBoxContainer.new()
	menu.set_anchors_preset(Control.PRESET_CENTER)
	menu.position = Vector2(-MENU_WIDTH / 2.0, -175.0)
	menu.size = Vector2(MENU_WIDTH, 360.0)
	menu.add_theme_constant_override("separation", 11)
	add_child(menu)

	var title := Label.new()
	title.text = "RUSTACCORDION"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 38)
	title.add_theme_color_override("font_color", Color("efefea"))
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	title.add_theme_constant_override("shadow_offset_x", 3)
	title.add_theme_constant_override("shadow_offset_y", 4)
	menu.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "A QUIET DESCENT"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 12)
	subtitle.add_theme_color_override("font_color", Color("b8b9b6"))
	menu.add_child(subtitle)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 22)
	menu.add_child(spacer)

	menu.add_child(_menu_button("PLAY", _play))
	menu.add_child(_menu_button("LEVELS", _levels))
	menu.add_child(_menu_button("SETTINGS", _settings))

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 10)
	menu.add_child(row)

	language_button = _small_button("LANGUAGE: EN", _switch_language)
	sound_button = _small_button("SOUND: ON", _switch_sound)
	row.add_child(language_button)
	row.add_child(sound_button)

	var footer := Label.new()
	footer.text = "© 2026  •  PRESS PLAY TO DESCEND"
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	footer.position = Vector2(-180, -42)
	footer.size = Vector2(360, 20)
	footer.add_theme_font_size_override("font_size", 10)
	footer.add_theme_color_override("font_color", Color(0.7, 0.7, 0.68, 0.55))
	add_child(footer)


func _menu_button(caption: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size = Vector2(MENU_WIDTH, 48)
	button.add_theme_font_size_override("font_size", 16)
	button.add_theme_color_override("font_color", Color("eeeeea"))
	button.add_theme_color_override("font_hover_color", Color("ffffff"))
	button.add_theme_color_override("font_pressed_color", Color("111111"))
	button.add_theme_stylebox_override("normal", _style(Color(0.06, 0.065, 0.065, 0.82), Color(0.7, 0.7, 0.67, 0.48)))
	button.add_theme_stylebox_override("hover", _style(Color(0.78, 0.79, 0.76, 0.95), Color("ffffff")))
	button.add_theme_stylebox_override("pressed", _style(Color("f2f2ed"), Color("ffffff")))
	button.pressed.connect(callback)
	return button


func _small_button(caption: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size = Vector2(145, 34)
	button.add_theme_font_size_override("font_size", 10)
	button.add_theme_color_override("font_color", Color("d8d8d4"))
	button.add_theme_color_override("font_hover_color", Color("ffffff"))
	button.add_theme_stylebox_override("normal", _style(Color(0.04, 0.045, 0.045, 0.84), Color(0.6, 0.6, 0.58, 0.45)))
	button.add_theme_stylebox_override("hover", _style(Color(0.22, 0.225, 0.22, 0.95), Color(0.85, 0.85, 0.81, 0.8)))
	button.pressed.connect(callback)
	return button


func _style(background: Color, border: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = background
	box.border_color = border
	box.set_border_width_all(1)
	box.set_corner_radius_all(3)
	return box


func _process(delta: float) -> void:
	for flake in snow:
		var position: Vector2 = flake["point"]
		flake["wave"] += delta
		position.y += flake["speed"] * delta
		position.x += (flake["drift"] + sin(flake["wave"] * 1.5) * 5.0) * delta
		if position.y > size.y + 3.0:
			position = Vector2(randf_range(0.0, size.x), -3.0)
		if position.x < -3.0:
			position.x = size.x + 3.0
		elif position.x > size.x + 3.0:
			position.x = -3.0
		flake["point"] = position
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("030404"))
	draw_rect(Rect2(Vector2.ZERO, Vector2(size.x, size.y * 0.55)), Color("0a0b0b"))

	# Jagged cave walls and shadowy foreground ledges.
	draw_colored_polygon(PackedVector2Array([Vector2(0, 0), Vector2(size.x * 0.19, 0), Vector2(size.x * 0.13, size.y * 0.17), Vector2(size.x * 0.22, size.y * 0.33), Vector2(size.x * 0.11, size.y * 0.52), Vector2(size.x * 0.17, size.y * 0.72), Vector2(size.x * 0.07, size.y), Vector2(0, size.y)]), Color("151716"))
	draw_colored_polygon(PackedVector2Array([Vector2(size.x, 0), Vector2(size.x * 0.79, 0), Vector2(size.x * 0.85, size.y * 0.18), Vector2(size.x * 0.76, size.y * 0.37), Vector2(size.x * 0.88, size.y * 0.55), Vector2(size.x * 0.81, size.y * 0.73), Vector2(size.x * 0.91, size.y), Vector2(size.x, size.y)]), Color("151716"))
	draw_colored_polygon(PackedVector2Array([Vector2(0, size.y * 0.80), Vector2(size.x * 0.22, size.y * 0.71), Vector2(size.x * 0.37, size.y), Vector2(0, size.y)]), Color("0b0c0c"))
	draw_colored_polygon(PackedVector2Array([Vector2(size.x, size.y * 0.78), Vector2(size.x * 0.79, size.y * 0.69), Vector2(size.x * 0.65, size.y), Vector2(size.x, size.y)]), Color("0b0c0c"))

	for flake in snow:
		var position: Vector2 = flake["point"]
		var radius: float = flake["radius"]
		draw_circle(position, radius * 2.0, Color(0.95, 0.96, 0.94, 0.14))
		draw_circle(position, radius, Color(0.95, 0.96, 0.94, 0.75))


func _play() -> void:
	print("Play selected")


func _levels() -> void:
	print("Levels selected")


func _settings() -> void:
	print("Settings selected")


func _switch_language() -> void:
	language = "FR" if language == "EN" else "EN"
	language_button.text = "LANGUAGE: " + language


func _switch_sound() -> void:
	sound_on = not sound_on
	sound_button.text = "SOUND: " + ("ON" if sound_on else "OFF")
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), not sound_on)
