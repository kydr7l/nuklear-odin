#+build linux
// Draw the Nuklear demo UI with Xlib in an X11 window.
// This is a port of nuklear/demo/x11/nuklear_xlib.h and main.c.
package main

import "base:runtime"
import "core:c/libc"
import "core:fmt"
import "core:math"
import "core:os"
import "core:time"
import nk "../.."
import "../common"
import xlib "vendor:x11/xlib"

// These Xlib procedures are not in vendor:x11/xlib.
foreign import libx11 "system:X11"

@(default_calling_convention = "c")
foreign libx11 {
	XSupportsLocale :: proc() -> b32 ---
	XCloseIM        :: proc(im: xlib.XIM) -> i32 ---
	XDestroyIC      :: proc(ic: xlib.XIC) ---
}

// vendor:x11/xlib declares DrawLines without the mode argument (an upstream bug).
// Odin does not allow a second declaration of the same symbol, so call it through this type.
Draw_Lines_Proc :: #type proc "c" (dpy: ^xlib.Display, d: xlib.Drawable, gc: xlib.GC, pts: [^]xlib.XPoint, n: i32, mode: xlib.CoordMode)
draw_lines := cast(Draw_Lines_Proc)xlib.DrawLines

// These atoms are not in vendor:x11/xlib. Their values are fixed by the X protocol.
XA_PRIMARY :: xlib.Atom(1)
XA_STRING  :: xlib.Atom(31)

FRAME_TIME        :: 20 * time.Millisecond // as DTIME in main.c
DOUBLE_CLICK_LO   :: 0.02 // seconds
DOUBLE_CLICK_HI   :: 0.20 // seconds
CURVE_SEGMENTS    :: 22
PASTE_TIMEOUT     :: 500 * time.Millisecond
PASTE_MAX_LONGS   :: 65536 // the largest paste is 256 KB

Font :: struct {
	user:   nk.User_Font,
	xfont:  ^xlib.XFontStruct,
	ascent: i32,
}

App :: struct {
	ctx:           nk.Context,
	font:          Font,
	dpy:           ^xlib.Display,
	screen:        i32,
	root:          xlib.Window,
	win:           xlib.Window,
	gc:            xlib.GC,
	pixmap:        xlib.Pixmap, // the back buffer
	width, height: u32,
	wm_delete:     xlib.Atom,
	xa_clipboard:  xlib.Atom,
	xa_targets:    xlib.Atom,
	xa_utf8:       xlib.Atom,
	im:            xlib.XIM,
	ic:            xlib.XIC,
	clipboard:     []u8, // the text that this program owns, or nil
	last_click:    time.Tick,
	last_frame:    time.Tick,
	insert_toggle: bool,
	running:       bool,
}

app: App

// Convert UTF-8 to Latin-1. A rune that does not fit in one byte becomes "?".
// The core font has one byte for each glyph, so width and draw both use this text.
// The caller must have a temp allocator guard.
to_latin1 :: proc(text: cstring, count: i32) -> []u8 {
	out := make([dynamic]u8, 0, int(count), context.temp_allocator)
	for r in string((cast([^]u8)text)[:count]) {
		append(&out, u8(r) if r < 0x100 else '?')
	}
	return out[:]
}

// The X11 demo expects a TrueColor visual, as nuklear_xlib.h does.
pixel :: proc "contextless" (c: nk.Color) -> uint {
	return uint(c.r) << 16 | uint(c.g) << 8 | uint(c.b)
}

// ---- The font ----

font_width :: proc "c" (handle: nk.Handle, height: f32, text: cstring, count: i32) -> f32 {
	context = runtime.default_context()
	runtime.DEFAULT_TEMP_ALLOCATOR_TEMP_GUARD()
	font := cast(^Font)handle.ptr
	if font == nil || text == nil {
		return 0
	}
	latin1 := to_latin1(text, count)
	return f32(xlib.TextWidth(font.xfont, raw_data(latin1), i32(len(latin1))))
}

