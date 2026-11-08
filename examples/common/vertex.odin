package common

import "core:c"
import nk "../.."

// The vertex format that the demo backends upload to the GPU.
Vertex :: struct {
	position: [2]f32,
	uv:       [2]f32,
	color:    [4]u8,
}

// Convert the draw commands of the context into vertices and indices.
convert :: proc(ctx: ^nk.Context, cmds, verts, elems: ^nk.Buffer, null_tex: nk.Draw_Null_Texture) -> nk.Flags {
	@(static) layout := [?]nk.Draw_Vertex_Layout_Element {
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
		tex_null             = null_tex,
		vertex_layout        = raw_data(layout[:]),
		vertex_size          = size_of(Vertex),
		vertex_alignment     = align_of(Vertex),
	}
	return nk.convert(ctx, cmds, verts, elems, &config)
}

// Bake the default font into RGBA32 pixels. The caller uploads the pixels, then calls nk.font_atlas_end.
// The pixels belong to the atlas. They stay valid until nk.font_atlas_clear.
bake_default_font :: proc(atlas: ^nk.Font_Atlas, height: f32) -> (font: ^nk.Font, pixels: []u8, atlas_width, atlas_height: i32) {
	nk.font_atlas_init_default(atlas)
	nk.font_atlas_begin(atlas)
	font = nk.font_atlas_add_default(atlas, height, nil)
	w, h: c.int
	data := nk.font_atlas_bake(atlas, &w, &h, nk.FONT_ATLAS_RGBA32)
	if data != nil {
		pixels = ([^]u8)(data)[:int(w) * int(h) * 4]
	}
	return font, pixels, w, h
}
