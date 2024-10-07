extends Node2D

# TODO: get the selected one from another manager maybe?
@export var player: PlayableCharacter;

func _input(event: InputEvent) -> void:
	if event.is_action("move_to_grid"):
		print('move to grid!');
		
