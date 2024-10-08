package main

import "core:fmt"
import "core:log"
import "core:mem"
import "core:strings"
import "core:c"
import "core:unicode/utf8"
import rl "vendor:raylib"
import mu "vendor:microui"

all_windows :: proc(ctx: ^mu.Context)
{
    @static opts := mu.Options{
        .NO_CLOSE,
    }

	if mu.window(ctx, "Debug window", {350, 40, 300, 200}, opts) {
        if .ACTIVE in mu.header(ctx, fmt.tprintf("Memory info - %v kB", debug_state.allocator.current_memory_allocated / 1_000)) {
            mu.layout_row(ctx, {150, -1}, 0)
            mu.label(ctx, "current memory allocated: ")
            mu.label(ctx, fmt.tprintf("%v kB", debug_state.allocator.current_memory_allocated / 1_000))
            mu.label(ctx, "total memory allocated: ")
            mu.label(ctx, fmt.tprintf("%v kB", debug_state.allocator.total_memory_allocated / 1_000))
            mu.label(ctx, "total memory freed: ")
            mu.label(ctx, fmt.tprintf("%v kB", debug_state.allocator.total_memory_freed / 1_000))
            mu.label(ctx, "total allocation call: ")
            mu.label(ctx, fmt.tprintf("%v", debug_state.allocator.total_allocation_count))
        }
	}

    if mu.window(ctx, "Game state", {40, 40, 300, 200}, opts) {
        mu.layout_row(ctx, {150, -1}, 0)
        mu.label(ctx, fmt.tprintf("target x:%v y:%v", game_state.target.x, game_state.target.y))
        mu.label(ctx, fmt.tprintf("move to x:%v y:%v", game_state.move_to.x, game_state.move_to.y))
    }
}

render :: proc "contextless" (ctx: ^mu.Context) {
	render_texture :: proc "contextless" (renderer: rl.RenderTexture2D, dst: ^rl.Rectangle, src: mu.Rect, color: rl.Color) {
		dst.width = f32(src.w)
		dst.height = f32(src.h)

		rl.BeginTextureMode(renderer)
		rl.DrawTextureRec(
			texture  = state.atlas_texture.texture,
			source   = {f32(src.x), f32(src.y), f32(src.w), f32(src.h)},
			position = {dst.x, dst.y},
			tint     = color,
		)
		rl.EndTextureMode()
	}

	to_rl_color :: proc "contextless" (in_color: mu.Color) -> (out_color: rl.Color) {
		return {in_color.r, in_color.g, in_color.b, in_color.a}
	}

	rl.BeginTextureMode(state.screen_texture)
	rl.EndScissorMode()
	rl.ClearBackground(rl.Color{}) // clear background with transparent color
	rl.EndTextureMode()

	command_backing: ^mu.Command
	for variant in mu.next_command_iterator(ctx, &command_backing) {
		switch cmd in variant {
		case ^mu.Command_Text:
			dst := rl.Rectangle{f32(cmd.pos.x), f32(cmd.pos.y), 0, 0}
			for ch in cmd.str do if ch&0xc0 != 0x80 {
				r := min(int(ch), 127)
				src := mu.default_atlas[mu.DEFAULT_ATLAS_FONT + r]
				render_texture(state.screen_texture, &dst, src, to_rl_color(cmd.color))
				dst.x += dst.width
			}
		case ^mu.Command_Rect:
			rl.BeginTextureMode(state.screen_texture)
			rl.DrawRectangle(cmd.rect.x, cmd.rect.y, cmd.rect.w, cmd.rect.h, to_rl_color(cmd.color))
			rl.EndTextureMode()
		case ^mu.Command_Icon:
			src := mu.default_atlas[cmd.id]
			x := cmd.rect.x + (cmd.rect.w - src.w)/2
			y := cmd.rect.y + (cmd.rect.h - src.h)/2
			render_texture(state.screen_texture, &rl.Rectangle {f32(x), f32(y), 0, 0}, src, to_rl_color(cmd.color))
		case ^mu.Command_Clip:
			rl.BeginTextureMode(state.screen_texture)
			rl.BeginScissorMode(cmd.rect.x, cmd.rect.y, cmd.rect.w, cmd.rect.h)
			rl.EndTextureMode()
		case ^mu.Command_Jump:
			unreachable()
		}
	}

	//rl.BeginDrawing()
	//rl.ClearBackground(rl.RAYWHITE)
	rl.DrawTextureRec(
		texture  = state.screen_texture.texture,
		source   = {0, 0, f32(state.screen_width), -f32(state.screen_height)},
		position = {0, 0},
		tint     = rl.WHITE,
	)
	//rl.EndDrawing()
}

u8_slider :: proc(ctx: ^mu.Context, val: ^u8, lo, hi: u8) -> (res: mu.Result_Set) {
	mu.push_id(ctx, uintptr(val))

	@static tmp: mu.Real
	tmp = mu.Real(val^)
	res = mu.slider(ctx, &tmp, mu.Real(lo), mu.Real(hi), 0, "%.0f", {.ALIGN_CENTER})
	val^ = u8(tmp)
	mu.pop_id(ctx)
	return
}
