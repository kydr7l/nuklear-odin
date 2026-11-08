#+build windows
// Draw the Nuklear demo UI with GDI in a Win32 window.
// This is a port of nuklear/demo/gdi/nuklear_gdi.h and main.c.
package main

import "base:runtime"
import "core:fmt"
import "core:math"
import "core:os"
import win "core:sys/windows"
import nk "../.."
import "../common"

// These GDI procedures are not in core:sys/windows.
foreign import gdi32 "system:Gdi32.lib"

@(default_calling_convention = "system")
foreign gdi32 {
	Polyline          :: proc(hdc: win.HDC, apt: [^]win.POINT, cpt: win.INT) -> win.BOOL ---
	PolyBezier        :: proc(hdc: win.HDC, apt: [^]win.POINT, cpt: win.DWORD) -> win.BOOL ---
	SetArcDirection   :: proc(hdc: win.HDC, dir: win.INT) -> win.INT ---
	IntersectClipRect :: proc(hdc: win.HDC, left, top, right, bottom: win.INT) -> win.INT ---
	SelectClipRgn     :: proc(hdc: win.HDC, rgn: win.HRGN) -> win.INT ---
}

AD_COUNTERCLOCKWISE :: 1

Font :: struct {
	user:   nk.User_Font,
	height: win.INT,
	handle: win.HFONT,
	dc:     win.HDC, // the DC that measures the text width
}

Gdi :: struct {
	ctx:            nk.Context,
	font:           Font,
	bitmap:         win.HBITMAP, // the back buffer
	window_dc:      win.HDC,
	memory_dc:      win.HDC, // the back buffer is selected in this DC
	width, height:  win.INT,
	insert_toggle:  bool,
	high_surrogate: win.WCHAR, // the first half of a UTF-16 pair, or 0
}

gdi: Gdi

color_ref :: proc "contextless" (c: nk.Color) -> win.COLORREF {
	return win.RGB(c.r, c.g, c.b)
}

// Convert UTF-8 to UTF-16. The caller must have a temp allocator guard.
to_wide :: proc(text: cstring, count: win.INT) -> []win.WCHAR {
	n := win.MultiByteToWideChar(win.CP_UTF8, 0, (^u8)(text), count, nil, 0)
	wide := make([]win.WCHAR, n, context.temp_allocator)
	win.MultiByteToWideChar(win.CP_UTF8, 0, (^u8)(text), count, (^u16)(raw_data(wide)), n)
	return wide
}

to_points :: proc(pts: [^]nk.Vec2i, count: int, close: bool) -> []win.POINT {
	out := make([]win.POINT, count + 1 if close else count, context.temp_allocator)
	for i in 0 ..< count {
		out[i] = {win.LONG(pts[i].x), win.LONG(pts[i].y)}
	}
	if close && count > 0 {
		out[count] = out[0]
	}
	return out
}

// ---- The font ----

font_width :: proc "c" (handle: nk.Handle, height: f32, text: cstring, count: i32) -> f32 {
	context = runtime.default_context()
	runtime.DEFAULT_TEMP_ALLOCATOR_TEMP_GUARD()
	font := cast(^Font)handle.ptr
	if font == nil || text == nil {
		return 0
	}
	wide := to_wide(text, count)
	size: win.SIZE
	if win.GetTextExtentPoint32W(font.dc, cstring16(raw_data(wide)), win.INT(len(wide)), &size) {
		return f32(size.cx)
	}
	return -1
}

font_create :: proc(font: ^Font, name: cstring16, size: win.INT) {
	font.dc = win.CreateCompatibleDC(nil)
	font.handle = win.CreateFontW(
		size, 0, 0, 0, win.FW_NORMAL, 0, 0, 0, win.DEFAULT_CHARSET, win.OUT_DEFAULT_PRECIS,
		win.CLIP_DEFAULT_PRECIS, win.CLEARTYPE_QUALITY, win.DEFAULT_PITCH | win.FF_DONTCARE, name,
	)
	win.SelectObject(font.dc, win.HGDIOBJ(font.handle))
	metric: win.TEXTMETRICW
	win.GetTextMetricsW(font.dc, &metric)
	font.height = metric.tmHeight
	font.user.userdata.ptr = font
	font.user.height = f32(font.height)
	font.user.width = font_width
}

// ---- The clipboard ----

