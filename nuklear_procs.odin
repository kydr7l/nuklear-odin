package nuklear

import "core:c"

when ODIN_OS == .Windows {
	foreign import lib "lib/nuklear.lib"
} else {
	foreign import lib {"lib/libnuklear.a", "system:m"}
}

// nk_set_user_data is not bound. It exists only with NK_INCLUDE_COMMAND_USERDATA.
@(default_calling_convention = "c", link_prefix = "nk_")
foreign lib {
	// CONTEXT
	init_default :: proc(ctx: ^Context, font: ^User_Font) -> Bool ---
	init_fixed   :: proc(ctx: ^Context, memory: rawptr, size: Size, font: ^User_Font) -> Bool ---
	init         :: proc(ctx: ^Context, alloc: ^Allocator, font: ^User_Font) -> Bool ---
	init_custom  :: proc(ctx: ^Context, cmds: ^Buffer, pool: ^Buffer, font: ^User_Font) -> Bool ---
	clear        :: proc(ctx: ^Context) ---
	free         :: proc(ctx: ^Context) ---

	// INPUT
	input_begin   :: proc(ctx: ^Context) ---
	input_motion  :: proc(ctx: ^Context, x, y: c.int) ---
	input_key     :: proc(ctx: ^Context, key: Keys, down: Bool) ---
	input_button  :: proc(ctx: ^Context, button: Buttons, x, y: c.int, down: Bool) ---
	input_scroll  :: proc(ctx: ^Context, val: Vec2) ---
	input_char    :: proc(ctx: ^Context, ch: c.char) ---
	input_glyph   :: proc(ctx: ^Context, glyph: ^Glyph) ---
	input_unicode :: proc(ctx: ^Context, rune_: Rune) ---
	input_end     :: proc(ctx: ^Context) ---

	// DRAWING
	_begin      :: proc(ctx: ^Context) -> ^Command ---
	_next       :: proc(ctx: ^Context, cmd: ^Command) -> ^Command ---
	convert     :: proc(ctx: ^Context, cmds, vertices, elements: ^Buffer, config: ^Convert_Config) -> Flags ---
	_draw_begin :: proc(ctx: ^Context, buf: ^Buffer) -> ^Draw_Command ---
	_draw_end   :: proc(ctx: ^Context, buf: ^Buffer) -> ^Draw_Command ---
	_draw_next  :: proc(cmd: ^Draw_Command, buf: ^Buffer, ctx: ^Context) -> ^Draw_Command ---

	// WINDOW
	begin                          :: proc(ctx: ^Context, title: cstring, bounds: Rect, flags: Flags) -> Bool ---
	begin_titled                   :: proc(ctx: ^Context, name, title: cstring, bounds: Rect, flags: Flags) -> Bool ---
	end                            :: proc(ctx: ^Context) ---
	window_find                    :: proc(ctx: ^Context, name: cstring) -> ^Window ---
	window_get_bounds              :: proc(ctx: ^Context) -> Rect ---
	window_get_position            :: proc(ctx: ^Context) -> Vec2 ---
	window_get_size                :: proc(ctx: ^Context) -> Vec2 ---
	window_get_width               :: proc(ctx: ^Context) -> f32 ---
	window_get_height              :: proc(ctx: ^Context) -> f32 ---
	window_get_panel               :: proc(ctx: ^Context) -> ^Panel ---
	window_get_content_region      :: proc(ctx: ^Context) -> Rect ---
	window_get_content_region_min  :: proc(ctx: ^Context) -> Vec2 ---
	window_get_content_region_max  :: proc(ctx: ^Context) -> Vec2 ---
	window_get_content_region_size :: proc(ctx: ^Context) -> Vec2 ---
	window_get_canvas              :: proc(ctx: ^Context) -> ^Command_Buffer ---
	window_get_scroll              :: proc(ctx: ^Context, offset_x, offset_y: ^Uint) ---
	window_has_focus               :: proc(ctx: ^Context) -> Bool ---
	window_is_hovered              :: proc(ctx: ^Context) -> Bool ---
	window_is_collapsed            :: proc(ctx: ^Context, name: cstring) -> Bool ---
	window_is_closed               :: proc(ctx: ^Context, name: cstring) -> Bool ---
	window_is_hidden               :: proc(ctx: ^Context, name: cstring) -> Bool ---
	window_is_active               :: proc(ctx: ^Context, name: cstring) -> Bool ---
	window_is_any_hovered          :: proc(ctx: ^Context) -> Bool ---
	item_is_any_active             :: proc(ctx: ^Context) -> Bool ---
	window_set_bounds              :: proc(ctx: ^Context, name: cstring, bounds: Rect) ---
	window_set_position            :: proc(ctx: ^Context, name: cstring, pos: Vec2) ---
	window_set_size                :: proc(ctx: ^Context, name: cstring, size: Vec2) ---
	window_set_focus               :: proc(ctx: ^Context, name: cstring) ---
	window_set_scroll              :: proc(ctx: ^Context, offset_x, offset_y: Uint) ---
	window_close                   :: proc(ctx: ^Context, name: cstring) ---
	window_collapse                :: proc(ctx: ^Context, name: cstring, state: Collapse_States) ---
	window_collapse_if             :: proc(ctx: ^Context, name: cstring, state: Collapse_States, cond: c.int) ---
	window_show                    :: proc(ctx: ^Context, name: cstring, state: Show_States) ---
	window_show_if                 :: proc(ctx: ^Context, name: cstring, state: Show_States, cond: c.int) ---
	rule_horizontal                :: proc(ctx: ^Context, color: Color, rounding: Bool) ---

	// LAYOUT
	layout_set_min_row_height        :: proc(ctx: ^Context, height: f32) ---
	layout_reset_min_row_height      :: proc(ctx: ^Context) ---
	layout_widget_bounds             :: proc(ctx: ^Context) -> Rect ---
	layout_ratio_from_pixel          :: proc(ctx: ^Context, pixel_width: f32) -> f32 ---
	layout_row_dynamic               :: proc(ctx: ^Context, height: f32, cols: c.int) ---
	layout_row_static                :: proc(ctx: ^Context, height: f32, item_width, cols: c.int) ---
	layout_row_begin                 :: proc(ctx: ^Context, fmt: Layout_Format, row_height: f32, cols: c.int) ---
	layout_row_push                  :: proc(ctx: ^Context, value: f32) ---
	layout_row_end                   :: proc(ctx: ^Context) ---
	layout_row                       :: proc(ctx: ^Context, fmt: Layout_Format, height: f32, cols: c.int, ratio: [^]f32) ---
	layout_row_template_begin        :: proc(ctx: ^Context, row_height: f32) ---
	layout_row_template_push_dynamic :: proc(ctx: ^Context) ---
	layout_row_template_push_variable :: proc(ctx: ^Context, min_width: f32) ---
	layout_row_template_push_static  :: proc(ctx: ^Context, width: f32) ---
	layout_row_template_end          :: proc(ctx: ^Context) ---
	layout_space_begin               :: proc(ctx: ^Context, fmt: Layout_Format, height: f32, widget_count: c.int) ---
	layout_space_push                :: proc(ctx: ^Context, bounds: Rect) ---
	layout_space_end                 :: proc(ctx: ^Context) ---
	layout_space_bounds              :: proc(ctx: ^Context) -> Rect ---
	layout_space_to_screen           :: proc(ctx: ^Context, vec: Vec2) -> Vec2 ---
	layout_space_to_local            :: proc(ctx: ^Context, vec: Vec2) -> Vec2 ---
	layout_space_rect_to_screen      :: proc(ctx: ^Context, bounds: Rect) -> Rect ---
	layout_space_rect_to_local       :: proc(ctx: ^Context, bounds: Rect) -> Rect ---
	spacer                           :: proc(ctx: ^Context) ---

	// GROUP
	group_begin                 :: proc(ctx: ^Context, title: cstring, flags: Flags) -> Bool ---
	group_begin_titled          :: proc(ctx: ^Context, name, title: cstring, flags: Flags) -> Bool ---
	group_end                   :: proc(ctx: ^Context) ---
	group_scrolled_offset_begin :: proc(ctx: ^Context, x_offset, y_offset: ^Uint, title: cstring, flags: Flags) -> Bool ---
	group_scrolled_begin        :: proc(ctx: ^Context, off: ^Scroll, title: cstring, flags: Flags) -> Bool ---
	group_scrolled_end          :: proc(ctx: ^Context) ---
	group_get_scroll            :: proc(ctx: ^Context, id: cstring, x_offset, y_offset: ^Uint) ---
	group_set_scroll            :: proc(ctx: ^Context, id: cstring, x_offset, y_offset: Uint) ---

	// TREE
	tree_push_hashed          :: proc(ctx: ^Context, type: Tree_Type, title: cstring, initial_state: Collapse_States, hash: cstring, len: c.int, seed: c.int) -> Bool ---
	tree_image_push_hashed    :: proc(ctx: ^Context, type: Tree_Type, img: Image, title: cstring, initial_state: Collapse_States, hash: cstring, len: c.int, seed: c.int) -> Bool ---
	tree_pop                  :: proc(ctx: ^Context) ---
	tree_state_push           :: proc(ctx: ^Context, type: Tree_Type, title: cstring, state: ^Collapse_States) -> Bool ---
	tree_state_image_push     :: proc(ctx: ^Context, type: Tree_Type, img: Image, title: cstring, state: ^Collapse_States) -> Bool ---
	tree_state_pop            :: proc(ctx: ^Context) ---
	tree_element_push_hashed  :: proc(ctx: ^Context, type: Tree_Type, title: cstring, initial_state: Collapse_States, selected: ^Bool, hash: cstring, len: c.int, seed: c.int) -> Bool ---
	tree_element_image_push_hashed :: proc(ctx: ^Context, type: Tree_Type, img: Image, title: cstring, initial_state: Collapse_States, selected: ^Bool, hash: cstring, len: c.int, seed: c.int) -> Bool ---
	tree_element_pop          :: proc(ctx: ^Context) ---

	// LIST VIEW
	list_view_begin :: proc(ctx: ^Context, out: ^List_View, id: cstring, flags: Flags, row_height, row_count: c.int) -> Bool ---
	list_view_end   :: proc(view: ^List_View) ---

	// WIDGET
	widget                   :: proc(bounds: ^Rect, ctx: ^Context) -> Widget_Layout_States ---
	widget_bounds            :: proc(ctx: ^Context) -> Rect ---
	widget_position          :: proc(ctx: ^Context) -> Vec2 ---
	widget_size              :: proc(ctx: ^Context) -> Vec2 ---
	widget_width             :: proc(ctx: ^Context) -> f32 ---
	widget_height            :: proc(ctx: ^Context) -> f32 ---
	widget_is_hovered        :: proc(ctx: ^Context) -> Bool ---
	widget_is_mouse_clicked  :: proc(ctx: ^Context, button: Buttons) -> Bool ---
	widget_has_mouse_click_down :: proc(ctx: ^Context, button: Buttons, down: Bool) -> Bool ---
	spacing                  :: proc(ctx: ^Context, cols: c.int) ---
	widget_disable_begin     :: proc(ctx: ^Context) ---
	widget_disable_end       :: proc(ctx: ^Context) ---
}

