extends Node

const COMIDA_LARVA := 0.05   # por larva por segundo
const COMIDA_ADULTA := 0.02  # por adulta por segundo

func _ready() -> void:
	TickManager.tick.connect(_on_tick)

func _on_tick(delta: float) -> void:
	var consumo := GameManager.get_value("larvas") * ConfigManager.get_perilla("comida_larva") * delta
	consumo += GameManager.get_adultas_total() * ConfigManager.get_perilla("comida_adulta") * delta
	GameManager.add_value("comida", -consumo)
