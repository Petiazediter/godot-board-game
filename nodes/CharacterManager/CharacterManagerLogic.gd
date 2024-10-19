extends Node2D
class_name CharacterManager;

@export var board: Board;
signal change_selected_character(id: int);
signal on_change_selected_character(id: int);
signal on_update_characters;

var action_in_progress = null;

var players: Array[PlayableCharacter] = [];
var id_selected_character: int = -1;
@export var character_movement_manager: CharacterMovementManager;
@export var main_camera: DraggableCamera;

@export var auto_focus_camera_on_char_change: bool = true;

func get_is_action_in_progress() -> bool:
	return action_in_progress != null;

func _ready() -> void:
	change_selected_character.connect(_change_selected_character);
	for child_node in get_children():
		if child_node is PlayableCharacter:
			players.append(child_node);
	on_update_characters.emit();
	if players.size() >= 1: 
		id_selected_character = 0;
		change_selected_character.emit(id_selected_character);

func get_selected_character() -> PlayableCharacter:
	return players[id_selected_character];

func _change_selected_character(id: int) -> void:
	id_selected_character = id;
	on_change_selected_character.emit();
	if auto_focus_camera_on_char_change:
		main_camera.auto_focus(players[id].position);

func on_current_action_start() -> void:
	print('An action is started!');

func on_current_action_over() -> void:
	stop_current_action();

func is_action_in_progess() -> bool:
	return action_in_progress is CharacterAction;

func set_action_in_progress(character_action: CharacterAction) -> void:
	stop_current_action();
	action_in_progress = character_action;
	action_in_progress.on_action_end.connect(on_current_action_over);
	action_in_progress.on_action_start.connect(on_current_action_start);

func stop_current_action():
	if action_in_progress:
		if action_in_progress is CharacterAction:
			if action_in_progress.on_action_end.is_connected(on_current_action_over):
				action_in_progress.on_action_end.disconnect(on_current_action_over);
			if action_in_progress.on_action_start.is_connected(on_current_action_start):
				action_in_progress.on_action_start.disconnect(on_current_action_start);
		action_in_progress = null;