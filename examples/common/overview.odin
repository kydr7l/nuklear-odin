package common

import "base:runtime"
import "core:c"
import "core:fmt"
import "core:math"
import "core:time"
import "core:time/datetime"
import "core:time/timezone"
import nk "../.."

// The white color. Nuklear defines it as nk_white in nuklear.h.
WHITE :: nk.Color{255, 255, 255, 255}

// Port of nuklear/demo/common/overview.c. The INCLUDE_STYLE theme code is not ported.
// The result is false when the user closes the window.
overview :: proc(ctx: ^nk.Context) -> bool {
	// Window flags.
	@(static) show_menu: nk.Bool = true
	@(static) window_flags: nk.Flags = nk.WINDOW_TITLE | nk.WINDOW_BORDER | nk.WINDOW_SCALABLE | nk.WINDOW_MOVABLE | nk.WINDOW_MINIMIZABLE | nk.WINDOW_SCROLL_AUTO_HIDE
	actual_window_flags: nk.Flags = 0

	// Widget flags.
	@(static) disable_widgets: nk.Bool = false

	// Popups.
	@(static) header_align: nk.Style_Header_Align = nk.HEADER_RIGHT
	@(static) show_app_about: nk.Bool = false

	ctx.style.window.header.align = header_align

	actual_window_flags = window_flags
	if actual_window_flags & nk.WINDOW_TITLE == 0 {
		actual_window_flags &= ~nk.Flags(nk.WINDOW_MINIMIZABLE | nk.WINDOW_CLOSABLE)
	}
	if nk.begin(ctx, "Overview", nk.rect(10, 10, 400, 600), actual_window_flags) {
		if show_menu {
			// Menu bar.
			@(static) mprog: nk.Size = 60
			@(static) mslider: c.int = 10
			@(static) mcheck: nk.Bool = true
			nk.menubar_begin(ctx)

			// Menu 1.
			nk.layout_row_begin(ctx, nk.STATIC, 25, 5)
			nk.layout_row_push(ctx, 45)
			if nk.menu_begin_label(ctx, "MENU", nk.TEXT_LEFT, nk.vec2(120, 200)) {
				@(static) prog: nk.Size = 40
				@(static) slider: c.int = 10
				@(static) check: nk.Bool = true
				nk.layout_row_dynamic(ctx, 25, 1)
				if nk.menu_item_label(ctx, "Hide", nk.TEXT_LEFT) {
					show_menu = false
				}
				if nk.menu_item_label(ctx, "About", nk.TEXT_LEFT) {
					show_app_about = true
				}
				nk.progress(ctx, &prog, 100, nk.MODIFIABLE != 0)
				nk.slider_int(ctx, 0, &slider, 16, 1)
				nk.checkbox_label(ctx, "check", &check)
				nk.menu_end(ctx)
			}
			// Menu 2.
			nk.layout_row_push(ctx, 60)
			if nk.menu_begin_label(ctx, "ADVANCED", nk.TEXT_LEFT, nk.vec2(200, 600)) {
				MENU_NONE  :: 0
				MENU_FILE  :: 1
				MENU_EDIT  :: 2
				MENU_VIEW  :: 3
				MENU_CHART :: 4
				@(static) menu_state: c.int = MENU_NONE
				state: nk.Collapse_States

				state = nk.MAXIMIZED if menu_state == MENU_FILE else nk.MINIMIZED
				if nk.tree_state_push(ctx, nk.TREE_TAB, "FILE", &state) {
					menu_state = MENU_FILE
					nk.menu_item_label(ctx, "New", nk.TEXT_LEFT)
					nk.menu_item_label(ctx, "Open", nk.TEXT_LEFT)
					nk.menu_item_label(ctx, "Save", nk.TEXT_LEFT)
					nk.menu_item_label(ctx, "Close", nk.TEXT_LEFT)
					nk.menu_item_label(ctx, "Exit", nk.TEXT_LEFT)
					nk.tree_pop(ctx)
				} else if menu_state == MENU_FILE {
					menu_state = MENU_NONE
				}

				state = nk.MAXIMIZED if menu_state == MENU_EDIT else nk.MINIMIZED
				if nk.tree_state_push(ctx, nk.TREE_TAB, "EDIT", &state) {
					menu_state = MENU_EDIT
					nk.menu_item_label(ctx, "Copy", nk.TEXT_LEFT)
					nk.menu_item_label(ctx, "Delete", nk.TEXT_LEFT)
					nk.menu_item_label(ctx, "Cut", nk.TEXT_LEFT)
					nk.menu_item_label(ctx, "Paste", nk.TEXT_LEFT)
					nk.tree_pop(ctx)
				} else if menu_state == MENU_EDIT {
					menu_state = MENU_NONE
				}

				state = nk.MAXIMIZED if menu_state == MENU_VIEW else nk.MINIMIZED
				if nk.tree_state_push(ctx, nk.TREE_TAB, "VIEW", &state) {
					menu_state = MENU_VIEW
					nk.menu_item_label(ctx, "About", nk.TEXT_LEFT)
					nk.menu_item_label(ctx, "Options", nk.TEXT_LEFT)
					nk.menu_item_label(ctx, "Customize", nk.TEXT_LEFT)
					nk.tree_pop(ctx)
				} else if menu_state == MENU_VIEW {
					menu_state = MENU_NONE
				}

				state = nk.MAXIMIZED if menu_state == MENU_CHART else nk.MINIMIZED
				if nk.tree_state_push(ctx, nk.TREE_TAB, "CHART", &state) {
					values := [?]f32{26, 13, 30, 15, 25, 10, 20, 40, 12, 8, 22, 28}
					menu_state = MENU_CHART
					nk.layout_row_dynamic(ctx, 150, 1)
					nk.chart_begin(ctx, nk.CHART_COLUMN, len(values), 0, 50)
					for v in values {
						nk.chart_push(ctx, v)
					}
					nk.chart_end(ctx)
					nk.tree_pop(ctx)
				} else if menu_state == MENU_CHART {
					menu_state = MENU_NONE
				}
				nk.menu_end(ctx)
			}
			// Menu widgets.
			nk.layout_row_push(ctx, 70)
			nk.progress(ctx, &mprog, 100, nk.MODIFIABLE != 0)
			nk.slider_int(ctx, 0, &mslider, 16, 1)
			nk.checkbox_label(ctx, "check", &mcheck)
			nk.menubar_end(ctx)
		}

		if show_app_about {
			// About popup.
			@(static) s := nk.Rect{20, 100, 300, 190}
			if nk.popup_begin(ctx, nk.POPUP_STATIC, "About", nk.WINDOW_CLOSABLE, s) {
				nk.layout_row_dynamic(ctx, 20, 1)
				nk.label(ctx, "Nuklear", nk.TEXT_LEFT)
				nk.label(ctx, "By Micha Mettke", nk.TEXT_LEFT)
				nk.label(ctx, "nuklear is licensed under the public domain License.", nk.TEXT_LEFT)
				nk.popup_end(ctx)
			} else {
				show_app_about = false
			}
		}

		// Window flags.
		if nk.tree_push(ctx, nk.TREE_TAB, "Window", nk.MINIMIZED) {
			nk.layout_row_dynamic(ctx, 30, 2)
			nk.checkbox_label(ctx, "Menu", &show_menu)
			nk.checkbox_flags_label(ctx, "Titlebar", &window_flags, nk.WINDOW_TITLE)
			nk.checkbox_flags_label(ctx, "Border", &window_flags, nk.WINDOW_BORDER)
			nk.checkbox_flags_label(ctx, "Resizable", &window_flags, nk.WINDOW_SCALABLE)
			nk.checkbox_flags_label(ctx, "Movable", &window_flags, nk.WINDOW_MOVABLE)
			nk.checkbox_flags_label(ctx, "No Scrollbar", &window_flags, nk.WINDOW_NO_SCROLLBAR)
			nk.checkbox_flags_label(ctx, "Minimizable", &window_flags, nk.WINDOW_MINIMIZABLE)
			nk.checkbox_flags_label(ctx, "Scale Left", &window_flags, nk.WINDOW_SCALE_LEFT)
			nk.checkbox_label(ctx, "Disable widgets", &disable_widgets)
			nk.tree_pop(ctx)
		}

		if disable_widgets {
			nk.widget_disable_begin(ctx)
		}

		if nk.tree_push(ctx, nk.TREE_TAB, "Widgets", nk.MINIMIZED) {
			A :: 0
			B :: 1
			C :: 2
			@(static) checkbox_left_text_left: nk.Bool
			@(static) checkbox_centered_text_right: nk.Bool
			@(static) checkbox_right_text_right: nk.Bool
			@(static) checkbox_right_text_left: nk.Bool
			@(static) option_left: c.int
			@(static) option_right: c.int
			if nk.tree_push(ctx, nk.TREE_NODE, "Text", nk.MINIMIZED) {
				// Text widgets.
				nk.layout_row_dynamic(ctx, 20, 1)
				nk.label(ctx, "Label aligned left", nk.TEXT_LEFT)
				nk.label(ctx, "Label aligned centered", nk.TEXT_CENTERED)
				nk.label(ctx, "Label aligned right", nk.TEXT_RIGHT)
				nk.label_colored(ctx, "Blue text", nk.TEXT_LEFT, nk.rgb(0, 0, 255))
				nk.label_colored(ctx, "Yellow text", nk.TEXT_LEFT, nk.rgb(255, 255, 0))
				nk.text(ctx, "Text without /0", 15, nk.TEXT_RIGHT)

				nk.layout_row_static(ctx, 100, 200, 1)
				nk.label_wrap(ctx, "This is a very long line to hopefully get this text to be wrapped into multiple lines to show line wrapping")
				nk.layout_row_dynamic(ctx, 100, 1)
				nk.label_wrap(ctx, "This is another long text to show dynamic window changes on multiline text")
				nk.tree_pop(ctx)
			}

			if nk.tree_push(ctx, nk.TREE_NODE, "Link", nk.MINIMIZED) {
				nk.layout_row_dynamic(ctx, 20, 1)
				if nk.link_label(ctx, "Default underlined link", nk.TEXT_LEFT) {
					fmt.println("Link pressed!")
				}
				if nk.link_label_hover_underline(ctx, "Underline on hover", nk.TEXT_LEFT) {
					fmt.println("Hover-underline link pressed!")
				}
				if nk.link_label_no_underline(ctx, "No underline", nk.TEXT_LEFT) {
					fmt.println("No-underline link pressed!")
				}
				if nk.link_label_colored(ctx, "Colored link", nk.TEXT_LEFT, nk.rgb(100, 160, 255)) {
					fmt.println("Colored link pressed!")
				}

				nk.link_label(ctx, "Left aligned link", nk.TEXT_LEFT)
				nk.link_label(ctx, "Centered link", nk.TEXT_CENTERED)
				nk.link_label(ctx, "Right aligned link", nk.TEXT_RIGHT)

				nk.widget_disable_begin(ctx)
				nk.link_label(ctx, "Disabled link", nk.TEXT_LEFT)
				nk.widget_disable_end(ctx)
				nk.tree_pop(ctx)
			}

			if nk.tree_push(ctx, nk.TREE_NODE, "Button", nk.MINIMIZED) {
				// Button widgets.
				nk.layout_row_static(ctx, 30, 100, 3)
				if nk.button_label(ctx, "Button") {
					fmt.println("Button pressed!")
				}
				nk.button_set_behavior(ctx, nk.BUTTON_REPEATER)
				if nk.button_label(ctx, "Repeater") {
					fmt.println("Repeater is being pressed!")
				}
				nk.button_set_behavior(ctx, nk.BUTTON_DEFAULT)
				nk.button_color(ctx, nk.rgb(0, 0, 255))

				nk.layout_row_static(ctx, 25, 25, 8)
				nk.button_symbol(ctx, nk.SYMBOL_CIRCLE_SOLID)
				nk.button_symbol(ctx, nk.SYMBOL_RECT_SOLID)
				nk.button_symbol(ctx, nk.SYMBOL_CIRCLE_OUTLINE)
				nk.button_symbol(ctx, nk.SYMBOL_RECT_OUTLINE)
				nk.button_symbol(ctx, nk.SYMBOL_TRIANGLE_UP)
				nk.button_symbol(ctx, nk.SYMBOL_TRIANGLE_RIGHT)
				nk.button_symbol(ctx, nk.SYMBOL_TRIANGLE_DOWN)
				nk.button_symbol(ctx, nk.SYMBOL_TRIANGLE_LEFT)
				nk.button_symbol(ctx, nk.SYMBOL_TRIANGLE_UP_OUTLINE)
				nk.button_symbol(ctx, nk.SYMBOL_TRIANGLE_RIGHT_OUTLINE)
				nk.button_symbol(ctx, nk.SYMBOL_TRIANGLE_DOWN_OUTLINE)
				nk.button_symbol(ctx, nk.SYMBOL_TRIANGLE_LEFT_OUTLINE)
				nk.button_symbol(ctx, nk.SYMBOL_CHEVRON_UP)
				nk.button_symbol(ctx, nk.SYMBOL_CHEVRON_RIGHT)
				nk.button_symbol(ctx, nk.SYMBOL_CHEVRON_DOWN)
				nk.button_symbol(ctx, nk.SYMBOL_CHEVRON_LEFT)
				nk.button_symbol(ctx, nk.SYMBOL_HAMBURGER)
				nk.button_symbol(ctx, nk.SYMBOL_X)
				nk.button_symbol(ctx, nk.SYMBOL_UNDERSCORE)
				nk.button_symbol(ctx, nk.SYMBOL_PLUS)
				nk.button_symbol(ctx, nk.SYMBOL_MINUS)

				nk.layout_row_static(ctx, 30, 100, 2)
				nk.button_symbol_label(ctx, nk.SYMBOL_TRIANGLE_LEFT, "prev", nk.TEXT_RIGHT)
				nk.button_symbol_label(ctx, nk.SYMBOL_TRIANGLE_RIGHT, "next", nk.TEXT_LEFT)

				nk.tree_pop(ctx)
			}

			if nk.tree_push(ctx, nk.TREE_NODE, "Basic", nk.MINIMIZED) {
				// Basic widgets.
				@(static) int_slider: c.int = 5
				@(static) float_slider: f32 = 2.5
				@(static) int_knob: c.int = 5
				@(static) float_knob: f32 = 2.5
				@(static) prog_value: nk.Size = 40
				@(static) property_float: f32 = 2
				@(static) property_int: c.int = 10
				@(static) property_neg: c.int = 10

				@(static) range_float_min: f32 = 0
				@(static) range_float_max: f32 = 100
				@(static) range_float_value: f32 = 50
				@(static) range_int_min: c.int = 0
				@(static) range_int_value: c.int = 2048
				@(static) range_int_max: c.int = 4096
				@(static) ratio := [?]f32{120, 150}
				@(static) range_int_value_hidden: c.int = 2048

				nk.layout_row_dynamic(ctx, 0, 1)
				nk.checkbox_label(ctx, "CheckLeft TextLeft", &checkbox_left_text_left)
				nk.checkbox_label_align(ctx, "CheckCenter TextRight", &checkbox_centered_text_right, nk.WIDGET_ALIGN_CENTERED | nk.WIDGET_ALIGN_MIDDLE, nk.TEXT_RIGHT)
				nk.checkbox_label_align(ctx, "CheckRight TextRight", &checkbox_right_text_right, nk.WIDGET_LEFT, nk.TEXT_RIGHT)
				nk.checkbox_label_align(ctx, "CheckRight TextLeft", &checkbox_right_text_left, nk.WIDGET_RIGHT, nk.TEXT_LEFT)

				nk.layout_row_static(ctx, 30, 80, 3)
				if nk.option_label(ctx, "optionA", option_left == A) {option_left = A}
				if nk.option_label(ctx, "optionB", option_left == B) {option_left = B}
				if nk.option_label(ctx, "optionC", option_left == C) {option_left = C}

				nk.layout_row_static(ctx, 30, 80, 3)
				if nk.option_label_align(ctx, "optionA", option_right == A, nk.WIDGET_RIGHT, nk.TEXT_RIGHT) {option_right = A}
				if nk.option_label_align(ctx, "optionB", option_right == B, nk.WIDGET_RIGHT, nk.TEXT_RIGHT) {option_right = B}
				if nk.option_label_align(ctx, "optionC", option_right == C, nk.WIDGET_RIGHT, nk.TEXT_RIGHT) {option_right = C}

				nk.layout_row(ctx, nk.STATIC, 30, 2, raw_data(ratio[:]))
				nk.label(ctx, "Slider int", nk.TEXT_LEFT)
				nk.slider_int(ctx, 0, &int_slider, 10, 1)

				nk.label(ctx, "Slider float", nk.TEXT_LEFT)
				nk.slider_float(ctx, 0, &float_slider, 5.0, 0.5)
				nk.label(ctx, fmt.ctprintf("Progressbar: %d", int(prog_value)), nk.TEXT_LEFT)
				nk.progress(ctx, &prog_value, 100, nk.MODIFIABLE != 0)

				nk.layout_row(ctx, nk.STATIC, 40, 2, raw_data(ratio[:]))
				nk.label(ctx, fmt.ctprintf("Knob int: %d", int_knob), nk.TEXT_LEFT)
				nk.knob_int(ctx, 0, &int_knob, 10, 1, nk.DOWN, 60.0)
				nk.label(ctx, fmt.ctprintf("Knob float: %.2f", float_knob), nk.TEXT_LEFT)
				nk.knob_float(ctx, 0, &float_knob, 5.0, 0.5, nk.DOWN, 60.0)

				nk.layout_row(ctx, nk.STATIC, 25, 2, raw_data(ratio[:]))
				nk.label(ctx, "Property float:", nk.TEXT_LEFT)
				nk.property_float(ctx, "Float:", 0, &property_float, 64.0, 0.1, 0.2)
				nk.label(ctx, "Property int:", nk.TEXT_LEFT)
				nk.property_int(ctx, "Int:", 0, &property_int, 100, 1, 1)
				nk.label(ctx, "Property neg:", nk.TEXT_LEFT)
				nk.property_int(ctx, "Neg:", -10, &property_neg, 10, 1, 1)

				nk.layout_row_dynamic(ctx, 25, 1)
				nk.label(ctx, "Range:", nk.TEXT_LEFT)
				nk.layout_row_dynamic(ctx, 25, 3)
				nk.property_float(ctx, "#min:", 0, &range_float_min, range_float_max, 1.0, 0.2)
				nk.property_float(ctx, "#float:", range_float_min, &range_float_value, range_float_max, 1.0, 0.2)
				nk.property_float(ctx, "#max:", range_float_min, &range_float_max, 100, 1.0, 0.2)

				nk.property_int(ctx, "#min:", min(c.int), &range_int_min, range_int_max, 1, 10)
				nk.property_int(ctx, "#neg:", range_int_min, &range_int_value, range_int_max, 1, 10)
				nk.property_int(ctx, "#max:", range_int_min, &range_int_max, max(c.int), 1, 10)

				nk.layout_row_dynamic(ctx, 0, 2)
				nk.label(ctx, "Hidden Label:", nk.TEXT_LEFT)
				nk.property_int(ctx, "##Hidden Label", range_int_min, &range_int_value_hidden, max(c.int), 1, 10)

				nk.tree_pop(ctx)
			}

			if nk.tree_push(ctx, nk.TREE_NODE, "Inactive", nk.MINIMIZED) {
				@(static) inactive: nk.Bool = true
				nk.layout_row_dynamic(ctx, 30, 1)
				nk.checkbox_label(ctx, "Inactive", &inactive)

				nk.layout_row_static(ctx, 30, 80, 1)
				if inactive {
					nk.widget_disable_begin(ctx)
				}

				if nk.button_label(ctx, "button") {
					fmt.println("button pressed")
				}

				nk.widget_disable_end(ctx)

				nk.tree_pop(ctx)
			}

			if nk.tree_push(ctx, nk.TREE_NODE, "Selectable", nk.MINIMIZED) {
				if nk.tree_push(ctx, nk.TREE_NODE, "List", nk.MINIMIZED) {
					@(static) selected := [4]nk.Bool{false, false, true, false}
					nk.layout_row_static(ctx, 18, 100, 1)
					nk.selectable_label(ctx, "Selectable", nk.TEXT_LEFT, &selected[0])
					nk.selectable_label(ctx, "Selectable", nk.TEXT_LEFT, &selected[1])
					nk.label(ctx, "Not Selectable", nk.TEXT_LEFT)
					nk.selectable_label(ctx, "Selectable", nk.TEXT_LEFT, &selected[2])
					nk.selectable_label(ctx, "Selectable", nk.TEXT_LEFT, &selected[3])
					nk.tree_pop(ctx)
				}
				if nk.tree_push(ctx, nk.TREE_NODE, "Grid", nk.MINIMIZED) {
					@(static) selected := [16]nk.Bool{
						true, false, false, false,
						false, true, false, false,
						false, false, true, false,
						false, false, false, true,
					}
					nk.layout_row_static(ctx, 50, 50, 4)
					for i in 0 ..< 16 {
						if nk.selectable_label(ctx, "Z", nk.TEXT_CENTERED, &selected[i]) {
							x, y := i % 4, i / 4
							if x > 0 {selected[i - 1] = !selected[i - 1]}
							if x < 3 {selected[i + 1] = !selected[i + 1]}
							if y > 0 {selected[i - 4] = !selected[i - 4]}
							if y < 3 {selected[i + 4] = !selected[i + 4]}
						}
					}
					nk.tree_pop(ctx)
				}
				nk.tree_pop(ctx)
			}

			if nk.tree_push(ctx, nk.TREE_NODE, "Combo", nk.MINIMIZED) {
				// A combo box is not only a list of text.
				// It shows a selected value and opens a popup window to change it.
				// The popup can hold any widget, for example a color picker or a date picker.
				@(static) chart_selection: f32 = 8.0
				@(static) current_weapon: c.int = 0
				@(static) check_values: [5]nk.Bool
				@(static) position: [3]f32
				@(static) combo_color := nk.Color{130, 50, 50, 255}
				@(static) combo_color2 := nk.Colorf{0.509, 0.705, 0.2, 1.0}
				@(static) prog_a: nk.Size = 20
				@(static) prog_b: nk.Size = 40
				@(static) prog_c: nk.Size = 10
				@(static) prog_d: nk.Size = 90
				@(static) weapons := [?]cstring{"Fist", "Pistol", "Shotgun", "Plasma", "BFG"}

				sum: int

				// Default combo box.
				nk.layout_row_static(ctx, 25, 200, 1)
				current_weapon = nk.combo(ctx, raw_data(weapons[:]), len(weapons), current_weapon, 25, nk.vec2(200, 200))

				// Slider color combo box.
				if nk.combo_begin_color(ctx, combo_color, nk.vec2(200, 200)) {
					@(static) ratios := [?]f32{0.15, 0.85}
					nk.layout_row(ctx, nk.DYNAMIC, 30, 2, raw_data(ratios[:]))
					nk.label(ctx, "R:", nk.TEXT_LEFT)
					combo_color.r = nk.Byte(nk.slide_int(ctx, 0, c.int(combo_color.r), 255, 5))
					nk.label(ctx, "G:", nk.TEXT_LEFT)
					combo_color.g = nk.Byte(nk.slide_int(ctx, 0, c.int(combo_color.g), 255, 5))
					nk.label(ctx, "B:", nk.TEXT_LEFT)
					combo_color.b = nk.Byte(nk.slide_int(ctx, 0, c.int(combo_color.b), 255, 5))
					nk.label(ctx, "A:", nk.TEXT_LEFT)
					combo_color.a = nk.Byte(nk.slide_int(ctx, 0, c.int(combo_color.a), 255, 5))
					nk.combo_end(ctx)
				}
				// Complex color combo box.
				if nk.combo_begin_color(ctx, nk.rgb_cf(combo_color2), nk.vec2(200, 400)) {
					COL_RGB :: 0
					COL_HSV :: 1
					@(static) col_mode: c.int = COL_RGB
					nk.layout_row_dynamic(ctx, 120, 1)
					combo_color2 = nk.color_picker(ctx, combo_color2, nk.RGBA)

					nk.layout_row_dynamic(ctx, 25, 2)
					if nk.option_label(ctx, "RGB", col_mode == COL_RGB) {col_mode = COL_RGB}
					if nk.option_label(ctx, "HSV", col_mode == COL_HSV) {col_mode = COL_HSV}

					nk.layout_row_dynamic(ctx, 25, 1)
					if col_mode == COL_RGB {
						combo_color2.r = nk.propertyf(ctx, "#R:", 0, combo_color2.r, 1.0, 0.01, 0.005)
						combo_color2.g = nk.propertyf(ctx, "#G:", 0, combo_color2.g, 1.0, 0.01, 0.005)
						combo_color2.b = nk.propertyf(ctx, "#B:", 0, combo_color2.b, 1.0, 0.01, 0.005)
						combo_color2.a = nk.propertyf(ctx, "#A:", 0, combo_color2.a, 1.0, 0.01, 0.005)
					} else {
						hsva: [4]f32
						nk.colorf_hsva_fv(raw_data(hsva[:]), combo_color2)
						hsva[0] = nk.propertyf(ctx, "#H:", 0, hsva[0], 1.0, 0.01, 0.05)
						hsva[1] = nk.propertyf(ctx, "#S:", 0, hsva[1], 1.0, 0.01, 0.05)
						hsva[2] = nk.propertyf(ctx, "#V:", 0, hsva[2], 1.0, 0.01, 0.05)
						hsva[3] = nk.propertyf(ctx, "#A:", 0, hsva[3], 1.0, 0.01, 0.05)
						combo_color2 = nk.hsva_colorfv(raw_data(hsva[:]))
					}
					nk.combo_end(ctx)
				}
				// Progress bar combo box.
				sum = int(prog_a + prog_b + prog_c + prog_d)
				if nk.combo_begin_label(ctx, fmt.ctprintf("%d", sum), nk.vec2(200, 200)) {
					nk.layout_row_dynamic(ctx, 30, 1)
					nk.progress(ctx, &prog_a, 100, nk.MODIFIABLE != 0)
					nk.progress(ctx, &prog_b, 100, nk.MODIFIABLE != 0)
					nk.progress(ctx, &prog_c, 100, nk.MODIFIABLE != 0)
					nk.progress(ctx, &prog_d, 100, nk.MODIFIABLE != 0)
					nk.combo_end(ctx)
				}

				// Check box combo box.
				sum = 0
				for v in check_values {
					if v {sum += 1}
				}
				if nk.combo_begin_label(ctx, fmt.ctprintf("%d", sum), nk.vec2(200, 200)) {
					nk.layout_row_dynamic(ctx, 30, 1)
					nk.checkbox_label(ctx, weapons[0], &check_values[0])
					nk.checkbox_label(ctx, weapons[1], &check_values[1])
					nk.checkbox_label(ctx, weapons[2], &check_values[2])
					nk.checkbox_label(ctx, weapons[3], &check_values[3])
					nk.combo_end(ctx)
				}

				// Complex text combo box.
				if nk.combo_begin_label(ctx, fmt.ctprintf("%.2f, %.2f, %.2f", position[0], position[1], position[2]), nk.vec2(200, 200)) {
					nk.layout_row_dynamic(ctx, 25, 1)
					nk.property_float(ctx, "#X:", -1024.0, &position[0], 1024.0, 1, 0.5)
					nk.property_float(ctx, "#Y:", -1024.0, &position[1], 1024.0, 1, 0.5)
					nk.property_float(ctx, "#Z:", -1024.0, &position[2], 1024.0, 1, 0.5)
					nk.combo_end(ctx)
				}

				// Chart combo box.
				if nk.combo_begin_label(ctx, fmt.ctprintf("%.1f", chart_selection), nk.vec2(200, 250)) {
					@(static) values := [?]f32{26, 13, 30, 15, 25, 10, 20, 40, 12, 8, 22, 28, 5}
					nk.layout_row_dynamic(ctx, 150, 1)
					nk.chart_begin(ctx, nk.CHART_COLUMN, len(values), 0, 50)
					for v in values {
						res := nk.chart_push(ctx, v)
						if res & nk.CHART_CLICKED != 0 {
							chart_selection = v
							nk.combo_close(ctx)
						}
					}
					nk.chart_end(ctx)
					nk.combo_end(ctx)
				}

				{
					@(static) time_selected: bool
					@(static) date_selected: bool
					// The values follow struct tm: the month is 0 to 11, the year counts from 1900.
					@(static) sel_hour, sel_min, sel_sec: c.int
					@(static) sel_mday, sel_mon, sel_year: c.int
					if !time_selected || !date_selected {
						// Keep the time and date updated if nothing is selected.
						now, _ := time.time_to_datetime(time.now())
						// Use the local time zone. If the load fails, the time stays in UTC.
						// The region lives until the program ends, so it uses the heap allocator.
						@(static) local_tried: bool
						@(static) local_region: ^datetime.TZ_Region
						if !local_tried {
							local_tried = true
							local_region, _ = timezone.region_load("local", runtime.heap_allocator())
						}
						if local_region != nil {
							now = timezone.datetime_to_tz(now, local_region) or_else now
						}
						if !time_selected {
							sel_hour, sel_min, sel_sec = c.int(now.hour), c.int(now.minute), c.int(now.second)
						}
						if !date_selected {
							sel_mday, sel_mon, sel_year = c.int(now.day), c.int(now.month) - 1, c.int(now.year) - 1900
						}
					}

					// Time combo box.
					if nk.combo_begin_label(ctx, fmt.ctprintf("%02d:%02d:%02d", sel_hour, sel_min, sel_sec), nk.vec2(200, 250)) {
						time_selected = true
						nk.layout_row_dynamic(ctx, 25, 1)
						sel_sec = nk.propertyi(ctx, "#S:", 0, sel_sec, 60, 1, 1)
						sel_min = nk.propertyi(ctx, "#M:", 0, sel_min, 60, 1, 1)
						sel_hour = nk.propertyi(ctx, "#H:", 0, sel_hour, 23, 1, 1)
						nk.combo_end(ctx)
					}

					// Date combo box.
					if nk.combo_begin_label(ctx, fmt.ctprintf("%02d-%02d-%02d", sel_mday, sel_mon + 1, sel_year + 1900), nk.vec2(350, 400)) {
						month := [?]cstring{"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}
						week_days := [?]cstring{"SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"}
						month_days := [?]c.int{31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
						year := sel_year + 1900
						leap_year: c.int = 1 if (year % 4 == 0 && year % 100 != 0) || year % 400 == 0 else 0
						days := month_days[sel_mon] + leap_year if sel_mon == 1 else month_days[sel_mon]

						// Header with the month and the year.
						date_selected = true
						nk.layout_row_begin(ctx, nk.DYNAMIC, 20, 3)
						nk.layout_row_push(ctx, 0.05)
						if nk.button_symbol(ctx, nk.SYMBOL_TRIANGLE_LEFT) {
							if sel_mon == 0 {
								sel_mon = 11
								sel_year = max(0, sel_year - 1)
							} else {
								sel_mon -= 1
							}
						}
						nk.layout_row_push(ctx, 0.9)
						nk.label(ctx, fmt.ctprintf("%s %d", month[sel_mon], year), nk.TEXT_CENTERED)
						nk.layout_row_push(ctx, 0.05)
						if nk.button_symbol(ctx, nk.SYMBOL_TRIANGLE_RIGHT) {
							if sel_mon == 11 {
								sel_mon = 0
								sel_year += 1
							} else {
								sel_mon += 1
							}
						}
						nk.layout_row_end(ctx)

						// The week day formula. The C code uses double for the precision.
						{
							year_n := year - 1 if sel_mon < 2 else year
							y := year_n % 100
							cc := year_n / 100
							y4 := c.int(f32(y) / 4)
							c4 := c.int(f32(cc) / 4)
							m := c.int(2.6 * f64((sel_mon + 10) % 12 + 1) - 0.2)
							week_day := ((1 + m + y + y4 + c4 - 2 * cc) % 7 + 7) % 7

							// Week days.
							nk.layout_row_dynamic(ctx, 35, 7)
							for d in week_days {
								nk.label(ctx, d, nk.TEXT_CENTERED)
							}

							// Days.
							if week_day > 0 {nk.spacing(ctx, week_day)}
							for i in 1 ..= days {
								if nk.button_label(ctx, fmt.ctprintf("%d", i)) {
									sel_mday = i
									nk.combo_close(ctx)
								}
							}
						}
						nk.combo_end(ctx)
					}
				}

				nk.tree_pop(ctx)
			}

			if nk.tree_push(ctx, nk.TREE_NODE, "Input", nk.MINIMIZED) {
				@(static) ratio := [?]f32{120, 150}
				@(static) field_buffer: [64]c.char
				@(static) field_w_overwrite_buf: [64]c.char
				@(static) text: [9][64]c.char
				@(static) text_len: [9]c.int
				@(static) box_buffer: [512]c.char
				@(static) field_len: c.int
				@(static) field_ow_len: c.int
				@(static) box_len: c.int

				nk.layout_row(ctx, nk.STATIC, 25, 2, raw_data(ratio[:]))
				nk.label(ctx, "Default:", nk.TEXT_LEFT)

				nk.edit_string(ctx, nk.EDIT_SIMPLE, raw_data(text[0][:]), &text_len[0], 64, nk.filter_default)
				nk.label(ctx, "Int:", nk.TEXT_LEFT)
				nk.edit_string(ctx, nk.EDIT_SIMPLE, raw_data(text[1][:]), &text_len[1], 64, nk.filter_decimal)
				nk.label(ctx, "Float:", nk.TEXT_LEFT)
				nk.edit_string(ctx, nk.EDIT_SIMPLE, raw_data(text[2][:]), &text_len[2], 64, nk.filter_float)
				nk.label(ctx, "Hex:", nk.TEXT_LEFT)
				nk.edit_string(ctx, nk.EDIT_SIMPLE, raw_data(text[4][:]), &text_len[4], 64, nk.filter_hex)
				nk.label(ctx, "Octal:", nk.TEXT_LEFT)
				nk.edit_string(ctx, nk.EDIT_SIMPLE, raw_data(text[5][:]), &text_len[5], 64, nk.filter_oct)
				nk.label(ctx, "Binary:", nk.TEXT_LEFT)
				nk.edit_string(ctx, nk.EDIT_SIMPLE, raw_data(text[6][:]), &text_len[6], 64, nk.filter_binary)

				nk.label(ctx, "Password:", nk.TEXT_LEFT)
				{
					old_len := text_len[8]
					buffer: [64]c.char
					for i in 0 ..< text_len[8] {
						buffer[i] = '*'
					}
					nk.edit_string(ctx, nk.EDIT_FIELD, raw_data(buffer[:]), &text_len[8], 64, nk.filter_default)
					if old_len < text_len[8] {
						copy(text[8][old_len:], buffer[old_len:text_len[8]])
					}
				}

				nk.label(ctx, "Field:", nk.TEXT_LEFT)
				nk.edit_string(ctx, nk.EDIT_FIELD, raw_data(field_buffer[:]), &field_len, 64, nk.filter_default)

				nk.label(ctx, "Field 2:", nk.TEXT_LEFT)
				nk.edit_string(ctx, nk.EDIT_SELECTABLE | nk.EDIT_CLIPBOARD, raw_data(field_w_overwrite_buf[:]), &field_ow_len, 64, nk.filter_default)

				nk.label(ctx, "Box:", nk.TEXT_LEFT)
				nk.layout_row_static(ctx, 180, 278, 1)
				nk.edit_string(ctx, nk.EDIT_BOX, raw_data(box_buffer[:]), &box_len, 512, nk.filter_default)

				nk.layout_row(ctx, nk.STATIC, 25, 2, raw_data(ratio[:]))
				active := nk.edit_string(ctx, nk.EDIT_FIELD | nk.EDIT_SIG_ENTER, raw_data(text[7][:]), &text_len[7], 64, nk.filter_ascii)
				if bool(nk.button_label(ctx, "Submit")) || (active & nk.EDIT_COMMITTED) != 0 {
					// The C code writes past the end of the line buffer when it is full. Keep the newline inside.
					if text_len[7] < len(text[7]) {
						text[7][text_len[7]] = '\n'
						text_len[7] += 1
					}
					// Keep the copy inside the box buffer.
					copied := copy(box_buffer[box_len:], text[7][:text_len[7]])
					box_len += c.int(copied)
					text_len[7] = 0
				}
				nk.tree_pop(ctx)
			}

			if nk.tree_push(ctx, nk.TREE_NODE, "Horizontal Rule", nk.MINIMIZED) {
				nk.layout_row_dynamic(ctx, 12, 1)
				nk.label(ctx, "Use this to subdivide spaces visually", nk.TEXT_LEFT)
				nk.layout_row_dynamic(ctx, 4, 1)
				nk.rule_horizontal(ctx, WHITE, true)
				nk.layout_row_dynamic(ctx, 75, 1)
				nk.label_wrap(ctx, "Best used in 'Card'-like layouts, with a bigger title font on top. Takes on the size of the previous layout definition. Rounding optional.")
				nk.tree_pop(ctx)
			}

			nk.tree_pop(ctx)
		}

		if nk.tree_push(ctx, nk.TREE_TAB, "Chart", nk.MINIMIZED) {
			// Chart widgets. The line chart and the column chart use the immediate mode API.
			// Call chart_begin with the minimum and maximum values for the Y-axis.
			// Call chart_push for each value. Call chart_end to finish the chart.
			id: f32 = 0
			@(static) col_index: int = -1
			@(static) line_index: int = -1
			@(static) show_markers: nk.Bool = true
			step: f32 = (2 * 3.141592654) / 32
			index: int = -1

			// Line chart.
			id = 0
			index = -1
			nk.layout_row_dynamic(ctx, 15, 1)
			nk.checkbox_label(ctx, "Show markers", &show_markers)
			nk.layout_row_dynamic(ctx, 100, 1)
			ctx.style.chart.show_markers = show_markers
			if nk.chart_begin(ctx, nk.CHART_LINES, 32, -1.0, 1.0) {
				for i in 0 ..< 32 {
					res := nk.chart_push(ctx, f32(math.cos(f64(id))))
					if res & nk.CHART_HOVERING != 0 {
						index = i
					}
					if res & nk.CHART_CLICKED != 0 {
						line_index = i
					}
					id += step
				}
				nk.chart_end(ctx)
			}

			if index != -1 {
				nk.tooltip(ctx, fmt.ctprintf("Value: %.2f", f32(math.cos(f64(f32(index) * step)))))
			}
			if line_index != -1 {
				nk.layout_row_dynamic(ctx, 20, 1)
				// The C code uses index here, not line_index. Keep this behavior.
				nk.label(ctx, fmt.ctprintf("Selected value: %.2f", f32(math.cos(f64(f32(index) * step)))), nk.TEXT_LEFT)
			}

			// Column chart.
			nk.layout_row_dynamic(ctx, 100, 1)
			if nk.chart_begin(ctx, nk.CHART_COLUMN, 32, 0.0, 1.0) {
				for i in 0 ..< 32 {
					res := nk.chart_push(ctx, f32(abs(math.sin(f64(id)))))
					if res & nk.CHART_HOVERING != 0 {
						index = i
					}
					if res & nk.CHART_CLICKED != 0 {
						col_index = i
					}
					id += step
				}
				nk.chart_end(ctx)
			}
			if index != -1 {
				nk.tooltip(ctx, fmt.ctprintf("Value: %.2f", f32(abs(math.sin(f64(step * f32(index)))))))
			}
			if col_index != -1 {
				nk.layout_row_dynamic(ctx, 20, 1)
				nk.label(ctx, fmt.ctprintf("Selected value: %.2f", f32(abs(math.sin(f64(step * f32(col_index)))))), nk.TEXT_LEFT)
			}

			// Mixed chart.
			nk.layout_row_dynamic(ctx, 100, 1)
			if nk.chart_begin(ctx, nk.CHART_COLUMN, 32, 0.0, 1.0) {
				nk.chart_add_slot(ctx, nk.CHART_LINES, 32, -1.0, 1.0)
				nk.chart_add_slot(ctx, nk.CHART_LINES, 32, -1.0, 1.0)
				id = 0
				for _ in 0 ..< 32 {
					nk.chart_push_slot(ctx, f32(abs(math.sin(f64(id)))), 0)
					nk.chart_push_slot(ctx, f32(math.cos(f64(id))), 1)
					nk.chart_push_slot(ctx, f32(math.sin(f64(id))), 2)
					id += step
				}
			}
			// The C code calls chart_end outside of the if.
			nk.chart_end(ctx)

			// Mixed colored chart.
			nk.layout_row_dynamic(ctx, 100, 1)
			if nk.chart_begin_colored(ctx, nk.CHART_LINES, nk.rgb(255, 0, 0), nk.rgb(150, 0, 0), 32, 0.0, 1.0) {
				nk.chart_add_slot_colored(ctx, nk.CHART_LINES, nk.rgb(0, 0, 255), nk.rgb(0, 0, 150), 32, -1.0, 1.0)
				nk.chart_add_slot_colored(ctx, nk.CHART_LINES, nk.rgb(0, 255, 0), nk.rgb(0, 150, 0), 32, -1.0, 1.0)
				id = 0
				for _ in 0 ..< 32 {
					nk.chart_push_slot(ctx, f32(abs(math.sin(f64(id)))), 0)
					nk.chart_push_slot(ctx, f32(math.cos(f64(id))), 1)
					nk.chart_push_slot(ctx, f32(math.sin(f64(id))), 2)
					id += step
				}
			}
			nk.chart_end(ctx)
			nk.tree_pop(ctx)
		}

		if nk.tree_push(ctx, nk.TREE_TAB, "Popup", nk.MINIMIZED) {
			@(static) color := nk.Color{255, 0, 0, 255}
			@(static) select_state: [4]nk.Bool
			@(static) popup_active: nk.Bool
			input := &ctx.input
			bounds: nk.Rect

			// Times are in seconds.
			@(static) delay_timer: f32 = 0.0
			@(static) clicked: nk.Bool = false

			// Menu contextual.
			nk.layout_row_static(ctx, 30, 160, 1)
			bounds = nk.widget_bounds(ctx)
			nk.label(ctx, "Right click me for menu", nk.TEXT_LEFT)

			if nk.contextual_begin(ctx, 0, nk.vec2(100, 300), bounds) {
				@(static) prog: nk.Size = 40
				@(static) slider: c.int = 10

				nk.layout_row_dynamic(ctx, 25, 1)
				nk.checkbox_label(ctx, "Menu", &show_menu)
				nk.progress(ctx, &prog, 100, nk.MODIFIABLE != 0)
				nk.slider_int(ctx, 0, &slider, 16, 1)
				if nk.contextual_item_label(ctx, "About", nk.TEXT_CENTERED) {
					show_app_about = true
				}
				nk.selectable_label(ctx, cstring("Unselect") if select_state[0] else cstring("Select"), nk.TEXT_LEFT, &select_state[0])
				nk.selectable_label(ctx, cstring("Unselect") if select_state[1] else cstring("Select"), nk.TEXT_LEFT, &select_state[1])
				nk.selectable_label(ctx, cstring("Unselect") if select_state[2] else cstring("Select"), nk.TEXT_LEFT, &select_state[2])
				nk.selectable_label(ctx, cstring("Unselect") if select_state[3] else cstring("Select"), nk.TEXT_LEFT, &select_state[3])
				nk.contextual_end(ctx)
			}

			// Color contextual.
			nk.layout_row_begin(ctx, nk.STATIC, 30, 2)
			nk.layout_row_push(ctx, 120)
			nk.label(ctx, "Right Click here:", nk.TEXT_LEFT)
			nk.layout_row_push(ctx, 50)
			bounds = nk.widget_bounds(ctx)
			nk.button_color(ctx, color)
			nk.layout_row_end(ctx)

			if nk.contextual_begin(ctx, 0, nk.vec2(350, 60), bounds) {
				nk.layout_row_dynamic(ctx, 30, 4)
				color.r = nk.Byte(nk.propertyi(ctx, "#r", 0, c.int(color.r), 255, 1, 1))
				color.g = nk.Byte(nk.propertyi(ctx, "#g", 0, c.int(color.g), 255, 1, 1))
				color.b = nk.Byte(nk.propertyi(ctx, "#b", 0, c.int(color.b), 255, 1, 1))
				color.a = nk.Byte(nk.propertyi(ctx, "#a", 0, c.int(color.a), 255, 1, 1))
				nk.contextual_end(ctx)
			}

			// Popup.
			nk.layout_row_begin(ctx, nk.STATIC, 30, 2)
			nk.layout_row_push(ctx, 120)
			nk.label(ctx, "Popup:", nk.TEXT_LEFT)
			nk.layout_row_push(ctx, 50)
			if nk.button_label(ctx, "Popup") {
				popup_active = true
			}
			nk.layout_row_end(ctx)

			if popup_active {
				@(static) s := nk.Rect{20, 100, 220, 90}
				if nk.popup_begin(ctx, nk.POPUP_STATIC, "Error", 0, s) {
					nk.layout_row_dynamic(ctx, 25, 1)
					nk.label(ctx, "A terrible error as occurred", nk.TEXT_LEFT)
					nk.layout_row_dynamic(ctx, 25, 2)
					if nk.button_label(ctx, "OK") {
						popup_active = false
						nk.popup_close(ctx)
					}
					if nk.button_label(ctx, "Cancel") {
						popup_active = false
						nk.popup_close(ctx)
					}
					nk.popup_end(ctx)
				} else {
					popup_active = false
				}
			}

			// Tooltips.
			nk.layout_row_static(ctx, 30, 400, 1)
			bounds = nk.widget_bounds(ctx)
			nk.label(ctx, "Hover for default tooltip", nk.TEXT_LEFT)
			if nk.input_is_mouse_hovering_rect(input, bounds) {
				nk.tooltip(ctx, "This is a default tooltip")
			}

			bounds = nk.widget_bounds(ctx)
			nk.label(ctx, "Hover motionless for a default delayed tooltip", nk.TEXT_LEFT)
			nk.do_tooltip_delay(ctx, "This is a delayed tooltip", bounds, &delay_timer)

			bounds = nk.widget_bounds(ctx)
			nk.label(ctx, "Hover motionless longer a custom delayed tooltip", nk.TEXT_LEFT)
			if nk.input_is_mouse_hovering_still_delay_rect(ctx, bounds, &delay_timer, 1.5) {
				nk.tooltip(ctx, "This is a custom delayed tooltip")
			}

			bounds = nk.widget_bounds(ctx)
			if nk.button_label(ctx, "Delayed tooltip with click sensitivity") {
				clicked = true
			}
			nk.do_tooltip_delay_clicked(ctx, "disappears when clicked, timer starts when you move again", bounds, &delay_timer, &clicked)

			bounds = nk.widget_bounds(ctx)
			nk.label(ctx, "Hover for Gnome-like tooltip", nk.TEXT_LEFT)
			if nk.input_is_mouse_hovering_rect(input, bounds) {
				offset := nk.Vec2{0, -15}
				nk.tooltip_offset(ctx, "Gnome bottom centers plus a -y offset", nk.BOTTOM_CENTER, offset)
			}
			bounds = nk.widget_bounds(ctx)
			nk.label(ctx, "Hover for a bottom left tooltip", nk.TEXT_LEFT)
			if nk.input_is_mouse_hovering_rect(input, bounds) {
				offset := nk.Vec2{0, 0}
				nk.tooltip_offset(ctx, "Bottom left positioning", nk.BOTTOM_LEFT, offset)
			}
			bounds = nk.widget_bounds(ctx)
			nk.label(ctx, "Hover for MAGIC!", nk.TEXT_LEFT)
			if nk.input_is_mouse_hovering_rect(input, bounds) {
				@(static) accum_time_seconds: f64 = 0.0
				speed: f64 = 3.0
				radius: f64 = 50.0
				offset: nk.Vec2
				offset.x = f32(radius * math.cos(accum_time_seconds * speed))
				offset.y = f32(radius * math.sin(accum_time_seconds * speed))
				nk.tooltip_offset(ctx, "WOW!", nk.MIDDLE_CENTER, offset)
				accum_time_seconds += f64(ctx.delta_time_seconds)
			}

			// Editor for the custom tooltip.
			{
				@(static) text_buf: [64]c.char
				@(static) text_initialized: bool
				@(static) offset: nk.Vec2
				@(static) tooltip_positions := [?]cstring{
					"TOP_LEFT",
					"TOP_CENTER",
					"TOP_RIGHT",

					"MIDDLE_LEFT",
					"MIDDLE_CENTER",
					"MIDDLE_RIGHT",

					"BOTTOM_LEFT",
					"BOTTOM_CENTER",
					"BOTTOM_RIGHT",
				}
				@(static) cur_pos: c.int = nk.TOP_LEFT

				if !text_initialized {
					// The buffer is zero filled, so the text keeps its terminating zero.
					text_default :: "you can customize this!"
					#assert(len(text_default) < len(text_buf))
					text := text_default
					for i in 0 ..< len(text) {
						text_buf[i] = c.char(text[i])
					}
					text_initialized = true
				}
				bounds = nk.widget_bounds(ctx)
				nk.label(ctx, "Hover for custom tooltip (you can customize it below)", nk.TEXT_LEFT)
				if nk.input_is_mouse_hovering_rect(input, bounds) {
					nk.tooltip_offset(ctx, cstring(raw_data(text_buf[:])), cur_pos, offset)
				}
				nk.layout_row_dynamic(ctx, 1, 1)
				nk.rule_horizontal(ctx, WHITE, true)
				nk.layout_row_dynamic(ctx, 30, 2)
				nk.label(ctx, "custom tooltip text:", nk.TEXT_LEFT)
				nk.edit_string_zero_terminated(ctx, nk.EDIT_SIMPLE, raw_data(text_buf[:]), len(text_buf), nk.filter_default)
				nk.layout_row_dynamic(ctx, 30, 1)
				cur_pos = nk.combo(ctx, raw_data(tooltip_positions[:]), len(tooltip_positions), cur_pos, 25, nk.vec2(200, 200))

				nk.layout_row_dynamic(ctx, 30, 2)
				nk.label(ctx, "custom tooltip offset", nk.TEXT_LEFT)
				nk.property_float(ctx, "#x", -100.0, &offset.x, 100.0, 5.0, 0.5)
				nk.label(ctx, "custom tooltip offset", nk.TEXT_LEFT)
				nk.property_float(ctx, "#y", -100.0, &offset.y, 100.0, 5.0, 0.5)
			}

			nk.tree_pop(ctx)
		}

		if nk.tree_push(ctx, nk.TREE_TAB, "Layout", nk.MINIMIZED) {
			if nk.tree_push(ctx, nk.TREE_NODE, "Widget", nk.MINIMIZED) {
				// Nuklear keeps the pointer to a row array, so the arrays are static.
				@(static) ratio_two := [?]f32{0.2, 0.6, 0.2}
				@(static) width_two := [?]f32{100, 200, 50}

				nk.layout_row_dynamic(ctx, 30, 1)
				nk.label(ctx, "Dynamic fixed column layout with generated position and size:", nk.TEXT_LEFT)
				nk.layout_row_dynamic(ctx, 30, 3)
				nk.button_label(ctx, "button")
				nk.button_label(ctx, "button")
				nk.button_label(ctx, "button")

				nk.layout_row_dynamic(ctx, 30, 1)
				nk.label(ctx, "static fixed column layout with generated position and size:", nk.TEXT_LEFT)
				nk.layout_row_static(ctx, 30, 100, 3)
				nk.button_label(ctx, "button")
				nk.button_label(ctx, "button")
				nk.button_label(ctx, "button")

				nk.layout_row_dynamic(ctx, 30, 1)
				nk.label(ctx, "Dynamic array-based custom column layout with generated position and custom size:", nk.TEXT_LEFT)
				nk.layout_row(ctx, nk.DYNAMIC, 30, 3, raw_data(ratio_two[:]))
				nk.button_label(ctx, "button")
				nk.button_label(ctx, "button")
				nk.button_label(ctx, "button")

				nk.layout_row_dynamic(ctx, 30, 1)
				nk.label(ctx, "Static array-based custom column layout with generated position and custom size:", nk.TEXT_LEFT)
				nk.layout_row(ctx, nk.STATIC, 30, 3, raw_data(width_two[:]))
				nk.button_label(ctx, "button")
				nk.button_label(ctx, "button")
				nk.button_label(ctx, "button")

				nk.layout_row_dynamic(ctx, 30, 1)
				nk.label(ctx, "Dynamic immediate mode custom column layout with generated position and custom size:", nk.TEXT_LEFT)
				nk.layout_row_begin(ctx, nk.DYNAMIC, 30, 3)
				nk.layout_row_push(ctx, 0.2)
				nk.button_label(ctx, "button")
				nk.layout_row_push(ctx, 0.6)
				nk.button_label(ctx, "button")
				nk.layout_row_push(ctx, 0.2)
				nk.button_label(ctx, "button")
				nk.layout_row_end(ctx)

				nk.layout_row_dynamic(ctx, 30, 1)
				nk.label(ctx, "Static immediate mode custom column layout with generated position and custom size:", nk.TEXT_LEFT)
				nk.layout_row_begin(ctx, nk.STATIC, 30, 3)
				nk.layout_row_push(ctx, 100)
				nk.button_label(ctx, "button")
				nk.layout_row_push(ctx, 200)
				nk.button_label(ctx, "button")
				nk.layout_row_push(ctx, 50)
				nk.button_label(ctx, "button")
				nk.layout_row_end(ctx)

				nk.layout_row_dynamic(ctx, 30, 1)
				nk.label(ctx, "Static free space with custom position and custom size:", nk.TEXT_LEFT)
				nk.layout_space_begin(ctx, nk.STATIC, 60, 4)
				nk.layout_space_push(ctx, nk.rect(100, 0, 100, 30))
				nk.button_label(ctx, "button")
				nk.layout_space_push(ctx, nk.rect(0, 15, 100, 30))
				nk.button_label(ctx, "button")
				nk.layout_space_push(ctx, nk.rect(200, 15, 100, 30))
				nk.button_label(ctx, "button")
				nk.layout_space_push(ctx, nk.rect(100, 30, 100, 30))
				nk.button_label(ctx, "button")
				nk.layout_space_end(ctx)

				nk.layout_row_dynamic(ctx, 30, 1)
				nk.label(ctx, "Row template:", nk.TEXT_LEFT)
				nk.layout_row_template_begin(ctx, 30)
				nk.layout_row_template_push_dynamic(ctx)
				nk.layout_row_template_push_variable(ctx, 80)
				nk.layout_row_template_push_static(ctx, 80)
				nk.layout_row_template_end(ctx)
				nk.button_label(ctx, "button")
				nk.button_label(ctx, "button")
				nk.button_label(ctx, "button")

				nk.tree_pop(ctx)
			}

			if nk.tree_push(ctx, nk.TREE_NODE, "Group", nk.MINIMIZED) {
				@(static) group_titlebar: nk.Bool = false
				@(static) group_border: nk.Bool = true
				@(static) group_no_scrollbar: nk.Bool = false
				@(static) group_width: c.int = 320
				@(static) group_height: c.int = 200

				group_flags: nk.Flags = 0
				if group_border {group_flags |= nk.WINDOW_BORDER}
				if group_no_scrollbar {group_flags |= nk.WINDOW_NO_SCROLLBAR}
				if group_titlebar {group_flags |= nk.WINDOW_TITLE}

				nk.layout_row_dynamic(ctx, 30, 3)
				nk.checkbox_label(ctx, "Titlebar", &group_titlebar)
				nk.checkbox_label(ctx, "Border", &group_border)
				nk.checkbox_label(ctx, "No Scrollbar", &group_no_scrollbar)

				nk.layout_row_begin(ctx, nk.STATIC, 22, 3)
				nk.layout_row_push(ctx, 50)
				nk.label(ctx, "size:", nk.TEXT_LEFT)
				nk.layout_row_push(ctx, 130)
				nk.property_int(ctx, "#Width:", 100, &group_width, 500, 10, 1)
				nk.layout_row_push(ctx, 130)
				nk.property_int(ctx, "#Height:", 100, &group_height, 500, 10, 1)
				nk.layout_row_end(ctx)

				nk.layout_row_static(ctx, f32(group_height), group_width, 2)
				if nk.group_begin(ctx, "Group", group_flags) {
					@(static) selected: [16]nk.Bool
					nk.layout_row_static(ctx, 18, 100, 1)
					for i in 0 ..< 16 {
						nk.selectable_label(ctx, cstring("Selected") if selected[i] else cstring("Unselected"), nk.TEXT_CENTERED, &selected[i])
					}
					nk.group_end(ctx)
				}
				nk.tree_pop(ctx)
			}
			if nk.tree_push(ctx, nk.TREE_NODE, "Tree", nk.MINIMIZED) {
				@(static) root_selected: nk.Bool = false
				sel := root_selected
				if nk.tree_element_push(ctx, nk.TREE_NODE, "Root", nk.MINIMIZED, &sel) {
					@(static) selected: [8]nk.Bool
					node_select := selected[0]
					if sel != root_selected {
						root_selected = sel
						for i in 0 ..< 8 {
							selected[i] = sel
						}
					}
					if nk.tree_element_push(ctx, nk.TREE_NODE, "Node", nk.MINIMIZED, &node_select) {
						@(static) sel_nodes: [4]nk.Bool
						if node_select != selected[0] {
							selected[0] = node_select
							for i in 0 ..< 4 {
								sel_nodes[i] = node_select
							}
						}
						nk.layout_row_static(ctx, 18, 100, 1)
						for j in 0 ..< 4 {
							nk.selectable_symbol_label(ctx, nk.SYMBOL_CIRCLE_SOLID, cstring("Selected") if sel_nodes[j] else cstring("Unselected"), nk.TEXT_RIGHT, &sel_nodes[j])
						}
						nk.tree_element_pop(ctx)
					}
					nk.layout_row_static(ctx, 18, 100, 1)
					for i in 1 ..< 8 {
						nk.selectable_symbol_label(ctx, nk.SYMBOL_CIRCLE_SOLID, cstring("Selected") if selected[i] else cstring("Unselected"), nk.TEXT_RIGHT, &selected[i])
					}
					nk.tree_element_pop(ctx)
				}
				nk.tree_pop(ctx)
			}
			if nk.tree_push(ctx, nk.TREE_NODE, "Notebook", nk.MINIMIZED) {
				@(static) current_tab: c.int = 0
				step: f32 = (2 * 3.141592654) / 32
				CHART_LINE  :: 0
				CHART_HISTO :: 1
				CHART_MIXED :: 2
				names := [?]cstring{"Lines", "Columns", "Mixed"}
				id: f32 = 0

				// Header.
				nk.style_push_vec2(ctx, &ctx.style.window.spacing, nk.vec2(0, 0))
				nk.style_push_float(ctx, &ctx.style.button.rounding, 0)
				nk.layout_row_begin(ctx, nk.STATIC, 20, 3)
				for i in 0 ..< 3 {
					// Make sure the button fits the text.
					f := ctx.style.font
					text_width := f.width(f.userdata, f.height, names[i], nk.strlen(names[i]))
					widget_width := text_width + 3 * ctx.style.button.padding.x
					nk.layout_row_push(ctx, widget_width)
					if current_tab == c.int(i) {
						// The active tab gets highlighted.
						button_color := ctx.style.button.normal
						ctx.style.button.normal = ctx.style.button.active
						current_tab = c.int(i) if nk.button_label(ctx, names[i]) else current_tab
						ctx.style.button.normal = button_color
					} else {
						current_tab = c.int(i) if nk.button_label(ctx, names[i]) else current_tab
					}
				}
				nk.style_pop_float(ctx)

				// Body.
				nk.layout_row_dynamic(ctx, 140, 1)
				if nk.group_begin(ctx, "Notebook", nk.WINDOW_BORDER) {
					nk.style_pop_vec2(ctx)
					switch current_tab {
					case CHART_LINE:
						nk.layout_row_dynamic(ctx, 100, 1)
						if nk.chart_begin_colored(ctx, nk.CHART_LINES, nk.rgb(255, 0, 0), nk.rgb(150, 0, 0), 32, 0.0, 1.0) {
							nk.chart_add_slot_colored(ctx, nk.CHART_LINES, nk.rgb(0, 0, 255), nk.rgb(0, 0, 150), 32, -1.0, 1.0)
							id = 0
							for _ in 0 ..< 32 {
								nk.chart_push_slot(ctx, f32(abs(math.sin(f64(id)))), 0)
								nk.chart_push_slot(ctx, f32(math.cos(f64(id))), 1)
								id += step
							}
						}
						nk.chart_end(ctx)
					case CHART_HISTO:
						nk.layout_row_dynamic(ctx, 100, 1)
						if nk.chart_begin_colored(ctx, nk.CHART_COLUMN, nk.rgb(255, 0, 0), nk.rgb(150, 0, 0), 32, 0.0, 1.0) {
							id = 0
							for _ in 0 ..< 32 {
								nk.chart_push_slot(ctx, f32(abs(math.sin(f64(id)))), 0)
								id += step
							}
						}
						nk.chart_end(ctx)
					case CHART_MIXED:
						nk.layout_row_dynamic(ctx, 100, 1)
						if nk.chart_begin_colored(ctx, nk.CHART_LINES, nk.rgb(255, 0, 0), nk.rgb(150, 0, 0), 32, 0.0, 1.0) {
							nk.chart_add_slot_colored(ctx, nk.CHART_LINES, nk.rgb(0, 0, 255), nk.rgb(0, 0, 150), 32, -1.0, 1.0)
							nk.chart_add_slot_colored(ctx, nk.CHART_COLUMN, nk.rgb(0, 255, 0), nk.rgb(0, 150, 0), 32, 0.0, 1.0)
							id = 0
							for _ in 0 ..< 32 {
								nk.chart_push_slot(ctx, f32(abs(math.sin(f64(id)))), 0)
								nk.chart_push_slot(ctx, f32(abs(math.cos(f64(id)))), 1)
								nk.chart_push_slot(ctx, f32(abs(math.sin(f64(id)))), 2)
								id += step
							}
						}
						nk.chart_end(ctx)
					}
					nk.group_end(ctx)
				} else {
					nk.style_pop_vec2(ctx)
				}
				nk.tree_pop(ctx)
			}

			if nk.tree_push(ctx, nk.TREE_NODE, "Simple", nk.MINIMIZED) {
				nk.layout_row_dynamic(ctx, 300, 2)
				if nk.group_begin(ctx, "Group_Without_Border", 0) {
					nk.layout_row_static(ctx, 18, 150, 1)
					for i in 0 ..< 64 {
						nk.label(ctx, fmt.ctprintf("0x%02x: scrollable region", i), nk.TEXT_LEFT)
					}
					nk.group_end(ctx)
				}
				if nk.group_begin(ctx, "Group_With_Border", nk.WINDOW_BORDER) {
					nk.layout_row_dynamic(ctx, 25, 2)
					for i in 0 ..< 64 {
						nk.button_label(ctx, fmt.ctprintf("%08d", (((i % 7) * 10) ~ 32) + (64 + (i % 2) * 2)))
					}
					nk.group_end(ctx)
				}
				nk.tree_pop(ctx)
			}

			if nk.tree_push(ctx, nk.TREE_NODE, "Complex", nk.MINIMIZED) {
				nk.layout_space_begin(ctx, nk.STATIC, 500, 64)
				nk.layout_space_push(ctx, nk.rect(0, 0, 150, 500))
				if nk.group_begin(ctx, "Group_left", nk.WINDOW_BORDER) {
					@(static) selected: [32]nk.Bool
					nk.layout_row_static(ctx, 18, 100, 1)
					for i in 0 ..< 32 {
						nk.selectable_label(ctx, cstring("Selected") if selected[i] else cstring("Unselected"), nk.TEXT_CENTERED, &selected[i])
					}
					nk.group_end(ctx)
				}

				nk.layout_space_push(ctx, nk.rect(160, 0, 150, 240))
				if nk.group_begin(ctx, "Group_top", nk.WINDOW_BORDER) {
					nk.layout_row_dynamic(ctx, 25, 1)
					nk.button_label(ctx, "#FFAA")
					nk.button_label(ctx, "#FFBB")
					nk.button_label(ctx, "#FFCC")
					nk.button_label(ctx, "#FFDD")
					nk.button_label(ctx, "#FFEE")
					nk.button_label(ctx, "#FFFF")
					nk.group_end(ctx)
				}

				nk.layout_space_push(ctx, nk.rect(160, 250, 150, 250))
				if nk.group_begin(ctx, "Group_buttom", nk.WINDOW_BORDER) {
					nk.layout_row_dynamic(ctx, 25, 1)
					nk.button_label(ctx, "#FFAA")
					nk.button_label(ctx, "#FFBB")
					nk.button_label(ctx, "#FFCC")
					nk.button_label(ctx, "#FFDD")
					nk.button_label(ctx, "#FFEE")
					nk.button_label(ctx, "#FFFF")
					nk.group_end(ctx)
				}

				nk.layout_space_push(ctx, nk.rect(320, 0, 150, 150))
				if nk.group_begin(ctx, "Group_right_top", nk.WINDOW_BORDER) {
					@(static) selected: [4]nk.Bool
					nk.layout_row_static(ctx, 18, 100, 1)
					for i in 0 ..< 4 {
						nk.selectable_label(ctx, cstring("Selected") if selected[i] else cstring("Unselected"), nk.TEXT_CENTERED, &selected[i])
					}
					nk.group_end(ctx)
				}

				nk.layout_space_push(ctx, nk.rect(320, 160, 150, 150))
				if nk.group_begin(ctx, "Group_right_center", nk.WINDOW_BORDER) {
					@(static) selected: [4]nk.Bool
					nk.layout_row_static(ctx, 18, 100, 1)
					for i in 0 ..< 4 {
						nk.selectable_label(ctx, cstring("Selected") if selected[i] else cstring("Unselected"), nk.TEXT_CENTERED, &selected[i])
					}
					nk.group_end(ctx)
				}

				nk.layout_space_push(ctx, nk.rect(320, 320, 150, 150))
				if nk.group_begin(ctx, "Group_right_bottom", nk.WINDOW_BORDER) {
					@(static) selected: [4]nk.Bool
					nk.layout_row_static(ctx, 18, 100, 1)
					for i in 0 ..< 4 {
						nk.selectable_label(ctx, cstring("Selected") if selected[i] else cstring("Unselected"), nk.TEXT_CENTERED, &selected[i])
					}
					nk.group_end(ctx)
				}
				nk.layout_space_end(ctx)
				nk.tree_pop(ctx)
			}

			if nk.tree_push(ctx, nk.TREE_NODE, "Splitter", nk.MINIMIZED) {
				input := &ctx.input
				nk.layout_row_dynamic(ctx, 30, 1)
				nk.label_wrap(ctx, "Adjust the tile sizes with the sliders or by dragging the space between tiles")

				if nk.tree_push(ctx, nk.TREE_NODE, "Vertical", nk.MINIMIZED) {
					@(static) a: f32 = 100
					@(static) b: f32 = 100
					@(static) cw: f32 = 100
					bounds: nk.Rect

					// Nuklear keeps the pointer to the row array, so the array is static.
					@(static) row_layout: [5]f32
					row_layout[0] = a
					row_layout[1] = 8
					row_layout[2] = b
					row_layout[3] = 8
					row_layout[4] = cw

					// Header.
					nk.layout_row_static(ctx, 30, 100, 2)
					nk.label(ctx, "left:", nk.TEXT_LEFT)
					nk.slider_float(ctx, 10.0, &a, 200.0, 10.0)

					nk.label(ctx, "middle:", nk.TEXT_LEFT)
					nk.slider_float(ctx, 10.0, &b, 200.0, 10.0)

					nk.label(ctx, "right:", nk.TEXT_LEFT)
					nk.slider_float(ctx, 10.0, &cw, 200.0, 10.0)

					// Tiles.
					nk.layout_row(ctx, nk.STATIC, 200, 5, raw_data(row_layout[:]))

					// Left space.
					if nk.group_begin(ctx, "left", nk.WINDOW_NO_SCROLLBAR | nk.WINDOW_BORDER | nk.WINDOW_NO_SCROLLBAR) {
						nk.layout_row_dynamic(ctx, 25, 1)
						nk.button_label(ctx, "#FFAA")
						nk.button_label(ctx, "#FFBB")
						nk.button_label(ctx, "#FFCC")
						nk.button_label(ctx, "#FFDD")
						nk.button_label(ctx, "#FFEE")
						nk.button_label(ctx, "#FFFF")
						nk.group_end(ctx)
					}

					// Scaler.
					bounds = nk.widget_bounds(ctx)
					nk.spacing(ctx, 1)
					if (bool(nk.input_is_mouse_hovering_rect(input, bounds)) || bool(nk.input_is_mouse_prev_hovering_rect(input, bounds))) && bool(nk.input_is_mouse_down(input, nk.BUTTON_LEFT)) {
						a = row_layout[0] + input.mouse.delta.x
						b = row_layout[2] - input.mouse.delta.x
					}

					// Middle space.
					if nk.group_begin(ctx, "center", nk.WINDOW_BORDER | nk.WINDOW_NO_SCROLLBAR) {
						nk.layout_row_dynamic(ctx, 25, 1)
						nk.button_label(ctx, "#FFAA")
						nk.button_label(ctx, "#FFBB")
						nk.button_label(ctx, "#FFCC")
						nk.button_label(ctx, "#FFDD")
						nk.button_label(ctx, "#FFEE")
						nk.button_label(ctx, "#FFFF")
						nk.group_end(ctx)
					}

					// Scaler.
					bounds = nk.widget_bounds(ctx)
					nk.spacing(ctx, 1)
					if (bool(nk.input_is_mouse_hovering_rect(input, bounds)) || bool(nk.input_is_mouse_prev_hovering_rect(input, bounds))) && bool(nk.input_is_mouse_down(input, nk.BUTTON_LEFT)) {
						b = row_layout[2] + input.mouse.delta.x
						cw = row_layout[4] - input.mouse.delta.x
					}

					// Right space.
					if nk.group_begin(ctx, "right", nk.WINDOW_BORDER | nk.WINDOW_NO_SCROLLBAR) {
						nk.layout_row_dynamic(ctx, 25, 1)
						nk.button_label(ctx, "#FFAA")
						nk.button_label(ctx, "#FFBB")
						nk.button_label(ctx, "#FFCC")
						nk.button_label(ctx, "#FFDD")
						nk.button_label(ctx, "#FFEE")
						nk.button_label(ctx, "#FFFF")
						nk.group_end(ctx)
					}

					nk.tree_pop(ctx)
				}

				if nk.tree_push(ctx, nk.TREE_NODE, "Horizontal", nk.MINIMIZED) {
					@(static) a: f32 = 100
					@(static) b: f32 = 100
					@(static) cw: f32 = 100
					bounds: nk.Rect

					// Header.
					nk.layout_row_static(ctx, 30, 100, 2)
					nk.label(ctx, "top:", nk.TEXT_LEFT)
					nk.slider_float(ctx, 10.0, &a, 200.0, 10.0)

					nk.label(ctx, "middle:", nk.TEXT_LEFT)
					nk.slider_float(ctx, 10.0, &b, 200.0, 10.0)

					nk.label(ctx, "bottom:", nk.TEXT_LEFT)
					nk.slider_float(ctx, 10.0, &cw, 200.0, 10.0)

					// Top space.
					nk.layout_row_dynamic(ctx, a, 1)
					if nk.group_begin(ctx, "top", nk.WINDOW_NO_SCROLLBAR | nk.WINDOW_BORDER) {
						nk.layout_row_dynamic(ctx, 25, 3)
						nk.button_label(ctx, "#FFAA")
						nk.button_label(ctx, "#FFBB")
						nk.button_label(ctx, "#FFCC")
						nk.button_label(ctx, "#FFDD")
						nk.button_label(ctx, "#FFEE")
						nk.button_label(ctx, "#FFFF")
						nk.group_end(ctx)
					}

					// Scaler.
					nk.layout_row_dynamic(ctx, 8, 1)
					bounds = nk.widget_bounds(ctx)
					nk.spacing(ctx, 1)
					if (bool(nk.input_is_mouse_hovering_rect(input, bounds)) || bool(nk.input_is_mouse_prev_hovering_rect(input, bounds))) && bool(nk.input_is_mouse_down(input, nk.BUTTON_LEFT)) {
						a = a + input.mouse.delta.y
						b = b - input.mouse.delta.y
					}

					// Middle space.
					nk.layout_row_dynamic(ctx, b, 1)
					if nk.group_begin(ctx, "middle", nk.WINDOW_NO_SCROLLBAR | nk.WINDOW_BORDER) {
						nk.layout_row_dynamic(ctx, 25, 3)
						nk.button_label(ctx, "#FFAA")
						nk.button_label(ctx, "#FFBB")
						nk.button_label(ctx, "#FFCC")
						nk.button_label(ctx, "#FFDD")
						nk.button_label(ctx, "#FFEE")
						nk.button_label(ctx, "#FFFF")
						nk.group_end(ctx)
					}

					{
						// Scaler.
						nk.layout_row_dynamic(ctx, 8, 1)
						bounds = nk.widget_bounds(ctx)
						if (bool(nk.input_is_mouse_hovering_rect(input, bounds)) || bool(nk.input_is_mouse_prev_hovering_rect(input, bounds))) && bool(nk.input_is_mouse_down(input, nk.BUTTON_LEFT)) {
							b = b + input.mouse.delta.y
							cw = cw - input.mouse.delta.y
						}
					}

					// Bottom space.
					nk.layout_row_dynamic(ctx, cw, 1)
					if nk.group_begin(ctx, "bottom", nk.WINDOW_NO_SCROLLBAR | nk.WINDOW_BORDER) {
						nk.layout_row_dynamic(ctx, 25, 3)
						nk.button_label(ctx, "#FFAA")
						nk.button_label(ctx, "#FFBB")
						nk.button_label(ctx, "#FFCC")
						nk.button_label(ctx, "#FFDD")
						nk.button_label(ctx, "#FFEE")
						nk.button_label(ctx, "#FFFF")
						nk.group_end(ctx)
					}
					nk.tree_pop(ctx)
				}
				nk.tree_pop(ctx)
			}
			nk.tree_pop(ctx)
		}

		// Input.
		if nk.tree_push(ctx, nk.TREE_TAB, "Input", nk.MINIMIZED) {
			input := &ctx.input
			@(static) button_names := [nk.BUTTON_MAX]cstring{"Left", "Middle", "Right", "Double Click", "X1", "X2"}

			// Mouse buttons.
			nk.layout_row_dynamic(ctx, 30, 1)
			nk.label(ctx, "Mouse Buttons", nk.TEXT_LEFT)
			nk.layout_row_dynamic(ctx, 20, 2)
			for i in 0 ..< nk.BUTTON_MAX {
				button := nk.Buttons(i)
				nk.label(ctx, button_names[i], nk.TEXT_LEFT)
				if nk.input_is_mouse_pressed(input, button) {
					nk.label(ctx, "Pressed", nk.TEXT_LEFT)
				} else if nk.input_is_mouse_down(input, button) {
					nk.label(ctx, "Down", nk.TEXT_LEFT)
				} else if nk.input_is_mouse_released(input, button) {
					nk.label(ctx, "Released", nk.TEXT_LEFT)
				} else {
					nk.label(ctx, "Up", nk.TEXT_LEFT)
				}
			}

			// Mouse wheel.
			nk.layout_row_dynamic(ctx, 30, 1)
			nk.label(ctx, "Mouse Wheel", nk.TEXT_LEFT)
			nk.layout_row_dynamic(ctx, 20, 2)
			nk.label(ctx, fmt.ctprintf("X: %.2f", input.mouse.scroll_delta.x), nk.TEXT_LEFT)
			nk.label(ctx, fmt.ctprintf("Y: %.2f", input.mouse.scroll_delta.y), nk.TEXT_LEFT)
			nk.tree_pop(ctx)
		}

		if disable_widgets {
			nk.widget_disable_end(ctx)
		}
	}
	nk.end(ctx)
	return !bool(nk.window_is_closed(ctx, "Overview"))
}
