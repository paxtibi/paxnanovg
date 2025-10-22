unit fontstash;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, gl, freetypehdyn;

const
  // FontStash constants (from fontstash.h)
  FONS_INVALID = -1;
  FONS_ZERO_TOPLEFT = 1 shl 0;
  FONS_ZERO_BOTTOMLEFT = 1 shl 1;
  FONS_ALIGN_LEFT = 1 shl 0;
  FONS_ALIGN_CENTER = 1 shl 1;
  FONS_ALIGN_RIGHT = 1 shl 2;
  FONS_ALIGN_TOP = 1 shl 3;
  FONS_ALIGN_MIDDLE = 1 shl 4;
  FONS_ALIGN_BOTTOM = 1 shl 5;
  FONS_ALIGN_BASELINE = 1 shl 6;
  FONS_SCRATCH_BUF_SIZE = 64000;
  FONS_HASH_LUT_SIZE = 256;
  FONS_INIT_FONTS = 4;
  FONS_INIT_GLYPHS = 256;
  FONS_INIT_ATLAS_NODES = 256;
  FONS_ATLAS_INIT_SIZE = 512;
  FONS_MAX_STATES = 20;

  // FreeType error codes used in FontStash (from fterrdef.h)
  FT_Err_Ok = $00;
  FT_Err_Cannot_Open_Resource = $01;
  FT_Err_Out_Of_Memory = $40;
  FT_Err_Invalid_Argument = $06;
  FT_Err_Too_Many_Glyphs = $1B;
  FT_Err_Invalid_CharMap_Handle = $26;
  FT_Err_Unimplemented_Feature = $07;

type
  // Forward declarations
  PFONSContext = ^TFONSContext;
  PFONSFont = ^TFONSFont;
  PFONSState = ^TFONSState;
  PFONSParams = ^TFONSParams;
  PFONSTextIter = ^TFONSTextIter;
  PFONSQuad = ^TFONSQuad;

  // Configuration parameters
  TFONSParams = record
    Width, Height: integer;
    flags: byte;
    userPtr: Pointer;
  end;

  // Rendering state
  TFONSState = record
    size: single;
    color: longword;
    blur: single;
    spacing: single;
    font: integer;
    align: integer;
  end;

  // Quad structure for glyph rendering
  TFONSQuad = record
    x0, y0, s0, t0: single;
    x1, y1, s1, t1: single;
  end;

  // Text iterator for rendering or measuring
  TFONSTextIter = record
    x, y: single;
    nextx, nexty: single;
    scale: single;
    spacing: single;
    font: PFONSFont;
    prevGlyphIndex: integer;
    codepoint: longword;
    istr, Next: pansichar;
    endptr: pansichar;
    utf8state: byte;
    bitmapOption: byte;
    isize: smallint;  // Font size (in pixels)
    iblur: smallint;  // Blur amount
  end;

  // Atlas node for skyline packing
  TFONSAtlasNode = record
    x, y, Width: smallint;
  end;

  // Texture atlas
  TFONSAtlas = record
    Width, Height: integer;
    nodes: array of TFONSAtlasNode;
    nnodes: integer;
    dirtyRect: array[0..3] of integer;
  end;

  // Glyph structure
  PFONSGlyph = ^TFONSGlyph;

  TFONSGlyph = record
    codepoint: longword;
    index: integer;
    font: PFONSFont;
    x, y: integer;
    Width, Height: integer;
    xoff, yoff: integer;
    xadvance: integer;
    x0, y0, x1, y1: single;
    s0, t0, s1, t1: single;
    Next: integer;
  end;

  // Font structure
  TFONSFont = record
    Name: string;
    ft: PFT_Face;
    Data: pbyte;
    dataSize: integer;
    freeData: byte;
    ascender: single;
    descender: single;
    Height: single;
    glyphs: array of TFONSGlyph;
    nglyphs: integer;
    cglyphs: integer;
    lut: array[0..FONS_HASH_LUT_SIZE - 1] of integer;
    nfallbacks: integer;
    fallbacks: array of integer;
  end;

  // Main context
  TFONSContext = record
    params: TFONSParams;
    itw, ith: single;
    texData: array of byte;
    dirtyRect: array[0..3] of integer;
    fonts: array of PFONSFont;
    nfonts: integer;
    atlas: TFONSAtlas;
    cfonts: integer;
    states: array[0..FONS_MAX_STATES - 1] of TFONSState;
    nstates: integer;
    handleError: procedure(error: FT_Error; userPtr: Pointer); cdecl;
    renderCreate: function(userPtr: Pointer; Width, Height: integer): integer; cdecl;
    renderUpdate: procedure(userPtr: Pointer; rect: PInteger; Data: pbyte); cdecl;
    renderDraw: procedure(userPtr: Pointer; verts, tcoords: PSingle; colors: PLongWord; nverts: integer); cdecl;
    renderDelete: procedure(userPtr: Pointer); cdecl;
    userPtr: Pointer;
    scratch: array[0..FONS_SCRATCH_BUF_SIZE - 1] of byte;
    nscratch: integer;
    ftlib: PFT_Library;
  end;