clipboard_paste :: proc "c" (handle: nk.Handle, edit: ^nk.Text_Edit) {
	context = runtime.default_context()
	runtime.DEFAULT_TEMP_ALLOCATOR_TEMP_GUARD()
	if !win.IsClipboardFormatAvailable(win.CF_UNICODETEXT) || !win.OpenClipboard(nil) {
		return
	}
	defer win.CloseClipboard()
	mem := win.GetClipboardData(win.CF_UNICODETEXT)
	if mem == nil {
		return
	}
	max_len := int(win.GlobalSize(win.LPVOID(mem))) / size_of(win.WCHAR)
	wstr := cast([^]win.WCHAR)win.GlobalLock(win.HGLOBAL(mem))
	if wstr == nil {
		return
	}
	defer win.GlobalUnlock(win.HGLOBAL(mem))
	wlen := 0
	for wlen < max_len && wstr[wlen] != 0 {
		wlen += 1
	}
	n := win.WideCharToMultiByte(win.CP_UTF8, 0, cstring16(wstr), win.INT(wlen), nil, 0, nil, nil)
	if n == 0 {
		return
	}
	utf8 := make([]u8, n, context.temp_allocator)
	win.WideCharToMultiByte(win.CP_UTF8, 0, cstring16(wstr), win.INT(wlen), (^u8)(raw_data(utf8)), n, nil, nil)
	nk.textedit_paste(edit, cstring(raw_data(utf8)), n)
}

clipboard_copy :: proc "c" (handle: nk.Handle, text: cstring, count: i32) {
	context = runtime.default_context()
	runtime.DEFAULT_TEMP_ALLOCATOR_TEMP_GUARD()
	if !win.OpenClipboard(nil) {
		return
	}
	defer win.CloseClipboard()
	wide := to_wide(text, count)
	if len(wide) == 0 {
		return
	}
	mem := win.GlobalAlloc(win.GMEM_MOVEABLE, win.SIZE_T((len(wide) + 1) * size_of(win.WCHAR)))
	if mem == nil {
		return
	}
	dest := cast([^]win.WCHAR)win.GlobalLock(win.HGLOBAL(mem))
	if dest == nil {
		return
	}
	copy(dest[:len(wide)], wide)
	dest[len(wide)] = 0
	win.GlobalUnlock(win.HGLOBAL(mem))
	win.EmptyClipboard()
	// The system owns the memory after this call succeeds.
	win.SetClipboardData(win.CF_UNICODETEXT, win.HANDLE(mem))
}

// ---- The back buffer ----

// Make a back buffer of the given size and fill it with the background color.
buffer_resize :: proc(width, height: win.INT) {
	new_bitmap := win.CreateCompatibleBitmap(gdi.window_dc, width, height)
	old_bitmap := win.SelectObject(gdi.memory_dc, win.HGDIOBJ(new_bitmap))
	if gdi.bitmap != nil {
		win.DeleteObject(win.HGDIOBJ(gdi.bitmap))
	} else {
		win.DeleteObject(old_bitmap) // the 1x1 bitmap of a new memory DC
	}
	gdi.bitmap = new_bitmap
	gdi.width, gdi.height = width, height
	clear_buffer(common.BACKGROUND)
}

clear_buffer :: proc(color: nk.Color) {
	dc := gdi.memory_dc
	win.SelectObject(dc, win.GetStockObject(win.DC_BRUSH))
	win.SetDCBrushColor(dc, color_ref(color))
	rect := win.RECT{0, 0, gdi.width, gdi.height}
	win.FillRect(dc, &rect, win.HBRUSH(win.GetStockObject(win.DC_BRUSH)))
}

blit :: proc(dc: win.HDC) {
	win.BitBlt(dc, 0, 0, gdi.width, gdi.height, gdi.memory_dc, 0, 0, win.SRCCOPY)
}

// ---- The renderer ----

// Select a pen of the given thickness. Call pen_end with the result.
pen_begin :: proc(dc: win.HDC, thickness: win.INT, color: nk.Color) -> win.HPEN {
	if thickness == 1 {
		win.SetDCPenColor(dc, color_ref(color))
		return nil
	}
	pen := win.CreatePen(win.PS_SOLID, thickness, color_ref(color))
	win.SelectObject(dc, win.HGDIOBJ(pen))
	return pen
}

