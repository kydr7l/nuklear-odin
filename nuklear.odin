// Bindings for the Nuklear immediate mode UI library (https://github.com/Immediate-Mode-UI/Nuklear).
// The names agree with nuklear.h, without the "nk_" and "NK_" prefixes.
//
// These bindings agree with the options in nuklear_options.h:
// STBRP_STATIC, STBTT_STATIC, NK_INCLUDE_FIXED_TYPES, NK_INCLUDE_STANDARD_IO,
// NK_INCLUDE_STANDARD_VARARGS, NK_INCLUDE_DEFAULT_ALLOCATOR,
// NK_INCLUDE_VERTEX_BUFFER_OUTPUT, NK_INCLUDE_FONT_BAKING and NK_INCLUDE_DEFAULT_FONT.
// The options change the layout of the types and the set of procedures.
// If you change nuklear_options.h, you must also change these bindings.
package nuklear

import "core:c"

Char       :: i8
Uchar      :: u8
Byte       :: u8
Short      :: i16
Ushort     :: u16
Int        :: i32
Uint       :: u32
Size       :: uintptr
Ptr        :: uintptr
Bool       :: b32
Flags      :: u32
Hash       :: u32
Rune       :: u32
Draw_Index :: u16

FALSE :: 0
TRUE  :: 1

UNDEFINED                       :: -1.0
UTF_INVALID                     :: 0xFFFD
UTF_SIZE                        :: 4
INPUT_MAX                       :: 16
MAX_NUMBER_BUFFER               :: 64
SCROLLBAR_HIDING_TIMEOUT        :: 4.0
WIDGET_DISABLED_FACTOR          :: 0.5
TEXTEDIT_UNDOSTATECOUNT         :: 99
TEXTEDIT_UNDOCHARCOUNT          :: 999
MAX_LAYOUT_ROW_TEMPLATE_COLUMNS :: 16
CHART_MAX_SLOT                  :: 4
WINDOW_MAX_NAME                 :: 64
BUTTON_BEHAVIOR_STACK_SIZE      :: 8
FONT_STACK_SIZE                 :: 8
STYLE_ITEM_STACK_SIZE           :: 16
FLOAT_STACK_SIZE                :: 32
VECTOR_STACK_SIZE               :: 16
FLAGS_STACK_SIZE                :: 32
COLOR_STACK_SIZE                :: 32
// The C value is max(size_of(Window), size_of(Panel)) / size_of(Uint) / 2.
// Table uses this constant, and Window points to Table. With the formula, Odin gives the Table arrays 0 elements.
VALUE_PAGE_CAPACITY :: 69
PI                  :: 3.141592654
PI_HALF             :: 1.570796326
MAX_FLOAT_PRECISION :: 2

Glyph :: [UTF_SIZE]u8

Handle :: struct #raw_union {
	ptr: rawptr,
	id:  c.int,
}

Color :: struct {
	r, g, b, a: Byte,
}

Colorf :: struct {
	r, g, b, a: f32,
}

Vec2 :: struct {
	x, y: f32,
}

Vec2i :: struct {
	x, y: c.short,
}

Rect :: struct {
	x, y, w, h: f32,
}

Recti :: struct {
	x, y, w, h: c.short,
}

Image :: struct {
	handle: Handle,
	w, h:   Ushort,
	region: [4]Ushort,
}

Nine_Slice :: struct {
	img:        Image,
	l, t, r, b: Ushort,
}

Cursor :: struct {
	img:          Image,
	size, offset: Vec2,
}

Scroll :: struct {
	x, y: Uint,
}

Heading :: c.int
UP    :: 0
RIGHT :: 1
DOWN  :: 2
LEFT  :: 3

Button_Behavior :: c.int
BUTTON_DEFAULT  :: 0
BUTTON_REPEATER :: 1

Link_Underline :: c.int
LINK_UNDERLINE_NONE   :: 0
LINK_UNDERLINE_HOVER  :: 1
LINK_UNDERLINE_ALWAYS :: 2

Modify :: c.int
FIXED      :: FALSE
MODIFIABLE :: TRUE

Orientation :: c.int
VERTICAL   :: 0
HORIZONTAL :: 1

Collapse_States :: c.int
MINIMIZED :: FALSE
MAXIMIZED :: TRUE

Show_States :: c.int
HIDDEN :: FALSE
SHOWN  :: TRUE

Chart_Type :: c.int
CHART_LINES  :: 0
CHART_COLUMN :: 1
CHART_MAX    :: 2

