package nuklear_tests

import "core:c"
import "core:strings"
import "core:testing"
import nk ".."
import common "../examples/common"

// A Nuklear context with the baked default font and no window system.
Headless :: struct {
	atlas:    nk.Font_Atlas,
	font:     ^nk.Font,
	null_tex: nk.Draw_Null_Texture,
	ctx:      nk.Context,
}

// Bake the default font (13 px) and start the context. The Headless value must not move afterward.
headless_init :: proc(t: ^testing.T, h: ^Headless) -> bool {
	font, pixels, _, _ := common.bake_default_font(&h.atlas, 13)
	h.font = font
	testing.expect(t, pixels != nil) or_return
	nk.font_atlas_end(&h.atlas, nk.Handle{id = 1}, &h.null_tex)
	testing.expect(t, h.font != nil) or_return
	return testing.expect(t, bool(nk.init_default(&h.ctx, &h.font.handle)))
}

headless_destroy :: proc(h: ^Headless) {
	nk.free(&h.ctx)
	nk.font_atlas_clear(&h.atlas)
}

// The text of a Command_Text.
command_string :: proc(cmd: ^nk.Command_Text) -> string {
	return strings.string_from_ptr(&cmd.string[0], int(cmd.length))
}

Vertex :: struct {
	position: [2]f32,
	uv:       [2]f32,
	color:    [4]u8,
}

@(test)
test_headless_frame :: proc(t: ^testing.T) {
	h: Headless
	if !headless_init(t, &h) {return}
	defer headless_destroy(&h)
	ctx := &h.ctx

	nk.input_begin(ctx)
	nk.input_end(ctx)
	if nk.begin(ctx, "Demo", nk.rect(50, 50, 200, 200), nk.WINDOW_BORDER | nk.WINDOW_MOVABLE | nk.WINDOW_TITLE) {
		nk.layout_row_static(ctx, 30, 80, 1)
		nk.button_label(ctx, "button")
	}
	nk.end(ctx)

	texts, rects := 0, 0
	cit := nk.Command_Iterator{ctx = ctx}
	for cmd in nk.foreach(&cit) {
		switch cmd.type {
		case nk.COMMAND_TEXT:
			texts += 1
		case nk.COMMAND_RECT_FILLED:
			rects += 1
		}
	}
	testing.expect(t, texts >= 1, "no Command_Text")
	testing.expect(t, rects >= 1, "no Command_Rect_Filled")

	layout := [?]nk.Draw_Vertex_Layout_Element {
		{nk.VERTEX_POSITION, nk.FORMAT_FLOAT, nk.Size(offset_of(Vertex, position))},
		{nk.VERTEX_TEXCOORD, nk.FORMAT_FLOAT, nk.Size(offset_of(Vertex, uv))},
		{nk.VERTEX_COLOR, nk.FORMAT_R8G8B8A8, nk.Size(offset_of(Vertex, color))},
		nk.VERTEX_LAYOUT_END,
	}
	config := nk.Convert_Config {
		global_alpha         = 1,
		line_AA              = nk.ANTI_ALIASING_ON,
		shape_AA             = nk.ANTI_ALIASING_ON,
		circle_segment_count = 22,
		arc_segment_count    = 22,
		curve_segment_count  = 22,
		tex_null             = h.null_tex,
		vertex_layout        = raw_data(layout[:]),
		vertex_size          = size_of(Vertex),
		vertex_alignment     = align_of(Vertex),
	}
	cmds, vertices, elements: nk.Buffer
	nk.buffer_init_default(&cmds)
	nk.buffer_init_default(&vertices)
	nk.buffer_init_default(&elements)
	defer nk.buffer_free(&cmds)
	defer nk.buffer_free(&vertices)
	defer nk.buffer_free(&elements)

	testing.expect_value(t, nk.convert(ctx, &cmds, &vertices, &elements, &config), nk.Flags(nk.CONVERT_SUCCESS))
	draws := 0
	dit := nk.Draw_Iterator{ctx = ctx, cmds = &cmds}
	for cmd in nk.draw_foreach(&dit) {
		if cmd.elem_count > 0 {draws += 1}
	}
	testing.expect(t, draws >= 1, "no Draw_Command with elements")
	nk.clear(ctx)
}

