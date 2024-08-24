package grid

import rl "vendor:raylib"

CellType :: enum {
	DEFAULT,
	BLOCK,
	GOAL,
	START,
}

Cell :: struct {
	type:      CellType,
	position:  GridCoord,
	heuristic: int,
	cost:      int,
}

get_score :: proc(cell: Cell) -> int {
	return cell.heuristic + cell.cost
}
