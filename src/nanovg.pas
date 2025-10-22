unit nanovg;

{$mode objfpc}{$H+}
{
Traduzione del codice https://github.com/memononen/nanovg
}

interface

uses
  Classes, SysUtils, fontStash, paxutils;

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
  PNVGVertex = ^TNVGVertex;

  TNVGVertex = record
    x, y, u, v: single;
  end;

  TNVGPath = record
    First: int32;
    Count: int32;
    closed: int8;
    nbevel: int32;
    fill: PNVGVertex;
    nfill: int32;
    stroke: PNVGVertex;
    nstroke: int32;
    winding: int32;
    convex: int32;
  end;


  TNVGParams = record
    userPtr: Pointer;
    edgeAntiAlias: longint;
    renderCreate: function(uptr: Pointer): longint;
    renderCreateTexture: function(uptr: Pointer; type_, w, h, imageFlags: longint; Data: pchar): longint;
    renderDeleteTexture: function(uptr: Pointer; image: longint): longint;
    renderUpdateTexture: function(uptr: Pointer; image, x, y, w, h: longint; Data: pchar): longint;
    renderGetTextureSize: function(uptr: Pointer; image: longint; w, h: PLongInt): longint;
    renderViewport: procedure(uptr: Pointer; Width, Height, devicePixelRatio: single);
    renderCancel: procedure(uptr: Pointer);
    renderFlush: procedure(uptr: Pointer);
    renderFill: procedure(uptr: Pointer; paint: PNVGpaint; compositeOperation: TNVGCompositeOperationState; scissor: PNVGscissor; fringe: single; bounds: PSingle; paths: PNVGpath; npaths: longint);
    renderStroke: procedure(uptr: Pointer; paint: PNVGpaint; compositeOperation: TNVGCompositeOperationState; scissor: PNVGscissor; fringe, strokeWidth: single; paths: PNVGpath; npaths: longint);
    renderTriangles: procedure(uptr: Pointer; paint: PNVGpaint; compositeOperation: TNVGCompositeOperationState; scissor: PNVGscissor; verts: PNVGvertex; nverts: longint; fringe: single);
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
    textAlign: TNVGAligns;
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
procedure nvgGlobalCompositeOperation(ctx: PNVGContext; op: int32);

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
procedure nvgStrokeWidth(ctx: PNVGContext; size: single);

// Sets how the end of the line (cap) is drawn,
// Can be one of: NVG_BUTT (default), NVG_ROUND, NVG_SQUARE.
procedure nvgLineCap(ctx: PNVGContext; cap: int32);

// Sets how sharp path corners are drawn.
// Can be one of NVG_MITER (default), NVG_ROUND, NVG_BEVEL.
procedure nvgLineJoin(ctx: PNVGContext; join: int32);

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
function nvgCreateImageRGBA(ctx: PNVGContext; w, h: int32; imageFlags: int32; const Data: pbyte): int32;

// Updates image data specified by image handle.
procedure nvgUpdateImage(ctx: PNVGContext; image: int32; const Data: pbyte);

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
procedure nvgArc(ctx: PNVGContext; cx, cy, r, a0, a1: single; dir: int32);

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
function nvgCreateFontAtIndex(ctx: PNVGContext; const Name, filename: pchar; const fontIndex: int32): int32;

// Creates font by loading it from the specified memory chunk.
// Returns handle to the font.
function nvgCreateFontMem(ctx: PNVGContext; const Name: pchar; Data: pbyte; ndata, freeData: int32): int32;

// fontIndex specifies which font face to load from a .ttf/.ttc file.
function nvgCreateFontMemAtIndex(ctx: PNVGContext; const Name: pbyte; Data: pbyte; ndata, freeData: int32; const fontIndex: int32): int32;

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
procedure nvgTextAlign(ctx: PNVGContext; align: int32);

// Sets the font face based on specified id of current text style.
procedure nvgFontFaceId(ctx: PNVGContext; font: int32);

// Sets the font face based on specified name of current text style.
procedure nvgFontFace(ctx: PNVGContext; const font: pchar);

// Draws text string at specified location. If end is specified only the sub-string up to the end is drawn.
function nvgText(ctx: PNVGContext; x, y: single; const start, stop: pchar): single;

// Draws multi-line text string at specified location wrapped at the specified width. If end is specified only the sub-string up to the end is drawn.
// White space is stripped at the beginning of the rows, the text is split at word boundaries or when new-line characters are encountered.
// Words longer than the max width are slit at nearest character (i.e. no hyphenation).
procedure nvgTextBox(ctx: PNVGContext; x, y, breakRowWidth: single; const start, stop: pchar);

// Measures the specified text string. Parameter bounds should be a pointer to single[4],
// if the bounding box of the text should be returned. The bounds value are [xmin,ymin, xmax,ymax]
// Returns the horizontal advance of the measured text (i.e. where the next character should drawn).
// Measured values are returned in local coordinate space.
function nvgTextBounds(ctx: PNVGContext; x, y: single; const start, stop: pchar; bounds: PSingle): single;

// Measures the specified multi-text string. Parameter bounds should be a pointer to single[4],
// if the bounding box of the text should be returned. The bounds value are [xmin,ymin, xmax,ymax]
// Measured values are returned in local coordinate space.
procedure nvgTextBoxBounds(ctx: PNVGContext; x, y, breakRowWidth: single; const start, stop: pchar; bounds: PSingle);

// Calculates the glyph x positions of the specified text. If end is specified only the sub-string will be used.
// Measured values are returned in local coordinate space.
function nvgTextGlyphPositions(ctx: PNVGContext; x, y: single; const start, stop: pchar; positions: PNVGGlyphPosition; maxPositions: int32): int32;

// Returns the vertical metrics based on the current text style.
// Measured values are returned in local coordinate space.
procedure nvgTextMetrics(ctx: PNVGContext; ascender, descender, lineh: PSingle);

// Breaks the specified text into lines. If end is specified only the sub-string will be used.
// White space is stripped at the beginning of the rows, the text is split at word boundaries or when new-line characters are encountered.
// Words longer than the max width are slit at nearest character (i.e. no hyphenation).
function nvgTextBreakLines(ctx: PNVGContext; const start, stop: pchar; breakRowWidth: single; rows: PNVGTextRow; maxRows: int32): int32;

// Constructor and destructor, called by the render back-end.
function nvgCreateInternal(params: PNVGParams): PNVGContext;
procedure nvgDeleteInternal(ctx: PNVGContext);

function nvgInternalParams(ctx: PNVGContext): PNVGparams;

// Debug function to dump cached path data.
procedure nvgDebugDumpPathCache(ctx: PNVGContext);

implementation

uses
  Math, stb_image;

function nvg__sqrtf(a: single): single; inline;
(*
static single nvg__sqrtf(single a) { return sqrtf(a); }
*)
begin
  Result := Sqrt(a);
end;

function nvg__modf(a, b: single): single; inline;
(*
static single nvg__modf(single a, single b) { return fmodf(a, b); }
*)
begin
  Result := Math.fmod(a, b);
end;

function nvg__sinf(a: single): single; inline;
(*
static single nvg__sinf(single a) { return sinf(a); }
*)
begin
  Result := sin(a);
end;

function nvg__cosf(a: single): single; inline;
(*
static single nvg__cosf(single a) { return cosf(a); }
*)
begin
  Result := cos(a);
end;

function nvg__tanf(a: single): single; inline;
(*
static single nvg__tanf(single a) { return tanf(a); }
*)
begin
  Result := Math.tan(a);
end;

function nvg__atan2f(a, b: single): single; inline;
(*
static single nvg__atan2f(single a,single b) { return atan2f(a, b); }
*)
begin
  Result := ArcTan2(a, b);
end;

function nvg__acosf(a: single): single;
(*
static single nvg__acosf(single a) { return acosf(a); }
*)
begin
  Result := ArcCos(a);
end;

function nvg__mini(a, b: int32): int32; inline;
(*
static int32 nvg__mini(int32 a, int32 b) { return a < b ? a : b; }
*)
begin
  Result := min(a, b);
end;

function nvg__maxi(a, b: int32): int32; inline;
(*
static int32 nvg__maxi(int32 a, int32 b) { return a > b ? a : b; }
*)
begin
  Result := Max(a, b);
end;

function nvg__clampi(a, mn, mx: int32): int32; inline;
(*
static int32 nvg__clampi(int32 a, int32 mn, int32 mx) { return a < mn ? mn : (a > mx ? mx : a); }
*)
begin
  Result := Math.ifThen(a < mn, mn, Math.ifThen(a > mx, mx, a));
end;

function nvg__minf(a, b: single): single; inline;
(*
static single nvg__minf(single a, single b) { return a < b ? a : b; }
*)
begin
  Result := Math.IfThen(a < b, a, b);
end;

function nvg__maxf(a, b: single): single; inline;
(*
static single nvg__maxf(single a, single b) { return a > b ? a : b; }
*)
begin
  Result := IfThen(a > b, a, b);
end;

function nvg__absf(a: single): single;
(*
static single nvg__absf(single a) { return a >= 0.0f ? a : -a; }
*)
begin
  Result := IfThen(a >= 0.0, a, -a);
end;

(*
static single nvg__signf(single a) { return a >= 0.0f ? 1.0f : -1.0f; }
*)
function nvg__clampf(a, mn, mx: single): single;
(*
static single nvg__clampf(single a, single mn, single mx) { return a < mn ? mn : (a > mx ? mx : a); }
*)
begin
  Result := IfThen(a < mn, mn, IfThen(a > mx, mx, a));
end;

function nvg__cross(dx0, dy0, dx1, dy1: single): single;
(*
static single nvg__cross(single dx0, single dy0, single dx1, single dy1) { return dx1*dy0 - dx0*dy1; }
*)
begin
  Result := dx1 * dy0 - dx0 * dy1;
end;

function nvg__normalize(var x, y: single): single;
(*
static single nvg__normalize(single *x, single* y)
{
  single d = nvg__sqrtf(( *x)*( *x) + ( *y)*( *y));
  if (d > 1e-6f) {
    single id = 1.0f / d;
    *x *= id;
    *y *= id;
  }
  return d;
}
*)
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

procedure nvg__deletePathCache(c: PNVGPathCache);
(*
static void nvg__deletePathCache(NVGpathCache* c)
{
  if (c == NULL) return;
  if (c->points != NULL) free(c->points);
  if (c->paths != NULL) free(c->paths);
  if (c->verts != NULL) free(c->verts);
  free(c);
}
*)
begin
  if (c = nil) then exit;
  if (c^.points <> nil) then Freemem(c^.points);
  if (c^.paths <> nil) then Freemem(c^.paths);
  if (c^.verts <> nil) then Freemem(c^.verts);
  Freemem(c);
end;

function nvg__allocPathCache(): PNVGPathCache;
(*
static NVGpathCache* nvg__allocPathCache(void)
{
  NVGpathCache* c = (NVGpathCache* )malloc(sizeof(NVGpathCache));
  if (c == NULL) goto error;
  memset(c, 0, sizeof(NVGpathCache));

  c->points = (NVGpoint* )malloc(sizeof(NVGpoint)*NVG_INIT_POINTS_SIZE);
  if (!c->points) goto error;
  c->npoints = 0;
  c->cpoints = NVG_INIT_POINTS_SIZE;

  c->paths = (NVGpath* )malloc(sizeof(NVGpath)*NVG_INIT_PATHS_SIZE);
  if (!c->paths) goto error;
  c->npaths = 0;
  c->cpaths = NVG_INIT_PATHS_SIZE;

  c->verts = (NVGvertex* )malloc(sizeof(NVGvertex)*NVG_INIT_VERTS_SIZE);
  if (!c->verts) goto error;
  c->nverts = 0;
  c->cverts = NVG_INIT_VERTS_SIZE;

  return c;
error:
  nvg__deletePathCache(c);
  return NULL;
}
*)
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

procedure nvg__setDevicePixelRatio(ctx: PNVGContext; ratio: single);
(*
static void nvg__setDevicePixelRatio(ctx: PNVGContext; single ratio)
{
  ctx->tessTol = 0.25f / ratio;
  ctx->distTol = 0.01f / ratio;
  ctx->fringeWidth = 1.0f / ratio;
  ctx->devicePxRatio = ratio;
}
*)
begin
  ctx^.tessTol := 0.25 / ratio;
  ctx^.distTol := 0.01 / ratio;
  ctx^.fringeWidth := 1.0 / ratio;
  ctx^.devicePxRatio := ratio;
end;

function nvg__compositeOperationState(op: TNVGCompositeOperation): TNVGCompositeOperationState;
(*
static NVGcompositeOperationState nvg__compositeOperationState(int32 op)
{
  int32 sfactor, dfactor;

  if (op == NVG_SOURCE_OVER)
  {
    sfactor = NVG_ONE;
    dfactor = NVG_ONE_MINUS_SRC_ALPHA;
  }
  else if (op == NVG_SOURCE_IN)
  {
    sfactor = NVG_DST_ALPHA;
    dfactor = NVG_ZERO;
  }
  else if (op == NVG_SOURCE_OUT)
  {
    sfactor = NVG_ONE_MINUS_DST_ALPHA;
    dfactor = NVG_ZERO;
  }
  else if (op == NVG_ATOP)
  {
    sfactor = NVG_DST_ALPHA;
    dfactor = NVG_ONE_MINUS_SRC_ALPHA;
  }
  else if (op == NVG_DESTINATION_OVER)
  {
    sfactor = NVG_ONE_MINUS_DST_ALPHA;
    dfactor = NVG_ONE;
  }
  else if (op == NVG_DESTINATION_IN)
  {
    sfactor = NVG_ZERO;
    dfactor = NVG_SRC_ALPHA;
  }
  else if (op == NVG_DESTINATION_OUT)
  {
    sfactor = NVG_ZERO;
    dfactor = NVG_ONE_MINUS_SRC_ALPHA;
  }
  else if (op == NVG_DESTINATION_ATOP)
  {
    sfactor = NVG_ONE_MINUS_DST_ALPHA;
    dfactor = NVG_SRC_ALPHA;
  }
  else if (op == NVG_LIGHTER)
  {
    sfactor = NVG_ONE;
    dfactor = NVG_ONE;
  }
  else if (op == NVG_COPY)
  {
    sfactor = NVG_ONE;
    dfactor = NVG_ZERO;
  }
  else if (op == NVG_XOR)
  {
    sfactor = NVG_ONE_MINUS_DST_ALPHA;
    dfactor = NVG_ONE_MINUS_SRC_ALPHA;
  }
  else
  {
    sfactor = NVG_ONE;
    dfactor = NVG_ZERO;
  }

  NVGcompositeOperationState state;
  state.srcRGB = sfactor;
  state.dstRGB = dfactor;
  state.srcAlpha = sfactor;
  state.dstAlpha = dfactor;
  return state;
}
*)
var
  sfactor, dfactor: int32;
begin
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
    end
    else
    begin
      sfactor := Ord(NVG_ONE);
      dfactor := Ord(NVG_ZERO);
    end;
  end;

  Result.srcRGB := sfactor;
  Result.dstRGB := dfactor;
  Result.srcAlpha := sfactor;
  Result.dstAlpha := dfactor;
end;

function nvg__getState(ctx: PNVGContext): PNVGState;
(*
static NVGstate* nvg__getState(ctx: PNVGContext)
{
  return &ctx->states[ctx->nstates-1];
}
*)
begin
  Result := @(ctx^.states[ctx^.nstates - 1]);
end;

