// Draw the Nuklear demo UI with raylib.
// Nuklear makes the triangles. The demo sends them to raylib with rlgl.
package main

import "base:runtime"
import "core:c"
import "core:fmt"
import "core:os"
import "core:strings"
import rl "vendor:raylib"
import "vendor:raylib/rlgl"
import nk "../.."
import "../common"

// Two presses of the left button in this time are a double click. raylib has no double click event.
DOUBLE_CLICK_SECONDS :: 0.3

Raylib :: struct {
	ctx:           nk.Context,
	atlas:         nk.Font_Atlas,
	atlas_texture: rl.Texture2D,
	null_texture:  nk.Draw_Null_Texture,
	cmds:          nk.Buffer, // the draw commands, kept between frames
	last_click:    f64, // the time of the last left press, in seconds
	double_click:  bool, // true while the current left press is a double click
	insert_toggle: bool,
}

app: Raylib

// ---- The clipboard ----

clipboard_paste :: proc "c" (handle: nk.Handle, edit: ^nk.Text_Edit) {
	context = runtime.default_context()
	text := rl.GetClipboardText() // nil on failure
	if text != nil && len(text) > 0 {
		nk.textedit_paste(edit, text, i32(len(text)))
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
	rl.SetClipboardText(str)
}

// ---- The renderer ----

// Make the texture of the font atlas from RGBA pixels.
upload_atlas :: proc(pixels: []u8, width, height: i32) {
	image := rl.Image {
		data    = raw_data(pixels),
		width   = width,
		height  = height,
		mipmaps = 1,
		format  = .UNCOMPRESSED_R8G8B8A8,
	}
	app.atlas_texture = rl.LoadTextureFromImage(image)
	// Point filtering keeps the glyphs sharp. Linear filtering blurs them.
	rl.SetTextureFilter(app.atlas_texture, .POINT)
}

// Convert the draw commands to vertices and draw them.
render :: proc() {
	verts, elems: nk.Buffer
	nk.buffer_init_default(&verts)
	nk.buffer_init_default(&elems)
	defer nk.buffer_free(&verts)
	defer nk.buffer_free(&elems)
	if common.convert(&app.ctx, &app.cmds, &verts, &elems, app.null_texture) != nk.CONVERT_SUCCESS {
		fmt.eprintln("nk.convert failed")
	}

	vertices := cast([^]common.Vertex)nk.buffer_memory_const(&verts)
	indices := cast([^]nk.Draw_Index)nk.buffer_memory_const(&elems)
	// Nuklear does not set a winding order for its triangles.
	rlgl.DisableBackfaceCulling()
	it := nk.Draw_Iterator{ctx = &app.ctx, cmds = &app.cmds}
	for cmd in nk.draw_foreach(&it) {
		if cmd.elem_count == 0 do continue
		// BeginScissorMode sends the batch that is waiting, so the clip rectangle applies only to this command.
		rl.BeginScissorMode(i32(cmd.clip_rect.x), i32(cmd.clip_rect.y), i32(cmd.clip_rect.w), i32(cmd.clip_rect.h))
		rlgl.SetTexture(c.uint(cmd.texture.id)) // every command has a texture: the null texture is a pixel of the atlas
		rlgl.Begin(rlgl.TRIANGLES)
		for i := 0; i < int(cmd.elem_count); i += 3 {
			// A large command can fill the batch. This call sends the batch and keeps the mode and texture.
			rlgl.CheckRenderBatchLimit(3)
			for k in 0 ..< 3 {
				v := vertices[indices[i + k]]
				rlgl.Color4ub(v.color.r, v.color.g, v.color.b, v.color.a)
				rlgl.TexCoord2f(v.uv.x, v.uv.y)
				rlgl.Vertex2f(v.position.x, v.position.y)
			}
		}
		rlgl.End()
		rl.EndScissorMode() // this sends the batch
		indices = indices[cmd.elem_count:] // the next command starts after this one
	}
	rlgl.EnableBackfaceCulling()

	nk.clear(&app.ctx)
	nk.buffer_clear(&app.cmds)
}

// ---- The input ----

// The state of the Ctrl key that a key map entry needs when the key goes down.
Ctrl_State :: enum {
	Any,
	Down,
	Up,
}

Key_Map :: struct {
	from: rl.KeyboardKey,
	to:   nk.Keys,
	ctrl: Ctrl_State,
}

// Some raylib keys send more than one Nuklear key. A shortcut key goes down only while Ctrl is down.
KEY_MAP := [?]Key_Map {
	{.LEFT_ALT, nk.KEY_ALT, .Any}, {.RIGHT_ALT, nk.KEY_ALT, .Any},
	{.LEFT_SHIFT, nk.KEY_SHIFT, .Any}, {.RIGHT_SHIFT, nk.KEY_SHIFT, .Any},
	{.LEFT_CONTROL, nk.KEY_CTRL, .Any}, {.RIGHT_CONTROL, nk.KEY_CTRL, .Any},
	{.DELETE, nk.KEY_DEL, .Any},
	{.ENTER, nk.KEY_ENTER, .Any}, {.KP_ENTER, nk.KEY_ENTER, .Any},
	{.TAB, nk.KEY_TAB, .Any},
	{.BACKSPACE, nk.KEY_BACKSPACE, .Any},
	{.HOME, nk.KEY_TEXT_START, .Any}, {.HOME, nk.KEY_SCROLL_START, .Any},
	{.END, nk.KEY_TEXT_END, .Any}, {.END, nk.KEY_SCROLL_END, .Any},
	{.PAGE_DOWN, nk.KEY_SCROLL_DOWN, .Any}, {.PAGE_UP, nk.KEY_SCROLL_UP, .Any},
	{.UP, nk.KEY_UP, .Any}, {.DOWN, nk.KEY_DOWN, .Any},
	{.LEFT, nk.KEY_LEFT, .Up}, {.LEFT, nk.KEY_TEXT_WORD_LEFT, .Down},
	{.RIGHT, nk.KEY_RIGHT, .Up}, {.RIGHT, nk.KEY_TEXT_WORD_RIGHT, .Down},
	{.ESCAPE, nk.KEY_TEXT_RESET_MODE, .Any},
	{.A, nk.KEY_TEXT_SELECT_ALL, .Down}, {.B, nk.KEY_TEXT_LINE_START, .Down},
	{.E, nk.KEY_TEXT_LINE_END, .Down}, {.C, nk.KEY_COPY, .Down},
	{.V, nk.KEY_PASTE, .Down}, {.X, nk.KEY_CUT, .Down},
	{.Z, nk.KEY_TEXT_UNDO, .Down}, {.R, nk.KEY_TEXT_REDO, .Down},
}

// Send the key events of this frame to Nuklear.
// Nuklear counts each call as one key press, so send a key only when it goes down, repeats or goes up.
handle_keys :: proc() {
	ctx := &app.ctx
	ctrl := rl.IsKeyDown(.LEFT_CONTROL) || rl.IsKeyDown(.RIGHT_CONTROL)
	for m in KEY_MAP {
		if rl.IsKeyPressed(m.from) || rl.IsKeyPressedRepeat(m.from) {
			if m.ctrl == .Any || (m.ctrl == .Down) == ctrl {
				nk.input_key(ctx, m.to, true)
			}
		} else if rl.IsKeyReleased(m.from) {
			nk.input_key(ctx, m.to, false)
		}
	}
	// F1 to F12 are in a row in both libraries.
	for i in 0 ..< 12 {
		key := rl.KeyboardKey(int(rl.KeyboardKey.F1) + i)
		if rl.IsKeyPressed(key) || rl.IsKeyPressedRepeat(key) {
			nk.input_key(ctx, nk.KEY_F1 + nk.Keys(i), true)
		} else if rl.IsKeyReleased(key) {
			nk.input_key(ctx, nk.KEY_F1 + nk.Keys(i), false)
		}
	}
	if rl.IsKeyPressed(.INSERT) {
		// Nuklear has two keys for the mode, not one toggle.
		app.insert_toggle = !app.insert_toggle
		nk.input_key(ctx, nk.KEY_TEXT_INSERT_MODE if app.insert_toggle else nk.KEY_TEXT_REPLACE_MODE, true)
	}
}

handle_mouse :: proc() {
	ctx := &app.ctx
	pos := rl.GetMousePosition()
	x, y := i32(pos.x), i32(pos.y)
	nk.input_motion(ctx, x, y)

	// A double click sends a double button event and the left button event.
	// The double event stays down until the left button goes up.
	if rl.IsMouseButtonPressed(.LEFT) {
		now := rl.GetTime()
		app.double_click = now - app.last_click < DOUBLE_CLICK_SECONDS
		app.last_click = now
	}
	if app.double_click && (rl.IsMouseButtonPressed(.LEFT) || rl.IsMouseButtonReleased(.LEFT)) {
		nk.input_button(ctx, nk.BUTTON_DOUBLE, x, y, nk.Bool(rl.IsMouseButtonDown(.LEFT)))
	}

	Button_Map :: struct {
		from: rl.MouseButton,
		to:   nk.Buttons,
	}
	@(static) buttons := [?]Button_Map {
		{.LEFT, nk.BUTTON_LEFT}, {.MIDDLE, nk.BUTTON_MIDDLE}, {.RIGHT, nk.BUTTON_RIGHT},
		{.SIDE, nk.BUTTON_X1}, {.EXTRA, nk.BUTTON_X2},
	}
	for b in buttons {
		if rl.IsMouseButtonPressed(b.from) {
			nk.input_button(ctx, b.to, x, y, true)
		} else if rl.IsMouseButtonReleased(b.from) {
			nk.input_button(ctx, b.to, x, y, false)
		}
	}

	wheel := rl.GetMouseWheelMoveV()
	nk.input_scroll(ctx, {wheel.x, wheel.y})
}

main :: proc() {
	rl.SetConfigFlags({.WINDOW_RESIZABLE})
	rl.InitWindow(common.WINDOW_WIDTH, common.WINDOW_HEIGHT, "Nuklear raylib Demo")
	defer rl.CloseWindow()
	// By default raylib closes the window on Escape. Nuklear needs this key.
	rl.SetExitKey(.KEY_NULL)
	rl.SetTargetFPS(60)

	// The default font is a bitmap font made for 13 pixels. Other sizes scale it and blur it.
	// Upload the pixels before font_atlas_end, which frees them.
	font, pixels, width, height := common.bake_default_font(&app.atlas, 13)
	if pixels == nil {
		fmt.eprintln("font bake failed")
		os.exit(1)
	}
	upload_atlas(pixels, width, height)
	nk.font_atlas_end(&app.atlas, {id = c.int(app.atlas_texture.id)}, &app.null_texture)

	ctx := &app.ctx
	if !nk.init_default(ctx, &font.handle) {
		fmt.eprintln("nk.init_default failed")
		os.exit(1)
	}
	ctx.clip.copy = clipboard_copy
	ctx.clip.paste = clipboard_paste
	nk.buffer_init_default(&app.cmds)

	for !rl.WindowShouldClose() {
		nk.input_begin(ctx)
		handle_mouse()
		handle_keys()
		// GetCharPressed returns the queued characters one by one, and 0 at the end.
		for r := rl.GetCharPressed(); r != 0; r = rl.GetCharPressed() {
			nk.input_unicode(ctx, nk.Rune(r))
		}
		nk.input_end(ctx)

		// Nuklear needs the time between frames for animations.
		ctx.delta_time_seconds = rl.GetFrameTime()

		common.frame(ctx)
		rl.BeginDrawing()
		rl.ClearBackground(transmute(rl.Color)common.BACKGROUND)
		render()
		rl.EndDrawing()
	}

	nk.buffer_free(&app.cmds)
	nk.font_atlas_clear(&app.atlas)
	nk.free(ctx)
	rl.UnloadTexture(app.atlas_texture)
}
