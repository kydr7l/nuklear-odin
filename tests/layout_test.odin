package nuklear_tests

import "core:c"
import "core:testing"
import nk ".."

when ODIN_OS == .Windows {
	foreign import layout "../lib/nuklear_layout.lib"
} else {
	foreign import layout "../lib/libnuklear_layout.a"
}

Layout_Entry :: struct {
	name:  cstring,
	size:  c.size_t,
	align: c.size_t,
}

@(default_calling_convention = "c")
foreign layout {
	nk_odin_layout :: proc(count: ^c.size_t) -> [^]Layout_Entry ---
	nk_odin_offset :: proc(field: cstring) -> c.size_t ---
}

// One entry for each public struct and union, with the C tag as the name.
odin_layouts := [?]Layout_Entry {
	{"nk_handle", size_of(nk.Handle), align_of(nk.Handle)},
	{"nk_color", size_of(nk.Color), align_of(nk.Color)},
	{"nk_colorf", size_of(nk.Colorf), align_of(nk.Colorf)},
	{"nk_vec2", size_of(nk.Vec2), align_of(nk.Vec2)},
	{"nk_vec2i", size_of(nk.Vec2i), align_of(nk.Vec2i)},
	{"nk_rect", size_of(nk.Rect), align_of(nk.Rect)},
	{"nk_recti", size_of(nk.Recti), align_of(nk.Recti)},
	{"nk_image", size_of(nk.Image), align_of(nk.Image)},
	{"nk_nine_slice", size_of(nk.Nine_Slice), align_of(nk.Nine_Slice)},
	{"nk_cursor", size_of(nk.Cursor), align_of(nk.Cursor)},
	{"nk_scroll", size_of(nk.Scroll), align_of(nk.Scroll)},
	{"nk_allocator", size_of(nk.Allocator), align_of(nk.Allocator)},
	{"nk_draw_null_texture", size_of(nk.Draw_Null_Texture), align_of(nk.Draw_Null_Texture)},
	{"nk_convert_config", size_of(nk.Convert_Config), align_of(nk.Convert_Config)},
	{"nk_list_view", size_of(nk.List_View), align_of(nk.List_View)},
	{"nk_user_font_glyph", size_of(nk.User_Font_Glyph), align_of(nk.User_Font_Glyph)},
	{"nk_user_font", size_of(nk.User_Font), align_of(nk.User_Font)},
	{"nk_baked_font", size_of(nk.Baked_Font), align_of(nk.Baked_Font)},
	{"nk_font_config", size_of(nk.Font_Config), align_of(nk.Font_Config)},
	{"nk_font_glyph", size_of(nk.Font_Glyph), align_of(nk.Font_Glyph)},
	{"nk_font", size_of(nk.Font), align_of(nk.Font)},
	{"nk_font_atlas", size_of(nk.Font_Atlas), align_of(nk.Font_Atlas)},
	{"nk_memory_status", size_of(nk.Memory_Status), align_of(nk.Memory_Status)},
	{"nk_buffer_marker", size_of(nk.Buffer_Marker), align_of(nk.Buffer_Marker)},
	{"nk_memory", size_of(nk.Memory), align_of(nk.Memory)},
	{"nk_buffer", size_of(nk.Buffer), align_of(nk.Buffer)},
	{"nk_str", size_of(nk.Str), align_of(nk.Str)},
	{"nk_clipboard", size_of(nk.Clipboard), align_of(nk.Clipboard)},
	{"nk_text_undo_record", size_of(nk.Text_Undo_Record), align_of(nk.Text_Undo_Record)},
	{"nk_text_undo_state", size_of(nk.Text_Undo_State), align_of(nk.Text_Undo_State)},
	{"nk_text_edit", size_of(nk.Text_Edit), align_of(nk.Text_Edit)},
	{"nk_command", size_of(nk.Command), align_of(nk.Command)},
	{"nk_command_scissor", size_of(nk.Command_Scissor), align_of(nk.Command_Scissor)},
	{"nk_command_line", size_of(nk.Command_Line), align_of(nk.Command_Line)},
	{"nk_command_curve", size_of(nk.Command_Curve), align_of(nk.Command_Curve)},
	{"nk_command_rect", size_of(nk.Command_Rect), align_of(nk.Command_Rect)},
	{"nk_command_rect_filled", size_of(nk.Command_Rect_Filled), align_of(nk.Command_Rect_Filled)},
	{"nk_command_rect_multi_color", size_of(nk.Command_Rect_Multi_Color), align_of(nk.Command_Rect_Multi_Color)},
	{"nk_command_triangle", size_of(nk.Command_Triangle), align_of(nk.Command_Triangle)},
	{"nk_command_triangle_filled", size_of(nk.Command_Triangle_Filled), align_of(nk.Command_Triangle_Filled)},
	{"nk_command_circle", size_of(nk.Command_Circle), align_of(nk.Command_Circle)},
	{"nk_command_circle_filled", size_of(nk.Command_Circle_Filled), align_of(nk.Command_Circle_Filled)},
	{"nk_command_arc", size_of(nk.Command_Arc), align_of(nk.Command_Arc)},
	{"nk_command_arc_filled", size_of(nk.Command_Arc_Filled), align_of(nk.Command_Arc_Filled)},
	{"nk_command_polygon", size_of(nk.Command_Polygon), align_of(nk.Command_Polygon)},
	{"nk_command_polygon_filled", size_of(nk.Command_Polygon_Filled), align_of(nk.Command_Polygon_Filled)},
	{"nk_command_polyline", size_of(nk.Command_Polyline), align_of(nk.Command_Polyline)},
	{"nk_command_image", size_of(nk.Command_Image), align_of(nk.Command_Image)},
	{"nk_command_custom", size_of(nk.Command_Custom), align_of(nk.Command_Custom)},
	{"nk_command_text", size_of(nk.Command_Text), align_of(nk.Command_Text)},
	{"nk_command_buffer", size_of(nk.Command_Buffer), align_of(nk.Command_Buffer)},
	{"nk_mouse_button", size_of(nk.Mouse_Button), align_of(nk.Mouse_Button)},
	{"nk_mouse", size_of(nk.Mouse), align_of(nk.Mouse)},
	{"nk_key", size_of(nk.Key), align_of(nk.Key)},
	{"nk_keyboard", size_of(nk.Keyboard), align_of(nk.Keyboard)},
	{"nk_input", size_of(nk.Input), align_of(nk.Input)},
	{"nk_draw_vertex_layout_element", size_of(nk.Draw_Vertex_Layout_Element), align_of(nk.Draw_Vertex_Layout_Element)},
	{"nk_draw_command", size_of(nk.Draw_Command), align_of(nk.Draw_Command)},
	{"nk_draw_list", size_of(nk.Draw_List), align_of(nk.Draw_List)},
	{"nk_style_item_data", size_of(nk.Style_Item_Data), align_of(nk.Style_Item_Data)},
	{"nk_style_item", size_of(nk.Style_Item), align_of(nk.Style_Item)},
	{"nk_style_text", size_of(nk.Style_Text), align_of(nk.Style_Text)},
	{"nk_style_link", size_of(nk.Style_Link), align_of(nk.Style_Link)},
	{"nk_style_button", size_of(nk.Style_Button), align_of(nk.Style_Button)},
	{"nk_style_toggle", size_of(nk.Style_Toggle), align_of(nk.Style_Toggle)},
	{"nk_style_selectable", size_of(nk.Style_Selectable), align_of(nk.Style_Selectable)},
	{"nk_style_slider", size_of(nk.Style_Slider), align_of(nk.Style_Slider)},
	{"nk_style_knob", size_of(nk.Style_Knob), align_of(nk.Style_Knob)},
	{"nk_style_progress", size_of(nk.Style_Progress), align_of(nk.Style_Progress)},
	{"nk_style_scrollbar", size_of(nk.Style_Scrollbar), align_of(nk.Style_Scrollbar)},
	{"nk_style_edit", size_of(nk.Style_Edit), align_of(nk.Style_Edit)},
	{"nk_style_property", size_of(nk.Style_Property), align_of(nk.Style_Property)},
	{"nk_style_chart", size_of(nk.Style_Chart), align_of(nk.Style_Chart)},
	{"nk_style_combo", size_of(nk.Style_Combo), align_of(nk.Style_Combo)},
	{"nk_style_tab", size_of(nk.Style_Tab), align_of(nk.Style_Tab)},
	{"nk_style_window_header", size_of(nk.Style_Window_Header), align_of(nk.Style_Window_Header)},
	{"nk_style_window", size_of(nk.Style_Window), align_of(nk.Style_Window)},
	{"nk_style", size_of(nk.Style), align_of(nk.Style)},
	{"nk_chart_slot", size_of(nk.Chart_Slot), align_of(nk.Chart_Slot)},
	{"nk_chart", size_of(nk.Chart), align_of(nk.Chart)},
	{"nk_row_layout", size_of(nk.Row_Layout), align_of(nk.Row_Layout)},
	{"nk_popup_buffer", size_of(nk.Popup_Buffer), align_of(nk.Popup_Buffer)},
	{"nk_menu_state", size_of(nk.Menu_State), align_of(nk.Menu_State)},
	{"nk_panel", size_of(nk.Panel), align_of(nk.Panel)},
	{"nk_popup_state", size_of(nk.Popup_State), align_of(nk.Popup_State)},
	{"nk_edit_state", size_of(nk.Edit_State), align_of(nk.Edit_State)},
	{"nk_property_state", size_of(nk.Property_State), align_of(nk.Property_State)},
	{"nk_window", size_of(nk.Window), align_of(nk.Window)},
	{"nk_config_stack_style_item_element", size_of(nk.Config_Stack_Style_Item_Element), align_of(nk.Config_Stack_Style_Item_Element)},
	{"nk_config_stack_float_element", size_of(nk.Config_Stack_Float_Element), align_of(nk.Config_Stack_Float_Element)},
	{"nk_config_stack_vec2_element", size_of(nk.Config_Stack_Vec2_Element), align_of(nk.Config_Stack_Vec2_Element)},
	{"nk_config_stack_flags_element", size_of(nk.Config_Stack_Flags_Element), align_of(nk.Config_Stack_Flags_Element)},
	{"nk_config_stack_color_element", size_of(nk.Config_Stack_Color_Element), align_of(nk.Config_Stack_Color_Element)},
	{"nk_config_stack_user_font_element", size_of(nk.Config_Stack_User_Font_Element), align_of(nk.Config_Stack_User_Font_Element)},
	{"nk_config_stack_button_behavior_element", size_of(nk.Config_Stack_Button_Behavior_Element), align_of(nk.Config_Stack_Button_Behavior_Element)},
	{"nk_config_stack_style_item", size_of(nk.Config_Stack_Style_Item), align_of(nk.Config_Stack_Style_Item)},
	{"nk_config_stack_float", size_of(nk.Config_Stack_Float), align_of(nk.Config_Stack_Float)},
	{"nk_config_stack_vec2", size_of(nk.Config_Stack_Vec2), align_of(nk.Config_Stack_Vec2)},
	{"nk_config_stack_flags", size_of(nk.Config_Stack_Flags), align_of(nk.Config_Stack_Flags)},
	{"nk_config_stack_color", size_of(nk.Config_Stack_Color), align_of(nk.Config_Stack_Color)},
	{"nk_config_stack_user_font", size_of(nk.Config_Stack_User_Font), align_of(nk.Config_Stack_User_Font)},
	{"nk_config_stack_button_behavior", size_of(nk.Config_Stack_Button_Behavior), align_of(nk.Config_Stack_Button_Behavior)},
	{"nk_configuration_stacks", size_of(nk.Configuration_Stacks), align_of(nk.Configuration_Stacks)},
	{"nk_table", size_of(nk.Table), align_of(nk.Table)},
	{"nk_page_data", size_of(nk.Page_Data), align_of(nk.Page_Data)},
	{"nk_page_element", size_of(nk.Page_Element), align_of(nk.Page_Element)},
	{"nk_page", size_of(nk.Page), align_of(nk.Page)},
	{"nk_pool", size_of(nk.Pool), align_of(nk.Pool)},
	{"nk_context", size_of(nk.Context), align_of(nk.Context)},
}

