extends Node

var _prog_vejez := 0.0
var _prog_hambre_larva := 0.0
var _prog_hambre_adulta := 0.0

const TAREAS := ["recolectoras", "excavadoras", "exploradoras"]


func _ready() -> void:
	TickManager.tick.connect(_on_tick)

func _on_tick(delta: float) -> void:
	var adultas := GameManager.get_adultas_total()
	var larvas := GameManager.get_value("larvas")
	var sin_comida := GameManager.get_value("comida") <= 0.0

	# Vejez: cada adulta vive "vida_adulta" segundos en promedio
	_prog_vejez += adultas / ConfigManager.get_perilla("vida_adulta") * delta
	_prog_vejez = _morir_adultas(_prog_vejez, "vejez")

	# Hambre: solo si la despensa está vacía
	if sin_comida:
		_prog_hambre_larva += larvas * ConfigManager.get_perilla("hambre_larva") * delta
		_prog_hambre_larva = _morir_larvas(_prog_hambre_larva)
		_prog_hambre_adulta += adultas * ConfigManager.get_perilla("hambre_adulta") * delta
		_prog_hambre_adulta = _morir_adultas(_prog_hambre_adulta, "hambre")
	else:
		_prog_hambre_larva = 0.0
		_prog_hambre_adulta = 0.0

	_muertes_por_riesgo(delta)


func _muertes_por_riesgo(delta: float) -> void:
	for tarea in TAREAS:
		var pool := int(GameManager.get_value(tarea))
		if pool <= 0:
			continue
		var esperado := pool * GameManager.get_riesgo(tarea) * delta / 60.0
		var n := int(esperado)
		if randf() < esperado - n:
			n += 1
		GameManager.matar(tarea, n, "riesgo")


func _morir_larvas(progreso: float) -> float:
	var n := int(floorf(progreso))
	if n >= 1:
		progreso -= GameManager.matar("larvas", n, "hambre")
	return progreso


func _morir_adultas(progreso: float, causa: String) -> float:
	var n := int(floorf(progreso))
	while n >= 1:
		var origen := _fuente_de_muerte()
		if origen == "":
			return 0.0   # no quedan adultas
		var muertas := GameManager.matar(origen, n, causa)
		if muertas <= 0:
			return 0.0   # seguro contra bucle infinito
		progreso -= muertas
		n -= muertas
	return progreso


# Ociosas primero, luego la tarea con más hormigas
func _fuente_de_muerte() -> String:
	if GameManager.get_value("ociosas") >= 1.0:
		return "ociosas"
	var mejor := ""
	var mejor_n := 0.0
	for t in TAREAS:
		var n := GameManager.get_value(t)
		if n > mejor_n:
			mejor_n = n
			mejor = t
	return mejor
