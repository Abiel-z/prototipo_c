extends VBoxContainer

func _ready() -> void:
	var tema := Theme.new()
	tema.set_color("font_color", "Label", Color.BLACK)
	tema.set_font_size("font_size", "Label", 11)
	tema.set_constant("separation", "HBoxContainer", 4)
	tema.set_constant("separation", "VBoxContainer", 2)
	theme = tema

	size_flags_horizontal = Control.SIZE_EXPAND_FILL

	for nombre in ConfigManager.PERILLAS:
		var info: Dictionary = ConfigManager.PERILLAS[nombre]

		var fila := HBoxContainer.new()
		fila.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var label := Label.new()
		label.text = nombre
		label.custom_minimum_size.x = 100
		label.clip_text = true   # si el nombre no entra, se corta en vez de empujar

		var slider := HSlider.new()
		slider.min_value = info["min"]
		slider.max_value = info["max"]
		slider.step = (info["max"] - info["min"]) / 200.0
		slider.value = ConfigManager.get_perilla(nombre)
		slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		slider.custom_minimum_size.x = 40   # puede achicarse bastante

		var valor := Label.new()
		valor.custom_minimum_size.x = 42
		valor.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		valor.text = "%.3f" % slider.value

		slider.value_changed.connect(func(v: float):
			ConfigManager.set_perilla(nombre, v)
			valor.text = "%.3f" % v
		)

		fila.add_child(label)
		fila.add_child(slider)
		fila.add_child(valor)
		add_child(fila)
