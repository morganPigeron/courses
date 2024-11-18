package grid

import "core:math"
import "core:testing"
import rl "vendor:raylib"

VisitedCell :: struct {
	cell:          ^Cell,
	score:         int,
	previous_cell: ^Cell,
}

aStar :: proc(grid: ^Grid, start_pos: GridCoord, end_pos: GridCoord) {
	update_heuristic(grid, end_pos)
	cost_of_path := 0
	previous_cell: Cell

	to_visit_cells := make([dynamic]^Cell, 0, len(grid.cells))
	defer delete(to_visit_cells)
	visited_cells := make([dynamic]VisitedCell, 0, len(grid.cells))
	defer delete(visited_cells)

	//find all cells to visit from actual cell
	update_cells_to_visit(grid, start_pos, &to_visit_cells)
	cell_to_visit := get_next_cell_to_visit(&to_visit_cells)
	cell_to_visit.cost = cost_of_path
	visited := visit_cell(
		cell_to_visit,
		/*previous_cell*/
		cell_to_visit,
	)
}

visit_cell :: proc(cell: ^Cell, previous_cell: ^Cell) -> VisitedCell {
	return VisitedCell {
		score = cell.cost + cell.heuristic,
		previous_cell = previous_cell,
		cell = cell,
	}
}

get_next_cell_to_visit :: proc(to_visit: ^[dynamic]^Cell) -> (result: ^Cell) {
	min_heuristic := 999999
	for cell in to_visit {
		if cell.heuristic < min_heuristic {
			min_heuristic = cell.heuristic
			result = cell
		}
	}
	return
}

update_cells_to_visit :: proc(grid: ^Grid, coord: GridCoord, to_visit: ^[dynamic]^Cell) {
	//check if coord is at the border
	if (coord.x == 0) {
		cell, _ := getCellByGridCoord(grid, {coord.x + 1, coord.y})
		append(to_visit, cell)
	} else if (coord.x == getNumCols(grid) - 1) {
		cell, _ := getCellByGridCoord(grid, {coord.x - 1, coord.y})
		append(to_visit, cell)
	} else {
		cell_right, _ := getCellByGridCoord(grid, {coord.x + 1, coord.y})
		append(to_visit, cell_right)
		cell_left, _ := getCellByGridCoord(grid, {coord.x - 1, coord.y})
		append(to_visit, cell_left)
	}

	if (coord.y == 0) {
		cell, _ := getCellByGridCoord(grid, {coord.x, coord.y + 1})
		append(to_visit, cell)
	} else if (coord.y == getNumRows(grid) - 1) {
		cell, _ := getCellByGridCoord(grid, {coord.x, coord.y - 1})
		append(to_visit, cell)
	} else {
		cell_bottom, _ := getCellByGridCoord(grid, {coord.x, coord.y + 1})
		append(to_visit, cell_bottom)
		cell_top, _ := getCellByGridCoord(grid, {coord.x, coord.y - 1})
		append(to_visit, cell_top)
	}
}

update_heuristic :: proc(grid: ^Grid, end_pos: GridCoord) {
	for &cell in grid.cells {
		cell.heuristic = heuristic(cell.position, end_pos)
	}
}

heuristic :: proc(start_pos: GridCoord, end_pos: GridCoord) -> int {
	x := math.abs(start_pos.x - end_pos.x)
	y := math.abs(start_pos.y - end_pos.y)
	return int(x + y)
}

@(test)
test_update_cells_to_visit :: proc(t: ^testing.T) {
	grid := new_grid(10, {0, 0}, {30, 30})
	defer cleanGrid(&grid)

	// \ 0 1 2 
	// 0 X * .
	// 1 * . .
	// 2 . . . 
	to_visit_cells := make([dynamic]^Cell, 0, len(grid.cells))
	update_cells_to_visit(&grid, {0, 0}, &to_visit_cells)
	testing.expect_value(t, len(to_visit_cells), 2)
	testing.expect_value(t, to_visit_cells[0].position, GridCoord{1, 0})
	testing.expect_value(t, to_visit_cells[1].position, GridCoord{0, 1})
	delete(to_visit_cells)

	// \ 0 1 2 
	// 0 . * .
	// 1 * X *
	// 2 . * . 
	to_visit_cells = make([dynamic]^Cell, 0, len(grid.cells))
	update_cells_to_visit(&grid, {1, 1}, &to_visit_cells)
	testing.expect_value(t, len(to_visit_cells), 4)
	testing.expect_value(t, to_visit_cells[0].position, GridCoord{2, 1})
	testing.expect_value(t, to_visit_cells[1].position, GridCoord{0, 1})
	testing.expect_value(t, to_visit_cells[2].position, GridCoord{1, 2})
	testing.expect_value(t, to_visit_cells[3].position, GridCoord{1, 0})
	delete(to_visit_cells)

	// \ 0 1 2 
	// 0 . . .
	// 1 . . *
	// 2 . * X 
	to_visit_cells = make([dynamic]^Cell, 0, len(grid.cells))
	update_cells_to_visit(&grid, {2, 2}, &to_visit_cells)
	testing.expect_value(t, len(to_visit_cells), 2)
	testing.expect_value(t, to_visit_cells[0].position, GridCoord{1, 2})
	testing.expect_value(t, to_visit_cells[1].position, GridCoord{2, 1})
	delete(to_visit_cells)
}

@(test)
test_heuristic :: proc(t: ^testing.T) {
	testing.expect_value(t, heuristic({0, 0}, {1, 1}), 2)
	testing.expect_value(t, heuristic({1, 1}, {0, 0}), 2)
	testing.expect_value(t, heuristic({0, 0}, {1, 0}), 1)
	testing.expect_value(t, heuristic({0, 0}, {0, 1}), 1)
}
