extends Node2D
class_name CharacterManager;


signal change_selected_character(id: int);
signal on_change_selected_character(id: int);
signal on_update_characters;

var players: Array[PlayableCharacter] = [];
var id_selected_character: int = -1;

func _ready() -> void:
	change_selected_character.connect(_change_selected_character);
	for child_node in get_children():
		if child_node is PlayableCharacter:
			players.append(child_node);
	on_update_characters.emit();
	if players.size() >= 1: 
		id_selected_character = 0;
		change_selected_character.emit(id_selected_character);

func _change_selected_character(id: int) -> void:
	id_selected_character = id;
	on_change_selected_character.emit(id);

func _input(event: InputEvent) -> void:
	if event.is_action("move_to_grid"):
		print('move to grid!');
