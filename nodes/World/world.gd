extends Node2D
class_name World

@onready var board: Board = $Layer0
@onready var astar_debug = $AstarDebug
@onready var line = $Line2D
@onready var character_manager: CharacterManager = $CharacterManager

var last_position := Vector2(0,0);

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("enable_grid_cell_debug"):
		astar_debug.visible = !astar_debug.visible;
	if event.is_action_pressed("move_to_grid"):
		pass;

func round_pos(vec2: Vector2) -> Vector2:
	return (vec2 / Vector2(board.tile_set.tile_size)).floor() * Vector2(board.tile_set.tile_size)

func _physics_process(delta: float) -> void:
	var mouse_position = get_global_mouse_position();
	var rounded: Vector2 = round_pos(mouse_position) + Vector2(board.tile_set.tile_size / 2);
	if !(rounded == last_position):
		var point = board.get_point(rounded);
		if board.astar.has_point(point):
			last_position = rounded;
			update_line();

func update_line():
	if character_manager.id_selected_character >= 0:
		var player = character_manager.players[character_manager.id_selected_character];
		var player_position = player.global_position + Vector2(board.tile_set.tile_size / 2)
		var player_point = board.get_point(player_position);
		if board.astar.has_point(player_point):
			var result = board.get_astar_path(player_position, last_position, true, -1);
			if result.error:
				# You can't reach the destination because there is a unit there!
				print('ERROR', result.error_path)
			line.position = Vector2.ZERO
			line.points = result.paths;