pen_end :: proc(dc: win.HDC, pen: win.HPEN) {
	if pen != nil {
		win.SelectObject(dc, win.GetStockObject(win.DC_PEN))
		win.DeleteObject(win.HGDIOBJ(pen))
	}
}

set_fill :: proc(dc: win.HDC, color: nk.Color) {
	win.SetDCPenColor(dc, color_ref(color))
	win.SetDCBrushColor(dc, color_ref(color))
}

// Draw a hollow shape: select the null brush, call draw, then restore the brush.
hollow :: proc(dc: win.HDC) -> win.HGDIOBJ {
	return win.SelectObject(dc, win.GetStockObject(win.NULL_BRUSH))
}

draw_arc :: proc(dc: win.HDC, cx, cy: win.INT, r: win.INT, a_min, a_delta: f32) {
	start_x := cx + win.INT(f32(r) * math.cos(a_min + a_delta))
	start_y := cy + win.INT(f32(r) * math.sin(a_min + a_delta))
	end_x := cx + win.INT(f32(r) * math.cos(a_min))
	end_y := cy + win.INT(f32(r) * math.sin(a_min))
	win.Pie(dc, cx - r, cy - r, cx + r, cy + r, start_x, start_y, end_x, end_y)
}

vertex :: proc(x, y: win.LONG, c: nk.Color) -> win.TRIVERTEX {
	return {x = x, y = y, Red = win.COLOR16(c.r) << 8, Green = win.COLOR16(c.g) << 8, Blue = win.COLOR16(c.b) << 8, Alpha = 0xff00}
}

