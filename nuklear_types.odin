// The public structs and unions of nuklear.h, in the order of nuklear.h.
// Each type has the C layout. tests/layout_test.odin compares them with the C types.
package nuklear

import "core:c"

Plugin_Alloc  :: #type proc "c" (handle: Handle, old: rawptr, size: Size) -> rawptr
Plugin_Free   :: #type proc "c" (handle: Handle, old: rawptr)
Plugin_Filter :: #type proc "c" (edit: ^Text_Edit, unicode: Rune) -> Bool
Plugin_Paste  :: #type proc "c" (handle: Handle, edit: ^Text_Edit)
Plugin_Copy   :: #type proc "c" (handle: Handle, text: cstring, len: c.int)

Allocator :: struct {
	userdata: Handle,
	alloc:    Plugin_Alloc,
	free:     Plugin_Free,
}

Draw_Null_Texture :: struct {
	texture: Handle, // the texture handle of a white pixel
	uv:      Vec2,   // the texture coordinates of the white pixel
}

Convert_Config :: struct {
	global_alpha:         f32,
	line_AA:              Anti_Aliasing,
	shape_AA:             Anti_Aliasing,
	circle_segment_count: c.uint,
	arc_segment_count:    c.uint,
	curve_segment_count:  c.uint,
	tex_null:             Draw_Null_Texture,
	vertex_layout:        [^]Draw_Vertex_Layout_Element, // ends with VERTEX_LAYOUT_END
	vertex_size:          Size,
	vertex_alignment:     Size,
}

List_View :: struct {
	begin, end, count: c.int,
	total_height:      c.int,
	ctx:               ^Context,
	scroll_pointer:    ^Uint,
	scroll_value:      Uint,
}

Text_Width_F       :: #type proc "c" (handle: Handle, h: f32, text: cstring, len: c.int) -> f32
Query_Font_Glyph_F :: #type proc "c" (handle: Handle, font_height: f32, glyph: ^User_Font_Glyph, codepoint, next_codepoint: Rune)

User_Font_Glyph :: struct {
	uv:            [2]Vec2,
	offset:        Vec2,
	width, height: f32,
	xadvance:      f32,
}

User_Font :: struct {
	userdata: Handle,
	height:   f32,
	width:    Text_Width_F,
	query:    Query_Font_Glyph_F,
	texture:  Handle,
}

Baked_Font :: struct {
	height:       f32,
	ascent:       f32,
	descent:      f32,
	glyph_offset: Rune,
	glyph_count:  Rune,
	ranges:       [^]Rune,
}

Font_Config :: struct {
	next:                       ^Font_Config,
	ttf_blob:                   rawptr,
	ttf_size:                   Size,
	ttf_data_owned_by_atlas:    c.uchar,
	merge_mode:                 c.uchar,
	pixel_snap:                 c.uchar,
	oversample_v, oversample_h: c.uchar,
	padding:                    [3]c.uchar,
	size:                       f32,
	coord_type:                 Font_Coord_Type,
	spacing:                    Vec2,
	range:                      [^]Rune,
	font:                       ^Baked_Font,
	fallback_glyph:             Rune,
	n:                          ^Font_Config,
	p:                          ^Font_Config,
}

Font_Glyph :: struct {
	codepoint:            Rune,
	xadvance:             f32,
	x0, y0, x1, y1, w, h: f32,
	u0, v0, u1, v1:       f32,
}

Font :: struct {
	next:               ^Font,
	handle:             User_Font,
	info:               Baked_Font,
	scale:              f32,
	glyphs:             [^]Font_Glyph,
	fallback:           ^Font_Glyph,
	fallback_codepoint: Rune,
	texture:            Handle,
	config:             ^Font_Config,
}

