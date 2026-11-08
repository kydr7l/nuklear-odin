// Draw the Nuklear demo UI with the SDL3 renderer.
// This is a port of nuklear/demo/sdl3_renderer/nuklear_sdl3_renderer.h.
// On Windows, put SDL3.dll from Odin's vendor/sdl3 folder next to the executable.
package main

import "base:runtime"
import "core:fmt"
import "core:os"
import "core:strings"
import sdl "vendor:sdl3"
import nk "../.."
import "../common"

Sdl :: struct {
	window:        ^sdl.Window,
	renderer:      ^sdl.Renderer,
	ctx:           nk.Context,
	atlas:         nk.Font_Atlas,
	atlas_texture: ^sdl.Texture,
	null_texture:  nk.Draw_Null_Texture,
	cmds:          nk.Buffer, // the draw commands, kept between frames
	last_render:   u64, // in nanoseconds
	insert_toggle: bool,
}

app: Sdl

fail :: proc(what: string) -> ! {
	fmt.eprintfln("%s failed: %s", what, sdl.GetError())
	os.exit(1)
}

// ---- The clipboard ----

clipboard_paste :: proc "c" (handle: nk.Handle, edit: ^nk.Text_Edit) {
	context = runtime.default_context()
	text := sdl.GetClipboardText() // an empty string on failure, not nil
	defer sdl.free(text)
	if text != nil && text[0] != 0 {
		str := cstring(text)
		nk.textedit_paste(edit, str, i32(len(str)))
	}
}

clipboard_copy :: proc "c" (handle: nk.Handle, text: cstring, count: i32) {
	context = runtime.default_context()
	runtime.DEFAULT_TEMP_ALLOCATOR_TEMP_GUARD()
	if count <= 0 || text == nil {
		return
	}
	// The text from Nuklear has no zero terminator, so make a copy.
	str := strings.clone_to_cstring(string(([^]u8)(text)[:count]), context.temp_allocator)
	sdl.SetClipboardText(str)
}

// ---- The renderer ----

// Make the texture of the font atlas from RGBA pixels.
upload_atlas :: proc(pixels: []u8, width, height: i32) {
	app.atlas_texture = sdl.CreateTexture(app.renderer, .RGBA32, .STATIC, width, height)
	if app.atlas_texture == nil do fail("SDL_CreateTexture")
	sdl.UpdateTexture(app.atlas_texture, nil, raw_data(pixels), width * 4)
	sdl.SetTextureBlendMode(app.atlas_texture, sdl.BLENDMODE_BLEND)
}

// Convert the draw commands to vertices and draw them.
// The vertex has float colors for SDL_RenderGeometryRaw, so this does not use common.convert.
render :: proc(clear: nk.Color) {
	@(static) layout := [?]nk.Draw_Vertex_Layout_Element {
		{nk.VERTEX_POSITION, nk.FORMAT_FLOAT, nk.Size(offset_of(sdl.Vertex, position))},
		{nk.VERTEX_TEXCOORD, nk.FORMAT_FLOAT, nk.Size(offset_of(sdl.Vertex, tex_coord))},
		{nk.VERTEX_COLOR, nk.FORMAT_R32G32B32A32_FLOAT, nk.Size(offset_of(sdl.Vertex, color))},
		nk.VERTEX_LAYOUT_END,
	}
	config := nk.Convert_Config {
		global_alpha         = 1,
		line_AA              = nk.ANTI_ALIASING_ON,
		shape_AA             = nk.ANTI_ALIASING_ON,
		circle_segment_count = 22,
		arc_segment_count    = 22,
		curve_segment_count  = 22,
		tex_null             = app.null_texture,
		vertex_layout        = raw_data(layout[:]),
		vertex_size          = size_of(sdl.Vertex),
		vertex_alignment     = align_of(sdl.Vertex),
	}
	verts, elems: nk.Buffer
	nk.buffer_init_default(&verts)
	nk.buffer_init_default(&elems)
	defer nk.buffer_free(&verts)
	defer nk.buffer_free(&elems)
	if nk.convert(&app.ctx, &app.cmds, &verts, &elems, &config) != nk.CONVERT_SUCCESS {
		fmt.eprintln("nk.convert failed")
	}

	r := app.renderer
	sdl.SetRenderDrawColor(r, clear.r, clear.g, clear.b, clear.a)
	sdl.RenderClear(r)
	// Geometry with an alpha value needs the blend mode.
	sdl.SetRenderDrawBlendMode(r, sdl.BLENDMODE_BLEND)

	base := cast([^]u8)nk.buffer_memory_const(&verts)
	count := i32(verts.needed / size_of(sdl.Vertex))
	indices := cast([^]nk.Draw_Index)nk.buffer_memory_const(&elems)
	stride :: size_of(sdl.Vertex)
	it := nk.Draw_Iterator{ctx = &app.ctx, cmds = &app.cmds}
	for cmd in nk.draw_foreach(&it) {
		if cmd.elem_count == 0 do continue
		clip := sdl.Rect{i32(cmd.clip_rect.x), i32(cmd.clip_rect.y), i32(cmd.clip_rect.w), i32(cmd.clip_rect.h)}
		sdl.SetRenderClipRect(r, &clip)
		sdl.RenderGeometryRaw(
			r, cast(^sdl.Texture)cmd.texture.ptr,
			cast([^]f32)(base[offset_of(sdl.Vertex, position):]), stride,
			cast([^]sdl.FColor)(base[offset_of(sdl.Vertex, color):]), stride,
			cast([^]f32)(base[offset_of(sdl.Vertex, tex_coord):]), stride,
			count, indices, i32(cmd.elem_count), size_of(nk.Draw_Index),
		)
		indices = indices[cmd.elem_count:] // the next command starts after this one
	}
	sdl.SetRenderClipRect(r, nil)
	sdl.RenderPresent(r)

	nk.clear(&app.ctx)
	nk.buffer_clear(&app.cmds)
}

