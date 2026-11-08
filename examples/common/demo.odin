// The UI that all the demos draw each frame.
package common

import "core:c"
import "base:runtime"
import "core:fmt"
import nk "../.."

WINDOW_WIDTH  :: 800
WINDOW_HEIGHT :: 600
BACKGROUND    :: nk.Color{30, 30, 30, 255}

// The Demo window from nuklear/demo/gdi/main.c.
demo :: proc(ctx: ^nk.Context) {
	EASY :: 0
	HARD :: 1
	@(static) op: c.int = EASY
	@(static) property: c.int = 20

	if nk.begin(ctx, "Demo", nk.rect(50, 50, 200, 200),
		nk.WINDOW_BORDER | nk.WINDOW_MOVABLE | nk.WINDOW_SCALABLE |
		nk.WINDOW_CLOSABLE | nk.WINDOW_MINIMIZABLE | nk.WINDOW_TITLE) {
		nk.layout_row_static(ctx, 30, 80, 1)
		if nk.button_label(ctx, "button") {
			fmt.println("button pressed")
		}
		nk.layout_row_dynamic(ctx, 30, 2)
		if nk.option_label(ctx, "easy", op == EASY) {op = EASY}
		if nk.option_label(ctx, "hard", op == HARD) {op = HARD}
		nk.layout_row_dynamic(ctx, 22, 1)
		nk.property_int(ctx, "Compression:", 0, &property, 100, 10, 1)
	}
	nk.end(ctx)
}

// Draw one frame of the UI. The caller starts and ends the input and renders the result.
frame :: proc(ctx: ^nk.Context) {
	// The labels come from ctprintf. Free only this frame's temporary memory at the end of the frame.
	runtime.DEFAULT_TEMP_ALLOCATOR_TEMP_GUARD()
	demo(ctx)
	overview(ctx)
}
