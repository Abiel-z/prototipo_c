extends Node

var _progreso := 0.0

func _ready() -> void:
	TickManager.tick.connect(_on_tick)

func _on_tick(delta: float) -> void:
	_progreso += GameManager.get_value("reinas") * ConfigManager.get_perilla("postura_reina") * delta
	var huevos := floorf(_progreso)
	if huevos >= 1.0:
		GameManager.add_value("huevos", huevos)
		_progreso -= huevos
