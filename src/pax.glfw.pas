unit pax.glfw;

{$mode ObjFPC}{$H+}
{ $DEFINE VK_VERSION_1_0}
interface

uses
  Classes, SysUtils, paxutils, dynlibs;

const
  libGLFW = 'glfw3.' + SharedSuffix;

  GLFW_VERSION_MAJOR = 3;
  {$IFDEF GLFW3_LASTEST}
  GLFW_VERSION_MINOR = 3;
  GLFW_VERSION_REVISION = 7;
  {$ELSE}
  GLFW_VERSION_MINOR = 4;
  GLFW_VERSION_REVISION = 0;
  {$ENDIF}
  GLFW_TRUE = 1;
  GLFW_FALSE = 0;
  GLFW_RELEASE = 0;
  GLFW_PRESS = 1;
  GLFW_REPEAT = 2;

  GLFW_HAT_CENTERED = 0;
  GLFW_HAT_UP = 1;
  GLFW_HAT_RIGHT = 2;
  GLFW_HAT_DOWN = 4;
  GLFW_HAT_LEFT = 8;
  GLFW_HAT_RIGHT_UP = (GLFW_HAT_RIGHT or GLFW_HAT_UP);
  GLFW_HAT_RIGHT_DOWN = (GLFW_HAT_RIGHT or GLFW_HAT_DOWN);
  GLFW_HAT_LEFT_UP = (GLFW_HAT_LEFT or GLFW_HAT_UP);
  GLFW_HAT_LEFT_DOWN = (GLFW_HAT_LEFT or GLFW_HAT_DOWN);

  GLFW_KEY_UNKNOWN = -1;

  GLFW_KEY_SPACE = 32;
  GLFW_KEY_APOSTROPHE = 39;
  GLFW_KEY_COMMA = 44;
  GLFW_KEY_MINUS = 45;
  GLFW_KEY_PERIOD = 46;
  GLFW_KEY_SLASH = 47;
  GLFW_KEY_0 = 48;
  GLFW_KEY_1 = 49;
  GLFW_KEY_2 = 50;
  GLFW_KEY_3 = 51;
  GLFW_KEY_4 = 52;
  GLFW_KEY_5 = 53;
  GLFW_KEY_6 = 54;
  GLFW_KEY_7 = 55;
  GLFW_KEY_8 = 56;
  GLFW_KEY_9 = 57;
  GLFW_KEY_SEMICOLON = 59;
  GLFW_KEY_EQUAL = 61;
  GLFW_KEY_A = 65;
  GLFW_KEY_B = 66;
  GLFW_KEY_C = 67;
  GLFW_KEY_D = 68;
  GLFW_KEY_E = 69;
  GLFW_KEY_F = 70;
  GLFW_KEY_G = 71;
  GLFW_KEY_H = 72;
  GLFW_KEY_I = 73;
  GLFW_KEY_J = 74;
  GLFW_KEY_K = 75;
  GLFW_KEY_L = 76;
  GLFW_KEY_M = 77;
  GLFW_KEY_N = 78;
  GLFW_KEY_O = 79;
  GLFW_KEY_P = 80;
  GLFW_KEY_Q = 81;
  GLFW_KEY_R = 82;
  GLFW_KEY_S = 83;
  GLFW_KEY_T = 84;
  GLFW_KEY_U = 85;
  GLFW_KEY_V = 86;
  GLFW_KEY_W = 87;
  GLFW_KEY_X = 88;
  GLFW_KEY_Y = 89;
  GLFW_KEY_Z = 90;
  GLFW_KEY_LEFT_BRACKET = 91;
  GLFW_KEY_BACKSLASH = 92;
  GLFW_KEY_RIGHT_BRACKET = 93;
  GLFW_KEY_GRAVE_ACCENT = 96;
  GLFW_KEY_WORLD_1 = 161;
  GLFW_KEY_WORLD_2 = 162;

  GLFW_KEY_ESCAPE = 256;
  GLFW_KEY_ENTER = 257;
  GLFW_KEY_TAB = 258;
  GLFW_KEY_BACKSPACE = 259;
  GLFW_KEY_INSERT = 260;
  GLFW_KEY_DELETE = 261;
  GLFW_KEY_RIGHT = 262;
  GLFW_KEY_LEFT = 263;
  GLFW_KEY_DOWN = 264;
  GLFW_KEY_UP = 265;
  GLFW_KEY_PAGE_UP = 266;
  GLFW_KEY_PAGE_DOWN = 267;
  GLFW_KEY_HOME = 268;
  GLFW_KEY_END = 269;
  GLFW_KEY_CAPS_LOCK = 280;
  GLFW_KEY_SCROLL_LOCK = 281;
  GLFW_KEY_NUM_LOCK = 282;
  GLFW_KEY_PRINT_SCREEN = 283;
  GLFW_KEY_PAUSE = 284;
  GLFW_KEY_F1 = 290;
  GLFW_KEY_F2 = 291;
  GLFW_KEY_F3 = 292;
  GLFW_KEY_F4 = 293;
  GLFW_KEY_F5 = 294;
  GLFW_KEY_F6 = 295;
  GLFW_KEY_F7 = 296;
  GLFW_KEY_F8 = 297;
  GLFW_KEY_F9 = 298;
  GLFW_KEY_F10 = 299;
  GLFW_KEY_F11 = 300;
  GLFW_KEY_F12 = 301;
  GLFW_KEY_F13 = 302;
  GLFW_KEY_F14 = 303;
  GLFW_KEY_F15 = 304;
  GLFW_KEY_F16 = 305;
  GLFW_KEY_F17 = 306;
  GLFW_KEY_F18 = 307;
  GLFW_KEY_F19 = 308;
  GLFW_KEY_F20 = 309;
  GLFW_KEY_F21 = 310;
  GLFW_KEY_F22 = 311;
  GLFW_KEY_F23 = 312;
  GLFW_KEY_F24 = 313;
  GLFW_KEY_F25 = 314;
  GLFW_KEY_KP_0 = 320;
  GLFW_KEY_KP_1 = 321;
  GLFW_KEY_KP_2 = 322;
  GLFW_KEY_KP_3 = 323;
  GLFW_KEY_KP_4 = 324;
  GLFW_KEY_KP_5 = 325;
  GLFW_KEY_KP_6 = 326;
  GLFW_KEY_KP_7 = 327;
  GLFW_KEY_KP_8 = 328;
  GLFW_KEY_KP_9 = 329;
  GLFW_KEY_KP_DECIMAL = 330;
  GLFW_KEY_KP_DIVIDE = 331;
  GLFW_KEY_KP_MULTIPLY = 332;
  GLFW_KEY_KP_SUBTRACT = 333;
  GLFW_KEY_KP_ADD = 334;
  GLFW_KEY_KP_ENTER = 335;
  GLFW_KEY_KP_EQUAL = 336;
  GLFW_KEY_LEFT_SHIFT = 340;
  GLFW_KEY_LEFT_CONTROL = 341;
  GLFW_KEY_LEFT_ALT = 342;
  GLFW_KEY_LEFT_SUPER = 343;
  GLFW_KEY_RIGHT_SHIFT = 344;
  GLFW_KEY_RIGHT_CONTROL = 345;
  GLFW_KEY_RIGHT_ALT = 346;
  GLFW_KEY_RIGHT_SUPER = 347;
  GLFW_KEY_MENU = 348;

  GLFW_KEY_LAST = GLFW_KEY_MENU;

  GLFW_MOD_SHIFT = $0001;
  GLFW_MOD_CONTROL = $0002;
  GLFW_MOD_ALT = $0004;
  GLFW_MOD_CAPS_LOCK = $0010;
  GLFW_MOD_NUM_LOCK = $0020;

  GLFW_MOUSE_BUTTON_1 = 0;
  GLFW_MOUSE_BUTTON_2 = 1;
  GLFW_MOUSE_BUTTON_3 = 2;
  GLFW_MOUSE_BUTTON_4 = 3;
  GLFW_MOUSE_BUTTON_5 = 4;
  GLFW_MOUSE_BUTTON_6 = 5;
  GLFW_MOUSE_BUTTON_7 = 6;
  GLFW_MOUSE_BUTTON_8 = 7;
  GLFW_MOUSE_BUTTON_LAST = GLFW_MOUSE_BUTTON_8;
  GLFW_MOUSE_BUTTON_LEFT = GLFW_MOUSE_BUTTON_1;
  GLFW_MOUSE_BUTTON_RIGHT = GLFW_MOUSE_BUTTON_2;
  GLFW_MOUSE_BUTTON_MIDDLE = GLFW_MOUSE_BUTTON_3;

  GLFW_JOYSTICK_1 = 0;
  GLFW_JOYSTICK_2 = 1;
  GLFW_JOYSTICK_3 = 2;
  GLFW_JOYSTICK_4 = 3;
  GLFW_JOYSTICK_5 = 4;
  GLFW_JOYSTICK_6 = 5;
  GLFW_JOYSTICK_7 = 6;
  GLFW_JOYSTICK_8 = 7;
  GLFW_JOYSTICK_9 = 8;
  GLFW_JOYSTICK_10 = 9;
  GLFW_JOYSTICK_11 = 10;
  GLFW_JOYSTICK_12 = 11;
  GLFW_JOYSTICK_13 = 12;
  GLFW_JOYSTICK_14 = 13;
  GLFW_JOYSTICK_15 = 14;
  GLFW_JOYSTICK_16 = 15;
  GLFW_JOYSTICK_LAST = GLFW_JOYSTICK_16;

  GLFW_GAMEPAD_BUTTON_A = 0;
  GLFW_GAMEPAD_BUTTON_B = 1;
  GLFW_GAMEPAD_BUTTON_X = 2;
  GLFW_GAMEPAD_BUTTON_Y = 3;
  GLFW_GAMEPAD_BUTTON_LEFT_BUMPER = 4;
  GLFW_GAMEPAD_BUTTON_RIGHT_BUMPER = 5;
  GLFW_GAMEPAD_BUTTON_BACK = 6;
  GLFW_GAMEPAD_BUTTON_START = 7;
  GLFW_GAMEPAD_BUTTON_GUIDE = 8;
  GLFW_GAMEPAD_BUTTON_LEFT_THUMB = 9;
  GLFW_GAMEPAD_BUTTON_RIGHT_THUMB = 10;
  GLFW_GAMEPAD_BUTTON_DPAD_UP = 11;
  GLFW_GAMEPAD_BUTTON_DPAD_RIGHT = 12;
  GLFW_GAMEPAD_BUTTON_DPAD_DOWN = 13;
  GLFW_GAMEPAD_BUTTON_DPAD_LEFT = 14;
  GLFW_GAMEPAD_BUTTON_LAST = GLFW_GAMEPAD_BUTTON_DPAD_LEFT;

  GLFW_GAMEPAD_BUTTON_CROSS = GLFW_GAMEPAD_BUTTON_A;
  GLFW_GAMEPAD_BUTTON_CIRCLE = GLFW_GAMEPAD_BUTTON_B;
  GLFW_GAMEPAD_BUTTON_SQUARE = GLFW_GAMEPAD_BUTTON_X;
  GLFW_GAMEPAD_BUTTON_TRIANGLE = GLFW_GAMEPAD_BUTTON_Y;

  GLFW_GAMEPAD_AXIS_LEFT_X = 0;
  GLFW_GAMEPAD_AXIS_LEFT_Y = 1;
  GLFW_GAMEPAD_AXIS_RIGHT_X = 2;
  GLFW_GAMEPAD_AXIS_RIGHT_Y = 3;
  GLFW_GAMEPAD_AXIS_LEFT_TRIGGER = 4;
  GLFW_GAMEPAD_AXIS_RIGHT_TRIGGER = 5;
  GLFW_GAMEPAD_AXIS_LAST = GLFW_GAMEPAD_AXIS_RIGHT_TRIGGER;

  GLFW_NO_ERROR = 0;
  GLFW_NOT_INITIALIZED = $00010001;
  GLFW_NO_CURRENT_CONTEXT = $00010002;
  GLFW_INVALID_ENUM = $00010003;
  GLFW_INVALID_VALUE = $00010004;
  GLFW_OUT_OF_MEMORY = $00010005;
  GLFW_API_UNAVAILABLE = $00010006;
  GLFW_VERSION_UNAVAILABLE = $00010007;
  GLFW_PLATFORM_ERROR = $00010008;
  GLFW_FORMAT_UNAVAILABLE = $00010009;
  GLFW_NO_WINDOW_CONTEXT = $0001000A;
  GLFW_CURSOR_UNAVAILABLE = $0001000B;
  GLFW_FEATURE_UNAVAILABLE = $0001000C;
  GLFW_FEATURE_UNIMPLEMENTED = $0001000D;
  GLFW_PLATFORM_UNAVAILABLE = $0001000E;
  GLFW_FOCUSED = $00020001;

  GLFW_ICONIFIED = $00020002;
  GLFW_RESIZABLE = $00020003;
  GLFW_VISIBLE = $00020004;
  GLFW_DECORATED = $00020005;

  GLFW_AUTO_ICONIFY = $00020006;
  GLFW_FLOATING = $00020007;
  GLFW_MAXIMIZED = $00020008;
  GLFW_CENTER_CURSOR = $00020009;
  GLFW_TRANSPARENT_FRAMEBUFFER = $0002000A;
  GLFW_HOVERED = $0002000B;
  GLFW_FOCUS_ON_SHOW = $0002000C;
  GLFW_MOUSE_PASSTHROUGH = $0002000D;
  GLFW_POSITION_X = $0002000E;
  GLFW_POSITION_Y = $0002000F;
  GLFW_RED_BITS = $00021001;
  GLFW_GREEN_BITS = $00021002;
  GLFW_BLUE_BITS = $00021003;
  GLFW_ALPHA_BITS = $00021004;
  GLFW_DEPTH_BITS = $00021005;
  GLFW_STENCIL_BITS = $00021006;
  GLFW_ACCUM_RED_BITS = $00021007;
  GLFW_ACCUM_GREEN_BITS = $00021008;
  GLFW_ACCUM_BLUE_BITS = $00021009;
  GLFW_ACCUM_ALPHA_BITS = $0002100A;
  GLFW_AUX_BUFFERS = $0002100B;
  GLFW_STEREO = $0002100C;
  GLFW_SAMPLES = $0002100D;
  GLFW_SRGB_CAPABLE = $0002100E;
  GLFW_REFRESH_RATE = $0002100F;
  GLFW_DOUBLEBUFFER = $00021010;
  GLFW_CLIENT_API = $00022001;
  GLFW_CONTEXT_VERSION_MAJOR = $00022002;
  GLFW_CONTEXT_VERSION_MINOR = $00022003;
  GLFW_CONTEXT_REVISION = $00022004;
  GLFW_CONTEXT_ROBUSTNESS = $00022005;
  GLFW_OPENGL_FORWARD_COMPAT = $00022006;
  GLFW_CONTEXT_DEBUG = $00022007;

  GLFW_OPENGL_DEBUG_CONTEXT = GLFW_CONTEXT_DEBUG;
  GLFW_OPENGL_PROFILE = $00022008;
  GLFW_CONTEXT_RELEASE_BEHAVIOR = $00022009;
  GLFW_CONTEXT_NO_ERROR = $0002200A;
  GLFW_CONTEXT_CREATION_API = $0002200B;
  GLFW_SCALE_TO_MONITOR = $0002200C;
  GLFW_SCALE_FRAMEBUFFER = $0002200D;
  GLFW_COCOA_RETINA_FRAMEBUFFER = $00023001;
  GLFW_COCOA_FRAME_NAME = $00023002;
  GLFW_COCOA_GRAPHICS_SWITCHING = $00023003;
  GLFW_X11_CLASS_NAME = $00024001;
  GLFW_X11_INSTANCE_NAME = $00024002;
  GLFW_WIN32_KEYBOARD_MENU = $00025001;
  GLFW_WIN32_SHOWDEFAULT = $00025002;
  GLFW_WAYLAND_APP_ID = $00026001;
  GLFW_NO_API = 0;
  GLFW_OPENGL_API = $00030001;
  GLFW_OPENGL_ES_API = $00030002;

  GLFW_NO_ROBUSTNESS = 0;
  GLFW_NO_RESET_NOTIFICATION = $00031001;
  GLFW_LOSE_CONTEXT_ON_RESET = $00031002;

  GLFW_OPENGL_ANY_PROFILE = 0;
  GLFW_OPENGL_CORE_PROFILE = $00032001;
  GLFW_OPENGL_COMPAT_PROFILE = $00032002;

  GLFW_CURSOR = $00033001;
  GLFW_STICKY_KEYS = $00033002;
  GLFW_STICKY_MOUSE_BUTTONS = $00033003;
  GLFW_LOCK_KEY_MODS = $00033004;
  GLFW_RAW_MOUSE_MOTION = $00033005;

  GLFW_CURSOR_NORMAL = $00034001;
  GLFW_CURSOR_HIDDEN = $00034002;
  GLFW_CURSOR_DISABLED = $00034003;
  GLFW_CURSOR_CAPTURED = $00034004;

  GLFW_ANY_RELEASE_BEHAVIOR = 0;
  GLFW_RELEASE_BEHAVIOR_FLUSH = $00035001;
  GLFW_RELEASE_BEHAVIOR_NONE = $00035002;

  GLFW_NATIVE_CONTEXT_API = $00036001;
  GLFW_EGL_CONTEXT_API = $00036002;
  GLFW_OSMESA_CONTEXT_API = $00036003;

  GLFW_ANGLE_PLATFORM_TYPE_NONE = $00037001;
  GLFW_ANGLE_PLATFORM_TYPE_OPENGL = $00037002;
  GLFW_ANGLE_PLATFORM_TYPE_OPENGLES = $00037003;
  GLFW_ANGLE_PLATFORM_TYPE_D3D9 = $00037004;
  GLFW_ANGLE_PLATFORM_TYPE_D3D11 = $00037005;
  GLFW_ANGLE_PLATFORM_TYPE_VULKAN = $00037007;
  GLFW_ANGLE_PLATFORM_TYPE_METAL = $00037008;

  GLFW_WAYLAND_PREFER_LIBDECOR = $00038001;
  GLFW_WAYLAND_DISABLE_LIBDECOR = $00038002;

  GLFW_ANY_POSITION = $80000000;

  GLFW_ARROW_CURSOR = $00036001;
  GLFW_IBEAM_CURSOR = $00036002;
  GLFW_CROSSHAIR_CURSOR = $00036003;
  GLFW_POINTING_HAND_CURSOR = $00036004;
  GLFW_RESIZE_EW_CURSOR = $00036005;
  GLFW_RESIZE_NS_CURSOR = $00036006;
  GLFW_RESIZE_NWSE_CURSOR = $00036007;
  GLFW_RESIZE_NESW_CURSOR = $00036008;
  GLFW_RESIZE_ALL_CURSOR = $00036009;
  GLFW_NOT_ALLOWED_CURSOR = $0003600A;
  GLFW_HRESIZE_CURSOR = GLFW_RESIZE_EW_CURSOR;
  GLFW_VRESIZE_CURSOR = GLFW_RESIZE_NS_CURSOR;
  GLFW_HAND_CURSOR = GLFW_POINTING_HAND_CURSOR;
  GLFW_CONNECTED = $00040001;
  GLFW_DISCONNECTED = $00040002;
  GLFW_JOYSTICK_HAT_BUTTONS = $00050001;
  GLFW_ANGLE_PLATFORM_TYPE = $00050002;
  GLFW_PLATFORM = $00050003;
  GLFW_COCOA_CHDIR_RESOURCES = $00051001;
  GLFW_COCOA_MENUBAR = $00051002;
  GLFW_X11_XCB_VULKAN_SURFACE = $00052001;
  GLFW_WAYLAND_LIBDECOR = $00053001;
  GLFW_ANY_PLATFORM = $00060000;
  GLFW_PLATFORM_WIN32 = $00060001;
  GLFW_PLATFORM_COCOA = $00060002;
  GLFW_PLATFORM_WAYLAND = $00060003;
  GLFW_PLATFORM_X11 = $00060004;
  GLFW_PLATFORM_NULL = $00060005;

  GLFW_DONT_CARE = -1;

