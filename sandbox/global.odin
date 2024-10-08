package main

import "core:fmt"
import "core:log"
import "core:mem"
import "core:strings"
import "core:c"
import "core:unicode/utf8"
import rl "vendor:raylib"
import mu "vendor:microui"

// game related 
textures := struct {
    tank_green_texture: rl.Texture,
    tank_green_cannon_texture: rl.Texture,
}{}

load_tank_texture :: proc () {
    textures.tank_green_texture = rl.LoadTexture("assets/tank/tankBody_green.png")
    textures.tank_green_cannon_texture = rl.LoadTexture("assets/tank/tankGreen_barrel1.png")
}

game_state := struct {
    target :rl.Vector2,
    move_to:rl.Vector2,
}{
}
  
// microui binding
state := struct {
    mu_ctx: mu.Context,
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