function nvgCreateInternal(params: PNVGParams): PNVGContext;
(*
NVGcontext* nvgCreateInternal(NVGparams* params)
{
  FONSparams fontParams;
  ctx: PNVGContext = (NVGcontext* )malloc(sizeof(NVGcontext));
  int32 i;
  if (ctx == NULL) goto error;
  memset(ctx, 0, sizeof(NVGcontext));

  ctx->params = *params;
  for (i = 0; i < NVG_MAX_FONTIMAGES; i++)
    ctx->fontImages[i] = 0;

  ctx->commands = (single* )malloc(sizeof(single)*NVG_INIT_COMMANDS_SIZE);
  if (!ctx->commands) goto error;
  ctx->ncommands = 0;
  ctx->ccommands = NVG_INIT_COMMANDS_SIZE;

  ctx->cache = nvg__allocPathCache();
  if (ctx->cache == NULL) goto error;

  nvgSave(ctx);
  nvgReset(ctx);

  nvg__setDevicePixelRatio(ctx, 1.0f);

  if (ctx->params.renderCreate(ctx->params.userPtr) == 0) goto error;

  // Init font rendering
  memset(&fontParams, 0, sizeof(fontParams));
  fontParams.width = NVG_INIT_FONTIMAGE_SIZE;
  fontParams.height = NVG_INIT_FONTIMAGE_SIZE;
  fontParams.flags = FONS_ZERO_TOPLEFT;
  fontParams.renderCreate = NULL;
  fontParams.renderUpdate = NULL;
  fontParams.renderDraw = NULL;
  fontParams.renderDelete = NULL;
  fontParams.userPtr = NULL;
  ctx->fs = fonsCreateInternal(&fontParams);
  if (ctx->fs == NULL) goto error;

  // Create font texture
  ctx->fontImages[0] = ctx->params.renderCreateTexture(ctx->params.userPtr, NVG_TEXTURE_ALPHA, fontParams.width, fontParams.height, 0, NULL);
  if (ctx->fontImages[0] == 0) goto error;
  ctx->fontImageIdx = 0;

  return ctx;

error:
  nvgDeleteInternal(ctx);
  return 0;
}
*)
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
    FillByte(fontParams, sizeof(fontParams), 0);
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
    Result^.fontImages[0] := Result^.params^.renderCreateTexture(Result^.params^.userPtr, Ord(NVG_TEXTURE_ALPHA), fontParams.Width, fontParams.Height, 0, nil);
    if (Result^.fontImages[0] = 0) then raise ENullPointerException.Create;
    Result^.fontImageIdx := 0;
  except
    nvgDeleteInternal(Result);
    Result := nil;
  end;
end;

function nvgInternalParams(ctx: PNVGContext): PNVGParams;
(*
NVGparams* nvgInternalParams(ctx: PNVGContext){    return &ctx->params;}
*)
begin
  Result := ctx^.params;
end;

procedure nvgDeleteInternal(ctx: PNVGContext);
(*
void nvgDeleteInternal(ctx: PNVGContext)
{
  int32 i;
  if (ctx == NULL) return;
  if (ctx->commands != NULL) free(ctx->commands);
  if (ctx->cache != NULL) nvg__deletePathCache(ctx->cache);

  if (ctx->fs)
    fonsDeleteInternal(ctx->fs);

  for (i = 0; i < NVG_MAX_FONTIMAGES; i++) {
    if (ctx->fontImages[i] != 0) {
      nvgDeleteImage(ctx, ctx->fontImages[i]);
      ctx->fontImages[i] = 0;
    }
  }

  if (ctx->params.renderDelete != NULL)
    ctx->params.renderDelete(ctx->params.userPtr);

  free(ctx);
}
*)
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
(*
void nvgBeginFrame(ctx: PNVGContext; single windowWidth, single windowHeight, single devicePixelRatio)
{
/*  printf("Tris: draws:%d  fill:%d  stroke:%d  text:%d  TOT:%d\n",
    ctx->drawCallCount, ctx->fillTriCount, ctx->strokeTriCount, ctx->textTriCount,
    ctx->fillTriCount+ctx->strokeTriCount+ctx->textTriCount);*/

  ctx->nstates = 0;
  nvgSave(ctx);
  nvgReset(ctx);

  nvg__setDevicePixelRatio(ctx, devicePixelRatio);

  ctx->params.renderViewport(ctx->params.userPtr, windowWidth, windowHeight, devicePixelRatio);

  ctx->drawCallCount = 0;
  ctx->fillTriCount = 0;
  ctx->strokeTriCount = 0;
  ctx->textTriCount = 0;
}
*)
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
(*
procedure nvgCancelFrame(ctx: PNVGContext)
{
  ctx->params.renderCancel(ctx->params.userPtr);
}
*)
begin
  ctx^.params^.renderCancel(ctx^.params^.userPtr);
end;

procedure nvgEndFrame(ctx: PNVGContext);
(*
procedure nvgEndFrame(ctx: PNVGContext)
{
  ctx->params.renderFlush(ctx->params.userPtr);
  if (ctx->fontImageIdx != 0) {
    int32 fontImage = ctx->fontImages[ctx->fontImageIdx];
    ctx->fontImages[ctx->fontImageIdx] = 0;
    int32 i, j, iw, ih;
    // delete images that smaller than current one
    if (fontImage == 0)
      return;
    nvgImageSize(ctx, fontImage, &iw, &ih);
    for (i = j = 0; i < ctx->fontImageIdx; i++) {
      if (ctx->fontImages[i] != 0) {
        int32 nw, nh;
        image: int32  = ctx->fontImages[i];
        ctx->fontImages[i] = 0;
        nvgImageSize(ctx, image, &nw, &nh);
        if (nw < iw || nh < ih)
          nvgDeleteImage(ctx, image);
        else
          ctx->fontImages[j++] = image;
      }
    }
    // make current font image to first
    ctx->fontImages[j] = ctx->fontImages[0];
    ctx->fontImages[0] = fontImage;
    ctx->fontImageIdx = 0;
  }
}
*)
var
  fontImage: int32;
  i, j, iw, ih: int32;
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
(*
NVGcolor nvgRGB(int8 r, int8 g, int8 b)
{
  return nvgRGBA(r,g,b,255);
}
*)
begin
  Result := nvgRGBA(r, g, b, $FF);
end;

function nvgRGB(r, g, b: single): TNVGColor;
  (* NVGcolor nvgRGBf(single r, single g, single b) { return nvgRGBAf(r,g,b,1.0f); } *)
begin
  Result := nvgRGBA(r, g, b, 1.0);
end;

function nvgRGBA(r, g, b, a: uint8): TNVGColor;
(*
NVGcolor nvgRGBA(int8 r, int8 g, int8 b, int8 a)
{
  color:TNVGColor ;
  // Use longer initialization to suppress warning.
  color.r = r / 255.0f;
  color.g = g / 255.0f;
  color.b = b / 255.0f;
  color.a = a / 255.0f;
  return color;
}
*)
begin
  Result.r := r / 255.0;
  Result.g := g / 255.0;
  Result.b := b / 255.0;
  Result.a := a / 255.0;
end;

function nvgRGBA(r, g, b, a: single): TNVGColor;
(*
NVGcolor nvgRGBAf(single r, single g, single b, single a)
{
  color:TNVGColor ;
  // Use longer initialization to suppress warning.
  color.r = r;
  color.g = g;
  color.b = b;
  color.a = a;
  return color;
}
*)
begin
  Result.r := r;
  Result.g := g;
  Result.b := b;
  Result.a := a;
end;

function nvgTransRGBA(c: TNVGColor; a: uint8): TNVGColor;
(*
NVGcolor nvgTransRGBA(NVGcolor c, int8 a)
{
  c.a = a / 255.0f;
  return c;
}
*)
begin
  Result := c;
  Result.a := a / 255.0;
end;

function nvgTransRGBA(c: TNVGColor; a: single): TNVGcolor;
  (* NVGcolor nvgTransRGBAf(NVGcolor c, single a) { c.a = a; return c; } *)
begin
  Result := c;
  Result.a := a;
end;

function nvgLerpRGBA(c0, c1: TNVGColor; u: single): TNVGColor;
(*
NVGcolor nvgLerpRGBA(NVGcolor c0, NVGcolor c1, single u)
{
  int32 i;
  single oneminu;
  NVGcolor cint = {{{0}}};

  u = nvg__clampf(u, 0.0f, 1.0f);
  oneminu = 1.0f - u;
  for( i = 0; i <4; i++ )
  {
    cint.rgba[i] = c0.rgba[i] * oneminu + c1.rgba[i] * u;
  }

  return cint;
}
*)
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

(*
NVGcolor nvgHSL(single h, single s, single l)
{
  return nvgHSLA(h,s,l,255);
}
*)
begin
  Result := nvgHSLA(h, s, l, 255);
end;

function nvg__hue(h, m1, m2: single): single;
(*
static single nvg__hue(single h, single m1, single m2)
{
  if (h < 0) h += 1;
  if (h > 1) h -= 1;
  if (h < 1.0f/6.0f)
    return m1 + (m2 - m1) * h * 6.0f;
  else if (h < 3.0f/6.0f)
    return m2;
  else if (h < 4.0f/6.0f)
    return m1 + (m2 - m1) * (2.0f/3.0f - h) * 6.0f;
  return m1;
}
*)
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
(*
NVGcolor nvgHSLA(single h, single s, single l, int8 a)
{
  single m1, m2;
  NVGcolor col;
  h = nvg__modf(h, 1.0f);
  if (h < 0.0f) h += 1.0f;
  s = nvg__clampf(s, 0.0f, 1.0f);
  l = nvg__clampf(l, 0.0f, 1.0f);
  m2 = l <= 0.5f ? (l * (1 + s)) : (l + s - l * s);
  m1 = 2 * l - m2;
  col.r = nvg__clampf(nvg__hue(h + 1.0f/3.0f, m1, m2), 0.0f, 1.0f);
  col.g = nvg__clampf(nvg__hue(h, m1, m2), 0.0f, 1.0f);
  col.b = nvg__clampf(nvg__hue(h - 1.0f/3.0f, m1, m2), 0.0f, 1.0f);
  col.a = a/255.0f;
  return col;
}
*)
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
(*
void nvgTransformIdentity(single* t)
{
  t[0] = 1.0f; t[1] = 0.0f;
  t[2] = 0.0f; t[3] = 1.0f;
  t[4] = 0.0f; t[5] = 0.0f;
}

*)
begin
  dst[0] := 1.0;
  dst[1] := 0.0;
  dst[2] := 0.0;
  dst[3] := 1.0;
  dst[4] := 0.0;
  dst[5] := 0.0;
end;

procedure nvgTransformTranslate(dst: PSingle; tx, ty: single);
(*
void nvgTransformTranslate(single* t, single tx, single ty)
{
  t[0] = 1.0f; t[1] = 0.0f;
  t[2] = 0.0f; t[3] = 1.0f;
  t[4] = tx; t[5] = ty;
}
*)
begin
  dst[0] := 1.0;
  dst[1] := 0.0;
  dst[2] := 0.0;
  dst[3] := 1.0;
  dst[4] := tx;
  dst[5] := ty;
end;


procedure nvgTransformScale(dst: PSingle; sx, sy: single);
(*
void nvgTransformScale(single* t, single sx, single sy)
{
  t[0] = sx; t[1] = 0.0f;
  t[2] = 0.0f; t[3] = sy;
  t[4] = 0.0f; t[5] = 0.0f;
}

*)
begin
  dst[0] := sx;
  dst[1] := 0.0;
  dst[2] := 0.0;
  dst[3] := sy;
  dst[4] := 0.0;
  dst[5] := 0.0;
end;

procedure nvgTransformRotate(dst: PSingle; a: single);
(*
void nvgTransformRotate(single* t, single a)
{
  single cs = nvg__cosf(a), sn = nvg__sinf(a);
  t[0] = cs; t[1] = sn;
  t[2] = -sn; t[3] = cs;
  t[4] = 0.0f; t[5] = 0.0f;
}
*)
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
(*
void nvgTransformSkewX(single* t, single a)
{
  t[0] = 1.0f; t[1] = 0.0f;
  t[2] = nvg__tanf(a); t[3] = 1.0f;
  t[4] = 0.0f; t[5] = 0.0f;
}

*)
begin
  dst[0] := 1.0;
  dst[1] := 0.0;
  dst[2] := nvg__tanf(a);
  dst[3] := 1.0;
  dst[4] := 0.0;
  dst[5] := 0.0;
end;

procedure nvgTransformSkewY(dst: PSingle; a: single);
(*
void nvgTransformSkewY(single* t, single a)
{
  t[0] = 1.0f; t[1] = nvg__tanf(a);
  t[2] = 0.0f; t[3] = 1.0f;
  t[4] = 0.0f; t[5] = 0.0f;
}
*)
begin
  dst[0] := 1.0;
  dst[1] := nvg__tanf(a);
  dst[2] := 0.0;
  dst[3] := 1.0;
  dst[4] := 0.0;
  dst[5] := 0.0;
end;

procedure nvgTransformMultiply(dst: PSingle; const src: PSingle);
(*
void nvgTransformMultiply(single* t, const single* s)
{
  single t0 = t[0] * s[0] + t[1] * s[2];
  single t2 = t[2] * s[0] + t[3] * s[2];
  single t4 = t[4] * s[0] + t[5] * s[2] + s[4];
  t[1] = t[0] * s[1] + t[1] * s[3];
  t[3] = t[2] * s[1] + t[3] * s[3];
  t[5] = t[4] * s[1] + t[5] * s[3] + s[5];
  t[0] = t0;
  t[2] = t2;
  t[4] = t4;
}
*)
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
(*
void nvgTransformPremultiply(single* t, const single* s)
{
  single s2[6];
  memcpy(s2, s, sizeof(single)*6);
  nvgTransformMultiply(s2, t);
  memcpy(t, s2, sizeof(single)*6);
}
*)
var
  s2: TAffineMatrix;
begin
  Move(src^,s2[0], sizeof(single) * 6);
  nvgTransformMultiply(s2, dst);
  move(s2[0],dst^, sizeof(single) * 6);
end;

(*
int32 nvgTransformInverse(single* inv, const single* t)
{
  double invdet, det = (double)t[0] * t[3] - (double)t[2] * t[1];
  if (det > -1e-6 && det < 1e-6) {
    nvgTransformIdentity(inv);
    return 0;
  }
  invdet = 1.0 / det;
  inv[0] = (single)(t[3] * invdet);
  inv[2] = (single)(-t[2] * invdet);
  inv[4] = (single)(((double)t[2] * t[5] - (double)t[3] * t[4]) * invdet);
  inv[1] = (single)(-t[1] * invdet);
  inv[3] = (single)(t[0] * invdet);
  inv[5] = (single)(((double)t[1] * t[4] - (double)t[0] * t[5]) * invdet);
  return 1;
}

*)
(*
procedure nvgTransformPoint(single* dx, single* dy, const single* t, single sx, single sy)
{
  *dx = sx*t[0] + sy*t[2] + t[4];
  *dy = sx*t[1] + sy*t[3] + t[5];
}

*)
(*
single nvgDegToRad(single deg)
{
  return deg / 180.0f * NVG_PI;
}

*)
(*
single nvgRadToDeg(single rad)
{
  return rad / NVG_PI * 180.0f;
}

*)
procedure nvg__setPaintColor(var p: TNVGPaint; color: TNVGColor);
(*
static void nvg__setPaintColor(TNVGPaint* p, color:TNVGColor )
{
  memset(p, 0, sizeof( *p));
  nvgTransformIdentity(p->xform);
  p->radius = 0.0f;
  p->feather = 1.0f;
  p->innerColor = color;
  p->outerColor = color;
}
*)
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
(*
void nvgSave(ctx: PNVGContext)
{
  if (ctx->nstates >= NVG_MAX_STATES)
    return;
  if (ctx->nstates > 0)
    memcpy(&ctx->states[ctx->nstates], &ctx->states[ctx->nstates-1], sizeof(NVGstate));
  ctx->nstates++;
}
*)
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
(*
void nvgRestore(ctx: PNVGContext)
{
  if (ctx->nstates <= 1)
    return;
  ctx->nstates--;
}
*)
begin
  if (ctx^.nstates <= 1) then
    exit;
  Dec(ctx^.nstates);
