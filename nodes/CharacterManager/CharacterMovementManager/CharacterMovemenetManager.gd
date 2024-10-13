extends CharacterAction
class_name CharacterMovementManager;

@onready var character_manager: CharacterManager = get_parent();
@export var board: Board;

var last_position = Vector2.ZERO;
var is_movement_in_progress: bool = false;

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_to_grid"):
		move_to_grid();

func round_position(pos: Vector2) -> Vector2:
	return (pos / Vector2(board.tile_set.tile_size)).floor() * Vector2(board.tile_set.tile_size);

func _physics_process(_delta: float) -> void:
	if is_movement_in_progress: return;
	track_mouse_to_draw_path();

func track_mouse_to_draw_path():
	var mouse_position = get_global_mouse_position();
	var rounded_mouse_position = round_position(mouse_position);
	if rounded_mouse_position == last_position: return;
	var point = board.get_point(rounded_mouse_position);
	if board.astar.has_point(point):
		last_position = rounded_mouse_position;
	else:
		last_position = null;
	update_grid_visibility();

func update_grid_visibility():
	var char_id: int = character_manager.id_selected_character;
	if (char_id < 0 or !last_position):
		board.astar_grid.draw_path([],[]);
	else:
		var player: PlayableCharacter = character_manager.get_selected_character();
		var player_position: Vector2 = player.global_position;
		var player_point_id: int = board.get_point(player_position);
		if board.astar.has_point(player_point_id):
			var result = board.get_astar_path(player_position, last_position, true, -1);
			board.astar_grid.draw_path(result.paths, result.error_paths);

func move_to_grid():
	if !last_position or is_movement_in_progress: return;
	var player_id: int = character_manager.id_selected_character;
	if (player_id < 0): return;
	is_movement_in_progress = true;
	var player: PlayableCharacter = character_manager.get_selected_character();
	var player_position = player.global_position;
	var p_id = board.get_point(player_position);
	if board.astar.has_point(p_id):
		var astar_path: Board.AstarPathResult = board.get_astar_path(player_position, last_position, true, -1);
		if astar_path.error_paths.size() != 0:
			print("You can't move here!");
			is_movement_in_progress = false;
			return;

		if astar_path.paths.size() == 0:
			print("You are not moving nowhere!");
			is_movement_in_progress = false;
			return;
		
		character_manager.set_action_in_progress(self);
		move_selected_character(astar_path.paths);
	else:
		is_movement_in_progress = false;

func move_selected_character(path: Array[Vector2]) -> void:
	var selected_character: PlayableCharacter = character_manager.get_selected_character();
	if !selected_character:
		printerr("No selected character when try to move??")
		return;
	selected_character.move_character(path);
	on_action_start.emit();