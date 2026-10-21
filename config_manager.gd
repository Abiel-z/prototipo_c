extends Node

signal perilla_cambiada(nombre: String, valor: float)

# base, min, max (min/max solo sirven para el panel de debug)
const PERILLAS := {
	"ociosidad":        {"base": 0.4,  "min": 0.0,  "max": 1.0},
	"tasa_abandono":    {"base": 0.02, "min": 0.0,  "max": 0.2},
	"tasa_recluta":     {"base": 0.15, "min": 0.0,  "max": 1.0},
	"tasa_libera":      {"base": 0.30, "min": 0.0,  "max": 1.0},
	"postura_reina":    {"base": 0.5,  "min": 0.0,  "max": 5.0},
	"duracion_huevo":   {"base": 10.0, "min": 1.0,  "max": 120.0},
	"duracion_larva":   {"base": 30.0, "min": 1.0,  "max": 120.0},
	"duracion_pupa":    {"base": 20.0, "min": 1.0,  "max": 120.0},
	"comida_larva":     {"base": 0.05, "min": 0.0,  "max": 1.0},
	"comida_adulta":    {"base": 0.02, "min": 0.0,  "max": 1.0},
	"recoleccion":      {"base": 0.04, "min": 0.0,  "max": 1.0},
	"riesgo_exploradoras": {"base": 0.35, "min": 0.0, "max": 1.0},
	"riesgo_recolectoras": {"base": 0.20, "min": 0.0, "max": 1.0},
	"riesgo_excavadoras":  {"base": 0.10, "min": 0.0, "max": 1.0},
	"escala_riesgo":       {"base": 0.1,  "min": 0.0, "max": 1.0},
	"vida_adulta":     {"base": 300.0, "min": 10.0, "max": 3000.0},  # segundos promedio
	"hambre_larva":    {"base": 0.05,  "min": 0.0,  "max": 1.0},     # fracción/seg sin comida
	"hambre_adulta":   {"base": 0.01,  "min": 0.0,  "max": 1.0},
}

var _valores := {}   # lo que valen ahora

func _ready() -> void:
	for p in PERILLAS:
		_valores[p] = PERILLAS[p]["base"]

func get_perilla(nombre: String) -> float:
	return _valores.get(nombre, 0.0)

func set_perilla(nombre: String, valor: float) -> void:
	if not PERILLAS.has(nombre):
		push_warning("Perilla desconocida: " + nombre)
		return
	_valores[nombre] = valor
	perilla_cambiada.emit(nombre, valor)