{ Exported functions }
function fonsCreate(Width, Height: integer; flags: integer = 0): PFONSContext;
procedure fonsFree(ctx: PFONSContext);
function fonsAddFont(ctx: PFONSContext; Name, path: pansichar): integer;
function fonsAddFontMem(ctx: PFONSContext; Name: pansichar; Data: pbyte; size: integer; freeData: integer; fontIndex: integer): integer;
function fonsGetFontByName(ctx: PFONSContext; Name: pansichar): integer;
procedure fonsSetSize(ctx: PFONSContext; size: single);
procedure fonsSetColor(ctx: PFONSContext; color: longword);
procedure fonsSetSpacing(ctx: PFONSContext; spacing: single);
procedure fonsSetBlur(ctx: PFONSContext; blur: single);
procedure fonsSetAlign(ctx: PFONSContext; align: integer);
procedure fonsSetFont(ctx: PFONSContext; font: integer);
procedure fonsPushState(ctx: PFONSContext);
procedure fonsPopState(ctx: PFONSContext);
procedure fonsClearState(ctx: PFONSContext);
function fonsTextIterInit(ctx: PFONSContext; iter: PFONSTextIter; x, y: single; str, endptr: pansichar): integer;
function fonsTextIterNext(ctx: PFONSContext; iter: PFONSTextIter; quad: PFONSQuad): integer;
function fonsTextBounds(ctx: PFONSContext; x, y: single; str, endptr: pansichar; bounds: PSingle): single;
function fonsDrawText(ctx: PFONSContext; x, y: single; str, endptr: pansichar; bounds: PSingle): single;
procedure fonsResetAtlas(ctx: PFONSContext; Width, Height: integer);
procedure fonsGetAtlasSize(ctx: PFONSContext; out Width, Height: integer);
function fonsAddFallbackFont(ctx: PFONSContext; base, fallback: integer): integer;

implementation

uses
  Math;

function FT_New_Memory_Face(library_: PFT_Library; file_base: Pointer; file_size: FT_Long; face_index: FT_Long; out aface: PFT_Face): FT_Error; cdecl; external FreeTypeDLL;

{ Internal functions }

procedure fons__initAtlas(var atlas: TFONSAtlas; Width, Height: integer);
begin
  atlas.Width := Width;
  atlas.Height := Height;
  atlas.nnodes := 0;
  SetLength(atlas.nodes, FONS_INIT_ATLAS_NODES);
  atlas.nodes[0].x := 0;
  atlas.nodes[0].y := 0;
  atlas.nodes[0].Width := Width;
  atlas.nnodes := 1;
end;

procedure fons__atlasAddSkylineLevel(var atlas: TFONSAtlas; idx, x, y, w, h: integer);
var
  i: integer;
  x0, y0, x1, y1: integer;
begin
  if atlas.nnodes + 1 > Length(atlas.nodes) then
    SetLength(atlas.nodes, atlas.nnodes * 2);

  for i := atlas.nnodes - 1 downto idx do
    atlas.nodes[i + 1] := atlas.nodes[i];

  atlas.nodes[idx].x := x;
  atlas.nodes[idx].y := y;
  atlas.nodes[idx].Width := w;
  Inc(atlas.nnodes);

  i := idx + 1;
  while i < atlas.nnodes do
  begin
    x0 := atlas.nodes[i - 1].x;
    y0 := atlas.nodes[i - 1].y;
    x1 := atlas.nodes[i].x;
    y1 := atlas.nodes[i].y;
    if x0 + atlas.nodes[i - 1].Width >= x1 then
    begin
      atlas.nodes[i - 1].Width := x1 + atlas.nodes[i].Width - x0;
      atlas.nodes[i - 1].x := x0;
      atlas.nodes[i - 1].y := y0;
      Dec(atlas.nnodes);
    end
    else
      Inc(i);
  end;
end;

function fons__atlasAddRect(var atlas: TFONSAtlas; rw, rh: integer; out rx, ry: integer): integer;
var
  i: integer;
  besth, bestw, besti, x, y: integer;
