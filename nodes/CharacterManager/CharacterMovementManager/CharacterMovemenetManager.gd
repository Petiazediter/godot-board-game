extends CharacterAction
class_name CharacterMovementManager;

@onready var character_manager: CharacterManager = get_parent();
@export var board: Board;
@export var character_movement_speed: float = 100;

var last_position = Vector2.ZERO;

func _ready() -> void:
	on_action_end.connect(_on_movement_ends);
	on_action_start.connect(_on_movement_start);

func _on_movement_ends() -> void:
	if character_manager.action_in_progress == self:
		character_manager.stop_current_action();
		character_manager.board.update();

func _on_movement_start() -> void:
	if character_manager.action_in_progress == self:
		board.astar_grid.draw_path([],[]);

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_to_grid"):
		move_to_grid();

func round_position(pos: Vector2) -> Vector2:
	return (pos / Vector2(board.tile_set.tile_size)).floor() * Vector2(board.tile_set.tile_size);

func _physics_process(_delta: float) -> void:
	if !character_manager.get_is_action_in_progress():
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
	if !last_position or character_manager.get_is_action_in_progress(): return;
	var player_id: int = character_manager.id_selected_character;
	if (player_id < 0): return;
	var player: PlayableCharacter = character_manager.get_selected_character();
	var player_position = player.global_position;
	var p_id = board.get_point(player_position);
	if board.astar.has_point(p_id):
		var astar_path: Board.AstarPathResult = board.get_astar_path(player_position, last_position, true, -1);
		if astar_path.error_paths.size() != 0:
			_on_movement_ends();
			return;

		if astar_path.paths.size() == 0:
			_on_movement_ends();
			return;
		
		character_manager.set_action_in_progress(self);
		move_selected_character(astar_path.paths);

func move_selected_character(path: Array[Vector2]) -> void:
	var selected_character: PlayableCharacter = character_manager.get_selected_character();
	if !selected_character:
		_on_movement_ends();
		return;
	selected_character.move_character(path);
	on_action_start.emit();