Font_Atlas :: struct {
	pixel:        rawptr,
	tex_width:    c.int,
	tex_height:   c.int,
	permanent:    Allocator,
	temporary:    Allocator,
	custom:       Recti,
	cursors:      [CURSOR_COUNT]Cursor,
	glyph_count:  c.int,
	glyphs:       [^]Font_Glyph,
	default_font: ^Font,
	fonts:        ^Font,
	config:       ^Font_Config,
	font_num:     c.int,
}

Memory_Status :: struct {
	memory:    rawptr,
	type:      c.uint,
	size:      Size,
	allocated: Size,
	needed:    Size,
	calls:     Size,
}

Buffer_Marker :: struct {
	active: Bool,
	offset: Size,
}

Memory :: struct {
	ptr:  rawptr,
	size: Size,
}

Buffer :: struct {
	marker:      [BUFFER_MAX]Buffer_Marker,
	pool:        Allocator,
	type:        Allocation_Type,
	memory:      Memory,
	grow_factor: f32,
	allocated:   Size,
	needed:      Size,
	calls:       Size,
	size:        Size,
}

Str :: struct {
	buffer: Buffer,
	len:    c.int, // the number of runes, not bytes
}

Clipboard :: struct {
	userdata: Handle,
	paste:    Plugin_Paste,
	copy:     Plugin_Copy,
}

Text_Undo_Record :: struct {
	where_:        c.int,
	insert_length: c.short,
	delete_length: c.short,
	char_storage:  c.short,
}

Text_Undo_State :: struct {
	undo_rec:        [TEXTEDIT_UNDOSTATECOUNT]Text_Undo_Record,
	undo_char:       [TEXTEDIT_UNDOCHARCOUNT]Rune,
	undo_point:      c.short,
	redo_point:      c.short,
	undo_char_point: c.short,
	redo_char_point: c.short,
}

Text_Edit :: struct {
	clip:                  Clipboard,
	string:                Str,
	filter:                Plugin_Filter,
	scrollbar:             Vec2,
	cursor:                c.int,
	select_start:          c.int,
	select_end:            c.int,
	mode:                  c.uchar,
	cursor_at_end_of_line: c.uchar,
	initialized:           c.uchar,
	has_preferred_x:       c.uchar,
	single_line:           c.uchar,
	active:                c.uchar,
	padding1:              c.uchar,
	preferred_x:           f32,
	undo:                  Text_Undo_State,
}

Command :: struct {
	type: Command_Type,
	next: Size, // the offset of the next command in the buffer
}

Command_Scissor :: struct {
	header: Command,
	x, y:   c.short,
	w, h:   c.ushort,
}

Command_Line :: struct {
	header:         Command,
	line_thickness: c.ushort,
	begin:          Vec2i,
	end:            Vec2i,
	color:          Color,
}

Command_Curve :: struct {
	header:         Command,
	line_thickness: c.ushort,
	begin:          Vec2i,
	end:            Vec2i,
	ctrl:           [2]Vec2i,
	color:          Color,
}

Command_Rect :: struct {
	header:         Command,
	rounding:       c.ushort,
	line_thickness: c.ushort,
	x, y:           c.short,
	w, h:           c.ushort,
	color:          Color,
}

Command_Rect_Filled :: struct {
	header:   Command,
	rounding: c.ushort,
	x, y:     c.short,
	w, h:     c.ushort,
	color:    Color,
}

Command_Rect_Multi_Color :: struct {
	header: Command,
	x, y:   c.short,
	w, h:   c.ushort,
	left:   Color,
	top:    Color,
	bottom: Color,
	right:  Color,
}

Command_Triangle :: struct {
	header:         Command,
	line_thickness: c.ushort,
	a:              Vec2i,
	b:              Vec2i,
	c:              Vec2i,
	color:          Color,
}

Command_Triangle_Filled :: struct {
	header: Command,
	a:      Vec2i,
	b:      Vec2i,
	c:      Vec2i,
	color:  Color,
}

Command_Circle :: struct {
	header:         Command,
	x, y:           c.short,
	line_thickness: c.ushort,
	w, h:           c.ushort,
	color:          Color,
}

