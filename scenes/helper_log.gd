extends Control

var world: World;

func _ready() -> void:
	world = self.get_parent();
	

func _process(delta: float) -> void:
	queue_redraw();

func _draw() -> void:
	var mouse_position = get_global_mouse_position();
	draw_string(SystemFont.new(), mouse_position, "{last_position} | {point_id}".format([["last_position", world.last_position], ["point_id", world.board.get_point(world.last_position)] ]) )  #str(world.last_position))
