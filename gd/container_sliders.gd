extends VBoxContainer

const SLIDER := preload("res://tscn/slider_tarea.tscn")

const TAREAS := {
	"recolectoras": "RECOLECTORAS",
	"excavadoras": "EXCAVADORAS",
	"exploradoras": "EXPLORADORAS",
}

func _ready() -> void:
	var ociosas: SliderTarea = SLIDER.instantiate()
	add_child(ociosas)
	ociosas.configurar("ociosas", "OCIOSAS", false)
	
	for tarea in TAREAS:
		var s: SliderTarea = SLIDER.instantiate()
		add_child(s)
		s.configurar(tarea, TAREAS[tarea])
	
