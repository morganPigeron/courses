package main

import "core:log"
import "core:c"
import "core:os"
import png "core:image/png"

import "vendor:glfw"
import gl "vendor:OpenGL"

running : b32 = true

GL_MAJOR_VERSION : c.int : 4
GL_MINOR_VERSION :: 6

/*
refs:
https://gist.github.com/SorenSaket/155afe1ec11a79def63341c588ade329
*/

main :: proc() {
    context.logger = log.create_console_logger()

    glfw.WindowHint(glfw.RESIZABLE, 1)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR,GL_MAJOR_VERSION) 
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR,GL_MINOR_VERSION)
    glfw.WindowHint(glfw.OPENGL_PROFILE,glfw.OPENGL_CORE_PROFILE)
    
    glfw.Init()
    defer glfw.Terminate()
    
    window := glfw.CreateWindow(640, 480, "seam-carving", nil, nil)
    defer glfw.DestroyWindow(window)

    glfw.MakeContextCurrent(window)
    glfw.SwapInterval(1) // vsync
    glfw.SetKeyCallback(window, key_callback)
    glfw.SetFramebufferSizeCallback(window, size_callback)

    gl.load_up_to(
	int(GL_MAJOR_VERSION),
	GL_MINOR_VERSION,
	glfw.gl_set_proc_address
    )

    // load initial image
    image_data, ok := os.read_entire_file_from_filename("Broadway_tower_edit.png")
    defer delete(image_data)
    if !ok {
	log.error("cannot load image")
	return 
    }

    image, image_err := png.load_from_bytes(image_data)
    defer free(image)
    if image_err != nil {
	log.errorf("cannot load png from byte: %v", image_err)
    }

    texid: u32 
    gl.GenTextures(1, &texid)
    gl.BindTexture(gl.TEXTURE_2D, texid)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)
    gl.TexImage2D(
	gl.TEXTURE_2D,
	0,
	gl.RGBA8UI,
	i32(image.width),
	i32(image.height),
	0, // border
	gl.RGBA, // format
	gl.UNSIGNED_BYTE,
	&image.pixels
    )

    gl.FramebufferTexture(
	gl.FRAMEBUFFER,
	gl.COLOR_ATTACHMENT0,
	texid,
	0
    )
    
    for !glfw.WindowShouldClose(window) && running {
	glfw.PollEvents()
	draw()
	glfw.SwapBuffers(window)
    }
}

draw :: proc(){
    // Set the opengl clear color
    // 0-1 rgba values
    gl.ClearColor(0.2, 0.3, 0.3, 1.0)
    // Clear the screen with the set clearcolor
    gl.Clear(gl.COLOR_BUFFER_BIT)

    // Own drawing code here
}

key_callback :: proc "c" (
    window: glfw.WindowHandle,
    key,
    scancode,
    action,
    mods: i32
) {
    if key == glfw.KEY_ESCAPE {
	running = false
    }
}

size_callback :: proc "c" (
    window: glfw.WindowHandle,
    width,
    height: i32
) {
    // Set the OpenGL viewport size
    gl.Viewport(0, 0, width, height)
}