Chart_Event :: c.int
CHART_HOVERING :: 0x01
CHART_CLICKED  :: 0x02

Color_Format :: c.int
RGB  :: 0
RGBA :: 1

Popup_Type :: c.int
POPUP_STATIC  :: 0
POPUP_DYNAMIC :: 1

Layout_Format :: c.int
DYNAMIC :: 0
STATIC  :: 1

Tree_Type :: c.int
TREE_NODE :: 0
TREE_TAB  :: 1

Tooltip_Pos :: c.int
TOP_LEFT      :: 0
TOP_CENTER    :: 1
TOP_RIGHT     :: 2
MIDDLE_LEFT   :: 3
MIDDLE_CENTER :: 4
MIDDLE_RIGHT  :: 5
BOTTOM_LEFT   :: 6
BOTTOM_CENTER :: 7
BOTTOM_RIGHT  :: 8

Symbol_Type :: c.int
SYMBOL_NONE                   :: 0
SYMBOL_X                      :: 1
SYMBOL_UNDERSCORE             :: 2
SYMBOL_CIRCLE_SOLID           :: 3
SYMBOL_CIRCLE_OUTLINE         :: 4
SYMBOL_RECT_SOLID             :: 5
SYMBOL_RECT_OUTLINE           :: 6
SYMBOL_TRIANGLE_UP            :: 7
SYMBOL_TRIANGLE_DOWN          :: 8
SYMBOL_TRIANGLE_LEFT          :: 9
SYMBOL_TRIANGLE_RIGHT         :: 10
SYMBOL_PLUS                   :: 11
SYMBOL_MINUS                  :: 12
SYMBOL_TRIANGLE_UP_OUTLINE    :: 13
SYMBOL_TRIANGLE_DOWN_OUTLINE  :: 14
SYMBOL_TRIANGLE_LEFT_OUTLINE  :: 15
SYMBOL_TRIANGLE_RIGHT_OUTLINE :: 16
SYMBOL_CHEVRON_UP             :: 17
SYMBOL_CHEVRON_RIGHT          :: 18
SYMBOL_CHEVRON_DOWN           :: 19
SYMBOL_CHEVRON_LEFT           :: 20
SYMBOL_HAMBURGER              :: 21
SYMBOL_MAX                    :: 22

Keys :: c.int
KEY_NONE              :: 0
KEY_SHIFT             :: 1
KEY_CTRL              :: 2
KEY_DEL               :: 3
KEY_ENTER             :: 4
KEY_TAB               :: 5
KEY_BACKSPACE         :: 6
KEY_COPY              :: 7
KEY_CUT               :: 8
KEY_PASTE             :: 9
KEY_UP                :: 10
KEY_DOWN              :: 11
KEY_LEFT              :: 12
KEY_RIGHT             :: 13
KEY_TEXT_INSERT_MODE  :: 14
KEY_TEXT_REPLACE_MODE :: 15
KEY_TEXT_RESET_MODE   :: 16
KEY_TEXT_LINE_START   :: 17
KEY_TEXT_LINE_END     :: 18
KEY_TEXT_START        :: 19
KEY_TEXT_END          :: 20
KEY_TEXT_UNDO         :: 21
KEY_TEXT_REDO         :: 22
KEY_TEXT_SELECT_ALL   :: 23
KEY_TEXT_WORD_LEFT    :: 24
KEY_TEXT_WORD_RIGHT   :: 25
KEY_SCROLL_START      :: 26
KEY_SCROLL_END        :: 27
KEY_SCROLL_DOWN       :: 28
KEY_SCROLL_UP         :: 29
KEY_ALT               :: 30
KEY_F1                :: 31
KEY_F2                :: 32
KEY_F3                :: 33
KEY_F4                :: 34
KEY_F5                :: 35
KEY_F6                :: 36
KEY_F7                :: 37
KEY_F8                :: 38
KEY_F9                :: 39
KEY_F10               :: 40
KEY_F11               :: 41
KEY_F12               :: 42
KEY_MAX               :: 43

Buttons :: c.int
BUTTON_LEFT   :: 0
BUTTON_MIDDLE :: 1
BUTTON_RIGHT  :: 2
BUTTON_DOUBLE :: 3
BUTTON_X1     :: 4
BUTTON_X2     :: 5
BUTTON_MAX    :: 6

Anti_Aliasing :: c.int
ANTI_ALIASING_OFF :: 0
ANTI_ALIASING_ON  :: 1

