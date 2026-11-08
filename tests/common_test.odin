package nuklear_tests

import "core:strings"
import "core:testing"
import nk ".."
import common "../examples/common"

// Run the shared UI for 3 frames. The Demo and Overview windows must draw and convert.
@(test)
test_common_frame :: proc(t: ^testing.T) {
	h: Headless
	if !headless_init(t, &h) {return}
	defer headless_destroy(&h)
	ctx := &h.ctx

	cmds, vertices, elements: nk.Buffer
	nk.buffer_init_default(&cmds)
	nk.buffer_init_default(&vertices)
	nk.buffer_init_default(&elements)
	defer nk.buffer_free(&cmds)
	defer nk.buffer_free(&vertices)
	defer nk.buffer_free(&elements)

	for frame in 0 ..< 3 {
		nk.input_begin(ctx)
		nk.input_end(ctx)
		common.frame(ctx)

		if frame == 2 {
			demo_title, overview_title := false, false
			cit := nk.Command_Iterator{ctx = ctx}
			for cmd in nk.foreach(&cit) {
				if cmd.type != nk.COMMAND_TEXT {continue}
				switch command_string((^nk.Command_Text)(cmd)) {
				case "Demo":     demo_title = true
				case "Overview": overview_title = true
				}
			}
			testing.expect(t, demo_title, "no Command_Text for Demo")
			testing.expect(t, overview_title, "no Command_Text for Overview")

			testing.expect_value(t, common.convert(ctx, &cmds, &vertices, &elements, h.null_tex), nk.Flags(nk.CONVERT_SUCCESS))
			draws := 0
			dit := nk.Draw_Iterator{ctx = ctx, cmds = &cmds}
			for cmd in nk.draw_foreach(&dit) {
				if cmd.elem_count > 0 {draws += 1}
			}
			testing.expect(t, draws >= 1, "no Draw_Command with elements")
		}
		nk.clear(ctx)
	}
}

Text :: struct {
	s:    string,
	x, y: i32, // the center
}

// Run one frame with the left mouse button at (x, y), up or down.
// Return the text of the frame. The strings live in the temp allocator.
step :: proc(ctx: ^nk.Context, x, y: i32, down: bool) -> (texts: [dynamic]Text) {
	texts = make([dynamic]Text, context.temp_allocator)
	nk.input_begin(ctx)
	nk.input_motion(ctx, x, y)
	nk.input_button(ctx, nk.BUTTON_LEFT, x, y, nk.Bool(down))
	nk.input_end(ctx)
	common.frame(ctx)
	cit := nk.Command_Iterator{ctx = ctx}
	for cmd in nk.foreach(&cit) {
		if cmd.type != nk.COMMAND_TEXT {continue}
		c := (^nk.Command_Text)(cmd)
		s, _ := strings.clone(command_string(c), context.temp_allocator)
		append(&texts, Text{s, i32(c.x) + i32(c.w) / 2, i32(c.y) + i32(c.h) / 2})
	}
	nk.clear(ctx)
	return
}

// Return the first text for which the match procedure is true.
find :: proc(texts: [dynamic]Text, match: proc(s: string) -> bool) -> (text: Text, ok: bool) {
	for text in texts {
		if match(text.s) {return text, true}
	}
	return {}, false
}

// A combo box shows the time as HH:MM:SS and the date as DD-MM-YYYY.
is_time :: proc(s: string) -> bool {return len(s) == 8 && s[2] == ':' && s[5] == ':'}
is_date :: proc(s: string) -> bool {return len(s) == 10 && s[2] == '-' && s[5] == '-'}
is_seconds :: proc(s: string) -> bool {return s == "S:"} // a property in the time popup
is_week_day :: proc(s: string) -> bool {return s == "SUN"} // a label in the date popup

// Run the Overview with every tree open. The combo box popups for the time and the date run too.
// A tree keeps its state in a table of the window. This test sets every value in the tables to MAXIMIZED.
// So the test does not change overview.odin. A nested tree appears one frame after its parent opens.
@(test)
test_common_all_trees_open :: proc(t: ^testing.T) {
	h: Headless
	if !headless_init(t, &h) {return}
	defer headless_destroy(&h)
	ctx := &h.ctx
	defer free_all(context.temp_allocator)

	for frame in 0 ..< 8 {
		step(ctx, 0, 0, false)
		if frame == 0 {
			// Make the window so tall that no widget is out of view.
			nk.window_set_size(ctx, "Overview", nk.vec2(400, 20000))
		}
		overview := nk.window_find(ctx, "Overview")
		if !testing.expect(t, overview != nil, "no Overview window") {return}
		for table := overview.tables; table != nil; table = table.next {
			for i in 0 ..< table.size {
				table.values[i] = nk.Uint(nk.MAXIMIZED)
			}
		}
	}

	// Click the time combo box. The popup has the property S: in it.
	time_box, ok := find(step(ctx, 0, 0, false), is_time)
	if !testing.expect(t, ok, "no time combo box: the Combo tree did not open") {return}
	step(ctx, time_box.x, time_box.y, true)
	step(ctx, time_box.x, time_box.y, false)
	_, ok = find(step(ctx, time_box.x, time_box.y, false), is_seconds)
	testing.expect(t, ok, "the time popup did not open")
	// A click outside of the popup closes it.
	step(ctx, 700, 500, true)
	step(ctx, 700, 500, false)

	// Click the date combo box. The popup has the week days in it.
	date_box: Text
	date_box, ok = find(step(ctx, 0, 0, false), is_date)
	if !testing.expect(t, ok, "no date combo box") {return}
	step(ctx, date_box.x, date_box.y, true)
	step(ctx, date_box.x, date_box.y, false)
	_, ok = find(step(ctx, date_box.x, date_box.y, false), is_week_day)
	testing.expect(t, ok, "the date popup did not open")
}
