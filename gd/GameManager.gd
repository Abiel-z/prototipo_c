extends Node

signal muerte_registrada(tarea: String, causa: String, n: int)
signal value_changed(nombre: String, valor: float)
signal pesos_cambiados

const CLAVES_ADULTAS := ["ociosas", "recolectoras", "excavadoras", "exploradoras"]


const EPSILON := 0.01

const INFO := {
	"huevos":       {"nombre": "Huevos",       "categoria": "colonia"},
	"larvas":       {"nombre": "Larvas",       "categoria": "colonia"},
	"pupas":        {"nombre": "Pupas",        "categoria": "colonia"},
	"hormigas":     {"nombre": "Hormigas",     "categoria": "colonia"},
	"ociosas":      {"nombre": "Ociosas",       "categoria": "tareas"},
	"recolectoras": {"nombre": "Recolectoras",  "categoria": "tareas"},
	"excavadoras":  {"nombre": "Excavadoras",   "categoria": "tareas"},
	"exploradoras": {"nombre": "Exploradoras",  "categoria": "tareas"},
	"comida":       {"nombre": "Comida",       "categoria": "almacen"},
}

var valores := {
	"reinas": 1.0,
	"huevos": 0.0,
	"larvas": 0.0,
	"pupas": 0.0,
	"ociosas": 0.0,
	"recolectoras": 0.0,
	"excavadoras": 0.0,
	"exploradoras": 0.0,
	"comida": 0.0,
}

var pesos := {
	"recolectoras": 50.0,
	"excavadoras": 25.0,
	"exploradoras": 25.0,
}

var mod_riesgo := {"exploradoras": 1.0, "recolectoras": 1.0, "excavadoras": 1.0}


func get_nombre(clave: String) -> String:
	return INFO.get(clave, {}).get("nombre", clave)

func get_claves_de(categoria: String) -> Array:
	var resultado := []
	for clave in INFO:
		if INFO[clave]["categoria"] == categoria:
			resultado.append(clave)
	return resultado

func get_value(nombre: String) -> float:
	if nombre == "hormigas":
		return get_adultas_total()
	return valores.get(nombre, 0.0)

func set_value(nombre: String, valor: float) -> void:
	valor = max(0.0, valor)
	if valor < EPSILON:
		valor = 0.0
	valores[nombre] = valor
	value_changed.emit(nombre, valor)
	if nombre in CLAVES_ADULTAS:
		value_changed.emit("hormigas", get_adultas_total())

func add_value(nombre: String, cantidad: float) -> void:
	set_value(nombre, get_value(nombre) + cantidad)

func get_peso(tarea: String) -> float:
	return pesos.get(tarea, 0.0)

func set_peso(tarea: String, valor: float) -> void:
	valor = clampf(valor, 0.0, 100.0)
	var resto := 100.0 - valor
	var suma_otros := 0.0
	for t in pesos:
		if t != tarea:
			suma_otros += pesos[t]

	for t in pesos:
		if t == tarea:
			continue
		if suma_otros > 0.0:
			pesos[t] = resto * pesos[t] / suma_otros
		else:
			pesos[t] = resto / (pesos.size() - 1)   # si los otros estaban en 0, repartir parejo

	pesos[tarea] = valor
	pesos_cambiados.emit()

func get_adultas_total() -> float:
	return valores.get("ociosas", 0.0) + valores.get("recolectoras", 0.0) \
		+ valores.get("excavadoras", 0.0) + valores.get("exploradoras", 0.0)

func get_reserva() -> float:
	return floorf(get_adultas_total() * ConfigManager.get_perilla("ociosidad"))

func registrar_muertes(causa: String, n: int) -> void:
	if n <= 0:
		return
	add_value("muertes_" + causa, n)
	add_value("muertes_total", n)

func matar(tarea: String, n: int, causa: String) -> int:
	n = mini(n, int(get_value(tarea)))
	if n <= 0:
		return 0
	add_value(tarea, -n)
	if tarea == "larvas":
		add_value("muertes_larvas", n)
	else:
		add_value("muertes_" + causa, n)
		add_value("muertes_total", n)
	muerte_registrada.emit(tarea, causa, n)
	return n

func get_objetivo(tarea: String) -> float:
	var utiles := get_adultas_total() - get_reserva()
	if tarea == "exploradoras":
		# absorbe el redondeo para que los objetivos sumen exactamente "utiles"
		var otros := 0.0
		for t in pesos:
			if t != "exploradoras":
				otros += floorf(utiles * pesos[t] / 100.0)
		return utiles - otros
	return floorf(utiles * pesos[tarea] / 100.0)

func get_riesgo(tarea: String) -> float:
	return ConfigManager.get_perilla("riesgo_" + tarea) \
		* ConfigManager.get_perilla("escala_riesgo") \
		* mod_riesgo[tarea]
