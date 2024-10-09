extends PanelContainer
class_name AvailableCharacterItem

@onready var character_name_label: Label = $MarginContainer/VBoxContainer/Label;

var character_name: String;
var character_id: int;
var is_selected: bool = false;

@onready var select_btn: Button = $MarginContainer/VBoxContainer/Button;
@onready var character_list: AvailableCharactersList = self.get_parent();

func set_character_name(new_name: String) -> void:
	character_name = new_name;
	character_name_label.text = new_name;
	
func set_character_id(id: int) -> void:
	character_id = id;
	check_selected();

func _ready() -> void:
	character_list.character_manager.on_change_selected_character.connect(_on_change_selected_character);
	check_selected();

func _on_change_selected_character() -> void:
	check_selected();

func check_selected() -> void:
	set_selected(character_list.character_manager.id_selected_character == character_id);

func set_selected(value: bool) -> void:
	is_selected = value;
	select_btn.modulate = Color.GREEN if value else Color.RED;

func _on_select_button_up() -> void:
	character_list.character_manager.change_selected_character.emit(character_id);
	
