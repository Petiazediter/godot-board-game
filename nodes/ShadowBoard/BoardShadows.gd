extends TileMapLayer
class_name BoardShadows;

@export var board: Board;

enum TileVisibility {
    DISCOVERED = 0,
    UNDISCOVERED = 1,
    ILLUMINATED = 2
}

# { [Vector2 cellPosition]: TileVisibility }
var tile_cells: Dictionary = {};
var ever_discovered: Array[Vector2i] = [];

func _ready() -> void:
    #board.on_board_updated.connect(illuminate_tiles);
    init_board();
    update_shadow_board();
    pass

func init_board() -> void:
    var cells = board.get_used_cells();
    for cell in cells:
        tile_cells[cell] = TileVisibility.UNDISCOVERED;

func update_shadow_board() -> void:
    for coord in tile_cells:
        match tile_cells[coord]:
            TileVisibility.DISCOVERED:
                set_cell(coord, 0, Vector2i(1,0) )
            TileVisibility.UNDISCOVERED:
                set_cell(coord, 0, Vector2i(0,0) )
            TileVisibility.ILLUMINATED:
                set_cell(coord, -1, Vector2i(-1,-1) )

func illuminate_tiles(tile_coords: Array):
    for coord in tile_cells:
        if tile_cells[coord] == TileVisibility.ILLUMINATED:
            print('set discovered');
            tile_cells[coord] = TileVisibility.DISCOVERED;
            set_cell(coord, 0, Vector2i(1,0));

    for coord in tile_coords:
        tile_cells[coord] = TileVisibility.ILLUMINATED;
    update_shadow_board();