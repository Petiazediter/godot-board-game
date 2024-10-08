extends TileMapLayer
class_name Board;

@export var character_manager: CharacterManager;

const DIRECTIONS := [Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN]

var astar: AStar2D = AStar2D.new();
var obstacles: Array[Vector2] = [];
var unit_positions: Array[Vector2] = [];

func _ready() -> void:
	character_manager.on_update_characters.connect(update);
	update();

func update() -> void:
	create_pathfinding_points();
	register_units();

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
		var data: TileData = get_cell_tile_data(cell);
		var cell_position: Vector2 = global_position + map_to_local(cell);
		cell_positions.append(cell_position);
		if is_obstacle(data):
			obstacles.append(cell_position);
	return cell_positions;

func register_units():
	for player in character_manager.players:
		if player is PlayableCharacter:
			unit_positions.append(player.global_position + Vector2((tile_set.tile_size/2)));
	
func is_obstacle(cell_data: TileData): 
	return cell_data.get_custom_data("is_walkable") == false;

func position_has_obstacle(obstacle_position: Vector2, ignore_obstacle_position = null) -> bool:
	if obstacle_position == ignore_obstacle_position: return false
	for obstacle in obstacles:
		if obstacle == obstacle_position: return true
	return false
	
func position_has_unit(unit_position: Vector2, ignore_unit_position = null) -> bool:
	if unit_position == ignore_unit_position: return false
	for unit in unit_positions:
		if unit == unit_position: return true
	return false
	
func get_point(point_position: Vector2) -> int:
	var a := int(point_position.x)
	var b := int(point_position.y)
	return unique_number_from_two_int(a,b);

func unique_number_from_two_int(a: int,b: int):
	# source: https://en.wikipedia.org/wiki/Pairing_function
	return (a * a + a + (2 * (a * b)) + 3*b + b*b ) / 2

func connect_cardinals(center: int) -> void:
	var position = astar.get_point_position(center);
	for direction in DIRECTIONS:
		var position2 = direction * Vector2(tile_set.tile_size)
		var cardinal_point := get_point(position + position2)
		if cardinal_point != center and astar.has_point(cardinal_point):
			astar.connect_points(center, cardinal_point, true);

class AstarPathResult:
	var error: bool;
	var error_path: Vector2;
	var paths: Array;
	
	func _init(paths: Array, error: bool, error_path: Vector2) -> void:
		self.error = error;
		self.error_path = error_path;
		self.paths = paths;

func get_astar_path(from: Vector2, to: Vector2, should_avoid_obstacles: bool = true, steps: int = -1) -> AstarPathResult:
	if should_avoid_obstacles:
		set_disable_points_for_units(true, to);
		set_disable_points_for_obstacles(true);
	var astar_path = astar.get_point_path(get_point(from), get_point(to))
	set_disable_points_for_obstacles(false);
	set_disable_points_for_units(false, to);
	
	var paths: Array = set_path_length(astar_path, steps);
	var is_error: bool = false;
	var error_path: Vector2;
	
	if paths.size() > 0:
		if (position_has_unit(paths[paths.size() - 1])):
			is_error = true;
			error_path = to;
			paths.resize(paths.size() - 1);
	return AstarPathResult.new(paths,is_error,error_path);

func set_path_length(point_path: Array, max_distance: int) -> Array:
	if max_distance < 0: return point_path
	var new_size := int(min(point_path.size(), max_distance))
	point_path.resize(new_size)
	return point_path

func set_disable_points_for_obstacles(value: bool):
	for obstacle in obstacles:
		astar.set_point_disabled(get_point(obstacle), value);

func set_disable_points_for_units(value: bool, ignore_pos: Vector2):
	for unit in unit_positions:
		if unit != ignore_pos:
			astar.set_point_disabled(get_point(unit), value);
