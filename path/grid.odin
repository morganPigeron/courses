package main

import "core:fmt"
import "core:log"
import "core:testing"
import rl "vendor:raylib"

Cell :: struct {
	isActive: bool,
}

Grid :: struct {
	size:  int,
	start: rl.Vector2,
	end:   rl.Vector2,
	cells: []Cell,
}

new_grid :: proc(cellSize: int, topLeft: rl.Vector2, bottomRight: rl.Vector2) -> Grid {

	newGrid := Grid{}
	newGrid.start = topLeft
	newGrid.end = bottomRight
	newGrid.size = cellSize

	newGrid.cells = make([]Cell, getNumCols(newGrid) * getNumRows(newGrid))
	return newGrid
}

clearGrid :: proc(grid: ^Grid) {
	for &cell in grid.cells {
		cell.isActive = false
	}
}

cleanGrid :: proc(grid: ^Grid) {
	delete(grid.cells)
}

get2dCoord :: proc(grid: Grid, i: int) -> rl.Vector2 {
	x := (i % int(getNumCols(grid))) * grid.size
	y := (i / int(getNumCols(grid))) * grid.size
	x_f32 := f32(x)
	y_f32 := f32(y)
	return {x_f32, y_f32}
}

IsInGrid :: proc(grid: Grid, coord: rl.Vector2) -> bool {
	return(
		coord.x > grid.start.x &&
		coord.x < grid.end.x &&
		coord.y > grid.start.y &&
		coord.y < grid.end.y \
	)
}

getCellByCoord :: proc(grid: Grid, coord: rl.Vector2) -> (cellFound: ^Cell, ok: bool) {
	if !IsInGrid(grid, coord) {
		return nil, false
	}
	col_num := getNumCols(grid)
	row_num := getNumRows(grid)
	scale_x := int(coord.x * f32(col_num) / f32(getWidth(grid)))
	scale_y := int(coord.y * f32(row_num) / f32(getHeight(grid)))
	index := scale_y * col_num + scale_x
	return &grid.cells[index], true
}

getWidth :: proc(grid: Grid) -> int {
	return int(grid.end.x - grid.start.x)
}

getHeight :: proc(grid: Grid) -> int {
	return int(grid.end.y - grid.start.y)
}

getNumCols :: proc(grid: Grid) -> int {
	return int((grid.end.x - grid.start.x) / f32(grid.size))
}

getNumRows :: proc(grid: Grid) -> int {
	return int((grid.end.y - grid.start.y) / f32(grid.size))
}

draw2dGrid :: proc(grid: Grid) {
	for cell, i in grid.cells {
		startCoord := get2dCoord(grid, i)
		if cell.isActive {
			rl.DrawRectangleV(startCoord, {f32(grid.size), f32(grid.size)}, rl.WHITE)
		} else {
			rl.DrawRectangleV(startCoord, {f32(grid.size), f32(grid.size)}, rl.BLACK)
		}
	}
	for i := int(grid.start.x); i <= int(grid.end.x); i += grid.size {
		rl.DrawLineV({f32(i), grid.start.y}, {f32(i), grid.end.y}, rl.PURPLE)
	}
	for i := int(grid.start.y); i <= int(grid.end.y); i += grid.size {
		rl.DrawLineV({grid.start.x, f32(i)}, {grid.end.x, f32(i)}, rl.PURPLE)
	}

	//Debug text
	/*
	for i := 0; i < len(grid.cells); i += 1 {
		if i % 10 == 0 {
			coord := get2dCoord(grid, i)
			rl.DrawCircleV(coord, 2, rl.RED)
			rl.DrawText(fmt.ctprintf("%v", i), i32(coord.x), i32(coord.y), 1, rl.RED)
		}
	}
    */
}

@(test)
test_grid_creation :: proc(t: ^testing.T) {
	grid := new_grid(10, {0, 0}, {100, 100})
	testing.expect_value(t, len(grid.cells), getNumCols(grid) * getNumRows(grid))
	cleanGrid(&grid)

	grid = new_grid(10, {0, 0}, {1220, 720})
	testing.expect_value(t, len(grid.cells), getNumCols(grid) * getNumRows(grid))
	cleanGrid(&grid)
}

@(test)
test_getCellByCoord :: proc(t: ^testing.T) {
	grid := new_grid(10, {0, 0}, {20, 20})
	grid.cells[0].isActive = true
	cell, ok := getCellByCoord(grid, {5, 5})
	testing.expect_value(t, ok, true)
	testing.expect_value(t, cell.isActive, true)
	cleanGrid(&grid)

	grid = new_grid(10, {0, 0}, {20, 20})
	grid.cells[1].isActive = true
	cell, ok = getCellByCoord(grid, {15, 5})
	testing.expect_value(t, ok, true)
	testing.expect_value(t, cell.isActive, true)
	cleanGrid(&grid)

	grid = new_grid(10, {0, 0}, {20, 20})
	grid.cells[2].isActive = true
	cell, ok = getCellByCoord(grid, {5, 15})
	testing.expect_value(t, ok, true)
	testing.expect_value(t, cell.isActive, true)
	cleanGrid(&grid)

	grid = new_grid(10, {0, 0}, {20, 20})
	grid.cells[3].isActive = true
	cell, ok = getCellByCoord(grid, {15, 15})
	testing.expect_value(t, ok, true)
	testing.expect_value(t, cell.isActive, true)
	cleanGrid(&grid)
}

@(test)
test_get_cell_coordinate :: proc(t: ^testing.T) {
	grid := new_grid(10, {0, 0}, {20, 20})
	testing.expect_value(t, get2dCoord(grid, 0), rl.Vector2{0, 0})
	testing.expect_value(t, get2dCoord(grid, 1), rl.Vector2{10, 0})
	testing.expect_value(t, get2dCoord(grid, 2), rl.Vector2{0, 10})
	testing.expect_value(t, get2dCoord(grid, 3), rl.Vector2{10, 10})
	cleanGrid(&grid)

	grid = new_grid(10, {0, 0}, {200, 200})
	testing.expect_value(t, get2dCoord(grid, 19), rl.Vector2{190, 0})
	testing.expect_value(t, get2dCoord(grid, 39), rl.Vector2{190, 10})
	testing.expect_value(t, get2dCoord(grid, 399), rl.Vector2{190, 190})
	cleanGrid(&grid)

	grid = new_grid(10, {0, 0}, {20, 40})
	testing.expect_value(t, get2dCoord(grid, 0), rl.Vector2{0, 0})
	testing.expect_value(t, get2dCoord(grid, 1), rl.Vector2{10, 0})
	testing.expect_value(t, get2dCoord(grid, 2), rl.Vector2{0, 10})
	testing.expect_value(t, get2dCoord(grid, 7), rl.Vector2{10, 30})
	cleanGrid(&grid)
}

@(test)
test_out_of_bound :: proc(t: ^testing.T) {
	grid := new_grid(10, {0, 0}, {20, 20})
	grid.cells[0].isActive = true
	cell, ok := getCellByCoord(grid, {50, 50})
	testing.expect_value(t, ok, false)
	cleanGrid(&grid)
}
