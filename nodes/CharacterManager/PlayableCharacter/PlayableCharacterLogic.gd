extends CharacterBody2D
class_name PlayableCharacter

@onready var character_manager: CharacterManager = get_parent();
@export var movement_speed: float = 100.0;

var path_to_move: Array[Vector2] = [];
var current_direction: int = 0;
var is_movement_in_progress: bool = false;
 
func move_character(path: Array[Vector2]) -> void:
	path_to_move = path;
	current_direction = 0;
	is_movement_in_progress = path.size() > 0;
	character_manager.action_in_progress.on_action_end.emit();

func _physics_process(delta: float) -> void:
	if is_movement_in_progress:
		var dir = path_to_move[current_direction];
		global_position = global_position.move_toward(dir, delta * movement_speed);
		if (global_position == dir):
			var point_id = character_manager.board.get_point(path_to_move[current_direction]);
			global_position = character_manager.board.astar.get_point_position(point_id);
			current_direction = current_direction + 1;
			
			if current_direction == path_to_move.size():
				is_movement_in_progress = false;
