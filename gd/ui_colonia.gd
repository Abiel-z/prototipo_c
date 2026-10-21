extends VBoxContainer

const FILA := preload("res://tscn/fila_recurso.tscn")

# Menú de la colonia: solo huevos, larvas, pupas, hormigas
func _ready() -> void:
	for clave in GameManager.get_claves_de("colonia"):
		var fila: FilaRecurso = FILA.instantiate()
		add_child(fila)
		fila.configurar(clave, GameManager.get_nombre(clave))
