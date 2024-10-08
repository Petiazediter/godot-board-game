extends HBoxContainer
class_name AvailableCharactersList;

@export var character_manager: CharacterManager;
var prefab = preload("res://nodes/AvailableCharacterList/AvailableCharacter/AvailableCharacterItem.tscn");

func _ready() -> void:
	draw_characters();
	
func draw_characters() -> void:
	for player_index in character_manager.players.size():
		var node = prefab.instantiate();
		if node is AvailableCharacterItem:
			add_child(node);
			node.set_character_name("Player {id}".format([ ["id", player_index ] ]));
			node.set_character_id(player_index);
