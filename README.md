# nuklear-odin

Odin bindings for [Nuklear](https://github.com/Immediate-Mode-UI/Nuklear). Nuklear is an immediate mode UI library in one C header. It does not draw. It makes a list of draw commands or a vertex buffer. You draw them with your own renderer.

## Build

Clone the repository with its submodule:

```sh
git clone --recursive <this repository>
```

Build the C library into `lib/`:

```sh
.\build.bat     # Windows (needs clang and llvm-lib from LLVM)
./build.sh      # Linux (needs cc and ar)
```

This makes `lib/nuklear.lib` (Windows) or `lib/libnuklear.a` (Linux). It also makes the `nuklear_layout` library, which only the tests use.

The build scripts accept one build option:

| Build option | Effect |
|--------------|--------|
| `debug`      | Compile with `-O0 -g` in place of `-O3 -DNDEBUG`. |

Set the `CC` environment variable to use a different C compiler.

## Test

Build the C library first. The layout test needs the `nuklear_layout` library.

```sh
odin test tests
```

## Use

```odin
import nk "path/to/nuklear-odin"

// Bake the default font.
atlas: nk.Font_Atlas
nk.font_atlas_init_default(&atlas)
nk.font_atlas_begin(&atlas)
font := nk.font_atlas_add_default(&atlas, 13, nil)
w, h: i32
pixels := nk.font_atlas_bake(&atlas, &w, &h, nk.FONT_ATLAS_RGBA32)
// Upload the pixels to a texture. Then call nk.font_atlas_end.

ctx: nk.Context
nk.init_default(&ctx, &font.handle)

// ... for each frame, send the input with nk.input_begin, nk.input_motion, ..., nk.input_end ...
if nk.begin(&ctx, "Hello", {50, 50, 200, 100}, nk.WINDOW_BORDER | nk.WINDOW_MOVABLE | nk.WINDOW_TITLE) {
	nk.layout_row_dynamic(&ctx, 30, 1)
	if nk.button_label(&ctx, "Click") {
		// ... the user clicked the button ...
	}
}
nk.end(&ctx)

it := nk.Command_Iterator{ctx = &ctx}
for cmd in nk.foreach(&it) {
	// ... draw cmd, or call nk.convert to make triangles ...
}
nk.clear(&ctx)
```

## Names

The names agree with `nuklear.h`, without the `nk_` and `NK_` prefixes.

| C | Odin |
|---|------|
| `nk_begin` | `nk.begin` |
| `NK_WINDOW_BORDER` | `nk.WINDOW_BORDER` |
| `struct nk_context` | `nk.Context` |
| `nk_true`, `nk_false` | `nk.TRUE`, `nk.FALSE` |
| `nk__begin` | `nk._begin` |

Each type name is in `Ada_Case`. A struct field keeps its C name, with one exception: `Text_Undo_Record.where_`.

Each C enum is an alias of `c.int`. Its members are untyped constants. Combine flags with `|`, as in C: `nk.WINDOW_BORDER | nk.WINDOW_MOVABLE`. `nk.Bool` is `b32`.

Use the Odin `true` and `false` for an `nk.Bool`. `nk.TRUE` and `nk.FALSE` are untyped integers for a `c.int` parameter.

Odin has no C macros. These procedures replace the macros that make a loop or use the caller location:

- `nk.foreach` replaces `nk_foreach`. Set only `ctx` in a `nk.Command_Iterator`.
- `nk.draw_foreach` replaces `nk_draw_foreach`. Set only `ctx` and `cmds` in a `nk.Draw_Iterator`.
- `nk.tree_push`, `nk.tree_image_push`, and `nk.tree_element_push` replace the `nk_tree_*_push` macros. The `_id` forms replace the `nk_tree_*_push_id` macros.

The `labelf`, `tooltipf`, and `tooltipf_offset` procedures do not change the type of a variadic argument. Give `f64` for a float. Give `c.int` for an integer.

## Examples

All examples show the Nuklear "Demo" window and a port of `overview.c`.

```sh
odin run examples/gdi      # Win32 GDI window (Windows only)
odin run examples/sdl      # SDL3 window
odin run examples/raylib   # raylib window
odin run examples/x11      # X11 window (Linux only)
```

- On Windows, the SDL example needs `SDL3.dll` next to the program that `odin run examples/sdl` makes. Run it from the repository root, and copy `SDL3.dll` from the `vendor/sdl3` folder of your Odin installation to the current directory.
- On Linux, the SDL example needs the SDL3 library of your system.
- The X11 example and the Linux build and test steps did not run on Linux. They passed only `odin check -target:linux_amd64`.

## Compile options

Nuklear sets its features with compile options. The compile options are in `nuklear_options.h`. They change the layout of the types and the set of procedures.

A change to these compile options needs a change to the bindings. The layout test in `tests/` shows a mismatch.

## License

Nuklear: see `nuklear/LICENSE`.