type
  TGLFWGLProc = procedure(); cdecl;
  TGLFWVKProc = procedure(); cdecl;

  PGLFWMonitor = Pointer;
  PPGLFWMonitor = ^PGLFWMonitor;

  PGLFWWindow = Pointer;
  PPGLFWWindow = ^PGLFWWindow;

  PGLFWCursor = Pointer;
  PPGLFWCursor = ^PGLFWCursor;

  {$IFDEF GLFW3_LASTEST}
  TGLFWallocatefun = procedure(size: cSize_t; user: Pointer); cdecl;
  TGLFWreallocatefun = procedure (block: Pointer; size: cSize_t; user: Pointer); cdecl;
  TGLFWdeallocatefun = procedure(block: Pointer; size: cSize_t; user: Pointer); cdecl;
  {$ENDIF}

  TGLFWErrorfun = procedure(error_code: integer; const description: pchar); cdecl;
  TGLFWWindowposfun = procedure(window: PGLFWwindow; xpos, ypos: integer); cdecl;
  TGLFWWindowsizefun = procedure(window: PGLFWwindow; Width, Height: integer); cdecl;
  TGLFWWindowclosefun = procedure(window: PGLFWwindow); cdecl;
  TGLFWWindowrefreshfun = procedure(window: PGLFWwindow); cdecl;
  TGLFWWindowfocusfun = procedure(window: PGLFWwindow; focused: integer); cdecl;
  TGLFWWindowiconifyfun = procedure(window: PGLFWwindow; iconified: integer); cdecl;
  TGLFWWindowmaximizefun = procedure(window: PGLFWwindow; maximized: integer); cdecl;
  TGLFWFramebuffersizefun = procedure(window: PGLFWwindow; Width, Height: integer); cdecl;
  TGLFWWindowcontentscalefun = procedure(window: PGLFWwindow; xscale, yscale: single); cdecl;
  TGLFWMousebuttonfun = procedure(window: PGLFWwindow; button, action, mods: integer); cdecl;
  TGLFWCursorposfun = procedure(window: PGLFWwindow; xpos, ypos: double); cdecl;
  TGLFWCursorenterfun = procedure(window: PGLFWwindow; entered: integer); cdecl;
  TGLFWScrollfun = procedure(window: PGLFWwindow; xoffset, yoffset: double); cdecl;
  TGLFWKeyfun = procedure(window: PGLFWwindow; key, scancode, action, mods: integer); cdecl;
  TGLFWCharfun = procedure(window: PGLFWwindow; codepoint: cardinal); cdecl;
  TGLFWCharmodsfun = procedure(window: PGLFWwindow; codepoint: cardinal; mods: integer); cdecl;
  TGLFWDropfun = procedure(window: PGLFWwindow; path_count: integer; const paths: PPChar); cdecl;
  TGLFWMonitorfun = procedure(monitor: PGLFWmonitor; event: integer); cdecl;
  TGLFWJoystickfun = procedure(joy, event: integer); cdecl;

  TGLFWVidMode = record
    Width: integer;
    Height: integer;
    redBits: integer;
    greenBits: integer;
    blueBits: integer;
    refreshRate: integer;
  end;
  PGLFWVidMode = ^TGLFWVidMode;
  PPGLFWVidMode = ^PGLFWVidMode;

  TGLFWgammaramp = record
    red: PWord;
    green: PWord;
    blue: PWord;
    size: cardinal;
  end;
  PGLFWgammaramp = ^TGLFWgammaramp;
  PPGLFWgammaramp = ^PGLFWgammaramp;

  TGLFWimage = record
    Width: integer;
    Height: integer;
    pixels: pbyte;
  end;
  PGLFWimage = ^TGLFWimage;
  PPGLFWimage = ^PGLFWimage;

  TGLFWgamepadstate = record
    Buttons: array[0..14] of byte;
    axes: array[0..5] of single;
  end;
  PGLFWgamepadstate = ^TGLFWgamepadstate;
  PPGLFWgamepadstate = ^PGLFWgamepadstate;

  {$IFDEF GLFW3_LASTEST}
  TGLFWallocator = record
    allocate: TGLFWallocatefun;
    reallocate: TGLFWreallocatefun;
    deallocate: TGLFWdeallocatefun;
    user: Pointer;
  end;
  PGLFWallocator = ^TGLFWallocator;
  PPGLFWallocator = PGLFWallocator;
  {$ENDIF}

  IGLFW = interface
    ['{FDD9B942-1A20-43AA-B654-05D9A58F0214}']
    function glfwInit(): integer;
    procedure glfwTerminate();
    procedure glfwInitHint(hint, Value: integer);
    {$IFDEF GLFW3_LASTEST}
procedure glfwInitAllocator(allocator: PGLFWallocator);
{$IFDEF VK_VERSION_1_0}
procedure glfwInitVulkanLoader(loader: TGLFWVKProc);
{$ENDIF} {$ENDIF}
    procedure glfwGetVersion(major, minor, rev: PInteger);
    function glfwGetVersionString(): pchar;
    function glfwGetError(description: pchar): integer;
    function glfwSetErrorCallback(callback: TGLFWerrorfun): TGLFWerrorfun;
    {$IFDEF GLFW3_LASTEST}
function glfwGetPlatform(): Integer;
function glfwPlatformSupported(platform: Integer): Integer;
    {$ENDIF}
    function glfwGetMonitors(out Count: integer): PPGLFWmonitor;
    function glfwGetPrimaryMonitor(): PGLFWmonitor;
    procedure glfwGetMonitorPos(monitor: PGLFWmonitor; xpos, ypos: PInteger);
    procedure glfwGetMonitorWorkarea(monitor: PGLFWmonitor; xpos, ypos, Width, Height: PInteger);
    procedure glfwGetMonitorPhysicalSize(monitor: PGLFWmonitor; widthMM, heightMM: PInteger);
    procedure glfwGetMonitorContentScale(monitor: PGLFWmonitor; xscale, yscale: PSingle);
    function glfwGetMonitorName(monitor: PGLFWmonitor): pchar;
    procedure glfwSetMonitorUserPointer(monitor: PGLFWmonitor; user: Pointer);
    function glfwGetMonitorUserPointer(monitor: PGLFWmonitor): pointer;
    function glfwSetMonitorCallback(callback: TGLFWmonitorfun): TGLFWmonitorfun;
    function glfwGetVideoModes(monitor: PGLFWmonitor; var Count: integer): PGLFWvidmode;
    function glfwGetVideoMode(monitor: PGLFWmonitor): PGLFWvidmode;
    procedure glfwSetGamma(monitor: PGLFWmonitor; gamma: single);
    function glfwGetGammaRamp(monitor: PGLFWmonitor): PGLFWgammaramp;
    procedure glfwSetGammaRamp(monitor: PGLFWmonitor; const ramp: PGLFWgammaramp);
    procedure glfwDefaultWindowHints();
    procedure glfwWindowHint(hint, Value: integer);
    procedure glfwWindowHintString(hint: integer; Value: pchar);
    function glfwCreateWindow(Width, Height: integer; const title: pchar; monitor: PGLFWmonitor; share: PGLFWwindow): PGLFWwindow;
    procedure glfwDestroyWindow(window: PGLFWwindow);
    function glfwWindowShouldClose(window: PGLFWwindow): integer;
    procedure glfwSetWindowShouldClose(window: PGLFWwindow; Value: integer);
    {$IFDEF GLFW3_LASTEST}
function glfwGetWindowTitle(window: PGLFWwindow): PChar;
    {$ENDIF}
    procedure glfwSetWindowTitle(window: PGLFWwindow; const title: pchar);
    procedure glfwSetWindowIcon(window: PGLFWwindow; Count: integer; const images: PGLFWimage);
    procedure glfwGetWindowPos(window: PGLFWwindow; xpos, ypos: PInteger);
    procedure glfwSetWindowPos(window: PGLFWwindow; xpos, ypos: integer);
    procedure glfwGetWindowSize(window: PGLFWwindow; Width, Height: PInteger);
    procedure glfwSetWindowSizeLimits(window: PGLFWwindow; minwidth, minheight, maxwidth, maxheight: integer);
    procedure glfwSetWindowAspectRatio(window: PGLFWwindow; numer, denom: integer);
    procedure glfwSetWindowSize(window: PGLFWwindow; Width, Height: integer);
    procedure glfwGetFramebufferSize(window: PGLFWwindow; Width, Height: PInteger);
    procedure glfwGetWindowFrameSize(window: PGLFWwindow; left, top, right, bottom: PInteger);
    procedure glfwGetWindowContentScale(window: PGLFWwindow; xscale, yscale: PSingle);
    function glfwGetWindowOpacity(window: PGLFWwindow): single;
    procedure glfwSetWindowOpacity(window: PGLFWwindow; opacity: single);
    procedure glfwIconifyWindow(window: PGLFWwindow);
    procedure glfwRestoreWindow(window: PGLFWwindow);
    procedure glfwMaximizeWindow(window: PGLFWwindow);
    procedure glfwShowWindow(window: PGLFWwindow);
    procedure glfwHideWindow(window: PGLFWwindow);
    procedure glfwFocusWindow(window: PGLFWwindow);
    procedure glfwRequestWindowAttention(window: PGLFWwindow);
    function glfwGetWindowMonitor(window: PGLFWwindow): PGLFWmonitor;
    procedure glfwSetWindowMonitor(window: PGLFWwindow; monitor: PGLFWmonitor; xpos, ypos, Width, Height, refreshRate: integer);
    function glfwGetWindowAttrib(window: PGLFWwindow; attrib: integer): integer;
    procedure glfwSetWindowAttrib(window: PGLFWwindow; attrib, Value: integer);
    procedure glfwSetWindowUserPointer(window: PGLFWwindow; userpointer: Pointer);
    function glfwGetWindowUserPointer(window: PGLFWwindow): Pointer;
    function glfwSetWindowPosCallback(window: PGLFWwindow; callback: TGLFWwindowposfun): TGLFWwindowposfun;
    function glfwSetWindowSizeCallback(window: PGLFWwindow; callback: TGLFWwindowsizefun): TGLFWwindowsizefun;
    function glfwSetWindowCloseCallback(window: PGLFWwindow; callback: TGLFWwindowclosefun): TGLFWwindowclosefun;
    function glfwSetWindowRefreshCallback(window: PGLFWwindow; callback: TGLFWwindowrefreshfun): TGLFWwindowrefreshfun;
    function glfwSetWindowFocusCallback(window: PGLFWwindow; callback: TGLFWwindowfocusfun): TGLFWwindowfocusfun;
    function glfwSetWindowIconifyCallback(window: PGLFWwindow; callback: TGLFWwindowiconifyfun): TGLFWwindowiconifyfun;
    function glfwSetWindowMaximizeCallback(window: PGLFWwindow; callback: TGLFWwindowmaximizefun): TGLFWwindowmaximizefun;
    function glfwSetFramebufferSizeCallback(window: PGLFWwindow; callback: TGLFWframebuffersizefun): TGLFWframebuffersizefun;
    function glfwSetWindowContentScaleCallback(window: PGLFWwindow; callback: TGLFWwindowcontentscalefun): TGLFWwindowcontentscalefun;
    procedure glfwPollEvents();
    procedure glfwWaitEvents();
    procedure glfwWaitEventsTimeout(timeout: double);
    procedure glfwPostEmptyEvent();
    function glfwGetInputMode(window: PGLFWwindow; mode: integer): integer;
    procedure glfwSetInputMode(window: PGLFWwindow; mode, Value: integer);
    function glfwRawMouseMotionSupported(): integer;
    function glfwGetKeyName(key, scancode: integer): pchar;
    function glfwGetKeyScancode(key: integer): integer;
    function glfwGetKey(window: PGLFWwindow; key: integer): integer;
    function glfwGetMouseButton(window: PGLFWwindow; button: integer): integer;
    procedure glfwGetCursorPos(window: PGLFWwindow; xpos, ypos: PDouble);
    procedure glfwSetCursorPos(window: PGLFWwindow; xpos, ypos: double);
    function glfwCreateCursor(const image: PGLFWimage; xhot, yhot: integer): PGLFWcursor;
    function glfwCreateStandardCursor(shape: integer): PGLFWcursor;
    procedure glfwDestroyCursor(cursor: PGLFWcursor);
    procedure glfwSetCursor(window: PGLFWwindow; cursor: PGLFWcursor);
    function glfwSetKeyCallback(window: PGLFWwindow; callback: TGLFWkeyfun): TGLFWkeyfun;
    function glfwSetCharCallback(window: PGLFWwindow; callback: TGLFWcharfun): TGLFWcharfun;
    function glfwSetCharModsCallback(window: PGLFWwindow; callback: TGLFWcharmodsfun): TGLFWcharmodsfun;
    function glfwSetMouseButtonCallback(window: PGLFWwindow; callback: TGLFWmousebuttonfun): TGLFWmousebuttonfun;
    function glfwSetCursorPosCallback(window: PGLFWwindow; callback: TGLFWcursorposfun): TGLFWcursorposfun;
    function glfwSetCursorEnterCallback(window: PGLFWwindow; callback: TGLFWcursorenterfun): TGLFWcursorenterfun;
    function glfwSetScrollCallback(window: PGLFWwindow; callback: TGLFWscrollfun): TGLFWscrollfun;
    function glfwSetDropCallback(window: PGLFWwindow; callback: TGLFWdropfun): TGLFWdropfun;
    function glfwJoystickPresent(jId: integer): integer;
    function glfwGetJoystickAxes(jId: integer; Count: PInteger): PSingle;
    function glfwGetJoystickButtons(jId: integer; Count: PInteger): pbyte;
    function glfwGetJoystickHats(jId: integer; Count: PInteger): pbyte;
    function glfwGetJoystickName(jId: integer): pchar;
    function glfwGetJoystickGUID(jId: integer): pchar;
    procedure glfwSetJoystickUserPointer(jId: integer; userPointer: Pointer);
    function glfwGetJoystickUserPointer(jId: integer): Pointer;
    function glfwJoystickIsGamepad(jId: integer): integer;
    function glfwSetJoystickCallback(callback: TGLFWjoystickfun): TGLFWjoystickfun;
    function glfwUpdateGamepadMappings(const string_: pchar): integer;
    function glfwGetGamepadName(jId: integer): pchar;
    function glfwGetGamepadState(jId: integer; state: PGLFWgamepadstate): integer;
    procedure glfwSetClipboardString(window: PGLFWwindow; const Text: pchar);
    function glfwGetClipboardString(window: PGLFWwindow): pchar;
    function glfwGetTime(): double;
    procedure glfwSetTime(time: double);
    function glfwGetTimerValue(): uint64;
    function glfwGetTimerFrequency(): uint64;
    procedure glfwMakeContextCurrent(window: PGLFWwindow);
    function glfwGetCurrentContext(): PGLFWwindow;
    procedure glfwSwapBuffers(window: PGLFWwindow);
    procedure glfwSwapInterval(interval: integer);
    function glfwExtensionSupported(const extension: pchar): integer;
    function glfwGetProcAddress(const procname: pchar): TGLFWGLProc;
    function glfwVulkanSupported(): integer;
    function glfwGetRequiredInstanceExtensions(var Count: uint32): ppchar;
    {$IFDEF VK_VERSION_1_0}
