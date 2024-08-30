package grid

import "core:fmt"
import "core:log"
import "core:testing"
import rl "vendor:raylib"

GridCoord :: [2]int

Grid :: struct {
	size:  int,
	start: rl.Vector2,
	end:   rl.Vector2,
	cells: []Cell,
}

new_grid :: proc(cellSize: int, topLeft: rl.Vector2, bottomRight: rl.Vector2) -> Grid {

	grid := Grid{}
	grid.start = topLeft
	grid.end = bottomRight
	grid.size = cellSize

	grid.cells = make([]Cell, getNumCols(&grid) * getNumRows(&grid))
	initGrid(&grid)
	return grid
}

initGrid :: proc(grid: ^Grid) {
	for &cell, i in grid.cells {
		coord := get2dGridCoord(grid, i)
		cell.position = {int(coord.x), int(coord.y)}
	}
}

clearGrid :: proc(grid: ^Grid) {
	for &cell in grid.cells {
		cell.type = .DEFAULT
	}
}

clearGridExcept :: proc(grid: ^Grid, state: CellType) {
	for &cell in grid.cells {
		if cell.type != state {
			cell.type = .DEFAULT
		}
	}
}

cleanGrid :: proc(grid: ^Grid) {
	delete(grid.cells)
}

get2dCoord :: proc(grid: ^Grid, i: int) -> rl.Vector2 {
	x := (i % int(getNumCols(grid))) * grid.size
	y := (i / int(getNumCols(grid))) * grid.size
	x_f32 := f32(x) + grid.start.x
	y_f32 := f32(y) + grid.start.y
	return {x_f32, y_f32}
}

get2dGridCoord :: proc(grid: ^Grid, i: int) -> rl.Vector2 {
	x := (i % int(getNumCols(grid)))
	y := (i / int(getNumCols(grid)))
	return {f32(x), f32(y)}
}

IsInGrid :: proc {
	IsInGrid_byCoordinate,
	IsInGrid_byGridCoordinate,
}

IsInGrid_byCoordinate :: proc(grid: ^Grid, coord: rl.Vector2) -> bool {
	return(
		coord.x > grid.start.x &&
		coord.x < grid.end.x &&
		coord.y > grid.start.y &&
		coord.y < grid.end.y \
	)
}

IsInGrid_byGridCoordinate :: proc(grid: ^Grid, coord: GridCoord) -> bool {
	return getNumCols(grid) > coord.x && getNumRows(grid) > coord.y
}

getCellByCoord :: proc(grid: ^Grid, coord: rl.Vector2) -> (cellFound: ^Cell, ok: bool) {
	if !IsInGrid(grid, coord) {
		return nil, false
	}

	col_num := getNumCols(grid)
	row_num := getNumRows(grid)
	inGridCoord := coord - grid.start
	scale_x := int(inGridCoord.x * f32(col_num) / f32(getWidth(grid)))
	scale_y := int(inGridCoord.y * f32(row_num) / f32(getHeight(grid)))
	index := scale_y * col_num + scale_x
	return &grid.cells[index], true
}

getCellByGridCoord :: proc(grid: ^Grid, coord: GridCoord) -> (cellFound: ^Cell, ok: bool) {
	if !IsInGrid(grid, coord) {
		return nil, false
	}

	col_num := getNumCols(grid)
	row_num := getNumRows(grid)
	scale_x := coord.x * col_num / getWidth(grid)
	scale_y := coord.y * row_num / getHeight(grid)
	index := scale_y * col_num + scale_x
	return &grid.cells[index], true
}

getWidth :: proc(grid: ^Grid) -> int {
	return int(grid.end.x - grid.start.x)
}

getHeight :: proc(grid: ^Grid) -> int {
	return int(grid.end.y - grid.start.y)
}

getNumCols :: proc(grid: ^Grid) -> int {
	return int((grid.end.x - grid.start.x) / f32(grid.size))
}

getNumRows :: proc(grid: ^Grid) -> int {
	return int((grid.end.y - grid.start.y) / f32(grid.size))
}

draw2dGrid :: proc(grid: ^Grid) {
	for cell, i in grid.cells {
		startCoord := get2dCoord(grid, i)
		color: rl.Color
		switch cell.type {
		case .DEFAULT:
			color = rl.WHITE
		case .BLOCK:
			color = rl.BLACK
		case .GOAL:
			color = rl.GREEN
		case .START:
			color = rl.BLUE
		}

		rl.DrawRectangleV(startCoord, {f32(grid.size), f32(grid.size)}, color)
	}
	for i := int(grid.start.x); i <= int(grid.end.x); i += grid.size {
		rl.DrawLineV({f32(i), grid.start.y}, {f32(i), grid.end.y}, rl.PURPLE)
	}
	for i := int(grid.start.y); i <= int(grid.end.y); i += grid.size {
		rl.DrawLineV({grid.start.x, f32(i)}, {grid.end.x, f32(i)}, rl.PURPLE)
	}

	//Debug text
	for i := 0; i < len(grid.cells); i += 1 {
		coord := get2dCoord(grid, i)
		rl.DrawCircleV(coord, 2, rl.RED)
		rl.DrawText(
			fmt.ctprintf("%v", get_score(grid.cells[i])),
			i32(coord.x + f32(grid.size / 2)),
			i32(coord.y + f32(grid.size / 2)),
			1,
			rl.RED,
		)
	}
}