begin
  besth := atlas.Height;
  bestw := atlas.Width;
  besti := -1;
  rx := -1;
  ry := -1;

  for i := 0 to atlas.nnodes - 1 do
  begin
    if atlas.nodes[i].y + rh <= atlas.Height then
    begin
      if (rw <= atlas.nodes[i].Width) and (atlas.nodes[i].Width <= bestw) then
      begin
        besti := i;
        bestw := atlas.nodes[i].Width;
        rx := atlas.nodes[i].x;
        ry := atlas.nodes[i].y;
      end;
    end;
  end;

  if besti = -1 then
    Exit(0);

  fons__atlasAddSkylineLevel(atlas, besti, rx, ry + rh, rw, rh);
  Result := 1;
end;

procedure fons__atlasReset(var atlas: TFONSAtlas; Width, Height: integer);
begin
  fons__initAtlas(atlas, Width, Height);
  FillChar(atlas.dirtyRect, SizeOf(atlas.dirtyRect), 0);
end;

function fons__atlasExpand(var atlas: TFONSAtlas; w, h: integer): integer;
begin
  if (w > atlas.Width) or (h > atlas.Height) then
  begin
    atlas.Width := w;
    atlas.Height := h;
    fons__atlasReset(atlas, w, h);
    Result := 1;
  end
  else
    Result := 0;
end;

function fons__addGlyph(ctx: PFONSContext; font: PFONSFont; codepoint: longword; size: single; blur: single; glyphIndex: integer; bitmapOption: byte): PFONSGlyph;
var
  err: FT_Error;
  glyph: PFONSGlyph;
  bitmap: FT_Bitmap;
  gx, gy, gw, gh: integer;
  scale: single;
  loadFlags: integer;
begin
  if font^.nglyphs >= font^.cglyphs then
  begin
    font^.cglyphs := ifthen(font^.cglyphs = 0, FONS_INIT_GLYPHS, font^.cglyphs * 2);
    SetLength(font^.glyphs, font^.cglyphs);
  end;

  glyph := @font^.glyphs[font^.nglyphs];
  FillChar(glyph^, SizeOf(TFONSGlyph), 0);
  glyph^.codepoint := codepoint;
  glyph^.index := glyphIndex;
  glyph^.font := font;

  scale := size / 64.0;
  err := FT_Set_Pixel_Sizes(font^.ft, 0, Round(size));
  if err <> FT_Err_Ok then
  begin
    if Assigned(ctx^.handleError) then
      ctx^.handleError(err, ctx^.userPtr);
    Exit(nil);
  end;

  loadFlags := FT_LOAD_RENDER;
  if bitmapOption = 0 then
    loadFlags := loadFlags or FT_LOAD_MONOCHROME;
  err := FT_Load_Glyph(font^.ft, glyphIndex, loadFlags);
  if err <> FT_Err_Ok then
  begin
    if Assigned(ctx^.handleError) then
      ctx^.handleError(err, ctx^.userPtr);
    Exit(nil);
  end;

  bitmap := font^.ft^.glyph^.bitmap;
  gw := bitmap.Width + 2;
  gh := bitmap.rows + 2;

  if fons__atlasAddRect(ctx^.atlas, gw, gh, gx, gy) = 0 then
  begin
    if Assigned(ctx^.handleError) then
      ctx^.handleError(FT_Err_Out_Of_Memory, ctx^.userPtr);
    Exit(nil);
  end;

  glyph^.x := gx + 1;
  glyph^.y := gy + 1;
  glyph^.Width := bitmap.Width;
  glyph^.Height := bitmap.rows;
  glyph^.xoff := font^.ft^.glyph^.bitmap_left;
  glyph^.yoff := font^.ft^.glyph^.bitmap_top - bitmap.rows;
  glyph^.xadvance := font^.ft^.glyph^.metrics.horiAdvance;
  glyph^.s0 := (gx + 1) * ctx^.itw;
  glyph^.t0 := (gy + 1) * ctx^.ith;
  glyph^.s1 := (gx + 1 + bitmap.Width) * ctx^.itw;
  glyph^.t1 := (gy + 1 + bitmap.rows) * ctx^.ith;

  if ctx^.dirtyRect[0] = 0 then
    ctx^.dirtyRect[0] := gx
  else
    ctx^.dirtyRect[0] := Min(ctx^.dirtyRect[0], gx);
  if ctx^.dirtyRect[1] = 0 then
    ctx^.dirtyRect[1] := gy
  else
    ctx^.dirtyRect[1] := Min(ctx^.dirtyRect[1], gy);
  ctx^.dirtyRect[2] := Max(ctx^.dirtyRect[2], gx + gw);
  ctx^.dirtyRect[3] := Max(ctx^.dirtyRect[3], gy + gh);

  if Assigned(ctx^.renderUpdate) then
    ctx^.renderUpdate(ctx^.userPtr, @ctx^.dirtyRect[0], bitmap.buffer);

  Inc(font^.nglyphs);
  Result := glyph;
