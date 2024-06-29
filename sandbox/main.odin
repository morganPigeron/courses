package main

import "core:fmt"
import "core:log"
import "core:mem"
import "core:strings"
import "core:c"
import "core:unicode/utf8"
import rl "vendor:raylib"
import mu "vendor:microui"

// microui binding
state := struct{
    mu_ctx: mu.Context,
    log_buf:         [1<<16]byte,
    log_buf_len:     int,
    log_buf_updated: bool,
    bg: mu.Color,
    atlas_texture: rl.RenderTexture2D,

    screen_width: c.int,
    screen_height: c.int,

    screen_texture: rl.RenderTexture2D,
}{
    screen_width = 1280,
    screen_height = 720,
    bg = {90, 95, 100, 255},
}

debug_state := struct {
    allocator: ^mem.Tracking_Allocator,
}{}

mouse_buttons_map := [mu.Mouse]rl.MouseButton{
    .LEFT    = .LEFT,
    .RIGHT   = .RIGHT,
    .MIDDLE  = .MIDDLE,
}

key_map := [mu.Key][2]rl.KeyboardKey{
    .SHIFT     = {.LEFT_SHIFT,   .RIGHT_SHIFT},
    .CTRL      = {.LEFT_CONTROL, .RIGHT_CONTROL},
    .ALT       = {.LEFT_ALT,     .RIGHT_ALT},
    .BACKSPACE = {.BACKSPACE,    .KEY_NULL},
    .DELETE    = {.DELETE,       .KEY_NULL},
    .RETURN    = {.ENTER,        .KP_ENTER},
    .LEFT      = {.LEFT,         .KEY_NULL},
    .RIGHT     = {.RIGHT,        .KEY_NULL},
    .HOME      = {.HOME,         .KEY_NULL},
    .END       = {.END,          .KEY_NULL},
    .A         = {.A,            .KEY_NULL},
    .X         = {.X,            .KEY_NULL},
    .C         = {.C,            .KEY_NULL},
    .V         = {.V,            .KEY_NULL},
}

main :: proc() {
	context.logger = log.create_console_logger()

	//Tracking allocator
	tracking_allocator: mem.Tracking_Allocator
    debug_state.allocator = &tracking_allocator
	mem.tracking_allocator_init(&tracking_allocator, context.allocator)
	context.allocator = mem.tracking_allocator(&tracking_allocator)
	reset_tracking_allocator :: proc(a: ^mem.Tracking_Allocator) -> bool {
		leaks := false
		for key, value in a.allocation_map {
			fmt.printf("%v: Leaked %v bytes\n", value.location, value.size)
			leaks = true
		}
		mem.tracking_allocator_clear(a)
		return leaks
	}
	defer reset_tracking_allocator(&tracking_allocator)
	//Tracking allocator end

	rl.InitWindow(state.screen_width, state.screen_height, "sandbox")
	defer rl.CloseWindow()
	rl.SetTargetFPS(60)

    // connect clipboard with microui
    ctx := &state.mu_ctx
    mu.init(ctx,
        set_clipboard = proc(user_data: rawptr, text: string) -> (ok: bool) {
            cstr := strings.clone_to_cstring(text)
            rl.SetClipboardText(cstr)
            delete(cstr)
            return true
        },
        get_clipboard = proc(user_data: rawptr) -> (text: string, ok: bool) {
            cstr := rl.GetClipboardText()
            if cstr != nil {
                text = string(cstr)
                ok = true
            }
            return
        },
    )

    // set context text size
	ctx.text_width = mu.default_atlas_text_width
	ctx.text_height = mu.default_atlas_text_height

    // set texture atlas 
	state.atlas_texture = rl.LoadRenderTexture(c.int(mu.DEFAULT_ATLAS_WIDTH), c.int(mu.DEFAULT_ATLAS_HEIGHT))
	defer rl.UnloadRenderTexture(state.atlas_texture)
	image := rl.GenImageColor(c.int(mu.DEFAULT_ATLAS_WIDTH), c.int(mu.DEFAULT_ATLAS_HEIGHT), rl.Color{0, 0, 0, 0})
	defer rl.UnloadImage(image)
	for alpha, i in mu.default_atlas_alpha {
		x := i % mu.DEFAULT_ATLAS_WIDTH
		y := i / mu.DEFAULT_ATLAS_WIDTH
		color := rl.Color{255, 255, 255, alpha}
		rl.ImageDrawPixel(&image, c.int(x), c.int(y), color)
	}
	rl.BeginTextureMode(state.atlas_texture)
	rl.UpdateTexture(state.atlas_texture.texture, rl.LoadImageColors(image))
	rl.EndTextureMode()

    // set screen texture
	state.screen_texture = rl.LoadRenderTexture(state.screen_width, state.screen_height)
	defer rl.UnloadRenderTexture(state.screen_texture)
	
	//rl.DisableCursor()
	for !rl.WindowShouldClose() { 

        // do i really need to free this each loop ?
		free_all(context.temp_allocator)

        // connect mouse input
		mouse_pos := rl.GetMousePosition()
		mouse_x, mouse_y := i32(mouse_pos.x), i32(mouse_pos.y)
		mu.input_mouse_move(ctx, mouse_x, mouse_y)
		mouse_wheel_pos := rl.GetMouseWheelMoveV()
		mu.input_scroll(ctx, i32(mouse_wheel_pos.x) * 30, i32(mouse_wheel_pos.y) * -30)
		for button_rl, button_mu in mouse_buttons_map {
			switch {
			case rl.IsMouseButtonPressed(button_rl):
				mu.input_mouse_down(ctx, mouse_x, mouse_y, button_mu)
			case rl.IsMouseButtonReleased(button_rl):
				mu.input_mouse_up  (ctx, mouse_x, mouse_y, button_mu)
			}
		}
        
        // connect keyboard input
		for keys_rl, key_mu in key_map {
			for key_rl in keys_rl {
				switch {
				case key_rl == .KEY_NULL:
					// ignore
				case rl.IsKeyPressed(key_rl):
					mu.input_key_down(ctx, key_mu)
				case rl.IsKeyReleased(key_rl):
					mu.input_key_up  (ctx, key_mu)
				}
			}
		}
        
        // connect text typed 
        {
			buf: [512]byte
			n: int
			for n < len(buf) {
				c := rl.GetCharPressed()
				if c == 0 {
					break
				}
				b, w := utf8.encode_rune(c)
				n += copy(buf[n:], b[:w])
			}
			mu.input_text(ctx, string(buf[:n]))
		}

        { //update
            mu.begin(ctx)
            all_windows(ctx)
            mu.end(ctx)
        }
        
        { //rendering
            rl.BeginDrawing()
            defer(rl.EndDrawing())
            
            rl.ClearBackground(rl.RAYWHITE)

            render(ctx)
        }
	}
}

all_windows :: proc(ctx: ^mu.Context)
{
    @static opts := mu.Options{
        .NO_CLOSE
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

