class_name SliderTarea
extends VBoxContainer


@onready var label_titulo: Label = $Cabecera/Titulo
@onready var label_actual: Label = $Cabecera/Actual
@onready var label_esperado: Label = $Cabecera/Esperado
@onready var slider: HSlider = $Slider
@onready var barra_real: ProgressBar = $BarraReal

var tarea := ""
var tiene_slider := true

func configurar(p_tarea: String, p_titulo: String, p_con_slider := true) -> void:
	tarea = p_tarea
	tiene_slider = p_con_slider
	label_titulo.text = p_titulo

	if tiene_slider:
		slider.value = GameManager.get_peso(tarea)
		slider.value_changed.connect(_on_slider_cambiado)
		GameManager.pesos_cambiados.connect(_refrescar)
	else:
		slider.hide()   # o slider.queue_free() si no lo vas a necesitar nunca

	GameManager.value_changed.connect(_on_value_changed)
	_refrescar()

func _on_slider_cambiado(valor: float) -> void:
	GameManager.set_peso(tarea, valor)   # esto emite pesos_cambiados, que ya refresca

func _on_value_changed(nombre: String, _valor: float) -> void:
	# refrescar si cambia cualquier clave que afecte al total de adultas
	if nombre == "ociosas" or GameManager.pesos.has(nombre):
		_refrescar()

func _refrescar() -> void:
	var real := GameManager.get_value(tarea)
	var total := GameManager.get_adultas_total()
	label_actual.text = str(int(real))
	barra_real.value = (real / total * 100.0) if total > 0.0 else 0.0

	if tiene_slider:
		slider.set_value_no_signal(GameManager.get_peso(tarea))
		label_esperado.text = str(int(GameManager.get_objetivo(tarea)))
	else:
		label_esperado.text = ""   # ociosas no tiene objetivo