@(test)
test_grid_creation :: proc(t: ^testing.T) {
	grid := new_grid(10, {0, 0}, {100, 100})
	testing.expect_value(t, len(grid.cells), getNumCols(&grid) * getNumRows(&grid))
	cleanGrid(&grid)

	grid = new_grid(10, {0, 0}, {1220, 720})
	testing.expect_value(t, len(grid.cells), getNumCols(&grid) * getNumRows(&grid))
	cleanGrid(&grid)
}

@(test)
test_init_grid :: proc(t: ^testing.T) {
	grid := new_grid(10, {0, 0}, {20, 20})
	initGrid(&grid)
	testing.expect_value(t, grid.cells[0].position.x, 0)
	testing.expect_value(t, grid.cells[1].position.x, 1)
	testing.expect_value(t, grid.cells[2].position.x, 0)
	testing.expect_value(t, grid.cells[3].position.x, 1)
	testing.expect_value(t, grid.cells[0].position.y, 0)
	testing.expect_value(t, grid.cells[1].position.y, 0)
	testing.expect_value(t, grid.cells[2].position.y, 1)
	testing.expect_value(t, grid.cells[3].position.y, 1)
	cleanGrid(&grid)
}

@(test)
test_getCellByCoord :: proc(t: ^testing.T) {
	grid := new_grid(10, {0, 0}, {20, 20})
	grid.cells[0].type = .BLOCK
	cell, ok := getCellByCoord(&grid, {5, 5})
	testing.expect_value(t, ok, true)
	testing.expect_value(t, cell.type, CellType.BLOCK)
	cleanGrid(&grid)

	grid = new_grid(10, {0, 0}, {20, 20})
	grid.cells[1].type = .BLOCK
	cell, ok = getCellByCoord(&grid, {15, 5})
	testing.expect_value(t, ok, true)
	testing.expect_value(t, cell.type, CellType.BLOCK)
	cleanGrid(&grid)

	grid = new_grid(10, {0, 0}, {20, 20})
	grid.cells[2].type = .BLOCK
	cell, ok = getCellByCoord(&grid, {5, 15})
	testing.expect_value(t, ok, true)
	testing.expect_value(t, cell.type, CellType.BLOCK)
	cleanGrid(&grid)

	grid = new_grid(10, {0, 0}, {20, 20})
	grid.cells[3].type = .BLOCK
	cell, ok = getCellByCoord(&grid, {15, 15})
	testing.expect_value(t, ok, true)
	testing.expect_value(t, cell.type, CellType.BLOCK)
	cleanGrid(&grid)
}

@(test)
test_get_cell_coordinate :: proc(t: ^testing.T) {
	grid := new_grid(10, {0, 0}, {20, 20})
	testing.expect_value(t, get2dCoord(&grid, 0), rl.Vector2{0, 0})
	testing.expect_value(t, get2dCoord(&grid, 1), rl.Vector2{10, 0})
	testing.expect_value(t, get2dCoord(&grid, 2), rl.Vector2{0, 10})
	testing.expect_value(t, get2dCoord(&grid, 3), rl.Vector2{10, 10})
	cleanGrid(&grid)

	grid = new_grid(10, {0, 0}, {200, 200})
	testing.expect_value(t, get2dCoord(&grid, 19), rl.Vector2{190, 0})
	testing.expect_value(t, get2dCoord(&grid, 39), rl.Vector2{190, 10})
	testing.expect_value(t, get2dCoord(&grid, 399), rl.Vector2{190, 190})
	cleanGrid(&grid)

	grid = new_grid(10, {0, 0}, {20, 40})
	testing.expect_value(t, get2dCoord(&grid, 0), rl.Vector2{0, 0})
	testing.expect_value(t, get2dCoord(&grid, 1), rl.Vector2{10, 0})
	testing.expect_value(t, get2dCoord(&grid, 2), rl.Vector2{0, 10})
	testing.expect_value(t, get2dCoord(&grid, 7), rl.Vector2{10, 30})
	cleanGrid(&grid)

	grid = new_grid(10, {10, 10}, {30, 30})
	testing.expect_value(t, get2dCoord(&grid, 0), rl.Vector2{10, 10})
	testing.expect_value(t, get2dCoord(&grid, 1), rl.Vector2{20, 10})
	testing.expect_value(t, get2dCoord(&grid, 2), rl.Vector2{10, 20})
	testing.expect_value(t, get2dCoord(&grid, 3), rl.Vector2{20, 20})
	cleanGrid(&grid)
}

@(test)
test_out_of_bound :: proc(t: ^testing.T) {
	grid := new_grid(10, {0, 0}, {20, 20})
	cell, ok := getCellByCoord(&grid, {500, 500})
	testing.expect_value(t, ok, false)
	cleanGrid(&grid)

	grid = new_grid(10, {1000, 1000}, {2000, 2000})
	cell, ok = getCellByCoord(&grid, {500, 500})
	testing.expect_value(t, ok, false)
	cleanGrid(&grid)
}

@(test)
test_get_2d_grid_coordinate :: proc(t: ^testing.T) {
	grid := new_grid(10, {0, 0}, {20, 20})
	testing.expect_value(t, get2dGridCoord(&grid, 0), rl.Vector2{0, 0})
	testing.expect_value(t, get2dGridCoord(&grid, 1), rl.Vector2{1, 0})
	testing.expect_value(t, get2dGridCoord(&grid, 2), rl.Vector2{0, 1})
	testing.expect_value(t, get2dGridCoord(&grid, 3), rl.Vector2{1, 1})
	cleanGrid(&grid)
}
