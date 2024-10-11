extends Node2D
class_name CharacterMovementManager;

@export var character_manager: CharacterManager;
@export var board: Board;

var last_position = Vector2.ZERO;

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("move_to_grid"):
        pass;

func round_position(pos: Vector2) -> Vector2:
    return (pos / Vector2(board.tile_set.tile_size)).floor() * Vector2(board.tile_set.tile_size);

func _physics_process(_delta: float) -> void:
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
        var player: PlayableCharacter = character_manager.players[char_id];
        var player_position: Vector2 = player.global_position;
        var player_point_id: int = board.get_point(player_position);
        if board.astar.has_point(player_point_id):
            var result = board.get_astar_path(player_position, last_position, true, -1);
            board.astar_grid.draw_path(result.paths, result.error_paths);
