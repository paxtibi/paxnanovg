unit nanovg;

{$mode objfpc}{$H+}
{$ModeSwitch Result}
{ Traduzione del codice https://github.com/memononen/nanovg }
interface

uses
  Classes, SysUtils, fontStash,
  Math, stb_image, paxutils;

const
  NVG_PI = 3.14159265358979323846264338327;
  NVG_INIT_FONTIMAGE_SIZE = 512;
  NVG_MAX_FONTIMAGE_SIZE = 2048;
  NVG_MAX_FONTIMAGES = 4;

  NVG_INIT_COMMANDS_SIZE = 256;
  NVG_INIT_POINTS_SIZE = 128;
  NVG_INIT_PATHS_SIZE = 16;
  NVG_INIT_VERTS_SIZE = 256;

  NVG_MAX_STATES = 32;
  NVG_KAPPA90 = 0.5522847493;  // Length proportional to radius of a cubic bezier handle for 90deg arcs.


type
  PNVGContext = ^TNVGContext;
  PNVGGlyphPosition = ^TNVGGlyphPosition;
  PNVGTextRow = ^TNVGTextRow;
  PNVGPaint = ^TNVGPaint;
  PNVGPoint = ^TNVGPoint;
  PNVGPathCache = ^TNVGPathCache;
  PNVGState = ^TNVGState;
  PNVGVertex = ^TNVGVertex;

  TNVGColor = record
    case boolean of
      False: (rgba: array[0..3] of single);
      True: (r, g, b, a: single);
  end;

  TNVGPaint = record
    xform: array[0..5] of single;
    extent: array [0..1] of single;
    radius: single;
    feather: single;
    innerColor: TNVGColor;
    outerColor: TNVGColor;
    image: integer;
  end;
  TNVGWinding = (
    NVG_CCW = 1,      // Winding for solid shapes
    NVG_CW = 2        // Winding for holes
    );
  TNVGSolidity = (
    NVG_SOLID = 1,      // CCW
    NVG_HOLE = 2      // CW
    );

  TNVGLineCap = (
    NVG_BUTT,
    NVG_ROUND,
    NVG_SQUARE,
    NVG_BEVEL,
    NVG_MITER
    );

  TNVGAlign = (
    // Horizontal align
    NVG_ALIGN_LEFT = 1 shl 0,  // Default, align text horizontally to left.
    NVG_ALIGN_CENTER = 1 shl 1,  // Align text horizontally to center.
    NVG_ALIGN_RIGHT = 1 shl 2,  // Align text horizontally to right.
    // Vertical align
    NVG_ALIGN_TOP = 1 shl 3,  // Align text vertically to top.
    NVG_ALIGN_MIDDLE = 1 shl 4,  // Align text vertically to middle.
    NVG_ALIGN_BOTTOM = 1 shl 5,  // Align text vertically to bottom.
    NVG_ALIGN_BASELINE = 1 shl 6 // Default, align text vertically to baseline.
    );
  TNVGAligns = set of TNVGAlign;
  TNVGBlendFactor = (
    NVG_ZERO = 1 shl 0,
    NVG_ONE = 1 shl 1,
    NVG_SRC_COLOR = 1 shl 2,
    NVG_ONE_MINUS_SRC_COLOR = 1 shl 3,
    NVG_DST_COLOR = 1 shl 4,
    NVG_ONE_MINUS_DST_COLOR = 1 shl 5,
    NVG_SRC_ALPHA = 1 shl 6,
    NVG_ONE_MINUS_SRC_ALPHA = 1 shl 7,
    NVG_DST_ALPHA = 1 shl 8,
    NVG_ONE_MINUS_DST_ALPHA = 1 shl 9,
    NVG_SRC_ALPHA_SATURATE = 1 shl 10
    );
  TNVGCompositeOperation = (
    NVG_SOURCE_OVER,
    NVG_SOURCE_IN,
    NVG_SOURCE_OUT,
    NVG_ATOP,
    NVG_DESTINATION_OVER,
    NVG_DESTINATION_IN,
    NVG_DESTINATION_OUT,
    NVG_DESTINATION_ATOP,
    NVG_LIGHTER,
    NVG_COPY,
    NVG_XOR
    );

  TNVGCompositeOperationState = record
    srcRGB: int32;
    dstRGB: int32;
    srcAlpha: int32;
    dstAlpha: int32;
  end;

  TNVGGlyphPosition = record
    str: pchar;  // Position of the glyph in the input string.
    x: single;      // The x-coordinate of the logical glyph position.
    minx, maxx: single;  // The bounds of the glyph shape.
  end;

  TNVGTextRow = record
    start: pchar;  // Pointer to the input text where the row starts.
    stop: pchar;  // Pointer to the input text where the row ends (one past the last character).
    Next: pchar;  // Pointer to the beginning of the next row.
    Width: single;    // Logical width of the row.
    minx, maxx: single;  // Actual bounds of the row. Logical with and bounds can differ because of kerning and some parts over extending.
  end;
  TNVGImageFlags = (
    NVG_IMAGE_GENERATE_MIPMAPS = 1 shl 0,     // Generate mipmaps during creation of the image.
    NVG_IMAGE_REPEATX = 1 shl 1,    // Repeat image in X direction.
    NVG_IMAGE_REPEATY = 1 shl 2,    // Repeat image in Y direction.
    NVG_IMAGE_FLIPY = 1 shl 3,    // Flips (inverses) image in Y direction when rendered.
    NVG_IMAGE_PREMULTIPLIED = 1 shl 4,    // Image data has premultiplied alpha.
    NVG_IMAGE_NEAREST = 1 shl 5    // Image interpolation is Nearest instead Linear
    );

  // Internal Render API

  TNVGTexture = (
    NVG_TEXTURE_ALPHA = $01,
    NVG_TEXTURE_RGBA = $02);

  PNVGScissor = ^TNVGScissor;
  PNVGPath = ^TNVGPath;
  PNVGParams = ^TNVGParams;

  TAffineMatrix = array[0..5] of single;

  TNVGScissor = record
    xform: TAffineMatrix;
    extent: array [0..1] of single;
  end;

  TNVGVertex = record
    x, y, u, v: single;
  end;
  TNVGVertexArray = array of TNVGVertex;

  TNVGPath = record
    First: int32;
    Count: int32;
    closed: boolean;
    nbevel: int32;
    fill: PNVGVertex;
    nfill: int32;
    stroke: PNVGVertex;
    nstroke: int32;
    winding: TNVGWinding;
    convex: boolean;
  end;

  TNVGPathArray = array of TNVGPath;

  TNVGParams = record
    userPtr: Pointer;
    edgeAntiAlias: boolean;
    renderCreate: function(uptr: Pointer): int32;
    renderCreateTexture: function(uptr: Pointer; textureType: TNVGTexture; w, h, imageFlags: int32; Data: pbyte): int32;
    renderDeleteTexture: function(uptr: Pointer; image: int32): int32;
    renderUpdateTexture: function(uptr: Pointer; image, x, y, w, h: int32; Data: pbyte): int32;
    renderGetTextureSize: function(uptr: Pointer; image: int32; var w, h: int32): int32;
    renderViewport: procedure(uptr: Pointer; Width, Height, devicePixelRatio: single);
    renderCancel: procedure(uptr: Pointer);
    renderFlush: procedure(uptr: Pointer);
    renderFill: procedure(uptr: Pointer; paint: PNVGPaint; compositeOperation: TNVGCompositeOperationState; scissor: PNVGScissor; fringe: single; bounds: PSingle; paths: PNVGPath; npaths: int32);
    renderStroke: procedure(uptr: Pointer; paint: PNVGPaint; compositeOperation: TNVGCompositeOperationState; scissor: PNVGScissor; fringe, strokeWidth: single; paths: PNVGPath; npaths: int32);
    renderTriangles: procedure(uptr: Pointer; paint: PNVGPaint; compositeOperation: TNVGCompositeOperationState; scissor: PNVGScissor; verts: PNVGvertex; nverts: int32; fringe: single);
    renderDelete: procedure(uptr: Pointer);
  end;

  TNVGCommands = (
    NVG_MOVETO = 0,
    NVG_LINETO = 1,
    NVG_BEZIERTO = 2,
    NVG_CLOSE = 3,
    NVG_WINDING = 4);

  TNVGPointFlags = (
    NVG_PT_CORNER = $01,
    NVG_PT_LEFT = $02,
    NVG_PT_BEVEL = $04,
    NVG_PR_INNERBEVEL = $08
    );

  TNVGState = record
    compositeOperation: TNVGCompositeOperationState;
    shapeAntiAlias: boolean;
    fill: TNVGPaint;
    stroke: TNVGPaint;
    strokeWidth: single;
    miterLimit: single;
    lineJoin: TNVGLineCap;
    lineCap: TNVGLineCap;
    alpha: single;
    xform: TAffineMatrix;
    scissor: TNVGScissor;
    fontSize: single;
    letterSpacing: single;
    lineHeight: single;
    fontBlur: single;
    textAlign: int32;
    fontId: int32;
  end;

  TNVGPoint = record
    x, y: single;
    dx, dy: single;
    len: single;
    dmx, dmy: single;
    flags: int8;
  end;

  TNVGPathCache = record
    points: PNVGPoint;
    npoints: int32;
    cpoints: int32;
    paths: PNVGPath;
    npaths: int32;
    cpaths: int32;
    verts: PNVGVertex;
    nverts: int32;
    cverts: int32;
    bounds: array[0..3] of single;
  end;

  TNVGStateArray = array of TNVGState;

  TNVGContext = record
    params: PNVGParams;
    commands: PSingle;
    ccommands: int32;
    ncommands: int32;
    commandx, commandy: single;
    states: TNVGStateArray;
    nstates: int32;
    cache: PNVGPathCache;
    tessTol: single;
    distTol: single;
    fringeWidth: single;
    devicePxRatio: single;
    fs: PFONScontext;
    fontImages: array[0..NVG_MAX_FONTIMAGES - 1] of int32;
    fontImageIdx: int32;
    drawCallCount: int32;
    fillTriCount: int32;
    strokeTriCount: int32;
    textTriCount: int32;
  end;

  TNVGCodePointType = (
    NVG_SPACE,
    NVG_NEWLINE,
    NVG_CHAR,
    NVG_CJK_CHAR
    );

// Begin drawing a new frame
// Calls to nanovg drawing API should be wrapped in nvgBeginFrame() & nvgEndFrame()
// nvgBeginFrame() defines the size of the window to render to in relation currently
// set viewport (i.e. glViewport on GL backends). Device pixel ration allows to
// control the rendering on Hi-DPI devices.
// For example, GLFW returns two dimension for an opened window: window size and
// frame buffer size. In that case you would set windowWidth/Height to the window size
// devicePixelRatio to: frameBufferWidth / windowWidth.
procedure nvgBeginFrame(ctx: PNVGContext; windowWidth: single; windowHeight: single; devicePixelRatio: single);

// Cancels drawing the current frame.
procedure nvgCancelFrame(ctx: PNVGContext);

// Ends drawing flushing remaining render state.
procedure nvgEndFrame(ctx: PNVGContext);

// Composite operation

// The composite operations in NanoVG are modeled after HTML Canvas API, and
// the blend func is based on OpenGL (see corresponding manuals for more info).
// The colors in the blending state have premultiplied alpha.

// Sets the composite operation. The op parameter should be one of NVGcompositeOperation.
procedure nvgGlobalCompositeOperation(ctx: PNVGContext; op: TNVGCompositeOperation);

// Sets the composite operation with custom pixel arithmetic. The parameters should be one of NVGblendFactor.
procedure nvgGlobalCompositeBlendFunc(ctx: PNVGContext; sfactor, dfactor: int32);

// Sets the composite operation with custom pixel arithmetic for RGB and alpha components separately. The parameters should be one of NVGblendFactor.
procedure nvgGlobalCompositeBlendFuncSeparate(ctx: PNVGContext; srcRGB, dstRGB, srcAlpha, dstAlpha: int32);
// Color utils
// Colors in NanoVG are stored as unsigned ints in ABGR format.
// Returns a color value from red, green, blue values. Alpha will be set to 255 (1.0f).
function nvgRGB(r, g, b: uint8): TNVGColor; overload;
// Returns a color value from red, green, blue values. Alpha will be set to 1.0f.
function nvgRGB(r, g, b: single): TNVGColor; overload;
// Returns a color value from red, green, blue and alpha values.
function nvgRGBA(r, g, b, a: uint8): TNVGColor; overload;
// Returns a color value from red, green, blue and alpha values.
function nvgRGBA(r, g, b, a: single): TNVGColor; overload;
// Linearly interpolates from color c0 to c1, and returns resulting color value.
function nvgLerpRGBA(c0: TNVGColor; c1: TNVGColor; u: single): TNVGColor;

// Sets transparency of a color value.
function nvgTransRGBA(c: TNVGColor; a: uint8): TNVGColor; overload;

// Sets transparency of a color value.
function nvgTransRGBA(c: TNVGColor; a: single): TNVGColor; overload;

// Returns color value specified by hue, saturation and lightness.
// HSL values are all in range [0..1], alpha will be set to 255.
function nvgHSL(h, s, l: single): TNVGColor;

// Returns color value specified by hue, saturation and lightness and alpha.
// HSL values are all in range [0..1], alpha in range [0..255]
function nvgHSLA(h, s, l: single; a: uint8): TNVGColor;


// State Handling

// NanoVG contains state which represents how paths will be rendered.
// The state contains transform, fill and stroke styles, text and font styles,
// and scissor clipping.

// Pushes and saves the current render state into a state stack.
// A matching nvgRestore() must be used to restore the state.
procedure nvgSave(ctx: PNVGContext);

// Pops and restores current render state.
procedure nvgRestore(ctx: PNVGContext);

// Resets current render state to default values. Does not affect the render state stack.
procedure nvgReset(ctx: PNVGContext);


// Render styles

// Fill and stroke render style can be either a solid color or a paint which is a gradient or a pattern.
// Solid color is simply defined as a color value, different kinds of paints can be created
// using nvgLinearGradient(), nvgBoxGradient(), nvgRadialGradient() and nvgImagePattern().

// Current render style can be saved and restored using nvgSave() and nvgRestore().

// Sets whether to draw antialias for nvgStroke() and nvgFill(). It's enabled by default.
procedure nvgShapeAntiAlias(ctx: PNVGContext; Enabled: boolean);

// Sets current stroke style to a solid color.
procedure nvgStrokeColor(ctx: PNVGContext; color: TNVGColor);

// Sets current stroke style to a paint, which can be a one of the gradients or a pattern.
procedure nvgStrokePaint(ctx: PNVGContext; paint: TNVGPaint);

// Sets current fill style to a solid color.
procedure nvgFillColor(ctx: PNVGContext; color: TNVGColor);

// Sets current fill style to a paint, which can be a one of the gradients or a pattern.
procedure nvgFillPaint(ctx: PNVGContext; paint: TNVGPaint);

// Sets the miter limit of the stroke style.
// Miter limit controls when a sharp corner is beveled.
procedure nvgMiterLimit(ctx: PNVGContext; limit: single);

// Sets the stroke width of the stroke style.
procedure nvgStrokeWidth(ctx: PNVGContext; Width: single);

// Sets how the end of the line (cap) is drawn,
// Can be one of: NVG_BUTT (default), NVG_ROUND, NVG_SQUARE.
procedure nvgLineCap(ctx: PNVGContext; cap: TNVGLineCap);

// Sets how sharp path corners are drawn.
// Can be one of NVG_MITER (default), NVG_ROUND, NVG_BEVEL.
procedure nvgLineJoin(ctx: PNVGContext; join: TNVGLineCap);

// Sets the transparency applied to all rendered shapes.
// Already transparent paths will get proportionally more transparent as well.
procedure nvgGlobalAlpha(ctx: PNVGContext; alpha: single);


// Transforms

// The paths, gradients, patterns and scissor region are transformed by an transformation
// matrix at the time when they are passed to the API.
// The current transformation matrix is a affine matrix:
//   [sx kx tx]
//   [ky sy ty]
//   [ 0  0  1]
// Where: sx,sy define scaling, kx,ky skewing, and tx,ty translation.
// The last row is assumed to be 0,0,1 and is not stored.

// Apart from nvgResetTransform(), each transformation function first creates
// specific transformation matrix and pre-multiplies the current transformation by it.

// Current coordinate system (transformation) can be saved and restored using nvgSave() and nvgRestore().

// Resets current transform to a identity matrix.
procedure nvgResetTransform(ctx: PNVGContext);

// Premultiplies current coordinate system by specified matrix.
// The parameters are interpreted as matrix as follows:
//   [a c e]
//   [b d f]
//   [0 0 1]
procedure nvgTransform(ctx: PNVGContext; a, b, c, d, e, f: single);

// Translates current coordinate system.
procedure nvgTranslate(ctx: PNVGContext; x, y: single);

// Rotates current coordinate system. Angle is specified in radians.
procedure nvgRotate(ctx: PNVGContext; angle: single);

// Skews the current coordinate system along X axis. Angle is specified in radians.
procedure nvgSkewX(ctx: PNVGContext; angle: single);

// Skews the current coordinate system along Y axis. Angle is specified in radians.
procedure nvgSkewY(ctx: PNVGContext; angle: single);

// Scales the current coordinate system.
procedure nvgScale(ctx: PNVGContext; x, y: single);

// Stores the top part (a-f) of the current transformation matrix in to the specified buffer.
//   [a c e]
//   [b d f]
//   [0 0 1]
// There should be space for 6 floats in the return buffer for the values a-f.
procedure nvgCurrentTransform(ctx: PNVGContext; xform: PSingle);

// The following functions can be used to make calculations on 2x3 transformation matrices.
// A 2x3 matrix is represented as single[6].

// Sets the transform to identity matrix.
procedure nvgTransformIdentity(dst: PSingle);

// Sets the transform to translation matrix matrix.
procedure nvgTransformTranslate(dst: PSingle; tx, ty: single);

// Sets the transform to scale matrix.
procedure nvgTransformScale(dst: PSingle; sx, sy: single);

// Sets the transform to rotate matrix. Angle is specified in radians.
procedure nvgTransformRotate(dst: PSingle; a: single);

// Sets the transform to skew-x matrix. Angle is specified in radians.
procedure nvgTransformSkewX(dst: PSingle; a: single);

// Sets the transform to skew-y matrix. Angle is specified in radians.
procedure nvgTransformSkewY(dst: PSingle; a: single);

// Sets the transform to the result of multiplication of two transforms, of A = A*B.
procedure nvgTransformMultiply(dst: PSingle; const src: PSingle);

// Sets the transform to the result of multiplication of two transforms, of A = B*A.
procedure nvgTransformPremultiply(dst: PSingle; const src: PSingle);

// Sets the destination to inverse of specified transform.
// Returns 1 if the inverse could be calculated, else 0.
function nvgTransformInverse(dst: PSingle; const src: PSingle): int32;

// Transform a point by given transform.
procedure nvgTransformPoint(dstx: PSingle; dsty: PSingle; const xform: PSingle; srcx, srcy: single);

// Converts degrees to radians and vice versa.
function nvgDegToRad(deg: single): single;
function nvgRadToDeg(rad: single): single;


// Images

// NanoVG allows you to load jpg, png, psd, tga, pic and gif files to be used for rendering.
// In addition you can upload your own image. The image loading is provided by stb_image.
// The parameter imageFlags is combination of flags defined in NVGimageFlags.

// Creates image by loading it from the disk from specified file name.
// Returns handle to the image.
function nvgCreateImage(ctx: PNVGContext; const filename: pchar; imageFlags: int32): int32;

// Creates image by loading it from the specified chunk of memory.
// Returns handle to the image.
function nvgCreateImageMem(ctx: PNVGContext; imageFlags: int32; Data: pbyte; ndata: int32): int32;

// Creates image from specified image data.
// Returns handle to the image.
function nvgCreateImageRGBA(ctx: PNVGContext; w, h: int32; imageFlags: int32; Data: pbyte): int32;

// Updates image data specified by image handle.
procedure nvgUpdateImage(ctx: PNVGContext; image: int32; Data: pbyte);

// Returns the dimensions of a created image.
procedure nvgImageSize(ctx: PNVGContext; image: int32; var w, h: int32);

// Deletes created image.
procedure nvgDeleteImage(ctx: PNVGContext; image: int32);

// Paints

// NanoVG supports four types of paints: linear gradient, box gradient, radial gradient and image pattern.
// These can be used as paints for strokes and fills.

// Creates and returns a linear gradient. Parameters (sx,sy)-(ex,ey) specify the start and end coordinates
// of the linear gradient, icol specifies the start color and ocol the end color.
// The gradient is transformed by the current transform when it is passed to nvgFillPaint() or nvgStrokePaint().
function nvgLinearGradient(ctx: PNVGContext; sx, sy, ex, ey: single; icol, ocol: TNVGColor): TNVGPaint;

// Creates and returns a box gradient. Box gradient is a feathered rounded rectangle, it is useful for rendering
// drop shadows or highlights for boxes. Parameters (x,y) define the top-left corner of the rectangle,
// (w,h) define the size of the rectangle, r defines the corner radius, and f feather. Feather defines how blurry
// the border of the rectangle is. Parameter icol specifies the inner color and ocol the outer color of the gradient.
// The gradient is transformed by the current transform when it is passed to nvgFillPaint() or nvgStrokePaint().
function nvgBoxGradient(ctx: PNVGContext; x, y, w, h, r, f: single; icol, ocol: TNVGColor): TNVGPaint;

// Creates and returns a radial gradient. Parameters (cx,cy) specify the center, inr and outr specify
// the inner and outer radius of the gradient, icol specifies the start color and ocol the end color.
// The gradient is transformed by the current transform when it is passed to nvgFillPaint() or nvgStrokePaint().
function nvgRadialGradient(ctx: PNVGContext; cx, cy, inr, outr: single; icol, ocol: TNVGColor): TNVGPaint;

// Creates and returns an image pattern. Parameters (ox,oy) specify the left-top location of the image pattern,
// (ex,ey) the size of one image, angle rotation around the top-left corner, image is handle to the image to render.
// The gradient is transformed by the current transform when it is passed to nvgFillPaint() or nvgStrokePaint().
function nvgImagePattern(ctx: PNVGContext; ox, oy, ex, ey, angle: single; image: int32; alpha: single): TNVGPaint;

// Scissoring

// Scissoring allows you to clip the rendering into a rectangle. This is useful for various
// user interface cases like rendering a text edit or a timeline.

// Sets the current scissor rectangle.
// The scissor rectangle is transformed by the current transform.
procedure nvgScissor(ctx: PNVGContext; x, y, w, h: single);

// Intersects current scissor rectangle with the specified rectangle.
// The scissor rectangle is transformed by the current transform.
// Note: in case the rotation of previous scissor rect differs from
// the current one, the intersection will be done between the specified
// rectangle and the previous scissor rectangle transformed in the current
// transform space. The resulting shape is always rectangle.
procedure nvgIntersectScissor(ctx: PNVGContext; x, y, w, h: single);

// Reset and disables scissoring.
procedure nvgResetScissor(ctx: PNVGContext);

// Paths

// Drawing a new shape starts with nvgBeginPath(), it clears all the currently defined paths.
// Then you define one or more paths and sub-paths which describe the shape. The are functions
// to draw common shapes like rectangles and circles, and lower level step-by-step functions,
// which allow to define a path curve by curve.

// NanoVG uses even-odd fill rule to draw the shapes. Solid shapes should have counter clockwise
// winding and holes should have counter clockwise order. To specify winding of a path you can
// call nvgPathWinding(). This is useful especially for the common shapes, which are drawn CCW.

// Finally you can fill the path using current fill style by calling nvgFill(), and stroke it
// with current stroke style by calling nvgStroke().

// The curve segments and sub-paths are transformed by the current transform.

// Clears the current path and sub-paths.
procedure nvgBeginPath(ctx: PNVGContext);

// Starts new sub-path with specified point as first point.
procedure nvgMoveTo(ctx: PNVGContext; x, y: single);

// Adds line segment from the last point in the path to the specified point.
procedure nvgLineTo(ctx: PNVGContext; x, y: single);

// Adds cubic bezier segment from last point in the path via two control points to the specified point.
procedure nvgBezierTo(ctx: PNVGContext; c1x, c1y, c2x, c2y, x, y: single);

// Adds quadratic bezier segment from last point in the path via a control point to the specified point.
procedure nvgQuadTo(ctx: PNVGContext; cx, cy, x, y: single);

// Adds an arc segment at the corner defined by the last path point, and two specified points.
procedure nvgArcTo(ctx: PNVGContext; x1, y1, x2, y2, radius: single);

// Closes current sub-path with a line segment.
procedure nvgClosePath(ctx: PNVGContext);

// Sets the current sub-path winding, see NVGwinding and NVGsolidity.
procedure nvgPathWinding(ctx: PNVGContext; dir: int32);

// Creates new circle arc shaped sub-path. The arc center is at cx,cy, the arc radius is r,
// and the arc is drawn from angle a0 to a1, and swept in direction dir (NVG_CCW, or NVG_CW).
// Angles are specified in radians.
procedure nvgArc(ctx: PNVGContext; cx, cy, r, a0, a1: single; dir: TNVGWinding);

// Creates new rectangle shaped sub-path.
procedure nvgRect(ctx: PNVGContext; x, y, w, h: single);

// Creates new rounded rectangle shaped sub-path.
procedure nvgRoundedRect(ctx: PNVGContext; x, y, w, h, r: single);

// Creates new rounded rectangle shaped sub-path with varying radii for each corner.
procedure nvgRoundedRectVarying(ctx: PNVGContext; x, y, w, h, radTopLeft, radTopRight, radBottomRight, radBottomLeft: single);

// Creates new ellipse shaped sub-path.
procedure nvgEllipse(ctx: PNVGContext; cx, cy, rx, ry: single);

// Creates new circle shaped sub-path.
procedure nvgCircle(ctx: PNVGContext; cx, cy, r: single);

// Fills the current path with current fill style.
procedure nvgFill(ctx: PNVGContext);

// Fills the current path with current stroke style.
procedure nvgStroke(ctx: PNVGContext);

// Text

// NanoVG allows you to load .ttf files and use the font to render text.

// The appearance of the text can be defined by setting the current text style
// and by specifying the fill color. Common text and font settings such as
// font size, letter spacing and text align are supported. Font blur allows you
// to create simple text effects such as drop shadows.

// At render time the font face can be set based on the font handles or name.

// Font measure functions return values in local space, the calculations are
// carried in the same resolution as the final rendering. This is done because
// the text glyph positions are snapped to the nearest pixels sharp rendering.

// The local space means that values are not rotated or scale as per the current
// transformation. For example if you set font size to 12, which would mean that
// line height is 16, then regardless of the current scaling and rotation, the
// returned line height is always 16. Some measures may vary because of the scaling
// since aforementioned pixel snapping.

// While this may sound a little odd, the setup allows you to always render the
// same way regardless of scaling. I.e. following works regardless of scaling:

//    const char* txt = "Text me up.";
//    nvgTextBounds(vg, x,y, txt, NULL, bounds);
//    nvgBeginPath(vg);
//    nvgRect(vg, bounds[0],bounds[1], bounds[2]-bounds[0], bounds[3]-bounds[1]);
//    nvgFill(vg);

// Note: currently only solid color fill is supported for text.

// Creates font by loading it from the disk from specified file name.
// Returns handle to the font.
function nvgCreateFont(ctx: PNVGContext; const Name, filename: pchar): int32;

// fontIndex specifies which font face to load from a .ttf/.ttc file.
function nvgCreateFontAtIndex(ctx: PNVGContext; const Name, filename: pchar; fontIndex: int32): int32;

// Creates font by loading it from the specified memory chunk.
// Returns handle to the font.
function nvgCreateFontMem(ctx: PNVGContext; const Name: pchar; Data: pbyte; ndata, freeData: int32): int32;

// fontIndex specifies which font face to load from a .ttf/.ttc file.
function nvgCreateFontMemAtIndex(ctx: PNVGContext; Name: pchar; Data: pbyte; ndata, freeData: int32; fontIndex: int32): int32;

// Finds a loaded font of specified name, and returns handle to it, or -1 if the font is not found.
function nvgFindFont(ctx: PNVGContext; const Name: pchar): int32;

// Adds a fallback font by handle.
function nvgAddFallbackFontId(ctx: PNVGContext; baseFont: int32; fallbackFont: int32): int32;

// Adds a fallback font by name.
function nvgAddFallbackFont(ctx: PNVGContext; const baseFont, fallbackFont: pchar): int32;

// Resets fallback fonts by handle.
procedure nvgResetFallbackFontsId(ctx: PNVGContext; baseFont: int32);

// Resets fallback fonts by name.
procedure nvgResetFallbackFonts(ctx: PNVGContext; const baseFont: pchar);

// Sets the font size of current text style.
procedure nvgFontSize(ctx: PNVGContext; size: single);

// Sets the blur of current text style.
procedure nvgFontBlur(ctx: PNVGContext; blur: single);

// Sets the letter spacing of current text style.
procedure nvgTextLetterSpacing(ctx: PNVGContext; spacing: single);

// Sets the proportional line height of current text style. The line height is specified as multiple of font size.
procedure nvgTextLineHeight(ctx: PNVGContext; lineHeight: single);

// Sets the text align of current text style, see NVGalign for options.
procedure nvgTextAlign(ctx: PNVGContext; align: TNVGAligns);

// Sets the font face based on specified id of current text style.
procedure nvgFontFaceId(ctx: PNVGContext; font: int32);

// Sets the font face based on specified name of current text style.
procedure nvgFontFace(ctx: PNVGContext; const font: pchar);

// Draws text string at specified location. If end is specified only the sub-string up to the end is drawn.
function nvgText(ctx: PNVGContext; x, y: single; start, stop: pchar): single;

// Draws multi-line text string at specified location wrapped at the specified width. If end is specified only the sub-string up to the end is drawn.
// White space is stripped at the beginning of the rows, the text is split at word boundaries or when new-line characters are encountered.
// Words longer than the max width are slit at nearest character (i.e. no hyphenation).
procedure nvgTextBox(ctx: PNVGContext; x, y, breakRowWidth: single; start, stop: pchar);

// Measures the specified text string. Parameter bounds should be a pointer to single[4],
// if the bounding box of the text should be returned. The bounds value are [xmin,ymin, xmax,ymax]
// Returns the horizontal advance of the measured text (i.e. where the next character should drawn).
// Measured values are returned in local coordinate space.
function nvgTextBounds(ctx: PNVGContext; x, y: single; start, stop: pchar; bounds: PSingle): single;

// Measures the specified multi-text string. Parameter bounds should be a pointer to single[4],
// if the bounding box of the text should be returned. The bounds value are [xmin,ymin, xmax,ymax]
// Measured values are returned in local coordinate space.
procedure nvgTextBoxBounds(ctx: PNVGContext; x, y, breakRowWidth: single; start, stop: pchar; bounds: PSingle);

// Calculates the glyph x positions of the specified text. If end is specified only the sub-string will be used.
// Measured values are returned in local coordinate space.
function nvgTextGlyphPositions(ctx: PNVGContext; x, y: single; start, stop: pchar; positions: PNVGGlyphPosition; maxPositions: int32): int32;

// Returns the vertical metrics based on the current text style.
// Measured values are returned in local coordinate space.
procedure nvgTextMetrics(ctx: PNVGContext; ascender, descender, lineh: PSingle);

// Breaks the specified text into lines. If end is specified only the sub-string will be used.
// White space is stripped at the beginning of the rows, the text is split at word boundaries or when new-line characters are encountered.
// Words longer than the max width are slit at nearest character (i.e. no hyphenation).
function nvgTextBreakLines(ctx: PNVGContext; start, stop: pchar; breakRowWidth: single; rows: PNVGTextRow; maxRows: int32; out nrows: int32): boolean;

// Constructor and destructor, called by the render back-end.
function nvgCreateInternal(params: PNVGParams): PNVGContext;
procedure nvgDeleteInternal(ctx: PNVGContext);

function nvgInternalParams(ctx: PNVGContext): PNVGparams;

// Debug function to dump cached path data.
procedure nvgDebugDumpPathCache(ctx: PNVGContext);

operator := (aligns: TNVGAligns): int32;
operator := (cmd: TNVGCommands): int32;
operator := (item: TNVGTexture): int32;
operator := (item: TNVGImageFlags): int32;

implementation


operator := (aligns: TNVGAligns): int32;
begin
  Result := 0;
  if NVG_ALIGN_LEFT in aligns then Result := Result or (1 shl 0);
  if NVG_ALIGN_CENTER in aligns then Result := Result or (1 shl 1);
  if NVG_ALIGN_RIGHT in aligns then Result := Result or (1 shl 2);
  if NVG_ALIGN_TOP in aligns then Result := Result or (1 shl 3);
  if NVG_ALIGN_MIDDLE in aligns then Result := Result or (1 shl 4);
  if NVG_ALIGN_BOTTOM in aligns then Result := Result or (1 shl 5);
  if NVG_ALIGN_BASELINE in aligns then Result := Result or (1 shl 6);
end;

operator := (cmd: TNVGCommands): int32;
begin
  Result := Ord(cmd);
end;

operator := (item: TNVGTexture): int32;
begin
  Result := Ord(item);
end;

operator := (item: TNVGImageFlags): int32;
begin
  Result := Ord(item);
end;

function IfThen(ifCondition: boolean; ifTrue, ifFalse: TNVGCodePointType): TNVGCodePointType; overload;
begin
  if ifCondition then
    Result := ifTrue
  else
    Result := ifFalse;
end;

function IfThen(ifCondition: boolean; ifTrue, ifFalse: pchar): pchar; overload;
begin
  if ifCondition then
    Result := ifTrue
  else
    Result := ifFalse;
end;


function nvg__sqrtf(a: single): single; inline;
begin
  Result := Sqrt(a);
end;

function nvg__modf(a, b: single): single; inline;
begin
  Result := Math.fmod(a, b);
end;

function nvg__sinf(a: single): single; inline;
begin
  Result := sin(a);
end;

function nvg__cosf(a: single): single; inline;
begin
  Result := cos(a);
end;

function nvg__tanf(a: single): single; inline;
begin
  Result := Math.tan(a);
end;

function nvg__atan2f(a, b: single): single; inline;
begin
  Result := ArcTan2(a, b);
end;

function nvg__acosf(a: single): single;
begin
  Result := ArcCos(a);
end;

function nvg__mini(a, b: int32): int32; inline;
begin
  Result := min(a, b);
end;

function nvg__maxi(a, b: int32): int32; inline;
begin
  Result := Max(a, b);
end;

function nvg__clampi(a, mn, mx: int32): int32; inline;
begin
  Result := Math.ifThen(a < mn, mn, Math.ifThen(a > mx, mx, a));
end;

function nvg__minf(a, b: single): single; inline;
begin
  Result := Math.IfThen(a < b, a, b);
end;

function nvg__maxf(a, b: single): single; inline;
begin
  Result := Math.IfThen(a > b, a, b);
end;

function nvg__absf(a: single): single; inline;
begin
  Result := Math.IfThen(a >= 0.0, a, -a);
end;

function nvg__signf(a: single): single; inline;
begin
  Result := Math.IfThen(a >= 0.0, 1.0, -1.0);
end;

function nvg__clampf(a, mn, mx: single): single; inline;
begin
  Result := Math.IfThen(a < mn, mn, Math.IfThen(a > mx, mx, a));
end;

function nvg__cross(dx0, dy0, dx1, dy1: single): single; inline;
begin
  Result := dx1 * dy0 - dx0 * dy1;
end;

function nvg__normalize(var x, y: single): single; inline;
var
  id, d: single;
begin
  d := nvg__sqrtf((x) * (x) + (y) * (y));
  if (d > 1e-6) then
  begin
    id := 1.0 / d;
    x *= id;
    y *= id;
  end;
  Result := d;
end;

procedure nvg__deletePathCache(c: PNVGPathCache); inline;
begin
  if (c = nil) then exit;
  if (c^.points <> nil) then Freemem(c^.points);
  if (c^.paths <> nil) then Freemem(c^.paths);
  if (c^.verts <> nil) then Freemem(c^.verts);
  Freemem(c);
end;

function nvg__allocPathCache(): PNVGPathCache; inline;
begin
  try
    Result := PNVGPathCache(GetMem(sizeof(TNVGPathCache)));
    if (Result = nil) then exit;
    FillByte(Result, sizeof(TNVGpathCache), 0);

    Result^.points := GetMem(sizeof(TNVGPoint) * NVG_INIT_POINTS_SIZE);
    if (Result^.points = nil) then raise ENullPointerException.Create;
    Result^.npoints := 0;
    Result^.cpoints := NVG_INIT_POINTS_SIZE;

    Result^.paths := GetMem(sizeof(TNVGPath) * NVG_INIT_PATHS_SIZE);
    if (Result^.paths = nil) then raise ENullPointerException.Create;
    Result^.npaths := 0;
    Result^.cpaths := NVG_INIT_PATHS_SIZE;

    Result^.verts := GetMem(sizeof(TNVGVertex) * NVG_INIT_VERTS_SIZE);
    if (Result^.verts = nil) then raise ENullPointerException.Create;
    Result^.nverts := 0;
    Result^.cverts := NVG_INIT_VERTS_SIZE;
  except
    nvg__deletePathCache(Result);
    Result := nil;
  end;
end;

procedure nvg__setDevicePixelRatio(ctx: PNVGContext; ratio: single); inline;
begin
  ctx^.tessTol := 0.25 / ratio;
  ctx^.distTol := 0.01 / ratio;
  ctx^.fringeWidth := 1.0 / ratio;
  ctx^.devicePxRatio := ratio;
end;

function nvg__compositeOperationState(op: TNVGCompositeOperation): TNVGCompositeOperationState; inline;
var
  sfactor, dfactor: int32;
begin
  sfactor := Ord(NVG_ONE);
  dfactor := Ord(NVG_ZERO);
  case op of
    NVG_SOURCE_OVER:
    begin
      sfactor := Ord(NVG_ONE);
      dfactor := Ord(NVG_ONE_MINUS_SRC_ALPHA);
    end;
    NVG_SOURCE_IN:
    begin
      sfactor := Ord(NVG_DST_ALPHA);
      dfactor := Ord(NVG_ZERO);
    end;
    NVG_SOURCE_OUT:
    begin
      sfactor := Ord(NVG_ONE_MINUS_DST_ALPHA);
      dfactor := Ord(NVG_ZERO);
    end;
    NVG_ATOP:
    begin
      sfactor := Ord(NVG_DST_ALPHA);
      dfactor := Ord(NVG_ONE_MINUS_SRC_ALPHA);
    end;
    NVG_DESTINATION_OVER:
    begin
      sfactor := Ord(NVG_ONE_MINUS_DST_ALPHA);
      dfactor := Ord(NVG_ONE);
    end;
    NVG_DESTINATION_IN:
    begin
      sfactor := Ord(NVG_ZERO);
      dfactor := Ord(NVG_SRC_ALPHA);
    end;
    NVG_DESTINATION_OUT:
    begin
      sfactor := Ord(NVG_ZERO);
      dfactor := Ord(NVG_ONE_MINUS_SRC_ALPHA);
    end;
    NVG_DESTINATION_ATOP:
    begin
      sfactor := Ord(NVG_ONE_MINUS_DST_ALPHA);
      dfactor := Ord(NVG_SRC_ALPHA);
    end;
    NVG_LIGHTER:
    begin
      sfactor := Ord(NVG_ONE);
      dfactor := Ord(NVG_ONE);
    end;
    NVG_COPY:
    begin
      sfactor := Ord(NVG_ONE);
      dfactor := Ord(NVG_ZERO);
    end;
    NVG_XOR:
    begin
      sfactor := Ord(NVG_ONE_MINUS_DST_ALPHA);
      dfactor := Ord(NVG_ONE_MINUS_SRC_ALPHA);
    end;
  end;

  Result.srcRGB := sfactor;
  Result.dstRGB := dfactor;
  Result.srcAlpha := sfactor;
  Result.dstAlpha := dfactor;
end;

function nvg__getState(ctx: PNVGContext): PNVGState; inline;
begin
  Result := @(ctx^.states[ctx^.nstates - 1]);
end;

function nvgCreateInternal(params: PNVGParams): PNVGContext;
var
  fontParams: TFONSParams;
  i: int32;
begin
  try
    Result := GetMem(sizeof(TNVGcontext));
    if (Result = nil) then exit;
    FillByte(Result, sizeof(TNVGContext), 0);

    Result^.params := params;
    for i := 0 to NVG_MAX_FONTIMAGES - 1 do
      Result^.fontImages[i] := 0;

    Result^.commands := GetMem(sizeof(single) * NVG_INIT_COMMANDS_SIZE);
    if (Result^.commands = nil) then raise ENullPointerException.Create;
    Result^.ncommands := 0;
    Result^.ccommands := NVG_INIT_COMMANDS_SIZE;

    Result^.cache := nvg__allocPathCache();
    if (Result^.cache = nil) then raise ENullPointerException.Create;

    nvgSave(Result);
    nvgReset(Result);

    nvg__setDevicePixelRatio(Result, 1.0);

    if (Result^.params^.renderCreate(Result^.params^.userPtr) = 0) then raise ENullPointerException.Create;

    // Init font rendering
    FillByte(fontParams, SizeOf(TFONSParams), 0);
    fontParams.Width := NVG_INIT_FONTIMAGE_SIZE;
    fontParams.Height := NVG_INIT_FONTIMAGE_SIZE;
    fontParams.flags := FONS_ZERO_TOPLEFT;
    fontParams.renderCreate := nil;
    fontParams.renderUpdate := nil;
    fontParams.renderDraw := nil;
    fontParams.renderDelete := nil;
    fontParams.userPtr := nil;
    Result^.fs := fonsCreateInternal(@fontParams);
    if (Result^.fs = nil) then raise ENullPointerException.Create;

    // Create font texture
    Result^.fontImages[0] := Result^.params^.renderCreateTexture(Result^.params^.userPtr, NVG_TEXTURE_ALPHA, fontParams.Width, fontParams.Height, 0, nil);
    if (Result^.fontImages[0] = 0) then raise ENullPointerException.Create;
    Result^.fontImageIdx := 0;
  except
    nvgDeleteInternal(Result);
    Result := nil;
  end;
end;

function nvgInternalParams(ctx: PNVGContext): PNVGparams;
begin
  Result := ctx^.params;
end;

procedure nvgDeleteInternal(ctx: PNVGContext);
var
  i: int32;
begin
  if (ctx = nil) then exit;
  if (ctx^.commands <> nil) then Freemem(ctx^.commands);
  if (ctx^.cache <> nil) then nvg__deletePathCache(ctx^.cache);

  if (ctx^.fs <> nil) then
    fonsDeleteInternal(ctx^.fs);

  for i := 0 to NVG_MAX_FONTIMAGES - 1 do
  begin
    if (ctx^.fontImages[i] <> 0) then
    begin
      nvgDeleteImage(ctx, ctx^.fontImages[i]);
      ctx^.fontImages[i] := 0;
    end;
  end;

  if (ctx^.params^.renderDelete <> nil) then
    ctx^.params^.renderDelete(ctx^.params^.userPtr);

  FreeMem(ctx);
end;

procedure nvgBeginFrame(ctx: PNVGContext; windowWidth: single; windowHeight: single; devicePixelRatio: single);
begin
  ctx^.nstates := 0;
  nvgSave(ctx);
  nvgReset(ctx);

  nvg__setDevicePixelRatio(ctx, devicePixelRatio);

  ctx^.params^.renderViewport(ctx^.params^.userPtr, windowWidth, windowHeight, devicePixelRatio);

  ctx^.drawCallCount := 0;
  ctx^.fillTriCount := 0;
  ctx^.strokeTriCount := 0;
  ctx^.textTriCount := 0;
end;

procedure nvgCancelFrame(ctx: PNVGContext);
begin
  ctx^.params^.renderCancel(ctx^.params^.userPtr);
end;

procedure nvgEndFrame(ctx: PNVGContext);
var
  fontImage: int32;
  i, j: int32;
  iw: int32 = 0;
  ih: int32 = 0;
  nw, nh: int32;
  image: int32;
begin
  ctx^.params^.renderFlush(ctx^.params^.userPtr);
  if (ctx^.fontImageIdx <> 0) then
  begin
    fontImage := ctx^.fontImages[ctx^.fontImageIdx];
    ctx^.fontImages[ctx^.fontImageIdx] := 0;
    // delete images that smaller than current one
    if (fontImage = 0) then
      exit;
    nvgImageSize(ctx, fontImage, iw, ih);
    j := 0;
    for i := 0 to ctx^.fontImageIdx - 1 do
    begin
      if (ctx^.fontImages[i] <> 0) then
      begin
        image := ctx^.fontImages[i];
        ctx^.fontImages[i] := 0;
        nvgImageSize(ctx, image, nw, nh);
        if (nw < iw) or (nh < ih) then
          nvgDeleteImage(ctx, image)
        else
        begin
          ctx^.fontImages[j] := image;
          Inc(j);
        end;
      end;
    end;
    // make current font image to first
    ctx^.fontImages[j] := ctx^.fontImages[0];
    ctx^.fontImages[0] := fontImage;
    ctx^.fontImageIdx := 0;
  end;
end;

function nvgRGB(r, g, b: uint8): TNVGColor;
begin
  Result := nvgRGBA(r, g, b, $FF);
end;

function nvgRGB(r, g, b: single): TNVGColor;
begin
  Result := nvgRGBA(r, g, b, 1.0);
end;

function nvgRGBA(r, g, b, a: uint8): TNVGColor;
begin
  Result.r := r / 255.0;
  Result.g := g / 255.0;
  Result.b := b / 255.0;
  Result.a := a / 255.0;
end;

function nvgRGBA(r, g, b, a: single): TNVGColor;
begin
  Result.r := r;
  Result.g := g;
  Result.b := b;
  Result.a := a;
end;

function nvgTransRGBA(c: TNVGColor; a: uint8): TNVGColor;
begin
  Result := c;
  Result.a := a / 255.0;
end;

function nvgTransRGBA(c: TNVGColor; a: single): TNVGColor;
begin
  Result := c;
  Result.a := a;
end;

function nvgLerpRGBA(c0: TNVGColor; c1: TNVGColor; u: single): TNVGColor;
var
  i: int32;
  oneminu: single;
begin
  u := nvg__clampf(u, 0.0, 1.0);
  oneminu := 1.0 - u;
  for i := 0 to 4 do
  begin
    Result.rgba[i] := c0.rgba[i] * oneminu + c1.rgba[i] * u;
  end;
end;

function nvgHSL(h, s, l: single): TNVGColor;
begin
  Result := nvgHSLA(h, s, l, 255);
end;

function nvg__hue(h, m1, m2: single): single; inline;
begin
  Result := m1;
  if (h < 0) then h += 1;
  if (h > 1) then h -= 1;
  if (h < 1.0 / 6.0) then
    Result := m1 + (m2 - m1) * h * 6.0
  else if (h < 3.0 / 6.0) then
    Result := m2
  else if (h < 4.0 / 6.0) then
    Result := m1 + (m2 - m1) * (2.0 / 3.0 - h) * 6.0;
end;

function nvgHSLA(h, s, l: single; a: uint8): TNVGColor;
var
  m1, m2: single;
begin
  h := nvg__modf(h, 1.0);
  if (h < 0.0) then h += 1.0;
  s := nvg__clampf(s, 0.0, 1.0);
  l := nvg__clampf(l, 0.0, 1.0);
  m2 := ifThen(l <= 0.5, (l * (1 + s)), (l + s - l * s));
  m1 := 2 * l - m2;
  Result.r := nvg__clampf(nvg__hue(h + 1.0 / 3.0, m1, m2), 0.0, 1.0);
  Result.g := nvg__clampf(nvg__hue(h, m1, m2), 0.0, 1.0);
  Result.b := nvg__clampf(nvg__hue(h - 1.0 / 3.0, m1, m2), 0.0, 1.0);
  Result.a := a / 255.0;
end;

procedure nvgTransformIdentity(dst: PSingle);
begin
  dst[0] := 1.0;
  dst[1] := 0.0;
  dst[2] := 0.0;
  dst[3] := 1.0;
  dst[4] := 0.0;
  dst[5] := 0.0;
end;

procedure nvgTransformTranslate(dst: PSingle; tx, ty: single);
begin
  dst[0] := 1.0;
  dst[1] := 0.0;
  dst[2] := 0.0;
  dst[3] := 1.0;
  dst[4] := tx;
  dst[5] := ty;
end;

procedure nvgTransformScale(dst: PSingle; sx, sy: single);
begin
  dst[0] := sx;
  dst[1] := 0.0;
  dst[2] := 0.0;
  dst[3] := sy;
  dst[4] := 0.0;
  dst[5] := 0.0;
end;

procedure nvgTransformRotate(dst: PSingle; a: single);
var
  cs, sn: single;
begin
  cs := nvg__cosf(a);
  sn := nvg__sinf(a);
  dst[0] := cs;
  dst[1] := sn;
  dst[2] := -sn;
  dst[3] := cs;
  dst[4] := 0.0;
  dst[5] := 0.0;
end;

procedure nvgTransformSkewX(dst: PSingle; a: single);
begin
  dst[0] := 1.0;
  dst[1] := 0.0;
  dst[2] := nvg__tanf(a);
  dst[3] := 1.0;
  dst[4] := 0.0;
  dst[5] := 0.0;
end;

procedure nvgTransformSkewY(dst: PSingle; a: single);
begin
  dst[0] := 1.0;
  dst[1] := nvg__tanf(a);
  dst[2] := 0.0;
  dst[3] := 1.0;
  dst[4] := 0.0;
  dst[5] := 0.0;
end;

procedure nvgTransformMultiply(dst: PSingle; const src: PSingle);
var
  t0, t2, t4: single;
begin
  t0 := dst[0] * src[0] + dst[1] * src[2];
  t2 := dst[2] * src[0] + dst[3] * src[2];
  t4 := dst[4] * src[0] + dst[5] * src[2] + src[4];
  dst[1] := dst[0] * src[1] + dst[1] * src[3];
  dst[3] := dst[2] * src[1] + dst[3] * src[3];
  dst[5] := dst[4] * src[1] + dst[5] * src[3] + src[5];
  dst[0] := t0;
  dst[2] := t2;
  dst[4] := t4;
end;

procedure nvgTransformPremultiply(dst: PSingle; const src: PSingle);
var
  s2: TAffineMatrix;
begin
  Move(src^, s2[0], sizeof(single) * 6);
  nvgTransformMultiply(s2, dst);
  move(s2[0], dst^, sizeof(single) * 6);
end;

function nvgTransformInverse(dst: PSingle; const src: PSingle): int32;
var
  invdet, det: double;
begin
  Result := 1;
  det := double(src[0] * src[3]) - double(src[2] * src[1]);
  if (det > -1e-6) and (det < 1e-6) then
  begin
    nvgTransformIdentity(dst);
    exit(0);
  end;
  invdet := 1.0 / det;
  dst[0] := (src[3] * invdet);
  dst[2] := (-src[2] * invdet);
  dst[4] := ((double(src[2] * src[5]) - double(src[3] * src[4])) * invdet);
  dst[1] := (-src[1] * invdet);
  dst[3] := (src[0] * invdet);
  dst[5] := ((double(src[1] * src[4]) - double(src[0] * src[5])) * invdet);
end;

procedure nvgTransformPoint(dstx: PSingle; dsty: PSingle; const xform: PSingle; srcx, srcy: single);
begin
  dstx^ := srcx * xform[0] + srcy * xform[2] + xform[4];
  dsty^ := srcx * xform[1] + srcy * xform[3] + xform[5];
end;

function nvgDegToRad(deg: single): single;
begin
  Result := deg / 180.0 * NVG_PI;
end;

function nvgRadToDeg(rad: single): single;
begin
  Result := rad / NVG_PI * 180.0;
end;

procedure nvg__setPaintColor(var p: TNVGPaint; color: TNVGColor); inline;
begin
  FillByte(p, sizeof(TNVGPaint), 0);
  nvgTransformIdentity(p.xform);
  p.radius := 0.0;
  p.feather := 1.0;
  p.innerColor := color;
  p.outerColor := color;
end;

// State handling

procedure nvgSave(ctx: PNVGContext);
begin
  with TNVGContext(ctx^) do
  begin
    if (nstates >= NVG_MAX_STATES) then
      exit;
    if (nstates > 0) then
    begin
      SetLength(states, Length(states) + 1);
      Inc(nstates);
    end;
  end;
end;

procedure nvgRestore(ctx: PNVGContext);
begin
  if (ctx^.nstates <= 1) then
    exit;
  Dec(ctx^.nstates);
end;

procedure nvgReset(ctx: PNVGContext);
var
  state: PNVGState;
begin
  state := nvg__getState(ctx);
  FillByte(state^, sizeof(TNVGState), 0);
  nvg__setPaintColor(state^.fill, nvgRGBA(255, 255, 255, 255));
  nvg__setPaintColor(state^.stroke, nvgRGBA(0, 0, 0, 255));
  state^.compositeOperation := nvg__compositeOperationState(NVG_SOURCE_OVER);
  state^.shapeAntiAlias := True;
  state^.strokeWidth := 1.0;
  state^.miterLimit := 10.0;
  state^.lineCap := NVG_BUTT;
  state^.lineJoin := NVG_MITER;
  state^.alpha := 1.0;
  nvgTransformIdentity(state^.xform);

  state^.scissor.extent[0] := -1.0;
  state^.scissor.extent[1] := -1.0;

  state^.fontSize := 16.0;
  state^.letterSpacing := 0.0;
  state^.lineHeight := 1.0;
  state^.fontBlur := 0.0;
  state^.textAlign := [NVG_ALIGN_LEFT, NVG_ALIGN_BASELINE];
  state^.fontId := 0;
end;

// State setting
procedure nvgShapeAntiAlias(ctx: PNVGContext; Enabled: boolean);
var
  state: PNVGstate;
begin
  state := nvg__getState(ctx);
  state^.shapeAntiAlias := Enabled;
end;

procedure nvgStrokeWidth(ctx: PNVGContext; Width: single);
var
  state: PNVGstate;
begin
  state := nvg__getState(ctx);
  state^.strokeWidth := Width;
end;

procedure nvgMiterLimit(ctx: PNVGContext; limit: single);
var
  state: PNVGState;
begin
  state := nvg__getState(ctx);
  state^.miterLimit := limit;
end;


procedure nvgLineCap(ctx: PNVGContext; cap: TNVGLineCap);
var
  state: PNVGState;
begin
  state := nvg__getState(ctx);
  state^.lineCap := cap;
end;

procedure nvgLineJoin(ctx: PNVGContext; join: TNVGLineCap);
var
  state: PNVGState;
begin
  state := nvg__getState(ctx);
  state^.lineJoin := join;
end;

procedure nvgGlobalAlpha(ctx: PNVGContext; alpha: single);
var
  state: PNVGState;
begin
  state := nvg__getState(ctx);
  state^.alpha := alpha;
end;

procedure nvgTransform(ctx: PNVGContext; a, b, c, d, e, f: single);
var
  state: PNVGState;
  t: TAffineMatrix;
begin
  state := nvg__getState(ctx);
  t[0] := a;
  t[1] := b;
  t[2] := c;
  t[3] := d;
  t[4] := e;
  t[5] := f;
  nvgTransformPremultiply(state^.xform, t);
end;

procedure nvgResetTransform(ctx: PNVGContext);
var
  state: PNVGState;
begin
  state := nvg__getState(ctx);
  nvgTransformIdentity(state^.xform);
end;

procedure nvgTranslate(ctx: PNVGContext; x, y: single);
var
  state: PNVGState;
  t: TAffineMatrix;
begin
  state := nvg__getState(ctx);
  nvgTransformTranslate(t, x, y);
  nvgTransformPremultiply(state^.xform, t);
end;


procedure nvgRotate(ctx: PNVGContext; angle: single);
var
  state: PNVGState;
  t: TAffineMatrix;
begin
  state := nvg__getState(ctx);
  nvgTransformRotate(t, angle);
  nvgTransformPremultiply(state^.xform, t);
end;

procedure nvgSkewX(ctx: PNVGContext; angle: single);
var
  state: PNVGState;
  t: TAffineMatrix;
begin
  state := nvg__getState(ctx);
  nvgTransformSkewX(t, angle);
  nvgTransformPremultiply(state^.xform, t);
end;

procedure nvgSkewY(ctx: PNVGContext; angle: single);
var
  state: PNVGState;
  t: TAffineMatrix;
begin
  state := nvg__getState(ctx);
  nvgTransformSkewY(t, angle);
  nvgTransformPremultiply(state^.xform, t);
end;

procedure nvgScale(ctx: PNVGContext; x, y: single);
var
  state: PNVGState;
  t: TAffineMatrix;
begin
  state := nvg__getState(ctx);
  nvgTransformScale(t, x, y);
  nvgTransformPremultiply(state^.xform, t);
end;

procedure nvgCurrentTransform(ctx: PNVGContext; xform: PSingle);
var
  state: PNVGState;
begin
  state := nvg__getState(ctx);
  if (xform = nil) then exit;
  move(state^.xform, xform, sizeof(single) * 6);
end;

procedure nvgStrokeColor(ctx: PNVGContext; color: TNVGColor);
var
  state: PNVGState;
begin
  state := nvg__getState(ctx);
  nvg__setPaintColor(state^.stroke, color);
end;

procedure nvgStrokePaint(ctx: PNVGContext; paint: TNVGPaint);
var
  state: PNVGState;
begin
  state := nvg__getState(ctx);
  state^.stroke := paint;
  nvgTransformMultiply(state^.stroke.xform, state^.xform);
end;

procedure nvgFillColor(ctx: PNVGContext; color: TNVGColor);
var
  state: PNVGState;
begin
  state := nvg__getState(ctx);
  nvg__setPaintColor(state^.fill, color);
end;

procedure nvgFillPaint(ctx: PNVGContext; paint: TNVGPaint);
var
  state: PNVGState;
begin
  state := nvg__getState(ctx);
  state^.fill := paint;
  nvgTransformMultiply(state^.fill.xform, state^.xform);
end;

function nvgCreateImage(ctx: PNVGContext; const filename: pchar; imageFlags: int32): int32;
var
  w, h, n, image: int32;
  img: pbyte;
begin
  Result := 0;
  stbi_set_unpremultiply_on_load(1);
  stbi_convert_iphone_png_to_rgb(1);
  img := stbi_load(filename, @w, @h, @n, 4);
  if (img <> nil) then
  begin
    image := nvgCreateImageRGBA(ctx, w, h, imageFlags, img);
    stbi_image_free(img);
    Result := image;
  end;
end;

function nvgCreateImageMem(ctx: PNVGContext; imageFlags: int32; Data: pbyte; ndata: int32): int32;
var
  w, h, n, image: int32;
  img: pbyte;
begin
  img := stbi_load_from_memory(Data, ndata, @w, @h, @n, 4);
  if (img = nil) then
  begin
    exit(0);
  end;
  image := nvgCreateImageRGBA(ctx, w, h, imageFlags, img);
  stbi_image_free(img);
  Result := image;
end;

function nvgCreateImageRGBA(ctx: PNVGContext; w, h: int32; imageFlags: int32; Data: pbyte): int32;
begin
  Result := ctx^.params^.renderCreateTexture(ctx^.params^.userPtr, NVG_TEXTURE_RGBA, w, h, imageFlags, Data);
end;

procedure nvgUpdateImage(ctx: PNVGContext; image: int32; Data: pbyte);
var
  w: int32 = 0;
  h: int32 = 0;
begin
  ctx^.params^.renderGetTextureSize(ctx^.params^.userPtr, image, w, h);
  ctx^.params^.renderUpdateTexture(ctx^.params^.userPtr, image, 0, 0, w, h, Data);
end;

procedure nvgImageSize(ctx: PNVGContext; image: int32; var w, h: int32);
begin
  ctx^.params^.renderGetTextureSize(ctx^.params^.userPtr, image, w, h);
end;

procedure nvgDeleteImage(ctx: PNVGContext; image: int32);
begin
  ctx^.params^.renderDeleteTexture(ctx^.params^.userPtr, image);
end;

function nvgLinearGradient(ctx: PNVGContext; sx, sy, ex, ey: single; icol, ocol: TNVGColor): TNVGPaint;
var
  dx, dy, d: single;
  large: single = 1e5;
begin
  FillChar(Result, sizeof(Result), 0);
  // Calculate transform aligned to the line
  dx := ex - sx;
  dy := ey - sy;
  d := sqrt(dx * dx + dy * dy);
  if (d > 0.0001) then
  begin
    dx /= d;
    dy /= d;
  end
  else
  begin
    dx := 0;
    dy := 1;
  end;

  Result.xform[0] := dy;
  Result.xform[1] := -dx;
  Result.xform[2] := dx;
  Result.xform[3] := dy;
  Result.xform[4] := sx - dx * large;
  Result.xform[5] := sy - dy * large;

  Result.extent[0] := large;
  Result.extent[1] := large + d * 0.5;

  Result.radius := 0.0;

  Result.feather := nvg__maxf(1.0, d);

  Result.innerColor := icol;
  Result.outerColor := ocol;

end;

function nvgRadialGradient(ctx: PNVGContext; cx, cy, inr, outr: single; icol, ocol: TNVGColor): TNVGPaint;
var
  r: single;
  f: single;
begin
  r := (inr + outr) * 0.5;
  f := (outr - inr);
  FillChar(Result, sizeof(Result), 0);

  nvgTransformIdentity(Result.xform);
  Result.xform[4] := cx;
  Result.xform[5] := cy;

  Result.extent[0] := r;
  Result.extent[1] := r;

  Result.radius := r;

  Result.feather := nvg__maxf(1.0, f);

  Result.innerColor := icol;
  Result.outerColor := ocol;
end;

function nvgBoxGradient(ctx: PNVGContext; x, y, w, h, r, f: single; icol, ocol: TNVGColor): TNVGPaint;
begin
  FillChar(Result, sizeof(Result), 0);

  nvgTransformIdentity(Result.xform);
  Result.xform[4] := x + w * 0.5;
  Result.xform[5] := y + h * 0.5;

  Result.extent[0] := w * 0.5;
  Result.extent[1] := h * 0.5;

  Result.radius := r;

  Result.feather := nvg__maxf(1.0, f);

  Result.innerColor := icol;
  Result.outerColor := ocol;
end;

function nvgImagePattern(ctx: PNVGContext; ox, oy, ex, ey, angle: single; image: int32; alpha: single): TNVGPaint;
begin
  FillChar(Result, sizeof(Result), 0);

  nvgTransformRotate(Result.xform, angle);
  Result.xform[4] := ox;
  Result.xform[5] := oy;

  Result.extent[0] := ex;
  Result.extent[1] := ey;

  Result.image := image;

  Result.outerColor := nvgRGBA(1, 1, 1, alpha);
  Result.innerColor := Result.outerColor;
end;


// Scissoring
procedure nvgScissor(ctx: PNVGContext; x, y, w, h: single);
var
  state: PNVGState;
begin
  state := nvg__getState(ctx);

  w := nvg__maxf(0.0, w);
  h := nvg__maxf(0.0, h);

  nvgTransformIdentity(state^.scissor.xform);
  state^.scissor.xform[4] := x + w * 0.5;
  state^.scissor.xform[5] := y + h * 0.5;
  nvgTransformMultiply(state^.scissor.xform, state^.xform);

  state^.scissor.extent[0] := w * 0.5;
  state^.scissor.extent[1] := h * 0.5;
end;

procedure nvg__isectRects(dst: PSingle; ax, ay, aw, ah, bx, by, bw, bh: single);
var
  maxx, maxy, minx, miny: single;
begin
  minx := nvg__maxf(ax, bx);
  miny := nvg__maxf(ay, by);
  maxx := nvg__minf(ax + aw, bx + bw);
  maxy := nvg__minf(ay + ah, by + bh);
  dst[0] := minx;
  dst[1] := miny;
  dst[2] := nvg__maxf(0.0, maxx - minx);
  dst[3] := nvg__maxf(0.0, maxy - miny);
end;


procedure nvgIntersectScissor(ctx: PNVGContext; x, y, w, h: single);
var
  state: PNVGState;
  pxform, invxorm: TAffineMatrix;
  rect: array[0..3] of single;
  ex, ey, tex, tey: single;
begin
  state := nvg__getState(ctx);
  // If no previous scissor has been set, set the scissor as current scissor.
  if (state^.scissor.extent[0] < 0) then
  begin
    nvgScissor(ctx, x, y, w, h);
    exit;
  end;

  // Transform the current scissor rect into current transform space.
  // If there is difference in rotation, this will be approximation.
  Move(pxform, state^.scissor.xform, sizeof(TAffineMatrix));
  ex := state^.scissor.extent[0];
  ey := state^.scissor.extent[1];
  nvgTransformInverse(invxorm, state^.xform);
  nvgTransformMultiply(pxform, invxorm);
  tex := ex * nvg__absf(pxform[0]) + ey * nvg__absf(pxform[2]);
  tey := ex * nvg__absf(pxform[1]) + ey * nvg__absf(pxform[3]);

  // Intersect rects.
  nvg__isectRects(rect, pxform[4] - tex, pxform[5] - tey, tex * 2, tey * 2, x, y, w, h);

  nvgScissor(ctx, rect[0], rect[1], rect[2], rect[3]);
end;


procedure nvgResetScissor(ctx: PNVGContext);
var
  state: PNVGstate;
begin
  state := nvg__getState(ctx);
  FillByte(state^.scissor.xform, sizeof(TAffineMatrix), 0);
  state^.scissor.extent[0] := -1.0;
  state^.scissor.extent[1] := -1.0;
end;

// Global composite operation.
procedure nvgGlobalCompositeOperation(ctx: PNVGContext; op: TNVGCompositeOperation);
var
  state: PNVGState;
begin
  state := nvg__getState(ctx);
  state^.compositeOperation := nvg__compositeOperationState(op);
end;

procedure nvgGlobalCompositeBlendFunc(ctx: PNVGContext; sfactor, dfactor: int32);
begin
  nvgGlobalCompositeBlendFuncSeparate(ctx, sfactor, dfactor, sfactor, dfactor);
end;

procedure nvgGlobalCompositeBlendFuncSeparate(ctx: PNVGContext; srcRGB, dstRGB, srcAlpha, dstAlpha: int32);
var
  op: TNVGCompositeOperationState;
  state: PNVGState;
begin
  op.srcRGB := srcRGB;
  op.dstRGB := dstRGB;
  op.srcAlpha := srcAlpha;
  op.dstAlpha := dstAlpha;

  state := nvg__getState(ctx);
  state^.compositeOperation := op;
end;

function nvg__ptEquals(x1, y1, x2, y2, tol: single): boolean;
var
  dx, dy: single;
begin
  dx := x2 - x1;
  dy := y2 - y1;
  Result := dx * dx + dy * dy < tol * tol;
end;

function nvg__distPtSeg(x, y: single; px, py, qx, qy: single): single;
var
  pqx, pqy, dx, dy, d, t: single;
begin
  pqx := qx - px;
  pqy := qy - py;
  dx := x - px;
  dy := y - py;
  d := pqx * pqx + pqy * pqy;
  t := pqx * dx + pqy * dy;
  if (d > 0) then t /= d;
  if (t < 0) then t := 0
  else if (t > 1) then t := 1;
  dx := px + t * pqx - x;
  dy := py + t * pqy - y;
  Result := dx * dx + dy * dy;
end;


procedure nvg__appendCommands(ctx: PNVGContext; vals: PSingle; nvals: int32);
var
  state: PNVGState;
  i: int32;
  cmd: int32;
  commands: PSingle;
  ccommands: int32;
begin
  state := nvg__getState(ctx);

  if (ctx^.ncommands + nvals > ctx^.ccommands) then
  begin
    ccommands := ctx^.ncommands + nvals + ctx^.ccommands div 2;
    commands := ReAllocMem(ctx^.commands, sizeof(single) * ccommands);
    if (commands = nil) then exit;
    ctx^.commands := commands;
    ctx^.ccommands := ccommands;
  end;

  if (trunc(vals[0]) <> Ord(NVG_CLOSE)) and (trunc(vals[0]) <> Ord(NVG_WINDING)) then
  begin
    ctx^.commandx := vals[nvals - 2];
    ctx^.commandy := vals[nvals - 1];
  end;
  // transform commands
  i := 0;
  while (i < nvals) do
  begin
    cmd := trunc(vals[i]);
    case (cmd) of
      Ord(NVG_MOVETO): begin
        nvgTransformPoint(@vals[i + 1], @vals[i + 2], state^.xform, vals[i + 1], vals[i + 2]);
        i += 3;
      end;
      Ord(NVG_LINETO): begin
        nvgTransformPoint(@vals[i + 1], @vals[i + 2], state^.xform, vals[i + 1], vals[i + 2]);
        i += 3;
      end;
      Ord(NVG_BEZIERTO): begin
        nvgTransformPoint(@vals[i + 1], @vals[i + 2], state^.xform, vals[i + 1], vals[i + 2]);
        nvgTransformPoint(@vals[i + 3], @vals[i + 4], state^.xform, vals[i + 3], vals[i + 4]);
        nvgTransformPoint(@vals[i + 5], @vals[i + 6], state^.xform, vals[i + 5], vals[i + 6]);
        i += 7;
      end;
      Ord(NVG_CLOSE): begin
        Inc(i);
      end;
      Ord(NVG_WINDING): begin
        i += 2;
      end;
      else
        Inc(i);
    end;
  end;
  move(ctx^.commands[ctx^.ncommands], vals, nvals * sizeof(single));

  ctx^.ncommands += nvals;
end;


procedure nvg__clearPathCache(ctx: PNVGContext); inline;
begin
  ctx^.cache^.npoints := 0;
  ctx^.cache^.npaths := 0;
end;


function nvg__lastPath(ctx: PNVGContext): PNVGPath;
begin
  Result := nil;
  if (ctx^.cache^.npaths > 0) then
    Result := @ctx^.cache^.paths[ctx^.cache^.npaths - 1];
end;

procedure nvg__addPath(ctx: PNVGContext);
var
  path: PNVGPath;
  paths: PNVGPath;
  cpaths: int32;
begin
  if (ctx^.cache^.npaths + 1 > ctx^.cache^.cpaths) then
  begin
    cpaths := ctx^.cache^.npaths + 1 + ctx^.cache^.cpaths div 2;
    paths := ReAllocMem(ctx^.cache^.paths, sizeof(TNVGPath) * cpaths);
    if (paths = nil) then exit;
    ctx^.cache^.paths := paths;
    ctx^.cache^.cpaths := cpaths;
  end;
  path := @(ctx^.cache^.paths[ctx^.cache^.npaths]);
  FillChar(path, sizeof(TNVGPath), 0);
  path^.First := ctx^.cache^.npoints;
  path^.winding := NVG_CCW;

  Inc(ctx^.cache^.npaths);
end;

function nvg__lastPoint(ctx: PNVGContext): PNVGPoint;
begin
  Result := nil;
  if (ctx^.cache^.npoints > 0) then
    Result := @(ctx^.cache^.points[ctx^.cache^.npoints - 1]);
end;


procedure nvg__addPoint(ctx: PNVGContext; x, y: single; flags: int32);
var
  path: PNVGpath;
  pt: PNVGpoint;
  points: PNVGPoint;
  cpoints: int32;
begin
  path := nvg__lastPath(ctx);
  if (path = nil) then exit;

  if (path^.Count > 0) and (ctx^.cache^.npoints > 0) then
  begin
    pt := nvg__lastPoint(ctx);
    if (nvg__ptEquals(pt^.x, pt^.y, x, y, ctx^.distTol)) then
    begin
      pt^.flags := pt^.flags or flags;
      exit;
    end;
  end;

  if (ctx^.cache^.npoints + 1 > ctx^.cache^.cpoints) then
  begin
    cpoints := ctx^.cache^.npoints + 1 + ctx^.cache^.cpoints div 2;
    points := ReAllocMem(ctx^.cache^.points, sizeof(TNVGPoint) * cpoints);
    if (points = nil) then exit;
    ctx^.cache^.points := points;
    ctx^.cache^.cpoints := cpoints;
  end;

  pt := @(ctx^.cache^.points[ctx^.cache^.npoints]);
  FillByte(pt, SizeOf(TNVGpoint), 0);
  pt^.x := x;
  pt^.y := y;
  pt^.flags := flags;

  Inc(ctx^.cache^.npoints);
  Inc(path^.Count);
end;

procedure nvg__closePath(ctx: PNVGContext); inline;
var
  path: PNVGPath;
begin
  path := nvg__lastPath(ctx);
  if (path = nil) then exit;
  path^.closed := True;
end;

procedure nvg__pathWinding(ctx: PNVGContext; winding: TNVGWinding); inline;
var
  path: PNVGPath;
begin
  path := nvg__lastPath(ctx);
  if (path = nil) then exit;
  path^.winding := winding;
end;

function nvg__getAverageScale(t: PSingle): single;
var
  sx, sy: single;
begin
  sx := sqrt(t[0] * t[0] + t[2] * t[2]);
  sy := sqrt(t[1] * t[1] + t[3] * t[3]);
  Result := (sx + sy) * 0.5;
end;

function nvg__allocTempVerts(ctx: PNVGContext; nverts: int32): PNVGvertex;
var
  verts: PNVGvertex;
  cverts: int32;
begin
  if nverts > ctx^.cache^.cverts then
  begin
    cverts := (nverts + $FF) and not $FF; // Arrotonda per 256 per evitare ri-allocazioni frequenti
    verts := ReAllocMem(ctx^.cache^.verts, cverts * SizeOf(TNVGVertex));
    if verts = nil then
    begin
      Result := nil;
      Exit;
    end;
    ctx^.cache^.verts := verts;
    ctx^.cache^.cverts := cverts;
  end;

  Result := ctx^.cache^.verts;
end;

function nvg__triarea2(ax, ay, bx, by, cx, cy: single): single;
var
  abx, aby, acx, acy: single;
begin
  abx := bx - ax;
  aby := by - ay;
  acx := cx - ax;
  acy := cy - ay;
  Result := acx * aby - abx * acy;
end;

function nvg__polyArea(pts: PNVGpoint; npts: int32): single;
var
  i: int32;
  area: single = 0;
  a, b, c: PNVGPoint;
begin
  for i := 2 to npts - 1 do
  begin
    a := @pts[0];
    b := @pts[i - 1];
    c := @pts[i];
    area += nvg__triarea2(a^.x, a^.y, b^.x, b^.y, c^.x, c^.y);
  end;
  Result := area * 0.5;
end;


procedure nvg__polyReverse(pts: PNVGPoint; npts: int32);
var
  i: int32 = 0;
  j: int32;// = npts-1;
  tmp: TNVGpoint;
begin
  j := npts - 1;
  while (i < j) do
  begin
    tmp := pts[i];
    pts[i] := pts[j];
    pts[j] := tmp;
    Inc(i);
    Dec(j);
  end;
end;

procedure nvg__vset(vtx: PNVGVertex; x, y, u, v: single);
begin
  vtx^.x := x;
  vtx^.y := y;
  vtx^.u := u;
  vtx^.v := v;
end;

procedure nvg__tesselateBezier(ctx: PNVGContext; x1, y1, x2, y2, x3, y3, x4, y4: single; level: int32; aType: int32);
var
  x12, y12, x23, y23, x34, y34, x123, y123, x234, y234, x1234, y1234: single;
  dx, dy, d2, d3: single;
begin
  if (level > 10) then exit;

  x12 := (x1 + x2) * 0.5;
  y12 := (y1 + y2) * 0.5;
  x23 := (x2 + x3) * 0.5;
  y23 := (y2 + y3) * 0.5;
  x34 := (x3 + x4) * 0.5;
  y34 := (y3 + y4) * 0.5;
  x123 := (x12 + x23) * 0.5;
  y123 := (y12 + y23) * 0.5;

  dx := x4 - x1;
  dy := y4 - y1;
  d2 := nvg__absf(((x2 - x4) * dy - (y2 - y4) * dx));
  d3 := nvg__absf(((x3 - x4) * dy - (y3 - y4) * dx));

  if ((d2 + d3) * (d2 + d3) < ctx^.tessTol * (dx * dx + dy * dy)) then
  begin
    nvg__addPoint(ctx, x4, y4, aType);
    exit;
  end;

  x234 := (x23 + x34) * 0.5;
  y234 := (y23 + y34) * 0.5;
  x1234 := (x123 + x234) * 0.5;
  y1234 := (y123 + y234) * 0.5;

  nvg__tesselateBezier(ctx, x1, y1, x12, y12, x123, y123, x1234, y1234, level + 1, 0);
  nvg__tesselateBezier(ctx, x1234, y1234, x234, y234, x34, y34, x4, y4, level + 1, aType);
end;

procedure nvg__flattenPaths(ctx: PNVGContext);
var
  cache: PNVGPathCache;
  last, p0, p1, pts: PNVGPoint;
  path: PNVGPath;
  i, j: int32;
  cp1, cp2, p: psingle;
  area: single;
  cmd: int32;
begin
  cache := ctx^.cache;
  //  NVGstate* state = nvg__getState(ctx);

  if (cache^.npaths > 0) then
    exit;

  // Flatten
  i := 0;
  while (i < ctx^.ncommands) do
  begin
    cmd := trunc(ctx^.commands[i]);
    case cmd of
      Ord(NVG_MOVETO):
      begin
        nvg__addPath(ctx);
        p := @ctx^.commands[i + 1];
        nvg__addPoint(ctx, p[0], p[1], Ord(NVG_PT_CORNER));
        Inc(i, 3);
      end;
      Ord(NVG_LINETO):
      begin
        p := @ctx^.commands[i + 1];
        nvg__addPoint(ctx, p[0], p[1], Ord(NVG_PT_CORNER));
        Inc(i, 3);
      end;
      Ord(NVG_BEZIERTO):
      begin
        last := nvg__lastPoint(ctx);
        if (last <> nil) then
        begin
          cp1 := @ctx^.commands[i + 1];
          cp2 := @ctx^.commands[i + 3];
          p := @ctx^.commands[i + 5];
          nvg__tesselateBezier(ctx, last^.x, last^.y, cp1[0], cp1[1], cp2[0], cp2[1], p[0], p[1], 0, Ord(NVG_PT_CORNER));
        end;
        i += 7;
      end;
      Ord(NVG_CLOSE): begin
        nvg__closePath(ctx);
        Inc(i);
      end;
      Ord(NVG_WINDING): begin
        nvg__pathWinding(ctx, TNVGWinding(trunc(ctx^.commands[i + 1])));
        i += 2;
      end
      else
        Inc(i);
    end;
  end;

  cache^.bounds[0] := 1e6;
  cache^.bounds[1] := 1e6;
  cache^.bounds[2] := -1e6;
  cache^.bounds[3] := -1e6;

  // Calculate the direction and length of line segments.
  for j := 0 to cache^.npaths - 1 do
  begin
    path := @cache^.paths[j];
    pts := @cache^.points[path^.First];

    // If the first and last points are the same, remove the last, mark as closed path.
    p0 := @pts[path^.Count - 1];
    p1 := @pts[0];
    if (nvg__ptEquals(p0^.x, p0^.y, p1^.x, p1^.y, ctx^.distTol)) then
    begin
      Dec(path^.Count);
      p0 := @pts[path^.Count - 1];
      path^.closed := True;
    end;

    // Enforce winding.
    if (path^.Count > 2) then
    begin
      area := nvg__polyArea(pts, path^.Count);
      if (path^.winding = NVG_CCW) and (area < 0.0) then
        nvg__polyReverse(pts, path^.Count);
      if (path^.winding = NVG_CW) and (area > 0.0) then
        nvg__polyReverse(pts, path^.Count);

    end;

    for i := 0 to path^.Count - 1 do
    begin
      // Calculate segment direction and length
      p0^.dx := p1^.x - p0^.x;
      p0^.dy := p1^.y - p0^.y;
      p0^.len := nvg__normalize(p0^.dx, p0^.dy);
      // Update bounds
      cache^.bounds[0] := nvg__minf(cache^.bounds[0], p0^.x);
      cache^.bounds[1] := nvg__minf(cache^.bounds[1], p0^.y);
      cache^.bounds[2] := nvg__maxf(cache^.bounds[2], p0^.x);
      cache^.bounds[3] := nvg__maxf(cache^.bounds[3], p0^.y);
      // Advance
      Inc(p1);
      p0 := p1;
    end;
  end;
end;


function nvg__curveDivs(r, arc, tol: single): int32;
var
  da: single;
begin
  da := nvg__acosf(r / (r + tol)) * 2.0;
  Result := nvg__maxi(2, ceil(arc / da));
end;


procedure nvg__chooseBevel(bevel: boolean; p0, p1: PNVGpoint; w: single; var x0, y0, x1, y1: single);
begin
  if (bevel) then
  begin
    x0 := p1^.x + p0^.dy * w;
    y0 := p1^.y - p0^.dx * w;
    x1 := p1^.x + p1^.dy * w;
    y1 := p1^.y - p1^.dx * w;
  end
  else
  begin
    x0 := p1^.x + p1^.dmx * w;
    y0 := p1^.y + p1^.dmy * w;
    x1 := p1^.x + p1^.dmx * w;
    y1 := p1^.y + p1^.dmy * w;
  end;
end;

function nvg__roundJoin(dst: PNVGvertex; p0, p1: PNVGpoint; lw, rw, lu, ru: single; ncap: int32; fringe: single): PNVGvertex;
var
  i, n: int32;
  dlx0, dly0, dlx1, dly1: single;
  lx0, ly0, lx1, ly1, a0, a1: single;
  rx0, ry0, rx1, ry1: single;
  u, a, rx, ry, lx, ly: single;
begin
  dlx0 := p0^.dy;
  dly0 := -p0^.dx;
  dlx1 := p1^.dy;
  dly1 := -p1^.dx;
  // NVG_NOTUSED(fringe); // Non usato, commentato

  if (p1^.flags and Ord(NVG_PT_LEFT)) <> 0 then
  begin
    nvg__chooseBevel((p1^.flags and Ord(NVG_PR_INNERBEVEL)) <> 0, p0, p1, lw, lx0, ly0, lx1, ly1);
    a0 := ArcTan2(-dly0, -dlx0);
    a1 := ArcTan2(-dly1, -dlx1);
    if a1 > a0 then
      a1 := a1 - NVG_PI * 2;

    nvg__vset(dst, lx0, ly0, lu, 1);
    Inc(dst);
    nvg__vset(dst, p1^.x - dlx0 * rw, p1^.y - dly0 * rw, ru, 1);
    Inc(dst);

    n := nvg__clampi(Trunc(Ceil(((a0 - a1) / NVG_PI) * ncap)), 2, ncap);
    for i := 0 to n - 1 do
    begin
      u := i / (n - 1);
      a := a0 + u * (a1 - a0);
      rx := p1^.x + Cos(a) * rw;
      ry := p1^.y + Sin(a) * rw;
      nvg__vset(dst, p1^.x, p1^.y, 0.5, 1);
      Inc(dst);
      nvg__vset(dst, rx, ry, ru, 1);
      Inc(dst);
    end;

    nvg__vset(dst, lx1, ly1, lu, 1);
    Inc(dst);
    nvg__vset(dst, p1^.x - dlx1 * rw, p1^.y - dly1 * rw, ru, 1);
    Inc(dst);
  end
  else
  begin
    nvg__chooseBevel((p1^.flags and Ord(NVG_PR_INNERBEVEL)) <> 0, p0, p1, -rw, rx0, ry0, rx1, ry1);
    a0 := ArcTan2(dly0, dlx0);
    a1 := ArcTan2(dly1, dlx1);
    if a1 < a0 then
      a1 := a1 + NVG_PI * 2;

    nvg__vset(dst, p1^.x + dlx0 * rw, p1^.y + dly0 * rw, lu, 1);
    Inc(dst);
    nvg__vset(dst, rx0, ry0, ru, 1);
    Inc(dst);

    n := nvg__clampi(Trunc(Ceil(((a1 - a0) / NVG_PI) * ncap)), 2, ncap);
    for i := 0 to n - 1 do
    begin
      u := i / (n - 1);
      a := a0 + u * (a1 - a0);
      lx := p1^.x + Cos(a) * lw;
      ly := p1^.y + Sin(a) * lw;
      nvg__vset(dst, lx, ly, lu, 1);
      Inc(dst);
      nvg__vset(dst, p1^.x, p1^.y, 0.5, 1);
      Inc(dst);
    end;

    nvg__vset(dst, p1^.x + dlx1 * rw, p1^.y + dly1 * rw, lu, 1);
    Inc(dst);
    nvg__vset(dst, rx1, ry1, ru, 1);
    Inc(dst);
  end;

  Result := dst;
end;

function nvg__bevelJoin(dst: PNVGvertex; p0, p1: PNVGpoint; lw, rw, lu, ru, fringe: single): PNVGvertex;
var
  rx0, ry0, rx1, ry1: single;
  lx0, ly0, lx1, ly1: single;
  dlx0, dly0, dlx1, dly1: single;
begin
  dlx0 := p0^.dy;
  dly0 := -p0^.dx;
  dlx1 := p1^.dy;
  dly1 := -p1^.dx;
  // NVG_NOTUSED(fringe); // Non usato, commentato

  if (p1^.flags and Ord(NVG_PT_LEFT)) <> 0 then
  begin
    nvg__chooseBevel((p1^.flags and Ord(NVG_PR_INNERBEVEL)) <> 0, p0, p1, lw, lx0, ly0, lx1, ly1);

    nvg__vset(dst, lx0, ly0, lu, 1);
    Inc(dst);
    nvg__vset(dst, p1^.x - dlx0 * rw, p1^.y - dly0 * rw, ru, 1);
    Inc(dst);

    if (p1^.flags and Ord(NVG_PT_BEVEL)) <> 0 then
    begin
      nvg__vset(dst, lx0, ly0, lu, 1);
      Inc(dst);
      nvg__vset(dst, p1^.x - dlx0 * rw, p1^.y - dly0 * rw, ru, 1);
      Inc(dst);

      nvg__vset(dst, lx1, ly1, lu, 1);
      Inc(dst);
      nvg__vset(dst, p1^.x - dlx1 * rw, p1^.y - dly1 * rw, ru, 1);
      Inc(dst);
    end
    else
    begin
      rx0 := p1^.x - p1^.dmx * rw;
      ry0 := p1^.y - p1^.dmy * rw;

      nvg__vset(dst, p1^.x, p1^.y, 0.5, 1);
      Inc(dst);
      nvg__vset(dst, p1^.x - dlx0 * rw, p1^.y - dly0 * rw, ru, 1);
      Inc(dst);

      nvg__vset(dst, rx0, ry0, ru, 1);
      Inc(dst);
      nvg__vset(dst, rx0, ry0, ru, 1);
      Inc(dst);

      nvg__vset(dst, p1^.x, p1^.y, 0.5, 1);
      Inc(dst);
      nvg__vset(dst, p1^.x - dlx1 * rw, p1^.y - dly1 * rw, ru, 1);
      Inc(dst);
    end;

    nvg__vset(dst, lx1, ly1, lu, 1);
    Inc(dst);
    nvg__vset(dst, p1^.x - dlx1 * rw, p1^.y - dly1 * rw, ru, 1);
    Inc(dst);
  end
  else
  begin
    nvg__chooseBevel((p1^.flags and Ord(NVG_PR_INNERBEVEL)) <> 0, p0, p1, -rw, rx0, ry0, rx1, ry1);

    nvg__vset(dst, p1^.x + dlx0 * lw, p1^.y + dly0 * lw, lu, 1);
    Inc(dst);
    nvg__vset(dst, rx0, ry0, ru, 1);
    Inc(dst);

    if (p1^.flags and Ord(NVG_PT_BEVEL)) <> 0 then
    begin
      nvg__vset(dst, p1^.x + dlx0 * lw, p1^.y + dly0 * lw, lu, 1);
      Inc(dst);
      nvg__vset(dst, rx0, ry0, ru, 1);
      Inc(dst);

      nvg__vset(dst, p1^.x + dlx1 * lw, p1^.y + dly1 * lw, lu, 1);
      Inc(dst);
      nvg__vset(dst, rx1, ry1, ru, 1);
      Inc(dst);
    end
    else
    begin
      lx0 := p1^.x + p1^.dmx * lw;
      ly0 := p1^.y + p1^.dmy * lw;

      nvg__vset(dst, p1^.x + dlx0 * lw, p1^.y + dly0 * lw, lu, 1);
      Inc(dst);
      nvg__vset(dst, p1^.x, p1^.y, 0.5, 1);
      Inc(dst);

      nvg__vset(dst, lx0, ly0, lu, 1);
      Inc(dst);
      nvg__vset(dst, lx0, ly0, lu, 1);
      Inc(dst);

      nvg__vset(dst, p1^.x + dlx1 * lw, p1^.y + dly1 * lw, lu, 1);
      Inc(dst);
      nvg__vset(dst, p1^.x, p1^.y, 0.5, 1);
      Inc(dst);
    end;

    nvg__vset(dst, p1^.x + dlx1 * lw, p1^.y + dly1 * lw, lu, 1);
    Inc(dst);
    nvg__vset(dst, rx1, ry1, ru, 1);
    Inc(dst);
  end;

  Result := dst;
end;

function nvg__buttCapStart(dst: PNVGvertex; p: PNVGpoint; dx, dy, w, d, aa, u0, u1: single): PNVGvertex;
var
  px, py: single;
  dlx, dly: single;
begin
  px := p^.x - dx * d;
  py := p^.y - dy * d;
  dlx := dy;
  dly := -dx;

  nvg__vset(dst, px + dlx * w - dx * aa, py + dly * w - dy * aa, u0, 0);
  Inc(dst);

  nvg__vset(dst, px - dlx * w - dx * aa, py - dly * w - dy * aa, u1, 0);
  Inc(dst);

  nvg__vset(dst, px + dlx * w, py + dly * w, u0, 1);
  Inc(dst);

  nvg__vset(dst, px - dlx * w, py - dly * w, u1, 1);
  Inc(dst);

  Result := dst;
end;

function nvg__buttCapEnd(dst: PNVGvertex; p: PNVGpoint; dx, dy, w, d, aa, u0, u1: single): PNVGvertex;
var
  px, py: single;
  dlx, dly: single;
begin
  px := p^.x + dx * d;
  py := p^.y + dy * d;
  dlx := dy;
  dly := -dx;

  nvg__vset(dst, px + dlx * w, py + dly * w, u0, 1);
  Inc(dst);

  nvg__vset(dst, px - dlx * w, py - dly * w, u1, 1);
  Inc(dst);

  nvg__vset(dst, px + dlx * w + dx * aa, py + dly * w + dy * aa, u0, 0);
  Inc(dst);

  nvg__vset(dst, px - dlx * w + dx * aa, py - dly * w + dy * aa, u1, 0);
  Inc(dst);

  Result := dst;
end;

function nvg__roundCapStart(dst: PNVGvertex; p: PNVGpoint; dx, dy, w: single; ncap: int32; aa, u0, u1: single): PNVGvertex;
var
  i: int32;
  px, py: single;
  dlx, dly: single;
  a, ax, ay: single;
begin
  px := p^.x;
  py := p^.y;
  dlx := dy;
  dly := -dx;
  // NVG_NOTUSED(aa); // Non usato, commentato

  for i := 0 to ncap - 1 do
  begin
    a := i / (ncap - 1) * NVG_PI;
    ax := cos(a) * w;
    ay := sin(a) * w;

    nvg__vset(dst, px - dlx * ax - dx * ay, py - dly * ax - dy * ay, u0, 1);
    Inc(dst);

    nvg__vset(dst, px, py, 0.5, 1);
    Inc(dst);
  end;

  nvg__vset(dst, px + dlx * w, py + dly * w, u0, 1);
  Inc(dst);

  nvg__vset(dst, px - dlx * w, py - dly * w, u1, 1);
  Inc(dst);

  Result := dst;
end;

function nvg__roundCapEnd(dst: PNVGVertex; p: PNVGPoint; dx, dy, w: single; ncap: int32; aa, u0, u1: single): PNVGVertex;
var
  i: int32;
  px, py, dlx, dly, a, ax, ay: single;
begin
  px := p^.x;
  py := p^.y;
  dlx := dy;
  dly := -dx;
  // NVG_NOTUSED(aa); -- In Pascal, i parametri inutilizzati non richiedono macro specifiche

  nvg__vset(dst, px + dlx * w, py + dly * w, u0, 1);
  Inc(dst);
  nvg__vset(dst, px - dlx * w, py - dly * w, u1, 1);
  Inc(dst);

  for i := 0 to ncap - 1 do
  begin
    a := i / (ncap - 1) * NVG_PI;
    ax := Cos(a) * w;
    ay := Sin(a) * w;
    nvg__vset(dst, px, py, 0.5, 1);
    Inc(dst);
    nvg__vset(dst, px - dlx * ax + dx * ay, py - dly * ax + dy * ay, u0, 1);
    Inc(dst);
  end;

  Result := dst;
end;

procedure nvg__calculateJoins(ctx: PNVGContext; w: single; lineJoin: TNVGLineCap; miterLimit: single);
var
  cache: PNVGpathCache;
  nleft, i, j: int32;
  iw: single;
  path: PNVGPath;
  pts, p0, p1: PNVGPoint;
  dlx0, dly0, dlx1, dly1, dmr2, cross, limit, scale: single;
begin
  cache := ctx^.cache;
  iw := 0.0;

  if w > 0.0 then
    iw := 1.0 / w;

  // Calculate which joins needs extra vertices to append, and gather vertex count.
  for i := 0 to cache^.npaths - 1 do
  begin
    path := @cache^.paths[i];
    pts := @cache^.points[path^.First];
    p0 := @pts[path^.Count - 1];
    p1 := @pts[0];
    nleft := 0;

    path^.nbevel := 0;

    for j := 0 to path^.Count - 1 do
    begin
      dlx0 := p0^.dy;
      dly0 := -p0^.dx;
      dlx1 := p1^.dy;
      dly1 := -p1^.dx;
      // Calculate extrusions
      p1^.dmx := (dlx0 + dlx1) * 0.5;
      p1^.dmy := (dly0 + dly1) * 0.5;
      dmr2 := p1^.dmx * p1^.dmx + p1^.dmy * p1^.dmy;
      if dmr2 > 0.000001 then
      begin
        scale := 1.0 / dmr2;
        if scale > 600.0 then
          scale := 600.0;
        p1^.dmx := p1^.dmx * scale;
        p1^.dmy := p1^.dmy * scale;
      end;

      // Clear flags, but keep the corner.
      if (p1^.flags and Ord(NVG_PT_CORNER)) <> 0 then
        p1^.flags := Ord(NVG_PT_CORNER)
      else
        p1^.flags := 0;

      // Keep track of left turns.
      cross := p1^.dx * p0^.dy - p0^.dx * p1^.dy;
      if cross > 0.0 then
      begin
        Inc(nleft);
        p1^.flags := p1^.flags or Ord(NVG_PT_LEFT);
      end;

      // Calculate if we should use bevel or miter for inner join.
      limit := nvg__maxf(1.01, nvg__minf(p0^.len, p1^.len) * iw);
      if (dmr2 * limit * limit) < 1.0 then
        p1^.flags := p1^.flags or Ord(NVG_PR_INNERBEVEL);

      // Check to see if the corner needs to be beveled.
      if (p1^.flags and Ord(NVG_PT_CORNER)) <> 0 then
      begin
        if (dmr2 * miterLimit * miterLimit) < 1.0 then
          p1^.flags := p1^.flags or Ord(NVG_PT_BEVEL)
        else if (lineJoin = NVG_BEVEL) or (lineJoin = NVG_ROUND) then
          p1^.flags := p1^.flags or Ord(NVG_PT_BEVEL);
      end;

      if (p1^.flags and (Ord(NVG_PT_BEVEL) or Ord(NVG_PR_INNERBEVEL))) <> 0 then
        Inc(path^.nbevel);

      p0 := p1;
      Inc(p1);
    end;

    if nleft = path^.Count then
      path^.convex := True
    else
      path^.convex := False;
  end;
end;

function nvg__expandStroke(ctx: PNVGContext; w, fringe: single; lineCap, lineJoin: TNVGLineCap; miterLimit: single): int32;
var
  cache: PNVGPathCache;
  verts, dst: PNVGvertex;
  cverts, i, j: int32;
  aa, u0, u1: single;
  ncap: int32;
  path: PNVGpath;
  pts, p0, p1: PNVGpoint;
  s, e, loop: int32;
  dx, dy: single;
begin
  cache := ctx^.cache;
  aa := fringe; // ctx^.fringeWidth;
  u0 := 0.0;
  u1 := 1.0;
  ncap := nvg__curveDivs(w, NVG_PI, ctx^.tessTol); // Calcola divisioni per mezzo cerchio

  w := w + aa * 0.5;

  // Disabilita gradiente per antialiasing se non usato
  if aa = 0.0 then
  begin
    u0 := 0.5;
    u1 := 0.5;
  end;

  nvg__calculateJoins(ctx, w, lineJoin, miterLimit);

  // Calcola massimo utilizzo vertici
  cverts := 0;
  for i := 0 to cache^.npaths - 1 do
  begin
    path := @cache^.paths[i];
    loop := IfThen(path^.closed = False, 0, 1);
    if lineJoin = NVG_ROUND then
      cverts := cverts + (path^.Count + path^.nbevel * (ncap + 2) + 1) * 2 // più uno per il loop
    else
      cverts := cverts + (path^.Count + path^.nbevel * 5 + 1) * 2; // più uno per il loop
    if loop = 0 then
    begin
      // Spazio per i cap
      if lineCap = NVG_ROUND then
        cverts := cverts + (ncap * 2 + 2) * 2
      else
        cverts := cverts + (3 + 3) * 2;
    end;
  end;

  verts := nvg__allocTempVerts(ctx, cverts);
  if verts = nil then
  begin
    Result := 0;
    Exit;
  end;

  for i := 0 to cache^.npaths - 1 do
  begin
    path := @cache^.paths[i];
    pts := @cache^.points[path^.First];
    path^.fill := nil;
    path^.nfill := 0;

    // Calcola fringe o stroke
    loop := IfThen(path^.closed = False, 0, 1);
    dst := verts;
    path^.stroke := dst;

    if loop <> 0 then
    begin
      // Loop chiuso
      p0 := @pts[path^.Count - 1];
      p1 := @pts[0];
      s := 0;
      e := path^.Count;
    end
    else
    begin
      // Aggiungi cap iniziale
      p0 := @pts[0];
      p1 := @pts[1];
      s := 1;
      e := path^.Count - 1;
    end;

    if loop = 0 then
    begin
      // Aggiungi cap iniziale
      dx := p1^.x - p0^.x;
      dy := p1^.y - p0^.y;
      nvg__normalize(dx, dy);
      if lineCap = NVG_BUTT then
        dst := nvg__buttCapStart(dst, p0, dx, dy, w, -aa * 0.5, aa, u0, u1)
      else if (lineCap = NVG_BUTT) or (lineCap = NVG_SQUARE) then
        dst := nvg__buttCapStart(dst, p0, dx, dy, w, w - aa, aa, u0, u1)
      else if lineCap = NVG_ROUND then
        dst := nvg__roundCapStart(dst, p0, dx, dy, w, ncap, aa, u0, u1);
    end;

    for j := s to e - 1 do
    begin
      if (p1^.flags and (Ord(NVG_PT_BEVEL) or Ord(NVG_PR_INNERBEVEL))) <> 0 then
      begin
        if lineJoin = NVG_ROUND then
          dst := nvg__roundJoin(dst, p0, p1, w, w, u0, u1, ncap, aa)
        else
          dst := nvg__bevelJoin(dst, p0, p1, w, w, u0, u1, aa);
      end
      else
      begin
        nvg__vset(dst, p1^.x + (p1^.dmx * w), p1^.y + (p1^.dmy * w), u0, 1);
        Inc(dst);
        nvg__vset(dst, p1^.x - (p1^.dmx * w), p1^.y - (p1^.dmy * w), u1, 1);
        Inc(dst);
      end;
      p0 := p1;
      Inc(p1);
    end;

    if loop <> 0 then
    begin
      // Chiudi il loop
      nvg__vset(dst, verts[0].x, verts[0].y, u0, 1);
      Inc(dst);
      nvg__vset(dst, verts[1].x, verts[1].y, u1, 1);
      Inc(dst);
    end
    else
    begin
      // Aggiungi cap finale
      dx := p1^.x - p0^.x;
      dy := p1^.y - p0^.y;
      nvg__normalize(dx, dy);
      if lineCap = NVG_BUTT then
        dst := nvg__buttCapEnd(dst, p1, dx, dy, w, -aa * 0.5, aa, u0, u1)
      else if (lineCap = NVG_BUTT) or (lineCap = NVG_SQUARE) then
        dst := nvg__buttCapEnd(dst, p1, dx, dy, w, w - aa, aa, u0, u1)
      else if lineCap = NVG_ROUND then
        dst := nvg__roundCapEnd(dst, p1, dx, dy, w, ncap, aa, u0, u1);
    end;

    path^.nstroke := int32(dst - verts);

    verts := dst;
  end;

  Result := 1;
end;

function nvg__expandFill(ctx: PNVGContext; w: single; lineJoin: TNVGLineCap; miterLimit: single): int32;
var
  cache: PNVGpathCache;
  verts: PNVGVertex;
  dst: PNVGVertex;
  path: PNVGPath;
  cverts, i, j: int32;
  aa, woff, lw, rw, lu, ru: single;
  fringe, convex: boolean;
  pts, p0, p1: PNVGPoint;
  dlx0, dly0, dlx1, dly1, lx, ly, lx0, ly0, lx1, ly1: single;
begin
  cache := ctx^.cache;
  aa := ctx^.fringeWidth;
  fringe := w > 0.0;

  nvg__calculateJoins(ctx, w, lineJoin, miterLimit);

  // Calculate max vertex usage.
  cverts := 0;
  for i := 0 to cache^.npaths - 1 do
  begin
    path := @cache^.paths[i];
    cverts += path^.Count + path^.nbevel + 1;
    if fringe then
      cverts += (path^.Count + path^.nbevel * 5 + 1) * 2; // plus one for loop
  end;

  verts := nvg__allocTempVerts(ctx, cverts);
  if verts = nil then
    exit(0);

  convex := (cache^.npaths = 1) and cache^.paths[0].convex;

  for i := 0 to cache^.npaths - 1 do
  begin
    path := @cache^.paths[i];
    pts := @cache^.points[path^.First];
    dst := verts;
    path^.fill := dst;

    // Calculate shape vertices.
    woff := 0.5 * aa;

    if fringe then
    begin
      // Looping
      p0 := @pts[path^.Count - 1];
      p1 := @pts[0];
      for j := 0 to path^.Count - 1 do
      begin
        if (p1^.flags and Ord(NVG_PT_BEVEL)) <> 0 then
        begin
          dlx0 := p0^.dy;
          dly0 := -p0^.dx;
          dlx1 := p1^.dy;
          dly1 := -p1^.dx;
          if (p1^.flags and Ord(NVG_PT_LEFT)) <> 0 then
          begin
            lx := p1^.x + p1^.dmx * woff;
            ly := p1^.y + p1^.dmy * woff;
            nvg__vset(dst, lx, ly, 0.5, 1);
            Inc(dst);
          end
          else
          begin
            lx0 := p1^.x + dlx0 * woff;
            ly0 := p1^.y + dly0 * woff;
            lx1 := p1^.x + dlx1 * woff;
            ly1 := p1^.y + dly1 * woff;
            nvg__vset(dst, lx0, ly0, 0.5, 1);
            Inc(dst);
            nvg__vset(dst, lx1, ly1, 0.5, 1);
            Inc(dst);
          end;
        end
        else
        begin
          nvg__vset(dst, p1^.x + (p1^.dmx * woff), p1^.y + (p1^.dmy * woff), 0.5, 1);
          Inc(dst);
        end;
        p0 := p1;
        Inc(p1);
      end;
    end
    else
    begin
      for j := 0 to path^.Count - 1 do
      begin
        nvg__vset(dst, pts[j].x, pts[j].y, 0.5, 1);
        Inc(dst);
      end;
    end;

    path^.nfill := int32(dst - verts);
    verts := dst;

    // Calculate fringe
    if fringe then
    begin
      lw := w + woff;
      rw := w - woff;
      lu := 0;
      ru := 1;
      dst := verts;
      path^.stroke := dst;

      // Create only half a fringe for convex shapes so that
      // the shape can be rendered without stenciling.
      if convex then
      begin
        lw := woff; // This should generate the same vertex as fill inset above.
        lu := 0.5;  // Set outline fade at middle.
      end;

      // Looping
      p0 := @pts[path^.Count - 1];
      p1 := @pts[0];

      for j := 0 to path^.Count - 1 do
      begin
        if (p1^.flags and (Ord(NVG_PT_BEVEL) or Ord(NVG_PR_INNERBEVEL))) <> 0 then
        begin
          dst := nvg__bevelJoin(dst, p0, p1, lw, rw, lu, ru, ctx^.fringeWidth);
        end
        else
        begin
          nvg__vset(dst, p1^.x + (p1^.dmx * lw), p1^.y + (p1^.dmy * lw), lu, 1);
          Inc(dst);
          nvg__vset(dst, p1^.x - (p1^.dmx * rw), p1^.y - (p1^.dmy * rw), ru, 1);
          Inc(dst);
        end;
        p0 := p1;
        Inc(p1);
      end;

      // Loop it
      nvg__vset(dst, verts[0].x, verts[0].y, lu, 1);
      Inc(dst);
      nvg__vset(dst, verts[1].x, verts[1].y, ru, 1);
      Inc(dst);

      path^.nstroke := int32(dst - verts);
      verts := dst;
    end
    else
    begin
      path^.stroke := nil;
      path^.nstroke := 0;
    end;
  end;

  Result := 1;
end;


// Draw
procedure nvgBeginPath(ctx: PNVGContext);
begin
  ctx^.ncommands := 0;
  nvg__clearPathCache(ctx);
end;

procedure nvgMoveTo(ctx: PNVGContext; x, y: single);
var
  vals: array[0..2] of single;
begin
  vals[0] := int32(NVG_MOVETO) * 1.0;
  vals[1] := x;
  vals[2] := y;
  nvg__appendCommands(ctx, @vals[0], 3);
end;

procedure nvgLineTo(ctx: PNVGContext; x, y: single);
var
  vals: array[0..2] of single;
begin
  vals[0] := int32(NVG_LINETO) * 1.0;
  vals[1] := x;
  vals[2] := y;
  nvg__appendCommands(ctx, @vals[0], 3);
end;

procedure nvgBezierTo(ctx: PNVGContext; c1x, c1y, c2x, c2y, x, y: single);
var
  vals: array[0..6] of single;
begin
  vals[0] := int32(NVG_BEZIERTO) * 1.0;
  vals[1] := c1x;
  vals[2] := c1y;
  vals[3] := c2x;
  vals[4] := c2y;
  vals[5] := x;
  vals[6] := y;
  nvg__appendCommands(ctx, @vals[0], 7);
end;

procedure nvgQuadTo(ctx: PNVGContext; cx, cy, x, y: single);
var
  x0, y0: single;
  vals: array[0..6] of single;
begin
  x0 := ctx^.commandx;
  y0 := ctx^.commandy;
  vals[0] := int32(NVG_BEZIERTO);
  vals[1] := x0 + 2.0 / 3.0 * (cx - x0);
  vals[2] := y0 + 2.0 / 3.0 * (cy - y0);
  vals[3] := x + 2.0 / 3.0 * (cx - x);
  vals[4] := y + 2.0 / 3.0 * (cy - y);
  vals[5] := x;
  vals[6] := y;
  nvg__appendCommands(ctx, @vals[0], 7);
end;

procedure nvgArcTo(ctx: PNVGContext; x1, y1, x2, y2, radius: single);
var
  x0, y0, dx0, dy0, dx1, dy1, a, d, cx, cy, a0, a1: single;
  dir: TNVGWinding;
begin
  x0 := ctx^.commandx;
  y0 := ctx^.commandy;

  if ctx^.ncommands = 0 then
    Exit;

  // Gestione casi degenerati
  if nvg__ptEquals(x0, y0, x1, y1, ctx^.distTol) or nvg__ptEquals(x1, y1, x2, y2, ctx^.distTol) or (nvg__distPtSeg(x1, y1, x0, y0, x2, y2) < ctx^.distTol * ctx^.distTol) or (radius < ctx^.distTol) then
  begin
    nvgLineTo(ctx, x1, y1);
    Exit;
  end;

  // Calcola cerchio tangente alle linee (x0,y0)-(x1,y1) e (x1,y1)-(x2,y2)
  dx0 := x0 - x1;
  dy0 := y0 - y1;
  dx1 := x2 - x1;
  dy1 := y2 - y1;
  nvg__normalize(dx0, dy0);
  nvg__normalize(dx1, dy1);
  a := nvg__acosf(dx0 * dx1 + dy0 * dy1);
  d := radius / nvg__tanf(a / 2.0);

  if d > 10000.0 then
  begin
    nvgLineTo(ctx, x1, y1);
    Exit;
  end;

  if nvg__cross(dx0, dy0, dx1, dy1) > 0.0 then
  begin
    cx := x1 + dx0 * d + dy0 * radius;
    cy := y1 + dy0 * d - dx0 * radius;
    a0 := nvg__atan2f(dx0, -dy0);
    a1 := nvg__atan2f(-dx1, dy1);
    dir := NVG_CW;
  end
  else
  begin
    cx := x1 + dx0 * d - dy0 * radius;
    cy := y1 + dy0 * d + dx0 * radius;
    a0 := nvg__atan2f(-dx0, dy0);
    a1 := nvg__atan2f(dx1, -dy1);
    dir := NVG_CCW;
  end;

  nvgArc(ctx, cx, cy, radius, a0, a1, dir);
end;

procedure nvgClosePath(ctx: PNVGContext);
var
  vals: array[0..0] of single;
begin
  vals[0] := int32(NVG_CLOSE);
  nvg__appendCommands(ctx, @vals[0], 1);
end;

procedure nvgPathWinding(ctx: PNVGContext; dir: int32);
var
  vals: array[0..1] of single;
begin
  vals[0] := int32(NVG_WINDING);
  vals[1] := dir;
  nvg__appendCommands(ctx, @vals[0], 2);
end;


procedure nvgArc(ctx: PNVGContext; cx, cy, r, a0, a1: single; dir: TNVGWinding);
var
  a, da, hda, kappa: single;
  dx, dy, x, y, tanx, tany: single;
  px, py, ptanx, ptany: single;
  vals: array[0..3 + 5 * 7 + 100 - 1] of single;
  i, ndivs, nvals: int32;
  move: int32;
begin
  // Inizializzazione variabili
  a := 0;
  da := 0;
  hda := 0;
  kappa := 0;
  dx := 0;
  dy := 0;
  x := 0;
  y := 0;
  tanx := 0;
  tany := 0;
  px := 0;
  py := 0;
  ptanx := 0;
  ptany := 0;

  // Determina il comando iniziale (MOVETO o LINETO)
  if ctx^.ncommands > 0 then
    move := NVG_LINETO
  else
    move := NVG_MOVETO;

  // Clampa gli angoli
  da := a1 - a0;
  if dir = NVG_CW then
  begin
    if nvg__absf(da) >= NVG_PI * 2 then
      da := NVG_PI * 2
    else
      while da < 0.0 do
        da := da + NVG_PI * 2;
  end
  else
  begin
    if nvg__absf(da) >= NVG_PI * 2 then
      da := -NVG_PI * 2
    else
      while da > 0.0 do
        da := da - NVG_PI * 2;
  end;

  // Divide l'arco in segmenti di massimo 90 gradi
  ndivs := nvg__maxi(1, nvg__mini(Trunc(nvg__absf(da) / (NVG_PI * 0.5) + 0.5), 5));
  hda := (da / ndivs) / 2.0;
  kappa := nvg__absf(4.0 / 3.0 * (1.0 - nvg__cosf(hda)) / nvg__sinf(hda));

  if dir = NVG_CCW then
    kappa := -kappa;

  nvals := 0;
  for i := 0 to ndivs do
  begin
    a := a0 + da * (i / ndivs);
    dx := nvg__cosf(a);
    dy := nvg__sinf(a);
    x := cx + dx * r;
    y := cy + dy * r;
    tanx := -dy * r * kappa;
    tany := dx * r * kappa;

    if i = 0 then
    begin
      vals[nvals] := move;
      Inc(nvals);
      vals[nvals] := x;
      Inc(nvals);
      vals[nvals] := y;
      Inc(nvals);
    end
    else
    begin
      vals[nvals] := int32(NVG_BEZIERTO);
      Inc(nvals);
      vals[nvals] := px + ptanx;
      Inc(nvals);
      vals[nvals] := py + ptany;
      Inc(nvals);
      vals[nvals] := x - tanx;
      Inc(nvals);
      vals[nvals] := y - tany;
      Inc(nvals);
      vals[nvals] := x;
      Inc(nvals);
      vals[nvals] := y;
      Inc(nvals);
    end;
    px := x;
    py := y;
    ptanx := tanx;
    ptany := tany;
  end;

  nvg__appendCommands(ctx, @vals[0], nvals);
end;


procedure nvgRect(ctx: PNVGContext; x, y, w, h: single);
var
  vals: array[0..12] of single;
begin
  vals[0] := int32(NVG_MOVETO);
  vals[1] := x;
  vals[2] := y;
  vals[3] := int32(NVG_LINETO);
  vals[4] := x;
  vals[5] := y + h;
  vals[6] := int32(NVG_LINETO);
  vals[7] := x + w;
  vals[8] := y + h;
  vals[9] := int32(NVG_LINETO);
  vals[10] := x + w;
  vals[11] := y;
  vals[12] := int32(NVG_CLOSE);
  nvg__appendCommands(ctx, @vals[0], 13);
end;

procedure nvgRoundedRect(ctx: PNVGContext; x, y, w, h, r: single);
begin
  nvgRoundedRectVarying(ctx, x, y, w, h, r, r, r, r);
end;

procedure nvgRoundedRectVarying(ctx: PNVGContext; x, y, w, h, radTopLeft, radTopRight, radBottomRight, radBottomLeft: single);
var
  halfw, halfh: single;
  rxBL, ryBL, rxBR, ryBR, rxTR, ryTR, rxTL, ryTL: single;
  vals: array[0..43] of single;
begin
  if (radTopLeft < 0.1) and (radTopRight < 0.1) and (radBottomRight < 0.1) and (radBottomLeft < 0.1) then
  begin
    nvgRect(ctx, x, y, w, h);
    Exit;
  end
  else
  begin
    halfw := Abs(w) * 0.5;
    halfh := Abs(h) * 0.5;
    rxBL := Min(radBottomLeft, halfw) * Sign(w);
    ryBL := Min(radBottomLeft, halfh) * Sign(h);
    rxBR := Min(radBottomRight, halfw) * Sign(w);
    ryBR := Min(radBottomRight, halfh) * Sign(h);
    rxTR := Min(radTopRight, halfw) * Sign(w);
    ryTR := Min(radTopRight, halfh) * Sign(h);
    rxTL := Min(radTopLeft, halfw) * Sign(w);
    ryTL := Min(radTopLeft, halfh) * Sign(h);

    vals[0] := int32(NVG_MOVETO);
    vals[1] := x;
    vals[2] := y + ryTL;
    vals[3] := int32(NVG_LINETO);
    vals[4] := x;
    vals[5] := y + h - ryBL;
    vals[6] := int32(NVG_BEZIERTO);
    vals[7] := x;
    vals[8] := y + h - ryBL * (1 - NVG_KAPPA90);
    vals[9] := x + rxBL * (1 - NVG_KAPPA90);
    vals[10] := y + h;
    vals[11] := x + rxBL;
    vals[12] := y + h;
    vals[13] := int32(NVG_LINETO);
    vals[14] := x + w - rxBR;
    vals[15] := y + h;
    vals[16] := int32(NVG_BEZIERTO);
    vals[17] := x + w - rxBR * (1 - NVG_KAPPA90);
    vals[18] := y + h;
    vals[19] := x + w;
    vals[20] := y + h - ryBR * (1 - NVG_KAPPA90);
    vals[21] := x + w;
    vals[22] := y + h - ryBR;
    vals[23] := int32(NVG_LINETO);
    vals[24] := x + w;
    vals[25] := y + ryTR;
    vals[26] := int32(NVG_BEZIERTO);
    vals[27] := x + w;
    vals[28] := y + ryTR * (1 - NVG_KAPPA90);
    vals[29] := x + w - rxTR * (1 - NVG_KAPPA90);
    vals[30] := y;
    vals[31] := x + w - rxTR;
    vals[32] := y;
    vals[33] := int32(NVG_LINETO);
    vals[34] := x + rxTL;
    vals[35] := y;
    vals[36] := int32(NVG_BEZIERTO);
    vals[37] := x + rxTL * (1 - NVG_KAPPA90);
    vals[38] := y;
    vals[39] := x;
    vals[40] := y + ryTL * (1 - NVG_KAPPA90);
    vals[41] := x;
    vals[42] := y + ryTL;
    vals[43] := int32(NVG_CLOSE);

    nvg__appendCommands(ctx, vals, Length(vals));
  end;
end;

procedure nvgEllipse(ctx: PNVGContext; cx, cy, rx, ry: single);
var
  vals: array[0..31] of single;
begin
  vals[0] := int32(NVG_MOVETO);
  vals[1] := cx - rx;
  vals[2] := cy;
  vals[3] := int32(NVG_BEZIERTO);
  vals[4] := cx - rx;
  vals[5] := cy + ry * NVG_KAPPA90;
  vals[6] := cx - rx * NVG_KAPPA90;
  vals[7] := cy + ry;
  vals[8] := cx;
  vals[9] := cy + ry;
  vals[10] := int32(NVG_BEZIERTO);
  vals[11] := cx + rx * NVG_KAPPA90;
  vals[12] := cy + ry;
  vals[13] := cx + rx;
  vals[14] := cy + ry * NVG_KAPPA90;
  vals[15] := cx + rx;
  vals[16] := cy;
  vals[17] := int32(NVG_BEZIERTO);
  vals[18] := cx + rx;
  vals[19] := cy - ry * NVG_KAPPA90;
  vals[20] := cx + rx * NVG_KAPPA90;
  vals[21] := cy - ry;
  vals[22] := cx;
  vals[23] := cy - ry;
  vals[24] := int32(NVG_BEZIERTO);
  vals[25] := cx - rx * NVG_KAPPA90;
  vals[26] := cy - ry;
  vals[27] := cx - rx;
  vals[28] := cy - ry * NVG_KAPPA90;
  vals[29] := cx - rx;
  vals[30] := cy;
  vals[31] := int32(NVG_CLOSE);

  nvg__appendCommands(ctx, vals, Length(vals));
end;

procedure nvgCircle(ctx: PNVGContext; cx, cy, r: single);
begin
  nvgEllipse(ctx, cx, cy, r, r);
end;

procedure nvgDebugDumpPathCache(ctx: PNVGContext);
{
var
  path: PNVGPath;
  i, j: int32;
}
begin
  (*
  printf("Dumping %d cached paths\n", ctx^.cache^.npaths);
  for (i = 0; i < ctx^.cache^.npaths; i++) {
    path = &ctx^.cache^.paths[i];
    printf(" - Path %d\n", i);
    if (path^.nfill) {
      printf("   - fill: %d\n", path^.nfill);
      for (j = 0; j < path^.nfill; j++)
        printf("%f\t%f\n", path^.fill[j].x, path^.fill[j].y);
    }
    if (path^.nstroke) {
      printf("   - stroke: %d\n", path^.nstroke);
      for (j = 0; j < path^.nstroke; j++)
        printf("%f\t%f\n", path^.stroke[j].x, path^.stroke[j].y);
    }
  }
  *)
end;

procedure nvgFill(ctx: PNVGContext);
var
  state: PNVGState;
  path: PNVGPath;
  fillPaint: TNVGPaint;
  i: int32;
begin
  state := nvg__getState(ctx);
  fillPaint := state^.fill;
  nvg__flattenPaths(ctx);
  if (ctx^.params^.edgeAntiAlias and state^.shapeAntiAlias) then
    nvg__expandFill(ctx, ctx^.fringeWidth, NVG_MITER, 2.4)
  else
    nvg__expandFill(ctx, 0.0, NVG_MITER, 2.4);

  // Apply global alpha
  fillPaint.innerColor.a *= state^.alpha;
  fillPaint.outerColor.a *= state^.alpha;

  ctx^.params^.renderFill(ctx^.params^.userPtr, @fillPaint, state^.compositeOperation, @state^.scissor, ctx^.fringeWidth, ctx^.cache^.bounds, ctx^.cache^.paths, ctx^.cache^.npaths);

  // Count triangles
  for i := 0 to ctx^.cache^.npaths - 1 do
  begin
    path := @(ctx^.cache^.paths[i]);
    ctx^.fillTriCount += path^.nfill - 2;
    ctx^.fillTriCount += path^.nstroke - 2;
    ctx^.drawCallCount += 2;
  end;
end;

procedure nvgStroke(ctx: PNVGContext);
var
  state: PNVGstate;
  scale: single;
  strokeWidth: single;
  strokePaint: TNVGPaint;
  path: PNVGpath;
  i: int32;
  alpha: single;
begin
  state := nvg__getState(ctx);
  scale := nvg__getAverageScale(@state^.xform[0]);
  strokeWidth := nvg__clampf(state^.strokeWidth * scale, 0.0, 200.0);
  strokePaint := state^.stroke;

  if strokeWidth < ctx^.fringeWidth then
  begin
    // Se lo spessore dello stroke è inferiore alla dimensione del pixel, usa alpha per emulare la copertura
    alpha := nvg__clampf(strokeWidth / ctx^.fringeWidth, 0.0, 1.0);
    strokePaint.innerColor.a := strokePaint.innerColor.a * alpha * alpha;
    strokePaint.outerColor.a := strokePaint.outerColor.a * alpha * alpha;
    strokeWidth := ctx^.fringeWidth;
  end;

  // Applica alpha globale
  strokePaint.innerColor.a := strokePaint.innerColor.a * state^.alpha;
  strokePaint.outerColor.a := strokePaint.outerColor.a * state^.alpha;

  nvg__flattenPaths(ctx);

  if (ctx^.params^.edgeAntiAlias and state^.shapeAntiAlias) then
    nvg__expandStroke(ctx, strokeWidth * 0.5, ctx^.fringeWidth, state^.lineCap, state^.lineJoin, state^.miterLimit)
  else
    nvg__expandStroke(ctx, strokeWidth * 0.5, 0.0, state^.lineCap, state^.lineJoin, state^.miterLimit);

  ctx^.params^.renderStroke(ctx^.params^.userPtr, @strokePaint, state^.compositeOperation, @state^.scissor, ctx^.fringeWidth,
    strokeWidth, ctx^.cache^.paths, ctx^.cache^.npaths);

  // Conta i triangoli
  for i := 0 to ctx^.cache^.npaths - 1 do
  begin
    path := @ctx^.cache^.paths[i];
    ctx^.strokeTriCount := ctx^.strokeTriCount + (path^.nstroke - 2);
    Inc(ctx^.drawCallCount);
  end;
end;


// Add fonts
function nvgCreateFont(ctx: PNVGContext; const Name, filename: pchar): int32;
begin
  Result := fonsAddFont(ctx^.fs, Name, filename, 0);
end;

function nvgCreateFontAtIndex(ctx: PNVGContext; const Name, filename: pchar; fontIndex: int32): int32;
begin
  Result := fonsAddFont(ctx^.fs, Name, filename, fontIndex);
end;

function nvgCreateFontMem(ctx: PNVGContext; const Name: pchar; Data: pbyte; ndata, freeData: int32): int32;
begin
  Result := fonsAddFontMem(ctx^.fs, Name, Data, ndata, freeData, 0);
end;

function nvgCreateFontMemAtIndex(ctx: PNVGContext; Name: pchar; Data: pbyte; ndata, freeData: int32; fontIndex: int32): int32;
begin
  Result := fonsAddFontMem(ctx^.fs, Name, Data, ndata, freeData, fontIndex);
end;

function nvgFindFont(ctx: PNVGContext; const Name: pchar): int32;
begin
  if Name = nil then
    Exit(-1);
  Result := fonsGetFontByName(ctx^.fs, Name);
end;

function nvgAddFallbackFontId(ctx: PNVGContext; baseFont: int32; fallbackFont: int32): int32;
begin
  if (baseFont = -1) or (fallbackFont = -1) then
    Exit(0);
  Result := fonsAddFallbackFont(ctx^.fs, baseFont, fallbackFont);
end;

function nvgAddFallbackFont(ctx: PNVGContext; const baseFont, fallbackFont: pchar): int32;
begin
  Result := nvgAddFallbackFontId(ctx, nvgFindFont(ctx, baseFont), nvgFindFont(ctx, fallbackFont));
end;

procedure nvgResetFallbackFontsId(ctx: PNVGContext; baseFont: int32);
begin
  fonsResetFallbackFont(ctx^.fs, baseFont);
end;

procedure nvgResetFallbackFonts(ctx: PNVGContext; const baseFont: pchar);
begin
  nvgResetFallbackFontsId(ctx, nvgFindFont(ctx, baseFont));
end;

// State setting
procedure nvgFontSize(ctx: PNVGContext; size: single);
var
  state: PNVGState;
begin
  state := nvg__getState(ctx);
  state^.fontSize := size;
end;

procedure nvgFontBlur(ctx: PNVGContext; blur: single);
var
  state: PNVGState;
begin
  state := nvg__getState(ctx);
  state^.fontBlur := blur;
end;

procedure nvgTextLetterSpacing(ctx: PNVGContext; spacing: single);
var
  state: PNVGState;
begin
  state := nvg__getState(ctx);
  state^.letterSpacing := spacing;
end;

procedure nvgTextLineHeight(ctx: PNVGContext; lineHeight: single);
var
  state: PNVGState;
begin
  state := nvg__getState(ctx);
  state^.lineHeight := lineHeight;
end;

procedure nvgTextAlign(ctx: PNVGContext; align: TNVGAligns);
var
  state: PNVGState;
begin
  state := nvg__getState(ctx);
  state^.textAlign := align;
end;

procedure nvgFontFaceId(ctx: PNVGContext; font: int32);
var
  state: PNVGState;
begin
  state := nvg__getState(ctx);
  state^.fontId := font;
end;

procedure nvgFontFace(ctx: PNVGContext; const font: pchar);
var
  state: PNVGState;
begin
  state := nvg__getState(ctx);
  state^.fontId := fonsGetFontByName(ctx^.fs, font);
end;

function nvg__quantize(a, d: single): single;
begin
  Result := Trunc(a / d + 0.5) * d;
end;

function nvg__getFontScale(state: PNVGState): single;
begin
  Result := nvg__minf(nvg__quantize(nvg__getAverageScale(state^.xform), 0.01), 4.0);
end;

procedure nvg__flushTextTexture(ctx: PNVGContext);
var
  dirty: array[0..3] of int32;
  fontImage, iw, ih, x, y, w, h: int32;
  Data: pbyte;
begin
  if fonsValidateTexture(ctx^.fs, @dirty[0]) then
  begin
    fontImage := ctx^.fontImages[ctx^.fontImageIdx];
    // Aggiorna la texture
    if fontImage <> 0 then
    begin
      Data := fonsGetTextureData(ctx^.fs, @iw, @ih);
      x := dirty[0];
      y := dirty[1];
      w := dirty[2] - dirty[0];
      h := dirty[3] - dirty[1];
      ctx^.params^.renderUpdateTexture(ctx^.params^.userPtr, fontImage, x, y, w, h, Data);
    end;
  end;
end;

function nvg__allocTextAtlas(ctx: PNVGContext): boolean;
var
  iw: int32 = 0;
  ih: int32 = 0;
begin
  Result := False;
  nvg__flushTextTexture(ctx);
  if ctx^.fontImageIdx >= NVG_MAX_FONTIMAGES - 1 then
  begin
    Exit;
  end;
  // Se l'immagine del font successiva ha già una texture
  if ctx^.fontImages[ctx^.fontImageIdx + 1] <> 0 then
    nvgImageSize(ctx, ctx^.fontImages[ctx^.fontImageIdx + 1], iw, ih)
  else
  begin
    // Calcola la nuova dimensione dell'immagine del font e creala
    nvgImageSize(ctx, ctx^.fontImages[ctx^.fontImageIdx], iw, ih);
    if iw > ih then
      ih := ih * 2
    else
      iw := iw * 2;
    if (iw > NVG_MAX_FONTIMAGE_SIZE) or (ih > NVG_MAX_FONTIMAGE_SIZE) then
    begin
      iw := NVG_MAX_FONTIMAGE_SIZE;
      ih := NVG_MAX_FONTIMAGE_SIZE;
    end;
    ctx^.fontImages[ctx^.fontImageIdx + 1] := ctx^.params^.renderCreateTexture(ctx^.params^.userPtr, NVG_TEXTURE_ALPHA, iw, ih, 0, nil);
  end;
  Inc(ctx^.fontImageIdx);
  fonsResetAtlas(ctx^.fs, iw, ih);
  Result := True;
end;

procedure nvg__renderText(ctx: PNVGContext; verts: PNVGVertex; nverts: int32);
var
  state: PNVGState;
  paint: TNVGPaint;
begin
  state := nvg__getState(ctx);
  paint := state^.fill;

  // Imposta l'immagine della texture
  paint.image := ctx^.fontImages[ctx^.fontImageIdx];

  // Applica l'alpha globale
  paint.innerColor.a := paint.innerColor.a * state^.alpha;
  paint.outerColor.a := paint.outerColor.a * state^.alpha;

  // Render dei triangoli
  ctx^.params^.renderTriangles(ctx^.params^.userPtr, @paint, state^.compositeOperation, @state^.scissor, verts, nverts, ctx^.fringeWidth);

  Inc(ctx^.drawCallCount);
  ctx^.textTriCount := ctx^.textTriCount + (nverts div 3);
end;

function nvg__isTransformFlipped(const xform: PSingle): boolean;
var
  det: single;
begin
  det := xform[0] * xform[3] - xform[2] * xform[1];
  Result := det < 0;
end;

function nvgText(ctx: PNVGContext; x, y: single; start, stop: pchar): single;
var
  state: PNVGState;
  iter, prevIter: TFONSTextIter;
  q: TFONSQuad;
  verts: PNVGVertex;
  scale, invscale: single;
  cverts, nverts: int32;
  isFlipped: boolean;
  c: array[0..7] of single;
begin
  state := nvg__getState(ctx);
  scale := nvg__getFontScale(state) * ctx^.devicePxRatio;
  invscale := 1.0 / scale;
  cverts := 0;
  nverts := 0;
  isFlipped := nvg__isTransformFlipped(@state^.xform);

  if stop = nil then
    stop := start + StrLen(start);

  if state^.fontId = FONS_INVALID then
  begin
    Result := x;
    Exit;
  end;

  fonsSetSize(ctx^.fs, state^.fontSize * scale);
  fonsSetSpacing(ctx^.fs, state^.letterSpacing * scale);
  fonsSetBlur(ctx^.fs, state^.fontBlur * scale);
  fonsSetAlign(ctx^.fs, state^.textAlign);
  fonsSetFont(ctx^.fs, state^.fontId);

  cverts := nvg__maxi(2, Trunc(stop - start)) * 6; // Stima conservativa
  verts := nvg__allocTempVerts(ctx, cverts);
  if verts = nil then
  begin
    Result := x;
    Exit;
  end;

  if not fonsTextIterInit(ctx^.fs, @iter, x * scale, y * scale, start, stop, FONS_GLYPH_BITMAP_REQUIRED) then
  begin
    Result := x;
    Exit;
  end;

  prevIter := iter;
  while fonsTextIterNext(ctx^.fs, @iter, @q) do
  begin
    if iter.prevGlyphIndex = -1 then // Impossibile recuperare il glifo?
    begin
      if nverts <> 0 then
      begin
        nvg__renderText(ctx, verts, nverts);
        nverts := 0;
      end;
      if not nvg__allocTextAtlas(ctx) then
        Break; // Nessuna memoria
      iter := prevIter;
      if not fonsTextIterNext(ctx^.fs, @iter, @q) then // Riprova
        Break; // Ancora nessun glifo
    end;
    prevIter := iter;
    if isFlipped then
    begin
      c[0] := q.y0;
      q.y0 := q.y1;
      q.y1 := c[0]; // Scambia y0 e y1
      c[0] := q.t0;
      q.t0 := q.t1;
      q.t1 := c[0]; // Scambia t0 e t1
    end;
    // Trasforma i vertici
    nvgTransformPoint(@c[0], @c[1], @state^.xform, q.x0 * invscale, q.y0 * invscale);
    nvgTransformPoint(@c[2], @c[3], @state^.xform, q.x1 * invscale, q.y0 * invscale);
    nvgTransformPoint(@c[4], @c[5], @state^.xform, q.x1 * invscale, q.y1 * invscale);
    nvgTransformPoint(@c[6], @c[7], @state^.xform, q.x0 * invscale, q.y1 * invscale);
    // Crea i triangoli
    if nverts + 6 <= cverts then
    begin
      nvg__vset(@verts[nverts], c[0], c[1], q.s0, q.t0);
      Inc(nverts);
      nvg__vset(@verts[nverts], c[4], c[5], q.s1, q.t1);
      Inc(nverts);
      nvg__vset(@verts[nverts], c[2], c[3], q.s1, q.t0);
      Inc(nverts);
      nvg__vset(@verts[nverts], c[0], c[1], q.s0, q.t0);
      Inc(nverts);
      nvg__vset(@verts[nverts], c[6], c[7], q.s0, q.t1);
      Inc(nverts);
      nvg__vset(@verts[nverts], c[4], c[5], q.s1, q.t1);
      Inc(nverts);
    end;
  end;

  // Esegue il flush della texture (da fare una volta per frame, TODO)
  nvg__flushTextTexture(ctx);

  // Renderizza i triangoli finali
  nvg__renderText(ctx, verts, nverts);

  Result := iter.nextx / scale;
end;

procedure nvgTextBox(ctx: PNVGContext; x, y, breakRowWidth: single; start, stop: pchar);
var
  state: PNVGState;
  rows: array[0..1] of TNVGtextRow;
  nrows, i, oldAlign, halign, valign: int32;
  lineh: single;
begin
  state := nvg__getState(ctx);
  oldAlign := state^.textAlign;
  halign := state^.textAlign and (int32(NVG_ALIGN_LEFT) or int32(NVG_ALIGN_CENTER) or int32(NVG_ALIGN_RIGHT));
  valign := state^.textAlign and (int32(NVG_ALIGN_TOP) or int32(NVG_ALIGN_MIDDLE) or int32(NVG_ALIGN_BOTTOM) or int32(NVG_ALIGN_BASELINE));
  lineh := 0;

  if state^.fontId = FONS_INVALID then
    Exit;

  nvgTextMetrics(ctx, nil, nil, @lineh);

  state^.textAlign := int32(NVG_ALIGN_LEFT) or valign;
  repeat
    if nvgTextBreakLines(ctx, start, stop, breakRowWidth, @rows[0], 2, nrows) then
    begin
      for i := 0 to nrows - 1 do
      begin
        if (halign and int32(NVG_ALIGN_LEFT)) <> 0 then
          nvgText(ctx, x, y, rows[i].start, rows[i].stop)
        else if (halign and int32(NVG_ALIGN_CENTER)) <> 0 then
          nvgText(ctx, x + breakRowWidth * 0.5 - rows[i].Width * 0.5, y, rows[i].start, rows[i].stop)
        else if (halign and int32(NVG_ALIGN_RIGHT)) <> 0 then
          nvgText(ctx, x + breakRowWidth - rows[i].Width, y, rows[i].start, rows[i].stop);
        y := y + lineh * state^.lineHeight;
      end;
      start := rows[nrows - 1].Next;
    end;
  until nrows = 0;

  state^.textAlign := oldAlign;
end;

function nvgTextGlyphPositions(ctx: PNVGContext; x, y: single; start, stop: pchar; positions: PNVGGlyphPosition; maxPositions: int32): int32;
var
  state: PNVGState;
  scale, invscale: single;
  iter, prevIter: TFONSTextIter;
  q: TFONSQuad;
  npos: int32;
begin
  state := nvg__getState(ctx);
  scale := nvg__getFontScale(state) * ctx^.devicePxRatio;
  invscale := 1.0 / scale;
  npos := 0;

  if state^.fontId = FONS_INVALID then
  begin
    Result := 0;
    Exit;
  end;

  if stop = nil then
    stop := start + StrLen(start);

  if start = stop then
  begin
    Result := 0;
    Exit;
  end;

  fonsSetSize(ctx^.fs, state^.fontSize * scale);
  fonsSetSpacing(ctx^.fs, state^.letterSpacing * scale);
  fonsSetBlur(ctx^.fs, state^.fontBlur * scale);
  fonsSetAlign(ctx^.fs, state^.textAlign);
  fonsSetFont(ctx^.fs, state^.fontId);

  if not fonsTextIterInit(ctx^.fs, @iter, x * scale, y * scale, start, stop, FONS_GLYPH_BITMAP_OPTIONAL) then
  begin
    Result := 0;
    Exit;
  end;

  prevIter := iter;
  while fonsTextIterNext(ctx^.fs, @iter, @q) do
  begin
    if (iter.prevGlyphIndex < 0) and nvg__allocTextAtlas(ctx) then
    begin
      iter := prevIter;
      if not fonsTextIterNext(ctx^.fs, @iter, @q) then
        Break;
    end;
    prevIter := iter;
    positions[npos].str := iter.str;
    positions[npos].x := iter.x * invscale;
    positions[npos].minx := nvg__minf(iter.x, q.x0) * invscale;
    positions[npos].maxx := nvg__maxf(iter.nextx, q.x1) * invscale;
    Inc(npos);
    if npos >= maxPositions then
      Break;
  end;

  Result := npos;
end;

function nvgTextBreakLines(ctx: PNVGContext; start, stop: pchar; breakRowWidth: single; rows: PNVGTextRow; maxRows: int32; out nrows: int32): boolean;
var
  state: PNVGState;
  scale, invscale, rowStartX, rowWidth, rowMinX, rowMaxX, nextWidth: single;
  rowStart, rowEnd, wordStart, breakEnd: pchar;
  wordStartX, wordMinX, breakWidth, breakMaxX: single;
  type_, ptype: TNVGCodePointType;
  pcodepoint: cardinal;
  iter, prevIter: TFONSTextIter;
  q: TFONSQuad;
begin
  nrows := 0;
  state := nvg__getState(ctx);
  scale := nvg__getFontScale(state) * ctx^.devicePxRatio;
  invscale := 1.0 / scale;
  rowStartX := 0;
  rowWidth := 0;
  rowMinX := 0;
  rowMaxX := 0;
  rowStart := nil;
  rowEnd := nil;
  wordStart := nil;
  wordStartX := 0;
  wordMinX := 0;
  breakEnd := nil;
  breakWidth := 0;
  breakMaxX := 0;
  type_ := NVG_SPACE;
  ptype := NVG_SPACE;
  pcodepoint := 0;

  if maxRows = 0 then
  begin
    Result := False;
    Exit;
  end;

  if state^.fontId = FONS_INVALID then
  begin
    Result := False;
    Exit;
  end;

  if stop = nil then
    stop := start + StrLen(start);

  if start = stop then
  begin
    Result := False;
    Exit;
  end;

  fonsSetSize(ctx^.fs, state^.fontSize * scale);
  fonsSetSpacing(ctx^.fs, state^.letterSpacing * scale);
  fonsSetBlur(ctx^.fs, state^.fontBlur * scale);
  fonsSetAlign(ctx^.fs, state^.textAlign);
  fonsSetFont(ctx^.fs, state^.fontId);

  breakRowWidth := breakRowWidth * scale;

  if not fonsTextIterInit(ctx^.fs, @iter, 0, 0, start, stop, FONS_GLYPH_BITMAP_OPTIONAL) then
  begin
    Result := False;
    Exit;
  end;

  prevIter := iter;
  while fonsTextIterNext(ctx^.fs, @iter, @q) do
  begin
    if (iter.prevGlyphIndex < 0) and nvg__allocTextAtlas(ctx) then
    begin
      iter := prevIter;
      if not fonsTextIterNext(ctx^.fs, @iter, @q) then
        Break;
    end;
    prevIter := iter;

    case iter.codepoint of
      9, 11, 12, 32, $00A0:
        type_ := NVG_SPACE;
      10:
        type_ := IfThen(pcodepoint = 13, NVG_SPACE, NVG_NEWLINE);
      13:
        type_ := IfThen(pcodepoint = 10, NVG_SPACE, NVG_NEWLINE);
      $0085:
        type_ := NVG_NEWLINE;
      else
      begin
        if ((iter.codepoint >= $4E00) and (iter.codepoint <= $9FFF)) or ((iter.codepoint >= $3000) and (iter.codepoint <= $30FF)) or ((iter.codepoint >= $FF00) and (iter.codepoint <= $FFEF)) or ((iter.codepoint >= $1100) and (iter.codepoint <= $11FF)) or ((iter.codepoint >= $3130) and (iter.codepoint <= $318F)) or ((iter.codepoint >= $AC00) and (iter.codepoint <= $D7AF)) then
          type_ := NVG_CJK_CHAR
        else
          type_ := NVG_CHAR;
      end;
    end;

    if type_ = NVG_NEWLINE then
    begin
      rows[nrows].start := IfThen(rowStart <> nil, rowStart, iter.str);
      rows[nrows].stop := IfThen(rowEnd <> nil, rowEnd, iter.str);
      rows[nrows].Width := rowWidth * invscale;
      rows[nrows].minx := rowMinX * invscale;
      rows[nrows].maxx := rowMaxX * invscale;
      rows[nrows].Next := iter.Next;
      Inc(nrows);
      if nrows >= maxRows then
      begin
        Result := True;
        Exit;
      end;
      breakEnd := rowStart;
      breakWidth := 0;
      breakMaxX := 0;
      rowStart := nil;
      rowEnd := nil;
      rowWidth := 0;
      rowMinX := 0;
      rowMaxX := 0;
    end
    else
    begin
      if rowStart = nil then
      begin
        if (type_ = NVG_CHAR) or (type_ = NVG_CJK_CHAR) then
        begin
          rowStartX := iter.x;
          rowStart := iter.str;
          rowEnd := iter.Next;
          rowWidth := iter.nextx - rowStartX;
          rowMinX := q.x0 - rowStartX;
          rowMaxX := q.x1 - rowStartX;
          wordStart := iter.str;
          wordStartX := iter.x;
          wordMinX := q.x0 - rowStartX;
          breakEnd := rowStart;
          breakWidth := 0;
          breakMaxX := 0;
        end;
      end
      else
      begin
        nextWidth := iter.nextx - rowStartX;
        if (type_ = NVG_CHAR) or (type_ = NVG_CJK_CHAR) then
        begin
          rowEnd := iter.Next;
          rowWidth := iter.nextx - rowStartX;
          rowMaxX := q.x1 - rowStartX;
        end;
        if (((ptype = NVG_CHAR) or (ptype = NVG_CJK_CHAR)) and (type_ = NVG_SPACE)) or (type_ = NVG_CJK_CHAR) then
        begin
          breakEnd := iter.str;
          breakWidth := rowWidth;
          breakMaxX := rowMaxX;
        end;
        if ((ptype = NVG_SPACE) and ((type_ = NVG_CHAR) or (type_ = NVG_CJK_CHAR))) or (type_ = NVG_CJK_CHAR) then
        begin
          wordStart := iter.str;
          wordStartX := iter.x;
          wordMinX := q.x0;
        end;
        if ((type_ = NVG_CHAR) or (type_ = NVG_CJK_CHAR)) and (nextWidth > breakRowWidth) then
        begin
          if breakEnd = rowStart then
          begin
            rows[nrows].start := rowStart;
            rows[nrows].stop := iter.str;
            rows[nrows].Width := rowWidth * invscale;
            rows[nrows].minx := rowMinX * invscale;
            rows[nrows].maxx := rowMaxX * invscale;
            rows[nrows].Next := iter.str;
            Inc(nrows);
            if nrows >= maxRows then
            begin
              Result := True;
              Exit;
            end;
            rowStartX := iter.x;
            rowStart := iter.str;
            rowEnd := iter.Next;
            rowWidth := iter.nextx - rowStartX;
            rowMinX := q.x0 - rowStartX;
            rowMaxX := q.x1 - rowStartX;
            wordStart := iter.str;
            wordStartX := iter.x;
            wordMinX := q.x0 - rowStartX;
          end
          else
          begin
            rows[nrows].start := rowStart;
            rows[nrows].stop := breakEnd;
            rows[nrows].Width := breakWidth * invscale;
            rows[nrows].minx := rowMinX * invscale;
            rows[nrows].maxx := breakMaxX * invscale;
            rows[nrows].Next := wordStart;
            Inc(nrows);
            if nrows >= maxRows then
            begin
              Result := True;
              Exit;
            end;
            rowStartX := wordStartX;
            rowStart := wordStart;
            rowEnd := iter.Next;
            rowWidth := iter.nextx - rowStartX;
            rowMinX := wordMinX - rowStartX;
            rowMaxX := q.x1 - rowStartX;
          end;
          breakEnd := rowStart;
          breakWidth := 0;
          breakMaxX := 0;
        end;
      end;
    end;

    pcodepoint := iter.codepoint;
    ptype := type_;
  end;

  if rowStart <> nil then
  begin
    rows[nrows].start := rowStart;
    rows[nrows].stop := rowEnd;
    rows[nrows].Width := rowWidth * invscale;
    rows[nrows].minx := rowMinX * invscale;
    rows[nrows].maxx := rowMaxX * invscale;
    rows[nrows].Next := stop;
    Inc(nrows);
  end;

  Result := nrows > 0;
end;

function nvgTextBounds(ctx: PNVGContext; x, y: single; start, stop: pchar; bounds: PSingle): single;
var
  state: PNVGState;
  scale, invscale, Width: single;
begin
  state := nvg__getState(ctx);
  scale := nvg__getFontScale(state) * ctx^.devicePxRatio;
  invscale := 1.0 / scale;

  if state^.fontId = FONS_INVALID then
  begin
    Result := 0;
    Exit;
  end;

  fonsSetSize(ctx^.fs, state^.fontSize * scale);
  fonsSetSpacing(ctx^.fs, state^.letterSpacing * scale);
  fonsSetBlur(ctx^.fs, state^.fontBlur * scale);
  fonsSetAlign(ctx^.fs, state^.textAlign);
  fonsSetFont(ctx^.fs, state^.fontId);

  Width := fonsTextBounds(ctx^.fs, x * scale, y * scale, start, stop, bounds);
  if bounds <> nil then
  begin
    fonsLineBounds(ctx^.fs, y * scale, @bounds[1], @bounds[3]);
    bounds[0] := bounds[0] * invscale;
    bounds[1] := bounds[1] * invscale;
    bounds[2] := bounds[2] * invscale;
    bounds[3] := bounds[3] * invscale;
  end;
  Result := Width * invscale;
end;

procedure nvgTextBoxBounds(ctx: PNVGContext; x, y, breakRowWidth: single; start, stop: pchar; bounds: PSingle);
var
  state: PNVGState;
  rows: array[0..1] of TNVGtextRow;
  scale, invscale, lineh, rminy, rmaxy, minx, miny, maxx, maxy, rminx, rmaxx, dx: single;
  oldAlign, halign, valign, nrows, i: int32;
begin
  state := nvg__getState(ctx);
  scale := nvg__getFontScale(state) * ctx^.devicePxRatio;
  invscale := 1.0 / scale;
  oldAlign := state^.textAlign;
  halign := state^.textAlign and (int32(NVG_ALIGN_LEFT) or int32(NVG_ALIGN_CENTER) or int32(NVG_ALIGN_RIGHT));
  valign := state^.textAlign and (int32(NVG_ALIGN_TOP) or int32(NVG_ALIGN_MIDDLE) or int32(NVG_ALIGN_BOTTOM) or int32(NVG_ALIGN_BASELINE));
  lineh := 0;
  rminy := 0;
  rmaxy := 0;
  minx := x;
  miny := y;
  maxx := x;
  maxy := y;

  if state^.fontId = FONS_INVALID then
  begin
    if bounds <> nil then
    begin
      bounds[0] := 0;
      bounds[1] := 0;
      bounds[2] := 0;
      bounds[3] := 0;
    end;
    Exit;
  end;

  nvgTextMetrics(ctx, nil, nil, @lineh);

  state^.textAlign := int32(NVG_ALIGN_LEFT) or valign;

  fonsSetSize(ctx^.fs, state^.fontSize * scale);
  fonsSetSpacing(ctx^.fs, state^.letterSpacing * scale);
  fonsSetBlur(ctx^.fs, state^.fontBlur * scale);
  fonsSetAlign(ctx^.fs, state^.textAlign);
  fonsSetFont(ctx^.fs, state^.fontId);
  fonsLineBounds(ctx^.fs, 0, @rminy, @rmaxy);
  rminy := rminy * invscale;
  rmaxy := rmaxy * invscale;

  while nvgTextBreakLines(ctx, start, stop, breakRowWidth, @rows[0], 2, nrows) do
  begin
    for i := 0 to nrows - 1 do
    begin
      dx := 0;
      if halign and int32(NVG_ALIGN_LEFT) <> 0 then
        dx := 0
      else if halign and int32(NVG_ALIGN_CENTER) <> 0 then
        dx := breakRowWidth * 0.5 - rows[i].Width * 0.5
      else if halign and int32(NVG_ALIGN_RIGHT) <> 0 then
        dx := breakRowWidth - rows[i].Width;
      rminx := x + rows[i].minx + dx;
      rmaxx := x + rows[i].maxx + dx;
      minx := nvg__minf(minx, rminx);
      maxx := nvg__maxf(maxx, rmaxx);
      miny := nvg__minf(miny, y + rminy);
      maxy := nvg__maxf(maxy, y + rmaxy);
      y := y + lineh * state^.lineHeight;
    end;
    start := rows[nrows - 1].Next;
  end;

  state^.textAlign := oldAlign;

  if bounds <> nil then
  begin
    bounds[0] := minx;
    bounds[1] := miny;
    bounds[2] := maxx;
    bounds[3] := maxy;
  end;
end;

procedure nvgTextMetrics(ctx: PNVGContext; ascender, descender, lineh: PSingle);
var
  state: PNVGState;
  scale, invscale: single;
begin
  state := nvg__getState(ctx);
  scale := nvg__getFontScale(state) * ctx^.devicePxRatio;
  invscale := 1.0 / scale;

  if state^.fontId = FONS_INVALID then
    Exit;

  fonsSetSize(ctx^.fs, state^.fontSize * scale);
  fonsSetSpacing(ctx^.fs, state^.letterSpacing * scale);
  fonsSetBlur(ctx^.fs, state^.fontBlur * scale);
  fonsSetAlign(ctx^.fs, state^.textAlign);
  fonsSetFont(ctx^.fs, state^.fontId);

  fonsVertMetrics(ctx^.fs, ascender, descender, lineh);
  if ascender <> nil then
    ascender^ := ascender^ * invscale;
  if descender <> nil then
    descender^ := descender^ * invscale;
  if lineh <> nil then
    lineh^ := lineh^ * invscale;
end;

end.