end;

function fons__getGlyph(ctx: PFONSContext; font: PFONSFont; codepoint: longword; size, blur: single; bitmapOption: byte): PFONSGlyph;
var
  i, glyphIndex: integer;
  hash: longword;
begin
  if font = nil then Exit(nil);

  hash := codepoint mod FONS_HASH_LUT_SIZE;
  for i := font^.lut[hash] to font^.nglyphs - 1 do
  begin
    if font^.glyphs[i].codepoint = codepoint then
      Exit(@font^.glyphs[i]);
  end;

  glyphIndex := FT_Get_Char_Index(font^.ft, codepoint);
  if glyphIndex = 0 then
  begin
    if Assigned(ctx^.handleError) then
      ctx^.handleError(FT_Err_Too_Many_Glyphs, ctx^.userPtr);
    Exit(nil);
  end;

  Result := fons__addGlyph(ctx, font, codepoint, size, blur, glyphIndex, bitmapOption);
  if Result <> nil then
    font^.lut[hash] := font^.nglyphs - 1;
end;

procedure fons__getQuad(ctx: PFONSContext; font: PFONSFont; prevGlyphIndex: integer; glyph: PFONSGlyph; scale, spacing: single; var nextx, nexty: single; quad: PFONSQuad);
var
  advance: single;
  kern: FT_Vector;
  err: FT_Error;
begin
  advance := glyph^.xadvance * scale;

  if prevGlyphIndex <> -1 then
  begin
    err := FT_Get_Kerning(font^.ft, prevGlyphIndex, glyph^.index, FT_KERNING_DEFAULT, kern);
    if err = FT_Err_Ok then
      advance := advance + kern.x * scale;
  end;

  if quad <> nil then
  begin
    quad^.x0 := nextx + glyph^.xoff * scale;
    quad^.y0 := nexty + glyph^.yoff * scale;
    quad^.x1 := quad^.x0 + glyph^.Width * scale;
    quad^.y1 := quad^.y0 + glyph^.Height * scale;
    quad^.s0 := glyph^.s0;
    quad^.t0 := glyph^.t0;
    quad^.s1 := glyph^.s1;
    quad^.t1 := glyph^.t1;
  end;

  nextx := nextx + advance + spacing;
end;

function fons__decUtf8(var state: byte; var codepoint: longword; val: byte): integer;
begin
  if state = 0 then
  begin
    if val < $80 then
    begin
      codepoint := val;
      Exit(1);
    end
    else if (val and $E0) = $C0 then
    begin
      codepoint := (val and $1F) shl 6;
      state := 1;
      Exit(0);
    end
    else if (val and $F0) = $E0 then
    begin
      codepoint := (val and $0F) shl 12;
      state := 2;
      Exit(0);
    end
    else
    begin
      state := 0;
      Exit(-1);
    end;
  end
  else if state = 1 then
  begin
    if (val and $C0) = $80 then
    begin
      codepoint := codepoint or (val and $3F);
      state := 0;
      Exit(1);
    end;
    state := 0;
    Exit(-1);
  end
  else if state = 2 then
  begin
    if (val and $C0) = $80 then
    begin
      codepoint := codepoint or ((val and $3F) shl 6);
      state := 1;
      Exit(0);
    end;
    state := 0;
    Exit(-1);
  end;
  Exit(-1);
end;

// **FIX #2+7: ALLOCAZIONE FONT**
function fons__allocFont(ctx: PFONSContext): integer;
var
  font: PFONSFont;
begin
  if ctx^.nfonts >= ctx^.cfonts then
  begin
    ctx^.cfonts := Max(ctx^.cfonts * 2, FONS_INIT_FONTS);
    SetLength(ctx^.fonts, ctx^.cfonts);
  end;
  New(font);
  ctx^.fonts[ctx^.nfonts] := font;
  Result := ctx^.nfonts;
  Inc(ctx^.nfonts);
end;

procedure fons__freeFont(font: PFONSFont);
begin
  if font^.ft <> nil then FT_Done_Face(font^.ft);
  if font^.freeData <> 0 then FreeMem(font^.Data);
  Dispose(font);
end;

function fons__tt_loadFont(ctx: PFONSContext; font: PFONSFont; Data: pbyte; dataSize: integer; fontIndex: integer): boolean;
var
  err: FT_Error;