// Load a core font. Try the name first, then "fixed". Return false if both fail.
font_create :: proc(font: ^Font, name: cstring) -> bool {
	font.xfont = xlib.LoadQueryFont(app.dpy, name)
	if font.xfont == nil {
		font.xfont = xlib.LoadQueryFont(app.dpy, "fixed")
	}
	if font.xfont == nil {
		return false
	}
	font.ascent = font.xfont.ascent
	font.user.userdata.ptr = font
	font.user.height = f32(font.xfont.ascent + font.xfont.descent)
	font.user.width = font_width
	// XDrawString uses the font of the GC.
	xlib.SetFont(app.dpy, app.gc, font.xfont.fid)
	return true
}

// ---- The clipboard ----

// Copy the text and take the PRIMARY and CLIPBOARD selections.
// Other programs ask for the text with a SelectionRequest event.
clipboard_copy :: proc "c" (handle: nk.Handle, text: cstring, count: i32) {
	context = runtime.default_context()
	delete(app.clipboard)
	app.clipboard = make([]u8, count)
	copy(app.clipboard, (cast([^]u8)text)[:count])
	xlib.SetSelectionOwner(app.dpy, XA_PRIMARY, app.win, xlib.CurrentTime)
	xlib.SetSelectionOwner(app.dpy, app.xa_clipboard, app.win, xlib.CurrentTime)
}

// Paste at once. nuklear_xlib.h waits for the SelectionNotify event in the event loop.
// That does not work here, because Nuklear gives a temporary text edit to this callback.
// So this procedure waits for the answer itself, for a short time.
clipboard_paste :: proc "c" (handle: nk.Handle, edit: ^nk.Text_Edit) {
	context = runtime.default_context()
	owner := xlib.GetSelectionOwner(app.dpy, app.xa_clipboard)
	if owner == app.win {
		if len(app.clipboard) > 0 {
			nk.textedit_text(edit, cstring(raw_data(app.clipboard)), i32(len(app.clipboard)))
		}
		return
	}
	if owner == xlib.None {
		return
	}
	xlib.ConvertSelection(app.dpy, app.xa_clipboard, app.xa_utf8, app.xa_clipboard, app.win, xlib.CurrentTime)
	xlib.Flush(app.dpy)
	ev: xlib.XEvent
	start := time.tick_now()
	for !xlib.CheckTypedWindowEvent(app.dpy, app.win, .SelectionNotify, &ev) {
		if time.tick_since(start) > PASTE_TIMEOUT {
			return
		}
		time.sleep(time.Millisecond)
	}
	if ev.xselection.property == xlib.None {
		return // the owner refused
	}
	type: xlib.Atom
	format: i32
	items, remain: uint
	data: rawptr
	xlib.GetWindowProperty(
		app.dpy, app.win, ev.xselection.property, 0, PASTE_MAX_LONGS, true, xlib.AnyPropertyType,
		&type, &format, &items, &remain, &data,
	)
	if data != nil {
		if format == 8 && items > 0 {
			nk.textedit_text(edit, cstring(data), i32(items))
		}
		xlib.Free(data)
	}
}

// Answer a request from another program for the text of this program.
selection_request :: proc(req: ^xlib.XSelectionRequestEvent) {
	reply: xlib.XEvent
	// An old client can send the property None. Then the target is the property (ICCCM).
	property := req.property if req.property != xlib.None else req.target
	// The property None means that this program refuses the request.
	reply.xselection = {
		type      = .SelectionNotify,
		requestor = req.requestor,
		selection = req.selection,
		target    = req.target,
		time      = req.time,
	}
	switch {
	case req.target == app.xa_targets:
		targets := [3]xlib.Atom{app.xa_targets, app.xa_utf8, XA_STRING}
		xlib.ChangeProperty(app.dpy, req.requestor, property, xlib.XA_ATOM, 32, xlib.PropModeReplace, &targets, 3)
		reply.xselection.property = property
	case len(app.clipboard) > 0 && (req.target == app.xa_utf8 || req.target == XA_STRING):
		// shortcut: the STRING target gets the UTF-8 bytes, so only ASCII is exact; upgrade if Latin-1 paste matters.
		xlib.ChangeProperty(
			app.dpy, req.requestor, property, req.target, 8, xlib.PropModeReplace,
			raw_data(app.clipboard), i32(len(app.clipboard)),
		)
		reply.xselection.property = property
	}
	xlib.SendEvent(app.dpy, req.requestor, false, {}, &reply)
	xlib.Flush(app.dpy)
}

// ---- The back buffer ----