// ---- The input ----

// Send a key to Nuklear. A shortcut key goes down only while Ctrl is down.
handle_key :: proc(e: ^sdl.KeyboardEvent) {
	down := e.down
	ctrl := e.mod & sdl.KMOD_CTRL != {}
	key :: proc(k: nk.Keys, down: bool) {
		nk.input_key(&app.ctx, k, nk.Bool(down))
	}
	switch e.key {
	case sdl.K_LALT, sdl.K_RALT: key(nk.KEY_ALT, down)
	case sdl.K_LSHIFT, sdl.K_RSHIFT: key(nk.KEY_SHIFT, down)
	case sdl.K_LCTRL, sdl.K_RCTRL: key(nk.KEY_CTRL, down)
	case sdl.K_DELETE: key(nk.KEY_DEL, down)
	case sdl.K_RETURN, sdl.K_KP_ENTER: key(nk.KEY_ENTER, down)
	case sdl.K_TAB: key(nk.KEY_TAB, down)
	case sdl.K_BACKSPACE: key(nk.KEY_BACKSPACE, down)
	case sdl.K_HOME:
		key(nk.KEY_TEXT_START, down)
		key(nk.KEY_SCROLL_START, down)
	case sdl.K_END:
		key(nk.KEY_TEXT_END, down)
		key(nk.KEY_SCROLL_END, down)
	case sdl.K_PAGEDOWN: key(nk.KEY_SCROLL_DOWN, down)
	case sdl.K_PAGEUP: key(nk.KEY_SCROLL_UP, down)
	case sdl.K_F1 ..= sdl.K_F12: key(nk.KEY_F1 + nk.Keys(e.key - sdl.K_F1), down)
	case sdl.K_UP: key(nk.KEY_UP, down)
	case sdl.K_DOWN: key(nk.KEY_DOWN, down)
	case sdl.K_LEFT: key(nk.KEY_TEXT_WORD_LEFT if ctrl else nk.KEY_LEFT, down)
	case sdl.K_RIGHT: key(nk.KEY_TEXT_WORD_RIGHT if ctrl else nk.KEY_RIGHT, down)
	case sdl.K_ESCAPE: key(nk.KEY_TEXT_RESET_MODE, down)
	case sdl.K_INSERT:
		// Switch only on press, so that the key repeat does not toggle.
		// Nuklear has two keys for the mode, not one toggle.
		if down && !e.repeat {
			app.insert_toggle = !app.insert_toggle
			key(nk.KEY_TEXT_INSERT_MODE if app.insert_toggle else nk.KEY_TEXT_REPLACE_MODE, true)
		}
	case sdl.K_A: key(nk.KEY_TEXT_SELECT_ALL, down && ctrl)
	case sdl.K_B: key(nk.KEY_TEXT_LINE_START, down && ctrl)
	case sdl.K_E: key(nk.KEY_TEXT_LINE_END, down && ctrl)
	case sdl.K_C: key(nk.KEY_COPY, down && ctrl)
	case sdl.K_V: key(nk.KEY_PASTE, down && ctrl)
	case sdl.K_X: key(nk.KEY_CUT, down && ctrl)
	case sdl.K_Z: key(nk.KEY_TEXT_UNDO, down && ctrl)
	case sdl.K_R: key(nk.KEY_TEXT_REDO, down && ctrl)
	}
}