begin
  Result := False;
  err := FT_New_Memory_Face(ctx^.ftlib, Data, dataSize, fontIndex, font^.ft);
  if err <> FT_Err_Ok then Exit;

  font^.ascender := font^.ft^.ascender / 64.0;
  font^.descender := font^.ft^.descender / 64.0;
  font^.Height := (font^.ft^.ascender - font^.ft^.descender + font^.ft^.Height) / 64.0;
  Result := True;
end;

function fons__tt_getFontVMetrics(font: PFONSFont; out ascent, descent, lineGap: integer): boolean;
begin
  ascent := Round(font^.ft^.ascender shr 6);
  descent := Round(font^.ft^.descender shr 6);
  lineGap := Round(font^.ft^.Height shr 6);
  Result := True;
end;

function fonsCreate(Width, Height: integer; flags: integer): PFONSContext;
var
  ctx: PFONSContext;
  err: FT_Error;
begin
  New(ctx);
  FillChar(ctx^, SizeOf(TFONSContext), 0);

  ctx^.params.Width := Width;
  ctx^.params.Height := Height;
  ctx^.params.flags := flags;
  ctx^.itw := 1.0 / Width;
  ctx^.ith := 1.0 / Height;

  err := FT_Init_FreeType(ctx^.ftlib);
  if err <> FT_Err_Ok then
  begin
    if Assigned(ctx^.handleError) then
      ctx^.handleError(err, ctx^.userPtr);
    Dispose(ctx);
    Exit(nil);
  end;

  fons__initAtlas(ctx^.atlas, Width, Height);
  SetLength(ctx^.texData, Width * Height);
  FillChar(ctx^.texData[0], Width * Height, 0);

  SetLength(ctx^.fonts, FONS_INIT_FONTS);
  ctx^.cfonts := FONS_INIT_FONTS;
  ctx^.nfonts := 0;

  fonsPushState(ctx);
  Result := ctx;
end;

procedure fonsFree(ctx: PFONSContext);
var
  i: integer;
begin
  if ctx = nil then Exit;

  for i := 0 to ctx^.nfonts - 1 do
  begin
    if ctx^.fonts[i] <> nil then
    begin
      if ctx^.fonts[i]^.ft <> nil then
        FT_Done_Face(ctx^.fonts[i]^.ft);
      if ctx^.fonts[i]^.freeData <> 0 then
        FreeMem(ctx^.fonts[i]^.Data);
      Dispose(ctx^.fonts[i]);
    end;
  end;

  if Assigned(ctx^.renderDelete) then
    ctx^.renderDelete(ctx^.userPtr);
  SetLength(ctx^.texData, 0);
  FT_Done_FreeType(ctx^.ftlib);
  Dispose(ctx);
end;

function fonsAddFont(ctx: PFONSContext; Name, path: pansichar): integer;
var
  font: PFONSFont;
  err: FT_Error;
begin
  if ctx = nil then
  begin
    if Assigned(ctx^.handleError) then
      ctx^.handleError(FT_Err_Invalid_Argument, ctx^.userPtr);
    Exit(FONS_INVALID);
  end;

  New(font);
  FillChar(font^, SizeOf(TFONSFont), 0);
  font^.Name := Copy(string(Name), 1, 63);
  SetLength(font^.glyphs, FONS_INIT_GLYPHS);
  font^.cglyphs := FONS_INIT_GLYPHS;
  FillChar(font^.lut[0], FONS_HASH_LUT_SIZE * SizeOf(integer), $FF);

  err := FT_New_Face(ctx^.ftlib, path, 0, font^.ft);
  if err <> FT_Err_Ok then
  begin
    if Assigned(ctx^.handleError) then
      ctx^.handleError(err, ctx^.userPtr);
    Dispose(font);
    Exit(FONS_INVALID);
  end;

  font^.ascender := font^.ft^.ascender / 64.0;
  font^.descender := font^.ft^.descender / 64.0;
  font^.Height := (font^.ft^.ascender - font^.ft^.descender + font^.ft^.Height) / 64.0;

  if ctx^.nfonts >= ctx^.cfonts then
  begin
    ctx^.cfonts := ctx^.cfonts * 2;
    SetLength(ctx^.fonts, ctx^.cfonts);
  end;
  ctx^.fonts[ctx^.nfonts] := font;
  Inc(ctx^.nfonts);
  Result := ctx^.nfonts - 1;
end;


function fonsAddFontMem(ctx: PFONSContext; Name: pansichar; Data: pbyte; size: integer; freeData: integer; fontIndex: integer): integer;
var
  i, idx, ascent, descent, lineGap: integer;
  font: PFONSFont;
label
  error;
