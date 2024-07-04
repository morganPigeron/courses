package main

import "core:fmt"
import "core:log"
import "core:mem"
import "core:strings"
import "core:c"
import "core:unicode/utf8"
import rl "vendor:raylib"
import mu "vendor:microui"

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
	
    // camera
    camera := rl.Camera2D{}
    camera.zoom = 1

    //game state
    troops := make([dynamic]troop, 0, 4096)
    defer(delete(troops))
    new_troop_at(&troops,rl.Vector2{})

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

            update_troops(troops[:])

            mu.begin(ctx)
            all_windows(ctx)
            mu.end(ctx)
        }
        
        { //rendering
            rl.BeginDrawing()
            defer(rl.EndDrawing())
            rl.ClearBackground(rl.RAYWHITE)
    
            {// 2D drawing
                rl.BeginMode2D(camera)

                render_troops(troops[:])

                rl.EndMode2D()
            }

            rl.DrawFPS(10, 10)
            render(ctx)
        }
	}
}

troop :: struct {
    position: rl.Vector2,
} 

new_troop_at :: proc (troops :^[dynamic]troop, position: rl.Vector2) -> troop {
    t := troop{
        position,
    }
    append(troops, t) 
    return troops[len(troops)-1] 
}

update_troops :: proc (troops: []troop) {
    for &t in troops {
       update_troop(&t) 
    }
}

update_troop :: proc (t: ^troop) {
    
}

render_troops :: proc (troops: []troop) {
    for &t in troops {
        rl.DrawRectangle(
                i32(t.position.x),
                i32(t.position.y),
                32,
                32,
                rl.RED
            )
    }
}
