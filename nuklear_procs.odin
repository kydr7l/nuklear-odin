package nuklear

import "core:c"
import "core:fmt"

when ODIN_OS == .Windows {
	foreign import lib "lib/nuklear.lib"
} else {
	foreign import lib {"lib/libnuklear.a", "system:m"}
}

// nk_set_user_data and nk_draw_list_push_userdata are not bound. They exist only with NK_INCLUDE_COMMAND_USERDATA.
// The six procedures with a va_list parameter are not bound. Odin cannot pass a va_list.
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

	// TEXT
	text                :: proc(ctx: ^Context, text: cstring, len: c.int, flags: Flags) ---
	text_colored        :: proc(ctx: ^Context, text: cstring, len: c.int, flags: Flags, color: Color) ---
	text_wrap           :: proc(ctx: ^Context, text: cstring, len: c.int) ---
	text_wrap_colored   :: proc(ctx: ^Context, text: cstring, len: c.int, color: Color) ---
	label               :: proc(ctx: ^Context, text: cstring, align: Flags) ---
	label_colored       :: proc(ctx: ^Context, text: cstring, align: Flags, color: Color) ---
	label_wrap          :: proc(ctx: ^Context, text: cstring) ---
	label_colored_wrap  :: proc(ctx: ^Context, text: cstring, color: Color) ---
	image               :: proc(ctx: ^Context, img: Image) ---
	image_color         :: proc(ctx: ^Context, img: Image, color: Color) ---
	labelf              :: proc(ctx: ^Context, flags: Flags, fmt: cstring, #c_vararg args: ..any) ---
	labelf_colored      :: proc(ctx: ^Context, flags: Flags, color: Color, fmt: cstring, #c_vararg args: ..any) ---
	labelf_wrap         :: proc(ctx: ^Context, fmt: cstring, #c_vararg args: ..any) ---
	labelf_colored_wrap :: proc(ctx: ^Context, color: Color, fmt: cstring, #c_vararg args: ..any) ---
	value_bool          :: proc(ctx: ^Context, prefix: cstring, value: c.int) ---
	value_int           :: proc(ctx: ^Context, prefix: cstring, value: c.int) ---
	value_uint          :: proc(ctx: ^Context, prefix: cstring, value: c.uint) ---
	value_float         :: proc(ctx: ^Context, prefix: cstring, value: f32) ---
	value_color_byte    :: proc(ctx: ^Context, prefix: cstring, color: Color) ---
	value_color_float   :: proc(ctx: ^Context, prefix: cstring, color: Color) ---
	value_color_hex     :: proc(ctx: ^Context, prefix: cstring, color: Color) ---

	// LINK
	link_text                  :: proc(ctx: ^Context, title: cstring, len: c.int, align: Flags) -> Bool ---
	link_label                 :: proc(ctx: ^Context, title: cstring, align: Flags) -> Bool ---
	link_text_styled           :: proc(ctx: ^Context, style: ^Style_Link, title: cstring, len: c.int, align: Flags) -> Bool ---
	link_label_styled          :: proc(ctx: ^Context, style: ^Style_Link, title: cstring, align: Flags) -> Bool ---
	link_text_underline        :: proc(ctx: ^Context, title: cstring, len: c.int, align: Flags, underline: Link_Underline) -> Bool ---
	link_label_underline       :: proc(ctx: ^Context, title: cstring, align: Flags, underline: Link_Underline) -> Bool ---
	link_text_hover_underline  :: proc(ctx: ^Context, title: cstring, len: c.int, align: Flags) -> Bool ---
	link_label_hover_underline :: proc(ctx: ^Context, title: cstring, align: Flags) -> Bool ---
	link_text_no_underline     :: proc(ctx: ^Context, title: cstring, len: c.int, align: Flags) -> Bool ---
	link_label_no_underline    :: proc(ctx: ^Context, title: cstring, align: Flags) -> Bool ---
	link_text_colored          :: proc(ctx: ^Context, title: cstring, len: c.int, align: Flags, color: Color) -> Bool ---
	link_label_colored         :: proc(ctx: ^Context, title: cstring, align: Flags, color: Color) -> Bool ---

	// BUTTON
	button_text                :: proc(ctx: ^Context, title: cstring, len: c.int) -> Bool ---
	button_label               :: proc(ctx: ^Context, title: cstring) -> Bool ---
	button_color               :: proc(ctx: ^Context, color: Color) -> Bool ---
	button_symbol              :: proc(ctx: ^Context, symbol: Symbol_Type) -> Bool ---
	button_image               :: proc(ctx: ^Context, img: Image) -> Bool ---
	button_symbol_label        :: proc(ctx: ^Context, symbol: Symbol_Type, text: cstring, text_alignment: Flags) -> Bool ---
	button_symbol_text         :: proc(ctx: ^Context, symbol: Symbol_Type, text: cstring, len: c.int, alignment: Flags) -> Bool ---
	button_image_label         :: proc(ctx: ^Context, img: Image, text: cstring, text_alignment: Flags) -> Bool ---
	button_image_text          :: proc(ctx: ^Context, img: Image, text: cstring, len: c.int, alignment: Flags) -> Bool ---
	button_text_styled         :: proc(ctx: ^Context, style: ^Style_Button, title: cstring, len: c.int) -> Bool ---
	button_label_styled        :: proc(ctx: ^Context, style: ^Style_Button, title: cstring) -> Bool ---
	button_symbol_styled       :: proc(ctx: ^Context, style: ^Style_Button, symbol: Symbol_Type) -> Bool ---
	button_image_styled        :: proc(ctx: ^Context, style: ^Style_Button, img: Image) -> Bool ---
	button_symbol_text_styled  :: proc(ctx: ^Context, style: ^Style_Button, symbol: Symbol_Type, text: cstring, len: c.int, alignment: Flags) -> Bool ---
	button_symbol_label_styled :: proc(ctx: ^Context, style: ^Style_Button, symbol: Symbol_Type, title: cstring, align: Flags) -> Bool ---
	button_image_label_styled  :: proc(ctx: ^Context, style: ^Style_Button, img: Image, text: cstring, text_alignment: Flags) -> Bool ---
	button_image_text_styled   :: proc(ctx: ^Context, style: ^Style_Button, img: Image, text: cstring, len: c.int, alignment: Flags) -> Bool ---
	button_set_behavior        :: proc(ctx: ^Context, behavior: Button_Behavior) ---
	button_push_behavior       :: proc(ctx: ^Context, behavior: Button_Behavior) -> Bool ---
	button_pop_behavior        :: proc(ctx: ^Context) -> Bool ---

	// CHECKBOX
	check_label          :: proc(ctx: ^Context, text: cstring, active: Bool) -> Bool ---
	check_text           :: proc(ctx: ^Context, text: cstring, len: c.int, active: Bool) -> Bool ---
	check_text_align     :: proc(ctx: ^Context, text: cstring, len: c.int, active: Bool, widget_alignment, text_alignment: Flags) -> Bool ---
	check_flags_label    :: proc(ctx: ^Context, text: cstring, flags, value: c.uint) -> c.uint ---
	check_flags_text     :: proc(ctx: ^Context, text: cstring, len: c.int, flags, value: c.uint) -> c.uint ---
	checkbox_label       :: proc(ctx: ^Context, text: cstring, active: ^Bool) -> Bool ---
	checkbox_label_align :: proc(ctx: ^Context, label: cstring, active: ^Bool, widget_alignment, text_alignment: Flags) -> Bool ---
	checkbox_text        :: proc(ctx: ^Context, text: cstring, len: c.int, active: ^Bool) -> Bool ---
	checkbox_text_align  :: proc(ctx: ^Context, text: cstring, len: c.int, active: ^Bool, widget_alignment, text_alignment: Flags) -> Bool ---
	checkbox_flags_label :: proc(ctx: ^Context, text: cstring, flags: ^c.uint, value: c.uint) -> Bool ---
	checkbox_flags_text  :: proc(ctx: ^Context, text: cstring, len: c.int, flags: ^c.uint, value: c.uint) -> Bool ---

	// RADIO BUTTON
	radio_label        :: proc(ctx: ^Context, text: cstring, active: ^Bool) -> Bool ---
	radio_label_align  :: proc(ctx: ^Context, label: cstring, active: ^Bool, widget_alignment, text_alignment: Flags) -> Bool ---
	radio_text         :: proc(ctx: ^Context, text: cstring, len: c.int, active: ^Bool) -> Bool ---
	radio_text_align   :: proc(ctx: ^Context, text: cstring, len: c.int, active: ^Bool, widget_alignment, text_alignment: Flags) -> Bool ---
	option_label       :: proc(ctx: ^Context, text: cstring, active: Bool) -> Bool ---
	option_label_align :: proc(ctx: ^Context, label: cstring, active: Bool, widget_alignment, text_alignment: Flags) -> Bool ---
	option_text        :: proc(ctx: ^Context, text: cstring, len: c.int, active: Bool) -> Bool ---
	option_text_align  :: proc(ctx: ^Context, text: cstring, len: c.int, is_active: Bool, widget_alignment, text_alignment: Flags) -> Bool ---

	// SELECTABLE
	selectable_label        :: proc(ctx: ^Context, text: cstring, align: Flags, value: ^Bool) -> Bool ---
	selectable_text         :: proc(ctx: ^Context, text: cstring, len: c.int, align: Flags, value: ^Bool) -> Bool ---
	selectable_image_label  :: proc(ctx: ^Context, img: Image, text: cstring, align: Flags, value: ^Bool) -> Bool ---
	selectable_image_text   :: proc(ctx: ^Context, img: Image, text: cstring, len: c.int, align: Flags, value: ^Bool) -> Bool ---
	selectable_symbol_label :: proc(ctx: ^Context, symbol: Symbol_Type, text: cstring, align: Flags, value: ^Bool) -> Bool ---
	selectable_symbol_text  :: proc(ctx: ^Context, symbol: Symbol_Type, text: cstring, len: c.int, align: Flags, value: ^Bool) -> Bool ---
	select_label            :: proc(ctx: ^Context, text: cstring, align: Flags, value: Bool) -> Bool ---
	select_text             :: proc(ctx: ^Context, text: cstring, len: c.int, align: Flags, value: Bool) -> Bool ---
	select_image_label      :: proc(ctx: ^Context, img: Image, text: cstring, align: Flags, value: Bool) -> Bool ---
	select_image_text       :: proc(ctx: ^Context, img: Image, text: cstring, len: c.int, align: Flags, value: Bool) -> Bool ---
	select_symbol_label     :: proc(ctx: ^Context, symbol: Symbol_Type, text: cstring, align: Flags, value: Bool) -> Bool ---
	select_symbol_text      :: proc(ctx: ^Context, symbol: Symbol_Type, text: cstring, len: c.int, align: Flags, value: Bool) -> Bool ---

	// SLIDER
	slide_float  :: proc(ctx: ^Context, min, val, max, step: f32) -> f32 ---
	slide_int    :: proc(ctx: ^Context, min, val, max, step: c.int) -> c.int ---
	slider_float :: proc(ctx: ^Context, min: f32, val: ^f32, max, step: f32) -> Bool ---
	slider_int   :: proc(ctx: ^Context, min: c.int, val: ^c.int, max, step: c.int) -> Bool ---

	// KNOB
	knob_float :: proc(ctx: ^Context, min: f32, val: ^f32, max, step: f32, zero_direction: Heading, dead_zone_degrees: f32) -> Bool ---
	knob_int   :: proc(ctx: ^Context, min: c.int, val: ^c.int, max, step: c.int, zero_direction: Heading, dead_zone_degrees: f32) -> Bool ---

	// PROGRESSBAR
	progress :: proc(ctx: ^Context, cur: ^Size, max: Size, modifyable: Bool) -> Bool ---
	prog     :: proc(ctx: ^Context, cur, max: Size, modifyable: Bool) -> Size ---

	// COLOR PICKER
	color_picker :: proc(ctx: ^Context, color: Colorf, fmt: Color_Format) -> Colorf ---
	color_pick   :: proc(ctx: ^Context, color: ^Colorf, fmt: Color_Format) -> Bool ---

	// PROPERTIES
	property_int    :: proc(ctx: ^Context, name: cstring, min: c.int, val: ^c.int, max, step: c.int, inc_per_pixel: f32) -> Bool ---
	property_float  :: proc(ctx: ^Context, name: cstring, min: f32, val: ^f32, max, step, inc_per_pixel: f32) -> Bool ---
	property_double :: proc(ctx: ^Context, name: cstring, min: f64, val: ^f64, max, step: f64, inc_per_pixel: f32) -> Bool ---
	propertyi       :: proc(ctx: ^Context, name: cstring, min, val, max, step: c.int, inc_per_pixel: f32) -> c.int ---
	propertyf       :: proc(ctx: ^Context, name: cstring, min, val, max, step, inc_per_pixel: f32) -> f32 ---
	propertyd       :: proc(ctx: ^Context, name: cstring, min, val, max, step: f64, inc_per_pixel: f32) -> f64 ---

	// TEXT EDIT
	edit_string                 :: proc(ctx: ^Context, flags: Flags, buffer: [^]c.char, len: ^c.int, max: c.int, filter: Plugin_Filter) -> Flags ---
	edit_string_zero_terminated :: proc(ctx: ^Context, flags: Flags, buffer: [^]c.char, max: c.int, filter: Plugin_Filter) -> Flags ---
	edit_buffer                 :: proc(ctx: ^Context, flags: Flags, edit: ^Text_Edit, filter: Plugin_Filter) -> Flags ---
	edit_focus                  :: proc(ctx: ^Context, flags: Flags) ---
	edit_unfocus                :: proc(ctx: ^Context) ---

	// CHART
	chart_begin            :: proc(ctx: ^Context, type: Chart_Type, num: c.int, min, max: f32) -> Bool ---
	chart_begin_colored    :: proc(ctx: ^Context, type: Chart_Type, color, active: Color, num: c.int, min, max: f32) -> Bool ---
	chart_add_slot         :: proc(ctx: ^Context, type: Chart_Type, count: c.int, min_value, max_value: f32) ---
	chart_add_slot_colored :: proc(ctx: ^Context, type: Chart_Type, color, active: Color, count: c.int, min_value, max_value: f32) ---
	chart_push             :: proc(ctx: ^Context, value: f32) -> Flags ---
	chart_push_slot        :: proc(ctx: ^Context, value: f32, slot: c.int) -> Flags ---
	chart_end              :: proc(ctx: ^Context) ---
	plot                   :: proc(ctx: ^Context, type: Chart_Type, values: [^]f32, count, offset: c.int) ---
	plot_function          :: proc(ctx: ^Context, type: Chart_Type, userdata: rawptr, value_getter: proc "c" (user: rawptr, index: c.int) -> f32, count, offset: c.int) ---

	// POPUP
	popup_begin      :: proc(ctx: ^Context, type: Popup_Type, text: cstring, flags: Flags, bounds: Rect) -> Bool ---
	popup_close      :: proc(ctx: ^Context) ---
	popup_end        :: proc(ctx: ^Context) ---
	popup_get_scroll :: proc(ctx: ^Context, offset_x, offset_y: ^Uint) ---
	popup_set_scroll :: proc(ctx: ^Context, offset_x, offset_y: Uint) ---

	// COMBOBOX
	combo              :: proc(ctx: ^Context, items: [^]cstring, count, selected, item_height: c.int, size: Vec2) -> c.int ---
	combo_separator    :: proc(ctx: ^Context, items_separated_by_separator: cstring, separator, selected, count, item_height: c.int, size: Vec2) -> c.int ---
	combo_string       :: proc(ctx: ^Context, items_separated_by_zeros: cstring, selected, count, item_height: c.int, size: Vec2) -> c.int ---
	combo_callback     :: proc(ctx: ^Context, item_getter: proc "c" (user: rawptr, index: c.int, out: ^cstring), userdata: rawptr, selected, count, item_height: c.int, size: Vec2) -> c.int ---
	combobox           :: proc(ctx: ^Context, items: [^]cstring, count: c.int, selected: ^c.int, item_height: c.int, size: Vec2) -> Bool ---
	combobox_string    :: proc(ctx: ^Context, items_separated_by_zeros: cstring, selected: ^c.int, count, item_height: c.int, size: Vec2) -> Bool ---
	combobox_separator :: proc(ctx: ^Context, items_separated_by_separator: cstring, separator: c.int, selected: ^c.int, count, item_height: c.int, size: Vec2) -> Bool ---
	combobox_callback  :: proc(ctx: ^Context, item_getter: proc "c" (user: rawptr, index: c.int, out: ^cstring), userdata: rawptr, selected: ^c.int, count, item_height: c.int, size: Vec2) -> Bool ---

	// ABSTRACT COMBOBOX
	combo_begin_text         :: proc(ctx: ^Context, selected: cstring, len: c.int, size: Vec2) -> Bool ---
	combo_begin_label        :: proc(ctx: ^Context, selected: cstring, size: Vec2) -> Bool ---
	combo_begin_color        :: proc(ctx: ^Context, color: Color, size: Vec2) -> Bool ---
	combo_begin_symbol       :: proc(ctx: ^Context, symbol: Symbol_Type, size: Vec2) -> Bool ---
	combo_begin_symbol_label :: proc(ctx: ^Context, selected: cstring, symbol: Symbol_Type, size: Vec2) -> Bool ---
	combo_begin_symbol_text  :: proc(ctx: ^Context, selected: cstring, len: c.int, symbol: Symbol_Type, size: Vec2) -> Bool ---
	combo_begin_image        :: proc(ctx: ^Context, img: Image, size: Vec2) -> Bool ---
	combo_begin_image_label  :: proc(ctx: ^Context, selected: cstring, img: Image, size: Vec2) -> Bool ---
	combo_begin_image_text   :: proc(ctx: ^Context, selected: cstring, len: c.int, img: Image, size: Vec2) -> Bool ---
	combo_item_label         :: proc(ctx: ^Context, text: cstring, alignment: Flags) -> Bool ---
	combo_item_text          :: proc(ctx: ^Context, text: cstring, len: c.int, alignment: Flags) -> Bool ---
	combo_item_image_label   :: proc(ctx: ^Context, img: Image, text: cstring, alignment: Flags) -> Bool ---
	combo_item_image_text    :: proc(ctx: ^Context, img: Image, text: cstring, len: c.int, alignment: Flags) -> Bool ---
	combo_item_symbol_label  :: proc(ctx: ^Context, symbol: Symbol_Type, text: cstring, alignment: Flags) -> Bool ---
	combo_item_symbol_text   :: proc(ctx: ^Context, symbol: Symbol_Type, text: cstring, len: c.int, alignment: Flags) -> Bool ---
	combo_close              :: proc(ctx: ^Context) ---
	combo_end                :: proc(ctx: ^Context) ---

	// CONTEXTUAL
	contextual_begin             :: proc(ctx: ^Context, flags: Flags, size: Vec2, trigger_bounds: Rect) -> Bool ---
	contextual_item_text         :: proc(ctx: ^Context, text: cstring, len: c.int, align: Flags) -> Bool ---
	contextual_item_label        :: proc(ctx: ^Context, text: cstring, align: Flags) -> Bool ---
	contextual_item_image_label  :: proc(ctx: ^Context, img: Image, text: cstring, alignment: Flags) -> Bool ---
	contextual_item_image_text   :: proc(ctx: ^Context, img: Image, text: cstring, len: c.int, alignment: Flags) -> Bool ---
	contextual_item_symbol_label :: proc(ctx: ^Context, symbol: Symbol_Type, text: cstring, alignment: Flags) -> Bool ---
	contextual_item_symbol_text  :: proc(ctx: ^Context, symbol: Symbol_Type, text: cstring, len: c.int, alignment: Flags) -> Bool ---
	contextual_close             :: proc(ctx: ^Context) ---
	contextual_end               :: proc(ctx: ^Context) ---

	// TOOLTIP
	tooltip                  :: proc(ctx: ^Context, text: cstring) ---
	tooltip_offset           :: proc(ctx: ^Context, text: cstring, position: Tooltip_Pos, offset: Vec2) ---
	do_tooltip               :: proc(ctx: ^Context, text: cstring, bounds: Rect) ---
	do_tooltip_delay         :: proc(ctx: ^Context, text: cstring, bounds: Rect, timer: ^f32) ---
	do_tooltip_delay_clicked :: proc(ctx: ^Context, text: cstring, bounds: Rect, timer: ^f32, clicked: ^Bool) ---
	tooltipf                 :: proc(ctx: ^Context, fmt: cstring, #c_vararg args: ..any) ---
	tooltipf_offset          :: proc(ctx: ^Context, pos: Tooltip_Pos, offset: Vec2, fmt: cstring, #c_vararg args: ..any) ---
	tooltip_begin            :: proc(ctx: ^Context, width: f32) -> Bool ---
	tooltip_begin_offset     :: proc(ctx: ^Context, width: f32, pos: Tooltip_Pos, offset: Vec2) -> Bool ---
	tooltip_end              :: proc(ctx: ^Context) ---

	// MENU
	menubar_begin           :: proc(ctx: ^Context) ---
	menubar_end             :: proc(ctx: ^Context) ---
	menu_begin_text         :: proc(ctx: ^Context, title: cstring, title_len: c.int, align: Flags, size: Vec2) -> Bool ---
	menu_begin_label        :: proc(ctx: ^Context, text: cstring, align: Flags, size: Vec2) -> Bool ---
	menu_begin_image        :: proc(ctx: ^Context, text: cstring, img: Image, size: Vec2) -> Bool ---
	menu_begin_image_text   :: proc(ctx: ^Context, text: cstring, len: c.int, align: Flags, img: Image, size: Vec2) -> Bool ---
	menu_begin_image_label  :: proc(ctx: ^Context, text: cstring, align: Flags, img: Image, size: Vec2) -> Bool ---
	menu_begin_symbol       :: proc(ctx: ^Context, text: cstring, symbol: Symbol_Type, size: Vec2) -> Bool ---
	menu_begin_symbol_text  :: proc(ctx: ^Context, text: cstring, len: c.int, align: Flags, symbol: Symbol_Type, size: Vec2) -> Bool ---
	menu_begin_symbol_label :: proc(ctx: ^Context, text: cstring, align: Flags, symbol: Symbol_Type, size: Vec2) -> Bool ---
	menu_item_text          :: proc(ctx: ^Context, text: cstring, len: c.int, align: Flags) -> Bool ---
	menu_item_label         :: proc(ctx: ^Context, text: cstring, alignment: Flags) -> Bool ---
	menu_item_image_label   :: proc(ctx: ^Context, img: Image, text: cstring, alignment: Flags) -> Bool ---
	menu_item_image_text    :: proc(ctx: ^Context, img: Image, text: cstring, len: c.int, alignment: Flags) -> Bool ---
	menu_item_symbol_text   :: proc(ctx: ^Context, symbol: Symbol_Type, text: cstring, len: c.int, alignment: Flags) -> Bool ---
	menu_item_symbol_label  :: proc(ctx: ^Context, symbol: Symbol_Type, text: cstring, alignment: Flags) -> Bool ---
	menu_close              :: proc(ctx: ^Context) ---
	menu_end                :: proc(ctx: ^Context) ---

	// STYLE
	style_default           :: proc(ctx: ^Context) ---
	style_from_table        :: proc(ctx: ^Context, table: [^]Color) ---
	style_load_cursor       :: proc(ctx: ^Context, style: Style_Cursor, cursor: ^Cursor) ---
	style_load_all_cursors  :: proc(ctx: ^Context, cursors: [^]Cursor) ---
	style_get_color_by_name :: proc(c_: Style_Colors) -> cstring ---
	style_set_font          :: proc(ctx: ^Context, font: ^User_Font) ---
	style_set_cursor        :: proc(ctx: ^Context, style: Style_Cursor) -> Bool ---
	style_show_cursor       :: proc(ctx: ^Context) ---
	style_hide_cursor       :: proc(ctx: ^Context) ---
	style_push_font         :: proc(ctx: ^Context, font: ^User_Font) -> Bool ---
	style_push_float        :: proc(ctx: ^Context, addr: ^f32, value: f32) -> Bool ---
	style_push_vec2         :: proc(ctx: ^Context, addr: ^Vec2, value: Vec2) -> Bool ---
	style_push_style_item   :: proc(ctx: ^Context, addr: ^Style_Item, value: Style_Item) -> Bool ---
	style_push_flags        :: proc(ctx: ^Context, addr: ^Flags, value: Flags) -> Bool ---
	style_push_color        :: proc(ctx: ^Context, addr: ^Color, value: Color) -> Bool ---
	style_pop_font          :: proc(ctx: ^Context) -> Bool ---
	style_pop_float         :: proc(ctx: ^Context) -> Bool ---
	style_pop_vec2          :: proc(ctx: ^Context) -> Bool ---
	style_pop_style_item    :: proc(ctx: ^Context) -> Bool ---
	style_pop_flags         :: proc(ctx: ^Context) -> Bool ---
	style_pop_color         :: proc(ctx: ^Context) -> Bool ---

	// COLOR
	rgb            :: proc(r, g, b: c.int) -> Color ---
	rgb_iv         :: proc(rgb: [^]c.int) -> Color ---
	rgb_bv         :: proc(rgb: [^]Byte) -> Color ---
	rgb_f          :: proc(r, g, b: f32) -> Color ---
	rgb_fv         :: proc(rgb: [^]f32) -> Color ---
	rgb_cf         :: proc(c_: Colorf) -> Color ---
	rgb_hex        :: proc(rgb: cstring) -> Color ---
	rgb_factor     :: proc(col: Color, factor: f32) -> Color ---
	rgba           :: proc(r, g, b, a: c.int) -> Color ---
	rgba_u32       :: proc(in_: Uint) -> Color ---
	rgba_iv        :: proc(rgba: [^]c.int) -> Color ---
	rgba_bv        :: proc(rgba: [^]Byte) -> Color ---
	rgba_f         :: proc(r, g, b, a: f32) -> Color ---
	rgba_fv        :: proc(rgba: [^]f32) -> Color ---
	rgba_cf        :: proc(c_: Colorf) -> Color ---
	rgba_hex       :: proc(rgb: cstring) -> Color ---
	hsva_colorf    :: proc(h, s, v, a: f32) -> Colorf ---
	hsva_colorfv   :: proc(c_: [^]f32) -> Colorf ---
	colorf_hsva_f  :: proc(out_h, out_s, out_v, out_a: ^f32, in_: Colorf) ---
	colorf_hsva_fv :: proc(hsva: [^]f32, in_: Colorf) ---
	hsv            :: proc(h, s, v: c.int) -> Color ---
	hsv_iv         :: proc(hsv: [^]c.int) -> Color ---
	hsv_bv         :: proc(hsv: [^]Byte) -> Color ---
	hsv_f          :: proc(h, s, v: f32) -> Color ---
	hsv_fv         :: proc(hsv: [^]f32) -> Color ---
	hsva           :: proc(h, s, v, a: c.int) -> Color ---
	hsva_iv        :: proc(hsva: [^]c.int) -> Color ---
	hsva_bv        :: proc(hsva: [^]Byte) -> Color ---
	hsva_f         :: proc(h, s, v, a: f32) -> Color ---
	hsva_fv        :: proc(hsva: [^]f32) -> Color ---
	color_f        :: proc(r, g, b, a: ^f32, color: Color) ---
	color_fv       :: proc(rgba_out: [^]f32, color: Color) ---
	color_cf       :: proc(color: Color) -> Colorf ---
	color_d        :: proc(r, g, b, a: ^f64, color: Color) ---
	color_dv       :: proc(rgba_out: [^]f64, color: Color) ---
	color_u32      :: proc(color: Color) -> Uint ---
	color_hex_rgba :: proc(output: [^]c.char, color: Color) ---
	color_hex_rgb  :: proc(output: [^]c.char, color: Color) ---
	color_hsv_i    :: proc(out_h, out_s, out_v: ^c.int, color: Color) ---
	color_hsv_b    :: proc(out_h, out_s, out_v: ^Byte, color: Color) ---
	color_hsv_iv   :: proc(hsv_out: [^]c.int, color: Color) ---
	color_hsv_bv   :: proc(hsv_out: [^]Byte, color: Color) ---
	color_hsv_f    :: proc(out_h, out_s, out_v: ^f32, color: Color) ---
	color_hsv_fv   :: proc(hsv_out: [^]f32, color: Color) ---
	color_hsva_i   :: proc(h, s, v, a: ^c.int, color: Color) ---
	color_hsva_b   :: proc(h, s, v, a: ^Byte, color: Color) ---
	color_hsva_iv  :: proc(hsva_out: [^]c.int, color: Color) ---
	color_hsva_bv  :: proc(hsva_out: [^]Byte, color: Color) ---
	color_hsva_f   :: proc(out_h, out_s, out_v, out_a: ^f32, color: Color) ---
	color_hsva_fv  :: proc(hsva_out: [^]f32, color: Color) ---

	// IMAGE
	handle_ptr              :: proc(ptr: rawptr) -> Handle ---
	handle_id               :: proc(id: c.int) -> Handle ---
	image_handle            :: proc(handle: Handle) -> Image ---
	image_ptr               :: proc(ptr: rawptr) -> Image ---
	image_id                :: proc(id: c.int) -> Image ---
	image_is_subimage       :: proc(img: ^Image) -> Bool ---
	subimage_ptr            :: proc(ptr: rawptr, w, h: Ushort, sub_region: Rect) -> Image ---
	subimage_id             :: proc(id: c.int, w, h: Ushort, sub_region: Rect) -> Image ---
	subimage_handle         :: proc(handle: Handle, w, h: Ushort, sub_region: Rect) -> Image ---
	nine_slice_handle       :: proc(handle: Handle, l, t, r, b: Ushort) -> Nine_Slice ---
	nine_slice_ptr          :: proc(ptr: rawptr, l, t, r, b: Ushort) -> Nine_Slice ---
	nine_slice_id           :: proc(id: c.int, l, t, r, b: Ushort) -> Nine_Slice ---
	nine_slice_is_sub9slice :: proc(img: ^Nine_Slice) -> c.int ---
	sub9slice_ptr           :: proc(ptr: rawptr, w, h: Ushort, sub_region: Rect, l, t, r, b: Ushort) -> Nine_Slice ---
	sub9slice_id            :: proc(id: c.int, w, h: Ushort, sub_region: Rect, l, t, r, b: Ushort) -> Nine_Slice ---
	sub9slice_handle        :: proc(handle: Handle, w, h: Ushort, sub_region: Rect, l, t, r, b: Ushort) -> Nine_Slice ---

	// MATH
	murmur_hash             :: proc(key: rawptr, len: c.int, seed: Hash) -> Hash ---
	triangle_from_direction :: proc(result: ^Vec2, r: Rect, pad_x, pad_y: f32, direction: Heading) ---
	vec2                    :: proc(x, y: f32) -> Vec2 ---
	vec2i                   :: proc(x, y: c.int) -> Vec2 ---
	vec2v                   :: proc(xy: [^]f32) -> Vec2 ---
	vec2iv                  :: proc(xy: [^]c.int) -> Vec2 ---
	get_null_rect           :: proc() -> Rect ---
	rect                    :: proc(x, y, w, h: f32) -> Rect ---
	recti                   :: proc(x, y, w, h: c.int) -> Rect ---
	recta                   :: proc(pos, size: Vec2) -> Rect ---
	rectv                   :: proc(xywh: [^]f32) -> Rect ---
	rectiv                  :: proc(xywh: [^]c.int) -> Rect ---
	rect_pos                :: proc(bounds: Rect) -> Vec2 ---
	rect_size               :: proc(bounds: Rect) -> Vec2 ---

	// STRING
	strlen                :: proc(str: cstring) -> c.int ---
	stricmp               :: proc(s1, s2: cstring) -> c.int ---
	stricmpn              :: proc(s1, s2: cstring, n: c.int) -> c.int ---
	strtoi                :: proc(str: cstring, endptr: ^cstring) -> c.int ---
	strtof                :: proc(str: cstring, endptr: ^cstring) -> f32 ---
	strtod                :: proc(str: cstring, endptr: ^cstring) -> f64 ---
	strfilter             :: proc(text, regexp: cstring) -> c.int ---
	strmatch_fuzzy_string :: proc(str, pattern: cstring, out_score: ^c.int) -> c.int ---
	strmatch_fuzzy_text   :: proc(txt: cstring, txt_len: c.int, pattern: cstring, out_score: ^c.int) -> c.int ---
	str_init_default      :: proc(str: ^Str) ---
	str_init              :: proc(str: ^Str, alloc: ^Allocator, size: Size) ---
	str_init_fixed        :: proc(str: ^Str, memory: rawptr, size: Size) ---
	str_clear             :: proc(str: ^Str) ---
	str_free              :: proc(str: ^Str) ---
	str_append_text_char  :: proc(str: ^Str, text: cstring, len: c.int) -> c.int ---
	str_append_str_char   :: proc(str: ^Str, text: cstring) -> c.int ---
	str_append_text_utf8  :: proc(str: ^Str, text: cstring, len: c.int) -> c.int ---
	str_append_str_utf8   :: proc(str: ^Str, text: cstring) -> c.int ---
	str_append_text_runes :: proc(str: ^Str, runes: [^]Rune, n: c.int) -> c.int ---
	str_append_str_runes  :: proc(str: ^Str, runes: [^]Rune) -> c.int ---
	str_insert_at_char    :: proc(str: ^Str, pos: c.int, text: cstring, len: c.int) -> c.int ---
	str_insert_at_rune    :: proc(str: ^Str, pos: c.int, text: cstring, len: c.int) -> c.int ---
	str_insert_text_char  :: proc(str: ^Str, pos: c.int, text: cstring, len: c.int) -> c.int ---
	str_insert_str_char   :: proc(str: ^Str, pos: c.int, text: cstring) -> c.int ---
	str_insert_text_utf8  :: proc(str: ^Str, pos: c.int, text: cstring, len: c.int) -> c.int ---
	str_insert_str_utf8   :: proc(str: ^Str, pos: c.int, text: cstring) -> c.int ---
	str_insert_text_runes :: proc(str: ^Str, pos: c.int, runes: [^]Rune, n: c.int) -> c.int ---
	str_insert_str_runes  :: proc(str: ^Str, pos: c.int, runes: [^]Rune) -> c.int ---
	str_remove_chars      :: proc(str: ^Str, len: c.int) ---
	str_remove_runes      :: proc(str: ^Str, len: c.int) ---
	str_delete_chars      :: proc(str: ^Str, pos, len: c.int) ---
	str_delete_runes      :: proc(str: ^Str, pos, len: c.int) ---
	str_at_char           :: proc(str: ^Str, pos: c.int) -> [^]c.char ---
	str_at_rune           :: proc(str: ^Str, pos: c.int, unicode: ^Rune, len: ^c.int) -> [^]c.char ---
	str_rune_at           :: proc(str: ^Str, pos: c.int) -> Rune ---
	str_at_char_const     :: proc(str: ^Str, pos: c.int) -> cstring ---
	str_at_const          :: proc(str: ^Str, pos: c.int, unicode: ^Rune, len: ^c.int) -> cstring ---
	str_get               :: proc(str: ^Str) -> [^]c.char ---
	str_get_const         :: proc(str: ^Str) -> cstring ---
	str_len               :: proc(str: ^Str) -> c.int ---
	str_len_char          :: proc(str: ^Str) -> c.int ---

	// UTF-8
	utf_decode :: proc(chr: cstring, u: ^Rune, clen: c.int) -> c.int ---
	utf_encode :: proc(u: Rune, chr: [^]c.char, clen: c.int) -> c.int ---
	utf_len    :: proc(str: cstring, byte_len: c.int) -> c.int ---
	utf_at     :: proc(buffer: cstring, length, index: c.int, unicode: ^Rune, len: ^c.int) -> cstring ---

	// FONT
	font_default_glyph_ranges        :: proc() -> [^]Rune ---
	font_chinese_glyph_ranges        :: proc() -> [^]Rune ---
	font_cyrillic_glyph_ranges       :: proc() -> [^]Rune ---
	font_korean_glyph_ranges         :: proc() -> [^]Rune ---
	font_atlas_init_default          :: proc(atlas: ^Font_Atlas) ---
	font_atlas_init                  :: proc(atlas: ^Font_Atlas, alloc: ^Allocator) ---
	font_atlas_init_custom           :: proc(atlas: ^Font_Atlas, persistent, transient: ^Allocator) ---
	font_atlas_begin                 :: proc(atlas: ^Font_Atlas) ---
	font_config                      :: proc(pixel_height: f32) -> Font_Config ---
	font_atlas_add                   :: proc(atlas: ^Font_Atlas, config: ^Font_Config) -> ^Font ---
	font_atlas_add_default           :: proc(atlas: ^Font_Atlas, height: f32, config: ^Font_Config) -> ^Font ---
	font_atlas_add_from_memory       :: proc(atlas: ^Font_Atlas, memory: rawptr, size: Size, height: f32, config: ^Font_Config) -> ^Font ---
	font_atlas_add_from_file         :: proc(atlas: ^Font_Atlas, file_path: cstring, height: f32, config: ^Font_Config) -> ^Font ---
	font_atlas_add_compressed        :: proc(atlas: ^Font_Atlas, memory: rawptr, size: Size, height: f32, config: ^Font_Config) -> ^Font ---
	font_atlas_add_compressed_base85 :: proc(atlas: ^Font_Atlas, data: cstring, height: f32, config: ^Font_Config) -> ^Font ---
	font_atlas_bake                  :: proc(atlas: ^Font_Atlas, width, height: ^c.int, fmt: Font_Atlas_Format) -> rawptr ---
	font_atlas_end                   :: proc(atlas: ^Font_Atlas, tex: Handle, null_tex: ^Draw_Null_Texture) ---
	font_find_glyph                  :: proc(font: ^Font, unicode: Rune) -> ^Font_Glyph ---
	font_atlas_cleanup               :: proc(atlas: ^Font_Atlas) ---
	font_atlas_clear                 :: proc(atlas: ^Font_Atlas) ---

	// MEMORY BUFFER
	buffer_init_default :: proc(buffer: ^Buffer) ---
	buffer_init         :: proc(buffer: ^Buffer, alloc: ^Allocator, size: Size) ---
	buffer_init_fixed   :: proc(buffer: ^Buffer, memory: rawptr, size: Size) ---
	buffer_info         :: proc(status: ^Memory_Status, buffer: ^Buffer) ---
	buffer_push         :: proc(buffer: ^Buffer, type: Buffer_Allocation_Type, memory: rawptr, size, align: Size) ---
	buffer_mark         :: proc(buffer: ^Buffer, type: Buffer_Allocation_Type) ---
	buffer_reset        :: proc(buffer: ^Buffer, type: Buffer_Allocation_Type) ---
	buffer_clear        :: proc(buffer: ^Buffer) ---
	buffer_free         :: proc(buffer: ^Buffer) ---
	buffer_memory       :: proc(buffer: ^Buffer) -> rawptr ---
	buffer_memory_const :: proc(buffer: ^Buffer) -> rawptr ---
	buffer_total        :: proc(buffer: ^Buffer) -> Size ---

	// TEXT EDITOR
	filter_default            :: proc(edit: ^Text_Edit, unicode: Rune) -> Bool ---
	filter_ascii              :: proc(edit: ^Text_Edit, unicode: Rune) -> Bool ---
	filter_float              :: proc(edit: ^Text_Edit, unicode: Rune) -> Bool ---
	filter_decimal            :: proc(edit: ^Text_Edit, unicode: Rune) -> Bool ---
	filter_hex                :: proc(edit: ^Text_Edit, unicode: Rune) -> Bool ---
	filter_oct                :: proc(edit: ^Text_Edit, unicode: Rune) -> Bool ---
	filter_binary             :: proc(edit: ^Text_Edit, unicode: Rune) -> Bool ---
	textedit_init_default     :: proc(edit: ^Text_Edit) ---
	textedit_init             :: proc(edit: ^Text_Edit, alloc: ^Allocator, size: Size) ---
	textedit_init_fixed       :: proc(edit: ^Text_Edit, memory: rawptr, size: Size) ---
	textedit_free             :: proc(edit: ^Text_Edit) ---
	textedit_text             :: proc(edit: ^Text_Edit, text: cstring, total_len: c.int) ---
	textedit_delete           :: proc(edit: ^Text_Edit, where_, len: c.int) ---
	textedit_delete_selection :: proc(edit: ^Text_Edit) ---
	textedit_select_all       :: proc(edit: ^Text_Edit) ---
	textedit_cut              :: proc(edit: ^Text_Edit) -> Bool ---
	textedit_paste            :: proc(edit: ^Text_Edit, text: cstring, len: c.int) -> Bool ---
	textedit_undo             :: proc(edit: ^Text_Edit) ---
	textedit_redo             :: proc(edit: ^Text_Edit) ---

	// DRAWING
	stroke_line           :: proc(b: ^Command_Buffer, x0, y0, x1, y1, line_thickness: f32, color: Color) ---
	stroke_curve          :: proc(b: ^Command_Buffer, ax, ay, ctrl0x, ctrl0y, ctrl1x, ctrl1y, bx, by, line_thickness: f32, color: Color) ---
	stroke_rect           :: proc(b: ^Command_Buffer, bounds: Rect, rounding, line_thickness: f32, color: Color) ---
	stroke_circle         :: proc(b: ^Command_Buffer, bounds: Rect, line_thickness: f32, color: Color) ---
	stroke_arc            :: proc(b: ^Command_Buffer, cx, cy, radius, a_min, a_max, line_thickness: f32, color: Color) ---
	stroke_triangle       :: proc(b: ^Command_Buffer, x0, y0, x1, y1, x2, y2, line_thichness: f32, color: Color) ---
	stroke_polyline       :: proc(b: ^Command_Buffer, points: [^]f32, point_count: c.int, line_thickness: f32, col: Color) ---
	stroke_polygon        :: proc(b: ^Command_Buffer, points: [^]f32, point_count: c.int, line_thickness: f32, color: Color) ---
	fill_rect             :: proc(b: ^Command_Buffer, bounds: Rect, rounding: f32, color: Color) ---
	fill_rect_multi_color :: proc(b: ^Command_Buffer, bounds: Rect, left, top, right, bottom: Color) ---
	fill_circle           :: proc(b: ^Command_Buffer, bounds: Rect, color: Color) ---
	fill_arc              :: proc(b: ^Command_Buffer, cx, cy, radius, a_min, a_max: f32, color: Color) ---
	fill_triangle         :: proc(b: ^Command_Buffer, x0, y0, x1, y1, x2, y2: f32, color: Color) ---
	fill_polygon          :: proc(b: ^Command_Buffer, points: [^]f32, point_count: c.int, color: Color) ---
	draw_image            :: proc(b: ^Command_Buffer, bounds: Rect, img: ^Image, color: Color) ---
	draw_nine_slice       :: proc(b: ^Command_Buffer, bounds: Rect, slice: ^Nine_Slice, color: Color) ---
	draw_text             :: proc(b: ^Command_Buffer, bounds: Rect, text: cstring, len: c.int, font: ^User_Font, bg, fg: Color) ---
	push_scissor          :: proc(b: ^Command_Buffer, bounds: Rect) ---
	push_custom           :: proc(b: ^Command_Buffer, bounds: Rect, cb: Command_Custom_Callback, usr: Handle) ---

	// INPUT
	input_has_mouse_click                            :: proc(in_: ^Input, button: Buttons) -> Bool ---
	input_has_mouse_click_in_rect                    :: proc(in_: ^Input, button: Buttons, bounds: Rect) -> Bool ---
	input_has_mouse_click_in_button_rect             :: proc(in_: ^Input, button: Buttons, bounds: Rect) -> Bool ---
	input_has_mouse_click_down_in_rect               :: proc(in_: ^Input, button: Buttons, bounds: Rect, down: Bool) -> Bool ---
	input_is_mouse_click_in_rect                     :: proc(in_: ^Input, button: Buttons, bounds: Rect) -> Bool ---
	input_is_mouse_click_down_in_rect                :: proc(i: ^Input, id: Buttons, b: Rect, down: Bool) -> Bool ---
	input_any_mouse_click_in_rect                    :: proc(in_: ^Input, bounds: Rect) -> Bool ---
	input_is_mouse_prev_hovering_rect                :: proc(in_: ^Input, bounds: Rect) -> Bool ---
	input_is_mouse_hovering_rect                     :: proc(in_: ^Input, bounds: Rect) -> Bool ---
	input_is_mouse_hovering_still_rect               :: proc(in_: ^Input, bounds: Rect) -> Bool ---
	input_is_mouse_hovering_delay_rect               :: proc(ctx: ^Context, bounds: Rect, timer: ^f32, delay: f32) -> Bool ---
	input_is_mouse_hovering_still_delay_rect         :: proc(ctx: ^Context, bounds: Rect, timer: ^f32, delay: f32) -> Bool ---
	input_is_mouse_hovering_still_delay_clicked_rect :: proc(ctx: ^Context, bounds: Rect, timer: ^f32, delay: f32, clicked: ^Bool) -> Bool ---
	input_is_mouse_moved                             :: proc(in_: ^Input) -> Bool ---
	input_mouse_clicked                              :: proc(in_: ^Input, button: Buttons, bounds: Rect) -> Bool ---
	input_is_mouse_down                              :: proc(in_: ^Input, button: Buttons) -> Bool ---
	input_is_mouse_pressed                           :: proc(in_: ^Input, button: Buttons) -> Bool ---
	input_is_mouse_released                          :: proc(in_: ^Input, button: Buttons) -> Bool ---
	input_is_key_pressed                             :: proc(in_: ^Input, key: Keys) -> Bool ---
	input_is_key_released                            :: proc(in_: ^Input, key: Keys) -> Bool ---
	input_is_key_down                                :: proc(in_: ^Input, key: Keys) -> Bool ---

	// DRAW LIST
	draw_list_init                  :: proc(list: ^Draw_List) ---
	draw_list_setup                 :: proc(list: ^Draw_List, config: ^Convert_Config, cmds, vertices, elements: ^Buffer, line_aa, shape_aa: Anti_Aliasing) ---
	_draw_list_begin                :: proc(list: ^Draw_List, buffer: ^Buffer) -> ^Draw_Command ---
	_draw_list_next                 :: proc(cmd: ^Draw_Command, buffer: ^Buffer, list: ^Draw_List) -> ^Draw_Command ---
	_draw_list_end                  :: proc(list: ^Draw_List, buffer: ^Buffer) -> ^Draw_Command ---
	draw_list_path_clear            :: proc(list: ^Draw_List) ---
	draw_list_path_line_to          :: proc(list: ^Draw_List, pos: Vec2) ---
	draw_list_path_arc_to_fast      :: proc(list: ^Draw_List, center: Vec2, radius: f32, a_min, a_max: c.int) ---
	draw_list_path_arc_to           :: proc(list: ^Draw_List, center: Vec2, radius, a_min, a_max: f32, segments: c.uint) ---
	draw_list_path_rect_to          :: proc(list: ^Draw_List, a, b: Vec2, rounding: f32) ---
	draw_list_path_curve_to         :: proc(list: ^Draw_List, p2, p3, p4: Vec2, num_segments: c.uint) ---
	draw_list_path_fill             :: proc(list: ^Draw_List, color: Color) ---
	draw_list_path_stroke           :: proc(list: ^Draw_List, color: Color, closed: Draw_List_Stroke, thickness: f32) ---
	draw_list_stroke_line           :: proc(list: ^Draw_List, a, b: Vec2, color: Color, thickness: f32) ---
	draw_list_stroke_rect           :: proc(list: ^Draw_List, rect: Rect, color: Color, rounding, thickness: f32) ---
	draw_list_stroke_triangle       :: proc(list: ^Draw_List, a, b, c_: Vec2, color: Color, thickness: f32) ---
	draw_list_stroke_circle         :: proc(list: ^Draw_List, center: Vec2, radius: f32, color: Color, segs: c.uint, thickness: f32) ---
	draw_list_stroke_curve          :: proc(list: ^Draw_List, p0, cp0, cp1, p1: Vec2, color: Color, segments: c.uint, thickness: f32) ---
	draw_list_stroke_poly_line      :: proc(list: ^Draw_List, pnts: [^]Vec2, cnt: c.uint, color: Color, stroke: Draw_List_Stroke, thickness: f32, aliasing: Anti_Aliasing) ---
	draw_list_fill_rect             :: proc(list: ^Draw_List, rect: Rect, color: Color, rounding: f32) ---
	draw_list_fill_rect_multi_color :: proc(list: ^Draw_List, rect: Rect, left, top, right, bottom: Color) ---
	draw_list_fill_triangle         :: proc(list: ^Draw_List, a, b, c_: Vec2, color: Color) ---
	draw_list_fill_circle           :: proc(list: ^Draw_List, center: Vec2, radius: f32, col: Color, segs: c.uint) ---
	draw_list_fill_poly_convex      :: proc(list: ^Draw_List, points: [^]Vec2, count: c.uint, color: Color, aliasing: Anti_Aliasing) ---
	draw_list_add_image             :: proc(list: ^Draw_List, texture: Image, rect: Rect, color: Color) ---
	draw_list_add_text              :: proc(list: ^Draw_List, font: ^User_Font, rect: Rect, text: cstring, len: c.int, font_height: f32, color: Color) ---

	// GUI
	style_item_color      :: proc(color: Color) -> Style_Item ---
	style_item_image      :: proc(img: Image) -> Style_Item ---
	style_item_nine_slice :: proc(slice: Nine_Slice) -> Style_Item ---
	style_item_hide       :: proc() -> Style_Item ---
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

// Build "file:line" in buf, as NK_FILE_LINE does in C. The _id forms need it, because the seed is the id.
@(private)
hash_of_line :: proc(buf: []u8, path: string, line: i32) -> (cstring, c.int) {
	s := fmt.bprintf(buf, "%s:%d", path, line)
	return cstring(raw_data(s)), c.int(len(s))
}

tree_push :: proc(ctx: ^Context, type: Tree_Type, title: cstring, state: Collapse_States, loc := #caller_location) -> Bool {
	hash, n := hash_of(loc.file_path)
	return tree_push_hashed(ctx, type, title, state, hash, n, c.int(loc.line))
}

tree_push_id :: proc(ctx: ^Context, type: Tree_Type, title: cstring, state: Collapse_States, id: c.int, loc := #caller_location) -> Bool {
	buf: [512]u8
	hash, n := hash_of_line(buf[:], loc.file_path, loc.line)
	return tree_push_hashed(ctx, type, title, state, hash, n, id)
}

tree_image_push :: proc(ctx: ^Context, type: Tree_Type, img: Image, title: cstring, state: Collapse_States, loc := #caller_location) -> Bool {
	hash, n := hash_of(loc.file_path)
	return tree_image_push_hashed(ctx, type, img, title, state, hash, n, c.int(loc.line))
}

tree_image_push_id :: proc(ctx: ^Context, type: Tree_Type, img: Image, title: cstring, state: Collapse_States, id: c.int, loc := #caller_location) -> Bool {
	buf: [512]u8
	hash, n := hash_of_line(buf[:], loc.file_path, loc.line)
	return tree_image_push_hashed(ctx, type, img, title, state, hash, n, id)
}

tree_element_push :: proc(ctx: ^Context, type: Tree_Type, title: cstring, state: Collapse_States, selected: ^Bool, loc := #caller_location) -> Bool {
	hash, n := hash_of(loc.file_path)
	return tree_element_push_hashed(ctx, type, title, state, selected, hash, n, c.int(loc.line))
}

tree_element_push_id :: proc(ctx: ^Context, type: Tree_Type, title: cstring, state: Collapse_States, selected: ^Bool, id: c.int, loc := #caller_location) -> Bool {
	buf: [512]u8
	hash, n := hash_of_line(buf[:], loc.file_path, loc.line)
	return tree_element_push_hashed(ctx, type, title, state, selected, hash, n, id)
}
