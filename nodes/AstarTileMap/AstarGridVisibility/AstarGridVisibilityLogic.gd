extends Control
class_name AstarGrid;
@export var board: Board;
var route_positions: Array[Vector2] = [];
var error_positions: Array[Vector2] = [];

func draw_path(positions: Array[Vector2] = [], err_positions: Array[Vector2] = []) -> void:
    add_draw_paths(positions);
    add_error_paths(err_positions);
    queue_redraw();

func add_draw_paths(positions: Array[Vector2]) -> void:
    self.route_positions = get_valid_points(positions);

func add_error_paths(positions: Array[Vector2]) -> void:
    self.error_positions = get_valid_points(positions);

func get_valid_points(positions: Array[Vector2]) -> Array[Vector2]:
    if ( positions.size() == 0 ): return [];
    var _valid_positions: Array[Vector2] = [];
    for draw_position in positions:
        var pos_id = board.get_point(draw_position);
        if board.astar.has_point(pos_id):
            _valid_positions.append(draw_position);
    return _valid_positions;

func _draw() -> void:
	# if no position don't draw anything;
    if (route_positions.size() == 0 and error_positions.size() == 0): return;
    var tile_size = Vector2(board.tile_set.tile_size);
    var MARGIN = 20
    for route_pos in route_positions:
        var point_id = board.get_point(route_pos);
        if board.astar.is_point_disabled(point_id): continue;
        draw_rectangle(route_pos, Vector2(tile_size), Color.GRAY, 1, Vector2(MARGIN,MARGIN));

    for error_pos in error_positions:
        var point_id = board.get_point(error_pos);
        if board.astar.is_point_disabled(point_id): continue;
        draw_rectangle(error_pos, Vector2(tile_size), Color.RED, 1, Vector2(MARGIN,MARGIN));

func draw_rectangle(top_left_pos: Vector2, rect_size: Vector2, color: Color, width: int, margin: Vector2 = Vector2.ZERO) -> void:
    # top left to top right
    draw_line(
        top_left_pos + margin,
        top_left_pos + Vector2(rect_size.x, 0) + Vector2(-margin.x, margin.y),
        color, width);
    # bottom left to bottom right
    draw_line(
        top_left_pos + Vector2(0, rect_size.y) + Vector2(margin.x, -margin.y),
        top_left_pos + rect_size + Vector2(-margin.x, -margin.y),
        color, width
    );
	# top left to bottom left
    draw_line(
        top_left_pos + margin,
        top_left_pos + Vector2(0, rect_size.y) + Vector2(margin.x, -margin.y),
        color, width
    );
	# top right to bottom right
    draw_line(
        top_left_pos + Vector2(rect_size.x, 0) + Vector2(-margin.x, margin.y),
        top_left_pos + rect_size + Vector2(-margin.x, -margin.y),
        color, width
    );