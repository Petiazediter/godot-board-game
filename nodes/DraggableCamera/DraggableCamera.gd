extends Camera2D
class_name DraggableCamera;

signal on_camera_change;
var is_feature_enabled = true;
var is_zoom_enabled = true;

var target_zoom: float = .8;

const MIN_ZOOM: float = .8;
const MAX_ZOOM: float = 1;
const ZOOM_INCREMENT: float = 0.1;

const ZOOM_RATE: float = 1;
@export var auto_focus_speed: float = 100;
var auto_move_target_position = null;

func _unhandled_input(event: InputEvent) -> void:
	if is_feature_enabled:
		if event is InputEventMouseMotion:
			if event.button_mask == MOUSE_BUTTON_MASK_MIDDLE:
				if auto_move_target_position == null:
					on_camera_change.emit();
					position -= event.relative * zoom;
		elif event is InputEventMouseButton and is_zoom_enabled:
			if event.is_pressed():
				if event.button_index == MOUSE_BUTTON_WHEEL_UP:
					zoom_out(); 
				elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
					zoom_in(); 

func zoom_in():
	target_zoom = max(target_zoom - ZOOM_INCREMENT, MIN_ZOOM);
	set_physics_process(true);

func zoom_out():
	target_zoom = min(target_zoom + ZOOM_INCREMENT, MAX_ZOOM);
	set_physics_process(true);

func _physics_process(delta: float) -> void:
	if !is_feature_enabled or !is_zoom_enabled : return set_physics_process(false);
	if auto_move_target_position != null:
		position = position.move_toward(auto_move_target_position, delta * auto_focus_speed);
		on_camera_change.emit();
		if position == auto_move_target_position:
			auto_move_target_position = null;
	else:
		on_camera_change.emit();
		zoom = lerp(
			zoom,
			target_zoom * Vector2.ONE,
			ZOOM_RATE * delta
		)
		on_camera_change.emit();
		set_physics_process(
			not is_equal_approx(zoom.x, target_zoom)
			)

func auto_focus(pos: Vector2) -> void:
	auto_move_target_position = pos;