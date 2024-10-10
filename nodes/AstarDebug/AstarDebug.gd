extends Control

var world: World;
@export var board: Board;
@onready var astar: AStar2D = board.astar if board else null;

func _ready() -> void:
	world = board.get_parent();
	board.camera.on_camera_change.connect(queue_redraw);

func position_has_obstacle(pos: Vector2):
	return board.position_has_obstacle(pos);

func _draw() -> void:
	if not astar is AStar2D: return
	var offset: Vector2 = Vector2( board.tile_set.tile_size / 2) - global_position;
	for point_id in astar.get_point_ids():
		if astar.is_point_disabled(point_id): continue;
		var point_position: Vector2 = astar.get_point_position(point_id);
		if position_has_obstacle(point_position): continue;
		draw_circle(point_position + offset, 4, Color.WHITE, false, 4, true);
		var point_connections: PackedInt64Array = astar.get_point_connections(point_id);
		var connected_positions = []
		for connected_point in point_connections:
			if astar.is_point_disabled(connected_point): continue;
			var connected_point_position = astar.get_point_position(connected_point);
			if position_has_obstacle(connected_point_position): continue;
			connected_positions.append(connected_point_position)
		
		for connected_poistion in connected_positions:
			draw_line(point_position + offset, connected_poistion + offset, Color.WHITE, 2, true);

	var mouse_position = get_global_mouse_position();
	if world.last_position:
		draw_string(SystemFont.new(), mouse_position - global_position, "{last_position} | {point_id}".format([["last_position", world.last_position], ["point_id", world.board.get_point(world.last_position)] ]) )  #str(world.last_position))

func _process(_delta: float) -> void:
	queue_redraw();