function glfwGetInstanceProcAddress(instance: VkInstance; const procname: PChar): TGLFWVKProc;
function glfwGetPhysicalDevicePresentationSupport(instance: VkInstance; device: VkPhysicalDevice; queuefamily: Cardinal): Integer;
function glfwCreateWindowSurface(instance: VkInstance; window: PGLFWwindow; const allocator: PVkAllocationCallbacks; surface: PVkSurfaceKHR): TVkResult;
    {$ENDIF}
  end;


function getGLFW: IGLFW;

implementation

var
  singleton: IGLFW;

type
  // ===================================================================
  // CORE - Inizializzazione, versione, errori
  // ===================================================================
  TGLFWInit = function: integer; cdecl;
  TGLFWTerminate = procedure; cdecl;
  TGLFWInitHint = procedure(hint: integer; Value: integer); cdecl;
  TGLFWDefaultWindowHints = procedure; cdecl;
  TGLFWGetVersion = procedure(major, minor, rev: PInteger); cdecl;
  TGLFWGetVersionString = function: pchar; cdecl;
  TGLFWGetError = function(description: pchar): integer; cdecl;
  TGLFWSetErrorCallback = function(callback: TGLFWerrorfun): TGLFWerrorfun; cdecl;

  // ===================================================================
  // WINDOW HINTS
  // ===================================================================
  TGLFWWindowHint = procedure(hint: integer; Value: integer); cdecl;
  TGLFWWindowHintString = procedure(hint: integer; Value: pchar); cdecl;

  // ===================================================================
  // WINDOW CREATION & DESTRUCTION
  // ===================================================================
  TGLFWCreateWindow = function(Width, Height: integer; const title: pchar; monitor: PGLFWmonitor; share: PGLFWwindow): PGLFWwindow; cdecl;
  TGLFWDestroyWindow = procedure(window: PGLFWwindow); cdecl;
  TGLFWWindowShouldClose = function(window: PGLFWwindow): integer; cdecl;
  TGLFWSetWindowShouldClose = procedure(window: PGLFWwindow; Value: integer); cdecl;

  // ===================================================================
  // WINDOW - Title & Icon
  // ===================================================================
  TGLFWSetWindowTitle = procedure(window: PGLFWwindow; title: pchar); cdecl;
  TGLFWSetWindowIcon = procedure(window: PGLFWwindow; Count: integer; images: PGLFWimage); cdecl;

  // ===================================================================
  // WINDOW - Position & Size
  // ===================================================================
  TGLFWGetWindowPos = procedure(window: PGLFWwindow; xpos, ypos: PInteger); cdecl;
  TGLFWSetWindowPos = procedure(window: PGLFWwindow; xpos, ypos: integer); cdecl;
  TGLFWGetWindowSize = procedure(window: PGLFWwindow; Width, Height: PInteger); cdecl;
  TGLFWSetWindowSize = procedure(window: PGLFWwindow; Width, Height: integer); cdecl;
  TGLFWSetWindowSizeLimits = procedure(window: PGLFWwindow; minw, minh, maxw, maxh: integer); cdecl;
  TGLFWSetWindowAspectRatio = procedure(window: PGLFWwindow; numer, denom: integer); cdecl;

  // ===================================================================
  // WINDOW - Framebuffer & Scaling
  // ===================================================================
  TGLFWGetFramebufferSize = procedure(window: PGLFWwindow; Width, Height: PInteger); cdecl;
  TGLFWGetWindowFrameSize = procedure(window: PGLFWwindow; left, top, right, bottom: PInteger); cdecl;
  TGLFWGetWindowContentScale = procedure(window: PGLFWwindow; xscale, yscale: PSingle); cdecl;
  TGLFWGetWindowOpacity = function(window: PGLFWwindow): single; cdecl;
  TGLFWSetWindowOpacity = procedure(window: PGLFWwindow; opacity: single); cdecl;

  // ===================================================================
  // WINDOW - State
  // ===================================================================
  TGLFWIconifyWindow = procedure(window: PGLFWwindow); cdecl;
  TGLFWRestoreWindow = procedure(window: PGLFWwindow); cdecl;
  TGLFWMaximizeWindow = procedure(window: PGLFWwindow); cdecl;
  TGLFWShowWindow = procedure(window: PGLFWwindow); cdecl;
  TGLFWHideWindow = procedure(window: PGLFWwindow); cdecl;
  TGLFWFocusWindow = procedure(window: PGLFWwindow); cdecl;
  TGLFWRequestWindowAttention = procedure(window: PGLFWwindow); cdecl;
  TGLFWGetWindowMonitor = function(window: PGLFWwindow): PGLFWmonitor; cdecl;
  TGLFWSetWindowMonitor = procedure(window: PGLFWwindow; monitor: PGLFWmonitor; xpos, ypos, Width, Height, refreshRate: integer); cdecl;

  // ===================================================================
  // WINDOW - Attributes
  // ===================================================================
  TGLFWGetWindowAttrib = function(window: PGLFWwindow; attrib: integer): integer; cdecl;
  TGLFWSetWindowAttrib = procedure(window: PGLFWwindow; attrib, Value: integer); cdecl;
  TGLFWSetWindowUserPointer = procedure(window: PGLFWwindow; pointer: Pointer); cdecl;
  TGLFWGetWindowUserPointer = function(window: PGLFWwindow): Pointer; cdecl;

  // ===================================================================
  // WINDOW - Callbacks
  // ===================================================================
  TGLFWSetWindowPosCallback = function(window: PGLFWwindow; callback: TGLFWwindowposfun): TGLFWwindowposfun; cdecl;
  TGLFWSetWindowSizeCallback = function(window: PGLFWwindow; callback: TGLFWwindowsizefun): TGLFWwindowsizefun; cdecl;
  TGLFWSetWindowCloseCallback = function(window: PGLFWwindow; callback: TGLFWwindowclosefun): TGLFWwindowclosefun; cdecl;
  TGLFWSetWindowRefreshCallback = function(window: PGLFWwindow; callback: TGLFWwindowrefreshfun): TGLFWwindowrefreshfun; cdecl;
  TGLFWSetWindowFocusCallback = function(window: PGLFWwindow; callback: TGLFWwindowfocusfun): TGLFWwindowfocusfun; cdecl;
  TGLFWSetWindowIconifyCallback = function(window: PGLFWwindow; callback: TGLFWwindowiconifyfun): TGLFWwindowiconifyfun; cdecl;
  TGLFWSetWindowMaximizeCallback = function(window: PGLFWwindow; callback: TGLFWwindowmaximizefun): TGLFWwindowmaximizefun; cdecl;
  TGLFWSetFramebufferSizeCallback = function(window: PGLFWwindow; callback: TGLFWframebuffersizefun): TGLFWframebuffersizefun; cdecl;
  TGLFWSetWindowContentScaleCallback = function(window: PGLFWwindow; callback: TGLFWwindowcontentscalefun): TGLFWwindowcontentscalefun; cdecl;

  // ===================================================================
  // EVENTS
  // ===================================================================
  TGLFWPollEvents = procedure; cdecl;
  TGLFWWaitEvents = procedure; cdecl;
  TGLFWWaitEventsTimeout = procedure(timeout: double); cdecl;
  TGLFWPostEmptyEvent = procedure; cdecl;

  // ===================================================================
  // INPUT - Mode & Raw
  // ===================================================================
  TGLFWGetInputMode = function(window: PGLFWwindow; mode: integer): integer; cdecl;
  TGLFWSetInputMode = procedure(window: PGLFWwindow; mode, Value: integer); cdecl;
  TGLFWRawMouseMotionSupported = function: integer; cdecl;

  // ===================================================================
  // INPUT - Keyboard & Mouse
  // ===================================================================
  TGLFWGetKey = function(window: PGLFWwindow; key: integer): integer; cdecl;
  TGLFWGetMouseButton = function(window: PGLFWwindow; button: integer): integer; cdecl;
  TGLFWGetCursorPos = procedure(window: PGLFWwindow; xpos, ypos: PDouble); cdecl;
  TGLFWSetCursorPos = procedure(window: PGLFWwindow; xpos, ypos: double); cdecl;
  TGLFWGetKeyName = function(key, scancode: integer): pchar; cdecl;
  TGLFWGetKeyScancode = function(key: integer): integer; cdecl;

  // ===================================================================
  // CURSOR
  // ===================================================================
  TGLFWCreateCursor = function(const image: PGLFWimage; xhot, yhot: integer): PGLFWcursor; cdecl;
  TGLFWCreateStandardCursor = function(shape: integer): PGLFWcursor; cdecl;
  TGLFWDestroyCursor = procedure(cursor: PGLFWcursor); cdecl;
  TGLFWSetCursor = procedure(window: PGLFWwindow; cursor: PGLFWcursor); cdecl;

  // ===================================================================
  // INPUT CALLBACKS
  // ===================================================================
  TGLFWSetKeyCallback = function(window: PGLFWwindow; callback: TGLFWkeyfun): TGLFWkeyfun; cdecl;
  TGLFWSetCharCallback = function(window: PGLFWwindow; callback: TGLFWcharfun): TGLFWcharfun; cdecl;
  TGLFWSetCharModsCallback = function(window: PGLFWwindow; callback: TGLFWcharmodsfun): TGLFWcharmodsfun; cdecl;
  TGLFWSetMouseButtonCallback = function(window: PGLFWwindow; callback: TGLFWmousebuttonfun): TGLFWmousebuttonfun; cdecl;
  TGLFWSetCursorPosCallback = function(window: PGLFWwindow; callback: TGLFWcursorposfun): TGLFWcursorposfun; cdecl;
  TGLFWSetCursorEnterCallback = function(window: PGLFWwindow; callback: TGLFWcursorenterfun): TGLFWcursorenterfun; cdecl;
  TGLFWSetScrollCallback = function(window: PGLFWwindow; callback: TGLFWscrollfun): TGLFWscrollfun; cdecl;
  TGLFWSetDropCallback = function(window: PGLFWwindow; callback: TGLFWdropfun): TGLFWdropfun; cdecl;

  // ===================================================================
  // MONITOR
  // ===================================================================
  TGLFWGetMonitors = function(Count: PInteger): PPGLFWmonitor; cdecl;
  TGLFWGetPrimaryMonitor = function: PGLFWmonitor; cdecl;
  TGLFWGetMonitorPos = procedure(monitor: PGLFWmonitor; xpos, ypos: PInteger); cdecl;
  TGLFWGetMonitorWorkarea = procedure(monitor: PGLFWmonitor; xpos, ypos, Width, Height: PInteger); cdecl;
  TGLFWGetMonitorPhysicalSize = procedure(monitor: PGLFWmonitor; widthMM, heightMM: PInteger); cdecl;
  TGLFWGetMonitorContentScale = procedure(monitor: PGLFWmonitor; xscale, yscale: PSingle); cdecl;
  TGLFWGetMonitorName = function(monitor: PGLFWmonitor): pchar; cdecl;
  TGLFWSetMonitorUserPointer = procedure(monitor: PGLFWmonitor; pointer: Pointer); cdecl;
  TGLFWGetMonitorUserPointer = function(monitor: PGLFWmonitor): Pointer; cdecl;
  TGLFWSetMonitorCallback = function(callback: TGLFWmonitorfun): TGLFWmonitorfun; cdecl;
  TGLFWGetVideoModes = function(monitor: PGLFWmonitor; var Count: integer): PGLFWvidmode; cdecl;
  TGLFWGetVideoMode = function(monitor: PGLFWmonitor): PGLFWvidmode; cdecl;
  TGLFWSetGamma = procedure(monitor: PGLFWmonitor; gamma: single); cdecl;
  TGLFWGetGammaRamp = function(monitor: PGLFWmonitor): PGLFWgammaramp; cdecl;
  TGLFWSetGammaRamp = procedure(monitor: PGLFWmonitor; const ramp: PGLFWgammaramp); cdecl;

  // ===================================================================
  // JOYSTICK / GAMEPAD
  // ===================================================================
  TGLFWJoystickPresent = function(jid: integer): integer; cdecl;
  TGLFWGetJoystickAxes = function(jid: integer; Count: PInteger): PSingle; cdecl;
  TGLFWGetJoystickButtons = function(jid: integer; Count: PInteger): pbyte; cdecl;
  TGLFWGetJoystickHats = function(jid: integer; Count: PInteger): pbyte; cdecl;
  TGLFWGetJoystickName = function(jid: integer): pchar; cdecl;
  TGLFWGetJoystickGUID = function(jid: integer): pchar; cdecl;
  TGLFWSetJoystickUserPointer = procedure(jid: integer; pointer: Pointer); cdecl;
  TGLFWGetJoystickUserPointer = function(jid: integer): Pointer; cdecl;
  TGLFWJoystickIsGamepad = function(jid: integer): integer; cdecl;
  TGLFWSetJoystickCallback = function(callback: TGLFWjoystickfun): TGLFWjoystickfun; cdecl;
  TGLFWUpdateGamepadMappings = function(str: pchar): integer; cdecl;
  TGLFWGetGamepadName = function(jid: integer): pchar; cdecl;
  TGLFWGetGamepadState = function(jid: integer; state: PGLFWgamepadstate): integer; cdecl;

  // ===================================================================
  // CLIPBOARD
  // ===================================================================
  TGLFWSetClipboardString = procedure(window: PGLFWwindow; str: pchar); cdecl;
  TGLFWGetClipboardString = function(window: PGLFWwindow): pchar; cdecl;

  // ===================================================================
  // TIMER
  // ===================================================================
  TGLFWGetTime = function: double; cdecl;
  TGLFWSetTime = procedure(time: double); cdecl;
  TGLFWGetTimerValue = function: uint64; cdecl;
  TGLFWGetTimerFrequency = function: uint64; cdecl;

  // ===================================================================
  // CONTEXT
  // ===================================================================
  TGLFWMakeContextCurrent = procedure(window: PGLFWwindow); cdecl;
  TGLFWGetCurrentContext = function: PGLFWwindow; cdecl;
  TGLFWSwapBuffers = procedure(window: PGLFWwindow); cdecl;
  TGLFWSwapInterval = procedure(interval: integer); cdecl;

  // ===================================================================
  // EXTENSIONS
  // ===================================================================
  TGLFWExtensionSupported = function(const extension: pchar): integer; cdecl;
  TGLFWGetProcAddress = function(const procname: pchar): TGLFWGLProc; cdecl;

  // ===================================================================
  // VULKAN
  // ===================================================================
  TGLFWVulkanSupported = function: integer; cdecl;
  TGLFWGetRequiredInstanceExtensions = function(var Count: cardinal): ppchar; cdecl;

  {$IFDEF VK_VERSION_1_0}
    TGLFWGetInstanceProcAddress = function(instance: VkInstance; const procname: pchar): TGLFWVKProc; cdecl;
    TGLFWGetPhysicalDevicePresentationSupport = function(instance: VkInstance; device: VkPhysicalDevice; queuefamily: Cardinal): Integer; cdecl;
    TGLFWCreateWindowSurface = function(instance: VkInstance; window: PGLFWwindow; const allocator: PVkAllocationCallbacks; surface: PVkSurfaceKHR): TVkResult; cdecl;
  {$ENDIF}

  // ===================================================================
  // GLFW 3.4+ (solo se definito GLFW3_LASTEST)
  // ===================================================================
  {$IFDEF GLFW3_LASTEST}
    TGLFWInitAllocator = procedure(allocator: PGLFWallocator); cdecl;
    TGLFWInitVulkanLoader = procedure(loader: TGLFWVKProc); cdecl;
    TGLFWGetPlatform = function: Integer; cdecl;
    TGLFWPlatformSupported = function(platform: Integer): Integer; cdecl;
    TGLFWGetWindowTitle = function(window: PGLFWwindow): pchar; cdecl;
  {$ENDIF}