handle_button :: proc(e: ^sdl.MouseButtonEvent) {
	x, y, down := i32(e.x), i32(e.y), nk.Bool(e.down)
	ctx := &app.ctx
	switch e.button {
	case sdl.BUTTON_LEFT:
		if e.clicks > 1 do nk.input_button(ctx, nk.BUTTON_DOUBLE, x, y, down)
		nk.input_button(ctx, nk.BUTTON_LEFT, x, y, down)
	case sdl.BUTTON_MIDDLE: nk.input_button(ctx, nk.BUTTON_MIDDLE, x, y, down)
	case sdl.BUTTON_RIGHT: nk.input_button(ctx, nk.BUTTON_RIGHT, x, y, down)
	case sdl.BUTTON_X1: nk.input_button(ctx, nk.BUTTON_X1, x, y, down)
	case sdl.BUTTON_X2: nk.input_button(ctx, nk.BUTTON_X2, x, y, down)
	}
}

main :: proc() {
	if !sdl.Init({.VIDEO}) do fail("SDL_Init")
	defer sdl.Quit()

	// There is no high pixel density flag, so the window size is the pixel size.
	// The renderer follows the size of the window, so a resize needs no code.
	if !sdl.CreateWindowAndRenderer(
		"Nuklear SDL3 Demo", common.WINDOW_WIDTH, common.WINDOW_HEIGHT, {.RESIZABLE}, &app.window, &app.renderer,
	) {
		fail("SDL_CreateWindowAndRenderer")
	}
	defer sdl.DestroyWindow(app.window)
	defer sdl.DestroyRenderer(app.renderer)
	sdl.SetRenderVSync(app.renderer, 1)

	// Upload the pixels before font_atlas_end, which frees them.
	font, pixels, width, height := common.bake_default_font(&app.atlas, 14)
	if pixels == nil do fail("font bake")
	upload_atlas(pixels, width, height)
	nk.font_atlas_end(&app.atlas, {ptr = app.atlas_texture}, &app.null_texture)

	ctx := &app.ctx
	if !nk.init_default(ctx, &font.handle) {
		fmt.eprintln("nk.init_default failed")
		os.exit(1)
	}
	ctx.clip.copy = clipboard_copy
	ctx.clip.paste = clipboard_paste
	nk.buffer_init_default(&app.cmds)
	if !sdl.StartTextInput(app.window) do fail("SDL_StartTextInput")
	app.last_render = sdl.GetTicksNS()

	for running := true; running; {
		nk.input_begin(ctx)
		event: sdl.Event
		for sdl.PollEvent(&event) {
			#partial switch event.type {
			case .QUIT, .WINDOW_CLOSE_REQUESTED:
				running = false
			case .KEY_DOWN, .KEY_UP:
				handle_key(&event.key)
			case .MOUSE_BUTTON_DOWN, .MOUSE_BUTTON_UP:
				handle_button(&event.button)
			case .MOUSE_MOTION:
				nk.input_motion(ctx, i32(event.motion.x), i32(event.motion.y))
			case .MOUSE_WHEEL:
				nk.input_scroll(ctx, {event.wheel.x, event.wheel.y})
			case .TEXT_INPUT:
				// The text is UTF-8 and can hold more than one rune.
				for r in string(event.text.text) {
					nk.input_unicode(ctx, nk.Rune(r))
				}
			}
		}
		nk.input_end(ctx)
		if !running do break

		// Nuklear needs the time between frames for animations.
		now := sdl.GetTicksNS()
		ctx.delta_time_seconds = f32(now - app.last_render) / 1e9
		app.last_render = now

		common.frame(ctx)
		render(common.BACKGROUND)
	}

	nk.buffer_free(&app.cmds)
	nk.font_atlas_clear(&app.atlas)
	nk.free(ctx)
	sdl.DestroyTexture(app.atlas_texture)
}