// Make a back buffer of the given size.
buffer_resize :: proc(width, height: u32) {
	// The GC does not refer to the pixmap, so the old pixmap is free to go.
	if app.pixmap != 0 {
		xlib.FreePixmap(app.dpy, app.pixmap)
	}
	depth := u32(xlib.DefaultDepth(app.dpy, app.screen))
	app.pixmap = xlib.CreatePixmap(app.dpy, app.root, width, height, depth)
	app.width, app.height = width, height
}

// ---- The renderer ----

set_fill :: proc(color: nk.Color) {
	xlib.SetForeground(app.dpy, app.gc, pixel(color))
}

set_stroke :: proc(color: nk.Color, thickness: u32) {
	xlib.SetForeground(app.dpy, app.gc, pixel(color))
	xlib.SetLineAttributes(app.dpy, app.gc, thickness, .LineSolid, .CapButt, .JoinMiter)
}

line :: proc(x0, y0, x1, y1: i32) {
	xlib.DrawLine(app.dpy, app.pixmap, app.gc, x0, y0, x1, y1)
}

// Draw connected lines in one call, so that the joints are mitered. A closed shape gets its first point again.
// The caller must have a temp allocator guard.
polyline :: proc(pts: [^]xlib.XPoint, count: int, close: bool) {
	if count < 2 {
		return
	}
	if !close {
		draw_lines(app.dpy, xlib.Drawable(app.pixmap), app.gc, pts, i32(count), .CoordModeOrigin)
		return
	}
	closed := make([]xlib.XPoint, count + 1, context.temp_allocator)
	copy(closed, pts[:count])
	closed[count] = pts[0]
	draw_lines(app.dpy, xlib.Drawable(app.pixmap), app.gc, raw_data(closed), i32(count + 1), .CoordModeOrigin)
}

// Draw or fill an arc. The angles are in 1/64 degree.
arc :: proc(x, y, w, h, a_start, a_extent: i32, filled: bool) {
	if filled {
		xlib.FillArc(app.dpy, app.pixmap, app.gc, x, y, u32(w), u32(h), a_start, a_extent)
	} else {
		xlib.DrawArc(app.dpy, app.pixmap, app.gc, x, y, u32(w), u32(h), a_start, a_extent)
	}
}

// Nuklear angles are in radians and go clockwise on the screen. The second angle is the end.
// X angles are in 1/64 degree and go counter-clockwise. The second angle is the extent.
arc_angles :: proc(a: [2]f32) -> (start, extent: i32) {
	k :: 180 * 64 / math.PI
	return i32(-a[0] * k), i32(-(a[1] - a[0]) * k)
}

// Draw a rectangle with round corners. The corner arcs are quarter circles.
stroke_rect :: proc(x, y, w, h, r: i32) {
	if r == 0 {
		xlib.DrawRectangle(app.dpy, app.pixmap, app.gc, x, y, u32(w), u32(h))
		return
	}
	xc, yc := x + r, y + r
	wc, hc := w - 2 * r, h - 2 * r
	line(xc, y, xc + wc, y)
	line(x + w, yc, x + w, yc + hc)
	line(xc, y + h, xc + wc, y + h)
	line(x, yc, x, yc + hc)
	arc(xc + wc - r, y, 2 * r, 2 * r, 0 * 64, 90 * 64, false)
	arc(x, y, 2 * r, 2 * r, 90 * 64, 90 * 64, false)
	arc(x, yc + hc - r, 2 * r, 2 * r, 180 * 64, 90 * 64, false)
	arc(xc + wc - r, yc + hc - r, 2 * r, 2 * r, -90 * 64, 90 * 64, false)
}

fill_rect :: proc(x, y, w, h, r: i32) {
	if r == 0 {
		xlib.FillRectangle(app.dpy, app.pixmap, app.gc, x, y, u32(w), u32(h))
		return
	}
	xc, yc := x + r, y + r
	wc, hc := w - 2 * r, h - 2 * r
	p :: proc(x, y: i32) -> xlib.XPoint {
		return {i16(x), i16(y)}
	}
	// A cross shape fills all of the rectangle except the four corners.
	pts := [12]xlib.XPoint{
		p(x, yc), p(xc, yc), p(xc, y),
		p(xc + wc, y), p(xc + wc, yc), p(x + w, yc),
		p(x + w, yc + hc), p(xc + wc, yc + hc), p(xc + wc, y + h),
		p(xc, y + h), p(xc, yc + hc), p(x, yc + hc),
	}
	xlib.FillPolygon(app.dpy, app.pixmap, app.gc, raw_data(pts[:]), 12, .Convex, .CoordModeOrigin)
	arc(xc + wc - r, y, 2 * r, 2 * r, 0 * 64, 90 * 64, true)
	arc(x, y, 2 * r, 2 * r, 90 * 64, 90 * 64, true)
	arc(x, yc + hc - r, 2 * r, 2 * r, 180 * 64, 90 * 64, true)
	arc(xc + wc - r, yc + hc - r, 2 * r, 2 * r, -90 * 64, 90 * 64, true)
}

