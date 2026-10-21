extends Node

const TAREAS := ["recolectoras", "excavadoras", "exploradoras"]

var _prog_sale := {}
var _prog_entra := {}

func _ready() -> void:
	for t in TAREAS:
		_prog_sale[t] = 0.0
		_prog_entra[t] = 0.0
	TickManager.tick.connect(_on_tick)

func _on_tick(delta: float) -> void:
	for t in TAREAS:
		_procesar_salida(t, delta)
		_procesar_entrada(t, delta)

func _procesar_salida(t: String, delta: float) -> void:
	var real := GameManager.get_value(t)
	var objetivo := GameManager.get_objetivo(t)
	var tasa :float= real * ConfigManager.get_perilla("tasa_abandono") + maxf(real - objetivo, 0.0) * ConfigManager.get_perilla("tasa_libera")
	_prog_sale[t] += tasa * delta

	var n := mini(int(floorf(_prog_sale[t])), int(real))
	if n >= 1:
		GameManager.add_value(t, -n)
		GameManager.add_value("ociosas", n)
		_prog_sale[t] -= n

func _procesar_entrada(t: String, delta: float) -> void:
	var real := GameManager.get_value(t)
	var objetivo := GameManager.get_objetivo(t)
	if objetivo <= 0.0:
		return
	var deficit := clampf((objetivo - real) / objetivo, 0.0, 1.0)
	var ociosas := GameManager.get_value("ociosas")
	_prog_entra[t] += ociosas * ConfigManager.get_perilla("tasa_recluta") * deficit * delta

	var n := mini(int(floorf(_prog_entra[t])), int(ociosas))
	if n >= 1:
		GameManager.add_value("ociosas", -n)
		GameManager.add_value(t, n)
		_prog_entra[t] -= n
