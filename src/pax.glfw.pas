unit pax.glfw;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, dynlibs;

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
    function glfwError(const description: PPChar): integer;
    function glfwSetErrorCallback(cbfun: TGLFWerrorfun): TGLFWerrorfun;
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
    procedure glfwGetMonitorUserPointer(monitor: PGLFWmonitor);
    function glfwSetMonitorCallback(cbfun: TGLFWmonitorfun): TGLFWmonitorfun;
    function glfwGetVideoModes(monitor: PGLFWmonitor; out Count: PInteger): PGLFWvidmode;
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
    function glfwGetRequiredInstanceExtensions(out Count: uint32): PPChar;
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
  { TGLFW }

  TGLFW = class(TInterfacedObject, IGLFW)
  protected
  type
    // Core
    TglfwInit = function: integer; cdecl;
    TglfwTerminate = procedure; cdecl;
    TglfwGetVersionString = function: pansichar; cdecl;

    // Window management
    TglfwWindowHint = procedure(hint: integer; Value: integer); cdecl;
    TglfwCreateWindow = function(Width: integer; Height: integer; const title: pansichar; monitor: PGLFWmonitor; share: PGLFWwindow): PGLFWwindow; cdecl;
    TglfwDestroyWindow = procedure(window: PGLFWwindow); cdecl;
    TglfwWindowShouldClose = function(window: PGLFWwindow): integer; cdecl;
    TglfwSetWindowShouldClose = procedure(window: PGLFWwindow; Value: integer); cdecl;
    TglfwPollEvents = procedure; cdecl;
    TglfwWaitEvents = procedure; cdecl;
    TglfwWaitEventsTimeout = procedure(timeout: double); cdecl;
    TglfwPostEmptyEvent = procedure; cdecl;
    TglfwSwapBuffers = procedure(window: PGLFWwindow); cdecl;
    TglfwMakeContextCurrent = procedure(window: PGLFWwindow); cdecl;
    TglfwGetCurrentContext = function: PGLFWwindow; cdecl;
    TglfwSwapInterval = procedure(interval: integer); cdecl;
    TglfwGetFramebufferSize = procedure(window: PGLFWwindow; Width: PInteger; Height: PInteger); cdecl;

    // Input
    TglfwGetKey = function(window: PGLFWwindow; key: integer): integer; cdecl;
    TglfwGetMouseButton = function(window: PGLFWwindow; button: integer): integer; cdecl;
    TglfwGetCursorPos = procedure(window: PGLFWwindow; xpos: PDouble; ypos: PDouble); cdecl;
    TglfwSetCursorPos = procedure(window: PGLFWwindow; xpos: double; ypos: double); cdecl;

    // Callbacks
    TglfwSetKeyCallback = function(window: PGLFWwindow; callback: TGLFWkeyfun): TGLFWkeyfun; cdecl;
    TglfwSetCharCallback = function(window: PGLFWwindow; callback: TGLFWcharfun): TGLFWcharfun; cdecl;
    TglfwSetMouseButtonCallback = function(window: PGLFWwindow; callback: TGLFWmousebuttonfun): TGLFWmousebuttonfun; cdecl;
    TglfwSetCursorPosCallback = function(window: PGLFWwindow; callback: TGLFWcursorposfun): TGLFWcursorposfun; cdecl;
    TglfwSetScrollCallback = function(window: PGLFWwindow; callback: TGLFWscrollfun): TGLFWscrollfun; cdecl;
    TglfwSetDropCallback = function(window: PGLFWwindow; callback: TGLFWdropfun): TGLFWdropfun; cdecl;

    // Cursor
    TglfwCreateCursor = function(const image: PGLFWimage; xhot, yhot: integer): PGLFWcursor; cdecl;
    TglfwCreateStandardCursor = function(shape: integer): PGLFWcursor; cdecl;
    TglfwDestroyCursor = procedure(cursor: PGLFWcursor); cdecl;
    TglfwSetCursor = procedure(window: PGLFWwindow; cursor: PGLFWcursor); cdecl;

    // Clipboard
    TglfwSetClipboardString = procedure(window: PGLFWwindow; const str: pansichar); cdecl;
    TglfwGetClipboardString = function(window: PGLFWwindow): pansichar; cdecl;

    // Timer
    TglfwGetTime = function: double; cdecl;
    TglfwSetTime = procedure(time: double); cdecl;
    TglfwGetTimerValue = function: uint64; cdecl;
    TglfwGetTimerFrequency = function: uint64; cdecl;

    // OpenGL / Vulkan
    TglfwExtensionSupported = function(const extension: pansichar): integer; cdecl;
    TglfwGetProcAddress = function(const procname: pansichar): Pointer; cdecl;
    TglfwVulkanSupported = function: integer; cdecl;
    TglfwGetRequiredInstanceExtensions = function(Count: PCardinal): PPAnsiChar; cdecl;
    TglfwCreateWindowSurface = function(instance: Pointer; window: PGLFWwindow; const allocator: Pointer; surface: PPointer): integer; cdecl;

    // 3.4+ funzioni moderne
    TglfwSetWindowAttrib = procedure(window: PGLFWwindow; attrib: integer; Value: integer); cdecl;
    TglfwGetWindowAttrib = function(window: PGLFWwindow; attrib: integer): integer; cdecl;
    TglfwSetWindowAspectRatio = procedure(window: PGLFWwindow; numer, denom: integer); cdecl;
    TglfwSetWindowSizeLimits = procedure(window: PGLFWwindow; minwidth, minheight, maxwidth, maxheight: integer); cdecl;

    // Joystick / Gamepad
    TglfwJoystickPresent = function(joy: integer): integer; cdecl;
    TglfwGetJoystickAxes = function(joy: integer; Count: PInteger): PSingle; cdecl;
    TglfwGetJoystickButtons = function(joy: integer; Count: PInteger): pbyte; cdecl;
    TglfwGetJoystickHats = function(joy: integer; Count: PInteger): pbyte; cdecl;
    TglfwGetJoystickName = function(joy: integer): pansichar; cdecl;
    TglfwGetGamepadState = function(joy: integer; state: PGLFWgamepadstate): integer; cdecl;
  protected
    FglfwInit: TglfwInit;
    FglfwTerminate: TglfwTerminate;
    FglfwGetVersionString: TglfwGetVersionString;

    // Window
    FglfwWindowHint: TglfwWindowHint;
    FglfwCreateWindow: TglfwCreateWindow;
    FglfwDestroyWindow: TglfwDestroyWindow;
    FglfwWindowShouldClose: TglfwWindowShouldClose;
    FglfwSetWindowShouldClose: TglfwSetWindowShouldClose;
    FglfwPollEvents: TglfwPollEvents;
    FglfwWaitEvents: TglfwWaitEvents;
    FglfwSwapBuffers: TglfwSwapBuffers;
    FglfwMakeContextCurrent: TglfwMakeContextCurrent;
    FglfwGetCurrentContext: TglfwGetCurrentContext;
    FglfwSwapInterval: TglfwSwapInterval;
    FglfwGetFramebufferSize: TglfwGetFramebufferSize;

    // Input
    FglfwGetKey: TglfwGetKey;
    FglfwGetMouseButton: TglfwGetMouseButton;
    FglfwGetCursorPos: TglfwGetCursorPos;
    FglfwSetCursorPos: TglfwSetCursorPos;

    // Callbacks
    FglfwSetKeyCallback: TglfwSetKeyCallback;
    FglfwSetCharCallback: TglfwSetCharCallback;
    FglfwSetMouseButtonCallback: TglfwSetMouseButtonCallback;
    FglfwSetCursorPosCallback: TglfwSetCursorPosCallback;
    FglfwSetScrollCallback: TglfwSetScrollCallback;
    FglfwSetDropCallback: TglfwSetDropCallback;

    // Cursor & Clipboard
    FglfwCreateCursor: TglfwCreateCursor;
    FglfwCreateStandardCursor: TglfwCreateStandardCursor;
    FglfwDestroyCursor: TglfwDestroyCursor;
    FglfwSetCursor: TglfwSetCursor;
    FglfwSetClipboardString: TglfwSetClipboardString;
    FglfwGetClipboardString: TglfwGetClipboardString;

    // Timer
    FglfwGetTime: TglfwGetTime;
    FglfwSetTime: TglfwSetTime;

    // Vulkan / OpenGL
    FglfwExtensionSupported: TglfwExtensionSupported;
    FglfwGetProcAddress: TglfwGetProcAddress;
    FglfwVulkanSupported: TglfwVulkanSupported;
    FglfwGetRequiredInstanceExtensions: TglfwGetRequiredInstanceExtensions;
    FglfwCreateWindowSurface: TglfwCreateWindowSurface;

    // 3.4+
    FglfwSetWindowAttrib: TglfwSetWindowAttrib;
    FglfwGetWindowAttrib: TglfwGetWindowAttrib;
    FglfwSetWindowAspectRatio: TglfwSetWindowAspectRatio;
    FglfwSetWindowSizeLimits: TglfwSetWindowSizeLimits;

    // Joystick
    FglfwJoystickPresent: TglfwJoystickPresent;
    FglfwGetJoystickAxes: TglfwGetJoystickAxes;
    FglfwGetJoystickButtons: TglfwGetJoystickButtons;
    FglfwGetJoystickHats: TglfwGetJoystickHats;
    FglfwGetJoystickName: TglfwGetJoystickName;
    FglfwGetGamepadState: TglfwGetGamepadState;
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
{$ENDIF} {$ENDIF}
    procedure glfwGetVersion(major, minor, rev: PInteger); virtual;
    function glfwGetVersionString(): pchar; virtual;
    function glfwError(const description: PPChar): integer; virtual;
    function glfwSetErrorCallback(cbfun: TGLFWerrorfun): TGLFWerrorfun; virtual;
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
    procedure glfwGetMonitorUserPointer(monitor: PGLFWmonitor); virtual;
    function glfwSetMonitorCallback(cbfun: TGLFWmonitorfun): TGLFWmonitorfun; virtual;
    function glfwGetVideoModes(monitor: PGLFWmonitor; out Count: PInteger): PGLFWvidmode; virtual;
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
    function glfwUpdateGamepadMappings(const string_: pchar): integer; virtual;
    function glfwGetGamepadName(jId: integer): pchar; virtual;
    function glfwGetGamepadState(jId: integer; state: PGLFWgamepadstate): integer; virtual;
    procedure glfwSetClipboardString(window: PGLFWwindow; const Text: pchar); virtual;
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
    function glfwGetRequiredInstanceExtensions(out Count: uint32): PPChar; virtual;
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
  if FHandle = NilHandle then
    raise Exception.Create('Impossibile caricare la libreria GLFW');

  // Core
  Bind(FGLFWInit, 'glfwInit');
  Bind(FGLFWTerminate, 'glfwTerminate');
  Bind(FGLFWGetVersionString, 'glfwGetVersionString');

  // Window
  Bind(FGLFWCreateWindow, 'glfwCreateWindow');
  Bind(FGLFWDestroyWindow, 'glfwDestroyWindow');
  Bind(FGLFWWindowShouldClose, 'glfwWindowShouldClose');
  Bind(FGLFWSetWindowShouldClose, 'glfwSetWindowShouldClose');
  Bind(FGLFWPollEvents, 'glfwPollEvents');
  Bind(FGLFWWaitEvents, 'glfwWaitEvents');
  Bind(FGLFWSwapBuffers, 'glfwSwapBuffers');
  Bind(FGLFWMakeContextCurrent, 'glfwMakeContextCurrent');
  Bind(FGLFWGetCurrentContext, 'glfwGetCurrentContext');
  Bind(FGLFWSwapInterval, 'glfwSwapInterval');
  Bind(FGLFWWindowHint, 'glfwWindowHint');
  Bind(FGLFWGetFramebufferSize, 'glfwGetFramebufferSize');

  // Input
  Bind(FGLFWGetKey, 'glfwGetKey');
  Bind(FGLFWGetMouseButton, 'glfwGetMouseButton');
  Bind(FGLFWGetCursorPos, 'glfwGetCursorPos');
  Bind(FGLFWSetCursorPos, 'glfwSetCursorPos');

  // Callbacks
  Bind(FGLFWSetKeyCallback, 'glfwSetKeyCallback');
  Bind(FGLFWSetMouseButtonCallback, 'glfwSetMouseButtonCallback');
  Bind(FGLFWSetCursorPosCallback, 'glfwSetCursorPosCallback');
  Bind(FGLFWSetScrollCallback, 'glfwSetScrollCallback');
  Bind(FGLFWSetCharCallback, 'glfwSetCharCallback');
  Bind(FGLFWSetDropCallback, 'glfwSetDropCallback');

  // Vulkan
  Bind(FGLFWVulkanSupported, 'glfwVulkanSupported');
  Bind(FGLFWGetRequiredInstanceExtensions, 'glfwGetRequiredInstanceExtensions');
  Bind(FGLFWCreateWindowSurface, 'glfwCreateWindowSurface');

  // 3.4+ funzioni
  Bind(FGLFWSetWindowAttrib, 'glfwSetWindowAttrib');
  Bind(FGLFWGetWindowAttrib, 'glfwGetWindowAttrib');
  Bind(FGLFWSetWindowAspectRatio, 'glfwSetWindowAspectRatio');
  Bind(FGLFWSetWindowSizeLimits, 'glfwSetWindowSizeLimits');

  // Timer
  Bind(FGLFWGetTime, 'glfwGetTime');
  Bind(FGLFWSetTime, 'glfwSetTime');

  // Clipboard
  Bind(FGLFWSetClipboardString, 'glfwSetClipboardString');
  Bind(FGLFWGetClipboardString, 'glfwGetClipboardString');

  // Cursor (3.1+)
  Bind(FGLFWCreateStandardCursor, 'glfwCreateStandardCursor');
  Bind(FGLFWCreateCursor, 'glfwCreateCursor');
  Bind(FGLFWDestroyCursor, 'glfwDestroyCursor');
  Bind(FGLFWSetCursor, 'glfwSetCursor');

  // Joystick/Gamepad
  Bind(FGLFWJoystickPresent, 'glfwJoystickPresent');
  Bind(FGLFWGetJoystickAxes, 'glfwGetJoystickAxes');
  Bind(FGLFWGetJoystickButtons, 'glfwGetJoystickButtons');
  Bind(FGLFWGetJoystickHats, 'glfwGetJoystickHats');
  Bind(FGLFWGetJoystickName, 'glfwGetJoystickName');
  Bind(FGLFWGetGamepadState, 'glfwGetGamepadState');

  // OpenGL proc
  Bind(FGLFWGetProcAddress, 'glfwGetProcAddress');
  Bind(FGLFWExtensionSupported, 'glfwExtensionSupported');
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