// The loop state of the nk_foreach macro. Set only ctx.
Command_Iterator :: struct {
	ctx:     ^Context,
	cmd:     ^Command,
	started: bool,
}

// Use it as: it := nk.Command_Iterator{ctx = ctx}; for cmd in nk.foreach(&it) {}
foreach :: proc(it: ^Command_Iterator) -> (cmd: ^Command, ok: bool) {
	if it.started {
		it.cmd = _next(it.ctx, it.cmd)
	} else {
		it.cmd = _begin(it.ctx)
		it.started = true
	}
	return it.cmd, it.cmd != nil
}

// The loop state of the nk_draw_foreach macro. Set only ctx and cmds.
Draw_Iterator :: struct {
	ctx:     ^Context,
	cmds:    ^Buffer,
	cmd:     ^Draw_Command,
	started: bool,
}

draw_foreach :: proc(it: ^Draw_Iterator) -> (cmd: ^Draw_Command, ok: bool) {
	if it.started {
		it.cmd = _draw_next(it.cmd, it.cmds, it.ctx)
	} else {
		it.cmd = _draw_begin(it.ctx, it.cmds)
		it.started = true
	}
	return it.cmd, it.cmd != nil
}

// The tree procedures below replace the C macros.
// The hash is the file path of the caller. The seed is the line, or the id.
@(private)
hash_of :: proc(path: string) -> (cstring, c.int) {
	return cstring(raw_data(path)), c.int(len(path))
}