end;

procedure nvgReset(ctx: PNVGContext);
(*
void nvgReset(ctx: PNVGContext)
{
  NVGstate* state = nvg__getState(ctx);
  memset(state, 0, sizeof( *state));

  nvg__setPaintColor(&state->fill, nvgRGBA(255,255,255,255));
  nvg__setPaintColor(&state->stroke, nvgRGBA(0,0,0,255));
  state->compositeOperation = nvg__compositeOperationState(NVG_SOURCE_OVER);
  state->shapeAntiAlias = 1;
  state->strokeWidth = 1.0f;
  state->miterLimit = 10.0f;
  state->lineCap = NVG_BUTT;
  state->lineJoin = NVG_MITER;
  state->alpha = 1.0f;
  nvgTransformIdentity(state->xform);

  state->scissor.extent[0] = -1.0f;
  state->scissor.extent[1] = -1.0f;

  state->fontSize = 16.0f;
  state->letterSpacing = 0.0f;
  state->lineHeight = 1.0f;
  state->fontBlur = 0.0f;
  state->textAlign = NVG_ALIGN_LEFT | NVG_ALIGN_BASELINE;
  state->fontId = 0;
}
*)
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

procedure nvgShapeAntiAlias(ctx: PNVGContext; Enabled: boolean);
(*
// State setting
void nvgShapeAntiAlias(ctx: PNVGContext; int32 enabled)
{
  NVGstate* state = nvg__getState(ctx);
  state->shapeAntiAlias = enabled;
}
*)
var
  state: PNVGstate;
begin
  state := nvg__getState(ctx);
  state^.shapeAntiAlias := Enabled;
end;
(*
procedure nvgStrokeWidth(ctx: PNVGContext; single width)
{
  NVGstate* state = nvg__getState(ctx);
  state->strokeWidth = width;
}
*)
(*
procedure nvgMiterLimit(ctx: PNVGContext; single limit)
{
  NVGstate* state = nvg__getState(ctx);
  state->miterLimit = limit;
}
*)
(*
procedure nvgLineCap(ctx: PNVGContext; int32 cap)
{
  NVGstate* state = nvg__getState(ctx);
  state->lineCap = cap;
}
*)
(*
procedure nvgLineJoin(ctx: PNVGContext; int32 join)
{
  NVGstate* state = nvg__getState(ctx);
  state->lineJoin = join;
}
*)
(*

procedure nvgGlobalAlpha(ctx: PNVGContext; single alpha)
{
  NVGstate* state = nvg__getState(ctx);
  state->alpha = alpha;
}
*)
(*
procedure nvgTransform(ctx: PNVGContext; single a, single b, single c, single d, single e, single f)
{
  NVGstate* state = nvg__getState(ctx);
  single t[6] = { a, b, c, d, e, f };
  nvgTransformPremultiply(state->xform, t);
}
*)
(*
procedure nvgResetTransform(ctx: PNVGContext)
{
  NVGstate* state = nvg__getState(ctx);
  nvgTransformIdentity(state->xform);
}
*)
(*
procedure nvgTranslate(ctx: PNVGContext; single x, single y)
{
  NVGstate* state = nvg__getState(ctx);
  single t[6];
  nvgTransformTranslate(t, x,y);
  nvgTransformPremultiply(state->xform, t);
}
*)
(*
procedure nvgRotate(ctx: PNVGContext; single angle)
{
  NVGstate* state = nvg__getState(ctx);
  single t[6];
  nvgTransformRotate(t, angle);
  nvgTransformPremultiply(state->xform, t);
}
*)
(*
procedure nvgSkewX(ctx: PNVGContext; single angle)
{
  NVGstate* state = nvg__getState(ctx);
  single t[6];
  nvgTransformSkewX(t, angle);
  nvgTransformPremultiply(state->xform, t);
}
*)
(*
procedure nvgSkewY(ctx: PNVGContext; single angle)
{
  NVGstate* state = nvg__getState(ctx);
  single t[6];
  nvgTransformSkewY(t, angle);
  nvgTransformPremultiply(state->xform, t);
}
*)
(*
procedure nvgScale(ctx: PNVGContext; single x, single y)
{
  NVGstate* state = nvg__getState(ctx);
  single t[6];
  nvgTransformScale(t, x,y);
  nvgTransformPremultiply(state->xform, t);
}
*)
(*
procedure nvgCurrentTransform(ctx: PNVGContext; single* xform)
{
  NVGstate* state = nvg__getState(ctx);
  if (xform == NULL) return;
  memcpy(xform, state->xform, sizeof(single)*6);
}
*)
procedure nvgStrokeColor(ctx: PNVGContext; color: TNVGColor);
(*
void nvgStrokeColor(ctx: PNVGContext; color:TNVGColor )
{
  NVGstate* state = nvg__getState(ctx);
  nvg__setPaintColor(&state->stroke, color);
}
*)
var
  state: PNVGState;
begin
  state := nvg__getState(ctx);
  nvg__setPaintColor(state^.stroke, color);
end;

procedure nvgStrokePaint(ctx: PNVGContext; paint: TNVGPaint);
(*
void nvgStrokePaint(ctx: PNVGContext; paint: TNVGPaint )
{
  NVGstate* state = nvg__getState(ctx);
  state->stroke = paint;
  nvgTransformMultiply(state->stroke.xform, state->xform);
}
*)
var
  state: PNVGState;
begin
  state := nvg__getState(ctx);
  state^.stroke := paint;
  nvgTransformMultiply(state^.stroke.xform, state^.xform);
end;

procedure nvgFillColor(ctx: PNVGContext; color: TNVGColor);
(*
void nvgFillColor(ctx: PNVGContext; color:TNVGColor )
{
  NVGstate* state = nvg__getState(ctx);
  nvg__setPaintColor(&state->fill, color);
}
*)
var
  state: PNVGState;
begin
  state := nvg__getState(ctx);
  nvg__setPaintColor(state^.fill, color);
end;

procedure nvgFillPaint(ctx: PNVGContext; paint: TNVGPaint);
(*
void nvgFillPaint(ctx: PNVGContext; paint: TNVGPaint )
{
  NVGstate* state = nvg__getState(ctx);
  state->fill = paint;
  nvgTransformMultiply(state->fill.xform, state->xform);
}
*)
var
  state: PNVGState;
begin
  state := nvg__getState(ctx);
  state^.fill := paint;
  nvgTransformMultiply(state^.fill.xform, state^.xform);
end;

function nvgCreateImage(ctx: PNVGContext; const filename: pchar; imageFlags: int32): int32;
(*
#ifndef NVG_NO_STB
int32 nvgCreateImage(ctx: PNVGContext; const char* filename, int32 imageFlags)
{
  int32 w, h, n, image;
  int8* img;
  stbi_set_unpremultiply_on_load(1);
  stbi_convert_iphone_png_to_rgb(1);
  img = stbi_load(filename, &w, &h, &n, 4);
  if (img == NULL) {
//    printf("Failed to load %s - %s\n", filename, stbi_failure_reason());
    return 0;
  }
  image = nvgCreateImageRGBA(ctx, w, h, imageFlags, img);
  stbi_image_free(img);
  return image;
}
*)
begin
  Result := 0;
end;

(*
int32 nvgCreateImageMem(ctx: PNVGContext; int32 imageFlags, int8* data, int32 ndata)
{
  int32 w, h, n, image;
  int8* img = stbi_load_from_memory(data, ndata, &w, &h, &n, 4);
  if (img == NULL) {
//    printf("Failed to load %s - %s\n", filename, stbi_failure_reason());
    return 0;
  }
  image = nvgCreateImageRGBA(ctx, w, h, imageFlags, img);
  stbi_image_free(img);
  return image;
}
#endif
*)
(*
int32 nvgCreateImageRGBA(ctx: PNVGContext; int32 w, int32 h, int32 imageFlags, const int8* data)
{
  return ctx->params.renderCreateTexture(ctx->params.userPtr, NVG_TEXTURE_RGBA, w, h, imageFlags, data);
}
*)
(*
procedure nvgUpdateImage(ctx: PNVGContext; image: int32 , const int8* data)
{
  int32 w, h;
  ctx->params.renderGetTextureSize(ctx->params.userPtr, image, &w, &h);
  ctx->params.renderUpdateTexture(ctx->params.userPtr, image, 0,0, w,h, data);
}
*)
(*
procedure nvgImageSize(ctx: PNVGContext; image: int32 , int32* w, int32* h)
{
  ctx->params.renderGetTextureSize(ctx->params.userPtr, image, w, h);
}
*)
(*
procedure nvgDeleteImage(ctx: PNVGContext; image: int32 )
{
  ctx->params.renderDeleteTexture(ctx->params.userPtr, image);
}
*)
(*
TNVGPaint nvgLinearGradient(ctx: PNVGContext;
                  single sx, single sy, single ex, single ey,
                  NVGcolor icol, NVGcolor ocol)
{
  TNVGPaint p;
  single dx, dy, d;
  const single large = 1e5;
  NVG_NOTUSED(ctx);
  memset(&p, 0, sizeof(p));

  // Calculate transform aligned to the line
  dx = ex - sx;
  dy = ey - sy;
  d = sqrtf(dx*dx + dy*dy);
  if (d > 0.0001f) {
    dx /= d;
    dy /= d;
  } else {
    dx = 0;
    dy = 1;
  }

  p.xform[0] = dy; p.xform[1] = -dx;
  p.xform[2] = dx; p.xform[3] = dy;
  p.xform[4] = sx - dx*large; p.xform[5] = sy - dy*large;

  p.extent[0] = large;
  p.extent[1] = large + d*0.5f;

  p.radius = 0.0f;

  p.feather = nvg__maxf(1.0f, d);

  p.innerColor = icol;
  p.outerColor = ocol;

  return p;
}
*)
(*
TNVGPaint nvgRadialGradient(ctx: PNVGContext;
                  single cx, single cy, single inr, single outr,
                  NVGcolor icol, NVGcolor ocol)
{
  TNVGPaint p;
  single r = (inr+outr)*0.5f;
  single f = (outr-inr);
  NVG_NOTUSED(ctx);
  memset(&p, 0, sizeof(p));

  nvgTransformIdentity(p.xform);
  p.xform[4] = cx;
  p.xform[5] = cy;

  p.extent[0] = r;
  p.extent[1] = r;

  p.radius = r;

  p.feather = nvg__maxf(1.0f, f);

  p.innerColor = icol;
  p.outerColor = ocol;

  return p;
}
*)
(*
TNVGPaint nvgBoxGradient(ctx: PNVGContext;
                 x, y: single;  single w, single h, single r, single f,
                 NVGcolor icol, NVGcolor ocol)
{
  TNVGPaint p;
  NVG_NOTUSED(ctx);
  memset(&p, 0, sizeof(p));

  nvgTransformIdentity(p.xform);
  p.xform[4] = x+w*0.5f;
  p.xform[5] = y+h*0.5f;

  p.extent[0] = w*0.5f;
  p.extent[1] = h*0.5f;

  p.radius = r;

  p.feather = nvg__maxf(1.0f, f);

  p.innerColor = icol;
  p.outerColor = ocol;

  return p;
}
*)
(*
TNVGPaint nvgImagePattern(ctx: PNVGContext;
                single cx, single cy, single w, single h, single angle,
                image: int32 , single alpha)
{
  TNVGPaint p;
  NVG_NOTUSED(ctx);
  memset(&p, 0, sizeof(p));

  nvgTransformRotate(p.xform, angle);
  p.xform[4] = cx;
  p.xform[5] = cy;

  p.extent[0] = w;
  p.extent[1] = h;

  p.image = image;

  p.innerColor = p.outerColor = nvgRGBAf(1,1,1,alpha);

  return p;
}
*)
(*
// Scissoring
procedure nvgScissor(ctx: PNVGContext; x, y: single;  single w, single h)
{
  NVGstate* state = nvg__getState(ctx);

  w = nvg__maxf(0.0f, w);
  h = nvg__maxf(0.0f, h);

  nvgTransformIdentity(state->scissor.xform);
  state->scissor.xform[4] = x+w*0.5f;
  state->scissor.xform[5] = y+h*0.5f;
  nvgTransformMultiply(state->scissor.xform, state->xform);

  state->scissor.extent[0] = w*0.5f;
  state->scissor.extent[1] = h*0.5f;
}
*)
(*
static void nvg__isectRects(single* dst,
              single ax, single ay, single aw, single ah,
              single bx, single by, single bw, single bh)
{
  single minx = nvg__maxf(ax, bx);
  single miny = nvg__maxf(ay, by);
  single maxx = nvg__minf(ax+aw, bx+bw);
  single maxy = nvg__minf(ay+ah, by+bh);
  dst[0] = minx;
  dst[1] = miny;
  dst[2] = nvg__maxf(0.0f, maxx - minx);
  dst[3] = nvg__maxf(0.0f, maxy - miny);
}
*)
(*
procedure nvgIntersectScissor(ctx: PNVGContext; x, y: single;  single w, single h)
{
  NVGstate* state = nvg__getState(ctx);
  single pxform[6], invxorm[6];
  single rect[4];
  single ex, ey, tex, tey;

  // If no previous scissor has been set, set the scissor as current scissor.
  if (state->scissor.extent[0] < 0) {
    nvgScissor(ctx, x, y, w, h);
    return;
  }

  // Transform the current scissor rect into current transform space.
  // If there is difference in rotation, this will be approximation.
  memcpy(pxform, state->scissor.xform, sizeof(single)*6);
  ex = state->scissor.extent[0];
  ey = state->scissor.extent[1];
  nvgTransformInverse(invxorm, state->xform);
  nvgTransformMultiply(pxform, invxorm);
  tex = ex*nvg__absf(pxform[0]) + ey*nvg__absf(pxform[2]);
  tey = ex*nvg__absf(pxform[1]) + ey*nvg__absf(pxform[3]);

  // Intersect rects.
  nvg__isectRects(rect, pxform[4]-tex,pxform[5]-tey,tex*2,tey*2, x,y,w,h);

  nvgScissor(ctx, rect[0], rect[1], rect[2], rect[3]);
}
*)
(*
procedure nvgResetScissor(ctx: PNVGContext)
{
  NVGstate* state = nvg__getState(ctx);
  memset(state->scissor.xform, 0, sizeof(state->scissor.xform));
  state->scissor.extent[0] = -1.0f;
  state->scissor.extent[1] = -1.0f;
}
*)
// Global composite operation.
procedure nvgGlobalCompositeOperation(ctx: PNVGContext; op: int32);
(*
procedure nvgGlobalCompositeOperation(ctx: PNVGContext; int32 op)
{
  NVGstate* state = nvg__getState(ctx);
  state->compositeOperation = nvg__compositeOperationState(op);
}
*)
begin
end;