end;

procedure TGLFW.glfwTerminate();
begin

end;

procedure TGLFW.glfwInitHint(hint, Value: integer);
begin

end;

procedure TGLFW.glfwGetVersion(major, minor, rev: PInteger);
begin

end;

function TGLFW.glfwGetVersionString(): pchar;
begin

end;

function TGLFW.glfwError(const description: PPChar): integer;
begin

end;

function TGLFW.glfwSetErrorCallback(cbfun: TGLFWerrorfun): TGLFWerrorfun;
begin

end;

function TGLFW.glfwGetMonitors(out Count: integer): PPGLFWmonitor;
begin

end;

function TGLFW.glfwGetPrimaryMonitor(): PGLFWmonitor;
begin

end;

procedure TGLFW.glfwGetMonitorPos(monitor: PGLFWmonitor; xpos, ypos: PInteger);
begin

end;

procedure TGLFW.glfwGetMonitorWorkarea(monitor: PGLFWmonitor; xpos, ypos, Width, Height: PInteger);
begin

end;

procedure TGLFW.glfwGetMonitorPhysicalSize(monitor: PGLFWmonitor; widthMM, heightMM: PInteger);
begin

end;

procedure TGLFW.glfwGetMonitorContentScale(monitor: PGLFWmonitor; xscale, yscale: PSingle);
begin

