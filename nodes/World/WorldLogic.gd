extends Node2D
class_name World

@onready var board: Board = $Board
@onready var astar_debug = $AstarDebug
@onready var line = $Line2D
@onready var character_manager: CharacterManager = $CharacterManager

# TODO: Vector 2 or null / change this when nullable available
var last_position = Vector2.ZERO;

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("enable_grid_cell_debug"):
		astar_debug.visible = !astar_debug.visible;
	if event.is_action_pressed("move_to_grid"):
		pass;

func round_pos(vec2: Vector2) -> Vector2:
	return (vec2 / Vector2(board.tile_set.tile_size)).floor() * Vector2(board.tile_set.tile_size)

func _physics_process(_delta: float) -> void:
	var mouse_position = get_global_mouse_position();
	var rounded: Vector2 = round_pos(mouse_position);
	if !(rounded == last_position):
		var point = board.get_point(rounded);
		if board.astar.has_point(point):
			last_position = rounded;
		else:
			last_position = null;
		update_line();

func update_line():
	if !(character_manager.id_selected_character >= 0) or !last_position: 
		line.points = [];
		return
	
	var player = character_manager.players[character_manager.id_selected_character];
	var player_position = player.global_position;
	var player_point = board.get_point(player_position);
	if board.astar.has_point(player_point):
		var result = board.get_astar_path(player_position, last_position, true, -1);
		board.astar_grid.draw_path(result.paths, result.error_paths );
