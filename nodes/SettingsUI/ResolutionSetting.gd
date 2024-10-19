extends Control

var fallback_option: Vector2i = Vector2i(1024, 768);

var RESOLUTION_LIST: Array[Vector2i] = [
    # 16:9
    Vector2i(2560, 1440),
    Vector2i(1920, 1080),
    Vector2i(1366, 768),
    Vector2i(1280, 720),
    # 16:10
    Vector2i(1920, 1200),
    Vector2i(1680, 1050),
    Vector2i(1440, 900),
    Vector2i(1280, 800),
    # 4:3
    Vector2i(1024, 768),
    Vector2i(800, 600),
    Vector2i(640, 480),
]

var WINDOW_MODE_LIST: Dictionary = {
    "Full Screen": DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN,
    "Borderless Window": DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN,
    "Windowed": DisplayServer.WindowMode.WINDOW_MODE_WINDOWED,
    "Windowed (Maximized)": DisplayServer.WindowMode.WINDOW_MODE_MAXIMIZED,
    "Windowed (Minimzed)": DisplayServer.WindowMode.WINDOW_MODE_MINIMIZED,
}

@export var res_options_bar: OptionButton;
@export var wind_mode_options_bar: OptionButton;

var current_option_res_ind = 0;
var current_option_wind_mode_ind = 0;

func sort_res(a: Vector2i, b: Vector2i) -> bool:
    if a.x > b.x:
        return true
    return false

func _ready() -> void:
    get_default_resolution();
    get_default_display_mode();

func get_default_display_mode() -> void:
    wind_mode_options_bar.clear();
    var i = 0;
    for key_label in WINDOW_MODE_LIST:
        wind_mode_options_bar.add_item(key_label);
        if DisplayServer.window_get_mode(DisplayServer.MAIN_WINDOW_ID) == WINDOW_MODE_LIST[key_label]:
            _on_display_type_selected(i)
            current_option_wind_mode_ind = i;
            wind_mode_options_bar.selected = i;
        i += 1;

func get_default_resolution() -> void:
    res_options_bar.clear();

    var screen_size: Vector2i = DisplayServer.screen_get_size();
    if screen_size not in RESOLUTION_LIST:
        RESOLUTION_LIST.append(screen_size);

    RESOLUTION_LIST.sort_custom(sort_res)

    var current_window_size: Vector2i = DisplayServer.window_get_size(DisplayServer.MAIN_WINDOW_ID);
    
    var index = -1;
    var fallback_index = -1;
    for option_index in RESOLUTION_LIST.size():
        var option = RESOLUTION_LIST[option_index];
        add_res_item("{x}x{y}".format([ ["x", option.x], ["y", option.y] ]));
        if current_window_size == option:
            index = option_index;
        if fallback_option == option:
            fallback_index = option_index
    
    if index == -1:
        if fallback_index > -1:
            res_options_bar.selected = fallback_index;
            current_option_res_ind = fallback_index;
            _on_resolution_selected(fallback_index);
        else:
            var last = RESOLUTION_LIST.size() - 1;
            res_options_bar.selected = last;
            current_option_res_ind = last;
            _on_resolution_selected(last);
    else:
        res_options_bar.selected = index;
        current_option_res_ind = index;
        _on_resolution_selected(index);

func add_res_item(label: String) -> void:
    res_options_bar.add_item(label);

func _on_display_type_selected(index:int) -> void:
    pass # Replace with function body.

func _on_resolution_selected(index:int) -> void:
    pass # Replace with function body.

func _on_revert_pressed() -> void:
    res_options_bar.selected = current_option_res_ind;
    wind_mode_options_bar.selected = current_option_wind_mode_ind;

func _on_apply_pressed() -> void:
    if current_option_res_ind != res_options_bar.selected:
        current_option_res_ind = res_options_bar.selected;
        DisplayServer.window_set_size(RESOLUTION_LIST[current_option_res_ind], DisplayServer.MAIN_WINDOW_ID);
        print('Updated resolution to ', RESOLUTION_LIST[current_option_res_ind]);
    if current_option_wind_mode_ind != wind_mode_options_bar.selected:
        current_option_wind_mode_ind = wind_mode_options_bar.selected;
        var label = wind_mode_options_bar.get_item_text(current_option_wind_mode_ind);
        DisplayServer.window_set_mode(WINDOW_MODE_LIST[label], DisplayServer.MAIN_WINDOW_ID);
        print('Updated window mode to ', label);