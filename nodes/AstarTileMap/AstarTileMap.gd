extends TileMapLayer
class_name Board;

@export var camera: DraggableCamera;
@export var character_manager: CharacterManager;
@export var astar_grid: AstarGrid;

# PATH FINDING CONSTS

const CAN_LAND_ON_OTHER_UNIT = false;
const CAN_GO_THROUGH_OTHER_UNIT = true;

#####################

const DIRECTIONS := [Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN]

@export var shadow_board: BoardShadows;

# External change to listen to;
signal on_board_changed;
# Internal change to emit;
signal on_board_updated;

var astar: AStar2D = AStar2D.new();
var obstacles: Array[Vector2] = [];
var units: Array[Vector2] = [];
var dynamic_obstacles: Array[Vector2] = [];

func _ready() -> void:
	character_manager.on_update_characters.connect(update);
	update();
	on_board_changed.connect(update);

func update() -> void:
	create_pathfinding_points();
	register_units();
	register_obstacles();
	on_board_updated.emit();

func create_pathfinding_points() -> void:
	astar.clear()
	var used_cell_positions = get_used_cell_global_positions();
	for cell_position in used_cell_positions:
		astar.add_point(get_point(cell_position), cell_position);
	for id in astar.get_point_ids():
		connect_cardinals(id);

func get_used_cell_global_positions() -> Array[Vector2] :
	var cells: Array[Vector2i] = get_used_cells();
	var cell_positions : Array[Vector2] = [];
	for cell in cells:
		var cell_position: Vector2 = global_position + map_to_local(cell) - Vector2(tile_set.tile_size / 2);
		cell_positions.append(cell_position);
	return cell_positions;

func register_units():
	units.clear();
	for player in character_manager.players:
		if player is PlayableCharacter:
			units.append(player.global_position);
			var distance_coords = get_tiles_in_distance_from_map_pos(local_to_map(player.global_position), 2) as Array[Vector2]
			shadow_board.illuminate_tiles(distance_coords);

func register_obstacles():
	dynamic_obstacles.clear();
	obstacles.clear();

	for cell in get_used_cells():
		var data: TileData = get_cell_tile_data(cell);
		if is_obstacle(data):
			var cell_position: Vector2 = global_position + map_to_local(cell) - Vector2(tile_set.tile_size / 2);
			obstacles.append(cell_position);

	for dynamic_obstacle in get_children():
		if dynamic_obstacle is DynamicObstacle:
			dynamic_obstacles.append(dynamic_obstacle.global_position)

func is_obstacle(cell_data: TileData): 
	return cell_data.get_custom_data("is_walkable") == false;

func position_has_obstacle(obstacle_position: Vector2, ignore_obstacle_position = null) -> bool:
	if obstacle_position == ignore_obstacle_position: return false
	for obstacle in obstacles:
		if obstacle == obstacle_position: return true
	for dynamic_obstacle in dynamic_obstacles:
		if dynamic_obstacle == obstacle_position: return true
	return false
	
func position_has_unit(unit_position: Vector2, ignore_unit_position = null) -> bool:
	if unit_position == ignore_unit_position: return false
	for unit in units:
		if unit == unit_position: return true
	return false
	
func get_point(point_position: Vector2) -> int:
	var a := int(point_position.x)
	var b := int(point_position.y)
	return unique_number_from_two_int(a,b);

func unique_number_from_two_int(a: int,b: int) -> int:
	# source: https://en.wikipedia.org/wiki/Pairing_function
	return (a * a + a + (2 * (a * b)) + 3*b + b*b ) / 2

func connect_cardinals(center: int) -> void:
	var center_position = astar.get_point_position(center);
	for direction in DIRECTIONS:
		var neighbor_position = direction * Vector2(tile_set.tile_size)
		var cardinal_point := get_point(center_position + neighbor_position)
		if cardinal_point != center and astar.has_point(cardinal_point):
			astar.connect_points(center, cardinal_point, true);

class AstarPathResult:
	var error_paths: Array[Vector2];
	var paths: Array[Vector2];
	
	func _init(_paths: Array[Vector2],_error_paths: Array[Vector2]) -> void:
		self.error_paths = _error_paths;
		self.paths = _paths;

func get_astar_path(from: Vector2, to: Vector2, should_avoid_obstacles: bool = true, steps: int = -1, include_self: bool = false) -> AstarPathResult:
	if should_avoid_obstacles:
		set_disable_points_for_units(!CAN_GO_THROUGH_OTHER_UNIT, to);
		set_disable_points_for_obstacles(true);
		set_disable_points_for_dynamic_obstacles(true, to);
	var path: Array[Vector2] = []
	var astar_path = astar.get_point_path(get_point(from), get_point(to));
	for _path: Vector2 in astar_path:
		path.append(_path);

	set_disable_points_for_obstacles(false);
	set_disable_points_for_units(false, to);
	set_disable_points_for_dynamic_obstacles(false, to);
	
	return validate_path(path, steps, include_self);

func validate_path(point_path: Array[Vector2], max_distance: int, include_self: bool) -> AstarPathResult:
	# if selecting itself or nothing;
	if point_path.size() <= 1:
		return AstarPathResult.new([], []);

	var paths: Array[Vector2] = [];
	var error_paths: Array[Vector2] = [];
	for index in point_path.size():
		var path = point_path[index];
		# if we don't want to include the starting position;
		if !include_self and path == point_path[0]: continue;
		if ((index + 1) > max_distance and max_distance >= 0):
			error_paths.append(path);
		elif is_position_occupied(path):
			if position_has_unit(path):
				if (index == point_path.size()-1):
					if CAN_LAND_ON_OTHER_UNIT:
						paths.append(path);
					else:
						error_paths.append(path)
				elif !CAN_GO_THROUGH_OTHER_UNIT:
					error_paths.append(path)
				else:
					paths.append(path);
			else:
				error_paths.append(path)
		else: paths.append(path);
	return AstarPathResult.new(paths,error_paths);

func is_position_occupied(pos: Vector2):
	return (
		position_has_obstacle(pos) or
		position_has_unit(pos)
	)

func set_disable_points_for_obstacles(value: bool):
	for obstacle in obstacles:
		astar.set_point_disabled(get_point(obstacle), value);

func set_disable_points_for_dynamic_obstacles(value: bool, to: Vector2):
	for dynamic_obstacle in dynamic_obstacles:
		if dynamic_obstacle == to:
			for child in get_children():
				if child is DynamicObstacle:
					if child.global_position == dynamic_obstacle:
						if child.is_interactable:
							return;
		astar.set_point_disabled(get_point(dynamic_obstacle), value);

func set_disable_points_for_units(value: bool, ignore_pos: Vector2):
	for unit in units:
		if unit != ignore_pos:
			astar.set_point_disabled(get_point(unit), value);

func get_tiles_in_distance_from_map_pos(point_pos: Vector2, max_distance: int ):
	var positions = get_used_cells();
	var ret_val = []
	for cell in positions:
		var distance = sqrt(pow((cell.x - point_pos.x),2) + pow((cell.y - point_pos.y),2)) # dist = sqrt((x2-x1)^2 + (y2-y1)^2)
		# print(distance);
		if distance <= max_distance:
			ret_val.append(cell)
	return ret_val;
