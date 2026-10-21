extends Node

const RECOLECCION_POR_ADULTA := 0.04  # comida por adulta por segundo

func _ready() -> void:
	TickManager.tick.connect(_on_tick)

func _on_tick(delta: float) -> void:
	var recolectoras := GameManager.get_value("recolectoras")
	GameManager.add_value("comida", recolectoras * ConfigManager.get_perilla("recoleccion") * delta)