Convert_Result :: c.int
CONVERT_SUCCESS             :: 0
CONVERT_INVALID_PARAM       :: 1
CONVERT_COMMAND_BUFFER_FULL :: 1 << 1
CONVERT_VERTEX_BUFFER_FULL  :: 1 << 2
CONVERT_ELEMENT_BUFFER_FULL :: 1 << 3

Panel_Flags :: c.int
WINDOW_BORDER           :: 1 << 0
WINDOW_MOVABLE          :: 1 << 1
WINDOW_SCALABLE         :: 1 << 2
WINDOW_CLOSABLE         :: 1 << 3
WINDOW_MINIMIZABLE      :: 1 << 4
WINDOW_NO_SCROLLBAR     :: 1 << 5
WINDOW_TITLE            :: 1 << 6
WINDOW_SCROLL_AUTO_HIDE :: 1 << 7
WINDOW_BACKGROUND       :: 1 << 8
WINDOW_SCALE_LEFT       :: 1 << 9
WINDOW_NO_INPUT         :: 1 << 10

Widget_Align :: c.int
WIDGET_ALIGN_LEFT     :: 0x01
WIDGET_ALIGN_CENTERED :: 0x02
WIDGET_ALIGN_RIGHT    :: 0x04
WIDGET_ALIGN_TOP      :: 0x08
WIDGET_ALIGN_MIDDLE   :: 0x10
WIDGET_ALIGN_BOTTOM   :: 0x20

Widget_Alignment :: c.int
WIDGET_LEFT     :: WIDGET_ALIGN_MIDDLE | WIDGET_ALIGN_LEFT
WIDGET_CENTERED :: WIDGET_ALIGN_MIDDLE | WIDGET_ALIGN_CENTERED
WIDGET_RIGHT    :: WIDGET_ALIGN_MIDDLE | WIDGET_ALIGN_RIGHT

Widget_Layout_States :: c.int
WIDGET_INVALID  :: 0
WIDGET_VALID    :: 1
WIDGET_ROM      :: 2
WIDGET_DISABLED :: 3

Widget_States :: c.int
WIDGET_STATE_MODIFIED :: 1 << 1
WIDGET_STATE_INACTIVE :: 1 << 2
WIDGET_STATE_ENTERED  :: 1 << 3
WIDGET_STATE_HOVER    :: 1 << 4
WIDGET_STATE_ACTIVED  :: 1 << 5
WIDGET_STATE_LEFT     :: 1 << 6
WIDGET_STATE_HOVERED  :: WIDGET_STATE_HOVER | WIDGET_STATE_MODIFIED
WIDGET_STATE_ACTIVE   :: WIDGET_STATE_ACTIVED | WIDGET_STATE_MODIFIED

Text_Align :: c.int
TEXT_ALIGN_LEFT     :: 0x01
TEXT_ALIGN_CENTERED :: 0x02
TEXT_ALIGN_RIGHT    :: 0x04
TEXT_ALIGN_TOP      :: 0x08
TEXT_ALIGN_MIDDLE   :: 0x10
TEXT_ALIGN_BOTTOM   :: 0x20

Text_Alignment :: c.int
TEXT_LEFT     :: TEXT_ALIGN_MIDDLE | TEXT_ALIGN_LEFT
TEXT_CENTERED :: TEXT_ALIGN_MIDDLE | TEXT_ALIGN_CENTERED
TEXT_RIGHT    :: TEXT_ALIGN_MIDDLE | TEXT_ALIGN_RIGHT

Edit_Flags :: c.int
EDIT_DEFAULT              :: 0
EDIT_READ_ONLY            :: 1 << 0
EDIT_AUTO_SELECT          :: 1 << 1
EDIT_SIG_ENTER            :: 1 << 2
EDIT_ALLOW_TAB            :: 1 << 3
EDIT_NO_CURSOR            :: 1 << 4
EDIT_SELECTABLE           :: 1 << 5
EDIT_CLIPBOARD            :: 1 << 6
EDIT_CTRL_ENTER_NEWLINE   :: 1 << 7
EDIT_NO_HORIZONTAL_SCROLL :: 1 << 8
EDIT_ALWAYS_INSERT_MODE   :: 1 << 9
EDIT_MULTILINE            :: 1 << 10
EDIT_GOTO_END_ON_ACTIVATE :: 1 << 11