Command_Circle_Filled :: struct {
	header: Command,
	x, y:   c.short,
	w, h:   c.ushort,
	color:  Color,
}

Command_Arc :: struct {
	header:         Command,
	cx, cy:         c.short,
	r:              c.ushort,
	line_thickness: c.ushort,
	a:              [2]f32,
	color:          Color,
}

Command_Arc_Filled :: struct {
	header: Command,
	cx, cy: c.short,
	r:      c.ushort,
	a:      [2]f32,
	color:  Color,
}

// The C struct ends with "points[1]". The command buffer holds point_count points.
Command_Polygon :: struct {
	header:         Command,
	color:          Color,
	line_thickness: c.ushort,
	point_count:    c.ushort,
	points:         [1]Vec2i,
}

Command_Polygon_Filled :: struct {
	header:      Command,
	color:       Color,
	point_count: c.ushort,
	points:      [1]Vec2i,
}

Command_Polyline :: struct {
	header:         Command,
	color:          Color,
	line_thickness: c.ushort,
	point_count:    c.ushort,
	points:         [1]Vec2i,
}

Command_Image :: struct {
	header: Command,
	x, y:   c.short,
	w, h:   c.ushort,
	img:    Image,
	col:    Color,
}

Command_Custom_Callback :: #type proc "c" (canvas: rawptr, x, y: c.short, w, h: c.ushort, callback_data: Handle)

Command_Custom :: struct {
	header:        Command,
	x, y:          c.short,
	w, h:          c.ushort,
	callback_data: Handle,
	callback:      Command_Custom_Callback,
}

// The C struct ends with "string[2]". The command buffer holds length bytes and a zero byte.
Command_Text :: struct {
	header:     Command,
	font:       ^User_Font,
	background: Color,
	foreground: Color,
	x, y:       c.short,
	w, h:       c.ushort,
	height:     f32,
	length:     c.int,
	string:     [2]u8,
}

Command_Buffer :: struct {
	base:             ^Buffer,
	clip:             Rect,
	use_clipping:     c.int,
	userdata:         Handle,
	begin, end, last: Size,
}

Mouse_Button :: struct {
	down:        Bool,
	clicked:     c.uint,
	clicked_pos: Vec2,
}

Mouse :: struct {
	buttons:      [BUTTON_MAX]Mouse_Button,
	pos:          Vec2,
	prev:         Vec2,
	delta:        Vec2,
	scroll_delta: Vec2,
	grab:         c.uchar,
	grabbed:      c.uchar,
	ungrab:       c.uchar,
}

Key :: struct {
	down:    Bool,
	clicked: c.uint,
}

Keyboard :: struct {
	keys:     [KEY_MAX]Key,
	text:     [INPUT_MAX]u8,
	text_len: c.int,
}

Input :: struct {
	keyboard: Keyboard,
	mouse:    Mouse,
}

Draw_Vertex_Layout_Element :: struct {
	attribute: Draw_Vertex_Layout_Attribute,
	format:    Draw_Vertex_Layout_Format,
	offset:    Size,
}

// The last element of a vertex layout array.
VERTEX_LAYOUT_END :: Draw_Vertex_Layout_Element{VERTEX_ATTRIBUTE_COUNT, FORMAT_COUNT, 0}

Draw_Command :: struct {
	elem_count: c.uint,
	clip_rect:  Rect,
	texture:    Handle,
}

Draw_List :: struct {
	clip_rect:     Rect,
	circle_vtx:    [12]Vec2,
	config:        Convert_Config,
	buffer:        ^Buffer,
	vertices:      ^Buffer,
	elements:      ^Buffer,
	element_count: c.uint,
	vertex_count:  c.uint,
	cmd_count:     c.uint,
	cmd_offset:    Size,
	path_count:    c.uint,
	path_offset:   c.uint,
	line_AA:       Anti_Aliasing,
	shape_AA:      Anti_Aliasing,
}