begin
  idx := fons__allocFont(ctx);  // **FIX**
  if idx = FONS_INVALID then Exit(FONS_INVALID);

  font := ctx^.fonts[idx];  // **FIX**

  font^.Name := Copy(string(Name), 1, 63);  // **FIX**

  // Init hash lookup
  for i := 0 to FONS_HASH_LUT_SIZE - 1 do  // **FIX**
    font^.lut[i] := FONS_INVALID;  // **FIX**

  // Read font data
  font^.dataSize := size;
  font^.Data := Data;
  font^.freeData := freeData;

  // Init font
  ctx^.nscratch := 0;
  if not fons__tt_loadFont(ctx, font, Data, size, fontIndex) then goto error;  // **FIX**

  // Store normalized line height
  fons__tt_getFontVMetrics(font, ascent, descent, lineGap);  // **FIX**
  ascent += lineGap;
  lineGap := ascent - descent;
  font^.ascender := ascent / lineGap;
  font^.descender := descent / lineGap;
  font^.Height := font^.ascender - font^.descender;

  Result := idx;
  Exit;

  error:
    fons__freeFont(font);  // **FIX**
  Dec(ctx^.nfonts);
  Result := FONS_INVALID;
end;

function fonsGetFontByName(ctx: PFONSContext; Name: pansichar): integer;
var
  i: integer;
begin
  for i := 0 to ctx^.nfonts - 1 do
    if SameText(ctx^.fonts[i]^.Name, string(Name)) then
      Exit(i);
  Exit(FONS_INVALID);
end;

procedure fonsSetSize(ctx: PFONSContext; size: single);
begin
  if (ctx = nil) or (ctx^.nstates = 0) then Exit;
  ctx^.states[ctx^.nstates - 1].size := size;
end;

procedure fonsSetColor(ctx: PFONSContext; color: longword);
begin
  if (ctx = nil) or (ctx^.nstates = 0) then Exit;
  ctx^.states[ctx^.nstates - 1].color := color;
end;

procedure fonsSetSpacing(ctx: PFONSContext; spacing: single);
begin
  if (ctx = nil) or (ctx^.nstates = 0) then Exit;
  ctx^.states[ctx^.nstates - 1].spacing := spacing;
end;

procedure fonsSetBlur(ctx: PFONSContext; blur: single);
begin
  if (ctx = nil) or (ctx^.nstates = 0) then Exit;
  ctx^.states[ctx^.nstates - 1].blur := blur;
end;

procedure fonsSetAlign(ctx: PFONSContext; align: integer);
begin
  if (ctx = nil) or (ctx^.nstates = 0) then Exit;
  ctx^.states[ctx^.nstates - 1].align := align;
end;

procedure fonsSetFont(ctx: PFONSContext; font: integer);
begin
  if (ctx = nil) or (ctx^.nstates = 0) then Exit;
  ctx^.states[ctx^.nstates - 1].font := font;
end;

procedure fonsPushState(ctx: PFONSContext);
begin
  if ctx = nil then Exit;
  if ctx^.nstates >= FONS_MAX_STATES then Exit;
  if ctx^.nstates > 0 then
    ctx^.states[ctx^.nstates] := ctx^.states[ctx^.nstates - 1];
  Inc(ctx^.nstates);
end;

procedure fonsPopState(ctx: PFONSContext);
begin
  if (ctx = nil) or (ctx^.nstates <= 1) then Exit;
  Dec(ctx^.nstates);
end;

procedure fonsClearState(ctx: PFONSContext);
begin
  if (ctx = nil) or (ctx^.nstates = 0) then Exit;
  ctx^.states[0].size := 12.0;
  ctx^.states[0].color := $FFFFFFFF;
  ctx^.states[0].blur := 0;
  ctx^.states[0].spacing := 0;
  ctx^.states[0].font := 0;
  ctx^.states[0].align := FONS_ALIGN_LEFT or FONS_ALIGN_BASELINE;
  ctx^.nstates := 1;
end;

function fonsTextIterInit(ctx: PFONSContext; iter: PFONSTextIter; x, y: single; str, endptr: pansichar): integer;
var
  state: PFONSState;
  Width: single;