type
  { TGLFW }

  TGLFW = class(TInterfacedObject, IGLFW)
  protected
    // ===================================================================
    // CORE - Inizializzazione, versione, errori
    // ===================================================================
    FGLFWInit: TGLFWInit;
    FGLFWTerminate: TGLFWTerminate;
    FGLFWInitHint: TGLFWInitHint;
    FGLFWDefaultWindowHints: TGLFWDefaultWindowHints;
    FGLFWGetVersion: TGLFWGetVersion;
    FGLFWGetVersionString: TGLFWGetVersionString;
    FGLFWGetError: TGLFWGetError;
    FGLFWSetErrorCallback: TGLFWSetErrorCallback;

    // ===================================================================
    // WINDOW HINTS
    // ===================================================================
    FGLFWWindowHint: TGLFWWindowHint;
    FGLFWWindowHintString: TGLFWWindowHintString;

    // ===================================================================
    // WINDOW - Creazione e distruzione
    // ===================================================================
    FGLFWCreateWindow: TGLFWCreateWindow;
    FGLFWDestroyWindow: TGLFWDestroyWindow;
    FGLFWWindowShouldClose: TGLFWWindowShouldClose;
    FGLFWSetWindowShouldClose: TGLFWSetWindowShouldClose;

    // ===================================================================
    // WINDOW - Titolo e icona
    // ===================================================================
    FGLFWSetWindowTitle: TGLFWSetWindowTitle;
    FGLFWSetWindowIcon: TGLFWSetWindowIcon;

    // ===================================================================
    // WINDOW - Posizione e dimensione
    // ===================================================================
    FGLFWGetWindowPos: TGLFWGetWindowPos;
    FGLFWSetWindowPos: TGLFWSetWindowPos;
    FGLFWGetWindowSize: TGLFWGetWindowSize;
    FGLFWSetWindowSize: TGLFWSetWindowSize;
    FGLFWSetWindowSizeLimits: TGLFWSetWindowSizeLimits;
    FGLFWSetWindowAspectRatio: TGLFWSetWindowAspectRatio;

    // ===================================================================
    // WINDOW - Framebuffer e scaling
    // ===================================================================
    FGLFWGetFramebufferSize: TGLFWGetFramebufferSize;
    FGLFWGetWindowFrameSize: TGLFWGetWindowFrameSize;
    FGLFWGetWindowContentScale: TGLFWGetWindowContentScale;
    FGLFWGetWindowOpacity: TGLFWGetWindowOpacity;
    FGLFWSetWindowOpacity: TGLFWSetWindowOpacity;

    // ===================================================================
    // WINDOW - Stato
    // ===================================================================
    FGLFWIconifyWindow: TGLFWIconifyWindow;
    FGLFWRestoreWindow: TGLFWRestoreWindow;
    FGLFWMaximizeWindow: TGLFWMaximizeWindow;
    FGLFWShowWindow: TGLFWShowWindow;
    FGLFWHideWindow: TGLFWHideWindow;
    FGLFWFocusWindow: TGLFWFocusWindow;
    FGLFWRequestWindowAttention: TGLFWRequestWindowAttention;
    FGLFWGetWindowMonitor: TGLFWGetWindowMonitor;
    FGLFWSetWindowMonitor: TGLFWSetWindowMonitor;

    // ===================================================================
    // WINDOW - Attributi
    // ===================================================================
    FGLFWGetWindowAttrib: TGLFWGetWindowAttrib;
    FGLFWSetWindowAttrib: TGLFWSetWindowAttrib;
    FGLFWSetWindowUserPointer: TGLFWSetWindowUserPointer;
    FGLFWGetWindowUserPointer: TGLFWGetWindowUserPointer;

    // ===================================================================
    // WINDOW - Callback
    // ===================================================================
    FGLFWSetWindowPosCallback: TGLFWSetWindowPosCallback;
    FGLFWSetWindowSizeCallback: TGLFWSetWindowSizeCallback;
    FGLFWSetWindowCloseCallback: TGLFWSetWindowCloseCallback;
    FGLFWSetWindowRefreshCallback: TGLFWSetWindowRefreshCallback;
    FGLFWSetWindowFocusCallback: TGLFWSetWindowFocusCallback;
    FGLFWSetWindowIconifyCallback: TGLFWSetWindowIconifyCallback;
    FGLFWSetWindowMaximizeCallback: TGLFWSetWindowMaximizeCallback;
    FGLFWSetFramebufferSizeCallback: TGLFWSetFramebufferSizeCallback;
    FGLFWSetWindowContentScaleCallback: TGLFWSetWindowContentScaleCallback;

    // ===================================================================
    // EVENTS
    // ===================================================================
    FGLFWPollEvents: TGLFWPollEvents;
    FGLFWWaitEvents: TGLFWWaitEvents;
    FGLFWWaitEventsTimeout: TGLFWWaitEventsTimeout;
    FGLFWPostEmptyEvent: TGLFWPostEmptyEvent;

    // ===================================================================
    // INPUT - Modalità e stato
    // ===================================================================
    FGLFWGetInputMode: TGLFWGetInputMode;
    FGLFWSetInputMode: TGLFWSetInputMode;
    FGLFWRawMouseMotionSupported: TGLFWRawMouseMotionSupported;

    // ===================================================================
    // INPUT - Tastiera e mouse
    // ===================================================================
    FGLFWGetKey: TGLFWGetKey;
    FGLFWGetMouseButton: TGLFWGetMouseButton;
    FGLFWGetCursorPos: TGLFWGetCursorPos;
    FGLFWSetCursorPos: TGLFWSetCursorPos;
    FGLFWGetKeyName: TGLFWGetKeyName;
    FGLFWGetKeyScancode: TGLFWGetKeyScancode;

    // ===================================================================
    // CURSOR
    // ===================================================================
    FGLFWCreateCursor: TGLFWCreateCursor;
    FGLFWCreateStandardCursor: TGLFWCreateStandardCursor;
    FGLFWDestroyCursor: TGLFWDestroyCursor;
    FGLFWSetCursor: TGLFWSetCursor;

    // ===================================================================
    // INPUT CALLBACKS
    // ===================================================================
    FGLFWSetKeyCallback: TGLFWSetKeyCallback;
    FGLFWSetCharCallback: TGLFWSetCharCallback;
    FGLFWSetCharModsCallback: TGLFWSetCharModsCallback;
    FGLFWSetMouseButtonCallback: TGLFWSetMouseButtonCallback;
    FGLFWSetCursorPosCallback: TGLFWSetCursorPosCallback;
    FGLFWSetCursorEnterCallback: TGLFWSetCursorEnterCallback;
    FGLFWSetScrollCallback: TGLFWSetScrollCallback;
    FGLFWSetDropCallback: TGLFWSetDropCallback;

    // ===================================================================
    // MONITOR
    // ===================================================================
    FGLFWGetMonitors: TGLFWGetMonitors;
    FGLFWGetPrimaryMonitor: TGLFWGetPrimaryMonitor;
    FGLFWGetMonitorPos: TGLFWGetMonitorPos;
    FGLFWGetMonitorWorkarea: TGLFWGetMonitorWorkarea;
    FGLFWGetMonitorPhysicalSize: TGLFWGetMonitorPhysicalSize;
    FGLFWGetMonitorContentScale: TGLFWGetMonitorContentScale;
    FGLFWGetMonitorName: TGLFWGetMonitorName;
    FGLFWSetMonitorUserPointer: TGLFWSetMonitorUserPointer;
    FGLFWGetMonitorUserPointer: TGLFWGetMonitorUserPointer;
    FGLFWSetMonitorCallback: TGLFWSetMonitorCallback;
    FGLFWGetVideoModes: TGLFWGetVideoModes;
    FGLFWGetVideoMode: TGLFWGetVideoMode;
    FGLFWSetGamma: TGLFWSetGamma;
    FGLFWGetGammaRamp: TGLFWGetGammaRamp;
    FGLFWSetGammaRamp: TGLFWSetGammaRamp;

    // ===================================================================
    // JOYSTICK / GAMEPAD
    // ===================================================================
    FGLFWJoystickPresent: TGLFWJoystickPresent;
    FGLFWGetJoystickAxes: TGLFWGetJoystickAxes;
    FGLFWGetJoystickButtons: TGLFWGetJoystickButtons;
    FGLFWGetJoystickHats: TGLFWGetJoystickHats;
    FGLFWGetJoystickName: TGLFWGetJoystickName;
    FGLFWGetJoystickGUID: TGLFWGetJoystickGUID;
    FGLFWSetJoystickUserPointer: TGLFWSetJoystickUserPointer;
    FGLFWGetJoystickUserPointer: TGLFWGetJoystickUserPointer;
    FGLFWJoystickIsGamepad: TGLFWJoystickIsGamepad;
    FGLFWSetJoystickCallback: TGLFWSetJoystickCallback;
    FGLFWUpdateGamepadMappings: TGLFWUpdateGamepadMappings;
    FGLFWGetGamepadName: TGLFWGetGamepadName;
    FGLFWGetGamepadState: TGLFWGetGamepadState;

    // ===================================================================
    // CLIPBOARD
    // ===================================================================
    FGLFWSetClipboardString: TGLFWSetClipboardString;
    FGLFWGetClipboardString: TGLFWGetClipboardString;

    // ===================================================================
    // TIMER
    // ===================================================================
    FGLFWGetTime: TGLFWGetTime;
    FGLFWSetTime: TGLFWSetTime;
    FGLFWGetTimerValue: TGLFWGetTimerValue;
    FGLFWGetTimerFrequency: TGLFWGetTimerFrequency;

    // ===================================================================
    // CONTEXT
    // ===================================================================
    FGLFWMakeContextCurrent: TGLFWMakeContextCurrent;
    FGLFWGetCurrentContext: TGLFWGetCurrentContext;
    FGLFWSwapBuffers: TGLFWSwapBuffers;
    FGLFWSwapInterval: TGLFWSwapInterval;

    // ===================================================================
    // EXTENSIONS
    // ===================================================================
    FGLFWExtensionSupported: TGLFWExtensionSupported;
    FGLFWGetProcAddress: TGLFWGetProcAddress;

    // ===================================================================
    // VULKAN
    // ===================================================================
    FGLFWVulkanSupported: TGLFWVulkanSupported;
    FGLFWGetRequiredInstanceExtensions: TGLFWGetRequiredInstanceExtensions;

    {$IFDEF VK_VERSION_1_0}
    FGLFWGetInstanceProcAddress: TGLFWGetInstanceProcAddress;
    FGLFWGetPhysicalDevicePresentationSupport: TGLFWGetPhysicalDevicePresentationSupport;
    FGLFWCreateWindowSurface: TGLFWCreateWindowSurface;
    {$ENDIF}

    // ===================================================================
    // GLFW 3.4+ (solo se definito GLFW3_LASTEST)
    // ===================================================================
    {$IFDEF GLFW3_LASTEST}
    FGLFWInitAllocator: TGLFWInitAllocator;
    FGLFWInitVulkanLoader: TGLFWInitVulkanLoader;
    FGLFWGetPlatform: TGLFWGetPlatform;
    FGLFWPlatformSupported: TGLFWPlatformSupported;
    FGLFWGetWindowTitle: TGLFWGetWindowTitle;
    {$ENDIF}
  protected
    FHandle: TLibHandle;
  protected
    function LoadProc(Name: ansistring): {$ifdef cpui8086}FarPointer{$else}Pointer{$endif};
    procedure Bind(var FuncPtr; const Name: ansistring; Mandatory: boolean = False);
    procedure bindEntry;
    procedure LoadLibrary;
    procedure unLoadLibrary;
  public
    constructor Create;
    destructor Destroy; override;
    function glfwInit(): integer; virtual;
    procedure glfwTerminate(); virtual;
    procedure glfwInitHint(hint, Value: integer); virtual;
    {$IFDEF GLFW3_LASTEST}
procedure glfwInitAllocator(allocator: PGLFWallocator); virtual;
{$IFDEF VK_VERSION_1_0}
procedure glfwInitVulkanLoader(loader: TGLFWVKProc); virtual;
{$ENDIF}
    {$ENDIF}
    procedure glfwGetVersion(major, minor, rev: PInteger); virtual;
    function glfwGetVersionString(): pchar; virtual;
    function glfwGetError(description: pchar): integer; virtual;
    function glfwSetErrorCallback(callback: TGLFWerrorfun): TGLFWerrorfun; virtual;
    {$IFDEF GLFW3_LASTEST}