procedure nvgGlobalCompositeBlendFunc(ctx: PNVGContext; sfactor, dfactor: int32);
(*
procedure nvgGlobalCompositeBlendFunc(ctx: PNVGContext; int32 sfactor, int32 dfactor)
{
  nvgGlobalCompositeBlendFuncSeparate(ctx, sfactor, dfactor, sfactor, dfactor);
}
*)
begin
end;

procedure nvgGlobalCompositeBlendFuncSeparate(ctx: PNVGContext; srcRGB, dstRGB, srcAlpha, dstAlpha: int32);
(*
procedure nvgGlobalCompositeBlendFuncSeparate(ctx: PNVGContext; int32 srcRGB, int32 dstRGB, int32 srcAlpha, int32 dstAlpha)
{
  NVGcompositeOperationState op;
  op.srcRGB = srcRGB;
  op.dstRGB = dstRGB;
  op.srcAlpha = srcAlpha;
  op.dstAlpha = dstAlpha;

  NVGstate* state = nvg__getState(ctx);
  state->compositeOperation = op;
}
*)
begin
end;

(*
static int32 nvg__ptEquals(single x1, single y1, single x2, single y2, single tol)
{
  single dx = x2 - x1;
  single dy = y2 - y1;
  return dx*dx + dy*dy < tol*tol;
}
*)
(*
static single nvg__distPtSeg(x, y: single;  single px, single py, single qx, single qy)
{
  single pqx, pqy, dx, dy, d, t;
  pqx = qx-px;
  pqy = qy-py;
  dx = x-px;
  dy = y-py;
  d = pqx*pqx + pqy*pqy;
  t = pqx*dx + pqy*dy;
  if (d > 0) t /= d;
  if (t < 0) t = 0;
  else if (t > 1) t = 1;
  dx = px + t*pqx - x;
  dy = py + t*pqy - y;
  return dx*dx + dy*dy;
}
*)
(*
static void nvg__appendCommands(ctx: PNVGContext; single* vals, int32 nvals)
{
  NVGstate* state = nvg__getState(ctx);
  int32 i;

  if (ctx->ncommands+nvals > ctx->ccommands) {
    single* commands;
    int32 ccommands = ctx->ncommands+nvals + ctx->ccommands/2;
    commands = (single* )realloc(ctx->commands, sizeof(single)*ccommands);
    if (commands == NULL) return;
    ctx->commands = commands;
    ctx->ccommands = ccommands;
  }

  if ((int32)vals[0] != NVG_CLOSE && (int32)vals[0] != NVG_WINDING) {
    ctx->commandx = vals[nvals-2];
    ctx->commandy = vals[nvals-1];
  }

  // transform commands
  i = 0;
  while (i < nvals) {
    int32 cmd = (int32)vals[i];
    switch (cmd) {
    case NVG_MOVETO:
      nvgTransformPoint(&vals[i+1],&vals[i+2], state->xform, vals[i+1],vals[i+2]);
      i += 3;
      break;
    case NVG_LINETO:
      nvgTransformPoint(&vals[i+1],&vals[i+2], state->xform, vals[i+1],vals[i+2]);
      i += 3;
      break;
    case NVG_BEZIERTO:
      nvgTransformPoint(&vals[i+1],&vals[i+2], state->xform, vals[i+1],vals[i+2]);
      nvgTransformPoint(&vals[i+3],&vals[i+4], state->xform, vals[i+3],vals[i+4]);
      nvgTransformPoint(&vals[i+5],&vals[i+6], state->xform, vals[i+5],vals[i+6]);
      i += 7;
      break;
    case NVG_CLOSE:
      i++;
      break;
    case NVG_WINDING:
      i += 2;
      break;
    default:
      i++;
    }
  }

  memcpy(&ctx->commands[ctx->ncommands], vals, nvals*sizeof(single));

  ctx->ncommands += nvals;
}
*)
(*
static void nvg__clearPathCache(ctx: PNVGContext)
{
  ctx->cache->npoints = 0;
  ctx->cache->npaths = 0;
}
*)
(*
static NVGpath* nvg__lastPath(ctx: PNVGContext)
{
  if (ctx->cache->npaths > 0)
    return &ctx->cache->paths[ctx->cache->npaths-1];
  return NULL;
}
*)
(*
static void nvg__addPath(ctx: PNVGContext)
{
  NVGpath* path;
  if (ctx->cache->npaths+1 > ctx->cache->cpaths) {
    NVGpath* paths;
    int32 cpaths = ctx->cache->npaths+1 + ctx->cache->cpaths/2;
    paths = (NVGpath* )realloc(ctx->cache->paths, sizeof(NVGpath)*cpaths);
    if (paths == NULL) return;
    ctx->cache->paths = paths;
    ctx->cache->cpaths = cpaths;
  }
  path = &ctx->cache->paths[ctx->cache->npaths];
  memset(path, 0, sizeof( *path));
  path->first = ctx->cache->npoints;
  path->winding = NVG_CCW;

  ctx->cache->npaths++;
}
*)
(*
static NVGpoint* nvg__lastPoint(ctx: PNVGContext)
{
  if (ctx->cache->npoints > 0)
    return &ctx->cache->points[ctx->cache->npoints-1];
  return NULL;
}
*)
(*
static void nvg__addPoint(ctx: PNVGContext; x, y: single;  int32 flags)
{
  NVGpath* path = nvg__lastPath(ctx);
  NVGpoint* pt;
  if (path == NULL) return;

  if (path->count > 0 && ctx->cache->npoints > 0) {
    pt = nvg__lastPoint(ctx);
    if (nvg__ptEquals(pt->x,pt->y, x,y, ctx->distTol)) {
      pt->flags |= flags;
      return;
    }
  }

  if (ctx->cache->npoints+1 > ctx->cache->cpoints) {
    NVGpoint* points;
    int32 cpoints = ctx->cache->npoints+1 + ctx->cache->cpoints/2;
    points = (NVGpoint* )realloc(ctx->cache->points, sizeof(NVGpoint)*cpoints);
    if (points == NULL) return;
    ctx->cache->points = points;
    ctx->cache->cpoints = cpoints;
  }

  pt = &ctx->cache->points[ctx->cache->npoints];
  memset(pt, 0, sizeof( *pt));
  pt->x = x;
  pt->y = y;
  pt->flags = (int8)flags;

  ctx->cache->npoints++;
  path->count++;
}
*)
(*
static void nvg__closePath(ctx: PNVGContext)
{
  NVGpath* path = nvg__lastPath(ctx);
  if (path == NULL) return;
  path->closed = 1;
}
*)
(*
static void nvg__pathWinding(ctx: PNVGContext; int32 winding)
{
  NVGpath* path = nvg__lastPath(ctx);
  if (path == NULL) return;
  path->winding = winding;
}
*)
(*
static single nvg__getAverageScale(single *t)
{
  single sx = sqrtf(t[0]*t[0] + t[2]*t[2]);
  single sy = sqrtf(t[1]*t[1] + t[3]*t[3]);
  return (sx + sy) * 0.5f;
}
*)
(*
static NVGvertex* nvg__allocTempVerts(ctx: PNVGContext; int32 nverts)
{
  if (nverts > ctx->cache->cverts) {
    NVGvertex* verts;
    int32 cverts = (nverts + $ff) & ~$ff; // Round up to prevent allocations when things change just slightly.
    verts = (NVGvertex* )realloc(ctx->cache->verts, sizeof(NVGvertex)*cverts);
    if (verts == NULL) return NULL;
    ctx->cache->verts = verts;
    ctx->cache->cverts = cverts;
  }

  return ctx->cache->verts;
}
*)
(*
static single nvg__triarea2(single ax, single ay, single bx, single by, single cx, single cy)
{
  single abx = bx - ax;
  single aby = by - ay;
  single acx = cx - ax;
  single acy = cy - ay;
  return acx*aby - abx*acy;
}
*)
(*
static single nvg__polyArea(NVGpoint* pts, int32 npts)
{
  int32 i;
  single area = 0;
  for (i = 2; i < npts; i++) {
    NVGpoint* a = &pts[0];
    NVGpoint* b = &pts[i-1];
    NVGpoint* c = &pts[i];
    area += nvg__triarea2(a->x,a->y, b->x,b->y, c->x,c->y);
  }
  return area * 0.5f;
}
*)
(*
static void nvg__polyReverse(NVGpoint* pts, int32 npts)
{
  NVGpoint tmp;
  int32 i = 0, j = npts-1;
  while (i < j) {
    tmp = pts[i];
    pts[i] = pts[j];
    pts[j] = tmp;
    i++;
    j--;
  }
}
*)
(*
static void nvg__vset(NVGvertex* vtx, x, y: single;  single u, single v)
{
  vtx->x = x;
  vtx->y = y;
  vtx->u = u;
  vtx->v = v;
}
*)
(*
static void nvg__tesselateBezier(ctx: PNVGContext;
                 single x1, single y1, single x2, single y2,
                 single x3, single y3, single x4, single y4,
                 int32 level, int32 type)
{
  single x12,y12,x23,y23,x34,y34,x123,y123,x234,y234,x1234,y1234;
  single dx,dy,d2,d3;

  if (level > 10) return;

  x12 = (x1+x2)*0.5f;
  y12 = (y1+y2)*0.5f;
  x23 = (x2+x3)*0.5f;
  y23 = (y2+y3)*0.5f;
  x34 = (x3+x4)*0.5f;
  y34 = (y3+y4)*0.5f;
  x123 = (x12+x23)*0.5f;
  y123 = (y12+y23)*0.5f;

  dx = x4 - x1;
  dy = y4 - y1;
  d2 = nvg__absf(((x2 - x4) * dy - (y2 - y4) * dx));
  d3 = nvg__absf(((x3 - x4) * dy - (y3 - y4) * dx));

  if ((d2 + d3)*(d2 + d3) < ctx->tessTol * (dx*dx + dy*dy)) {
    nvg__addPoint(ctx, x4, y4, type);
    return;
  }

/*  if (nvg__absf(x1+x3-x2-x2) + nvg__absf(y1+y3-y2-y2) + nvg__absf(x2+x4-x3-x3) + nvg__absf(y2+y4-y3-y3) < ctx->tessTol) {
    nvg__addPoint(ctx, x4, y4, type);
    return;
  }*/

  x234 = (x23+x34)*0.5f;
  y234 = (y23+y34)*0.5f;
  x1234 = (x123+x234)*0.5f;
  y1234 = (y123+y234)*0.5f;

  nvg__tesselateBezier(ctx, x1,y1, x12,y12, x123,y123, x1234,y1234, level+1, 0);
  nvg__tesselateBezier(ctx, x1234,y1234, x234,y234, x34,y34, x4,y4, level+1, type);
}

*)
(*
static void nvg__flattenPaths(ctx: PNVGContext)
{
  NVGpathCache* cache = ctx->cache;
//  NVGstate* state = nvg__getState(ctx);
  NVGpoint* last;
  NVGpoint* p0;
  NVGpoint* p1;
  NVGpoint* pts;
  NVGpath* path;
  int32 i, j;
  single* cp1;
  single* cp2;
  single* p;
  single area;

  if (cache->npaths > 0)
    return;

  // Flatten
  i = 0;
  while (i < ctx->ncommands) {
    int32 cmd = (int32)ctx->commands[i];
    switch (cmd) {
    case NVG_MOVETO:
      nvg__addPath(ctx);
      p = &ctx->commands[i+1];
      nvg__addPoint(ctx, p[0], p[1], NVG_PT_CORNER);
      i += 3;
      break;
    case NVG_LINETO:
      p = &ctx->commands[i+1];
      nvg__addPoint(ctx, p[0], p[1], NVG_PT_CORNER);
      i += 3;
      break;
    case NVG_BEZIERTO:
      last = nvg__lastPoint(ctx);
      if (last != NULL) {
        cp1 = &ctx->commands[i+1];
        cp2 = &ctx->commands[i+3];
        p = &ctx->commands[i+5];
        nvg__tesselateBezier(ctx, last->x,last->y, cp1[0],cp1[1], cp2[0],cp2[1], p[0],p[1], 0, NVG_PT_CORNER);
      }
      i += 7;
      break;
    case NVG_CLOSE:
      nvg__closePath(ctx);
      i++;
      break;
    case NVG_WINDING:
      nvg__pathWinding(ctx, (int32)ctx->commands[i+1]);
      i += 2;
      break;
    default:
      i++;
    }
  }

  cache->bounds[0] = cache->bounds[1] = 1e6f;
  cache->bounds[2] = cache->bounds[3] = -1e6f;

  // Calculate the direction and length of line segments.
  for (j = 0; j < cache->npaths; j++) {
    path = &cache->paths[j];
    pts = &cache->points[path->first];

    // If the first and last points are the same, remove the last, mark as closed path.
    p0 = &pts[path->count-1];
    p1 = &pts[0];
    if (nvg__ptEquals(p0->x,p0->y, p1->x,p1->y, ctx->distTol)) {
      path->count--;
      p0 = &pts[path->count-1];
      path->closed = 1;
    }

    // Enforce winding.
    if (path->count > 2) {
      area = nvg__polyArea(pts, path->count);
      if (path->winding == NVG_CCW && area < 0.0f)
        nvg__polyReverse(pts, path->count);
      if (path->winding == NVG_CW && area > 0.0f)
        nvg__polyReverse(pts, path->count);
    }

    for(i = 0; i < path->count; i++) {
      // Calculate segment direction and length
      p0->dx = p1->x - p0->x;
      p0->dy = p1->y - p0->y;
      p0->len = nvg__normalize(&p0->dx, &p0->dy);
      // Update bounds
      cache->bounds[0] = nvg__minf(cache->bounds[0], p0->x);
      cache->bounds[1] = nvg__minf(cache->bounds[1], p0->y);
      cache->bounds[2] = nvg__maxf(cache->bounds[2], p0->x);
      cache->bounds[3] = nvg__maxf(cache->bounds[3], p0->y);
      // Advance
      p0 = p1++;
    }
  }
}

*)
(*
static int32 nvg__curveDivs(single r, single arc, single tol)
{
  single da = acosf(r / (r + tol)) * 2.0f;
  return nvg__maxi(2, (int32)ceilf(arc / da));
}

*)
(*
static void nvg__chooseBevel(int32 bevel, NVGpoint* p0, NVGpoint* p1, single w,
              single* x0, single* y0, single* x1, single* y1)
{
  if (bevel) {
    *x0 = p1->x + p0->dy * w;
    *y0 = p1->y - p0->dx * w;
    *x1 = p1->x + p1->dy * w;
    *y1 = p1->y - p1->dx * w;
  } else {
    *x0 = p1->x + p1->dmx * w;
    *y0 = p1->y + p1->dmy * w;
    *x1 = p1->x + p1->dmx * w;
    *y1 = p1->y + p1->dmy * w;
  }
}

*)
(*
static NVGvertex* nvg__roundJoin(NVGvertex* dst, NVGpoint* p0, NVGpoint* p1,
                 single lw, single rw, single lu, single ru, int32 ncap,
                 single fringe)
{
  int32 i, n;
  single dlx0 = p0->dy;
  single dly0 = -p0->dx;
  single dlx1 = p1->dy;
  single dly1 = -p1->dx;
  NVG_NOTUSED(fringe);

  if (p1->flags & NVG_PT_LEFT) {
    single lx0,ly0,lx1,ly1,a0,a1;
    nvg__chooseBevel(p1->flags & NVG_PR_INNERBEVEL, p0, p1, lw, &lx0,&ly0, &lx1,&ly1);
    a0 = atan2f(-dly0, -dlx0);
    a1 = atan2f(-dly1, -dlx1);
    if (a1 > a0) a1 -= NVG_PI*2;

    nvg__vset(dst, lx0, ly0, lu,1); dst++;
    nvg__vset(dst, p1->x - dlx0*rw, p1->y - dly0*rw, ru,1); dst++;

    n = nvg__clampi((int32)ceilf(((a0 - a1) / NVG_PI) * ncap), 2, ncap);
    for (i = 0; i < n; i++) {
      single u = i/(single)(n-1);
      single a = a0 + u*(a1-a0);
      single rx = p1->x + cosf(a) * rw;
      single ry = p1->y + sinf(a) * rw;
      nvg__vset(dst, p1->x, p1->y, 0.5f,1); dst++;
      nvg__vset(dst, rx, ry, ru,1); dst++;
    }

    nvg__vset(dst, lx1, ly1, lu,1); dst++;
    nvg__vset(dst, p1->x - dlx1*rw, p1->y - dly1*rw, ru,1); dst++;

  } else {
    single rx0,ry0,rx1,ry1,a0,a1;
    nvg__chooseBevel(p1->flags & NVG_PR_INNERBEVEL, p0, p1, -rw, &rx0,&ry0, &rx1,&ry1);
    a0 = atan2f(dly0, dlx0);
    a1 = atan2f(dly1, dlx1);
    if (a1 < a0) a1 += NVG_PI*2;

    nvg__vset(dst, p1->x + dlx0*rw, p1->y + dly0*rw, lu,1); dst++;
    nvg__vset(dst, rx0, ry0, ru,1); dst++;

    n = nvg__clampi((int32)ceilf(((a1 - a0) / NVG_PI) * ncap), 2, ncap);
    for (i = 0; i < n; i++) {
      single u = i/(single)(n-1);
      single a = a0 + u*(a1-a0);
      single lx = p1->x + cosf(a) * lw;
      single ly = p1->y + sinf(a) * lw;
      nvg__vset(dst, lx, ly, lu,1); dst++;
      nvg__vset(dst, p1->x, p1->y, 0.5f,1); dst++;
    }

    nvg__vset(dst, p1->x + dlx1*rw, p1->y + dly1*rw, lu,1); dst++;
    nvg__vset(dst, rx1, ry1, ru,1); dst++;

  }
  return dst;
}

*)
(*
static NVGvertex* nvg__bevelJoin(NVGvertex* dst, NVGpoint* p0, NVGpoint* p1,
                    single lw, single rw, single lu, single ru, single fringe)
{
  single rx0,ry0,rx1,ry1;
  single lx0,ly0,lx1,ly1;
  single dlx0 = p0->dy;
  single dly0 = -p0->dx;
  single dlx1 = p1->dy;
  single dly1 = -p1->dx;
  NVG_NOTUSED(fringe);

  if (p1->flags & NVG_PT_LEFT) {
    nvg__chooseBevel(p1->flags & NVG_PR_INNERBEVEL, p0, p1, lw, &lx0,&ly0, &lx1,&ly1);

    nvg__vset(dst, lx0, ly0, lu,1); dst++;
    nvg__vset(dst, p1->x - dlx0*rw, p1->y - dly0*rw, ru,1); dst++;

    if (p1->flags & NVG_PT_BEVEL) {
      nvg__vset(dst, lx0, ly0, lu,1); dst++;
      nvg__vset(dst, p1->x - dlx0*rw, p1->y - dly0*rw, ru,1); dst++;

      nvg__vset(dst, lx1, ly1, lu,1); dst++;
      nvg__vset(dst, p1->x - dlx1*rw, p1->y - dly1*rw, ru,1); dst++;
    } else {
      rx0 = p1->x - p1->dmx * rw;
      ry0 = p1->y - p1->dmy * rw;

      nvg__vset(dst, p1->x, p1->y, 0.5f,1); dst++;
      nvg__vset(dst, p1->x - dlx0*rw, p1->y - dly0*rw, ru,1); dst++;

      nvg__vset(dst, rx0, ry0, ru,1); dst++;
      nvg__vset(dst, rx0, ry0, ru,1); dst++;

      nvg__vset(dst, p1->x, p1->y, 0.5f,1); dst++;
      nvg__vset(dst, p1->x - dlx1*rw, p1->y - dly1*rw, ru,1); dst++;
    }

    nvg__vset(dst, lx1, ly1, lu,1); dst++;
    nvg__vset(dst, p1->x - dlx1*rw, p1->y - dly1*rw, ru,1); dst++;

  } else {
    nvg__chooseBevel(p1->flags & NVG_PR_INNERBEVEL, p0, p1, -rw, &rx0,&ry0, &rx1,&ry1);

    nvg__vset(dst, p1->x + dlx0*lw, p1->y + dly0*lw, lu,1); dst++;
    nvg__vset(dst, rx0, ry0, ru,1); dst++;

    if (p1->flags & NVG_PT_BEVEL) {
      nvg__vset(dst, p1->x + dlx0*lw, p1->y + dly0*lw, lu,1); dst++;
      nvg__vset(dst, rx0, ry0, ru,1); dst++;

      nvg__vset(dst, p1->x + dlx1*lw, p1->y + dly1*lw, lu,1); dst++;
      nvg__vset(dst, rx1, ry1, ru,1); dst++;
    } else {
      lx0 = p1->x + p1->dmx * lw;
      ly0 = p1->y + p1->dmy * lw;

      nvg__vset(dst, p1->x + dlx0*lw, p1->y + dly0*lw, lu,1); dst++;
      nvg__vset(dst, p1->x, p1->y, 0.5f,1); dst++;

      nvg__vset(dst, lx0, ly0, lu,1); dst++;
      nvg__vset(dst, lx0, ly0, lu,1); dst++;

      nvg__vset(dst, p1->x + dlx1*lw, p1->y + dly1*lw, lu,1); dst++;
      nvg__vset(dst, p1->x, p1->y, 0.5f,1); dst++;
    }

    nvg__vset(dst, p1->x + dlx1*lw, p1->y + dly1*lw, lu,1); dst++;
    nvg__vset(dst, rx1, ry1, ru,1); dst++;
  }

  return dst;
}
*)
(*
static NVGvertex* nvg__buttCapStart(NVGvertex* dst, NVGpoint* p,
                  single dx, single dy, single w, single d,
                  single aa, single u0, single u1)
{
  single px = p->x - dx*d;
  single py = p->y - dy*d;
  single dlx = dy;
  single dly = -dx;
  nvg__vset(dst, px + dlx*w - dx*aa, py + dly*w - dy*aa, u0,0); dst++;
  nvg__vset(dst, px - dlx*w - dx*aa, py - dly*w - dy*aa, u1,0); dst++;
  nvg__vset(dst, px + dlx*w, py + dly*w, u0,1); dst++;
  nvg__vset(dst, px - dlx*w, py - dly*w, u1,1); dst++;
  return dst;
}
*)
(*
static NVGvertex* nvg__buttCapEnd(NVGvertex* dst, NVGpoint* p,
                  single dx, single dy, single w, single d,
                  single aa, single u0, single u1)
{
  single px = p->x + dx*d;
  single py = p->y + dy*d;
  single dlx = dy;
  single dly = -dx;
  nvg__vset(dst, px + dlx*w, py + dly*w, u0,1); dst++;
  nvg__vset(dst, px - dlx*w, py - dly*w, u1,1); dst++;
  nvg__vset(dst, px + dlx*w + dx*aa, py + dly*w + dy*aa, u0,0); dst++;
  nvg__vset(dst, px - dlx*w + dx*aa, py - dly*w + dy*aa, u1,0); dst++;
  return dst;
}
*)
(*
static NVGvertex* nvg__roundCapStart(NVGvertex* dst, NVGpoint* p,
                   single dx, single dy, single w, int32 ncap,
                   single aa, single u0, single u1)
{
  int32 i;
  single px = p->x;
  single py = p->y;
  single dlx = dy;
  single dly = -dx;
  NVG_NOTUSED(aa);
  for (i = 0; i < ncap; i++) {
    single a = i/(single)(ncap-1)*NVG_PI;
    single ax = cosf(a) * w, ay = sinf(a) * w;
    nvg__vset(dst, px - dlx*ax - dx*ay, py - dly*ax - dy*ay, u0,1); dst++;
    nvg__vset(dst, px, py, 0.5f,1); dst++;
  }
  nvg__vset(dst, px + dlx*w, py + dly*w, u0,1); dst++;
  nvg__vset(dst, px - dlx*w, py - dly*w, u1,1); dst++;
  return dst;
}
*)
(*
static NVGvertex* nvg__roundCapEnd(NVGvertex* dst, NVGpoint* p,
                   single dx, single dy, single w, int32 ncap,
                   single aa, single u0, single u1)
{
  int32 i;
  single px = p->x;
  single py = p->y;
  single dlx = dy;
  single dly = -dx;
  NVG_NOTUSED(aa);
  nvg__vset(dst, px + dlx*w, py + dly*w, u0,1); dst++;
  nvg__vset(dst, px - dlx*w, py - dly*w, u1,1); dst++;
  for (i = 0; i < ncap; i++) {
    single a = i/(single)(ncap-1)*NVG_PI;
    single ax = cosf(a) * w, ay = sinf(a) * w;
    nvg__vset(dst, px, py, 0.5f,1); dst++;
    nvg__vset(dst, px - dlx*ax + dx*ay, py - dly*ax + dy*ay, u0,1); dst++;
  }
  return dst;
}
*)
(*
static void nvg__calculateJoins(ctx: PNVGContext; single w, int32 lineJoin, single miterLimit)
{
  NVGpathCache* cache = ctx->cache;
  int32 i, j;
  single iw = 0.0f;

  if (w > 0.0f) iw = 1.0f / w;

  // Calculate which joins needs extra vertices to append, and gather vertex count.
  for (i = 0; i < cache->npaths; i++) {
    NVGpath* path = &cache->paths[i];
    NVGpoint* pts = &cache->points[path->first];
    NVGpoint* p0 = &pts[path->count-1];
    NVGpoint* p1 = &pts[0];
    int32 nleft = 0;

    path->nbevel = 0;

    for (j = 0; j < path->count; j++) {
      single dlx0, dly0, dlx1, dly1, dmr2, cross, limit;
      dlx0 = p0->dy;
      dly0 = -p0->dx;
      dlx1 = p1->dy;
      dly1 = -p1->dx;
      // Calculate extrusions
      p1->dmx = (dlx0 + dlx1) * 0.5f;
      p1->dmy = (dly0 + dly1) * 0.5f;
      dmr2 = p1->dmx*p1->dmx + p1->dmy*p1->dmy;
      if (dmr2 > 0.000001f) {
        single scale = 1.0f / dmr2;
        if (scale > 600.0f) {
          scale = 600.0f;
        }
        p1->dmx *= scale;
        p1->dmy *= scale;
      }

      // Clear flags, but keep the corner.
      p1->flags = (p1->flags & NVG_PT_CORNER) ? NVG_PT_CORNER : 0;

      // Keep track of left turns.
      cross = p1->dx * p0->dy - p0->dx * p1->dy;
      if (cross > 0.0f) {
        nleft++;
        p1->flags |= NVG_PT_LEFT;
      }

      // Calculate if we should use bevel or miter for inner join.
      limit = nvg__maxf(1.01f, nvg__minf(p0->len, p1->len) * iw);
      if ((dmr2 * limit*limit) < 1.0f)
        p1->flags |= NVG_PR_INNERBEVEL;

      // Check to see if the corner needs to be beveled.
      if (p1->flags & NVG_PT_CORNER) {
        if ((dmr2 * miterLimit*miterLimit) < 1.0f || lineJoin == NVG_BEVEL || lineJoin == NVG_ROUND) {
          p1->flags |= NVG_PT_BEVEL;
        }
      }

      if ((p1->flags & (NVG_PT_BEVEL | NVG_PR_INNERBEVEL)) != 0)
        path->nbevel++;

      p0 = p1++;
    }

    path->convex = (nleft == path->count) ? 1 : 0;
  }
}
*)
(*
static int32 nvg__expandStroke(ctx: PNVGContext; single w, single fringe, int32 lineCap, int32 lineJoin, single miterLimit)
{
  NVGpathCache* cache = ctx->cache;
  NVGvertex* verts;
  NVGvertex* dst;
  int32 cverts, i, j;
  single aa = fringe;//ctx->fringeWidth;
  single u0 = 0.0f, u1 = 1.0f;
  int32 ncap = nvg__curveDivs(w, NVG_PI, ctx->tessTol);  // Calculate divisions per half circle.

  w += aa * 0.5f;

  // Disable the gradient used for antialiasing when antialiasing is not used.
  if (aa == 0.0f) {
    u0 = 0.5f;
    u1 = 0.5f;
  }

  nvg__calculateJoins(ctx, w, lineJoin, miterLimit);

  // Calculate max vertex usage.
  cverts = 0;
  for (i = 0; i < cache->npaths; i++) {
    NVGpath* path = &cache->paths[i];
    int32 loop = (path->closed == 0) ? 0 : 1;
    if (lineJoin == NVG_ROUND)
      cverts += (path->count + path->nbevel*(ncap+2) + 1) * 2; // plus one for loop
    else
      cverts += (path->count + path->nbevel*5 + 1) * 2; // plus one for loop
    if (loop == 0) {
      // space for caps
      if (lineCap == NVG_ROUND) {
        cverts += (ncap*2 + 2)*2;
      } else {
        cverts += (3+3)*2;
      }
    }
  }

  verts = nvg__allocTempVerts(ctx, cverts);
  if (verts == NULL) return 0;

  for (i = 0; i < cache->npaths; i++) {
    NVGpath* path = &cache->paths[i];
    NVGpoint* pts = &cache->points[path->first];
    NVGpoint* p0;
    NVGpoint* p1;
    int32 s, e, loop;
    single dx, dy;

    path->fill = 0;
    path->nfill = 0;

    // Calculate fringe or stroke
    loop = (path->closed == 0) ? 0 : 1;
    dst = verts;
    path->stroke = dst;

    if (loop) {
      // Looping
      p0 = &pts[path->count-1];
      p1 = &pts[0];
      s = 0;
      e = path->count;
    } else {
      // Add cap
      p0 = &pts[0];
      p1 = &pts[1];
      s = 1;
      e = path->count-1;
    }

    if (loop == 0) {
      // Add cap
      dx = p1->x - p0->x;
      dy = p1->y - p0->y;
      nvg__normalize(&dx, &dy);
      if (lineCap == NVG_BUTT)
        dst = nvg__buttCapStart(dst, p0, dx, dy, w, -aa*0.5f, aa, u0, u1);
      else if (lineCap == NVG_BUTT || lineCap == NVG_SQUARE)
        dst = nvg__buttCapStart(dst, p0, dx, dy, w, w-aa, aa, u0, u1);
      else if (lineCap == NVG_ROUND)
        dst = nvg__roundCapStart(dst, p0, dx, dy, w, ncap, aa, u0, u1);
    }

    for (j = s; j < e; ++j) {
      if ((p1->flags & (NVG_PT_BEVEL | NVG_PR_INNERBEVEL)) != 0) {
        if (lineJoin == NVG_ROUND) {
          dst = nvg__roundJoin(dst, p0, p1, w, w, u0, u1, ncap, aa);
        } else {
          dst = nvg__bevelJoin(dst, p0, p1, w, w, u0, u1, aa);
        }
      } else {
        nvg__vset(dst, p1->x + (p1->dmx * w), p1->y + (p1->dmy * w), u0,1); dst++;
        nvg__vset(dst, p1->x - (p1->dmx * w), p1->y - (p1->dmy * w), u1,1); dst++;
      }
      p0 = p1++;
    }

    if (loop) {
      // Loop it
      nvg__vset(dst, verts[0].x, verts[0].y, u0,1); dst++;
      nvg__vset(dst, verts[1].x, verts[1].y, u1,1); dst++;
    } else {
      // Add cap
      dx = p1->x - p0->x;
      dy = p1->y - p0->y;
      nvg__normalize(&dx, &dy);
      if (lineCap == NVG_BUTT)
        dst = nvg__buttCapEnd(dst, p1, dx, dy, w, -aa*0.5f, aa, u0, u1);
      else if (lineCap == NVG_BUTT || lineCap == NVG_SQUARE)
        dst = nvg__buttCapEnd(dst, p1, dx, dy, w, w-aa, aa, u0, u1);
      else if (lineCap == NVG_ROUND)
        dst = nvg__roundCapEnd(dst, p1, dx, dy, w, ncap, aa, u0, u1);
    }

    path->nstroke = (int32)(dst - verts);

    verts = dst;
  }

  return 1;
}
*)
(*
static int32 nvg__expandFill(ctx: PNVGContext; single w, int32 lineJoin, single miterLimit)
{
  NVGpathCache* cache = ctx->cache;
  NVGvertex* verts;
  NVGvertex* dst;
  int32 cverts, convex, i, j;
  single aa = ctx->fringeWidth;
  int32 fringe = w > 0.0f;

  nvg__calculateJoins(ctx, w, lineJoin, miterLimit);

  // Calculate max vertex usage.
  cverts = 0;
  for (i = 0; i < cache->npaths; i++) {
    NVGpath* path = &cache->paths[i];
    cverts += path->count + path->nbevel + 1;
    if (fringe)
      cverts += (path->count + path->nbevel*5 + 1) * 2; // plus one for loop
  }

  verts = nvg__allocTempVerts(ctx, cverts);
  if (verts == NULL) return 0;

  convex = cache->npaths == 1 && cache->paths[0].convex;

  for (i = 0; i < cache->npaths; i++) {
    NVGpath* path = &cache->paths[i];
    NVGpoint* pts = &cache->points[path->first];
    NVGpoint* p0;
    NVGpoint* p1;
    single rw, lw, woff;
    single ru, lu;

    // Calculate shape vertices.
    woff = 0.5f*aa;
    dst = verts;
    path->fill = dst;

    if (fringe) {
      // Looping
      p0 = &pts[path->count-1];
      p1 = &pts[0];
      for (j = 0; j < path->count; ++j) {
        if (p1->flags & NVG_PT_BEVEL) {
          single dlx0 = p0->dy;
          single dly0 = -p0->dx;
          single dlx1 = p1->dy;
          single dly1 = -p1->dx;
          if (p1->flags & NVG_PT_LEFT) {
            single lx = p1->x + p1->dmx * woff;
            single ly = p1->y + p1->dmy * woff;
            nvg__vset(dst, lx, ly, 0.5f,1); dst++;
          } else {
            single lx0 = p1->x + dlx0 * woff;
            single ly0 = p1->y + dly0 * woff;
            single lx1 = p1->x + dlx1 * woff;
            single ly1 = p1->y + dly1 * woff;
            nvg__vset(dst, lx0, ly0, 0.5f,1); dst++;
            nvg__vset(dst, lx1, ly1, 0.5f,1); dst++;
          }
        } else {
          nvg__vset(dst, p1->x + (p1->dmx * woff), p1->y + (p1->dmy * woff), 0.5f,1); dst++;
        }
        p0 = p1++;
      }
    } else {
      for (j = 0; j < path->count; ++j) {
        nvg__vset(dst, pts[j].x, pts[j].y, 0.5f,1);
        dst++;
      }
    }

    path->nfill = (int32)(dst - verts);
    verts = dst;

    // Calculate fringe
    if (fringe) {
      lw = w + woff;
      rw = w - woff;
      lu = 0;
      ru = 1;
      dst = verts;
      path->stroke = dst;

      // Create only half a fringe for convex shapes so that
      // the shape can be rendered without stenciling.
      if (convex) {
        lw = woff;  // This should generate the same vertex as fill inset above.
        lu = 0.5f;  // Set outline fade at middle.
      }

      // Looping
      p0 = &pts[path->count-1];
      p1 = &pts[0];

      for (j = 0; j < path->count; ++j) {
        if ((p1->flags & (NVG_PT_BEVEL | NVG_PR_INNERBEVEL)) != 0) {
          dst = nvg__bevelJoin(dst, p0, p1, lw, rw, lu, ru, ctx->fringeWidth);
        } else {
          nvg__vset(dst, p1->x + (p1->dmx * lw), p1->y + (p1->dmy * lw), lu,1); dst++;
          nvg__vset(dst, p1->x - (p1->dmx * rw), p1->y - (p1->dmy * rw), ru,1); dst++;
        }
        p0 = p1++;
      }

      // Loop it
      nvg__vset(dst, verts[0].x, verts[0].y, lu,1); dst++;
      nvg__vset(dst, verts[1].x, verts[1].y, ru,1); dst++;

      path->nstroke = (int32)(dst - verts);
      verts = dst;
    } else {
      path->stroke = NULL;
      path->nstroke = 0;
    }
  }

  return 1;
}
*)
(*
// Draw
procedure nvgBeginPath(ctx: PNVGContext)
{
  ctx->ncommands = 0;
  nvg__clearPathCache(ctx);
}
*)
(*
procedure nvgMoveTo(ctx: PNVGContext; single x, single y)
{
  single vals[] = { NVG_MOVETO, x, y };
  nvg__appendCommands(ctx, vals, NVG_COUNTOF(vals));
}
*)
(*
procedure nvgLineTo(ctx: PNVGContext; single x, single y)
{
  single vals[] = { NVG_LINETO, x, y };
  nvg__appendCommands(ctx, vals, NVG_COUNTOF(vals));
}
*)
(*
procedure nvgBezierTo(ctx: PNVGContext; single c1x, single c1y, single c2x, single c2y, single x, single y)
{
  single vals[] = { NVG_BEZIERTO, c1x, c1y, c2x, c2y, x, y };
  nvg__appendCommands(ctx, vals, NVG_COUNTOF(vals));
}
*)
(*
procedure nvgQuadTo(ctx: PNVGContext; single cx, single cy, single x, single y)
{
    single x0 = ctx->commandx;
    single y0 = ctx->commandy;
    single vals[] = { NVG_BEZIERTO,
        x0 + 2.0f/3.0f*(cx - x0), y0 + 2.0f/3.0f*(cy - y0),
        x + 2.0f/3.0f*(cx - x), y + 2.0f/3.0f*(cy - y),
        x, y };
    nvg__appendCommands(ctx, vals, NVG_COUNTOF(vals));
}
*)
(*
procedure nvgArcTo(ctx: PNVGContext; single x1, single y1, single x2, single y2, single radius)
{
  single x0 = ctx->commandx;
  single y0 = ctx->commandy;
  single dx0,dy0, dx1,dy1, a, d, cx,cy, a0,a1;
  int32 dir;

  if (ctx->ncommands == 0) {
    return;
  }

  // Handle degenerate cases.
  if (nvg__ptEquals(x0,y0, x1,y1, ctx->distTol) ||
    nvg__ptEquals(x1,y1, x2,y2, ctx->distTol) ||
    nvg__distPtSeg(x1,y1, x0,y0, x2,y2) < ctx->distTol*ctx->distTol ||
    radius < ctx->distTol) {
    nvgLineTo(ctx, x1,y1);
    return;
  }

  // Calculate tangential circle to lines (x0,y0)-(x1,y1) and (x1,y1)-(x2,y2).
  dx0 = x0-x1;
  dy0 = y0-y1;
  dx1 = x2-x1;
  dy1 = y2-y1;
  nvg__normalize(&dx0,&dy0);
  nvg__normalize(&dx1,&dy1);
  a = nvg__acosf(dx0*dx1 + dy0*dy1);
  d = radius / nvg__tanf(a/2.0f);

//  printf("a=%f° d=%f\n", a/NVG_PI*180.0f, d);

  if (d > 10000.0f) {
    nvgLineTo(ctx, x1,y1);
    return;
  }

  if (nvg__cross(dx0,dy0, dx1,dy1) > 0.0f) {
    cx = x1 + dx0*d + dy0*radius;
    cy = y1 + dy0*d + -dx0*radius;
    a0 = nvg__atan2f(dx0, -dy0);
    a1 = nvg__atan2f(-dx1, dy1);
    dir = NVG_CW;
//    printf("CW c=(%f, %f) a0=%f° a1=%f°\n", cx, cy, a0/NVG_PI*180.0f, a1/NVG_PI*180.0f);
  } else {
    cx = x1 + dx0*d + -dy0*radius;
    cy = y1 + dy0*d + dx0*radius;
    a0 = nvg__atan2f(-dx0, dy0);
    a1 = nvg__atan2f(dx1, -dy1);
    dir = NVG_CCW;
//    printf("CCW c=(%f, %f) a0=%f° a1=%f°\n", cx, cy, a0/NVG_PI*180.0f, a1/NVG_PI*180.0f);
  }

  nvgArc(ctx, cx, cy, radius, a0, a1, dir);
}
*)
(*
procedure nvgClosePath(ctx: PNVGContext)
{
  single vals[] = { NVG_CLOSE };
  nvg__appendCommands(ctx, vals, NVG_COUNTOF(vals));
}
*)
(*
procedure nvgPathWinding(ctx: PNVGContext; int32 dir)
{
  single vals[] = { NVG_WINDING, (single)dir };
  nvg__appendCommands(ctx, vals, NVG_COUNTOF(vals));
}
*)
(*
procedure nvgArc(ctx: PNVGContext; single cx, single cy, single r, single a0, single a1, int32 dir)
{
  single a = 0, da = 0, hda = 0, kappa = 0;
  single dx = 0, dy = 0, x = 0, y = 0, tanx = 0, tany = 0;
  single px = 0, py = 0, ptanx = 0, ptany = 0;
  single vals[3 + 5*7 + 100];
  int32 i, ndivs, nvals;
  int32 move = ctx->ncommands > 0 ? NVG_LINETO : NVG_MOVETO;

  // Clamp angles
  da = a1 - a0;
  if (dir == NVG_CW) {
    if (nvg__absf(da) >= NVG_PI*2) {
      da = NVG_PI*2;
    } else {
      while (da < 0.0f) da += NVG_PI*2;
    }
  } else {
    if (nvg__absf(da) >= NVG_PI*2) {
      da = -NVG_PI*2;
    } else {
      while (da > 0.0f) da -= NVG_PI*2;
    }
  }

  // Split arc into max 90 degree segments.
  ndivs = nvg__maxi(1, nvg__mini((int32)(nvg__absf(da) / (NVG_PI*0.5f) + 0.5f), 5));
  hda = (da / (single)ndivs) / 2.0f;
  kappa = nvg__absf(4.0f / 3.0f * (1.0f - nvg__cosf(hda)) / nvg__sinf(hda));

  if (dir == NVG_CCW)
    kappa = -kappa;

  nvals = 0;
  for (i = 0; i <= ndivs; i++) {
    a = a0 + da * (i/(single)ndivs);
    dx = nvg__cosf(a);
    dy = nvg__sinf(a);
    x = cx + dx*r;
    y = cy + dy*r;
    tanx = -dy*r*kappa;
    tany = dx*r*kappa;

    if (i == 0) {
      vals[nvals++] = (single)move;
      vals[nvals++] = x;
      vals[nvals++] = y;
    } else {
      vals[nvals++] = NVG_BEZIERTO;
      vals[nvals++] = px+ptanx;
      vals[nvals++] = py+ptany;
      vals[nvals++] = x-tanx;
      vals[nvals++] = y-tany;
      vals[nvals++] = x;
      vals[nvals++] = y;
    }
    px = x;
    py = y;
    ptanx = tanx;
    ptany = tany;
  }

  nvg__appendCommands(ctx, vals, nvals);
}
*)
(*
procedure nvgRect(ctx: PNVGContext; x, y: single;  single w, single h)
{
  single vals[] = {
    NVG_MOVETO, x,y,
    NVG_LINETO, x,y+h,
    NVG_LINETO, x+w,y+h,
    NVG_LINETO, x+w,y,
    NVG_CLOSE
  };
  nvg__appendCommands(ctx, vals, NVG_COUNTOF(vals));
}
*)
(*
procedure nvgRoundedRect(ctx: PNVGContext; x, y: single;  single w, single h, single r)
{
  nvgRoundedRectVarying(ctx, x, y, w, h, r, r, r, r);
}
*)
(*
procedure nvgRoundedRectVarying(ctx: PNVGContext; x, y: single;  single w, single h, single radTopLeft, single radTopRight, single radBottomRight, single radBottomLeft)
{
  if(radTopLeft < 0.1f && radTopRight < 0.1f && radBottomRight < 0.1f && radBottomLeft < 0.1f) {
    nvgRect(ctx, x, y, w, h);
    return;
  } else {
    single halfw = nvg__absf(w)*0.5f;
    single halfh = nvg__absf(h)*0.5f;
    single rxBL = nvg__minf(radBottomLeft, halfw) * nvg__signf(w), ryBL = nvg__minf(radBottomLeft, halfh) * nvg__signf(h);
    single rxBR = nvg__minf(radBottomRight, halfw) * nvg__signf(w), ryBR = nvg__minf(radBottomRight, halfh) * nvg__signf(h);
    single rxTR = nvg__minf(radTopRight, halfw) * nvg__signf(w), ryTR = nvg__minf(radTopRight, halfh) * nvg__signf(h);
    single rxTL = nvg__minf(radTopLeft, halfw) * nvg__signf(w), ryTL = nvg__minf(radTopLeft, halfh) * nvg__signf(h);
    single vals[] = {
      NVG_MOVETO, x, y + ryTL,
      NVG_LINETO, x, y + h - ryBL,
      NVG_BEZIERTO, x, y + h - ryBL*(1 - NVG_KAPPA90), x + rxBL*(1 - NVG_KAPPA90), y + h, x + rxBL, y + h,
      NVG_LINETO, x + w - rxBR, y + h,
      NVG_BEZIERTO, x + w - rxBR*(1 - NVG_KAPPA90), y + h, x + w, y + h - ryBR*(1 - NVG_KAPPA90), x + w, y + h - ryBR,
      NVG_LINETO, x + w, y + ryTR,
      NVG_BEZIERTO, x + w, y + ryTR*(1 - NVG_KAPPA90), x + w - rxTR*(1 - NVG_KAPPA90), y, x + w - rxTR, y,
      NVG_LINETO, x + rxTL, y,
      NVG_BEZIERTO, x + rxTL*(1 - NVG_KAPPA90), y, x, y + ryTL*(1 - NVG_KAPPA90), x, y + ryTL,
      NVG_CLOSE
    };
    nvg__appendCommands(ctx, vals, NVG_COUNTOF(vals));
  }
}
*)
(*
procedure nvgEllipse(ctx: PNVGContext; single cx, single cy, single rx, single ry)
{
  single vals[] = {
    NVG_MOVETO, cx-rx, cy,
    NVG_BEZIERTO, cx-rx, cy+ry*NVG_KAPPA90, cx-rx*NVG_KAPPA90, cy+ry, cx, cy+ry,
    NVG_BEZIERTO, cx+rx*NVG_KAPPA90, cy+ry, cx+rx, cy+ry*NVG_KAPPA90, cx+rx, cy,
    NVG_BEZIERTO, cx+rx, cy-ry*NVG_KAPPA90, cx+rx*NVG_KAPPA90, cy-ry, cx, cy-ry,
    NVG_BEZIERTO, cx-rx*NVG_KAPPA90, cy-ry, cx-rx, cy-ry*NVG_KAPPA90, cx-rx, cy,
    NVG_CLOSE
  };
  nvg__appendCommands(ctx, vals, NVG_COUNTOF(vals));
}
*)
(*
procedure nvgCircle(ctx: PNVGContext; single cx, single cy, single r)
{
  nvgEllipse(ctx, cx,cy, r,r);
}
*)
(*
procedure nvgDebugDumpPathCache(ctx: PNVGContext)
{
  const NVGpath* path;
  int32 i, j;

  printf("Dumping %d cached paths\n", ctx->cache->npaths);
  for (i = 0; i < ctx->cache->npaths; i++) {
    path = &ctx->cache->paths[i];
    printf(" - Path %d\n", i);
    if (path->nfill) {
      printf("   - fill: %d\n", path->nfill);
      for (j = 0; j < path->nfill; j++)
        printf("%f\t%f\n", path->fill[j].x, path->fill[j].y);
    }
    if (path->nstroke) {
      printf("   - stroke: %d\n", path->nstroke);
      for (j = 0; j < path->nstroke; j++)
        printf("%f\t%f\n", path->stroke[j].x, path->stroke[j].y);
    }
  }
}
*)
(*
procedure nvgFill(ctx: PNVGContext)
{
  NVGstate* state = nvg__getState(ctx);
  const NVGpath* path;
  TNVGPaint fillPaint = state->fill;
  int32 i;

  nvg__flattenPaths(ctx);
  if (ctx->params.edgeAntiAlias && state->shapeAntiAlias)
    nvg__expandFill(ctx, ctx->fringeWidth, NVG_MITER, 2.4f);
  else
    nvg__expandFill(ctx, 0.0f, NVG_MITER, 2.4f);

  // Apply global alpha
  fillPaint.innerColor.a *= state->alpha;
  fillPaint.outerColor.a *= state->alpha;

  ctx->params.renderFill(ctx->params.userPtr, &fillPaint, state->compositeOperation, &state->scissor, ctx->fringeWidth,
               ctx->cache->bounds, ctx->cache->paths, ctx->cache->npaths);

  // Count triangles
  for (i = 0; i < ctx->cache->npaths; i++) {
    path = &ctx->cache->paths[i];
    ctx->fillTriCount += path->nfill-2;
    ctx->fillTriCount += path->nstroke-2;
    ctx->drawCallCount += 2;
  }
}
*)
(*
procedure nvgStroke(ctx: PNVGContext)
{
  NVGstate* state = nvg__getState(ctx);
  single scale = nvg__getAverageScale(state->xform);
  single strokeWidth = nvg__clampf(state->strokeWidth * scale, 0.0f, 200.0f);
  TNVGPaint strokePaint = state->stroke;
  const NVGpath* path;
  int32 i;


  if (strokeWidth < ctx->fringeWidth) {
    // If the stroke width is less than pixel size, use alpha to emulate coverage.
    // Since coverage is area, scale by alpha*alpha.
    single alpha = nvg__clampf(strokeWidth / ctx->fringeWidth, 0.0f, 1.0f);
    strokePaint.innerColor.a *= alpha*alpha;
    strokePaint.outerColor.a *= alpha*alpha;
    strokeWidth = ctx->fringeWidth;
  }

  // Apply global alpha
  strokePaint.innerColor.a *= state->alpha;
  strokePaint.outerColor.a *= state->alpha;

  nvg__flattenPaths(ctx);

  if (ctx->params.edgeAntiAlias && state->shapeAntiAlias)
    nvg__expandStroke(ctx, strokeWidth*0.5f, ctx->fringeWidth, state->lineCap, state->lineJoin, state->miterLimit);
  else
    nvg__expandStroke(ctx, strokeWidth*0.5f, 0.0f, state->lineCap, state->lineJoin, state->miterLimit);

  ctx->params.renderStroke(ctx->params.userPtr, &strokePaint, state->compositeOperation, &state->scissor, ctx->fringeWidth,
               strokeWidth, ctx->cache->paths, ctx->cache->npaths);

  // Count triangles
  for (i = 0; i < ctx->cache->npaths; i++) {
    path = &ctx->cache->paths[i];
    ctx->strokeTriCount += path->nstroke-2;
    ctx->drawCallCount++;
  }
}
*)
(*
// Add fonts
int32 nvgCreateFont(ctx: PNVGContext; const char* name, const char* filename)
{
  return fonsAddFont(ctx->fs, name, filename, 0);
}
*)
(*
int32 nvgCreateFontAtIndex(ctx: PNVGContext; const char* name, const char* filename, const int32 fontIndex)
{
  return fonsAddFont(ctx->fs, name, filename, fontIndex);
}
*)
(*
int32 nvgCreateFontMem(ctx: PNVGContext; const char* name, int8* data, int32 ndata, int32 freeData)
{
  return fonsAddFontMem(ctx->fs, name, data, ndata, freeData, 0);
}
*)
(*
int32 nvgCreateFontMemAtIndex(ctx: PNVGContext; const char* name, int8* data, int32 ndata, int32 freeData, const int32 fontIndex)
{
  return fonsAddFontMem(ctx->fs, name, data, ndata, freeData, fontIndex);
}
*)
(*
int32 nvgFindFont(ctx: PNVGContext; const char* name)
{
  if (name == NULL) return -1;
  return fonsGetFontByName(ctx->fs, name);
}
*)
(*
int32 nvgAddFallbackFontId(ctx: PNVGContext; int32 baseFont, int32 fallbackFont)
{
  if(baseFont == -1 || fallbackFont == -1) return 0;
  return fonsAddFallbackFont(ctx->fs, baseFont, fallbackFont);
}
*)
(*
int32 nvgAddFallbackFont(ctx: PNVGContext; const char* baseFont, const char* fallbackFont)
{
  return nvgAddFallbackFontId(ctx, nvgFindFont(ctx, baseFont), nvgFindFont(ctx, fallbackFont));
}
*)
(*
procedure nvgResetFallbackFontsId(ctx: PNVGContext; int32 baseFont)
{
  fonsResetFallbackFont(ctx->fs, baseFont);
}
*)
(*
procedure nvgResetFallbackFonts(ctx: PNVGContext; const char* baseFont)
{
  nvgResetFallbackFontsId(ctx, nvgFindFont(ctx, baseFont));
}
*)
(*
// State setting
procedure nvgFontSize(ctx: PNVGContext; single size)
{
  NVGstate* state = nvg__getState(ctx);
  state->fontSize = size;
}
*)
(*
procedure nvgFontBlur(ctx: PNVGContext; single blur)
{
  NVGstate* state = nvg__getState(ctx);
  state->fontBlur = blur;
}
*)
(*
procedure nvgTextLetterSpacing(ctx: PNVGContext; single spacing)
{
  NVGstate* state = nvg__getState(ctx);
  state->letterSpacing = spacing;
}
*)
(*
procedure nvgTextLineHeight(ctx: PNVGContext; single lineHeight)
{
  NVGstate* state = nvg__getState(ctx);
  state->lineHeight = lineHeight;
}
*)
(*
procedure nvgTextAlign(ctx: PNVGContext; int32 align)
{
  NVGstate* state = nvg__getState(ctx);
  state->textAlign = align;
}
*)
(*
procedure nvgFontFaceId(ctx: PNVGContext; int32 font)
{
  NVGstate* state = nvg__getState(ctx);
  state->fontId = font;
}
*)
(*
procedure nvgFontFace(ctx: PNVGContext; const char* font)
{
  NVGstate* state = nvg__getState(ctx);
  state->fontId = fonsGetFontByName(ctx->fs, font);
}
*)
(*
static single nvg__quantize(single a, single d)
{
  return ((int32)(a / d + 0.5f)) * d;
}
*)
(*
static single nvg__getFontScale(NVGstate* state)
{
  return nvg__minf(nvg__quantize(nvg__getAverageScale(state->xform), 0.01f), 4.0f);
}
*)
(*
static void nvg__flushTextTexture(ctx: PNVGContext)
{
  int32 dirty[4];

  if (fonsValidateTexture(ctx->fs, dirty)) {
    int32 fontImage = ctx->fontImages[ctx->fontImageIdx];
    // Update texture
    if (fontImage != 0) {
      int32 iw, ih;
      const int8* data = fonsGetTextureData(ctx->fs, &iw, &ih);
      int32 x = dirty[0];
      int32 y = dirty[1];
      int32 w = dirty[2] - dirty[0];
      int32 h = dirty[3] - dirty[1];
      ctx->params.renderUpdateTexture(ctx->params.userPtr, fontImage, x,y, w,h, data);
    }
  }
}
*)
(*
static int32 nvg__allocTextAtlas(ctx: PNVGContext)
{
  int32 iw, ih;
  nvg__flushTextTexture(ctx);
  if (ctx->fontImageIdx >= NVG_MAX_FONTIMAGES-1)
    return 0;
  // if next fontImage already have a texture
  if (ctx->fontImages[ctx->fontImageIdx+1] != 0)
    nvgImageSize(ctx, ctx->fontImages[ctx->fontImageIdx+1], &iw, &ih);
  else { // calculate the new font image size and create it.
    nvgImageSize(ctx, ctx->fontImages[ctx->fontImageIdx], &iw, &ih);
    if (iw > ih)
      ih *= 2;
    else
      iw *= 2;
    if (iw > NVG_MAX_FONTIMAGE_SIZE || ih > NVG_MAX_FONTIMAGE_SIZE)
      iw = ih = NVG_MAX_FONTIMAGE_SIZE;
    ctx->fontImages[ctx->fontImageIdx+1] = ctx->params.renderCreateTexture(ctx->params.userPtr, NVG_TEXTURE_ALPHA, iw, ih, 0, NULL);
  }
  ++ctx->fontImageIdx;
  fonsResetAtlas(ctx->fs, iw, ih);
  return 1;
}
*)
(*
static void nvg__renderText(ctx: PNVGContext; NVGvertex* verts, int32 nverts)
{
  NVGstate* state = nvg__getState(ctx);
  paint: TNVGPaint  = state->fill;

  // Render triangles.
  paint.image = ctx->fontImages[ctx->fontImageIdx];

  // Apply global alpha
  paint.innerColor.a *= state->alpha;
  paint.outerColor.a *= state->alpha;

  ctx->params.renderTriangles(ctx->params.userPtr, &paint, state->compositeOperation, &state->scissor, verts, nverts, ctx->fringeWidth);

  ctx->drawCallCount++;
  ctx->textTriCount += nverts/3;
}
*)
(*
static int32 nvg__isTransformFlipped(const single *xform)
{
  single det = xform[0] * xform[3] - xform[2] * xform[1];
  return( det < 0);
}
*)
(*
single nvgText(ctx: PNVGContext; x, y: single;  const start, stop: PChar)
{
  NVGstate* state = nvg__getState(ctx);
  FONStextIter iter, prevIter;
  FONSquad q;
  NVGvertex* verts;
  single scale = nvg__getFontScale(state) * ctx->devicePxRatio;
  single invscale = 1.0f / scale;
  int32 cverts = 0;
  int32 nverts = 0;
  int32 isFlipped = nvg__isTransformFlipped(state->xform);

  if (end == NULL)
    end = string + strlen(string);

  if (state->fontId == FONS_INVALID) return x;

  fonsSetSize(ctx->fs, state->fontSize*scale);
  fonsSetSpacing(ctx->fs, state->letterSpacing*scale);
  fonsSetBlur(ctx->fs, state->fontBlur*scale);
  fonsSetAlign(ctx->fs, state->textAlign);
  fonsSetFont(ctx->fs, state->fontId);

  cverts = nvg__maxi(2, (int32)(end - string)) * 6; // conservative estimate.
  verts = nvg__allocTempVerts(ctx, cverts);
  if (verts == NULL) return x;

  fonsTextIterInit(ctx->fs, &iter, x*scale, y*scale, string, end, FONS_GLYPH_BITMAP_REQUIRED);
  prevIter = iter;
  while (fonsTextIterNext(ctx->fs, &iter, &q)) {
    single c[4*2];
    if (iter.prevGlyphIndex == -1) { // can not retrieve glyph?
      if (nverts != 0) {
        nvg__renderText(ctx, verts, nverts);
        nverts = 0;
      }
      if (!nvg__allocTextAtlas(ctx))
        break; // no memory :(
      iter = prevIter;
      fonsTextIterNext(ctx->fs, &iter, &q); // try again
      if (iter.prevGlyphIndex == -1) // still can not find glyph?
        break;
    }
    prevIter = iter;
    if(isFlipped) {
      single tmp;

      tmp = q.y0; q.y0 = q.y1; q.y1 = tmp;
      tmp = q.t0; q.t0 = q.t1; q.t1 = tmp;
    }
    // Transform corners.
    nvgTransformPoint(&c[0],&c[1], state->xform, q.x0*invscale, q.y0*invscale);
    nvgTransformPoint(&c[2],&c[3], state->xform, q.x1*invscale, q.y0*invscale);
    nvgTransformPoint(&c[4],&c[5], state->xform, q.x1*invscale, q.y1*invscale);
    nvgTransformPoint(&c[6],&c[7], state->xform, q.x0*invscale, q.y1*invscale);
    // Create triangles
    if (nverts+6 <= cverts) {
      nvg__vset(&verts[nverts], c[0], c[1], q.s0, q.t0); nverts++;
      nvg__vset(&verts[nverts], c[4], c[5], q.s1, q.t1); nverts++;
      nvg__vset(&verts[nverts], c[2], c[3], q.s1, q.t0); nverts++;
      nvg__vset(&verts[nverts], c[0], c[1], q.s0, q.t0); nverts++;
      nvg__vset(&verts[nverts], c[6], c[7], q.s0, q.t1); nverts++;
      nvg__vset(&verts[nverts], c[4], c[5], q.s1, q.t1); nverts++;
    }
  }

  // TODO: add back-end bit to do this just once per frame.
  nvg__flushTextTexture(ctx);

  nvg__renderText(ctx, verts, nverts);

  return iter.nextx / scale;
}
*)
(*
procedure nvgTextBox(ctx: PNVGContext; x, y: single;  single breakRowWidth, const start, stop: PChar)
{
  NVGstate* state = nvg__getState(ctx);
  NVGtextRow rows[2];
  int32 nrows = 0, i;
  int32 oldAlign = state->textAlign;
  int32 halign = state->textAlign & (NVG_ALIGN_LEFT | NVG_ALIGN_CENTER | NVG_ALIGN_RIGHT);
  int32 valign = state->textAlign & (NVG_ALIGN_TOP | NVG_ALIGN_MIDDLE | NVG_ALIGN_BOTTOM | NVG_ALIGN_BASELINE);
  single lineh = 0;

  if (state->fontId == FONS_INVALID) return;

  nvgTextMetrics(ctx, NULL, NULL, &lineh);

  state->textAlign = NVG_ALIGN_LEFT | valign;

  while ((nrows = nvgTextBreakLines(ctx, string, end, breakRowWidth, rows, 2))) {
    for (i = 0; i < nrows; i++) {
      NVGtextRow* row = &rows[i];
      if (halign & NVG_ALIGN_LEFT)
        nvgText(ctx, x, y, row->start, row->end);
      else if (halign & NVG_ALIGN_CENTER)
        nvgText(ctx, x + breakRowWidth*0.5f - row->width*0.5f, y, row->start, row->end);
      else if (halign & NVG_ALIGN_RIGHT)
        nvgText(ctx, x + breakRowWidth - row->width, y, row->start, row->end);
      y += lineh * state->lineHeight;
    }
    string = rows[nrows-1].next;
  }

  state->textAlign = oldAlign;
}
*)
(*
int32 nvgTextGlyphPositions(ctx: PNVGContext; x, y: single;  const start, stop: PChar, NVGglyphPosition* positions, int32 maxPositions)
{
  NVGstate* state = nvg__getState(ctx);
  single scale = nvg__getFontScale(state) * ctx->devicePxRatio;
  single invscale = 1.0f / scale;
  FONStextIter iter, prevIter;
  FONSquad q;
  int32 npos = 0;

  if (state->fontId == FONS_INVALID) return 0;

  if (end == NULL)
    end = string + strlen(string);

  if (string == end)
    return 0;

  fonsSetSize(ctx->fs, state->fontSize*scale);
  fonsSetSpacing(ctx->fs, state->letterSpacing*scale);
  fonsSetBlur(ctx->fs, state->fontBlur*scale);
  fonsSetAlign(ctx->fs, state->textAlign);
  fonsSetFont(ctx->fs, state->fontId);

  fonsTextIterInit(ctx->fs, &iter, x*scale, y*scale, string, end, FONS_GLYPH_BITMAP_OPTIONAL);
  prevIter = iter;
  while (fonsTextIterNext(ctx->fs, &iter, &q)) {
    if (iter.prevGlyphIndex < 0 && nvg__allocTextAtlas(ctx)) { // can not retrieve glyph?
      iter = prevIter;
      fonsTextIterNext(ctx->fs, &iter, &q); // try again
    }
    prevIter = iter;
    positions[npos].str = iter.str;
    positions[npos].x = iter.x * invscale;
    positions[npos].minx = nvg__minf(iter.x, q.x0) * invscale;
    positions[npos].maxx = nvg__maxf(iter.nextx, q.x1) * invscale;
    npos++;
    if (npos >= maxPositions)
      break;
  }

  return npos;
}
*)
(*
enum NVGcodepointType {
  NVG_SPACE,
  NVG_NEWLINE,
  NVG_CHAR,
  NVG_CJK_CHAR,
};
*)
(*
int32 nvgTextBreakLines(ctx: PNVGContext; const start, stop: PChar, single breakRowWidth, NVGtextRow* rows, int32 maxRows)
{
  NVGstate* state = nvg__getState(ctx);
  single scale = nvg__getFontScale(state) * ctx->devicePxRatio;
  single invscale = 1.0f / scale;
  FONStextIter iter, prevIter;
  FONSquad q;
  int32 nrows = 0;
  single rowStartX = 0;
  single rowWidth = 0;
  single rowMinX = 0;
  single rowMaxX = 0;
  const char* rowStart = NULL;
  const char* rowEnd = NULL;
  const char* wordStart = NULL;
  single wordStartX = 0;
  single wordMinX = 0;
  const char* breakEnd = NULL;
  single breakWidth = 0;
  single breakMaxX = 0;
  int32 type = NVG_SPACE, ptype = NVG_SPACE;
  unsigned int32 pcodepoint = 0;

  if (maxRows == 0) return 0;
  if (state->fontId == FONS_INVALID) return 0;

  if (end == NULL)
    end = string + strlen(string);

  if (string == end) return 0;

  fonsSetSize(ctx->fs, state->fontSize*scale);
  fonsSetSpacing(ctx->fs, state->letterSpacing*scale);
  fonsSetBlur(ctx->fs, state->fontBlur*scale);
  fonsSetAlign(ctx->fs, state->textAlign);
  fonsSetFont(ctx->fs, state->fontId);

  breakRowWidth *= scale;

  fonsTextIterInit(ctx->fs, &iter, 0, 0, string, end, FONS_GLYPH_BITMAP_OPTIONAL);
  prevIter = iter;
  while (fonsTextIterNext(ctx->fs, &iter, &q)) {
    if (iter.prevGlyphIndex < 0 && nvg__allocTextAtlas(ctx)) { // can not retrieve glyph?
      iter = prevIter;
      fonsTextIterNext(ctx->fs, &iter, &q); // try again
    }
    prevIter = iter;
    switch (iter.codepoint) {
      case 9:      // \t
      case 11:    // \v
      case 12:    // \f
      case 32:    // space
      case $00a0:  // NBSP
        type = NVG_SPACE;
        break;
      case 10:    // \n
        type = pcodepoint == 13 ? NVG_SPACE : NVG_NEWLINE;
        break;
      case 13:    // \r
        type = pcodepoint == 10 ? NVG_SPACE : NVG_NEWLINE;
        break;
      case $0085:  // NEL
        type = NVG_NEWLINE;
        break;
      default:
        if ((iter.codepoint >= $4E00 && iter.codepoint <= $9FFF) ||
          (iter.codepoint >= $3000 && iter.codepoint <= $30FF) ||
          (iter.codepoint >= $FF00 && iter.codepoint <= $FFEF) ||
          (iter.codepoint >= $1100 && iter.codepoint <= $11FF) ||
          (iter.codepoint >= $3130 && iter.codepoint <= $318F) ||
          (iter.codepoint >= $AC00 && iter.codepoint <= $D7AF))
          type = NVG_CJK_CHAR;
        else
          type = NVG_CHAR;
        break;
    }

    if (type == NVG_NEWLINE) {
      // Always handle new lines.
      rows[nrows].start = rowStart != NULL ? rowStart : iter.str;
      rows[nrows].end = rowEnd != NULL ? rowEnd : iter.str;
      rows[nrows].width = rowWidth * invscale;
      rows[nrows].minx = rowMinX * invscale;
      rows[nrows].maxx = rowMaxX * invscale;
      rows[nrows].next = iter.next;
      nrows++;
      if (nrows >= maxRows)
        return nrows;
      // Set null break point
      breakEnd = rowStart;
      breakWidth = 0.0;
      breakMaxX = 0.0;
      // Indicate to skip the white space at the beginning of the row.
      rowStart = NULL;
      rowEnd = NULL;
      rowWidth = 0;
      rowMinX = rowMaxX = 0;
    } else {
      if (rowStart == NULL) {
        // Skip white space until the beginning of the line
        if (type == NVG_CHAR || type == NVG_CJK_CHAR) {
          // The current char is the row so far
          rowStartX = iter.x;
          rowStart = iter.str;
          rowEnd = iter.next;
          rowWidth = iter.nextx - rowStartX;
          rowMinX = q.x0 - rowStartX;
          rowMaxX = q.x1 - rowStartX;
          wordStart = iter.str;
          wordStartX = iter.x;
          wordMinX = q.x0 - rowStartX;
          // Set null break point
          breakEnd = rowStart;
          breakWidth = 0.0;
          breakMaxX = 0.0;
        }
      } else {
        single nextWidth = iter.nextx - rowStartX;

        // track last non-white space character
        if (type == NVG_CHAR || type == NVG_CJK_CHAR) {
          rowEnd = iter.next;
          rowWidth = iter.nextx - rowStartX;
          rowMaxX = q.x1 - rowStartX;
        }
        // track last end of a word
        if (((ptype == NVG_CHAR || ptype == NVG_CJK_CHAR) && type == NVG_SPACE) || type == NVG_CJK_CHAR) {
          breakEnd = iter.str;
          breakWidth = rowWidth;
          breakMaxX = rowMaxX;
        }
        // track last beginning of a word
        if ((ptype == NVG_SPACE && (type == NVG_CHAR || type == NVG_CJK_CHAR)) || type == NVG_CJK_CHAR) {
          wordStart = iter.str;
          wordStartX = iter.x;
          wordMinX = q.x0;
        }

        // Break to new line when a character is beyond break width.
        if ((type == NVG_CHAR || type == NVG_CJK_CHAR) && nextWidth > breakRowWidth) {
          // The run length is too long, need to break to new line.
          if (breakEnd == rowStart) {
            // The current word is longer than the row length, just break it from here.
            rows[nrows].start = rowStart;
            rows[nrows].end = iter.str;
            rows[nrows].width = rowWidth * invscale;
            rows[nrows].minx = rowMinX * invscale;
            rows[nrows].maxx = rowMaxX * invscale;
            rows[nrows].next = iter.str;
            nrows++;
            if (nrows >= maxRows)
              return nrows;
            rowStartX = iter.x;
            rowStart = iter.str;
            rowEnd = iter.next;
            rowWidth = iter.nextx - rowStartX;
            rowMinX = q.x0 - rowStartX;
            rowMaxX = q.x1 - rowStartX;
            wordStart = iter.str;
            wordStartX = iter.x;
            wordMinX = q.x0 - rowStartX;
          } else {
            // Break the line from the end of the last word, and start new line from the beginning of the new.
            rows[nrows].start = rowStart;
            rows[nrows].end = breakEnd;
            rows[nrows].width = breakWidth * invscale;
            rows[nrows].minx = rowMinX * invscale;
            rows[nrows].maxx = breakMaxX * invscale;
            rows[nrows].next = wordStart;
            nrows++;
            if (nrows >= maxRows)
              return nrows;
            // Update row
            rowStartX = wordStartX;
            rowStart = wordStart;
            rowEnd = iter.next;
            rowWidth = iter.nextx - rowStartX;
            rowMinX = wordMinX - rowStartX;
            rowMaxX = q.x1 - rowStartX;
          }
          // Set null break point
          breakEnd = rowStart;
          breakWidth = 0.0;
          breakMaxX = 0.0;
        }
      }
    }

    pcodepoint = iter.codepoint;
    ptype = type;
  }

  // Break the line from the end of the last word, and start new line from the beginning of the new.
  if (rowStart != NULL) {
    rows[nrows].start = rowStart;
    rows[nrows].end = rowEnd;
    rows[nrows].width = rowWidth * invscale;
    rows[nrows].minx = rowMinX * invscale;
    rows[nrows].maxx = rowMaxX * invscale;
    rows[nrows].next = end;
    nrows++;
  }

  return nrows;
}
*)
(*
single nvgTextBounds(ctx: PNVGContext; x, y: single;  const start, stop: PChar, single* bounds)
{
  NVGstate* state = nvg__getState(ctx);
  single scale = nvg__getFontScale(state) * ctx->devicePxRatio;
  single invscale = 1.0f / scale;
  single width;

  if (state->fontId == FONS_INVALID) return 0;

  fonsSetSize(ctx->fs, state->fontSize*scale);
  fonsSetSpacing(ctx->fs, state->letterSpacing*scale);
  fonsSetBlur(ctx->fs, state->fontBlur*scale);
  fonsSetAlign(ctx->fs, state->textAlign);
  fonsSetFont(ctx->fs, state->fontId);

  width = fonsTextBounds(ctx->fs, x*scale, y*scale, string, end, bounds);
  if (bounds != NULL) {
    // Use line bounds for height.
    fonsLineBounds(ctx->fs, y*scale, &bounds[1], &bounds[3]);
    bounds[0] *= invscale;
    bounds[1] *= invscale;
    bounds[2] *= invscale;
    bounds[3] *= invscale;
  }
  return width * invscale;
}
*)
(*
procedure nvgTextBoxBounds(ctx: PNVGContext; x, y: single;  single breakRowWidth, const start, stop: PChar, single* bounds)
{
  NVGstate* state = nvg__getState(ctx);
  NVGtextRow rows[2];
  single scale = nvg__getFontScale(state) * ctx->devicePxRatio;
  single invscale = 1.0f / scale;
  int32 nrows = 0, i;
  int32 oldAlign = state->textAlign;
  int32 halign = state->textAlign & (NVG_ALIGN_LEFT | NVG_ALIGN_CENTER | NVG_ALIGN_RIGHT);
  int32 valign = state->textAlign & (NVG_ALIGN_TOP | NVG_ALIGN_MIDDLE | NVG_ALIGN_BOTTOM | NVG_ALIGN_BASELINE);
  single lineh = 0, rminy = 0, rmaxy = 0;
  single minx, miny, maxx, maxy;

  if (state->fontId == FONS_INVALID) {
    if (bounds != NULL)
      bounds[0] = bounds[1] = bounds[2] = bounds[3] = 0.0f;
    return;
  }

  nvgTextMetrics(ctx, NULL, NULL, &lineh);

  state->textAlign = NVG_ALIGN_LEFT | valign;

  minx = maxx = x;
  miny = maxy = y;

  fonsSetSize(ctx->fs, state->fontSize*scale);
  fonsSetSpacing(ctx->fs, state->letterSpacing*scale);
  fonsSetBlur(ctx->fs, state->fontBlur*scale);
  fonsSetAlign(ctx->fs, state->textAlign);
  fonsSetFont(ctx->fs, state->fontId);
  fonsLineBounds(ctx->fs, 0, &rminy, &rmaxy);
  rminy *= invscale;
  rmaxy *= invscale;

  while ((nrows = nvgTextBreakLines(ctx, string, end, breakRowWidth, rows, 2))) {
    for (i = 0; i < nrows; i++) {
      NVGtextRow* row = &rows[i];
      single rminx, rmaxx, dx = 0;
      // Horizontal bounds
      if (halign & NVG_ALIGN_LEFT)
        dx = 0;
      else if (halign & NVG_ALIGN_CENTER)
        dx = breakRowWidth*0.5f - row->width*0.5f;
      else if (halign & NVG_ALIGN_RIGHT)
        dx = breakRowWidth - row->width;
      rminx = x + row->minx + dx;
      rmaxx = x + row->maxx + dx;
      minx = nvg__minf(minx, rminx);
      maxx = nvg__maxf(maxx, rmaxx);
      // Vertical bounds.
      miny = nvg__minf(miny, y + rminy);
      maxy = nvg__maxf(maxy, y + rmaxy);

      y += lineh * state->lineHeight;
    }
    string = rows[nrows-1].next;
  }

  state->textAlign = oldAlign;

  if (bounds != NULL) {
    bounds[0] = minx;
    bounds[1] = miny;
    bounds[2] = maxx;
    bounds[3] = maxy;
  }
}
*)
(*
procedure nvgTextMetrics(ctx: PNVGContext; single* ascender, single* descender, single* lineh)
{
  NVGstate* state = nvg__getState(ctx);
  single scale = nvg__getFontScale(state) * ctx->devicePxRatio;
  single invscale = 1.0f / scale;

  if (state->fontId == FONS_INVALID) return;

  fonsSetSize(ctx->fs, state->fontSize*scale);
  fonsSetSpacing(ctx->fs, state->letterSpacing*scale);
  fonsSetBlur(ctx->fs, state->fontBlur*scale);
  fonsSetAlign(ctx->fs, state->textAlign);
  fonsSetFont(ctx->fs, state->fontId);

  fonsVertMetrics(ctx->fs, ascender, descender, lineh);
  if (ascender != NULL)
    *ascender *= invscale;
  if (descender != NULL)
    *descender *= invscale;
  if (lineh != NULL)
    *lineh *= invscale;
}
// vim: ft=c nu noet ts=4
*)

end.