// X11 has no gradient. Fill small cells with the color that the bilinear mix gives at the cell center.
// shortcut: the cells are 4 px square, so the gradient has steps; upgrade with XImage if it matters.
fill_rect_multi_color :: proc(r: ^nk.Command_Rect_Multi_Color) {
	STEP :: 4
	rgb :: proc(c: nk.Color) -> [3]f32 {
		return {f32(c.r), f32(c.g), f32(c.b)}
	}
	// The corners go clockwise from the top left: left, top, right, bottom.
	top_left, top_right, bottom_right, bottom_left := rgb(r.left), rgb(r.top), rgb(r.right), rgb(r.bottom)
	w, h := i32(r.w), i32(r.h)
	for y := i32(0); y < h; y += STEP {
		v := (f32(y) + STEP / 2) / f32(h)
		for x := i32(0); x < w; x += STEP {
			u := (f32(x) + STEP / 2) / f32(w)
			upper := top_left + (top_right - top_left) * u
			lower := bottom_left + (bottom_right - bottom_left) * u
			c := upper + (lower - upper) * v
			xlib.SetForeground(app.dpy, app.gc, uint(c[0]) << 16 | uint(c[1]) << 8 | uint(c[2]))
			xlib.FillRectangle(
				app.dpy, app.pixmap, app.gc, i32(r.x) + x, i32(r.y) + y,
				u32(min(i32(STEP), w - x)), u32(min(i32(STEP), h - y)),
			)
		}
	}
}