function glfwGetPlatform(): Integer;
function glfwPlatformSupported(platform: Integer): Integer;
    {$ENDIF}
    function glfwGetMonitors(out Count: integer): PPGLFWmonitor; virtual;
    function glfwGetPrimaryMonitor(): PGLFWmonitor; virtual;
    procedure glfwGetMonitorPos(monitor: PGLFWmonitor; xpos, ypos: PInteger); virtual;
    procedure glfwGetMonitorWorkarea(monitor: PGLFWmonitor; xpos, ypos, Width, Height: PInteger); virtual;
    procedure glfwGetMonitorPhysicalSize(monitor: PGLFWmonitor; widthMM, heightMM: PInteger); virtual;
    procedure glfwGetMonitorContentScale(monitor: PGLFWmonitor; xscale, yscale: PSingle); virtual;
    function glfwGetMonitorName(monitor: PGLFWmonitor): pchar; virtual;
    procedure glfwSetMonitorUserPointer(monitor: PGLFWmonitor; user: Pointer); virtual;
    function glfwGetMonitorUserPointer(monitor: PGLFWmonitor): pointer; virtual;
    function glfwSetMonitorCallback(callback: TGLFWmonitorfun): TGLFWmonitorfun; virtual;
    function glfwGetVideoModes(monitor: PGLFWmonitor; var Count: integer): PGLFWvidmode; virtual;
    function glfwGetVideoMode(monitor: PGLFWmonitor): PGLFWvidmode; virtual;
    procedure glfwSetGamma(monitor: PGLFWmonitor; gamma: single); virtual;
    function glfwGetGammaRamp(monitor: PGLFWmonitor): PGLFWgammaramp; virtual;
    procedure glfwSetGammaRamp(monitor: PGLFWmonitor; const ramp: PGLFWgammaramp); virtual;
    procedure glfwDefaultWindowHints(); virtual;
    procedure glfwWindowHint(hint, Value: integer); virtual;
    procedure glfwWindowHintString(hint: integer; Value: pchar); virtual;
    function glfwCreateWindow(Width, Height: integer; const title: pchar; monitor: PGLFWmonitor; share: PGLFWwindow): PGLFWwindow; virtual;
    procedure glfwDestroyWindow(window: PGLFWwindow); virtual;
    function glfwWindowShouldClose(window: PGLFWwindow): integer; virtual;
    procedure glfwSetWindowShouldClose(window: PGLFWwindow; Value: integer); virtual;
    {$IFDEF GLFW3_LASTEST}
function glfwGetWindowTitle(window: PGLFWwindow): PChar; virtual;
    {$ENDIF}
    procedure glfwSetWindowTitle(window: PGLFWwindow; const title: pchar); virtual;
    procedure glfwSetWindowIcon(window: PGLFWwindow; Count: integer; const images: PGLFWimage); virtual;
    procedure glfwGetWindowPos(window: PGLFWwindow; xpos, ypos: PInteger); virtual;
    procedure glfwSetWindowPos(window: PGLFWwindow; xpos, ypos: integer); virtual;
    procedure glfwGetWindowSize(window: PGLFWwindow; Width, Height: PInteger); virtual;
    procedure glfwSetWindowSizeLimits(window: PGLFWwindow; minwidth, minheight, maxwidth, maxheight: integer); virtual;
    procedure glfwSetWindowAspectRatio(window: PGLFWwindow; numer, denom: integer); virtual;
    procedure glfwSetWindowSize(window: PGLFWwindow; Width, Height: integer); virtual;
    procedure glfwGetFramebufferSize(window: PGLFWwindow; Width, Height: PInteger); virtual;
    procedure glfwGetWindowFrameSize(window: PGLFWwindow; left, top, right, bottom: PInteger); virtual;
    procedure glfwGetWindowContentScale(window: PGLFWwindow; xscale, yscale: PSingle); virtual;
    function glfwGetWindowOpacity(window: PGLFWwindow): single; virtual;
    procedure glfwSetWindowOpacity(window: PGLFWwindow; opacity: single); virtual;
    procedure glfwIconifyWindow(window: PGLFWwindow); virtual;
    procedure glfwRestoreWindow(window: PGLFWwindow); virtual;
    procedure glfwMaximizeWindow(window: PGLFWwindow); virtual;
    procedure glfwShowWindow(window: PGLFWwindow); virtual;
    procedure glfwHideWindow(window: PGLFWwindow); virtual;
    procedure glfwFocusWindow(window: PGLFWwindow); virtual;
    procedure glfwRequestWindowAttention(window: PGLFWwindow); virtual;
    function glfwGetWindowMonitor(window: PGLFWwindow): PGLFWmonitor; virtual;
    procedure glfwSetWindowMonitor(window: PGLFWwindow; monitor: PGLFWmonitor; xpos, ypos, Width, Height, refreshRate: integer); virtual;
    function glfwGetWindowAttrib(window: PGLFWwindow; attrib: integer): integer; virtual;
    procedure glfwSetWindowAttrib(window: PGLFWwindow; attrib, Value: integer); virtual;
    procedure glfwSetWindowUserPointer(window: PGLFWwindow; userpointer: Pointer); virtual;
    function glfwGetWindowUserPointer(window: PGLFWwindow): Pointer; virtual;
    function glfwSetWindowPosCallback(window: PGLFWwindow; callback: TGLFWwindowposfun): TGLFWwindowposfun; virtual;
    function glfwSetWindowSizeCallback(window: PGLFWwindow; callback: TGLFWwindowsizefun): TGLFWwindowsizefun; virtual;
    function glfwSetWindowCloseCallback(window: PGLFWwindow; callback: TGLFWwindowclosefun): TGLFWwindowclosefun; virtual;
    function glfwSetWindowRefreshCallback(window: PGLFWwindow; callback: TGLFWwindowrefreshfun): TGLFWwindowrefreshfun; virtual;
    function glfwSetWindowFocusCallback(window: PGLFWwindow; callback: TGLFWwindowfocusfun): TGLFWwindowfocusfun; virtual;
    function glfwSetWindowIconifyCallback(window: PGLFWwindow; callback: TGLFWwindowiconifyfun): TGLFWwindowiconifyfun; virtual;
    function glfwSetWindowMaximizeCallback(window: PGLFWwindow; callback: TGLFWwindowmaximizefun): TGLFWwindowmaximizefun; virtual;
    function glfwSetFramebufferSizeCallback(window: PGLFWwindow; callback: TGLFWframebuffersizefun): TGLFWframebuffersizefun; virtual;
    function glfwSetWindowContentScaleCallback(window: PGLFWwindow; callback: TGLFWwindowcontentscalefun): TGLFWwindowcontentscalefun; virtual;
    procedure glfwPollEvents(); virtual;
    procedure glfwWaitEvents(); virtual;
    procedure glfwWaitEventsTimeout(timeout: double); virtual;
    procedure glfwPostEmptyEvent(); virtual;
    function glfwGetInputMode(window: PGLFWwindow; mode: integer): integer; virtual;
    procedure glfwSetInputMode(window: PGLFWwindow; mode, Value: integer); virtual;
    function glfwRawMouseMotionSupported(): integer; virtual;
    function glfwGetKeyName(key, scancode: integer): pchar; virtual;
    function glfwGetKeyScancode(key: integer): integer; virtual;
    function glfwGetKey(window: PGLFWwindow; key: integer): integer; virtual;
    function glfwGetMouseButton(window: PGLFWwindow; button: integer): integer; virtual;
    procedure glfwGetCursorPos(window: PGLFWwindow; xpos, ypos: PDouble); virtual;
    procedure glfwSetCursorPos(window: PGLFWwindow; xpos, ypos: double); virtual;
    function glfwCreateCursor(const image: PGLFWimage; xhot, yhot: integer): PGLFWcursor; virtual;
    function glfwCreateStandardCursor(shape: integer): PGLFWcursor; virtual;
    procedure glfwDestroyCursor(cursor: PGLFWcursor); virtual;
    procedure glfwSetCursor(window: PGLFWwindow; cursor: PGLFWcursor); virtual;
    function glfwSetKeyCallback(window: PGLFWwindow; callback: TGLFWkeyfun): TGLFWkeyfun; virtual;
    function glfwSetCharCallback(window: PGLFWwindow; callback: TGLFWcharfun): TGLFWcharfun; virtual;
    function glfwSetCharModsCallback(window: PGLFWwindow; callback: TGLFWcharmodsfun): TGLFWcharmodsfun; virtual;
    function glfwSetMouseButtonCallback(window: PGLFWwindow; callback: TGLFWmousebuttonfun): TGLFWmousebuttonfun; virtual;
    function glfwSetCursorPosCallback(window: PGLFWwindow; callback: TGLFWcursorposfun): TGLFWcursorposfun; virtual;
    function glfwSetCursorEnterCallback(window: PGLFWwindow; callback: TGLFWcursorenterfun): TGLFWcursorenterfun; virtual;
    function glfwSetScrollCallback(window: PGLFWwindow; callback: TGLFWscrollfun): TGLFWscrollfun; virtual;
    function glfwSetDropCallback(window: PGLFWwindow; callback: TGLFWdropfun): TGLFWdropfun; virtual;
    function glfwJoystickPresent(jId: integer): integer; virtual;
    function glfwGetJoystickAxes(jId: integer; Count: PInteger): PSingle; virtual;
    function glfwGetJoystickButtons(jId: integer; Count: PInteger): pbyte; virtual;
    function glfwGetJoystickHats(jId: integer; Count: PInteger): pbyte; virtual;
    function glfwGetJoystickName(jId: integer): pchar; virtual;
    function glfwGetJoystickGUID(jId: integer): pchar; virtual;
    procedure glfwSetJoystickUserPointer(jId: integer; userPointer: Pointer); virtual;
    function glfwGetJoystickUserPointer(jId: integer): Pointer; virtual;
    function glfwJoystickIsGamepad(jId: integer): integer; virtual;
    function glfwSetJoystickCallback(callback: TGLFWjoystickfun): TGLFWjoystickfun; virtual;
    function glfwUpdateGamepadMappings(const str: pchar): integer; virtual;
    function glfwGetGamepadName(jId: integer): pchar; virtual;
    function glfwGetGamepadState(jId: integer; state: PGLFWgamepadstate): integer; virtual;
    procedure glfwSetClipboardString(window: PGLFWwindow; const str: pchar); virtual;
    function glfwGetClipboardString(window: PGLFWwindow): pchar; virtual;
    function glfwGetTime(): double; virtual;
    procedure glfwSetTime(time: double); virtual;
    function glfwGetTimerValue(): uint64; virtual;
    function glfwGetTimerFrequency(): uint64; virtual;
    procedure glfwMakeContextCurrent(window: PGLFWwindow); virtual;
    function glfwGetCurrentContext(): PGLFWwindow; virtual;
    procedure glfwSwapBuffers(window: PGLFWwindow); virtual;
    procedure glfwSwapInterval(interval: integer); virtual;
    function glfwExtensionSupported(const extension: pchar): integer; virtual;
    function glfwGetProcAddress(const procname: pchar): TGLFWGLProc; virtual;
    function glfwVulkanSupported(): integer; virtual;
    function glfwGetRequiredInstanceExtensions(var Count: uint32): ppchar; virtual;
    {$IFDEF VK_VERSION_1_0}
function glfwGetInstanceProcAddress(instance: VkInstance; const procname: PChar): TGLFWVKProc; virtual;
function glfwGetPhysicalDevicePresentationSupport(instance: VkInstance; device: VkPhysicalDevice; queuefamily: Cardinal): Integer; virtual;
function glfwCreateWindowSurface(instance: VkInstance; window: PGLFWwindow; const allocator: PVkAllocationCallbacks; surface: PVkSurfaceKHR): TVkResult; virtual;
    {$ENDIF}
  end;

function getGLFW: IGLFW;
begin
  if not Assigned(singleton) then
  begin
    singleton := TGLFW.Create;
  end;
  Result := singleton;
end;

{ TGLFW }

function TGLFW.LoadProc(Name: ansistring): Pointer;
begin
  Result := dynlibs.GetProcAddress(FHandle, Name);
  if not assigned(Result) then
  begin
    Writeln(Name, ' not found');
  end;
end;

procedure TGLFW.Bind(var FuncPtr; const Name: ansistring; Mandatory: boolean);
begin
  Pointer(FuncPtr) := LoadProc(Name);
  if (Pointer(FuncPtr) <> nil) and Mandatory then
    raise Exception.Create('OpenGL function not found: ' + Name);
end;