end;

function TGLFW.glfwGetMonitorName(monitor: PGLFWmonitor): pchar;
begin

end;

procedure TGLFW.glfwSetMonitorUserPointer(monitor: PGLFWmonitor; user: Pointer);
begin

end;

procedure TGLFW.glfwGetMonitorUserPointer(monitor: PGLFWmonitor);
begin

end;

function TGLFW.glfwSetMonitorCallback(cbfun: TGLFWmonitorfun): TGLFWmonitorfun;
begin

end;

function TGLFW.glfwGetVideoModes(monitor: PGLFWmonitor; out Count: PInteger): PGLFWvidmode;
begin

end;

function TGLFW.glfwGetVideoMode(monitor: PGLFWmonitor): PGLFWvidmode;
begin

end;

procedure TGLFW.glfwSetGamma(monitor: PGLFWmonitor; gamma: single);
begin

end;

function TGLFW.glfwGetGammaRamp(monitor: PGLFWmonitor): PGLFWgammaramp;
begin

end;

procedure TGLFW.glfwSetGammaRamp(monitor: PGLFWmonitor; const ramp: PGLFWgammaramp);
begin

end;

procedure TGLFW.glfwDefaultWindowHints();
begin

end;

procedure TGLFW.glfwWindowHint(hint, Value: integer);
begin

