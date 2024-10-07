extends BoxContainer


@onready var text_of_placeholder = $TextureRect;
@export var slot_type = SLOT_TYPE.NECKLACE;

func _ready() -> void:
	# text_of_placeholde
	text_of_placeholder.modulate.a = 0.5;
	print(CharacterInfo.get_equipment(self.slot_type).get_name());