Style_Item_Data :: struct #raw_union {
	color: Color,
	image: Image,
	slice: Nine_Slice,
}

Style_Item :: struct {
	type: Style_Item_Type,
	data: Style_Item_Data,
}

Style_Text :: struct {
	color:           Color,
	padding:         Vec2,
	color_factor:    f32,
	disabled_factor: f32,
}

Style_Link :: struct {
	text_normal:         Color,
	text_hover:          Color,
	text_active:         Color,
	underline:           Link_Underline,
	underline_thickness: f32,
	padding:             Vec2,
	touch_padding:       Vec2,
	color_factor:        f32,
	disabled_factor:     f32,
}

Style_Button :: struct {
	normal:                  Style_Item,
	hover:                   Style_Item,
	active:                  Style_Item,
	border_color:            Color,
	color_factor_background: f32,
	text_background:         Color,
	text_normal:             Color,
	text_hover:              Color,
	text_active:             Color,
	text_alignment:          Flags,
	color_factor_text:       f32,
	border:                  f32,
	rounding:                f32,
	padding:                 Vec2,
	image_padding:           Vec2,
	touch_padding:           Vec2,
	disabled_factor:         f32,
	userdata:                Handle,
	draw_begin:              proc "c" (buffer: ^Command_Buffer, userdata: Handle),
	draw_end:                proc "c" (buffer: ^Command_Buffer, userdata: Handle),
}

Style_Toggle :: struct {
	normal:          Style_Item,
	hover:           Style_Item,
	active:          Style_Item,
	border_color:    Color,
	cursor_normal:   Style_Item,
	cursor_hover:    Style_Item,
	text_normal:     Color,
	text_hover:      Color,
	text_active:     Color,
	text_background: Color,
	text_alignment:  Flags,
	padding:         Vec2,
	touch_padding:   Vec2,
	spacing:         f32,
	border:          f32,
	color_factor:    f32,
	disabled_factor: f32,
	userdata:        Handle,
	draw_begin:      proc "c" (buffer: ^Command_Buffer, userdata: Handle),
	draw_end:        proc "c" (buffer: ^Command_Buffer, userdata: Handle),
}

Style_Selectable :: struct {
	normal:              Style_Item,
	hover:               Style_Item,
	pressed:             Style_Item,
	normal_active:       Style_Item,
	hover_active:        Style_Item,
	pressed_active:      Style_Item,
	text_normal:         Color,
	text_hover:          Color,
	text_pressed:        Color,
	text_normal_active:  Color,
	text_hover_active:   Color,
	text_pressed_active: Color,
	text_background:     Color,
	text_alignment:      Flags,
	rounding:            f32,
	padding:             Vec2,
	touch_padding:       Vec2,
	image_padding:       Vec2,
	color_factor:        f32,
	disabled_factor:     f32,
	userdata:            Handle,
	draw_begin:          proc "c" (buffer: ^Command_Buffer, userdata: Handle),
	draw_end:            proc "c" (buffer: ^Command_Buffer, userdata: Handle),
}

Style_Slider :: struct {
	normal:          Style_Item,
	hover:           Style_Item,
	active:          Style_Item,
	border_color:    Color,
	bar_normal:      Color,
	bar_hover:       Color,
	bar_active:      Color,
	bar_filled:      Color,
	cursor_normal:   Style_Item,
	cursor_hover:    Style_Item,
	cursor_active:   Style_Item,
	border:          f32,
	rounding:        f32,
	bar_height:      f32,
	padding:         Vec2,
	spacing:         Vec2,
	cursor_size:     Vec2,
	color_factor:    f32,
	disabled_factor: f32,
	show_buttons:    c.int,
	inc_button:      Style_Button,
	dec_button:      Style_Button,
	inc_symbol:      Symbol_Type,
	dec_symbol:      Symbol_Type,
	userdata:        Handle,
	draw_begin:      proc "c" (buffer: ^Command_Buffer, userdata: Handle),
	draw_end:        proc "c" (buffer: ^Command_Buffer, userdata: Handle),
}