// Draw all the commands of the frame in the back buffer, then copy it to the window.
render :: proc(clear: nk.Color) {
	dpy, pixmap, gc := app.dpy, app.pixmap, app.gc
	// The clip of the last frame must not hide the clear or the copy.
	xlib.SetClipMask(dpy, gc, 0)
	set_fill(clear)
	xlib.FillRectangle(dpy, pixmap, gc, 0, 0, app.width, app.height)

	it := nk.Command_Iterator{ctx = &app.ctx}
	for cmd in nk.foreach(&it) {
		switch cmd.type {
		case nk.COMMAND_SCISSOR:
			s := cast(^nk.Command_Scissor)cmd
			// One more pixel on each side, as nuklear_xlib.h does.
			clip := xlib.XRectangle{s.x - 1, s.y - 1, s.w + 2, s.h + 2}
			xlib.SetClipRectangles(dpy, gc, 0, 0, &clip, 1, 0)
		case nk.COMMAND_LINE:
			l := cast(^nk.Command_Line)cmd
			set_stroke(l.color, u32(l.line_thickness))
			line(i32(l.begin.x), i32(l.begin.y), i32(l.end.x), i32(l.end.y))
		case nk.COMMAND_CURVE:
			q := cast(^nk.Command_Curve)cmd
			p := [4][2]f32{
				{f32(q.begin.x), f32(q.begin.y)},
				{f32(q.ctrl[0].x), f32(q.ctrl[0].y)},
				{f32(q.ctrl[1].x), f32(q.ctrl[1].y)},
				{f32(q.end.x), f32(q.end.y)},
			}
			pts: [CURVE_SEGMENTS + 1]xlib.XPoint
			pts[0] = {q.begin.x, q.begin.y}
			for i in 1 ..= CURVE_SEGMENTS {
				t := f32(i) / CURVE_SEGMENTS
				u := 1 - t
				pos := p[0] * (u * u * u) + p[1] * (3 * u * u * t) + p[2] * (3 * u * t * t) + p[3] * (t * t * t)
				pts[i] = {i16(pos.x), i16(pos.y)}
			}
			set_stroke(q.color, u32(q.line_thickness))
			polyline(raw_data(pts[:]), len(pts), false)
		case nk.COMMAND_RECT:
			r := cast(^nk.Command_Rect)cmd
			set_stroke(r.color, u32(r.line_thickness))
			// The border stays inside the rectangle, as in nuklear_xlib.h.
			stroke_rect(
				i32(r.x), i32(r.y), max(i32(r.w) - i32(r.line_thickness), 0),
				max(i32(r.h) - i32(r.line_thickness), 0), i32(r.rounding),
			)
		case nk.COMMAND_RECT_FILLED:
			r := cast(^nk.Command_Rect_Filled)cmd
			set_fill(r.color)
			fill_rect(i32(r.x), i32(r.y), i32(r.w), i32(r.h), i32(r.rounding))
		case nk.COMMAND_RECT_MULTI_COLOR:
			fill_rect_multi_color(cast(^nk.Command_Rect_Multi_Color)cmd)
		case nk.COMMAND_CIRCLE:
			c := cast(^nk.Command_Circle)cmd
			set_stroke(c.color, u32(c.line_thickness))
			arc(i32(c.x), i32(c.y), i32(c.w), i32(c.h), 0, 360 * 64, false)
		case nk.COMMAND_CIRCLE_FILLED:
			c := cast(^nk.Command_Circle_Filled)cmd
			set_fill(c.color)
			arc(i32(c.x), i32(c.y), i32(c.w), i32(c.h), 0, 360 * 64, true)
		case nk.COMMAND_ARC:
			q := cast(^nk.Command_Arc)cmd
			set_stroke(q.color, u32(q.line_thickness))
			start, extent := arc_angles(q.a)
			r := i32(q.r)
			arc(i32(q.cx) - r, i32(q.cy) - r, 2 * r, 2 * r, start, extent, false)
		case nk.COMMAND_ARC_FILLED:
			q := cast(^nk.Command_Arc_Filled)cmd
			set_fill(q.color)
			start, extent := arc_angles(q.a)
			r := i32(q.r)
			arc(i32(q.cx) - r, i32(q.cy) - r, 2 * r, 2 * r, start, extent, true)
		case nk.COMMAND_TRIANGLE:
			t := cast(^nk.Command_Triangle)cmd
			pts := [3]xlib.XPoint{{t.a.x, t.a.y}, {t.b.x, t.b.y}, {t.c.x, t.c.y}}
			set_stroke(t.color, u32(t.line_thickness))
			polyline(raw_data(pts[:]), 3, true)
		case nk.COMMAND_TRIANGLE_FILLED:
			t := cast(^nk.Command_Triangle_Filled)cmd
			pts := [3]xlib.XPoint{{t.a.x, t.a.y}, {t.b.x, t.b.y}, {t.c.x, t.c.y}}
			set_fill(t.color)
			xlib.FillPolygon(dpy, pixmap, gc, raw_data(pts[:]), 3, .Convex, .CoordModeOrigin)
		case nk.COMMAND_POLYGON:
			p := cast(^nk.Command_Polygon)cmd
			set_stroke(p.color, u32(p.line_thickness))
			// Vec2i and XPoint are two i16 values, so the points need no copy.
			polyline(cast([^]xlib.XPoint)&p.points, int(p.point_count), true)
		case nk.COMMAND_POLYGON_FILLED:
			p := cast(^nk.Command_Polygon_Filled)cmd
			set_fill(p.color)
			xlib.FillPolygon(dpy, pixmap, gc, cast([^]xlib.XPoint)&p.points, i32(p.point_count), .Convex, .CoordModeOrigin)
		case nk.COMMAND_POLYLINE:
			p := cast(^nk.Command_Polyline)cmd
			set_stroke(p.color, u32(p.line_thickness))
			polyline(cast([^]xlib.XPoint)&p.points, int(p.point_count), false)
		case nk.COMMAND_TEXT:
			t := cast(^nk.Command_Text)cmd
			font := cast(^Font)t.font.userdata.ptr
			if font == nil || t.length == 0 {
				break
			}
			text := to_latin1(cstring(cast([^]u8)&t.string), t.length)
			set_fill(t.foreground)
			// Y is the top of the text. XDrawString wants the baseline.
			xlib.DrawString(dpy, pixmap, gc, i32(t.x), i32(t.y) + font.ascent, raw_data(text), i32(len(text)))
		case nk.COMMAND_NOP, nk.COMMAND_IMAGE, nk.COMMAND_CUSTOM:
		// The overview does not make these commands.
		}
	}
	nk.clear(&app.ctx)
	xlib.SetClipMask(dpy, gc, 0)
	xlib.CopyArea(dpy, xlib.Drawable(pixmap), xlib.Drawable(app.win), gc, 0, 0, app.width, app.height, 0, 0)
}