@(test)
test_struct_layouts :: proc(t: ^testing.T) {
	count: c.size_t
	entries := nk_odin_layout(&count)[:count]
	testing.expect_value(t, len(odin_layouts), int(count))
	for e in entries {
		found := false
		for o in odin_layouts {
			if o.name != e.name do continue
			found = true
			testing.expectf(t, o.size == e.size, "%s: the Odin size is %d, but the C size is %d", e.name, o.size, e.size)
			testing.expectf(t, o.align == e.align, "%s: the Odin alignment is %d, but the C alignment is %d", e.name, o.align, e.align)
		}
		testing.expectf(t, found, "%s: the Odin table has no entry", e.name)
	}
}

Offset_Entry :: struct {
	name:   cstring,
	offset: uintptr,
}

// The C name of each field is "c_tag.field".
odin_offsets := [?]Offset_Entry {
	{"nk_command.type", offset_of(nk.Command, type)},
	{"nk_command.next", offset_of(nk.Command, next)},
	{"nk_command_scissor.header", offset_of(nk.Command_Scissor, header)},
	{"nk_command_scissor.x", offset_of(nk.Command_Scissor, x)},
	{"nk_command_scissor.y", offset_of(nk.Command_Scissor, y)},
	{"nk_command_scissor.w", offset_of(nk.Command_Scissor, w)},
	{"nk_command_scissor.h", offset_of(nk.Command_Scissor, h)},
	{"nk_command_line.header", offset_of(nk.Command_Line, header)},
	{"nk_command_line.line_thickness", offset_of(nk.Command_Line, line_thickness)},
	{"nk_command_line.begin", offset_of(nk.Command_Line, begin)},
	{"nk_command_line.end", offset_of(nk.Command_Line, end)},
	{"nk_command_line.color", offset_of(nk.Command_Line, color)},
	{"nk_command_rect.header", offset_of(nk.Command_Rect, header)},
	{"nk_command_rect.rounding", offset_of(nk.Command_Rect, rounding)},
	{"nk_command_rect.line_thickness", offset_of(nk.Command_Rect, line_thickness)},
	{"nk_command_rect.x", offset_of(nk.Command_Rect, x)},
	{"nk_command_rect.y", offset_of(nk.Command_Rect, y)},
	{"nk_command_rect.w", offset_of(nk.Command_Rect, w)},
	{"nk_command_rect.h", offset_of(nk.Command_Rect, h)},
	{"nk_command_rect.color", offset_of(nk.Command_Rect, color)},
	{"nk_command_rect_filled.header", offset_of(nk.Command_Rect_Filled, header)},
	{"nk_command_rect_filled.rounding", offset_of(nk.Command_Rect_Filled, rounding)},
	{"nk_command_rect_filled.x", offset_of(nk.Command_Rect_Filled, x)},
	{"nk_command_rect_filled.y", offset_of(nk.Command_Rect_Filled, y)},
	{"nk_command_rect_filled.w", offset_of(nk.Command_Rect_Filled, w)},
	{"nk_command_rect_filled.h", offset_of(nk.Command_Rect_Filled, h)},
	{"nk_command_rect_filled.color", offset_of(nk.Command_Rect_Filled, color)},
	{"nk_command_rect_multi_color.header", offset_of(nk.Command_Rect_Multi_Color, header)},
	{"nk_command_rect_multi_color.x", offset_of(nk.Command_Rect_Multi_Color, x)},
	{"nk_command_rect_multi_color.y", offset_of(nk.Command_Rect_Multi_Color, y)},
	{"nk_command_rect_multi_color.w", offset_of(nk.Command_Rect_Multi_Color, w)},
	{"nk_command_rect_multi_color.h", offset_of(nk.Command_Rect_Multi_Color, h)},
	{"nk_command_rect_multi_color.left", offset_of(nk.Command_Rect_Multi_Color, left)},
	{"nk_command_rect_multi_color.top", offset_of(nk.Command_Rect_Multi_Color, top)},
	{"nk_command_rect_multi_color.bottom", offset_of(nk.Command_Rect_Multi_Color, bottom)},
	{"nk_command_rect_multi_color.right", offset_of(nk.Command_Rect_Multi_Color, right)},
	{"nk_command_triangle_filled.header", offset_of(nk.Command_Triangle_Filled, header)},
	{"nk_command_triangle_filled.a", offset_of(nk.Command_Triangle_Filled, a)},
	{"nk_command_triangle_filled.b", offset_of(nk.Command_Triangle_Filled, b)},
	{"nk_command_triangle_filled.c", offset_of(nk.Command_Triangle_Filled, c)},
	{"nk_command_triangle_filled.color", offset_of(nk.Command_Triangle_Filled, color)},
	{"nk_command_circle.header", offset_of(nk.Command_Circle, header)},
	{"nk_command_circle.x", offset_of(nk.Command_Circle, x)},
	{"nk_command_circle.y", offset_of(nk.Command_Circle, y)},
	{"nk_command_circle.line_thickness", offset_of(nk.Command_Circle, line_thickness)},
	{"nk_command_circle.w", offset_of(nk.Command_Circle, w)},
	{"nk_command_circle.h", offset_of(nk.Command_Circle, h)},
	{"nk_command_circle.color", offset_of(nk.Command_Circle, color)},
	{"nk_command_circle_filled.header", offset_of(nk.Command_Circle_Filled, header)},
	{"nk_command_circle_filled.x", offset_of(nk.Command_Circle_Filled, x)},
	{"nk_command_circle_filled.y", offset_of(nk.Command_Circle_Filled, y)},
	{"nk_command_circle_filled.w", offset_of(nk.Command_Circle_Filled, w)},
	{"nk_command_circle_filled.h", offset_of(nk.Command_Circle_Filled, h)},
	{"nk_command_circle_filled.color", offset_of(nk.Command_Circle_Filled, color)},
	{"nk_command_arc_filled.header", offset_of(nk.Command_Arc_Filled, header)},
	{"nk_command_arc_filled.cx", offset_of(nk.Command_Arc_Filled, cx)},
	{"nk_command_arc_filled.cy", offset_of(nk.Command_Arc_Filled, cy)},
	{"nk_command_arc_filled.r", offset_of(nk.Command_Arc_Filled, r)},
	{"nk_command_arc_filled.a", offset_of(nk.Command_Arc_Filled, a)},
	{"nk_command_arc_filled.color", offset_of(nk.Command_Arc_Filled, color)},
	{"nk_command_polygon_filled.header", offset_of(nk.Command_Polygon_Filled, header)},
	{"nk_command_polygon_filled.color", offset_of(nk.Command_Polygon_Filled, color)},
	{"nk_command_polygon_filled.point_count", offset_of(nk.Command_Polygon_Filled, point_count)},
	{"nk_command_polygon_filled.points", offset_of(nk.Command_Polygon_Filled, points)},
	{"nk_command_polyline.header", offset_of(nk.Command_Polyline, header)},
	{"nk_command_polyline.color", offset_of(nk.Command_Polyline, color)},
	{"nk_command_polyline.line_thickness", offset_of(nk.Command_Polyline, line_thickness)},
	{"nk_command_polyline.point_count", offset_of(nk.Command_Polyline, point_count)},
	{"nk_command_polyline.points", offset_of(nk.Command_Polyline, points)},
	{"nk_command_image.header", offset_of(nk.Command_Image, header)},
	{"nk_command_image.x", offset_of(nk.Command_Image, x)},
	{"nk_command_image.y", offset_of(nk.Command_Image, y)},
	{"nk_command_image.w", offset_of(nk.Command_Image, w)},
	{"nk_command_image.h", offset_of(nk.Command_Image, h)},
	{"nk_command_image.img", offset_of(nk.Command_Image, img)},
	{"nk_command_image.col", offset_of(nk.Command_Image, col)},
	{"nk_command_text.header", offset_of(nk.Command_Text, header)},
	{"nk_command_text.font", offset_of(nk.Command_Text, font)},
	{"nk_command_text.background", offset_of(nk.Command_Text, background)},
	{"nk_command_text.foreground", offset_of(nk.Command_Text, foreground)},
	{"nk_command_text.x", offset_of(nk.Command_Text, x)},
	{"nk_command_text.y", offset_of(nk.Command_Text, y)},
	{"nk_command_text.w", offset_of(nk.Command_Text, w)},
	{"nk_command_text.h", offset_of(nk.Command_Text, h)},
	{"nk_command_text.height", offset_of(nk.Command_Text, height)},
	{"nk_command_text.length", offset_of(nk.Command_Text, length)},
	{"nk_command_text.string", offset_of(nk.Command_Text, string)},
	{"nk_draw_command.elem_count", offset_of(nk.Draw_Command, elem_count)},
	{"nk_draw_command.clip_rect", offset_of(nk.Draw_Command, clip_rect)},
	{"nk_draw_command.texture", offset_of(nk.Draw_Command, texture)},
	{"nk_convert_config.global_alpha", offset_of(nk.Convert_Config, global_alpha)},
	{"nk_convert_config.line_AA", offset_of(nk.Convert_Config, line_AA)},
	{"nk_convert_config.shape_AA", offset_of(nk.Convert_Config, shape_AA)},
	{"nk_convert_config.circle_segment_count", offset_of(nk.Convert_Config, circle_segment_count)},
	{"nk_convert_config.arc_segment_count", offset_of(nk.Convert_Config, arc_segment_count)},
	{"nk_convert_config.curve_segment_count", offset_of(nk.Convert_Config, curve_segment_count)},
	{"nk_convert_config.tex_null", offset_of(nk.Convert_Config, tex_null)},
	{"nk_convert_config.vertex_layout", offset_of(nk.Convert_Config, vertex_layout)},
	{"nk_convert_config.vertex_size", offset_of(nk.Convert_Config, vertex_size)},
	{"nk_convert_config.vertex_alignment", offset_of(nk.Convert_Config, vertex_alignment)},
	{"nk_draw_vertex_layout_element.attribute", offset_of(nk.Draw_Vertex_Layout_Element, attribute)},
	{"nk_draw_vertex_layout_element.format", offset_of(nk.Draw_Vertex_Layout_Element, format)},
	{"nk_draw_vertex_layout_element.offset", offset_of(nk.Draw_Vertex_Layout_Element, offset)},
	{"nk_user_font.userdata", offset_of(nk.User_Font, userdata)},
	{"nk_user_font.height", offset_of(nk.User_Font, height)},
	{"nk_user_font.width", offset_of(nk.User_Font, width)},
	{"nk_user_font.query", offset_of(nk.User_Font, query)},
	{"nk_user_font.texture", offset_of(nk.User_Font, texture)},
	{"nk_context.input", offset_of(nk.Context, input)},
	{"nk_context.style", offset_of(nk.Context, style)},
}

@(test)
test_command_offsets :: proc(t: ^testing.T) {
	for o in odin_offsets {
		c_offset := nk_odin_offset(o.name)
		testing.expectf(t, c_offset != max(c.size_t), "%s: layout.c has no entry", o.name)
		testing.expectf(t, uint(o.offset) == c_offset, "%s: the Odin offset is %d, but the C offset is %d", o.name, o.offset, c_offset)
	}
}