Style_Knob :: struct {
	normal:            Style_Item,
	hover:             Style_Item,
	active:            Style_Item,
	border_color:      Color,
	knob_normal:       Color,
	knob_hover:        Color,
	knob_active:       Color,
	knob_border_color: Color,
	cursor_normal:     Color,
	cursor_hover:      Color,
	cursor_active:     Color,
	border:            f32,
	knob_border:       f32,
	padding:           Vec2,
	spacing:           Vec2,
	cursor_width:      f32,
	color_factor:      f32,
	disabled_factor:   f32,
	userdata:          Handle,
	draw_begin:        proc "c" (buffer: ^Command_Buffer, userdata: Handle),
	draw_end:          proc "c" (buffer: ^Command_Buffer, userdata: Handle),
}

Style_Progress :: struct {
	normal:              Style_Item,
	hover:               Style_Item,
	active:              Style_Item,
	border_color:        Color,
	cursor_normal:       Style_Item,
	cursor_hover:        Style_Item,
	cursor_active:       Style_Item,
	cursor_border_color: Color,
	rounding:            f32,
	border:              f32,
	cursor_border:       f32,
	cursor_rounding:     f32,
	padding:             Vec2,
	color_factor:        f32,
	disabled_factor:     f32,
	userdata:            Handle,
	draw_begin:          proc "c" (buffer: ^Command_Buffer, userdata: Handle),
	draw_end:            proc "c" (buffer: ^Command_Buffer, userdata: Handle),
}

Style_Scrollbar :: struct {
	normal:              Style_Item,
	hover:               Style_Item,
	active:              Style_Item,
	border_color:        Color,
	cursor_normal:       Style_Item,
	cursor_hover:        Style_Item,
	cursor_active:       Style_Item,
	cursor_border_color: Color,
	border:              f32,
	rounding:            f32,
	border_cursor:       f32,
	rounding_cursor:     f32,
	padding:             Vec2,
	color_factor:        f32,
	disabled_factor:     f32,
	show_buttons:        c.int,
	inc_button:          Style_Button,
	dec_button:          Style_Button,
	inc_symbol:          Symbol_Type,
	dec_symbol:          Symbol_Type,
	userdata:            Handle,
	draw_begin:          proc "c" (buffer: ^Command_Buffer, userdata: Handle),
	draw_end:            proc "c" (buffer: ^Command_Buffer, userdata: Handle),
}

Style_Edit :: struct {
	normal:               Style_Item,
	hover:                Style_Item,
	active:               Style_Item,
	border_color:         Color,
	scrollbar:            Style_Scrollbar,
	cursor_normal:        Color,
	cursor_hover:         Color,
	cursor_text_normal:   Color,
	cursor_text_hover:    Color,
	text_normal:          Color,
	text_hover:           Color,
	text_active:          Color,
	selected_normal:      Color,
	selected_hover:       Color,
	selected_text_normal: Color,
	selected_text_hover:  Color,
	border:               f32,
	rounding:             f32,
	cursor_size:          f32,
	scrollbar_size:       Vec2,
	padding:              Vec2,
	row_padding:          f32,
	color_factor:         f32,
	disabled_factor:      f32,
}

Style_Property :: struct {
	normal:          Style_Item,
	hover:           Style_Item,
	active:          Style_Item,
	border_color:    Color,
	label_normal:    Color,
	label_hover:     Color,
	label_active:    Color,
	sym_left:        Symbol_Type,
	sym_right:       Symbol_Type,
	border:          f32,
	rounding:        f32,
	padding:         Vec2,
	color_factor:    f32,
	disabled_factor: f32,
	edit:            Style_Edit,
	inc_button:      Style_Button,
	dec_button:      Style_Button,
	userdata:        Handle,
	draw_begin:      proc "c" (buffer: ^Command_Buffer, userdata: Handle),
	draw_end:        proc "c" (buffer: ^Command_Buffer, userdata: Handle),
}