end;

procedure TGLFW.glfwWindowHintString(hint: integer; Value: pchar);
begin

end;

function TGLFW.glfwCreateWindow(Width, Height: integer; const title: pchar; monitor: PGLFWmonitor; share: PGLFWwindow): PGLFWwindow;
begin

end;

procedure TGLFW.glfwDestroyWindow(window: PGLFWwindow);
begin

end;

function TGLFW.glfwWindowShouldClose(window: PGLFWwindow): integer;
begin

end;

procedure TGLFW.glfwSetWindowShouldClose(window: PGLFWwindow; Value: integer);
begin

end;

procedure TGLFW.glfwSetWindowTitle(window: PGLFWwindow; const title: pchar);
begin

end;

procedure TGLFW.glfwSetWindowIcon(window: PGLFWwindow; Count: integer; const images: PGLFWimage);
begin

end;

procedure TGLFW.glfwGetWindowPos(window: PGLFWwindow; xpos, ypos: PInteger);
begin

end;

procedure TGLFW.glfwSetWindowPos(window: PGLFWwindow; xpos, ypos: integer);
begin

end;

procedure TGLFW.glfwGetWindowSize(window: PGLFWwindow; Width, Height: PInteger);
begin

end;

procedure TGLFW.glfwSetWindowSizeLimits(window: PGLFWwindow; minwidth, minheight, maxwidth, maxheight: integer);
begin