procedure TGLFW.bindEntry;
begin
  if FHandle = 0 then
    raise Exception.Create('GLFW: Libreria non caricata');

  // ===================================================================
  // CORE
  //  Inizializzazione, versione, errori
  // ===================================================================
  Bind(FGLFWInit, 'glfwInit');
  Bind(FGLFWTerminate, 'glfwTerminate');
  Bind(FGLFWInitHint, 'glfwInitHint', False);                    // da 3.3
  Bind(FGLFWDefaultWindowHints, 'glfwDefaultWindowHints');
  Bind(FGLFWGetVersion, 'glfwGetVersion');
  Bind(FGLFWGetVersionString, 'glfwGetVersionString');
  Bind(FGLFWGetError, 'glfwGetError');
  Bind(FGLFWSetErrorCallback, 'glfwSetErrorCallback');

  // ===================================================================
  // WINDOW HINTS
  // ===================================================================
  Bind(FGLFWWindowHint, 'glfwWindowHint');
  Bind(FGLFWWindowHintString, 'glfwWindowHintString', False);    // da 3.3

  // ===================================================================
  // WINDOW - Creazione e gestione base
  // ===================================================================
  Bind(FGLFWCreateWindow, 'glfwCreateWindow');
  Bind(FGLFWDestroyWindow, 'glfwDestroyWindow');
  Bind(FGLFWWindowShouldClose, 'glfwWindowShouldClose');
  Bind(FGLFWSetWindowShouldClose, 'glfwSetWindowShouldClose');

  // ===================================================================
  // WINDOW - Titolo e icona
  // ===================================================================
  Bind(FGLFWSetWindowTitle, 'glfwSetWindowTitle');
  Bind(FGLFWSetWindowIcon, 'glfwSetWindowIcon');

  // ===================================================================
  // WINDOW - Posizione e dimensione
  // ===================================================================
  Bind(FGLFWGetWindowPos, 'glfwGetWindowPos');
  Bind(FGLFWSetWindowPos, 'glfwSetWindowPos');
  Bind(FGLFWGetWindowSize, 'glfwGetWindowSize');
  Bind(FGLFWSetWindowSize, 'glfwSetWindowSize');
  Bind(FGLFWSetWindowSizeLimits, 'glfwSetWindowSizeLimits', False);     // da 3.3
  Bind(FGLFWSetWindowAspectRatio, 'glfwSetWindowAspectRatio', False);  // da 3.3

  // ===================================================================
  // WINDOW - Framebuffer e scaling
  // ===================================================================
  Bind(FGLFWGetFramebufferSize, 'glfwGetFramebufferSize');
  Bind(FGLFWGetWindowFrameSize, 'glfwGetWindowFrameSize', False);      // da 3.3
  Bind(FGLFWGetWindowContentScale, 'glfwGetWindowContentScale', False); // da 3.3
  Bind(FGLFWGetWindowOpacity, 'glfwGetWindowOpacity', False);          // da 3.3
  Bind(FGLFWSetWindowOpacity, 'glfwSetWindowOpacity', False);          // da 3.3

  // ===================================================================
  // WINDOW - Stato
  // ===================================================================
  Bind(FGLFWIconifyWindow, 'glfwIconifyWindow');
  Bind(FGLFWRestoreWindow, 'glfwRestoreWindow');
  Bind(FGLFWMaximizeWindow, 'glfwMaximizeWindow');
  Bind(FGLFWShowWindow, 'glfwShowWindow');
  Bind(FGLFWHideWindow, 'glfwHideWindow');
  Bind(FGLFWFocusWindow, 'glfwFocusWindow');
  Bind(FGLFWRequestWindowAttention, 'glfwRequestWindowAttention', False); // da 3.3
  Bind(FGLFWGetWindowMonitor, 'glfwGetWindowMonitor');
  Bind(FGLFWSetWindowMonitor, 'glfwSetWindowMonitor');

  // ===================================================================
  // WINDOW - Attributi
  // ===================================================================
  Bind(FGLFWGetWindowAttrib, 'glfwGetWindowAttrib');
  Bind(FGLFWSetWindowAttrib, 'glfwSetWindowAttrib', False);            // da 3.3
  Bind(FGLFWSetWindowUserPointer, 'glfwSetWindowUserPointer');
  Bind(FGLFWGetWindowUserPointer, 'glfwGetWindowUserPointer');

  // ===================================================================
  // WINDOW - Callback
  // ===================================================================
  Bind(FGLFWSetWindowPosCallback, 'glfwSetWindowPosCallback');
  Bind(FGLFWSetWindowSizeCallback, 'glfwSetWindowSizeCallback');
  Bind(FGLFWSetWindowCloseCallback, 'glfwSetWindowCloseCallback');
  Bind(FGLFWSetWindowRefreshCallback, 'glfwSetWindowRefreshCallback');
  Bind(FGLFWSetWindowFocusCallback, 'glfwSetWindowFocusCallback');
  Bind(FGLFWSetWindowIconifyCallback, 'glfwSetWindowIconifyCallback');
  Bind(FGLFWSetWindowMaximizeCallback, 'glfwSetWindowMaximizeCallback');
  Bind(FGLFWSetFramebufferSizeCallback, 'glfwSetFramebufferSizeCallback');
  Bind(FGLFWSetWindowContentScaleCallback, 'glfwSetWindowContentScaleCallback', False); // da 3.3

  // ===================================================================
  // EVENTS
  // ===================================================================
  Bind(FGLFWPollEvents, 'glfwPollEvents');
  Bind(FGLFWWaitEvents, 'glfwWaitEvents');
  Bind(FGLFWWaitEventsTimeout, 'glfwWaitEventsTimeout', False);       // da 3.2
  Bind(FGLFWPostEmptyEvent, 'glfwPostEmptyEvent', False);              // da 3.2

  // ===================================================================
  // INPUT - Modalità e stato
  // ===================================================================
  Bind(FGLFWGetInputMode, 'glfwGetInputMode');
  Bind(FGLFWSetInputMode, 'glfwSetInputMode');
  Bind(FGLFWRawMouseMotionSupported, 'glfwRawMouseMotionSupported', False); // da 3.3

  // ===================================================================
  // INPUT - Tastiera e mouse
  // ===================================================================
  Bind(FGLFWGetKey, 'glfwGetKey');
  Bind(FGLFWGetMouseButton, 'glfwGetMouseButton');
  Bind(FGLFWGetCursorPos, 'glfwGetCursorPos');
  Bind(FGLFWSetCursorPos, 'glfwSetCursorPos');
  Bind(FGLFWGetKeyName, 'glfwGetKeyName', False);                      // da 3.2
  Bind(FGLFWGetKeyScancode, 'glfwGetKeyScancode', False);                // da 3.3

  // ===================================================================
  // CURSOR
  // ===================================================================
  Bind(FGLFWCreateCursor, 'glfwCreateCursor');
  Bind(FGLFWCreateStandardCursor, 'glfwCreateStandardCursor');
  Bind(FGLFWDestroyCursor, 'glfwDestroyCursor');
  Bind(FGLFWSetCursor, 'glfwSetCursor');

  // ===================================================================
  // INPUT CALLBACKS
  // ===================================================================
  Bind(FGLFWSetKeyCallback, 'glfwSetKeyCallback');
  Bind(FGLFWSetCharCallback, 'glfwSetCharCallback');
  Bind(FGLFWSetCharModsCallback, 'glfwSetCharModsCallback', False);   // da 3.1, rimossa in 3.4
  Bind(FGLFWSetMouseButtonCallback, 'glfwSetMouseButtonCallback');
  Bind(FGLFWSetCursorPosCallback, 'glfwSetCursorPosCallback');
  Bind(FGLFWSetCursorEnterCallback, 'glfwSetCursorEnterCallback');
  Bind(FGLFWSetScrollCallback, 'glfwSetScrollCallback');
  Bind(FGLFWSetDropCallback, 'glfwSetDropCallback');

  // ===================================================================
  // MONITOR
  // ===================================================================
  Bind(FGLFWGetMonitors, 'glfwGetMonitors');
  Bind(FGLFWGetPrimaryMonitor, 'glfwGetPrimaryMonitor');
  Bind(FGLFWGetMonitorPos, 'glfwGetMonitorPos');
  Bind(FGLFWGetMonitorWorkarea, 'glfwGetMonitorWorkarea', False);      // da 3.3
  Bind(FGLFWGetMonitorPhysicalSize, 'glfwGetMonitorPhysicalSize');
  Bind(FGLFWGetMonitorContentScale, 'glfwGetMonitorContentScale', False); // da 3.3
  Bind(FGLFWGetMonitorName, 'glfwGetMonitorName');
  Bind(FGLFWSetMonitorUserPointer, 'glfwSetMonitorUserPointer');
  Bind(FGLFWGetMonitorUserPointer, 'glfwGetMonitorUserPointer');
  Bind(FGLFWSetMonitorCallback, 'glfwSetMonitorCallback');
  Bind(FGLFWGetVideoModes, 'glfwGetVideoModes');
  Bind(FGLFWGetVideoMode, 'glfwGetVideoMode');
  Bind(FGLFWSetGamma, 'glfwSetGamma');
  Bind(FGLFWGetGammaRamp, 'glfwGetGammaRamp');
  Bind(FGLFWSetGammaRamp, 'glfwSetGammaRamp');

  // ===================================================================
  // JOYSTICK / GAMEPAD
  // ===================================================================
  Bind(FGLFWJoystickPresent, 'glfwJoystickPresent');
  Bind(FGLFWGetJoystickAxes, 'glfwGetJoystickAxes');
  Bind(FGLFWGetJoystickButtons, 'glfwGetJoystickButtons');
  Bind(FGLFWGetJoystickHats, 'glfwGetJoystickHats');
  Bind(FGLFWGetJoystickName, 'glfwGetJoystickName');
  Bind(FGLFWGetJoystickGUID, 'glfwGetJoystickGUID', False);            // da 3.3
  Bind(FGLFWSetJoystickUserPointer, 'glfwSetJoystickUserPointer');
  Bind(FGLFWGetJoystickUserPointer, 'glfwGetJoystickUserPointer');
  Bind(FGLFWJoystickIsGamepad, 'glfwJoystickIsGamepad');
  Bind(FGLFWSetJoystickCallback, 'glfwSetJoystickCallback');
  Bind(FGLFWUpdateGamepadMappings, 'glfwUpdateGamepadMappings');
  Bind(FGLFWGetGamepadName, 'glfwGetGamepadName');
  Bind(FGLFWGetGamepadState, 'glfwGetGamepadState');

  // ===================================================================
  // CLIPBOARD
  // ===================================================================
  Bind(FGLFWSetClipboardString, 'glfwSetClipboardString');
  Bind(FGLFWGetClipboardString, 'glfwGetClipboardString');

  // ===================================================================
  // TIMER
  // ===================================================================
  Bind(FGLFWGetTime, 'glfwGetTime');
  Bind(FGLFWSetTime, 'glfwSetTime');
  Bind(FGLFWGetTimerValue, 'glfwGetTimerValue', False);                // da 3.2
  Bind(FGLFWGetTimerFrequency, 'glfwGetTimerFrequency', False);        // da 3.2

  // ===================================================================
  // CONTEXT
  // ===================================================================
  Bind(FGLFWMakeContextCurrent, 'glfwMakeContextCurrent');
  Bind(FGLFWGetCurrentContext, 'glfwGetCurrentContext');
  Bind(FGLFWSwapBuffers, 'glfwSwapBuffers');
  Bind(FGLFWSwapInterval, 'glfwSwapInterval');

  // ===================================================================
  // EXTENSIONS
  // ===================================================================
  Bind(FGLFWExtensionSupported, 'glfwExtensionSupported');
  Bind(FGLFWGetProcAddress, 'glfwGetProcAddress');

  // ===================================================================
  // VULKAN
  // ===================================================================
  Bind(FGLFWVulkanSupported, 'glfwVulkanSupported');
  Bind(FGLFWGetRequiredInstanceExtensions, 'glfwGetRequiredInstanceExtensions');

  {$IFDEF VK_VERSION_1_0}
  Bind(FGLFWGetInstanceProcAddress, 'glfwGetInstanceProcAddress', False);
  Bind(FGLFWGetPhysicalDevicePresentationSupport, 'glfwGetPhysicalDevicePresentationSupport', False);
  Bind(FGLFWCreateWindowSurface, 'glfwCreateWindowSurface', False);
  {$ENDIF}

  // ===================================================================
  // GLFW 3.4+ (solo se definito GLFW3_LASTEST)
  // ===================================================================
  {$IFDEF GLFW3_LASTEST}
  Bind(FGLFWInitAllocator, 'glfwInitAllocator', False);
  Bind(FGLFWInitVulkanLoader, 'glfwInitVulkanLoader', False);
  Bind(FGLFWGetPlatform, 'glfwGetPlatform', False);
  Bind(FGLFWPlatformSupported, 'glfwPlatformSupported', False);
  Bind(FGLFWGetWindowTitle, 'glfwGetWindowTitle', False);
  {$ENDIF}
end;

procedure TGLFW.LoadLibrary;
begin
  FHandle := dynlibs.LoadLibrary(libGLFW);
end;

procedure TGLFW.unLoadLibrary;
begin
  dynlibs.UnloadLibrary(FHandle);
end;

constructor TGLFW.Create;
begin
  LoadLibrary;
  bindEntry;
end;

destructor TGLFW.Destroy;
begin
  unLoadLibrary;
  inherited Destroy;
end;

function TGLFW.glfwInit(): integer;
begin
  if Assigned(FGLFWInit) then
    Result := FGLFWInit()
  else
    raise ENullPointerException.Create('glfwInit');
end;

procedure TGLFW.glfwTerminate();
begin
  if Assigned(FGLFWTerminate) then
    FGLFWTerminate()
  else
    raise ENullPointerException.Create('glfwTerminate');
end;

procedure TGLFW.glfwInitHint(hint, Value: integer);
begin
  if Assigned(FGLFWInitHint) then
    FGLFWInitHint(hint, Value)
  else
    raise ENullPointerException.Create('glfwInitHint');
end;

procedure TGLFW.glfwGetVersion(major, minor, rev: PInteger);
begin
  if Assigned(FGLFWGetVersion) then
    FGLFWGetVersion(major, minor, rev)
  else
    raise ENullPointerException.Create('glfwGetVersion');
end;

function TGLFW.glfwGetVersionString(): pchar;
begin
  if Assigned(FGLFWGetVersionString) then
    Result := FGLFWGetVersionString()
  else
    raise ENullPointerException.Create('glfwGetVersionString');
end;

function TGLFW.glfwGetError(description: pchar): integer;
begin
  if Assigned(FGLFWGetError) then
    Result := FGLFWGetError(description)
  else
    raise ENullPointerException.Create('glfwGetError');
end;

function TGLFW.glfwSetErrorCallback(callback: TGLFWerrorfun): TGLFWerrorfun;
begin
  if Assigned(FGLFWSetErrorCallback) then
    Result := FGLFWSetErrorCallback(callback)
  else
    raise ENullPointerException.Create('glfwSetErrorCallback');
end;

procedure TGLFW.glfwDefaultWindowHints();
begin
  if Assigned(FGLFWDefaultWindowHints) then
    FGLFWDefaultWindowHints()
  else
    raise ENullPointerException.Create('glfwDefaultWindowHints');
end;

procedure TGLFW.glfwWindowHint(hint, Value: integer);
begin
  if Assigned(FGLFWWindowHint) then
    FGLFWWindowHint(hint, Value)
  else
    raise ENullPointerException.Create('glfwWindowHint');
end;

procedure TGLFW.glfwWindowHintString(hint: integer; Value: pchar);
begin
  if Assigned(FGLFWWindowHintString) then
    FGLFWWindowHintString(hint, Value)
  else
    raise ENullPointerException.Create('glfwWindowHintString');
end;

function TGLFW.glfwCreateWindow(Width, Height: integer; const title: pchar; monitor, share: PGLFWwindow): PGLFWwindow;
begin
  if Assigned(FGLFWCreateWindow) then
    Result := FGLFWCreateWindow(Width, Height, title, monitor, share)
  else
    raise ENullPointerException.Create('glfwCreateWindow');
end;

procedure TGLFW.glfwDestroyWindow(window: PGLFWwindow);
begin
  if Assigned(FGLFWDestroyWindow) then
    FGLFWDestroyWindow(window)
  else
    raise ENullPointerException.Create('glfwDestroyWindow');
end;

function TGLFW.glfwWindowShouldClose(window: PGLFWwindow): integer;
begin
  if Assigned(FGLFWWindowShouldClose) then
    Result := FGLFWWindowShouldClose(window)
  else
    raise ENullPointerException.Create('glfwWindowShouldClose');
end;

procedure TGLFW.glfwSetWindowShouldClose(window: PGLFWwindow; Value: integer);
begin
  if Assigned(FGLFWSetWindowShouldClose) then
    FGLFWSetWindowShouldClose(window, Value)
  else
    raise ENullPointerException.Create('glfwSetWindowShouldClose');
end;

procedure TGLFW.glfwSetWindowTitle(window: PGLFWwindow; const title: pchar);
begin
  if Assigned(FGLFWSetWindowTitle) then
    FGLFWSetWindowTitle(window, title)
  else
    raise ENullPointerException.Create('glfwSetWindowTitle');
end;

procedure TGLFW.glfwSetWindowIcon(window: PGLFWwindow; Count: integer; const images: PGLFWimage);
begin
  if Assigned(FGLFWSetWindowIcon) then
    FGLFWSetWindowIcon(window, Count, images)
  else
    raise ENullPointerException.Create('glfwSetWindowIcon');
end;

procedure TGLFW.glfwGetWindowPos(window: PGLFWwindow; xpos, ypos: PInteger);
begin
  if Assigned(FGLFWGetWindowPos) then
    FGLFWGetWindowPos(window, xpos, ypos)
  else
    raise ENullPointerException.Create('glfwGetWindowPos');
end;

procedure TGLFW.glfwSetWindowPos(window: PGLFWwindow; xpos, ypos: integer);
begin
  if Assigned(FGLFWSetWindowPos) then
    FGLFWSetWindowPos(window, xpos, ypos)
  else
    raise ENullPointerException.Create('glfwSetWindowPos');
end;

procedure TGLFW.glfwGetWindowSize(window: PGLFWwindow; Width, Height: PInteger);
begin
  if Assigned(FGLFWGetWindowSize) then
    FGLFWGetWindowSize(window, Width, Height)
  else
    raise ENullPointerException.Create('glfwGetWindowSize');
end;

procedure TGLFW.glfwSetWindowSize(window: PGLFWwindow; Width, Height: integer);
begin
  if Assigned(FGLFWSetWindowSize) then
    FGLFWSetWindowSize(window, Width, Height)
  else
    raise ENullPointerException.Create('glfwSetWindowSize');
end;

procedure TGLFW.glfwSetWindowSizeLimits(window: PGLFWwindow; minwidth, minheight, maxwidth, maxheight: integer);
begin
  if Assigned(FGLFWSetWindowSizeLimits) then
    FGLFWSetWindowSizeLimits(window, minwidth, minheight, maxwidth, maxheight)
  else
    raise ENullPointerException.Create('glfwSetWindowSizeLimits');
end;