begin
  if (ctx = nil) or (ctx^.nstates = 0) or (str = nil) then
  begin
    if Assigned(ctx^.handleError) then
      ctx^.handleError(FT_Err_Invalid_Argument, ctx^.userPtr);
    Exit(0);
  end;

  state := @ctx^.states[ctx^.nstates - 1];
  if (state^.font < 0) or (state^.font >= ctx^.nfonts) then
  begin
    if Assigned(ctx^.handleError) then
      ctx^.handleError(FT_Err_Invalid_Argument, ctx^.userPtr);
    Exit(0);
  end;

  FillChar(iter^, SizeOf(TFONSTextIter), 0);
  iter^.x := x;
  iter^.y := y;
  iter^.nextx := x;
  iter^.nexty := y;
  iter^.scale := state^.size / 64.0;
  iter^.spacing := state^.spacing;
  iter^.font := ctx^.fonts[state^.font];
  iter^.istr := str;
  iter^.Next := str;
  iter^.endptr := endptr;
  iter^.utf8state := 0;
  iter^.bitmapOption := Ord(state^.blur > 0);
  iter^.isize := Round(state^.size);
  iter^.iblur := Round(state^.blur);

  if (state^.align and (FONS_ALIGN_LEFT or FONS_ALIGN_CENTER or FONS_ALIGN_RIGHT)) <> 0 then
  begin
    Width := fonsTextBounds(ctx, x, y, str, endptr, nil);
    if (state^.align and FONS_ALIGN_CENTER) <> 0 then
      iter^.x := x - Width * 0.5
    else if (state^.align and FONS_ALIGN_RIGHT) <> 0 then
      iter^.x := x - Width;
    iter^.nextx := iter^.x;
  end;

  if (state^.align and (FONS_ALIGN_TOP or FONS_ALIGN_MIDDLE or FONS_ALIGN_BOTTOM or FONS_ALIGN_BASELINE)) <> 0 then
  begin
    if (state^.align and FONS_ALIGN_TOP) <> 0 then
      iter^.y := y + iter^.font^.ascender * iter^.scale
    else if (state^.align and FONS_ALIGN_MIDDLE) <> 0 then
      iter^.y := y - (iter^.font^.Height * iter^.scale) * 0.5
    else if (state^.align and FONS_ALIGN_BOTTOM) <> 0 then
      iter^.y := y - iter^.font^.descender * iter^.scale;
    iter^.nexty := iter^.y;
  end;

  Result := 1;
end;

function fonsTextIterNext(ctx: PFONSContext; iter: PFONSTextIter; quad: PFONSQuad): integer;
var
  glyph: PFONSGlyph;
  codepoint: longword;
  state: byte;
  font: PFONSFont;
  str: pansichar;
  i: integer;
begin
  state := iter^.utf8state;
  font := iter^.font;
  str := iter^.Next;
  iter^.istr := iter^.Next;

  if str = iter^.endptr then
    Exit(0);

  while str <> iter^.endptr do
  begin
    if fons__decUtf8(state, codepoint, Ord(str^)) = 0 then
    begin
      Inc(str);
      glyph := fons__getGlyph(ctx, font, codepoint, iter^.isize, iter^.iblur, iter^.bitmapOption);
      if (glyph = nil) and (font^.nfallbacks > 0) then
      begin
        for i := 0 to font^.nfallbacks - 1 do
        begin
          if (font^.fallbacks[i] >= 0) and (font^.fallbacks[i] < ctx^.nfonts) then
          begin
            glyph := fons__getGlyph(ctx, ctx^.fonts[font^.fallbacks[i]], codepoint, iter^.isize, iter^.iblur, iter^.bitmapOption);
            if glyph <> nil then Break;
          end;
        end;
      end;

      iter^.x := iter^.nextx;
      iter^.y := iter^.nexty;
      if glyph <> nil then
        fons__getQuad(ctx, font, iter^.prevGlyphIndex, glyph, iter^.scale, iter^.spacing, iter^.nextx, iter^.nexty, quad);
      iter^.prevGlyphIndex := IfThen(glyph <> nil, glyph^.index, -1);
      iter^.utf8state := state;
      iter^.Next := str;
      Exit(1);
    end;
    Inc(str);
  end;

  iter^.utf8state := 0;
  iter^.Next := str;
  Exit(0);
end;

function fonsTextBounds(ctx: PFONSContext; x, y: single; str, endptr: pansichar; bounds: PSingle): single;
var
  iter: TFONSTextIter;
  minx, miny, maxx, maxy: single;
  quad: TFONSQuad;
begin
  minx := x;
  miny := y;
  maxx := x;
  maxy := y;

  if fonsTextIterInit(ctx, @iter, x, y, str, endptr) <> 0 then
  begin
    while fonsTextIterNext(ctx, @iter, @quad) <> 0 do
    begin
      minx := Min(minx, quad.x0);
      miny := Min(miny, quad.y0);
      maxx := Max(maxx, quad.x1);
      maxy := Max(maxy, quad.y1);
    end;
  end;

  if bounds <> nil then
  begin
    bounds^ := minx;
    Inc(bounds);
    bounds^ := miny;
    Inc(bounds);
    bounds^ := maxx;
    Inc(bounds);
    bounds^ := maxy;
  end;

  Result := iter.nextx - x;
end;

