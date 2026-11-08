/* Compile options for the Nuklear static library. */

/* Make the stb symbols static, because raylib exports the same stbrp_* symbols. */
#define STBRP_STATIC
#define STBTT_STATIC

#define NK_INCLUDE_FIXED_TYPES
#define NK_INCLUDE_STANDARD_IO
#define NK_INCLUDE_STANDARD_VARARGS
#define NK_INCLUDE_DEFAULT_ALLOCATOR
#define NK_INCLUDE_VERTEX_BUFFER_OUTPUT
#define NK_INCLUDE_FONT_BAKING
#define NK_INCLUDE_DEFAULT_FONT