render :: proc(clear: nk.Color) {
	dc := gdi.memory_dc
	win.SelectObject(dc, win.GetStockObject(win.DC_PEN))
	win.SelectObject(dc, win.GetStockObject(win.DC_BRUSH))
	clear_buffer(clear)

	it := nk.Command_Iterator{ctx = &gdi.ctx}
	for cmd in nk.foreach(&it) {
		switch cmd.type {
		case nk.COMMAND_SCISSOR:
			s := cast(^nk.Command_Scissor)cmd
			SelectClipRgn(dc, nil)
			IntersectClipRect(dc, win.INT(s.x), win.INT(s.y), win.INT(s.x) + win.INT(s.w) + 1, win.INT(s.y) + win.INT(s.h) + 1)
		case nk.COMMAND_LINE:
			l := cast(^nk.Command_Line)cmd
			pen := pen_begin(dc, win.INT(l.line_thickness), l.color)
			win.MoveToEx(dc, win.INT(l.begin.x), win.INT(l.begin.y), nil)
			win.LineTo(dc, win.INT(l.end.x), win.INT(l.end.y))
			pen_end(dc, pen)
		case nk.COMMAND_CURVE:
			q := cast(^nk.Command_Curve)cmd
			p := [4]win.POINT{
				{win.LONG(q.begin.x), win.LONG(q.begin.y)},
				{win.LONG(q.ctrl[0].x), win.LONG(q.ctrl[0].y)},
				{win.LONG(q.ctrl[1].x), win.LONG(q.ctrl[1].y)},
				{win.LONG(q.end.x), win.LONG(q.end.y)},
			}
			pen := pen_begin(dc, win.INT(q.line_thickness), q.color)
			PolyBezier(dc, raw_data(p[:]), 4)
			pen_end(dc, pen)
		case nk.COMMAND_RECT:
			r := cast(^nk.Command_Rect)cmd
			x, y, w, h := win.INT(r.x), win.INT(r.y), win.INT(r.w), win.INT(r.h)
			pen := pen_begin(dc, win.INT(r.line_thickness), r.color)
			brush := hollow(dc)
			if r.rounding == 0 {
				win.Rectangle(dc, x, y, x + w, y + h)
			} else {
				win.RoundRect(dc, x, y, x + w, y + h, win.INT(r.rounding) * 2, win.INT(r.rounding) * 2)
			}
			win.SelectObject(dc, brush)
			pen_end(dc, pen)
		case nk.COMMAND_RECT_FILLED:
			r := cast(^nk.Command_Rect_Filled)cmd
			x, y, w, h := win.INT(r.x), win.INT(r.y), win.INT(r.w), win.INT(r.h)
			set_fill(dc, r.color)
			if r.rounding == 0 {
				rect := win.RECT{x, y, x + w, y + h}
				win.FillRect(dc, &rect, win.HBRUSH(win.GetStockObject(win.DC_BRUSH)))
			} else {
				win.RoundRect(dc, x, y, x + w, y + h, win.INT(r.rounding) * 2, win.INT(r.rounding) * 2)
			}
		case nk.COMMAND_RECT_MULTI_COLOR:
			r := cast(^nk.Command_Rect_Multi_Color)cmd
			x, y := win.LONG(r.x), win.LONG(r.y)
			x1, y1 := x + win.LONG(r.w), y + win.LONG(r.h)
			// The corners go clockwise from the top left: left, top, right, bottom.
			vt := [4]win.TRIVERTEX{
				vertex(x, y, r.left), vertex(x1, y, r.top), vertex(x1, y1, r.right), vertex(x, y1, r.bottom),
			}
			tri := [2]win.GRADIENT_TRIANGLE{{0, 1, 2}, {0, 2, 3}}
			win.GdiGradientFill(dc, raw_data(vt[:]), 4, raw_data(tri[:]), 2, win.GRADIENT_FILL_TRIANGLE)
		case nk.COMMAND_CIRCLE:
			c := cast(^nk.Command_Circle)cmd
			pen := pen_begin(dc, win.INT(c.line_thickness), c.color)
			brush := hollow(dc)
			win.Ellipse(dc, win.INT(c.x), win.INT(c.y), win.INT(c.x) + win.INT(c.w), win.INT(c.y) + win.INT(c.h))
			win.SelectObject(dc, brush)
			pen_end(dc, pen)
		case nk.COMMAND_CIRCLE_FILLED:
			c := cast(^nk.Command_Circle_Filled)cmd
			set_fill(dc, c.color)
			win.Ellipse(dc, win.INT(c.x), win.INT(c.y), win.INT(c.x) + win.INT(c.w), win.INT(c.y) + win.INT(c.h))
		case nk.COMMAND_ARC:
			q := cast(^nk.Command_Arc)cmd
			pen: win.HPEN
			if q.line_thickness == 1 {
				win.SetDCPenColor(dc, color_ref(q.color))
			} else {
				// A flat end cap makes a thick arc look better.
				brush := win.LOGBRUSH{lbStyle = win.BS_SOLID, lbColor = color_ref(q.color)}
				pen = win.ExtCreatePen(win.PS_SOLID | win.PS_ENDCAP_FLAT | win.PS_GEOMETRIC, win.DWORD(q.line_thickness), &brush, 0, nil)
				win.SelectObject(dc, win.HGDIOBJ(pen))
			}
			old_brush := hollow(dc)
			SetArcDirection(dc, AD_COUNTERCLOCKWISE)
			draw_arc(dc, win.INT(q.cx), win.INT(q.cy), win.INT(q.r), q.a[0], q.a[1])
			win.SelectObject(dc, old_brush)
			pen_end(dc, pen)
		case nk.COMMAND_ARC_FILLED:
			q := cast(^nk.Command_Arc_Filled)cmd
			set_fill(dc, q.color)
			draw_arc(dc, win.INT(q.cx), win.INT(q.cy), win.INT(q.r), q.a[0], q.a[1])
		case nk.COMMAND_TRIANGLE:
			t := cast(^nk.Command_Triangle)cmd
			p := [4]win.POINT{
				{win.LONG(t.a.x), win.LONG(t.a.y)},
				{win.LONG(t.b.x), win.LONG(t.b.y)},
				{win.LONG(t.c.x), win.LONG(t.c.y)},
				{win.LONG(t.a.x), win.LONG(t.a.y)},
			}
			pen := pen_begin(dc, win.INT(t.line_thickness), t.color)
			Polyline(dc, raw_data(p[:]), 4)
			pen_end(dc, pen)
		case nk.COMMAND_TRIANGLE_FILLED:
			t := cast(^nk.Command_Triangle_Filled)cmd
			p := [3]win.POINT{
				{win.LONG(t.a.x), win.LONG(t.a.y)},
				{win.LONG(t.b.x), win.LONG(t.b.y)},
				{win.LONG(t.c.x), win.LONG(t.c.y)},
			}
			set_fill(dc, t.color)
			win.Polygon(dc, raw_data(p[:]), 3)
		case nk.COMMAND_POLYGON:
			p := cast(^nk.Command_Polygon)cmd
			pts := to_points(cast([^]nk.Vec2i)&p.points, int(p.point_count), true)
			pen := pen_begin(dc, win.INT(p.line_thickness), p.color)
			Polyline(dc, raw_data(pts), win.INT(len(pts)))
			pen_end(dc, pen)
		case nk.COMMAND_POLYGON_FILLED:
			p := cast(^nk.Command_Polygon_Filled)cmd
			pts := to_points(cast([^]nk.Vec2i)&p.points, int(p.point_count), false)
			set_fill(dc, p.color)
			win.Polygon(dc, raw_data(pts), win.INT(len(pts)))
		case nk.COMMAND_POLYLINE:
			p := cast(^nk.Command_Polyline)cmd
			pts := to_points(cast([^]nk.Vec2i)&p.points, int(p.point_count), false)
			pen := pen_begin(dc, win.INT(p.line_thickness), p.color)
			Polyline(dc, raw_data(pts), win.INT(len(pts)))
			pen_end(dc, pen)
		case nk.COMMAND_TEXT:
			t := cast(^nk.Command_Text)cmd
			font := cast(^Font)t.font.userdata.ptr
			if font == nil || t.length == 0 {
				break
			}
			text := cstring(cast([^]u8)&t.string)
			wide := to_wide(text, t.length)
			// The text background is transparent.
			win.SetBkMode(dc, .TRANSPARENT)
			win.SetTextColor(dc, color_ref(t.foreground))
			win.SelectObject(dc, win.HGDIOBJ(font.handle))
			win.TextOutW(dc, win.INT(t.x), win.INT(t.y), cstring16(raw_data(wide)), win.INT(len(wide)))
		case nk.COMMAND_NOP, nk.COMMAND_IMAGE, nk.COMMAND_CUSTOM:
		// The overview does not make these commands.
		}
	}
	blit(gdi.window_dc)
	nk.clear(&gdi.ctx)
}

