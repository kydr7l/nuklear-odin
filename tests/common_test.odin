package nuklear_tests

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