Style_Chart :: struct {
	background:      Style_Item,
	border_color:    Color,
	selected_color:  Color,
	color:           Color,
	border:          f32,
	rounding:        f32,
	padding:         Vec2,
	color_factor:    f32,
	disabled_factor: f32,
	show_markers:    Bool,
}

Style_Combo :: struct {
	normal:          Style_Item,
	hover:           Style_Item,
	active:          Style_Item,
	border_color:    Color,
	label_normal:    Color,
	label_hover:     Color,
	label_active:    Color,
	symbol_normal:   Color,
	symbol_hover:    Color,
	symbol_active:   Color,
	button:          Style_Button,
	sym_normal:      Symbol_Type,
	sym_hover:       Symbol_Type,
	sym_active:      Symbol_Type,
	border:          f32,
	rounding:        f32,
	content_padding: Vec2,
	button_padding:  Vec2,
	spacing:         Vec2,
	color_factor:    f32,
	disabled_factor: f32,
}

Style_Tab :: struct {
	background:           Style_Item,
	border_color:         Color,
	text:                 Color,
	tab_maximize_button:  Style_Button,
	tab_minimize_button:  Style_Button,
	node_maximize_button: Style_Button,
	node_minimize_button: Style_Button,
	sym_minimize:         Symbol_Type,
	sym_maximize:         Symbol_Type,
	border:               f32,
	rounding:             f32,
	indent:               f32,
	padding:              Vec2,
	spacing:              Vec2,
	color_factor:         f32,
	disabled_factor:      f32,
}

Style_Window_Header :: struct {
	normal:          Style_Item,
	hover:           Style_Item,
	active:          Style_Item,
	close_button:    Style_Button,
	minimize_button: Style_Button,
	close_symbol:    Symbol_Type,
	minimize_symbol: Symbol_Type,
	maximize_symbol: Symbol_Type,
	label_normal:    Color,
	label_hover:     Color,
	label_active:    Color,
	align:           Style_Header_Align,
	padding:         Vec2,
	label_padding:   Vec2,
	spacing:         Vec2,
}

Style_Window :: struct {
	header:                  Style_Window_Header,
	fixed_background:        Style_Item,
	background:              Color,
	border_color:            Color,
	popup_border_color:      Color,
	combo_border_color:      Color,
	contextual_border_color: Color,
	menu_border_color:       Color,
	group_border_color:      Color,
	tooltip_border_color:    Color,
	scaler:                  Style_Item,
	border:                  f32,
	combo_border:            f32,
	contextual_border:       f32,
	menu_border:             f32,
	group_border:            f32,
	tooltip_border:          f32,
	popup_border:            f32,
	min_row_height_padding:  f32,
	rounding:                f32,
	spacing:                 Vec2,
	scrollbar_size:          Vec2,
	min_size:                Vec2,
	padding:                 Vec2,
	group_padding:           Vec2,
	popup_padding:           Vec2,
	combo_padding:           Vec2,
	contextual_padding:      Vec2,
	menu_padding:            Vec2,
	tooltip_padding:         Vec2,
	tooltip_origin:          Tooltip_Pos,
	tooltip_offset:          Vec2,
	tooltip_delay:           f32,
}

Style :: struct {
	font:              ^User_Font,
	cursors:           [CURSOR_COUNT]^Cursor,
	cursor_active:     ^Cursor,
	cursor_last:       ^Cursor,
	cursor_visible:    c.int,
	text:              Style_Text,
	link:              Style_Link,
	button:            Style_Button,
	contextual_button: Style_Button,
	menu_button:       Style_Button,
	option:            Style_Toggle,
	checkbox:          Style_Toggle,
	selectable:        Style_Selectable,
	slider:            Style_Slider,
	knob:              Style_Knob,
	progress:          Style_Progress,
	property:          Style_Property,
	edit:              Style_Edit,
	chart:             Style_Chart,
	scrollh:           Style_Scrollbar,
	scrollv:           Style_Scrollbar,
	tab:               Style_Tab,
	combo:             Style_Combo,
	window:            Style_Window,
}

