/* Sizes, alignments and field offsets of the public Nuklear types.
 * The layout test compares these C values with the Odin types. */
#include <stddef.h>
#include <string.h>
#include "../nuklear_options.h"
#include "../nuklear/nuklear.h"

typedef struct { const char *name; size_t size; size_t align; } nk_odin_layout_entry;

#define S(t) {#t, sizeof(struct t), _Alignof(struct t)}
#define U(t) {#t, sizeof(union t), _Alignof(union t)}

static const nk_odin_layout_entry layouts[] = {
	{"nk_handle", sizeof(nk_handle), _Alignof(nk_handle)},
	S(nk_color), S(nk_colorf), S(nk_vec2), S(nk_vec2i), S(nk_rect), S(nk_recti),
	S(nk_image), S(nk_nine_slice), S(nk_cursor), S(nk_scroll), S(nk_allocator),
	S(nk_draw_null_texture), S(nk_convert_config), S(nk_list_view),
	S(nk_user_font_glyph), S(nk_user_font), S(nk_baked_font), S(nk_font_config),
	S(nk_font_glyph), S(nk_font), S(nk_font_atlas), S(nk_memory_status),
	S(nk_buffer_marker), S(nk_memory), S(nk_buffer), S(nk_str), S(nk_clipboard),
	S(nk_text_undo_record), S(nk_text_undo_state), S(nk_text_edit),
	S(nk_command), S(nk_command_scissor), S(nk_command_line), S(nk_command_curve),
	S(nk_command_rect), S(nk_command_rect_filled), S(nk_command_rect_multi_color),
	S(nk_command_triangle), S(nk_command_triangle_filled), S(nk_command_circle),
	S(nk_command_circle_filled), S(nk_command_arc), S(nk_command_arc_filled),
	S(nk_command_polygon), S(nk_command_polygon_filled), S(nk_command_polyline),
	S(nk_command_image), S(nk_command_custom), S(nk_command_text),
	S(nk_command_buffer), S(nk_mouse_button), S(nk_mouse), S(nk_key),
	S(nk_keyboard), S(nk_input), S(nk_draw_vertex_layout_element),
	S(nk_draw_command), S(nk_draw_list), U(nk_style_item_data), S(nk_style_item),
	S(nk_style_text), S(nk_style_link), S(nk_style_button), S(nk_style_toggle),
	S(nk_style_selectable), S(nk_style_slider), S(nk_style_knob),
	S(nk_style_progress), S(nk_style_scrollbar), S(nk_style_edit),
	S(nk_style_property), S(nk_style_chart), S(nk_style_combo), S(nk_style_tab),
	S(nk_style_window_header), S(nk_style_window), S(nk_style), S(nk_chart_slot),
	S(nk_chart), S(nk_row_layout), S(nk_popup_buffer), S(nk_menu_state),
	S(nk_panel), S(nk_popup_state), S(nk_edit_state), S(nk_property_state),
	S(nk_window), S(nk_config_stack_style_item_element),
	S(nk_config_stack_float_element), S(nk_config_stack_vec2_element),
	S(nk_config_stack_flags_element), S(nk_config_stack_color_element),
	S(nk_config_stack_user_font_element), S(nk_config_stack_button_behavior_element),
	S(nk_config_stack_style_item), S(nk_config_stack_float), S(nk_config_stack_vec2),
	S(nk_config_stack_flags), S(nk_config_stack_color), S(nk_config_stack_user_font),
	S(nk_config_stack_button_behavior), S(nk_configuration_stacks), S(nk_table),
	U(nk_page_data), S(nk_page_element), S(nk_page), S(nk_pool), S(nk_context),
};

const nk_odin_layout_entry *nk_odin_layout(size_t *count)
{
	*count = sizeof(layouts) / sizeof(layouts[0]);
	return layouts;
}

typedef struct { const char *name; size_t offset; } nk_odin_offset_entry;

#define O(t, f) {#t "." #f, offsetof(struct t, f)}