end;

procedure TGLFW.glfwSetWindowAspectRatio(window: PGLFWwindow; numer, denom: integer);
begin

end;

procedure TGLFW.glfwSetWindowSize(window: PGLFWwindow; Width, Height: integer);
begin

end;

procedure TGLFW.glfwGetFramebufferSize(window: PGLFWwindow; Width, Height: PInteger);
begin

end;

procedure TGLFW.glfwGetWindowFrameSize(window: PGLFWwindow; left, top, right, bottom: PInteger);
begin

end;

procedure TGLFW.glfwGetWindowContentScale(window: PGLFWwindow; xscale, yscale: PSingle);
begin

end;

function TGLFW.glfwGetWindowOpacity(window: PGLFWwindow): single;
begin

end;

procedure TGLFW.glfwSetWindowOpacity(window: PGLFWwindow; opacity: single);
begin

end;

procedure TGLFW.glfwIconifyWindow(window: PGLFWwindow);
begin

end;

procedure TGLFW.glfwRestoreWindow(window: PGLFWwindow);
begin

end;

procedure TGLFW.glfwMaximizeWindow(window: PGLFWwindow);
begin

end;

procedure TGLFW.glfwShowWindow(window: PGLFWwindow);
begin

end;

procedure TGLFW.glfwHideWindow(window: PGLFWwindow);
begin

end;

procedure TGLFW.glfwFocusWindow(window: PGLFWwindow);
begin

end;

