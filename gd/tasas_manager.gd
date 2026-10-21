extends Node

signal tasas_actualizadas

const PASO := 1.0       # cada cuántos segundos de juego se cierra una muestra
const VENTANA := 10.0   # cuántos segundos se promedian

var _ultimo := {}       # último valor visto de cada clave
var _ganado := {}       # acumulado de la muestra actual
var _perdido := {}
var _historial := {}    # clave -> Array de Vector2(ganado, perdido)
var _t := 0.0

func _ready() -> void:
	for clave in GameManager.valores:
		_ultimo[clave] = GameManager.valores[clave]
	GameManager.value_changed.connect(_on_value_changed)
	TickManager.tick.connect(_on_tick)

func _on_value_changed(nombre: String, valor: float) -> void:
	var dif : float = valor - _ultimo.get(nombre, 0.0)
	_ultimo[nombre] = valor
	if dif > 0.0:
		_ganado[nombre] = _ganado.get(nombre, 0.0) + dif
	elif dif < 0.0:
		_perdido[nombre] = _perdido.get(nombre, 0.0) + -dif

func _on_tick(delta: float) -> void:
	_t += delta
	if _t < PASO:
		return
	_t -= PASO

	var max_muestras := int(VENTANA / PASO)
	for clave in _ultimo:
		var h: Array = _historial.get(clave, [])
		h.append(Vector2(_ganado.get(clave, 0.0), _perdido.get(clave, 0.0)))
		if h.size() > max_muestras:
			h.pop_front()
		_historial[clave] = h
	_ganado.clear()
	_perdido.clear()
	tasas_actualizadas.emit()

# Neto por segundo (lo que muestras como "producción")
func get_tasa(clave: String) -> float:
	var h: Array = _historial.get(clave, [])
	if h.is_empty():
		return 0.0
	var neto := 0.0
	for m in h:
		neto += m.x - m.y
	return neto / (h.size() * PASO)

# Por si quieres un tooltip "+0.5 / -0.3"
func get_ganado(clave: String) -> float:
	return _suma(clave, "x")

func get_perdido(clave: String) -> float:
	return _suma(clave, "y")

func _suma(clave: String, eje: String) -> float:
	var h: Array = _historial.get(clave, [])
	if h.is_empty():
		return 0.0
	var total := 0.0
	for m in h:
		total += m[eje]
	return total / (h.size() * PASO)