Edit_Types :: c.int
EDIT_SIMPLE :: EDIT_ALWAYS_INSERT_MODE
EDIT_FIELD  :: EDIT_SIMPLE | EDIT_SELECTABLE | EDIT_CLIPBOARD
EDIT_BOX    :: EDIT_ALWAYS_INSERT_MODE | EDIT_SELECTABLE | EDIT_MULTILINE | EDIT_ALLOW_TAB | EDIT_CLIPBOARD
EDIT_EDITOR :: EDIT_SELECTABLE | EDIT_MULTILINE | EDIT_ALLOW_TAB | EDIT_CLIPBOARD

Edit_Events :: c.int
EDIT_ACTIVE      :: 1 << 0
EDIT_INACTIVE    :: 1 << 1
EDIT_ACTIVATED   :: 1 << 2
EDIT_DEACTIVATED :: 1 << 3
EDIT_COMMITTED   :: 1 << 4
EDIT_COMMITED    :: EDIT_COMMITTED // the old spelling in nuklear.h

Style_Colors :: c.int
COLOR_TEXT                    :: 0
COLOR_WINDOW                  :: 1
COLOR_HEADER                  :: 2
COLOR_BORDER                  :: 3
COLOR_BUTTON                  :: 4
COLOR_BUTTON_HOVER            :: 5
COLOR_BUTTON_ACTIVE           :: 6
COLOR_TOGGLE                  :: 7
COLOR_TOGGLE_HOVER            :: 8
COLOR_TOGGLE_CURSOR           :: 9
COLOR_SELECT                  :: 10
COLOR_SELECT_ACTIVE           :: 11
COLOR_SLIDER                  :: 12
COLOR_SLIDER_CURSOR           :: 13
COLOR_SLIDER_CURSOR_HOVER     :: 14
COLOR_SLIDER_CURSOR_ACTIVE    :: 15
COLOR_PROPERTY                :: 16
COLOR_EDIT                    :: 17
COLOR_EDIT_CURSOR             :: 18
COLOR_COMBO                   :: 19
COLOR_CHART                   :: 20
COLOR_CHART_COLOR             :: 21
COLOR_CHART_COLOR_HIGHLIGHT   :: 22
COLOR_SCROLLBAR               :: 23
COLOR_SCROLLBAR_CURSOR        :: 24
COLOR_SCROLLBAR_CURSOR_HOVER  :: 25
COLOR_SCROLLBAR_CURSOR_ACTIVE :: 26
COLOR_TAB_HEADER              :: 27
COLOR_KNOB                    :: 28
COLOR_KNOB_CURSOR             :: 29
COLOR_KNOB_CURSOR_HOVER       :: 30
COLOR_KNOB_CURSOR_ACTIVE      :: 31
COLOR_COUNT                   :: 32

Style_Cursor :: c.int
CURSOR_ARROW                      :: 0
CURSOR_TEXT                       :: 1
CURSOR_MOVE                       :: 2
CURSOR_RESIZE_VERTICAL            :: 3
CURSOR_RESIZE_HORIZONTAL          :: 4
CURSOR_RESIZE_TOP_LEFT_DOWN_RIGHT :: 5
CURSOR_RESIZE_TOP_RIGHT_DOWN_LEFT :: 6
CURSOR_COUNT                      :: 7

Font_Coord_Type :: c.int
COORD_UV    :: 0
COORD_PIXEL :: 1

Font_Atlas_Format :: c.int
FONT_ATLAS_ALPHA8 :: 0
FONT_ATLAS_RGBA32 :: 1

Allocation_Type :: c.int
BUFFER_FIXED   :: 0
BUFFER_DYNAMIC :: 1

Buffer_Allocation_Type :: c.int
BUFFER_FRONT :: 0
BUFFER_BACK  :: 1
BUFFER_MAX   :: 2

Text_Edit_Type :: c.int
TEXT_EDIT_SINGLE_LINE :: 0
TEXT_EDIT_MULTI_LINE  :: 1

Text_Edit_Mode :: c.int
TEXT_EDIT_MODE_VIEW    :: 0
TEXT_EDIT_MODE_INSERT  :: 1
TEXT_EDIT_MODE_REPLACE :: 2