Chart_Slot :: struct {
	type:            Chart_Type,
	color:           Color,
	highlight:       Color,
	min, max, range: f32,
	count:           c.int,
	last:            Vec2,
	index:           c.int,
	show_markers:    Bool,
}

Chart :: struct {
	slot:       c.int,
	x, y, w, h: f32,
	slots:      [CHART_MAX_SLOT]Chart_Slot,
}

Row_Layout :: struct {
	type:        Panel_Row_Layout_Type,
	index:       c.int,
	height:      f32,
	min_height:  f32,
	columns:     c.int,
	ratio:       [^]f32,
	item_width:  f32,
	item_height: f32,
	item_offset: f32,
	filled:      f32,
	item:        Rect,
	tree_depth:  c.int,
	templates:   [MAX_LAYOUT_ROW_TEMPLATE_COLUMNS]f32,
}

Popup_Buffer :: struct {
	begin:  Size,
	parent: Size,
	last:   Size,
	end:    Size,
	active: Bool,
}

Menu_State :: struct {
	x, y, w, h: f32,
	offset:     Scroll,
}

Panel :: struct {
	type:              Panel_Type,
	flags:             Flags,
	bounds:            Rect,
	offset_x:          ^Uint,
	offset_y:          ^Uint,
	at_x, at_y, max_x: f32,
	footer_height:     f32,
	header_height:     f32,
	border:            f32,
	has_scrolling:     c.uint,
	clip:              Rect,
	menu:              Menu_State,
	row:               Row_Layout,
	chart:             Chart,
	buffer:            ^Command_Buffer,
	parent:            ^Panel,
}

Popup_State :: struct {
	win:                ^Window,
	type:               Panel_Type,
	buf:                Popup_Buffer,
	name:               Hash,
	active:             Bool,
	combo_count:        c.uint,
	con_count, con_old: c.uint,
	active_con:         c.uint,
	header:             Rect,
}

Edit_State :: struct {
	name:         Hash,
	seq:          c.uint,
	old:          c.uint,
	active, prev: c.int,
	cursor:       c.int,
	sel_start:    c.int,
	sel_end:      c.int,
	scrollbar:    Scroll,
	mode:         c.uchar,
	single_line:  c.uchar,
}

Property_State :: struct {
	active, prev: c.int,
	buffer:       [MAX_NUMBER_BUFFER]u8,
	length:       c.int,
	cursor:       c.int,
	select_start: c.int,
	select_end:   c.int,
	name:         Hash,
	seq:          c.uint,
	old:          c.uint,
	state:        c.int,
	prev_state:   c.int,
	prev_name:    Hash,
	prev_buffer:  [MAX_NUMBER_BUFFER]u8,
	prev_length:  c.int,
}

Window :: struct {
	seq:                    c.uint,
	name:                   Hash,
	name_string:            [WINDOW_MAX_NAME]u8,
	flags:                  Flags,
	bounds:                 Rect,
	scrollbar:              Scroll,
	buffer:                 Command_Buffer,
	layout:                 ^Panel,
	scrollbar_hiding_timer: f32,
	property:               Property_State,
	popup:                  Popup_State,
	edit:                   Edit_State,
	scrolled:               c.uint,
	widgets_disabled:       Bool,
	tables:                 ^Table,
	table_count:            c.uint,
	next:                   ^Window,
	prev:                   ^Window,
	parent:                 ^Window,
}

Config_Stack_Style_Item_Element :: struct {
	address:   ^Style_Item,
	old_value: Style_Item,
}