static const nk_odin_offset_entry offsets[] = {
	O(nk_command, type), O(nk_command, next),
	O(nk_command_scissor, header), O(nk_command_scissor, x), O(nk_command_scissor, y),
	O(nk_command_scissor, w), O(nk_command_scissor, h),
	O(nk_command_line, header), O(nk_command_line, line_thickness),
	O(nk_command_line, begin), O(nk_command_line, end), O(nk_command_line, color),
	O(nk_command_rect, header), O(nk_command_rect, rounding),
	O(nk_command_rect, line_thickness), O(nk_command_rect, x), O(nk_command_rect, y),
	O(nk_command_rect, w), O(nk_command_rect, h), O(nk_command_rect, color),
	O(nk_command_rect_filled, header), O(nk_command_rect_filled, rounding),
	O(nk_command_rect_filled, x), O(nk_command_rect_filled, y),
	O(nk_command_rect_filled, w), O(nk_command_rect_filled, h),
	O(nk_command_rect_filled, color),
	O(nk_command_rect_multi_color, header), O(nk_command_rect_multi_color, x),
	O(nk_command_rect_multi_color, y), O(nk_command_rect_multi_color, w),
	O(nk_command_rect_multi_color, h), O(nk_command_rect_multi_color, left),
	O(nk_command_rect_multi_color, top), O(nk_command_rect_multi_color, bottom),
	O(nk_command_rect_multi_color, right),
	O(nk_command_triangle_filled, header), O(nk_command_triangle_filled, a),
	O(nk_command_triangle_filled, b), O(nk_command_triangle_filled, c),
	O(nk_command_triangle_filled, color),
	O(nk_command_circle, header), O(nk_command_circle, x), O(nk_command_circle, y),
	O(nk_command_circle, line_thickness), O(nk_command_circle, w),
	O(nk_command_circle, h), O(nk_command_circle, color),
	O(nk_command_circle_filled, header), O(nk_command_circle_filled, x),
	O(nk_command_circle_filled, y), O(nk_command_circle_filled, w),
	O(nk_command_circle_filled, h), O(nk_command_circle_filled, color),
	O(nk_command_arc_filled, header), O(nk_command_arc_filled, cx),
	O(nk_command_arc_filled, cy), O(nk_command_arc_filled, r),
	O(nk_command_arc_filled, a), O(nk_command_arc_filled, color),
	O(nk_command_polygon_filled, header), O(nk_command_polygon_filled, color),
	O(nk_command_polygon_filled, point_count), O(nk_command_polygon_filled, points),
	O(nk_command_polyline, header), O(nk_command_polyline, color),
	O(nk_command_polyline, line_thickness), O(nk_command_polyline, point_count),
	O(nk_command_polyline, points),
	O(nk_command_image, header), O(nk_command_image, x), O(nk_command_image, y),
	O(nk_command_image, w), O(nk_command_image, h), O(nk_command_image, img),
	O(nk_command_image, col),
	O(nk_command_text, header), O(nk_command_text, font), O(nk_command_text, background),
	O(nk_command_text, foreground), O(nk_command_text, x), O(nk_command_text, y),
	O(nk_command_text, w), O(nk_command_text, h), O(nk_command_text, height),
	O(nk_command_text, length), O(nk_command_text, string),
	O(nk_draw_command, elem_count), O(nk_draw_command, clip_rect),
	O(nk_draw_command, texture),
	O(nk_convert_config, global_alpha), O(nk_convert_config, line_AA),
	O(nk_convert_config, shape_AA), O(nk_convert_config, circle_segment_count),
	O(nk_convert_config, arc_segment_count), O(nk_convert_config, curve_segment_count),
	O(nk_convert_config, tex_null), O(nk_convert_config, vertex_layout),
	O(nk_convert_config, vertex_size), O(nk_convert_config, vertex_alignment),
	O(nk_draw_vertex_layout_element, attribute), O(nk_draw_vertex_layout_element, format),
	O(nk_draw_vertex_layout_element, offset),
	O(nk_user_font, userdata), O(nk_user_font, height), O(nk_user_font, width),
	O(nk_user_font, query), O(nk_user_font, texture),
	O(nk_context, input), O(nk_context, style),
};

size_t nk_odin_offset(const char *field)
{
	size_t i;
	for (i = 0; i < sizeof(offsets) / sizeof(offsets[0]); i++)
		if (strcmp(offsets[i].name, field) == 0) return offsets[i].offset;
	return (size_t)-1;
}
