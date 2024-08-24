package grid

import "core:math"
import "core:testing"
import rl "vendor:raylib"

aStar :: proc(grid: ^Grid, start_pos: GridCoord, end_pos: GridCoord) {
	update_start_cell(grid, start_pos)
	update_heuristic(grid, end_pos)
	update_cost_around(grid, start_pos)
}

update_start_cell :: proc(grid: ^Grid, pos: GridCoord) {
	//getCellByGridCoord(pos)
}

update_cost_around :: proc(grid: ^Grid, pos: GridCoord) {

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
test_heuristic :: proc(t: ^testing.T) {
	testing.expect_value(t, heuristic({0, 0}, {1, 1}), 2)
	testing.expect_value(t, heuristic({1, 1}, {0, 0}), 2)
	testing.expect_value(t, heuristic({0, 0}, {1, 0}), 1)
	testing.expect_value(t, heuristic({0, 0}, {0, 1}), 1)
}
