package nuklear_tests

import "core:c"
import "core:testing"
import nk ".."

// The linker must find every procedure of the foreign block.
// Task 4 adds the procedures of the later header sections.
@(test)
test_every_procedure_links :: proc(t: ^testing.T) {
	procs := [?]rawptr {
		rawptr(nk._begin),
		rawptr(nk._draw_begin),
		rawptr(nk._draw_end),
		rawptr(nk._draw_next),
		rawptr(nk._next),
		rawptr(nk.begin),
		rawptr(nk.begin_titled),
		rawptr(nk.clear),
		rawptr(nk.convert),
		rawptr(nk.end),
		rawptr(nk.free),
		rawptr(nk.group_begin),
		rawptr(nk.group_begin_titled),
		rawptr(nk.group_end),
		rawptr(nk.group_get_scroll),
		rawptr(nk.group_scrolled_begin),
		rawptr(nk.group_scrolled_end),
		rawptr(nk.group_scrolled_offset_begin),
		rawptr(nk.group_set_scroll),
		rawptr(nk.init),
		rawptr(nk.init_custom),
		rawptr(nk.init_default),
		rawptr(nk.init_fixed),
		rawptr(nk.input_begin),
		rawptr(nk.input_button),
		rawptr(nk.input_char),
		rawptr(nk.input_end),
		rawptr(nk.input_glyph),
		rawptr(nk.input_key),
		rawptr(nk.input_motion),
		rawptr(nk.input_scroll),
		rawptr(nk.input_unicode),
		rawptr(nk.item_is_any_active),
		rawptr(nk.layout_ratio_from_pixel),
		rawptr(nk.layout_reset_min_row_height),
		rawptr(nk.layout_row),
		rawptr(nk.layout_row_begin),
		rawptr(nk.layout_row_dynamic),
		rawptr(nk.layout_row_end),
		rawptr(nk.layout_row_push),
		rawptr(nk.layout_row_static),
		rawptr(nk.layout_row_template_begin),
		rawptr(nk.layout_row_template_end),
		rawptr(nk.layout_row_template_push_dynamic),
		rawptr(nk.layout_row_template_push_static),
		rawptr(nk.layout_row_template_push_variable),
		rawptr(nk.layout_set_min_row_height),
		rawptr(nk.layout_space_begin),
		rawptr(nk.layout_space_bounds),
		rawptr(nk.layout_space_end),
		rawptr(nk.layout_space_push),
		rawptr(nk.layout_space_rect_to_local),
		rawptr(nk.layout_space_rect_to_screen),
		rawptr(nk.layout_space_to_local),
		rawptr(nk.layout_space_to_screen),
		rawptr(nk.layout_widget_bounds),
		rawptr(nk.list_view_begin),
		rawptr(nk.list_view_end),
		rawptr(nk.rule_horizontal),
		rawptr(nk.spacer),
		rawptr(nk.spacing),
		rawptr(nk.tree_element_image_push_hashed),
		rawptr(nk.tree_element_pop),
		rawptr(nk.tree_element_push_hashed),
		rawptr(nk.tree_image_push_hashed),
		rawptr(nk.tree_pop),
		rawptr(nk.tree_push_hashed),
		rawptr(nk.tree_state_image_push),
		rawptr(nk.tree_state_pop),
		rawptr(nk.tree_state_push),
		rawptr(nk.widget),
		rawptr(nk.widget_bounds),
		rawptr(nk.widget_disable_begin),
		rawptr(nk.widget_disable_end),
		rawptr(nk.widget_has_mouse_click_down),
		rawptr(nk.widget_height),
		rawptr(nk.widget_is_hovered),
		rawptr(nk.widget_is_mouse_clicked),
		rawptr(nk.widget_position),
		rawptr(nk.widget_size),
		rawptr(nk.widget_width),
		rawptr(nk.window_close),
		rawptr(nk.window_collapse),
		rawptr(nk.window_collapse_if),
		rawptr(nk.window_find),
		rawptr(nk.window_get_bounds),
		rawptr(nk.window_get_canvas),
		rawptr(nk.window_get_content_region),
		rawptr(nk.window_get_content_region_max),
		rawptr(nk.window_get_content_region_min),
		rawptr(nk.window_get_content_region_size),
		rawptr(nk.window_get_height),
		rawptr(nk.window_get_panel),
		rawptr(nk.window_get_position),
		rawptr(nk.window_get_scroll),
		rawptr(nk.window_get_size),
		rawptr(nk.window_get_width),
		rawptr(nk.window_has_focus),
		rawptr(nk.window_is_active),
		rawptr(nk.window_is_any_hovered),
		rawptr(nk.window_is_closed),
		rawptr(nk.window_is_collapsed),
		rawptr(nk.window_is_hidden),
		rawptr(nk.window_is_hovered),
		rawptr(nk.window_set_bounds),
		rawptr(nk.window_set_focus),
		rawptr(nk.window_set_position),
		rawptr(nk.window_set_scroll),
		rawptr(nk.window_set_size),
		rawptr(nk.window_show),
		rawptr(nk.window_show_if),
	}
	for p, i in procs {
		testing.expectf(t, p != nil, "procedure %d is nil", i)
	}
}

// A window with no title bar and no border draws at least one command.
@(test)
test_foreach_visits_commands :: proc(t: ^testing.T) {
	memory: [64 * 1024]byte
	font := nk.User_Font{height = 10, width = proc "c" (_: nk.Handle, _: f32, _: cstring, n: c.int) -> f32 { return f32(n) * 5 }}
	ctx: nk.Context
	testing.expect(t, bool(nk.init_fixed(&ctx, raw_data(memory[:]), nk.Size(len(memory)), &font)))
	nk.input_begin(&ctx)
	nk.input_end(&ctx)
	if nk.begin(&ctx, "w", {0, 0, 100, 100}, 0) {
		nk.layout_row_dynamic(&ctx, 20, 1)
	}
	nk.end(&ctx)
	count := 0
	it := nk.Command_Iterator{ctx = &ctx}
	for _ in nk.foreach(&it) {
		count += 1
	}
	testing.expect(t, count > 0)
	nk.free(&ctx)
}

// The same id on two source lines must give two separate tree states, as in C.
// The first tree starts closed and the second starts open. A shared state would close both.
@(test)
test_tree_push_id_unique_per_line :: proc(t: ^testing.T) {
	memory: [64 * 1024]byte
	font := nk.User_Font{height = 10, width = proc "c" (_: nk.Handle, _: f32, _: cstring, n: c.int) -> f32 { return f32(n) * 5 }}
	ctx: nk.Context
	testing.expect(t, bool(nk.init_fixed(&ctx, raw_data(memory[:]), nk.Size(len(memory)), &font)))
	defer nk.free(&ctx)
	nk.input_begin(&ctx)
	nk.input_end(&ctx)
	if nk.begin(&ctx, "w", {0, 0, 200, 200}, 0) {
		nk.layout_row_dynamic(&ctx, 20, 1)
		first := nk.tree_push_id(&ctx, nk.TREE_TAB, "Same", nk.MINIMIZED, 0)
		if first {nk.tree_pop(&ctx)}
		second := nk.tree_push_id(&ctx, nk.TREE_TAB, "Same", nk.MAXIMIZED, 0)
		if second {nk.tree_pop(&ctx)}
		testing.expect(t, !bool(first))
		testing.expect(t, bool(second))
	}
	nk.end(&ctx)
}