// ---- The input ----

key :: proc(k: nk.Keys, down: bool) -> bool {
	nk.input_key(&app.ctx, k, nk.Bool(down))
	return true
}

// Return true if the next event is the key press that an auto repeat sends after this release.
is_auto_repeat :: proc(ev: ^xlib.XKeyEvent) -> bool {
	if xlib.EventsQueued(app.dpy, .QueuedAfterReading) == 0 {
		return false
	}
	next: xlib.XEvent
	xlib.PeekEvent(app.dpy, &next)
	return next.type == .KeyPress && next.xkey.time == ev.time && next.xkey.keycode == ev.keycode
}

// Send a key to Nuklear. Return true if the key is handled.
handle_key :: proc(ev: ^xlib.XKeyEvent, sym: xlib.KeySym, down: bool) -> bool {
	ctrl := .ControlMask in ev.state
	#partial switch sym {
	case .XK_Shift_L, .XK_Shift_R: return key(nk.KEY_SHIFT, down)
	case .XK_Control_L, .XK_Control_R: return key(nk.KEY_CTRL, down)
	case .XK_Delete: return key(nk.KEY_DEL, down)
	case .XK_Return, .XK_KP_Enter: return key(nk.KEY_ENTER, down)
	case .XK_Tab: return key(nk.KEY_TAB, down)
	case .XK_Left: return key(nk.KEY_TEXT_WORD_LEFT if ctrl else nk.KEY_LEFT, down)
	case .XK_Right: return key(nk.KEY_TEXT_WORD_RIGHT if ctrl else nk.KEY_RIGHT, down)
	case .XK_Up: return key(nk.KEY_UP, down)
	case .XK_Down: return key(nk.KEY_DOWN, down)
	case .XK_BackSpace: return key(nk.KEY_BACKSPACE, down)
	case .XK_Escape: return key(nk.KEY_TEXT_RESET_MODE, down)
	case .XK_Alt_L, .XK_Alt_R: return key(nk.KEY_ALT, down)
	case .XK_Page_Up: return key(nk.KEY_SCROLL_UP, down)
	case .XK_Page_Down: return key(nk.KEY_SCROLL_DOWN, down)
	case .XK_F1 ..= .XK_F12: return key(nk.KEY_F1 + nk.Keys(uint(sym) - uint(xlib.KeySym.XK_F1)), down)
	case .XK_Home:
		key(nk.KEY_TEXT_START, down)
		return key(nk.KEY_SCROLL_START, down)
	case .XK_End:
		key(nk.KEY_TEXT_END, down)
		return key(nk.KEY_SCROLL_END, down)
	case .XK_Insert:
		// Switch only on a real release, so that the key repeat does not toggle.
		// Nuklear has two keys for the mode, not one toggle.
		if !down && !is_auto_repeat(ev) {
			app.insert_toggle = !app.insert_toggle
			key(nk.KEY_TEXT_INSERT_MODE if app.insert_toggle else nk.KEY_TEXT_REPLACE_MODE, true)
		}
		return true
	case .XK_a: if ctrl do return key(nk.KEY_TEXT_SELECT_ALL, down)
	case .XK_b: if ctrl do return key(nk.KEY_TEXT_LINE_START, down)
	case .XK_e: if ctrl do return key(nk.KEY_TEXT_LINE_END, down)
	case .XK_c: if ctrl do return key(nk.KEY_COPY, down)
	case .XK_v: if ctrl do return key(nk.KEY_PASTE, down)
	case .XK_x: if ctrl do return key(nk.KEY_CUT, down)
	case .XK_z: if ctrl do return key(nk.KEY_TEXT_UNDO, down)
	case .XK_r: if ctrl do return key(nk.KEY_TEXT_REDO, down)
	case .XK_q: if ctrl && down {
		app.running = false // as main.c does
		return true
	}
	}
	return false
}