procedure TGLFW.glfwSetWindowAspectRatio(window: PGLFWwindow; numer, denom: integer);
begin
  if Assigned(FGLFWSetWindowAspectRatio) then
    FGLFWSetWindowAspectRatio(window, numer, denom)
  else
    raise ENullPointerException.Create('glfwSetWindowAspectRatio');
end;

procedure TGLFW.glfwGetFramebufferSize(window: PGLFWwindow; Width, Height: PInteger);
begin
  if Assigned(FGLFWGetFramebufferSize) then
    FGLFWGetFramebufferSize(window, Width, Height)
  else
    raise ENullPointerException.Create('glfwGetFramebufferSize');
end;

procedure TGLFW.glfwGetWindowFrameSize(window: PGLFWwindow; left, top, right, bottom: PInteger);
begin
  if Assigned(FGLFWGetWindowFrameSize) then
    FGLFWGetWindowFrameSize(window, left, top, right, bottom)
  else
    raise ENullPointerException.Create('glfwGetWindowFrameSize');
end;

procedure TGLFW.glfwGetWindowContentScale(window: PGLFWwindow; xscale, yscale: PSingle);
begin
  if Assigned(FGLFWGetWindowContentScale) then
    FGLFWGetWindowContentScale(window, xscale, yscale)
  else
    raise ENullPointerException.Create('glfwGetWindowContentScale');
end;

function TGLFW.glfwGetWindowOpacity(window: PGLFWwindow): single;
begin
  if Assigned(FGLFWGetWindowOpacity) then
    Result := FGLFWGetWindowOpacity(window)
  else
    raise ENullPointerException.Create('glfwGetWindowOpacity');
end;

procedure TGLFW.glfwSetWindowOpacity(window: PGLFWwindow; opacity: single);
begin
  if Assigned(FGLFWSetWindowOpacity) then
    FGLFWSetWindowOpacity(window, opacity)
  else
    raise ENullPointerException.Create('glfwSetWindowOpacity');
end;

procedure TGLFW.glfwIconifyWindow(window: PGLFWwindow);
begin
  if Assigned(FGLFWIconifyWindow) then
    FGLFWIconifyWindow(window)
  else
    raise ENullPointerException.Create('glfwIconifyWindow');
end;

procedure TGLFW.glfwRestoreWindow(window: PGLFWwindow);
begin
  if Assigned(FGLFWRestoreWindow) then
    FGLFWRestoreWindow(window)
  else
    raise ENullPointerException.Create('glfwRestoreWindow');
end;

procedure TGLFW.glfwMaximizeWindow(window: PGLFWwindow);
begin
  if Assigned(FGLFWMaximizeWindow) then
    FGLFWMaximizeWindow(window)
  else
    raise ENullPointerException.Create('glfwMaximizeWindow');
end;

procedure TGLFW.glfwShowWindow(window: PGLFWwindow);
begin
  if Assigned(FGLFWShowWindow) then
    FGLFWShowWindow(window)
  else
    raise ENullPointerException.Create('glfwShowWindow');
end;

procedure TGLFW.glfwHideWindow(window: PGLFWwindow);
begin
  if Assigned(FGLFWHideWindow) then
    FGLFWHideWindow(window)
  else
    raise ENullPointerException.Create('glfwHideWindow');
end;

procedure TGLFW.glfwFocusWindow(window: PGLFWwindow);
begin
  if Assigned(FGLFWFocusWindow) then
    FGLFWFocusWindow(window)
  else
    raise ENullPointerException.Create('glfwFocusWindow');
end;

procedure TGLFW.glfwRequestWindowAttention(window: PGLFWwindow);
begin
  if Assigned(FGLFWRequestWindowAttention) then
    FGLFWRequestWindowAttention(window)
  else
    raise ENullPointerException.Create('glfwRequestWindowAttention');
end;

function TGLFW.glfwGetWindowMonitor(window: PGLFWwindow): PGLFWmonitor;
begin
  if Assigned(FGLFWGetWindowMonitor) then
    Result := FGLFWGetWindowMonitor(window)
  else
    raise ENullPointerException.Create('glfwGetWindowMonitor');
end;

procedure TGLFW.glfwSetWindowMonitor(window: PGLFWwindow; monitor: PGLFWmonitor; xpos, ypos, Width, Height, refreshRate: integer);
begin
  if Assigned(FGLFWSetWindowMonitor) then
    FGLFWSetWindowMonitor(window, monitor, xpos, ypos, Width, Height, refreshRate)
  else
    raise ENullPointerException.Create('glfwSetWindowMonitor');
end;

function TGLFW.glfwGetWindowAttrib(window: PGLFWwindow; attrib: integer): integer;
begin
  if Assigned(FGLFWGetWindowAttrib) then
    Result := FGLFWGetWindowAttrib(window, attrib)
  else
    raise ENullPointerException.Create('glfwGetWindowAttrib');
end;

procedure TGLFW.glfwSetWindowAttrib(window: PGLFWwindow; attrib, Value: integer);
begin
  if Assigned(FGLFWSetWindowAttrib) then
    FGLFWSetWindowAttrib(window, attrib, Value)
  else
    raise ENullPointerException.Create('glfwSetWindowAttrib');
end;

procedure TGLFW.glfwSetWindowUserPointer(window: PGLFWwindow; userpointer: Pointer);
begin
  if Assigned(FGLFWSetWindowUserPointer) then
    FGLFWSetWindowUserPointer(window, userpointer)
  else
    raise ENullPointerException.Create('glfwSetWindowUserPointer');
end;

function TGLFW.glfwGetWindowUserPointer(window: PGLFWwindow): Pointer;
begin
  if Assigned(FGLFWGetWindowUserPointer) then
    Result := FGLFWGetWindowUserPointer(window)
  else
    raise ENullPointerException.Create('glfwGetWindowUserPointer');
end;

function TGLFW.glfwSetWindowPosCallback(window: PGLFWwindow; callback: TGLFWwindowposfun): TGLFWwindowposfun;
begin
  if Assigned(FGLFWSetWindowPosCallback) then
    Result := FGLFWSetWindowPosCallback(window, callback)
  else
    raise ENullPointerException.Create('glfwSetWindowPosCallback');
end;

function TGLFW.glfwSetWindowSizeCallback(window: PGLFWwindow; callback: TGLFWwindowsizefun): TGLFWwindowsizefun;
begin
  if Assigned(FGLFWSetWindowSizeCallback) then
    Result := FGLFWSetWindowSizeCallback(window, callback)
  else
    raise ENullPointerException.Create('glfwSetWindowSizeCallback');
end;

function TGLFW.glfwSetWindowCloseCallback(window: PGLFWwindow; callback: TGLFWwindowclosefun): TGLFWwindowclosefun;
begin
  if Assigned(FGLFWSetWindowCloseCallback) then
    Result := FGLFWSetWindowCloseCallback(window, callback)
  else
    raise ENullPointerException.Create('glfwSetWindowCloseCallback');
end;

function TGLFW.glfwSetWindowRefreshCallback(window: PGLFWwindow; callback: TGLFWwindowrefreshfun): TGLFWwindowrefreshfun;
begin
  if Assigned(FGLFWSetWindowRefreshCallback) then
    Result := FGLFWSetWindowRefreshCallback(window, callback)
  else
    raise ENullPointerException.Create('glfwSetWindowRefreshCallback');
end;

function TGLFW.glfwSetWindowFocusCallback(window: PGLFWwindow; callback: TGLFWwindowfocusfun): TGLFWwindowfocusfun;
begin
  if Assigned(FGLFWSetWindowFocusCallback) then
    Result := FGLFWSetWindowFocusCallback(window, callback)
  else
    raise ENullPointerException.Create('glfwSetWindowFocusCallback');
end;

function TGLFW.glfwSetWindowIconifyCallback(window: PGLFWwindow; callback: TGLFWwindowiconifyfun): TGLFWwindowiconifyfun;
begin
  if Assigned(FGLFWSetWindowIconifyCallback) then
    Result := FGLFWSetWindowIconifyCallback(window, callback)
  else
    raise ENullPointerException.Create('glfwSetWindowIconifyCallback');
end;

function TGLFW.glfwSetWindowMaximizeCallback(window: PGLFWwindow; callback: TGLFWwindowmaximizefun): TGLFWwindowmaximizefun;
begin
  if Assigned(FGLFWSetWindowMaximizeCallback) then
    Result := FGLFWSetWindowMaximizeCallback(window, callback)
  else
    raise ENullPointerException.Create('glfwSetWindowMaximizeCallback');
end;

function TGLFW.glfwSetFramebufferSizeCallback(window: PGLFWwindow; callback: TGLFWframebuffersizefun): TGLFWframebuffersizefun;
begin
  if Assigned(FGLFWSetFramebufferSizeCallback) then
    Result := FGLFWSetFramebufferSizeCallback(window, callback)
  else
    raise ENullPointerException.Create('glfwSetFramebufferSizeCallback');
end;

function TGLFW.glfwSetWindowContentScaleCallback(window: PGLFWwindow; callback: TGLFWwindowcontentscalefun): TGLFWwindowcontentscalefun;
begin
  if Assigned(FGLFWSetWindowContentScaleCallback) then
    Result := FGLFWSetWindowContentScaleCallback(window, callback)
  else
    raise ENullPointerException.Create('glfwSetWindowContentScaleCallback');
end;

procedure TGLFW.glfwPollEvents();
begin
  if Assigned(FGLFWPollEvents) then
    FGLFWPollEvents()
  else
    raise ENullPointerException.Create('glfwPollEvents');
end;

procedure TGLFW.glfwWaitEvents();
begin
  if Assigned(FGLFWWaitEvents) then
    FGLFWWaitEvents()
  else
    raise ENullPointerException.Create('glfwWaitEvents');
end;

procedure TGLFW.glfwWaitEventsTimeout(timeout: double);
begin
  if Assigned(FGLFWWaitEventsTimeout) then
    FGLFWWaitEventsTimeout(timeout)
  else
    raise ENullPointerException.Create('glfwWaitEventsTimeout');
end;

procedure TGLFW.glfwPostEmptyEvent();
begin
  if Assigned(FGLFWPostEmptyEvent) then
    FGLFWPostEmptyEvent()
  else
    raise ENullPointerException.Create('glfwPostEmptyEvent');
end;

function TGLFW.glfwGetInputMode(window: PGLFWwindow; mode: integer): integer;
begin
  if Assigned(FGLFWGetInputMode) then
    Result := FGLFWGetInputMode(window, mode)
  else
    raise ENullPointerException.Create('glfwGetInputMode');
end;

procedure TGLFW.glfwSetInputMode(window: PGLFWwindow; mode, Value: integer);
begin
  if Assigned(FGLFWSetInputMode) then
    FGLFWSetInputMode(window, mode, Value)
  else
    raise ENullPointerException.Create('glfwSetInputMode');
end;

function TGLFW.glfwRawMouseMotionSupported(): integer;
begin
  if Assigned(FGLFWRawMouseMotionSupported) then
    Result := FGLFWRawMouseMotionSupported()
  else
    raise ENullPointerException.Create('glfwRawMouseMotionSupported');
end;

function TGLFW.glfwGetKeyName(key, scancode: integer): pchar;
begin
  if Assigned(FGLFWGetKeyName) then
    Result := FGLFWGetKeyName(key, scancode)
  else
    raise ENullPointerException.Create('glfwGetKeyName');
end;

function TGLFW.glfwGetKeyScancode(key: integer): integer;
begin
  if Assigned(FGLFWGetKeyScancode) then
    Result := FGLFWGetKeyScancode(key)
  else
    raise ENullPointerException.Create('glfwGetKeyScancode');
end;

function TGLFW.glfwGetKey(window: PGLFWwindow; key: integer): integer;
begin
  if Assigned(FGLFWGetKey) then
    Result := FGLFWGetKey(window, key)
  else
    raise ENullPointerException.Create('glfwGetKey');
end;

function TGLFW.glfwGetMouseButton(window: PGLFWwindow; button: integer): integer;
begin
  if Assigned(FGLFWGetMouseButton) then
    Result := FGLFWGetMouseButton(window, button)
  else
    raise ENullPointerException.Create('glfwGetMouseButton');
end;

procedure TGLFW.glfwGetCursorPos(window: PGLFWwindow; xpos, ypos: PDouble);
begin
  if Assigned(FGLFWGetCursorPos) then
    FGLFWGetCursorPos(window, xpos, ypos)
  else
    raise ENullPointerException.Create('glfwGetCursorPos');
end;

procedure TGLFW.glfwSetCursorPos(window: PGLFWwindow; xpos, ypos: double);
begin
  if Assigned(FGLFWSetCursorPos) then
    FGLFWSetCursorPos(window, xpos, ypos)
  else
    raise ENullPointerException.Create('glfwSetCursorPos');
end;

function TGLFW.glfwCreateCursor(const image: PGLFWimage; xhot, yhot: integer): PGLFWcursor;
begin
  if Assigned(FGLFWCreateCursor) then
    Result := FGLFWCreateCursor(image, xhot, yhot)
  else
    raise ENullPointerException.Create('glfwCreateCursor');
end;

function TGLFW.glfwCreateStandardCursor(shape: integer): PGLFWcursor;
begin
  if Assigned(FGLFWCreateStandardCursor) then
    Result := FGLFWCreateStandardCursor(shape)
  else
    raise ENullPointerException.Create('glfwCreateStandardCursor');
end;

procedure TGLFW.glfwDestroyCursor(cursor: PGLFWcursor);
begin
  if Assigned(FGLFWDestroyCursor) then
    FGLFWDestroyCursor(cursor)
  else
    raise ENullPointerException.Create('glfwDestroyCursor');
end;

procedure TGLFW.glfwSetCursor(window: PGLFWwindow; cursor: PGLFWcursor);
begin
  if Assigned(FGLFWSetCursor) then
    FGLFWSetCursor(window, cursor)
  else
    raise ENullPointerException.Create('glfwSetCursor');
end;

function TGLFW.glfwSetKeyCallback(window: PGLFWwindow; callback: TGLFWkeyfun): TGLFWkeyfun;
begin
  if Assigned(FGLFWSetKeyCallback) then
    Result := FGLFWSetKeyCallback(window, callback)
  else
    raise ENullPointerException.Create('glfwSetKeyCallback');
end;

function TGLFW.glfwSetCharCallback(window: PGLFWwindow; callback: TGLFWcharfun): TGLFWcharfun;
begin
  if Assigned(FGLFWSetCharCallback) then
    Result := FGLFWSetCharCallback(window, callback)
  else
    raise ENullPointerException.Create('glfwSetCharCallback');
end;

function TGLFW.glfwSetCharModsCallback(window: PGLFWwindow; callback: TGLFWcharmodsfun): TGLFWcharmodsfun;
begin
  if Assigned(FGLFWSetCharModsCallback) then
    Result := FGLFWSetCharModsCallback(window, callback)
  else
    raise ENullPointerException.Create('glfwSetCharModsCallback');
end;

function TGLFW.glfwSetMouseButtonCallback(window: PGLFWwindow; callback: TGLFWmousebuttonfun): TGLFWmousebuttonfun;
begin
  if Assigned(FGLFWSetMouseButtonCallback) then
    Result := FGLFWSetMouseButtonCallback(window, callback)
  else
    raise ENullPointerException.Create('glfwSetMouseButtonCallback');
end;

function TGLFW.glfwSetCursorPosCallback(window: PGLFWwindow; callback: TGLFWcursorposfun): TGLFWcursorposfun;
begin
  if Assigned(FGLFWSetCursorPosCallback) then
    Result := FGLFWSetCursorPosCallback(window, callback)
  else
    raise ENullPointerException.Create('glfwSetCursorPosCallback');
end;

function TGLFW.glfwSetCursorEnterCallback(window: PGLFWwindow; callback: TGLFWcursorenterfun): TGLFWcursorenterfun;
begin
  if Assigned(FGLFWSetCursorEnterCallback) then
    Result := FGLFWSetCursorEnterCallback(window, callback)
  else
    raise ENullPointerException.Create('glfwSetCursorEnterCallback');
