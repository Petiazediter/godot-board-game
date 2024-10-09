extends Node2D
class_name DynamicObstacle

var is_destroyable: bool = false;
@onready var board: Board = self.get_parent();

func on_destroy() -> void:
    board.on_board_changed.emit();

func on_move(_new_position: Vector2) -> void:
    board.on_board_changed.emit();