procedure TGLFW.glfwRequestWindowAttention(window: PGLFWwindow);
begin

end;

function TGLFW.glfwGetWindowMonitor(window: PGLFWwindow): PGLFWmonitor;
begin

end;

procedure TGLFW.glfwSetWindowMonitor(window: PGLFWwindow; monitor: PGLFWmonitor; xpos, ypos, Width, Height, refreshRate: integer);
begin

end;

function TGLFW.glfwGetWindowAttrib(window: PGLFWwindow; attrib: integer): integer;
begin

end;

procedure TGLFW.glfwSetWindowAttrib(window: PGLFWwindow; attrib, Value: integer);
begin

end;

procedure TGLFW.glfwSetWindowUserPointer(window: PGLFWwindow; userpointer: Pointer);
begin

end;

function TGLFW.glfwGetWindowUserPointer(window: PGLFWwindow): Pointer;
begin

end;

function TGLFW.glfwSetWindowPosCallback(window: PGLFWwindow; callback: TGLFWwindowposfun): TGLFWwindowposfun;
begin

end;

function TGLFW.glfwSetWindowSizeCallback(window: PGLFWwindow; callback: TGLFWwindowsizefun): TGLFWwindowsizefun;
begin

end;

function TGLFW.glfwSetWindowCloseCallback(window: PGLFWwindow; callback: TGLFWwindowclosefun): TGLFWwindowclosefun;
begin

end;

function TGLFW.glfwSetWindowRefreshCallback(window: PGLFWwindow; callback: TGLFWwindowrefreshfun): TGLFWwindowrefreshfun;
begin

end;

function TGLFW.glfwSetWindowFocusCallback(window: PGLFWwindow; callback: TGLFWwindowfocusfun): TGLFWwindowfocusfun;
begin

end;

function TGLFW.glfwSetWindowIconifyCallback(window: PGLFWwindow; callback: TGLFWwindowiconifyfun): TGLFWwindowiconifyfun;
begin

end;

function TGLFW.glfwSetWindowMaximizeCallback(window: PGLFWwindow; callback: TGLFWwindowmaximizefun): TGLFWwindowmaximizefun;
begin

end;

function TGLFW.glfwSetFramebufferSizeCallback(window: PGLFWwindow; callback: TGLFWframebuffersizefun): TGLFWframebuffersizefun;
begin

end;

function TGLFW.glfwSetWindowContentScaleCallback(window: PGLFWwindow; callback: TGLFWwindowcontentscalefun): TGLFWwindowcontentscalefun;
begin

end;

procedure TGLFW.glfwPollEvents();
begin

end;

procedure TGLFW.glfwWaitEvents();
begin

end;

procedure TGLFW.glfwWaitEventsTimeout(timeout: double);
begin

end;

procedure TGLFW.glfwPostEmptyEvent();
begin

end;

function TGLFW.glfwGetInputMode(window: PGLFWwindow; mode: integer): integer;
begin

end;

procedure TGLFW.glfwSetInputMode(window: PGLFWwindow; mode, Value: integer);
begin

end;

function TGLFW.glfwRawMouseMotionSupported(): integer;
begin

end;

function TGLFW.glfwGetKeyName(key, scancode: integer): pchar;
begin

end;

function TGLFW.glfwGetKeyScancode(key: integer): integer;
begin

end;

function TGLFW.glfwGetKey(window: PGLFWwindow; key: integer): integer;
begin

end;

function TGLFW.glfwGetMouseButton(window: PGLFWwindow; button: integer): integer;
begin

end;

procedure TGLFW.glfwGetCursorPos(window: PGLFWwindow; xpos, ypos: PDouble);
begin

end;

procedure TGLFW.glfwSetCursorPos(window: PGLFWwindow; xpos, ypos: double);
begin

end;

function TGLFW.glfwCreateCursor(const image: PGLFWimage; xhot, yhot: integer): PGLFWcursor;
begin

end;

function TGLFW.glfwCreateStandardCursor(shape: integer): PGLFWcursor;
begin

end;

procedure TGLFW.glfwDestroyCursor(cursor: PGLFWcursor);
begin

end;