// Send the text of a key press to Nuklear. The text can hold more than one rune.
text_input :: proc(ev: ^xlib.XKeyEvent) {
	send :: proc(r: rune) {
		// Skip the control characters and the characters that the decoder could not read.
		if r >= 32 && r != 127 && r != 0xFFFD {
			nk.input_unicode(&app.ctx, nk.Rune(r))
		}
	}
	buf: [64]u8
	sym: xlib.KeySym
	if app.ic != nil {
		status: xlib.LookupStringStatus
		n := xlib.Xutf8LookupString(app.ic, ev, cstring(raw_data(buf[:])), len(buf), &sym, &status)
		if status == .LookupChars || status == .LookupBoth {
			for r in string(buf[:n]) {
				send(r)
			}
		}
	} else {
		// There is no input context. XLookupString gives Latin-1 bytes.
		n := xlib.LookupString(ev, raw_data(buf[:]), len(buf), &sym, nil)
		for b in buf[:max(n, 0)] {
			send(rune(b))
		}
	}
}

handle_button :: proc(ev: ^xlib.XButtonEvent, down: bool) {
	ctx := &app.ctx
	x, y := ev.x, ev.y
	switch int(ev.button) {
	case 1:
		if down {
			// A second press that comes soon after the first is a double click.
			dt := time.duration_seconds(time.tick_since(app.last_click))
			if dt > DOUBLE_CLICK_LO && dt < DOUBLE_CLICK_HI {
				nk.input_button(ctx, nk.BUTTON_DOUBLE, x, y, true)
			}
			app.last_click = time.tick_now()
		} else {
			nk.input_button(ctx, nk.BUTTON_DOUBLE, x, y, false)
		}
		nk.input_button(ctx, nk.BUTTON_LEFT, x, y, nk.Bool(down))
	case 2: nk.input_button(ctx, nk.BUTTON_MIDDLE, x, y, nk.Bool(down))
	case 3: nk.input_button(ctx, nk.BUTTON_RIGHT, x, y, nk.Bool(down))
	// The wheel sends a press and a release. Count only the press.
	case 4: if down do nk.input_scroll(ctx, {0, 1})
	case 5: if down do nk.input_scroll(ctx, {0, -1})
	case 8: nk.input_button(ctx, nk.BUTTON_X1, x, y, nk.Bool(down))
	case 9: nk.input_button(ctx, nk.BUTTON_X2, x, y, nk.Bool(down))
	}
}

handle_event :: proc(ev: ^xlib.XEvent) {
	#partial switch ev.type {
	case .KeyPress, .KeyRelease:
		down := ev.type == .KeyPress
		sym := xlib.LookupKeysym(&ev.xkey, 0)
		if !handle_key(&ev.xkey, sym, down) && down && .ControlMask not_in ev.xkey.state {
			text_input(&ev.xkey)
		}
	case .ButtonPress:
		handle_button(&ev.xbutton, true)
	case .ButtonRelease:
		handle_button(&ev.xbutton, false)
	case .MotionNotify:
		nk.input_motion(&app.ctx, ev.xmotion.x, ev.xmotion.y)
	case .ConfigureNotify:
		width, height := u32(max(ev.xconfigure.width, 0)), u32(max(ev.xconfigure.height, 0))
		if width > 0 && height > 0 && (width != app.width || height != app.height) {
			buffer_resize(width, height)
		}
	case .MappingNotify:
		xlib.RefreshKeyboardMapping(&ev.xmapping)
	case .ClientMessage:
		if xlib.Atom(ev.xclient.data.l[0]) == app.wm_delete {
			app.running = false
		}
	case .SelectionClear:
		// Keep the text while this program still owns CLIPBOARD. Another program that takes
		// PRIMARY (a text selection) must not remove the text that Ctrl+V pastes.
		if ev.xselectionclear.selection == app.xa_clipboard {
			delete(app.clipboard)
			app.clipboard = nil
		}
	case .SelectionRequest:
		selection_request(&ev.xselectionrequest)
	}
}

// ---- The window ----

