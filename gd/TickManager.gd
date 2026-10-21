extends Node

signal tick(delta: float)

const INTERVALO := 0.1        # segundos reales entre ticks

var velocidad := 1.0          # 1 = normal, 2 = doble, etc. (útil para debug)
var pausado := false

var _acumulado := 0.0

func _process(delta: float) -> void:
	if pausado:
		return
	_acumulado += delta
	while _acumulado >= INTERVALO:
		_acumulado -= INTERVALO
		tick.emit(INTERVALO * velocidad)
