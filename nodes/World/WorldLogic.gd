extends Node2D
class_name World

@onready var astar_debug = $Camera2D/AstarDebug;

func _ready() -> void:
	astar_debug.visible = false;

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("enable_grid_cell_debug"):
		astar_debug.visible = !astar_debug.visible;