// ---- The window ----

button :: proc(b: nk.Buttons, lparam: win.LPARAM, down: bool) {
	nk.input_button(&gdi.ctx, b, win.GET_X_LPARAM(lparam), win.GET_Y_LPARAM(lparam), nk.Bool(down))
}

// Send a key to Nuklear. Return true if the key is handled.
handle_key :: proc(wparam: win.WPARAM, down: bool) -> bool {
	ctrl := win.GetKeyState(win.VK_CONTROL) & i16(-0x8000) != 0
	key :: proc(k: nk.Keys, down: bool) -> bool {
		nk.input_key(&gdi.ctx, k, nk.Bool(down))
		return true
	}
	switch wparam {
	case win.VK_SHIFT, win.VK_LSHIFT, win.VK_RSHIFT: return key(nk.KEY_SHIFT, down)
	case win.VK_CONTROL, win.VK_LCONTROL, win.VK_RCONTROL: return key(nk.KEY_CTRL, down)
	case win.VK_DELETE: return key(nk.KEY_DEL, down)
	case win.VK_RETURN, win.VK_SEPARATOR: return key(nk.KEY_ENTER, down)
	case win.VK_TAB: return key(nk.KEY_TAB, down)
	case win.VK_LEFT: return key(nk.KEY_TEXT_WORD_LEFT if ctrl else nk.KEY_LEFT, down)
	case win.VK_RIGHT: return key(nk.KEY_TEXT_WORD_RIGHT if ctrl else nk.KEY_RIGHT, down)
	case win.VK_UP: return key(nk.KEY_UP, down)
	case win.VK_DOWN: return key(nk.KEY_DOWN, down)
	case win.VK_BACK: return key(nk.KEY_BACKSPACE, down)
	case win.VK_HOME:
		key(nk.KEY_TEXT_START, down)
		return key(nk.KEY_SCROLL_START, down)
	case win.VK_END:
		key(nk.KEY_TEXT_END, down)
		return key(nk.KEY_SCROLL_END, down)
	case win.VK_NEXT: return key(nk.KEY_SCROLL_DOWN, down)
	case win.VK_PRIOR: return key(nk.KEY_SCROLL_UP, down)
	case win.VK_ESCAPE: return key(nk.KEY_TEXT_RESET_MODE, down)
	case win.VK_MENU: return key(nk.KEY_ALT, down)
	case win.VK_F1 ..= win.VK_F12: return key(nk.KEY_F1 + nk.Keys(wparam - win.VK_F1), down)
	case win.VK_INSERT:
		// Switch only on release, so that the key repeat does not toggle.
		// Nuklear has two keys for the mode, not one toggle.
		if !down {
			gdi.insert_toggle = !gdi.insert_toggle
			key(nk.KEY_TEXT_INSERT_MODE if gdi.insert_toggle else nk.KEY_TEXT_REPLACE_MODE, true)
		}
		return true
	case 'A': if ctrl do return key(nk.KEY_TEXT_SELECT_ALL, down)
	case 'B': if ctrl do return key(nk.KEY_TEXT_LINE_START, down)
	case 'E': if ctrl do return key(nk.KEY_TEXT_LINE_END, down)
	case 'C': if ctrl do return key(nk.KEY_COPY, down)
	case 'V': if ctrl do return key(nk.KEY_PASTE, down)
	case 'X': if ctrl do return key(nk.KEY_CUT, down)
	case 'Z': if ctrl do return key(nk.KEY_TEXT_UNDO, down)
	case 'R': if ctrl do return key(nk.KEY_TEXT_REDO, down)
	}
	return false
}