// The two trees have the same title on two lines. A shared state would open both or close both.
// The first tree starts closed and the second starts open, so each must keep its own state.
@(test)
test_tree_push_unique_per_line :: proc(t: ^testing.T) {
	h: Headless
	if !headless_init(t, &h) {return}
	defer headless_destroy(&h)
	ctx := &h.ctx

	nk.input_begin(ctx)
	nk.input_end(ctx)
	first, second: nk.Bool
	if nk.begin(ctx, "Trees", nk.rect(0, 0, 300, 300), 0) {
		nk.layout_row_dynamic(ctx, 20, 1)
		first = nk.tree_push(ctx, nk.TREE_TAB, "Same", nk.MINIMIZED)
		if first {nk.tree_pop(ctx)}
		second = nk.tree_push(ctx, nk.TREE_TAB, "Same", nk.MAXIMIZED)
		if second {nk.tree_pop(ctx)}
	}
	nk.end(ctx)
	testing.expect(t, !bool(first), "first tree is open")
	testing.expect(t, bool(second), "second tree is closed")

	same := 0
	it := nk.Command_Iterator{ctx = ctx}
	for cmd in nk.foreach(&it) {
		if cmd.type == nk.COMMAND_TEXT && command_string((^nk.Command_Text)(cmd)) == "Same" {
			same += 1
		}
	}
	testing.expect_value(t, same, 2)
	nk.clear(ctx)
}

// One frame of a window with a single edit field.
edit_frame :: proc(ctx: ^nk.Context, buffer: []c.char, focus: bool, unicode: nk.Rune) {
	nk.input_begin(ctx)
	if unicode != 0 {nk.input_unicode(ctx, unicode)}
	nk.input_end(ctx)
	if nk.begin(ctx, "Edit", nk.rect(0, 0, 300, 100), 0) {
		nk.layout_row_dynamic(ctx, 30, 1)
		if focus {nk.edit_focus(ctx, nk.EDIT_FIELD)}
		nk.edit_string_zero_terminated(ctx, nk.EDIT_FIELD, raw_data(buffer), c.int(len(buffer)), nk.filter_default)
	}
	nk.end(ctx)
	nk.clear(ctx)
}

@(test)
test_text_input_unicode :: proc(t: ^testing.T) {
	h: Headless
	if !headless_init(t, &h) {return}
	defer headless_destroy(&h)

	buffer: [64]c.char
	edit_frame(&h.ctx, buffer[:], true, 0)
	edit_frame(&h.ctx, buffer[:], false, 0xE9)
	testing.expect_value(t, u8(buffer[0]), 0xC3)
	testing.expect_value(t, u8(buffer[1]), 0xA9)
	testing.expect_value(t, u8(buffer[2]), 0)
}

// The #c_vararg arguments must reach the C printf format.
// #c_vararg ..any does no C default promotion. Pass f64 for a float and c.int for a small integer.
@(test)
test_labelf_vararg :: proc(t: ^testing.T) {
	h: Headless
	if !headless_init(t, &h) {return}
	defer headless_destroy(&h)
	ctx := &h.ctx

	nk.input_begin(ctx)
	nk.input_end(ctx)
	if nk.begin(ctx, "Labels", nk.rect(0, 0, 300, 100), 0) {
		nk.layout_row_dynamic(ctx, 20, 1)
		nk.labelf(ctx, nk.TEXT_LEFT, "n=%d f=%.1f s=%s", c.int(42), f64(1.5), cstring("ok"))
	}
	nk.end(ctx)

	found := false
	it := nk.Command_Iterator{ctx = ctx}
	for cmd in nk.foreach(&it) {
		if cmd.type == nk.COMMAND_TEXT && command_string((^nk.Command_Text)(cmd)) == "n=42 f=1.5 s=ok" {
			found = true
		}
	}
	testing.expect(t, found, "labelf text not found")
	nk.clear(ctx)
}