function fonsDrawText(ctx: PFONSContext; x, y: single; str, endptr: pansichar; bounds: PSingle): single;
var
  iter: TFONSTextIter;
  quad: TFONSQuad;
  verts, tcoords: array of single;
  colors: array of longword;
  nverts: integer;
  state: PFONSState;
  i: integer;
begin
  if (ctx = nil) or (str = nil) then Exit;

  nverts := 0;
  SetLength(verts, FONS_SCRATCH_BUF_SIZE div SizeOf(single) * 2);
  SetLength(tcoords, FONS_SCRATCH_BUF_SIZE div SizeOf(single) * 2);
  SetLength(colors, FONS_SCRATCH_BUF_SIZE div SizeOf(longword));

  if fonsTextIterInit(ctx, @iter, x, y, str, endptr) <> 0 then
  begin
    while fonsTextIterNext(ctx, @iter, @quad) <> 0 do
    begin
      if nverts + 6 <= Length(verts) div 2 then
      begin
        verts[nverts * 2 + 0] := quad.x0;
        verts[nverts * 2 + 1] := quad.y0;
        tcoords[nverts * 2 + 0] := quad.s0;
        tcoords[nverts * 2 + 1] := quad.t0;
        verts[nverts * 2 + 2] := quad.x1;
        verts[nverts * 2 + 3] := quad.y0;
        tcoords[nverts * 2 + 2] := quad.s1;
        tcoords[nverts * 2 + 3] := quad.t0;
        verts[nverts * 2 + 4] := quad.x1;
        verts[nverts * 2 + 5] := quad.y1;
        tcoords[nverts * 2 + 4] := quad.s1;
        tcoords[nverts * 2 + 5] := quad.t1;
        verts[nverts * 2 + 6] := quad.x0;
        verts[nverts * 2 + 7] := quad.y0;
        tcoords[nverts * 2 + 6] := quad.s0;
        tcoords[nverts * 2 + 7] := quad.t0;
        verts[nverts * 2 + 8] := quad.x1;
        verts[nverts * 2 + 9] := quad.y1;
        tcoords[nverts * 2 + 8] := quad.s1;
        tcoords[nverts * 2 + 9] := quad.t1;
        verts[nverts * 2 + 10] := quad.x0;
        verts[nverts * 2 + 11] := quad.y1;
        tcoords[nverts * 2 + 10] := quad.s0;
        tcoords[nverts * 2 + 11] := quad.t1;
        for i := 0 to 5 do
          colors[nverts + i] := ctx^.states[ctx^.nstates - 1].color;
        Inc(nverts, 6);
      end;
    end;
  end;

  if (nverts > 0) and Assigned(ctx^.renderDraw) then
  begin
    state := @ctx^.states[ctx^.nstates - 1];
    ctx^.renderDraw(ctx^.userPtr, @verts[0], @tcoords[0], @colors[0], nverts);
  end;

  if bounds <> nil then
    fonsTextBounds(ctx, x, y, str, endptr, bounds);
  Result := x;
end;

procedure fonsResetAtlas(ctx: PFONSContext; Width, Height: integer);
var
  i: integer;
begin
  if ctx = nil then Exit;

  fons__atlasReset(ctx^.atlas, Width, Height);
  SetLength(ctx^.texData, Width * Height);
  FillChar(ctx^.texData[0], Width * Height, 0);

  for i := 0 to ctx^.nfonts - 1 do
  begin
    ctx^.fonts[i]^.nglyphs := 0;
    FillChar(ctx^.fonts[i]^.lut[0], Length(ctx^.fonts[i]^.lut) * SizeOf(integer), $FF);
  end;

  if Assigned(ctx^.renderUpdate) then
    ctx^.renderUpdate(ctx^.userPtr, @ctx^.dirtyRect[0], @ctx^.texData[0]);
end;

procedure fonsGetAtlasSize(ctx: PFONSContext; out Width, Height: integer);
begin
  if ctx = nil then Exit;
  Width := ctx^.params.Width;
  Height := ctx^.params.Height;
end;

function fonsAddFallbackFont(ctx: PFONSContext; base, fallback: integer): integer;
var
  font: PFONSFont;
begin
  if (ctx = nil) or (base < 0) or (base >= ctx^.nfonts) or (fallback < 0) or (fallback >= ctx^.nfonts) then
    Exit(0);

  font := ctx^.fonts[base];
  if font^.nfallbacks >= Length(font^.fallbacks) then
  begin
    SetLength(font^.fallbacks, ifthen(font^.nfallbacks = 0, 4, font^.nfallbacks * 2));
  end;

  font^.fallbacks[font^.nfallbacks] := fallback;
  Inc(font^.nfallbacks);
  Exit(1);
end;

end.