// Return true if the message is handled.
handle_event :: proc(hwnd: win.HWND, msg: win.UINT, wparam: win.WPARAM, lparam: win.LPARAM) -> bool {
	switch msg {
	case win.WM_SIZE:
		width, height := win.INT(win.LOWORD(lparam)), win.INT(win.HIWORD(lparam))
		if wparam != win.SIZE_MINIMIZED && width > 0 && height > 0 && (width != gdi.width || height != gdi.height) {
			buffer_resize(width, height)
		}
	case win.WM_ERASEBKGND:
		return true // the back buffer covers the window
	case win.WM_PAINT:
		paint: win.PAINTSTRUCT
		dc := win.BeginPaint(hwnd, &paint)
		blit(dc)
		win.EndPaint(hwnd, &paint)
		return true
	case win.WM_KEYDOWN, win.WM_KEYUP, win.WM_SYSKEYDOWN, win.WM_SYSKEYUP:
		return handle_key(wparam, (lparam >> 31) & 1 == 0)
	case win.WM_CHAR:
		r := win.WCHAR(wparam)
		switch {
		case 0xD800 <= r && r < 0xDC00: // the first half of a surrogate pair
			gdi.high_surrogate = r
			return true
		case 0xDC00 <= r && r < 0xE000: // the second half of a surrogate pair
			if gdi.high_surrogate != 0 {
				code := 0x10000 + ((nk.Rune(gdi.high_surrogate) - 0xD800) << 10) + (nk.Rune(r) - 0xDC00)
				nk.input_unicode(&gdi.ctx, code)
			}
			gdi.high_surrogate = 0
			return true
		case r >= 32 && r != 127:
			gdi.high_surrogate = 0
			nk.input_unicode(&gdi.ctx, nk.Rune(r))
			return true
		}
	case win.WM_LBUTTONDOWN:
		button(nk.BUTTON_LEFT, lparam, true)
		win.SetCapture(hwnd)
		return true
	case win.WM_LBUTTONUP:
		button(nk.BUTTON_DOUBLE, lparam, false)
		button(nk.BUTTON_LEFT, lparam, false)
		win.ReleaseCapture()
		return true
	case win.WM_LBUTTONDBLCLK:
		button(nk.BUTTON_DOUBLE, lparam, true)
		return true
	case win.WM_RBUTTONDOWN:
		button(nk.BUTTON_RIGHT, lparam, true)
		win.SetCapture(hwnd)
		return true
	case win.WM_RBUTTONUP:
		button(nk.BUTTON_RIGHT, lparam, false)
		win.ReleaseCapture()
		return true
	case win.WM_MBUTTONDOWN:
		button(nk.BUTTON_MIDDLE, lparam, true)
		win.SetCapture(hwnd)
		return true
	case win.WM_MBUTTONUP:
		button(nk.BUTTON_MIDDLE, lparam, false)
		win.ReleaseCapture()
		return true
	case win.WM_XBUTTONDOWN, win.WM_XBUTTONUP:
		down := msg == win.WM_XBUTTONDOWN
		switch win.GET_XBUTTON_WPARAM(wparam) {
		case win.XBUTTON1: button(nk.BUTTON_X1, lparam, down)
		case win.XBUTTON2: button(nk.BUTTON_X2, lparam, down)
		}
		if down do win.SetCapture(hwnd)
		else do win.ReleaseCapture()
		return true
	case win.WM_MOUSEWHEEL:
		delta := f32(win.GET_WHEEL_DELTA_WPARAM(wparam)) / win.WHEEL_DELTA
		nk.input_scroll(&gdi.ctx, {0, delta})
		return true
	case win.WM_MOUSEMOVE:
		nk.input_motion(&gdi.ctx, win.GET_X_LPARAM(lparam), win.GET_Y_LPARAM(lparam))
		return true
	}
	return false
}