procedure TGLFW.glfwSetCursor(window: PGLFWwindow; cursor: PGLFWcursor);
begin

end;

function TGLFW.glfwSetKeyCallback(window: PGLFWwindow; callback: TGLFWkeyfun): TGLFWkeyfun;
begin

end;

function TGLFW.glfwSetCharCallback(window: PGLFWwindow; callback: TGLFWcharfun): TGLFWcharfun;
begin

end;

function TGLFW.glfwSetCharModsCallback(window: PGLFWwindow; callback: TGLFWcharmodsfun): TGLFWcharmodsfun;
begin

end;

function TGLFW.glfwSetMouseButtonCallback(window: PGLFWwindow; callback: TGLFWmousebuttonfun): TGLFWmousebuttonfun;
begin

end;

function TGLFW.glfwSetCursorPosCallback(window: PGLFWwindow; callback: TGLFWcursorposfun): TGLFWcursorposfun;
begin

end;

function TGLFW.glfwSetCursorEnterCallback(window: PGLFWwindow; callback: TGLFWcursorenterfun): TGLFWcursorenterfun;
begin

end;

function TGLFW.glfwSetScrollCallback(window: PGLFWwindow; callback: TGLFWscrollfun): TGLFWscrollfun;
begin

end;

function TGLFW.glfwSetDropCallback(window: PGLFWwindow; callback: TGLFWdropfun): TGLFWdropfun;
begin

end;

function TGLFW.glfwJoystickPresent(jId: integer): integer;
begin

end;

function TGLFW.glfwGetJoystickAxes(jId: integer; Count: PInteger): PSingle;
begin

end;

function TGLFW.glfwGetJoystickButtons(jId: integer; Count: PInteger): pbyte;
begin

end;

function TGLFW.glfwGetJoystickHats(jId: integer; Count: PInteger): pbyte;
begin

end;

function TGLFW.glfwGetJoystickName(jId: integer): pchar;
begin

end;

function TGLFW.glfwGetJoystickGUID(jId: integer): pchar;
begin

end;

procedure TGLFW.glfwSetJoystickUserPointer(jId: integer; userPointer: Pointer);
begin

end;

function TGLFW.glfwGetJoystickUserPointer(jId: integer): Pointer;
begin

end;

function TGLFW.glfwJoystickIsGamepad(jId: integer): integer;
begin

end;

function TGLFW.glfwSetJoystickCallback(callback: TGLFWjoystickfun): TGLFWjoystickfun;
begin

end;

function TGLFW.glfwUpdateGamepadMappings(const string_: pchar): integer;
begin

end;

function TGLFW.glfwGetGamepadName(jId: integer): pchar;
begin

end;

function TGLFW.glfwGetGamepadState(jId: integer; state: PGLFWgamepadstate): integer;
begin

end;

procedure TGLFW.glfwSetClipboardString(window: PGLFWwindow; const Text: pchar);
begin

end;

function TGLFW.glfwGetClipboardString(window: PGLFWwindow): pchar;
begin

end;

function TGLFW.glfwGetTime(): double;
begin

end;

procedure TGLFW.glfwSetTime(time: double);
begin

end;

function TGLFW.glfwGetTimerValue(): uint64;
begin

end;

function TGLFW.glfwGetTimerFrequency(): uint64;
begin

end;

procedure TGLFW.glfwMakeContextCurrent(window: PGLFWwindow);
begin

end;

function TGLFW.glfwGetCurrentContext(): PGLFWwindow;
begin

end;

procedure TGLFW.glfwSwapBuffers(window: PGLFWwindow);
begin

end;

procedure TGLFW.glfwSwapInterval(interval: integer);
begin

end;

function TGLFW.glfwExtensionSupported(const extension: pchar): integer;
begin

end;

function TGLFW.glfwGetProcAddress(const procname: pchar): TGLFWGLProc;
begin

end;

function TGLFW.glfwVulkanSupported(): integer;
begin

end;

function TGLFW.glfwGetRequiredInstanceExtensions(out Count: uint32): PPChar;
begin

end;

initialization
  singleton := nil;


finalization

  singleton := nil;

end.
