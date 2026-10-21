class_name FilaRecurso
extends HBoxContainer
 
@onready var label_titulo: Label = $TITULO
@onready var label_cantidad: Label = $CANTIDAD
@onready var label_produccion: Label = $PRODUCCION

var clave := ""

# Llamar DESPUÉS de add_child(), si no los @onready aún son null
func configurar(p_clave: String, p_titulo: String) -> void:
	clave = p_clave
	label_titulo.text = p_titulo
	set_cantidad(GameManager.get_value(clave))
	set_produccion(0.0)
	GameManager.value_changed.connect(_on_value_changed)
	TasasManager.tasas_actualizadas.connect(_on_tasas)

func _on_tasas() -> void:
	set_produccion(TasasManager.get_tasa(clave))

func set_cantidad(valor: float) -> void:
	label_cantidad.text = str(int(valor))

func set_produccion(por_segundo: float) -> void:
	label_produccion.text = "%+.1f/s" % por_segundo

func _on_value_changed(nombre: String, valor: float) -> void:
	if nombre == clave:
		set_cantidad(valor)
