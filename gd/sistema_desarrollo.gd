extends Node

const DURACION_HUEVO := 10.0
const DURACION_LARVA := 30.0
const DURACION_PUPA := 20.0

# Progreso acumulado (0.0 a 1.0) de cada transición
var _prog_h_l := 0.0
var _prog_l_p := 0.0
var _prog_p_a := 0.0

func _ready() -> void:
	TickManager.tick.connect(_on_tick)

func _on_tick(delta: float) -> void:
	_prog_h_l = _avanzar("huevos", "larvas", ConfigManager.get_perilla("duracion_huevo"), _prog_h_l, delta)
	_prog_l_p = _avanzar("larvas", "pupas", ConfigManager.get_perilla("duracion_larva"), _prog_l_p, delta)
	_prog_p_a = _avanzar("pupas", "ociosas", ConfigManager.get_perilla("duracion_pupa"), _prog_p_a, delta)

func _avanzar(origen: String, destino: String, duracion: float, progreso: float, delta: float) -> float:
	var disponibles := floorf(GameManager.get_value(origen))
	if disponibles < 1.0:
		return 0.0   # no hay nada que mover, el progreso no se acumula

	# Cuánto progreso gana por tick: cada unidad tarda "duracion" en promedio,
	# y hay "disponibles" unidades avanzando en paralelo
	progreso += disponibles / duracion * delta

	var movidos := floorf(progreso)
	if movidos >= 1.0:
		movidos = minf(movidos, disponibles)
		GameManager.add_value(origen, -movidos)
		GameManager.add_value(destino, movidos)
		progreso -= movidos
	return progreso