main :: proc() {
	app.dpy = xlib.OpenDisplay(nil)
	if app.dpy == nil {
		fmt.eprintln("Could not open a display. Is $DISPLAY set?")
		os.exit(1)
	}
	app.screen = xlib.DefaultScreen(app.dpy)
	app.root = xlib.DefaultRootWindow(app.dpy)

	attr := xlib.XSetWindowAttributes{
		event_mask = {.KeyPress, .KeyRelease, .ButtonPress, .ButtonRelease, .PointerMotion, .StructureNotify},
	}
	app.win = xlib.CreateWindow(
		app.dpy, app.root, 0, 0, common.WINDOW_WIDTH, common.WINDOW_HEIGHT, 0,
		xlib.DefaultDepth(app.dpy, app.screen), .InputOutput, xlib.DefaultVisual(app.dpy, app.screen),
		{.CWEventMask}, &attr,
	)
	xlib.StoreName(app.dpy, app.win, "Nuklear X11 Demo")
	xlib.MapWindow(app.dpy, app.win)
	app.wm_delete = xlib.InternAtom(app.dpy, "WM_DELETE_WINDOW", false)
	xlib.SetWMProtocols(app.dpy, app.win, cast([^]xlib.Atom)&app.wm_delete, 1)
	app.xa_clipboard = xlib.InternAtom(app.dpy, "CLIPBOARD", false)
	app.xa_targets = xlib.InternAtom(app.dpy, "TARGETS", false)
	app.xa_utf8 = xlib.InternAtom(app.dpy, "UTF8_STRING", false)

	// The input context gives UTF-8 text. "@im=none" uses no input method server, as nuklear_xlib.h does.
	// If this fails, text_input uses XLookupString.
	if libc.setlocale(.ALL, "") != nil && XSupportsLocale() {
		xlib.SetLocaleModifiers("@im=none")
		app.im = xlib.OpenIM(app.dpy, nil, nil, nil)
		if app.im != nil {
			app.ic = xlib.CreateIC(
				app.im,
				xlib.XNInputStyle, uint(xlib.XIMPreeditNothing | xlib.XIMStatusNothing),
				xlib.XNClientWindow, app.win,
				xlib.XNFocusWindow, app.win,
				rawptr(nil),
			)
			if app.ic != nil {
				xlib.SetICFocus(app.ic)
			}
		}
	}

	app.gc = xlib.CreateGC(app.dpy, app.root, {}, nil)
	buffer_resize(common.WINDOW_WIDTH, common.WINDOW_HEIGHT)
	// "Arial" is not a core font name on most systems, so the font is usually "fixed".
	if !font_create(&app.font, "Arial") {
		fmt.eprintln("Could not load a font.")
		os.exit(1)
	}
	ctx := &app.ctx
	if !nk.init_default(ctx, &app.font.user) {
		fmt.eprintln("nk.init_default failed")
		os.exit(1)
	}
	ctx.clip.copy = clipboard_copy
	ctx.clip.paste = clipboard_paste

	app.running = true
	app.last_frame = time.tick_now()
	for app.running {
		runtime.DEFAULT_TEMP_ALLOCATOR_TEMP_GUARD()
		started := time.tick_now()
		nk.input_begin(ctx)
		for xlib.Pending(app.dpy) > 0 {
			ev: xlib.XEvent
			xlib.NextEvent(app.dpy, &ev)
			// The input method takes some key events, for example the keys of a compose sequence.
			if xlib.FilterEvent(&ev, app.win) {
				continue
			}
			handle_event(&ev)
		}
		nk.input_end(ctx)
		if !app.running do break

		// Nuklear needs the time between frames for animations.
		ctx.delta_time_seconds = f32(time.duration_seconds(time.tick_since(app.last_frame)))
		app.last_frame = time.tick_now()

		common.frame(ctx)
		render(common.BACKGROUND)
		xlib.Flush(app.dpy)

		if elapsed := time.tick_since(started); elapsed < FRAME_TIME {
			time.sleep(FRAME_TIME - elapsed)
		}
	}

	nk.free(ctx)
	delete(app.clipboard)
	if app.ic != nil do XDestroyIC(app.ic)
	if app.im != nil do XCloseIM(app.im)
	xlib.FreePixmap(app.dpy, app.pixmap)
	xlib.FreeGC(app.dpy, app.gc)
	xlib.FreeFont(app.dpy, app.font.xfont)
	xlib.DestroyWindow(app.dpy, app.win)
	xlib.CloseDisplay(app.dpy)
}