Command_Type :: c.int
COMMAND_NOP              :: 0
COMMAND_SCISSOR          :: 1
COMMAND_LINE             :: 2
COMMAND_CURVE            :: 3
COMMAND_RECT             :: 4
COMMAND_RECT_FILLED      :: 5
COMMAND_RECT_MULTI_COLOR :: 6
COMMAND_CIRCLE           :: 7
COMMAND_CIRCLE_FILLED    :: 8
COMMAND_ARC              :: 9
COMMAND_ARC_FILLED       :: 10
COMMAND_TRIANGLE         :: 11
COMMAND_TRIANGLE_FILLED  :: 12
COMMAND_POLYGON          :: 13
COMMAND_POLYGON_FILLED   :: 14
COMMAND_POLYLINE         :: 15
COMMAND_TEXT             :: 16
COMMAND_IMAGE            :: 17
COMMAND_CUSTOM           :: 18

Command_Clipping :: c.int
CLIPPING_OFF :: FALSE
CLIPPING_ON  :: TRUE

Draw_List_Stroke :: c.int
STROKE_OPEN   :: FALSE
STROKE_CLOSED :: TRUE

Draw_Vertex_Layout_Attribute :: c.int
VERTEX_POSITION        :: 0
VERTEX_COLOR           :: 1
VERTEX_TEXCOORD        :: 2
VERTEX_ATTRIBUTE_COUNT :: 3

Draw_Vertex_Layout_Format :: c.int
FORMAT_SCHAR               :: 0
FORMAT_SSHORT              :: 1
FORMAT_SINT                :: 2
FORMAT_UCHAR               :: 3
FORMAT_USHORT              :: 4
FORMAT_UINT                :: 5
FORMAT_FLOAT               :: 6
FORMAT_DOUBLE              :: 7
FORMAT_COLOR_BEGIN         :: 8
FORMAT_R8G8B8              :: FORMAT_COLOR_BEGIN
FORMAT_R16G15B16           :: 9
FORMAT_R32G32B32           :: 10
FORMAT_R8G8B8A8            :: 11
FORMAT_B8G8R8A8            :: 12
FORMAT_R16G15B16A16        :: 13
FORMAT_R32G32B32A32        :: 14
FORMAT_R32G32B32A32_FLOAT  :: 15
FORMAT_R32G32B32A32_DOUBLE :: 16
FORMAT_RGB32               :: 17
FORMAT_RGBA32              :: 18
FORMAT_COLOR_END           :: FORMAT_RGBA32
FORMAT_COUNT               :: 19

Style_Item_Type :: c.int
STYLE_ITEM_COLOR      :: 0
STYLE_ITEM_IMAGE      :: 1
STYLE_ITEM_NINE_SLICE :: 2

Style_Header_Align :: c.int
HEADER_LEFT  :: 0
HEADER_RIGHT :: 1

Panel_Type :: c.int
PANEL_NONE       :: 0
PANEL_WINDOW     :: 1 << 0
PANEL_GROUP      :: 1 << 1
PANEL_POPUP      :: 1 << 2
PANEL_CONTEXTUAL :: 1 << 4
PANEL_COMBO      :: 1 << 5
PANEL_MENU       :: 1 << 6
PANEL_TOOLTIP    :: 1 << 7

Panel_Set :: c.int
PANEL_SET_NONBLOCK :: PANEL_CONTEXTUAL | PANEL_COMBO | PANEL_MENU | PANEL_TOOLTIP
PANEL_SET_POPUP    :: PANEL_SET_NONBLOCK | PANEL_POPUP
PANEL_SET_SUB      :: PANEL_SET_POPUP | PANEL_GROUP

Panel_Row_Layout_Type :: c.int
LAYOUT_DYNAMIC_FIXED :: 0
LAYOUT_DYNAMIC_ROW   :: 1
LAYOUT_DYNAMIC_FREE  :: 2
LAYOUT_DYNAMIC       :: 3
LAYOUT_STATIC_FIXED  :: 4
LAYOUT_STATIC_ROW    :: 5
LAYOUT_STATIC_FREE   :: 6
LAYOUT_STATIC        :: 7
LAYOUT_TEMPLATE      :: 8
LAYOUT_COUNT         :: 9

Window_Flags :: c.int
WINDOW_PRIVATE         :: 1 << 11
WINDOW_DYNAMIC         :: WINDOW_PRIVATE
WINDOW_ROM             :: 1 << 12
WINDOW_NOT_INTERACTIVE :: WINDOW_ROM | WINDOW_NO_INPUT
WINDOW_HIDDEN          :: 1 << 13
WINDOW_CLOSED          :: 1 << 14
WINDOW_MINIMIZED       :: 1 << 15
WINDOW_REMOVE_ROM      :: 1 << 16
