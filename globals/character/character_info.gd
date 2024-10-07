extends Node

class EquipmentInnerClass:
	var type: int;
	var id: int;
	
	func _init(type: int, id: int) -> void:
		self.id = id;
		self.type = type;
		
	func get_name():
		if type == SLOT_TYPE.HELMET:
			return "Helmet";
		return "Unknown"

func get_equipments() -> Array[EquipmentInnerClass]:
	return [
		EquipmentInnerClass.new(SLOT_TYPE.HELMET, 1),
		EquipmentInnerClass.new(SLOT_TYPE.GLOVES, 2),
		EquipmentInnerClass.new(SLOT_TYPE.NECKLACE, 3)
	]
	
func get_equipment(slot: int) -> EquipmentInnerClass:
	return self.get_equipments().filter(func(equipment: EquipmentInnerClass): return equipment.type == slot)[0];