Config_Stack_Float_Element :: struct {
	address:   ^f32,
	old_value: f32,
}

Config_Stack_Vec2_Element :: struct {
	address:   ^Vec2,
	old_value: Vec2,
}

Config_Stack_Flags_Element :: struct {
	address:   ^Flags,
	old_value: Flags,
}

Config_Stack_Color_Element :: struct {
	address:   ^Color,
	old_value: Color,
}

Config_Stack_User_Font_Element :: struct {
	address:   ^^User_Font,
	old_value: ^User_Font,
}

Config_Stack_Button_Behavior_Element :: struct {
	address:   ^Button_Behavior,
	old_value: Button_Behavior,
}

Config_Stack_Style_Item :: struct {
	head:     c.int,
	elements: [STYLE_ITEM_STACK_SIZE]Config_Stack_Style_Item_Element,
}

Config_Stack_Float :: struct {
	head:     c.int,
	elements: [FLOAT_STACK_SIZE]Config_Stack_Float_Element,
}

Config_Stack_Vec2 :: struct {
	head:     c.int,
	elements: [VECTOR_STACK_SIZE]Config_Stack_Vec2_Element,
}

Config_Stack_Flags :: struct {
	head:     c.int,
	elements: [FLAGS_STACK_SIZE]Config_Stack_Flags_Element,
}

Config_Stack_Color :: struct {
	head:     c.int,
	elements: [COLOR_STACK_SIZE]Config_Stack_Color_Element,
}

Config_Stack_User_Font :: struct {
	head:     c.int,
	elements: [FONT_STACK_SIZE]Config_Stack_User_Font_Element,
}

Config_Stack_Button_Behavior :: struct {
	head:     c.int,
	elements: [BUTTON_BEHAVIOR_STACK_SIZE]Config_Stack_Button_Behavior_Element,
}

Configuration_Stacks :: struct {
	style_items:      Config_Stack_Style_Item,
	floats:           Config_Stack_Float,
	vectors:          Config_Stack_Vec2,
	flags:            Config_Stack_Flags,
	colors:           Config_Stack_Color,
	fonts:            Config_Stack_User_Font,
	button_behaviors: Config_Stack_Button_Behavior,
}

#assert(VALUE_PAGE_CAPACITY == max(size_of(Window), size_of(Panel)) / size_of(Uint) / 2)

Table :: struct {
	seq:        c.uint,
	size:       c.uint,
	keys:       [VALUE_PAGE_CAPACITY]Hash,
	values:     [VALUE_PAGE_CAPACITY]Uint,
	next, prev: ^Table,
}

Page_Data :: struct #raw_union {
	tbl: Table,
	pan: Panel,
	win: Window,
}

Page_Element :: struct {
	data: Page_Data,
	next: ^Page_Element,
	prev: ^Page_Element,
}

// The C struct ends with "win[1]". A page holds size elements.
Page :: struct {
	size: c.uint,
	next: ^Page,
	win:  [1]Page_Element,
}

Pool :: struct {
	alloc:      Allocator,
	type:       Allocation_Type,
	page_count: c.uint,
	pages:      ^Page,
	freelist:   ^Page_Element,
	capacity:   c.uint,
	size:       Size,
	cap:        Size,
}

Context :: struct {
	input:              Input,
	style:              Style,
	memory:             Buffer,
	clip:               Clipboard,
	last_widget_state:  Flags,
	button_behavior:    Button_Behavior,
	stacks:             Configuration_Stacks,
	delta_time_seconds: f32,
	draw_list:          Draw_List,
	text_edit:          Text_Edit,
	overlay:            Command_Buffer,
	build:              c.int,
	use_pool:           c.int,
	pool:               Pool,
	begin:              ^Window,
	end:                ^Window,
	active:             ^Window,
	current:            ^Window,
	freelist:           ^Page_Element,
	count:              c.uint,
	seq:                c.uint,
}