end;

function TGLFW.glfwSetScrollCallback(window: PGLFWwindow; callback: TGLFWscrollfun): TGLFWscrollfun;
begin
  if Assigned(FGLFWSetScrollCallback) then
    Result := FGLFWSetScrollCallback(window, callback)
  else
    raise ENullPointerException.Create('glfwSetScrollCallback');
end;

function TGLFW.glfwSetDropCallback(window: PGLFWwindow; callback: TGLFWdropfun): TGLFWdropfun;
begin
  if Assigned(FGLFWSetDropCallback) then
    Result := FGLFWSetDropCallback(window, callback)
  else
    raise ENullPointerException.Create('glfwSetDropCallback');
end;

function TGLFW.glfwJoystickPresent(jid: integer): integer;
begin
  if Assigned(FGLFWJoystickPresent) then
    Result := FGLFWJoystickPresent(jid)
  else
    raise ENullPointerException.Create('glfwJoystickPresent');
end;

function TGLFW.glfwGetJoystickAxes(jid: integer; Count: PInteger): PSingle;
begin
  if Assigned(FGLFWGetJoystickAxes) then
    Result := FGLFWGetJoystickAxes(jid, Count)
  else
    raise ENullPointerException.Create('glfwGetJoystickAxes');
end;

function TGLFW.glfwGetJoystickButtons(jid: integer; Count: PInteger): pbyte;
begin
  if Assigned(FGLFWGetJoystickButtons) then
    Result := FGLFWGetJoystickButtons(jid, Count)
  else
    raise ENullPointerException.Create('glfwGetJoystickButtons');
end;

function TGLFW.glfwGetJoystickHats(jid: integer; Count: PInteger): pbyte;
begin
  if Assigned(FGLFWGetJoystickHats) then
    Result := FGLFWGetJoystickHats(jid, Count)
  else
    raise ENullPointerException.Create('glfwGetJoystickHats');
end;

function TGLFW.glfwGetJoystickName(jid: integer): pchar;
begin
  if Assigned(FGLFWGetJoystickName) then
    Result := FGLFWGetJoystickName(jid)
  else
    raise ENullPointerException.Create('glfwGetJoystickName');
end;

function TGLFW.glfwGetJoystickGUID(jid: integer): pchar;
begin
  if Assigned(FGLFWGetJoystickGUID) then
    Result := FGLFWGetJoystickGUID(jid)
  else
    raise ENullPointerException.Create('glfwGetJoystickGUID');
end;

procedure TGLFW.glfwSetJoystickUserPointer(jid: integer; userpointer: Pointer);
begin
  if Assigned(FGLFWSetJoystickUserPointer) then
    FGLFWSetJoystickUserPointer(jid, userpointer)
  else
    raise ENullPointerException.Create('glfwSetJoystickUserPointer');
end;

function TGLFW.glfwGetJoystickUserPointer(jid: integer): Pointer;
begin
  if Assigned(FGLFWGetJoystickUserPointer) then
    Result := FGLFWGetJoystickUserPointer(jid)
  else
    raise ENullPointerException.Create('glfwGetJoystickUserPointer');
end;

function TGLFW.glfwJoystickIsGamepad(jid: integer): integer;
begin
  if Assigned(FGLFWJoystickIsGamepad) then
    Result := FGLFWJoystickIsGamepad(jid)
  else
    raise ENullPointerException.Create('glfwJoystickIsGamepad');
end;

function TGLFW.glfwSetJoystickCallback(callback: TGLFWjoystickfun): TGLFWjoystickfun;
begin
  if Assigned(FGLFWSetJoystickCallback) then
    Result := FGLFWSetJoystickCallback(callback)
  else
    raise ENullPointerException.Create('glfwSetJoystickCallback');
end;

function TGLFW.glfwUpdateGamepadMappings(const str: pchar): integer;
begin
  if Assigned(FGLFWUpdateGamepadMappings) then
    Result := FGLFWUpdateGamepadMappings(str)
  else
    raise ENullPointerException.Create('glfwUpdateGamepadMappings');
end;

function TGLFW.glfwGetGamepadName(jid: integer): pchar;
begin
  if Assigned(FGLFWGetGamepadName) then
    Result := FGLFWGetGamepadName(jid)
  else
    raise ENullPointerException.Create('glfwGetGamepadName');
end;

function TGLFW.glfwGetGamepadState(jid: integer; state: PGLFWgamepadstate): integer;
begin
  if Assigned(FGLFWGetGamepadState) then
    Result := FGLFWGetGamepadState(jid, state)
  else
    raise ENullPointerException.Create('glfwGetGamepadState');
end;

procedure TGLFW.glfwSetClipboardString(window: PGLFWwindow; const str: pchar);
begin
  if Assigned(FGLFWSetClipboardString) then
    FGLFWSetClipboardString(window, str)
  else
    raise ENullPointerException.Create('glfwSetClipboardString');
end;

function TGLFW.glfwGetClipboardString(window: PGLFWwindow): pchar;
begin
  if Assigned(FGLFWGetClipboardString) then
    Result := FGLFWGetClipboardString(window)
  else
    raise ENullPointerException.Create('glfwGetClipboardString');
end;

function TGLFW.glfwGetTime(): double;
begin
  if Assigned(FGLFWGetTime) then
    Result := FGLFWGetTime()
  else
    raise ENullPointerException.Create('glfwGetTime');
end;

procedure TGLFW.glfwSetTime(time: double);
begin
  if Assigned(FGLFWSetTime) then
    FGLFWSetTime(time)
  else
    raise ENullPointerException.Create('glfwSetTime');
end;

function TGLFW.glfwGetTimerValue(): uint64;
begin
  if Assigned(FGLFWGetTimerValue) then
    Result := FGLFWGetTimerValue()
  else
    raise ENullPointerException.Create('glfwGetTimerValue');
end;

function TGLFW.glfwGetTimerFrequency(): uint64;
begin
  if Assigned(FGLFWGetTimerFrequency) then
    Result := FGLFWGetTimerFrequency()
  else
    raise ENullPointerException.Create('glfwGetTimerFrequency');
end;

procedure TGLFW.glfwMakeContextCurrent(window: PGLFWwindow);
begin
  if Assigned(FGLFWMakeContextCurrent) then
    FGLFWMakeContextCurrent(window)
  else
    raise ENullPointerException.Create('glfwMakeContextCurrent');
end;

function TGLFW.glfwGetCurrentContext(): PGLFWwindow;
begin
  if Assigned(FGLFWGetCurrentContext) then
    Result := FGLFWGetCurrentContext()
  else
    raise ENullPointerException.Create('glfwGetCurrentContext');
end;

procedure TGLFW.glfwSwapBuffers(window: PGLFWwindow);
begin
  if Assigned(FGLFWSwapBuffers) then
    FGLFWSwapBuffers(window)
  else
    raise ENullPointerException.Create('glfwSwapBuffers');
end;

procedure TGLFW.glfwSwapInterval(interval: integer);
begin
  if Assigned(FGLFWSwapInterval) then
    FGLFWSwapInterval(interval)
  else
    raise ENullPointerException.Create('glfwSwapInterval');
end;

function TGLFW.glfwExtensionSupported(const extension: pchar): integer;
begin
  if Assigned(FGLFWExtensionSupported) then
    Result := FGLFWExtensionSupported(extension)
  else
    raise ENullPointerException.Create('glfwExtensionSupported');
end;

function TGLFW.glfwGetProcAddress(const procname: pchar): TGLFWGLProc;
begin
  if Assigned(FGLFWGetProcAddress) then
    Result := FGLFWGetProcAddress(procname)
  else
    raise ENullPointerException.Create('glfwGetProcAddress');
end;

function TGLFW.glfwVulkanSupported(): integer;
begin
  if Assigned(FGLFWVulkanSupported) then
    Result := FGLFWVulkanSupported()
  else
    raise ENullPointerException.Create('glfwVulkanSupported');
end;

function TGLFW.glfwGetRequiredInstanceExtensions(var Count: cardinal): ppchar;
begin
  if Assigned(FGLFWGetRequiredInstanceExtensions) then
    Result := FGLFWGetRequiredInstanceExtensions(Count)
  else
    raise ENullPointerException.Create('glfwGetRequiredInstanceExtensions');
end;

{$IFDEF VK_VERSION_1_0}
function TGLFW.glfwGetInstanceProcAddress(instance: VkInstance; const procname: pchar): TGLFWVKProc;
begin
  if Assigned(FGLFWGetInstanceProcAddress) then
    Result := FGLFWGetInstanceProcAddress(instance, procname)
  else
    raise ENullPointerException.Create('glfwGetInstanceProcAddress');
end;

function TGLFW.glfwGetPhysicalDevicePresentationSupport(instance: VkInstance; device: VkPhysicalDevice; queuefamily: Cardinal): Integer;
begin
  if Assigned(FGLFWGetPhysicalDevicePresentationSupport) then
    Result := FGLFWGetPhysicalDevicePresentationSupport(instance, device, queuefamily)
  else
    raise ENullPointerException.Create('glfwGetPhysicalDevicePresentationSupport');
end;

function TGLFW.glfwCreateWindowSurface(instance: VkInstance; window: PGLFWwindow;
  const allocator: PVkAllocationCallbacks; surface: PVkSurfaceKHR): TVkResult;
begin
  if Assigned(FGLFWCreateWindowSurface) then
    Result := FGLFWCreateWindowSurface(instance, window, allocator, surface)
  else
    raise ENullPointerException.Create('glfwCreateWindowSurface');
end;
{$ENDIF}

{$IFDEF GLFW3_LASTEST}
procedure TGLFW.glfwInitAllocator(allocator: PGLFWallocator);
begin
  if Assigned(FGLFWInitAllocator) then
    FGLFWInitAllocator(allocator)
  else
    raise ENullPointerException.Create('glfwInitAllocator');
end;

procedure TGLFW.glfwInitVulkanLoader(loader: TGLFWVKProc);
begin
  if Assigned(FGLFWInitVulkanLoader) then
    FGLFWInitVulkanLoader(loader)
  else
    raise ENullPointerException.Create('glfwInitVulkanLoader');
end;

function TGLFW.glfwGetPlatform(): Integer;
begin
  if Assigned(FGLFWGetPlatform) then
    Result := FGLFWGetPlatform()
  else
    raise ENullPointerException.Create('glfwGetPlatform');
end;

function TGLFW.glfwPlatformSupported(platform: Integer): Integer;
begin
  if Assigned(FGLFWPlatformSupported) then
    Result := FGLFWPlatformSupported(platform)
  else
    raise ENullPointerException.Create('glfwPlatformSupported');
end;

function TGLFW.glfwGetWindowTitle(window: PGLFWwindow): pchar;
begin
  if Assigned(FGLFWGetWindowTitle) then
    Result := FGLFWGetWindowTitle(window)
  else
    raise ENullPointerException.Create('glfwGetWindowTitle');
end;
{$ENDIF}

// ===================================================================
// MONITOR - IMPLEMENTAZIONI MANCANTI
// ===================================================================

function TGLFW.glfwGetMonitors(out Count: integer): PPGLFWmonitor;
begin
  if Assigned(FGLFWGetMonitors) then
    Result := FGLFWGetMonitors(@Count)
  else
    raise ENullPointerException.Create('glfwGetMonitors');
end;

function TGLFW.glfwGetPrimaryMonitor(): PGLFWmonitor;
begin
  if Assigned(FGLFWGetPrimaryMonitor) then
    Result := FGLFWGetPrimaryMonitor()
  else
    raise ENullPointerException.Create('glfwGetPrimaryMonitor');
end;

procedure TGLFW.glfwGetMonitorPos(monitor: PGLFWmonitor; xpos, ypos: PInteger);
begin
  if Assigned(FGLFWGetMonitorPos) then
    FGLFWGetMonitorPos(monitor, xpos, ypos)
  else
    raise ENullPointerException.Create('glfwGetMonitorPos');
end;

procedure TGLFW.glfwGetMonitorWorkarea(monitor: PGLFWmonitor; xpos, ypos, Width, Height: PInteger);
begin
  if Assigned(FGLFWGetMonitorWorkarea) then
    FGLFWGetMonitorWorkarea(monitor, xpos, ypos, Width, Height)
  else
    raise ENullPointerException.Create('glfwGetMonitorWorkarea');
end;

procedure TGLFW.glfwGetMonitorPhysicalSize(monitor: PGLFWmonitor; widthMM, heightMM: PInteger);
begin
  if Assigned(FGLFWGetMonitorPhysicalSize) then
    FGLFWGetMonitorPhysicalSize(monitor, widthMM, heightMM)
  else
    raise ENullPointerException.Create('glfwGetMonitorPhysicalSize');
end;

procedure TGLFW.glfwGetMonitorContentScale(monitor: PGLFWmonitor; xscale, yscale: PSingle);
begin
  if Assigned(FGLFWGetMonitorContentScale) then
    FGLFWGetMonitorContentScale(monitor, xscale, yscale)
  else
    raise ENullPointerException.Create('glfwGetMonitorContentScale');
end;

function TGLFW.glfwGetMonitorName(monitor: PGLFWmonitor): pchar;
begin
  if Assigned(FGLFWGetMonitorName) then
    Result := FGLFWGetMonitorName(monitor)
  else
    raise ENullPointerException.Create('glfwGetMonitorName');
end;

procedure TGLFW.glfwSetMonitorUserPointer(monitor: PGLFWmonitor; user: Pointer);
begin
  if Assigned(FGLFWSetMonitorUserPointer) then
    FGLFWSetMonitorUserPointer(monitor, user)
  else
    raise ENullPointerException.Create('glfwSetMonitorUserPointer');
end;

function TGLFW.glfwGetMonitorUserPointer(monitor: PGLFWmonitor): Pointer;
begin
  if Assigned(FGLFWGetMonitorUserPointer) then
    Result := FGLFWGetMonitorUserPointer(monitor)
  else
    raise ENullPointerException.Create('glfwGetMonitorUserPointer');
end;

function TGLFW.glfwSetMonitorCallback(callback: TGLFWmonitorfun): TGLFWmonitorfun;
begin
  if Assigned(FGLFWSetMonitorCallback) then
    Result := FGLFWSetMonitorCallback(callback)
  else
    raise ENullPointerException.Create('glfwSetMonitorCallback');
end;

function TGLFW.glfwGetVideoModes(monitor: PGLFWmonitor; var Count: integer): PGLFWvidmode;
begin
  if Assigned(FGLFWGetVideoModes) then
    Result := FGLFWGetVideoModes(monitor, Count)
  else
    raise ENullPointerException.Create('glfwGetVideoModes');
end;

function TGLFW.glfwGetVideoMode(monitor: PGLFWmonitor): PGLFWvidmode;
begin
  if Assigned(FGLFWGetVideoMode) then
    Result := FGLFWGetVideoMode(monitor)
  else
    raise ENullPointerException.Create('glfwGetVideoMode');
end;

procedure TGLFW.glfwSetGamma(monitor: PGLFWmonitor; gamma: single);
begin
  if Assigned(FGLFWSetGamma) then
    FGLFWSetGamma(monitor, gamma)
  else
    raise ENullPointerException.Create('glfwSetGamma');
end;

function TGLFW.glfwGetGammaRamp(monitor: PGLFWmonitor): PGLFWgammaramp;
begin
  if Assigned(FGLFWGetGammaRamp) then
    Result := FGLFWGetGammaRamp(monitor)
  else
    raise ENullPointerException.Create('glfwGetGammaRamp');
end;

procedure TGLFW.glfwSetGammaRamp(monitor: PGLFWmonitor; const ramp: PGLFWgammaramp);
begin
  if Assigned(FGLFWSetGammaRamp) then
    FGLFWSetGammaRamp(monitor, ramp)
  else
    raise ENullPointerException.Create('glfwSetGammaRamp');
end;

initialization
  singleton := nil;


finalization

  singleton := nil;

end.