tree_push :: proc(ctx: ^Context, type: Tree_Type, title: cstring, state: Collapse_States, loc := #caller_location) -> Bool {
	hash, n := hash_of(loc.file_path)
	return tree_push_hashed(ctx, type, title, state, hash, n, c.int(loc.line))
}

tree_push_id :: proc(ctx: ^Context, type: Tree_Type, title: cstring, state: Collapse_States, id: c.int, loc := #caller_location) -> Bool {
	hash, n := hash_of(loc.file_path)
	return tree_push_hashed(ctx, type, title, state, hash, n, id)
}

tree_image_push :: proc(ctx: ^Context, type: Tree_Type, img: Image, title: cstring, state: Collapse_States, loc := #caller_location) -> Bool {
	hash, n := hash_of(loc.file_path)
	return tree_image_push_hashed(ctx, type, img, title, state, hash, n, c.int(loc.line))
}

tree_image_push_id :: proc(ctx: ^Context, type: Tree_Type, img: Image, title: cstring, state: Collapse_States, id: c.int, loc := #caller_location) -> Bool {
	hash, n := hash_of(loc.file_path)
	return tree_image_push_hashed(ctx, type, img, title, state, hash, n, id)
}

tree_element_push :: proc(ctx: ^Context, type: Tree_Type, title: cstring, state: Collapse_States, selected: ^Bool, loc := #caller_location) -> Bool {
	hash, n := hash_of(loc.file_path)
	return tree_element_push_hashed(ctx, type, title, state, selected, hash, n, c.int(loc.line))
}

tree_element_push_id :: proc(ctx: ^Context, type: Tree_Type, title: cstring, state: Collapse_States, selected: ^Bool, id: c.int, loc := #caller_location) -> Bool {
	hash, n := hash_of(loc.file_path)
	return tree_element_push_hashed(ctx, type, title, state, selected, hash, n, id)
}