window_proc :: proc "system" (hwnd: win.HWND, msg: win.UINT, wparam: win.WPARAM, lparam: win.LPARAM) -> win.LRESULT {
	context = runtime.default_context()
	if msg == win.WM_DESTROY {
		win.PostQuitMessage(0)
		return 0
	}
	if handle_event(hwnd, msg, wparam, lparam) {
		return 0
	}
	return win.DefWindowProcW(hwnd, msg, wparam, lparam)
}

main :: proc() {
	instance := win.HINSTANCE(win.GetModuleHandleW(nil))
	class_name: cstring16 = "NuklearWindowClass"
	class := win.WNDCLASSW {
		style         = win.CS_DBLCLKS,
		lpfnWndProc   = window_proc,
		hInstance     = instance,
		hIcon         = win.LoadIconA(nil, win.IDI_APPLICATION),
		hCursor       = win.LoadCursorA(nil, win.IDC_ARROW),
		lpszClassName = class_name,
	}
	if win.RegisterClassW(&class) == 0 {
		fmt.eprintln("RegisterClassW failed")
		os.exit(1)
	}

	style := win.WS_OVERLAPPEDWINDOW
	ex_style := win.WS_EX_APPWINDOW
	rect := win.RECT{0, 0, common.WINDOW_WIDTH, common.WINDOW_HEIGHT}
	win.AdjustWindowRectEx(&rect, style, false, ex_style)
	hwnd := win.CreateWindowExW(
		ex_style, class_name, win.L("Nuklear GDI Demo"), style | win.WS_VISIBLE,
		win.CW_USEDEFAULT, win.CW_USEDEFAULT, rect.right - rect.left, rect.bottom - rect.top,
		nil, nil, instance, nil,
	)
	if hwnd == nil {
		fmt.eprintln("CreateWindowExW failed")
		os.exit(1)
	}

	gdi.window_dc = win.GetDC(hwnd)
	gdi.memory_dc = win.CreateCompatibleDC(gdi.window_dc)
	buffer_resize(common.WINDOW_WIDTH, common.WINDOW_HEIGHT)
	font_create(&gdi.font, "Arial", 14)
	ctx := &gdi.ctx
	if !nk.init_default(ctx, &gdi.font.user) {
		fmt.eprintln("nk.init_default failed")
		os.exit(1)
	}
	ctx.clip.copy = clipboard_copy
	ctx.clip.paste = clipboard_paste

	// This loop waits for a message when nothing changed, as nuklear/demo/gdi/main.c does.
	// After an event it draws two frames, so that the layout settles.
	running := true
	needs_refresh := true
	for running {
		runtime.DEFAULT_TEMP_ALLOCATOR_TEMP_GUARD()
		msg: win.MSG
		nk.input_begin(ctx)
		if !needs_refresh {
			if win.GetMessageW(&msg, nil, 0, 0) <= 0 {
				running = false
			} else {
				win.TranslateMessage(&msg)
				win.DispatchMessageW(&msg)
			}
			needs_refresh = true
		} else {
			needs_refresh = false
		}
		for win.PeekMessageW(&msg, nil, 0, 0, win.PM_REMOVE) {
			if msg.message == win.WM_QUIT {
				running = false
			}
			win.TranslateMessage(&msg)
			win.DispatchMessageW(&msg)
			needs_refresh = true
		}
		nk.input_end(ctx)
		if !running do break

		common.frame(ctx)
		render(common.BACKGROUND)
	}

	nk.free(ctx)
	win.DeleteObject(win.HGDIOBJ(gdi.font.handle))
	win.DeleteDC(gdi.font.dc)
	win.DeleteObject(win.HGDIOBJ(gdi.bitmap))
	win.DeleteDC(gdi.memory_dc)
	win.ReleaseDC(hwnd, gdi.window_dc)
	win.UnregisterClassW(class_name, instance)
}
