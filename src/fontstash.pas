unit FontStash;
{$mode objfpc}{$H+}
{$ModeSwitch typehelpers}
interface

uses
  SysUtils, Classes, freetypeh;

const

  // Dimensioni del buffer di scratch
  FONS_SCRATCH_BUF_SIZE = 96000;
  // Dimensione della lookup table per l'hash
  FONS_HASH_LUT_SIZE = 256;
  // Numero iniziale di font
  FONS_INIT_FONTS = 4;
  // Numero iniziale di glifi
  FONS_INIT_GLYPHS = 256;
  // Numero iniziale di nodi dell'atlante
  FONS_INIT_ATLAS_NODES = 256;
  // Numero massimo di stati
  FONS_MAX_STATES = 20;
  // Numero massimo di fallback per font
  FONS_MAX_FALLBACKS = 20;
  // Numero massimo di vertici
  FONS_VERTEX_COUNT = 1024;

  // Costanti per il blur
  APREC = 16;
  ZPREC = 7;

  // Valore per font non valido
  FONS_INVALID = -1;

type
  PFONSAtlas = ^TFONSAtlas;
  PFONSAtlasNode = ^TFONSAtlasNode;
  PFONSContext = ^TFONSContext;
  PFONSFont = ^TFONSFont;
  PFONSParams = ^TFONSParams;
  PFONSQuad = ^TFONSQuad;
  PFONSState = ^TFONSState;
  PFONSTextIter = ^TFONSTextIter;
  PFONSTTFontImpl = ^TFONSTTFontImpl;
  PFONSGlyph = ^TFONSGlyph;


  // FONSerrorCode: Codici di errore per FontStash
  TFONSerrorCode = (
    FONS_ERROR_DUMMY = 0,       // Valore dummy per evitare che il primo valore sia 1
    FONS_ATLAS_FULL = 1,        // Atlante dei font pieno
    FONS_SCRATCH_FULL = 2,      // Memoria scratch per il rendering dei glifi piena
    FONS_STATES_OVERFLOW = 3,   // Stack degli stati troppo grande
    FONS_STATES_UNDERFLOW = 4   // Tentativo di pop di troppi stati
    );

  // Definizione del puntatore a funzione per i callback
  TFONSRenderCreate = function(uptr: Pointer; Width, Height: int32): int32; cdecl;
  TFONSRenderResize = function(uptr: Pointer; Width, Height: int32): int32; cdecl;
  TFONSRenderUpdate = procedure(uptr: Pointer; rect: PInt32; Data: pbyte); cdecl;
  TFONSRenderDraw = procedure(uptr: Pointer; verts, tcoords: PSingle; colors: PCardinal; nverts: int32); cdecl;
  TFONSRenderDelete = procedure(uptr: Pointer); cdecl;
  TFONSErrorHandler = procedure(uptr: Pointer; error: TFONSErrorCode; val: int32); cdecl;

  TFONSFlags = (
    FONS_ZERO_TOPLEFT = 1,      // Origine in alto a sinistra
    FONS_ZERO_BOTTOMLEFT = 2    // Origine in basso a sinistra
    );

  // FONSalign: Flag per l'allineamento orizzontale e verticale
  TFONSAlign = (
    FONS_ALIGN_LEFT,     // Allineamento orizzontale a sinistra (default)
    FONS_ALIGN_CENTER,   // Allineamento orizzontale centrato
    FONS_ALIGN_RIGHT,    // Allineamento orizzontale a destra
    FONS_ALIGN_TOP,      // Allineamento verticale in alto
    FONS_ALIGN_MIDDLE,   // Allineamento verticale al centro
    FONS_ALIGN_BOTTOM,   // Allineamento verticale in basso
    FONS_ALIGN_BASELINE  // Allineamento verticale sulla linea di base (default)
    );
  TFONSAligns = set of TFONSAlign;

  // FONSglyphBitmap: Opzioni per il bitmap dei glifi
  TFONSGlyphBitmap = (
    FONS_GLYPH_BITMAP_DUMMY = 0, // Valore dummy per evitare che il primo valore sia 1
    FONS_GLYPH_BITMAP_OPTIONAL = 1, // Bitmap del glifo opzionale
    FONS_GLYPH_BITMAP_REQUIRED = 2  // Bitmap del glifo obbligatorio
    );

  // Struttura FONSParams
  TFONSParams = record
    Width, Height: int32;
    flags: int32;
    userPtr: Pointer;
    renderCreate: TFONSRenderCreate;
    renderResize: TFONSRenderResize;
    renderUpdate: TFONSRenderUpdate;
    renderDraw: TFONSRenderDraw;
    renderDelete: TFONSRenderDelete;
  end;

  // Struttura FONSQuad
  TFONSQuad = record
    x0, y0, s0, t0: single;
    x1, y1, s1, t1: single;
  end;

  // Struttura FONSglyph
  TFONSGlyph = record
    codepoint: cardinal; // unsigned int
    index: integer;      // int
    Next: integer;       // int
    size: smallint;      // short
    blur: smallint;      // short
    x0, y0, x1, y1: smallint; // short
    xadv, xoff, yoff: smallint; // short
  end;


  // Struttura FONSTextIter
  TFONSTextIter = record
    x, y, nextx, nexty: single;
    spacing: single;
    str, Next, stop: pchar;
    codepoint: cardinal;
    isize, iblur: smallint;
    font: PFONSfont;
    prevGlyphIndex: integer;
    utf8state: cardinal;
    bitmapOption: TFONSGlyphBitmap;
    scale: single;
  end;

  // Struttura FONSAtlasNode
  TFONSAtlasNode = record
    x, y, Width: int16;
  end;

  // Struttura FONSState
  TFONSState = record
    font: int32;        // Indice del font
    align: TFONSAligns;       // Allineamento
    size: single;       // Dimensione del font
    color: cardinal;    // Colore (unsigned int)
    blur: single;       // Effetto sfocatura
    spacing: single;    // Spaziatura
  end;

  // Struttura FONSAtlas
  TFONSAtlas = record
    Width: int32;         // Larghezza dell'atlante
    Height: int32;        // Altezza dell'atlante
    nodes: PFONSAtlasNode; // Puntatore a un array di nodi
    nnodes: int32;       // Numero di nodi utilizzati
    cnodes: int32;       // Capacità dell'array di nodi
  end;


  // Struttura TFONSTTFontImpl
  TFONSTTFontImpl = record
    font: PFT_Face; // Puntatore al font FreeType
  end;
  // Struttura FONSfont
  TFONSFont = record
    Name: array[0..63] of char; // Nome del font (stringa C-style)
    glyphs: PFONSGlyph;         // Array dinamico di glifi
    cglyphs: integer;           // Capacità dell'array di glifi
    nglyphs: integer;           // Numero di glifi usati
    lut: array[0..FONS_HASH_LUT_SIZE - 1] of integer; // Lookup table
    fallbacks: array[0..FONS_MAX_FALLBACKS - 1] of integer; // Font di fallback
    nfallbacks: integer;        // Numero di fallback
    Data: pbyte;                // Dati del font
    dataSize: integer;          // Dimensione dei dati
    freeData: byte;             // Flag per liberare i dati
    ascender: single;           // Ascendente normalizzato
    descender: single;          // Discendente normalizzato
    lineh: single;              // Altezza di linea normalizzata
    font: TFONSTTFontImpl;      // Implementazione FreeType
  end;


  // Array per verts, tcoords, colors e dirtyRect
  TFONSVertexArray = array[0..FONS_VERTEX_COUNT * 2 - 1] of single;
  TFONSColorArray = array[0..FONS_VERTEX_COUNT - 1] of cardinal;
  TFONSDirtyRect = array[0..3] of int32;
  TFONSStatesArray = array[0..FONS_MAX_STATES - 1] of TFONSState;

  // Struttura principale FONSContext
  TFONSContext = record
    params: TFONSParams;            // Parametri di configurazione
    itw, ith: single;               // Valori float per dimensioni inverse
    texData: pbyte;                 // Puntatore ai dati della texture
    dirtyRect: TFONSDirtyRect;      // Rettangolo di aggiornamento (4 interi)
    fonts: ^PFONSFont;              // Array dinamico di puntatori a FONSfont
    atlas: PFONSAtlas;              // Puntatore all'atlante
    cfonts: int32;                 // Capacità dell'array fonts
    nfonts: int32;                 // Numero di font effettivamente usati
    verts: TFONSVertexArray;        // Array di vertici (x, y)
    tcoords: TFONSVertexArray;      // Array di coordinate texture
    colors: TFONSColorArray;        // Array di colori
    nverts: int32;                 // Numero di vertici
    scratch: pbyte;                 // Buffer di memoria temporanea
    nscratch: int32;               // Dimensione del buffer scratch
    states: TFONSStatesArray;       // Array di stati
    nstates: int32;                // Numero di stati
    handleError: TFONSErrorHandler; // Puntatore a funzione per gestione errori
    errorUptr: Pointer;             // Puntatore opaco per dati utente
    ftLibrary: PFT_Library;         // Libreria FreeType
  end;

// Dichiarazioni delle funzioni
function fonsCreateInternal(params: PFONSParams): PFONSContext;
procedure fonsDeleteInternal(stash: PFONSContext);
procedure fonsSetErrorCallback(stash: PFONSContext; callback: TFONSErrorHandler; uptr: Pointer);
procedure fonsGetAtlasSize(stash: PFONSContext; Width, Height: PInt32);
function fonsExpandAtlas(stash: PFONSContext; Width, Height: int32): int32;
function fonsResetAtlas(stash: PFONSContext; Width, Height: int32): int32;
function fonsAddFont(stash: PFONSContext; Name, path: pchar; fontIndex: int32): int32;
function fonsAddFontMem(stash: PFONSContext; Name: pchar; Data: pbyte; dataSize, freeData, fontIndex: int32): int32;
function fonsGetFontByName(stash: PFONSContext; Name: pchar): int32;
function fonsAddFallbackFont(stash: PFONSContext; base, fallback: integer): integer;
procedure fonsResetFallbackFont(stash: PFONSContext; base: integer);
procedure fonsPushState(stash: PFONSContext);
procedure fonsPopState(stash: PFONSContext);
procedure fonsClearState(stash: PFONSContext);
procedure fonsSetSize(stash: PFONSContext; size: single);
procedure fonsSetColor(stash: PFONSContext; color: cardinal);
procedure fonsSetSpacing(stash: PFONSContext; spacing: single);
procedure fonsSetBlur(stash: PFONSContext; blur: single);
procedure fonsSetAlign(stash: PFONSContext; align: TFONSAligns);
procedure fonsSetFont(stash: PFONSContext; font: int32);
function fonsDrawText(stash: PFONSContext; x, y: single; str, end_: pchar): single;
function fonsTextBounds(stash: PFONSContext; x, y: single; str, end_: pchar; bounds: PSingle): single;
procedure fonsLineBounds(stash: PFONSContext; y: single; miny, maxy: PSingle);
procedure fonsVertMetrics(stash: PFONSContext; ascender, descender, lineh: PSingle);
function fonsTextIterInit(stash: PFONSContext; iter: PFONSTextIter; x, y: single; str, end_: pchar; bitmapOption: TFONSGlyphBitmap): boolean;
function fonsTextIterNext(stash: PFONSContext; iter: PFONSTextIter; quad: PFONSQuad): boolean;
function fonsGetTextureData(stash: PFONSContext; Width, Height: PInt32): pbyte;
function fonsValidateTexture(stash: PFONSContext; dirty: PInt32): boolean;
procedure fonsDrawDebug(stash: PFONSContext; x, y: single);

operator := (flags: TFONSFlags): int32;
operator := (alignSet: TFONSAligns): int32;
operator := (align: int8): TFONSAligns;
operator in(flags: TFONSFlags; Value: int32): boolean;
operator in(align: TFONSAlign; Value: int32): boolean;

implementation

uses
  Math;

type
  FT_UInt = uint32;
  FT_Int32 = int32;
  FT_Fixed = PUInt32;

const
  FT_LOAD_TARGET_LIGHT = $10000;

function FT_New_Memory_Face(aLibrary: PFT_Library; file_base: pbyte; file_size: FT_Long; face_index: FT_Long; aface: PFT_Face): FT_Error; cdecl; external 'freetype';
function FT_Get_Advance(face: PFT_Face; gindex: FT_UInt; load_flags: FT_Int32; padvance: FT_Fixed): FT_Error; cdecl; external 'freetype';
function FT_Get_Kerning(face: PFT_Face; left_glyph, right_glyph: FT_UInt; kern_mode: FT_UInt; kerning: PFT_Vector): FT_Error; cdecl; external 'freetype';

operator := (flags: TFONSFlags): int32; inline;
begin
  case flags of
    FONS_ZERO_TOPLEFT: Result := 1;     // Origine in alto a sinistra
    FONS_ZERO_BOTTOMLEFT: Result := 2;  // Origine in basso a sinistra
    else
      raise Exception.Create('Valore TFONSFlags non valido');
  end;
end;


operator in(flags: TFONSFlags; Value: int32): boolean;
begin
  Result := (Ord(flags) and Value) <> 0;
end;

operator in(align: TFONSAlign; Value: int32): boolean;
begin
  Result := (Ord(align) and Value) <> 0;
end;

operator := (alignSet: TFONSAligns): int32;
begin
  Result := 0;
  if FONS_ALIGN_LEFT in alignSet then Result := Result or (1 shl 0);
  if FONS_ALIGN_CENTER in alignSet then Result := Result or (1 shl 1);
  if FONS_ALIGN_RIGHT in alignSet then Result := Result or (1 shl 2);
  if FONS_ALIGN_TOP in alignSet then Result := Result or (1 shl 3);
  if FONS_ALIGN_MIDDLE in alignSet then Result := Result or (1 shl 4);
  if FONS_ALIGN_BOTTOM in alignSet then Result := Result or (1 shl 5);
  if FONS_ALIGN_BASELINE in alignSet then Result := Result or (1 shl 6);
end;

operator := (align: int8): TFONSAligns;
begin
  Result := [];
  if (align and (1 shl 0)) <> 0 then Include(Result, FONS_ALIGN_LEFT);
  if (align and (1 shl 1)) <> 0 then Include(Result, FONS_ALIGN_CENTER);
  if (align and (1 shl 2)) <> 0 then Include(Result, FONS_ALIGN_RIGHT);
  if (align and (1 shl 3)) <> 0 then Include(Result, FONS_ALIGN_TOP);
  if (align and (1 shl 4)) <> 0 then Include(Result, FONS_ALIGN_MIDDLE);
  if (align and (1 shl 5)) <> 0 then Include(Result, FONS_ALIGN_BOTTOM);
  if (align and (1 shl 6)) <> 0 then Include(Result, FONS_ALIGN_BASELINE);
end;

procedure fons__freeFont(font: PFONSFont); forward;

// Funzione di utilità
function iif(cond: boolean; a, b: integer): integer; inline;
begin
  if cond then Result := a
  else
    Result := b;
end;

// Funzioni di supporto
function fons__hashint(a: uint32): uint32;
begin
  a := a + not (a shl 15);
  a := a xor (a shr 10);
  a := a + (a shl 3);
  a := a xor (a shr 6);
  a := a + not (a shl 11);
  a := a xor (a shr 16);
  Result := a;
end;

function fons__mini(a, b: int32): int32; inline;
begin
  if a < b then Result := a
  else
    Result := b;
end;

function fons__maxi(a, b: int32): int32; inline;
begin
  if a > b then Result := a
  else
    Result := b;
end;

// Funzioni FreeType
function fons__tt_init(context: PFONSContext): boolean;
var
  ftError: FT_Error;
begin
  ftError := FT_Init_FreeType(context^.ftLibrary);
  Result := ftError = 0;
end;

function fons__tt_done(context: PFONSContext): boolean;
var
  ftError: FT_Error;
begin
  ftError := FT_Done_FreeType(context^.ftLibrary);
  Result := ftError = 0;
end;

function fons__tt_loadFont(context: PFONSContext; font: PFONSTTFontImpl; Data: pbyte; dataSize: int32; fontIndex: int32): boolean;
var
  ftError: FT_Error;
begin
  ftError := FT_New_Memory_Face(context^.ftLibrary, pbyte(Data), dataSize, fontIndex, font^.font);
  Result := ftError = 0;
end;

procedure fons__tt_getFontVMetrics(font: PFONSTTFontImpl; ascent, descent, lineGap: PInt32);
begin
  ascent^ := font^.font^.ascender;
  descent^ := font^.font^.descender;
  lineGap^ := font^.font^.Height - (ascent^ - descent^);
end;

function fons__tt_getPixelHeightScale(font: PFONSTTFontImpl; size: single): single;
begin
  Result := size / font^.font^.units_per_EM;
end;

function fons__tt_getGlyphIndex(font: PFONSTTFontImpl; codepoint: int32): int32;
begin
  Result := FT_Get_Char_Index(font^.font, codepoint);
end;

function fons__tt_buildGlyphBitmap(font: PFONSTTFontImpl; glyph: int32; size: single; scale: single; advance, lsb, x0, y0, x1, y1: PInt32): int32;
var
  ftError: FT_Error;
  ftGlyph: PFT_GlyphSlot;
  advFixed: FT_Fixed = nil;
begin
  Result := 0;
  ftError := FT_Set_Pixel_Sizes(font^.font, 0, Round(size));
  if ftError <> 0 then
  begin
    Exit;
  end;

  ftError := FT_Load_Glyph(font^.font, glyph, FT_LOAD_RENDER or FT_LOAD_FORCE_AUTOHINT or FT_LOAD_TARGET_LIGHT);
  if ftError <> 0 then
  begin
    Exit;
  end;

  ftError := FT_Get_Advance(font^.font, glyph, FT_LOAD_NO_SCALE, advFixed);
  if ftError <> 0 then
  begin
    Exit;
  end;

  ftGlyph := font^.font^.glyph;
  advance^ := advFixed^;
  lsb^ := ftGlyph^.metrics.horiBearingX;
  x0^ := ftGlyph^.bitmap_left;
  x1^ := x0^ + ftGlyph^.bitmap.Width;
  y0^ := -ftGlyph^.bitmap_top;
  y1^ := y0^ + ftGlyph^.bitmap.rows;
  Result := 1;
end;

procedure fons__tt_renderGlyphBitmap(font: PFONSTTFontImpl; output: pbyte; outWidth, outHeight, outStride: integer; scaleX, scaleY: single; glyph: integer);
var
  ftGlyph: PFT_GlyphSlot;
  ftGlyphOffset: integer;
  x, y: cardinal;
begin
  ftGlyph := font^.font^.glyph;
  ftGlyphOffset := 0;

  for y := 0 to ftGlyph^.bitmap.rows - 1 do
  begin
    for x := 0 to ftGlyph^.bitmap.Width - 1 do
    begin
      output[(y * outStride) + x] := pbyte(ftGlyph^.bitmap.buffer)[ftGlyphOffset];
      Inc(ftGlyphOffset);
    end;
  end;
end;

function fons__tt_getGlyphKernAdvance(font: PFONSTTFontImpl; glyph1, glyph2: integer): integer;
var
  ftKerning: PFT_Vector;
begin
  FT_Get_Kerning(font^.font, glyph1, glyph2, FT_KERNING_DEFAULT, ftKerning);
  Result := (ftKerning^.x + 32) shr 6; // Arrotonda e converte in Integer
end;

// UTF-8 Decoder (basato su Bjoern Hoehrmann)
const
  FONS_UTF8_ACCEPT = 0;
  FONS_UTF8_REJECT = 12;
  utf8d: array[0..363] of byte = (
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9,
    7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
    8, 8, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
    10, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 3, 3, 11, 6, 6, 6, 5, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
    0, 12, 24, 36, 60, 96, 84, 12, 12, 12, 48, 72, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,
    12, 0, 12, 12, 12, 12, 12, 0, 12, 0, 12, 12, 12, 24, 12, 12, 12, 12, 12, 24, 12, 24, 12, 12,
    12, 12, 12, 12, 12, 12, 12, 24, 12, 12, 12, 12, 12, 24, 12, 12, 12, 12, 12, 12, 12, 24, 12, 12,
    12, 12, 12, 12, 12, 12, 12, 36, 12, 36, 12, 12, 12, 36, 12, 12, 12, 12, 12, 36, 12, 36, 12, 12,
    12, 36, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12
    );

function fons__decutf8(state: PCardinal; codep: PCardinal; byte: cardinal): boolean;
var
  type_: cardinal;
begin
  type_ := utf8d[byte];

  if state^ <> FONS_UTF8_ACCEPT then
    codep^ := (byte and $3F) or (codep^ shl 6)
  else
    codep^ := ($FF shr type_) and byte;

  state^ := utf8d[256 + state^ + type_];
  Result := state^ <> FONS_UTF8_ACCEPT;
end;

// Atlas based on Skyline Bin Packer
procedure fons__deleteAtlas(atlas: PFONSAtlas);
begin
  if atlas = nil then
    Exit;
  if atlas^.nodes <> nil then
    FreeMem(atlas^.nodes);
  FreeMem(atlas);
end;

function fons__allocAtlas(w, h, nnodes: integer): PFONSAtlas;
var
  atlas: PFONSAtlas;
begin
  try
    GetMem(atlas, SizeOf(TFONSAtlas));
    FillChar(atlas^, SizeOf(TFONSAtlas), 0);

    atlas^.Width := w;
    atlas^.Height := h;

    GetMem(atlas^.nodes, SizeOf(TFONSAtlasNode) * nnodes);
    FillChar(atlas^.nodes^, SizeOf(TFONSAtlasNode) * nnodes, 0);
    atlas^.nnodes := 0;
    atlas^.cnodes := nnodes;

    atlas^.nodes[0].x := 0;
    atlas^.nodes[0].y := 0;
    atlas^.nodes[0].Width := w;
    Inc(atlas^.nnodes);

    Result := atlas;
  except
    if atlas <> nil then
      fons__deleteAtlas(atlas);
    Result := nil;
  end;
end;

function fons__atlasInsertNode(atlas: PFONSAtlas; idx, x, y, w: integer): integer;
var
  i: integer;
begin
  if atlas^.nnodes + 1 > atlas^.cnodes then
  begin
    if atlas^.cnodes = 0 then
      atlas^.cnodes := 8
    else
      atlas^.cnodes := atlas^.cnodes * 2;
    ReallocMem(atlas^.nodes, SizeOf(TFONSAtlasNode) * atlas^.cnodes);
    if atlas^.nodes = nil then
    begin
      Result := 0;
      Exit;
    end;
  end;

  for i := atlas^.nnodes downto idx + 1 do
    atlas^.nodes[i] := atlas^.nodes[i - 1];

  atlas^.nodes[idx].x := x;
  atlas^.nodes[idx].y := y;
  atlas^.nodes[idx].Width := w;
  Inc(atlas^.nnodes);

  Result := 1;
end;

procedure fons__atlasRemoveNode(atlas: PFONSAtlas; idx: integer);
var
  i: integer;
begin
  if atlas^.nnodes = 0 then
    Exit;
  for i := idx to atlas^.nnodes - 2 do
    atlas^.nodes[i] := atlas^.nodes[i + 1];
  Dec(atlas^.nnodes);
end;

procedure fons__atlasExpand(atlas: PFONSAtlas; w, h: integer);
begin
  if w > atlas^.Width then
    fons__atlasInsertNode(atlas, atlas^.nnodes, atlas^.Width, 0, w - atlas^.Width);
  atlas^.Width := w;
  atlas^.Height := h;
end;

procedure fons__atlasReset(atlas: PFONSAtlas; w, h: integer);
begin
  atlas^.Width := w;
  atlas^.Height := h;
  atlas^.nnodes := 0;

  atlas^.nodes[0].x := 0;
  atlas^.nodes[0].y := 0;
  atlas^.nodes[0].Width := w;
  Inc(atlas^.nnodes);
end;

function fons__atlasAddSkylineLevel(atlas: PFONSAtlas; idx, x, y, w, h: integer): integer;
var
  i, shrink: integer;
begin
  if fons__atlasInsertNode(atlas, idx, x, y + h, w) = 0 then
  begin
    Result := 0;
    Exit;
  end;

  i := idx + 1;
  while i < atlas^.nnodes do
  begin
    if atlas^.nodes[i].x < atlas^.nodes[i - 1].x + atlas^.nodes[i - 1].Width then
    begin
      shrink := atlas^.nodes[i - 1].x + atlas^.nodes[i - 1].Width - atlas^.nodes[i].x;
      atlas^.nodes[i].x := atlas^.nodes[i].x + shrink;
      atlas^.nodes[i].Width := atlas^.nodes[i].Width - shrink;
      if atlas^.nodes[i].Width <= 0 then
      begin
        fons__atlasRemoveNode(atlas, i);
        Dec(i);
      end
      else
        Break;
    end
    else
      Break;
    Inc(i);
  end;

  i := 0;
  while i < atlas^.nnodes - 1 do
  begin
    if atlas^.nodes[i].y = atlas^.nodes[i + 1].y then
    begin
      atlas^.nodes[i].Width := atlas^.nodes[i].Width + atlas^.nodes[i + 1].Width;
      fons__atlasRemoveNode(atlas, i + 1);
      Dec(i);
    end;
    Inc(i);
  end;

  Result := 1;
end;

function fons__atlasRectFits(atlas: PFONSAtlas; i, w, h: integer): integer;
var
  x, y, spaceLeft: integer;
begin
  x := atlas^.nodes[i].x;
  y := atlas^.nodes[i].y;
  if x + w > atlas^.Width then
  begin
    Result := -1;
    Exit;
  end;
  spaceLeft := w;
  while spaceLeft > 0 do
  begin
    if i = atlas^.nnodes then
    begin
      Result := -1;
      Exit;
    end;
    y := fons__maxi(y, atlas^.nodes[i].y);
    if y + h > atlas^.Height then
    begin
      Result := -1;
      Exit;
    end;
    spaceLeft := spaceLeft - atlas^.nodes[i].Width;
    Inc(i);
  end;
  Result := y;
end;

function fons__atlasAddRect(atlas: PFONSAtlas; rw, rh: integer; rx, ry: PInteger): integer;
var
  besth, bestw, besti, bestx, besty, i, y: integer;
begin
  besth := atlas^.Height;
  bestw := atlas^.Width;
  besti := -1;
  bestx := -1;
  besty := -1;

  for i := 0 to atlas^.nnodes - 1 do
  begin
    y := fons__atlasRectFits(atlas, i, rw, rh);
    if y <> -1 then
    begin
      if (y + rh < besth) or ((y + rh = besth) and (atlas^.nodes[i].Width < bestw)) then
      begin
        besti := i;
        bestw := atlas^.nodes[i].Width;
        besth := y + rh;
        bestx := atlas^.nodes[i].x;
        besty := y;
      end;
    end;
  end;

  if besti = -1 then
  begin
    Result := 0;
    Exit;
  end;

  if fons__atlasAddSkylineLevel(atlas, besti, bestx, besty, rw, rh) = 0 then
  begin
    Result := 0;
    Exit;
  end;

  rx^ := bestx;
  ry^ := besty;

  Result := 1;
end;

procedure fons__addWhiteRect(stash: PFONSContext; w, h: integer);
var
  x, y, gx, gy: integer;
  dst: pbyte;
begin
  if fons__atlasAddRect(stash^.atlas, w, h, @gx, @gy) = 0 then
    Exit;

  dst := @stash^.texData[gx + gy * stash^.params.Width];
  for y := 0 to h - 1 do
  begin
    for x := 0 to w - 1 do
      dst[x] := $FF;
    Inc(dst, stash^.params.Width);
  end;

  stash^.dirtyRect[0] := fons__mini(stash^.dirtyRect[0], gx);
  stash^.dirtyRect[1] := fons__mini(stash^.dirtyRect[1], gy);
  stash^.dirtyRect[2] := fons__maxi(stash^.dirtyRect[2], gx + w);
  stash^.dirtyRect[3] := fons__maxi(stash^.dirtyRect[3], gy + h);
end;

// Funzioni principali
function fonsCreateInternal(params: PFONSParams): PFONSContext;
var
  stash: PFONSContext;
begin
  try
    GetMem(stash, SizeOf(TFONSContext));
    FillChar(stash^, SizeOf(TFONSContext), 0);

    stash^.params := params^;

    GetMem(stash^.scratch, FONS_SCRATCH_BUF_SIZE);
    if stash^.scratch = nil then
      raise EOutOfMemory.Create('Impossibile allocare buffer scratch');

    if not fons__tt_init(stash) then
      raise EOutOfMemory.Create('Impossibile inizializzare FreeType');

    if Assigned(stash^.params.renderCreate) then
    begin
      if stash^.params.renderCreate(stash^.params.userPtr, stash^.params.Width, stash^.params.Height) = 0 then
        raise EOutOfMemory.Create('Impossibile creare texture');
    end;

    stash^.atlas := fons__allocAtlas(stash^.params.Width, stash^.params.Height, FONS_INIT_ATLAS_NODES);
    if stash^.atlas = nil then
      raise EOutOfMemory.Create('Impossibile allocare atlante');

    GetMem(stash^.fonts, SizeOf(PFONSFont) * FONS_INIT_FONTS);
    FillChar(stash^.fonts^, SizeOf(PFONSFont) * FONS_INIT_FONTS, 0);
    stash^.cfonts := FONS_INIT_FONTS;
    stash^.nfonts := 0;

    stash^.itw := 1.0 / stash^.params.Width;
    stash^.ith := 1.0 / stash^.params.Height;
    GetMem(stash^.texData, stash^.params.Width * stash^.params.Height);
    if stash^.texData = nil then
      raise EOutOfMemory.Create('Impossibile allocare texture');
    FillChar(stash^.texData^, stash^.params.Width * stash^.params.Height, 0);

    stash^.dirtyRect[0] := stash^.params.Width;
    stash^.dirtyRect[1] := stash^.params.Height;
    stash^.dirtyRect[2] := 0;
    stash^.dirtyRect[3] := 0;

    fons__addWhiteRect(stash, 2, 2);

    fonsPushState(stash);
    fonsClearState(stash);

    Result := stash;
  except
    fonsDeleteInternal(stash);
    Result := nil;
  end;
end;

procedure fonsDeleteInternal(stash: PFONSContext);
var
  i: integer;
begin
  if stash = nil then
    Exit;

  if Assigned(stash^.params.renderDelete) then
    stash^.params.renderDelete(stash^.params.userPtr);

  for i := 0 to stash^.nfonts - 1 do
    fons__freeFont(stash^.fonts[i]);

  if stash^.scratch <> nil then
    FreeMem(stash^.scratch);
  if stash^.fonts <> nil then
    FreeMem(stash^.fonts);
  if stash^.atlas <> nil then
    fons__deleteAtlas(stash^.atlas);
  if stash^.texData <> nil then
    FreeMem(stash^.texData);
  fons__tt_done(stash);
  FreeMem(stash);
end;

procedure fonsSetErrorCallback(stash: PFONSContext; callback: TFONSErrorHandler; uptr: Pointer);
begin
  if stash = nil then
    Exit;
  stash^.handleError := callback;
  stash^.errorUptr := uptr;
end;

procedure fonsGetAtlasSize(stash: PFONSContext; Width, Height: PInt32);
begin
  if stash = nil then
    Exit;
  Width^ := stash^.params.Width;
  Height^ := stash^.params.Height;
end;

function fonsExpandAtlas(stash: PFONSContext; Width, Height: int32): int32;
var
  Data: pbyte;
begin
  if (Width < stash^.params.Width) or (Height < stash^.params.Height) then
  begin
    Result := 0;
    Exit;
  end;

  if Assigned(stash^.params.renderResize) then
  begin
    if stash^.params.renderResize(stash^.params.userPtr, Width, Height) = 0 then
    begin
      Result := 0;
      Exit;
    end;
  end;

  if (Width > stash^.params.Width) or (Height > stash^.params.Height) then
  begin
    GetMem(Data, Width * Height);
    if Data = nil then
    begin
      Result := 0;
      Exit;
    end;
    FillChar(Data^, Width * Height, 0);
    Move(stash^.texData^, Data^, stash^.params.Width * stash^.params.Height);
    FreeMem(stash^.texData);
    stash^.texData := Data;
  end;

  fons__atlasExpand(stash^.atlas, Width, Height);

  stash^.params.Width := Width;
  stash^.params.Height := Height;
  stash^.itw := 1.0 / Width;
  stash^.ith := 1.0 / Height;

  stash^.dirtyRect[0] := Width;
  stash^.dirtyRect[1] := Height;
  stash^.dirtyRect[2] := 0;
  stash^.dirtyRect[3] := 0;

  Result := 1;
end;

function fonsResetAtlas(stash: PFONSContext; Width, Height: int32): int32;
begin
  if stash = nil then
  begin
    Result := 0;
    Exit;
  end;

  fons__atlasReset(stash^.atlas, Width, Height);

  if Assigned(stash^.params.renderResize) then
  begin
    if stash^.params.renderResize(stash^.params.userPtr, Width, Height) = 0 then
    begin
      Result := 0;
      Exit;
    end;
  end;

  FillChar(stash^.texData^, Width * Height, 0);
  stash^.params.Width := Width;
  stash^.params.Height := Height;
  stash^.itw := 1.0 / Width;
  stash^.ith := 1.0 / Height;

  stash^.dirtyRect[0] := Width;
  stash^.dirtyRect[1] := Height;
  stash^.dirtyRect[2] := 0;
  stash^.dirtyRect[3] := 0;

  fons__addWhiteRect(stash, 2, 2);

  Result := 1;
end;

function fons__getState(stash: PFONSContext): PFONSState;
begin
  Result := @stash^.states[stash^.nstates - 1];
end;

procedure fons__freeFont(font: PFONSFont);
begin
  if font = nil then
    Exit;
  if font^.glyphs <> nil then
    FreeMem(font^.glyphs);
  if (font^.freeData <> 0) and (font^.Data <> nil) then
    FreeMem(font^.Data);
  if font^.font.font <> nil then
    FT_Done_Face(font^.font.font);
  FreeMem(font);
end;

function fons__allocFont(stash: PFONSContext): integer;
var
  font: PFONSFont;
begin
  try
    if stash^.nfonts + 1 > stash^.cfonts then
    begin
      if stash^.cfonts = 0 then
        stash^.cfonts := 8
      else
        stash^.cfonts := stash^.cfonts * 2;
      ReallocMem(stash^.fonts, SizeOf(PFONSFont) * stash^.cfonts);
      if stash^.fonts = nil then
        raise EOutOfMemory.Create('Impossibile allocare memoria per fonts');
    end;

    GetMem(font, SizeOf(TFONSFont));
    FillChar(font^, SizeOf(TFONSFont), 0);

    GetMem(font^.glyphs, SizeOf(TFONSglyph) * FONS_INIT_GLYPHS);
    if font^.glyphs = nil then
      raise EOutOfMemory.Create('Impossibile allocare memoria per glyphs');
    font^.cglyphs := FONS_INIT_GLYPHS;
    font^.nglyphs := 0;

    stash^.fonts[stash^.nfonts] := font;
    Inc(stash^.nfonts);
    Result := stash^.nfonts - 1;
  except
    fons__freeFont(font);
    Result := FONS_INVALID;
  end;
end;

function fonsAddFont(stash: PFONSContext; Name, path: pchar; fontIndex: int32): int32;
var
  fp: file;
  dataSize: integer;
  readed: integer = 0;
  Data: pbyte;
begin
  try
    AssignFile(fp, path);
    Reset(fp, 1);
    dataSize := FileSize(fp);

    GetMem(Data, dataSize);
    try
      BlockRead(fp, Data^, dataSize, readed);
      if readed <> dataSize then
        raise EInOutError.Create('Errore nella lettura del file del font');
      Result := fonsAddFontMem(stash, Name, Data, dataSize, 1, fontIndex);
    finally
      FreeMem(Data);
      CloseFile(fp);
    end;
  except
    if FileRec(fp).Mode <> fmClosed then
      CloseFile(fp);
    Result := FONS_INVALID;
  end;
end;

function fonsAddFontMem(stash: PFONSContext; Name: pchar; Data: pbyte; dataSize, freeData, fontIndex: int32): int32;
var
  i, idx, ascent, descent, fh, lineGap: integer;
  font: PFONSFont;
begin
  idx := fons__allocFont(stash);
  if idx = FONS_INVALID then
  begin
    Result := FONS_INVALID;
    Exit;
  end;

  font := stash^.fonts[idx];

  StrLCopy(font^.Name, Name, SizeOf(font^.Name) - 1);
  font^.Name[SizeOf(font^.Name) - 1] := #0;

  for i := 0 to FONS_HASH_LUT_SIZE - 1 do
    font^.lut[i] := -1;

  font^.dataSize := dataSize;
  font^.Data := Data;
  font^.freeData := freeData;

  stash^.nscratch := 0;
  if not fons__tt_loadFont(stash, @font^.font, Data, dataSize, fontIndex) then
  begin
    fons__freeFont(font);
    stash^.fonts[idx] := nil;
    Dec(stash^.nfonts);
    Result := FONS_INVALID;
    Exit;
  end;

  fons__tt_getFontVMetrics(@font^.font, @ascent, @descent, @lineGap);
  ascent := ascent + lineGap;
  fh := ascent - descent;
  font^.ascender := ascent / fh;
  font^.descender := descent / fh;
  font^.lineh := font^.ascender - font^.descender;

  Result := idx;
end;

function fonsGetFontByName(stash: PFONSContext; Name: pchar): int32;
var
  i: integer;
begin
  for i := 0 to stash^.nfonts - 1 do
  begin
    if StrComp(stash^.fonts[i]^.Name, Name) = 0 then
    begin
      Result := i;
      Exit;
    end;
  end;
  Result := FONS_INVALID;
end;

function fonsAddFallbackFont(stash: PFONSContext; base, fallback: integer): integer;
var
  baseFont: PFONSFont;
begin
  if (base < 0) or (base >= stash^.nfonts) or (fallback < 0) or (fallback >= stash^.nfonts) then
  begin
    Result := 0;
    Exit;
  end;
  baseFont := stash^.fonts[base];
  if baseFont^.nfallbacks < FONS_MAX_FALLBACKS then
  begin
    baseFont^.fallbacks[baseFont^.nfallbacks] := fallback;
    Inc(baseFont^.nfallbacks);
    Result := 1;
  end
  else
    Result := 0;
end;

procedure fonsResetFallbackFont(stash: PFONSContext; base: integer);
var
  baseFont: PFONSFont;
  i: integer;
begin
  if (base < 0) or (base >= stash^.nfonts) then
    Exit;
  baseFont := stash^.fonts[base];
  baseFont^.nfallbacks := 0;
  baseFont^.nglyphs := 0;
  for i := 0 to FONS_HASH_LUT_SIZE - 1 do
    baseFont^.lut[i] := -1;
end;

procedure fonsSetSize(stash: PFONSContext; size: single);
begin
  if stash = nil then
    Exit;
  fons__getState(stash)^.size := size;
end;

procedure fonsSetColor(stash: PFONSContext; color: cardinal);
begin
  if stash = nil then
    Exit;
  fons__getState(stash)^.color := color;
end;

procedure fonsSetSpacing(stash: PFONSContext; spacing: single);
begin
  if stash = nil then
    Exit;
  fons__getState(stash)^.spacing := spacing;
end;

procedure fonsSetBlur(stash: PFONSContext; blur: single);
begin
  if stash = nil then
    Exit;
  fons__getState(stash)^.blur := blur;
end;

procedure fonsSetAlign(stash: PFONSContext; align: TFONSAligns);
begin
  if stash = nil then
    Exit;
  fons__getState(stash)^.align := align;
end;

procedure fonsSetFont(stash: PFONSContext; font: int32);
begin
  if stash = nil then
    Exit;
  fons__getState(stash)^.font := font;
end;

procedure fonsPushState(stash: PFONSContext);
begin
  if stash = nil then
    Exit;
  if stash^.nstates >= FONS_MAX_STATES then
  begin
    if Assigned(stash^.handleError) then
      stash^.handleError(stash^.errorUptr, FONS_STATES_OVERFLOW, 0);
    Exit;
  end;
  if stash^.nstates > 0 then
    Move(stash^.states[stash^.nstates - 1], stash^.states[stash^.nstates], SizeOf(TFONSState));
  Inc(stash^.nstates);
end;

procedure fonsPopState(stash: PFONSContext);
begin
  if stash = nil then
    Exit;
  if stash^.nstates <= 1 then
  begin
    if Assigned(stash^.handleError) then
      stash^.handleError(stash^.errorUptr, FONS_STATES_UNDERFLOW, 0);
    Exit;
  end;
  Dec(stash^.nstates);
end;

procedure fonsClearState(stash: PFONSContext);
var
  state: PFONSState;
begin
  if stash = nil then
    Exit;
  state := fons__getState(stash);
  state^.size := 12.0;
  state^.color := $FFFFFFFF;
  state^.font := 0;
  state^.blur := 0;
  state^.spacing := 0;
  state^.align := [FONS_ALIGN_LEFT, FONS_ALIGN_BASELINE];
end;

function fons__allocGlyph(font: PFONSFont): PFONSGlyph;
begin
  if font^.nglyphs + 1 > font^.cglyphs then
  begin
    if font^.cglyphs = 0 then
      font^.cglyphs := 8
    else
      font^.cglyphs := font^.cglyphs * 2;
    ReallocMem(font^.glyphs, SizeOf(TFONSglyph) * font^.cglyphs);
    if font^.glyphs = nil then
    begin
      Result := nil;
      Exit;
    end;
  end;
  Inc(font^.nglyphs);
  Result := @font^.glyphs[font^.nglyphs - 1];
end;

procedure fons__blurCols(dst: pbyte; w, h, dstStride, alpha: integer);
var
  x, y, z: integer;
begin
  for y := 0 to h - 1 do
  begin
    z := 0;
    for x := 1 to w - 1 do
    begin
      z := z + (alpha * ((dst[x] shl ZPREC) - z)) shr APREC;
      dst[x] := z shr ZPREC;
    end;
    dst[w - 1] := 0;
    z := 0;
    for x := w - 2 downto 0 do
    begin
      z := z + (alpha * ((dst[x] shl ZPREC) - z)) shr APREC;
      dst[x] := z shr ZPREC;
    end;
    dst[0] := 0;
    Inc(dst, dstStride);
  end;
end;

procedure fons__blurRows(dst: pbyte; w, h, dstStride, alpha: integer);
var
  x, y, z: integer;
begin
  for x := 0 to w - 1 do
  begin
    z := 0;
    for y := dstStride to (h - 1) * dstStride do
    begin
      z := z + (alpha * ((dst[y] shl ZPREC) - z)) shr APREC;
      dst[y] := z shr ZPREC;
    end;
    dst[(h - 1) * dstStride] := 0;
    z := 0;
    for y := (h - 2) * dstStride downto 0 do
    begin
      z := z + (alpha * ((dst[y] shl ZPREC) - z)) shr APREC;
      dst[y] := z shr ZPREC;
    end;
    dst[0] := 0;
    Inc(dst);
  end;
end;

procedure fons__blur(stash: PFONSContext; dst: pbyte; w, h, dstStride, blur: integer);
var
  alpha: integer;
  sigma: single;
begin
  if blur < 1 then
    Exit;
  sigma := blur * 0.57735;
  alpha := Round((1 shl APREC) * (1.0 - Exp(-2.3 / (sigma + 1.0))));
  fons__blurRows(dst, w, h, dstStride, alpha);
  fons__blurCols(dst, w, h, dstStride, alpha);
  fons__blurRows(dst, w, h, dstStride, alpha);
  fons__blurCols(dst, w, h, dstStride, alpha);
end;

function fons__getGlyph(stash: PFONSContext; font: PFONSFont; codepoint: cardinal; isize, iblur: int32; bitmapOption: TFONSGlyphBitmap): PFONSGlyph;
var
  i, g, advance, lsb, x0, y0, x1, y1, gw, gh, gx, gy, x, y: integer;
  scale: single;
  renderFont: PFONSFont;
  glyph: PFONSGlyph;
  h, pad, added: integer;
  bdst, dst: pbyte;
begin
  if (isize < 2) or (iblur > 20) then
  begin
    if iblur > 20 then
      iblur := 20;
    Result := nil;
    Exit;
  end;
  pad := iblur + 2;

  stash^.nscratch := 0;

  h := fons__hashint(codepoint) and (FONS_HASH_LUT_SIZE - 1);
  i := font^.lut[h];
  while i <> -1 do
  begin
    if (font^.glyphs[i].codepoint = codepoint) and (font^.glyphs[i].size = isize) and (font^.glyphs[i].blur = iblur) then
    begin
      glyph := @(font^.glyphs[i]);
      if (FONS_GLYPH_BITMAP_OPTIONAL = bitmapOption) or ((glyph^.x0 >= 0) and (glyph^.y0 >= 0)) then
      begin
        Result := glyph;
        Exit;
      end;
      Break;
    end;
    i := font^.glyphs[i].Next;
  end;

  renderFont := font;
  g := fons__tt_getGlyphIndex(@font^.font, codepoint);
  if g = 0 then
  begin
    for i := 0 to font^.nfallbacks - 1 do
    begin
      renderFont := stash^.fonts[font^.fallbacks[i]];
      g := fons__tt_getGlyphIndex(@renderFont^.font, codepoint);
      if g <> 0 then
        Break;
    end;
  end;

  scale := fons__tt_getPixelHeightScale(@renderFont^.font, isize / 10.0);
  fons__tt_buildGlyphBitmap(@renderFont^.font, g, isize / 10.0, scale, @advance, @lsb, @x0, @y0, @x1, @y1);
  gw := x1 - x0 + pad * 2;
  gh := y1 - y0 + pad * 2;

  if bitmapOption = FONS_GLYPH_BITMAP_REQUIRED then
  begin
    added := fons__atlasAddRect(stash^.atlas, gw, gh, @gx, @gy);
    if (added = 0) and Assigned(stash^.handleError) then
    begin
      stash^.handleError(stash^.errorUptr, FONS_ATLAS_FULL, 0);
      added := fons__atlasAddRect(stash^.atlas, gw, gh, @gx, @gy);
    end;
    if added = 0 then
    begin
      Result := nil;
      Exit;
    end;
  end
  else
  begin
    gx := -1;
    gy := -1;
  end;

  glyph := fons__allocGlyph(font);
  if glyph = nil then
  begin
    Result := nil;
    Exit;
  end;

  glyph^.codepoint := codepoint;
  glyph^.size := isize;
  glyph^.blur := iblur;
  glyph^.Next := font^.lut[h];
  font^.lut[h] := font^.nglyphs - 1;

  glyph^.index := g;
  glyph^.x0 := gx;
  glyph^.y0 := gy;
  glyph^.x1 := glyph^.x0 + gw;
  glyph^.y1 := glyph^.y0 + gh;
  glyph^.xadv := Round(scale * advance * 10.0);
  glyph^.xoff := x0 - pad;
  glyph^.yoff := y0 - pad;

  if bitmapOption = FONS_GLYPH_BITMAP_OPTIONAL then
  begin
    Result := glyph;
    Exit;
  end;

  dst := @stash^.texData[(glyph^.x0 + pad) + (glyph^.y0 + pad) * stash^.params.Width];
  fons__tt_renderGlyphBitmap(@renderFont^.font, dst, gw - pad * 2, gh - pad * 2, stash^.params.Width, scale, scale, g);

  dst := @stash^.texData[glyph^.x0 + glyph^.y0 * stash^.params.Width];
  for y := 0 to gh - 1 do
  begin
    dst[y * stash^.params.Width] := 0;
    dst[gw - 1 + y * stash^.params.Width] := 0;
  end;
  for x := 0 to gw - 1 do
  begin
    dst[x] := 0;
    dst[x + (gh - 1) * stash^.params.Width] := 0;
  end;

  if iblur > 0 then
  begin
    stash^.nscratch := 0;
    bdst := @stash^.texData[glyph^.x0 + glyph^.y0 * stash^.params.Width];
    fons__blur(stash, bdst, gw, gh, stash^.params.Width, iblur);
  end;

  stash^.dirtyRect[0] := fons__mini(stash^.dirtyRect[0], glyph^.x0);
  stash^.dirtyRect[1] := fons__mini(stash^.dirtyRect[1], glyph^.y0);
  stash^.dirtyRect[2] := fons__maxi(stash^.dirtyRect[2], glyph^.x1);
  stash^.dirtyRect[3] := fons__maxi(stash^.dirtyRect[3], glyph^.y1);

  Result := glyph;
end;

procedure fons__getQuad(stash: PFONSContext; font: PFONSFont; prevGlyphIndex: integer; glyph: PFONSglyph; scale, spacing: single; x, y: PSingle; q: PFONSQuad);
var
  rx, ry, xoff, yoff, x0, y0, x1, y1, adv: single;
begin
  if prevGlyphIndex <> -1 then
  begin
    adv := fons__tt_getGlyphKernAdvance(@font^.font, prevGlyphIndex, glyph^.index) * scale;
    x^ := x^ + Round(adv + spacing + 0.5);
  end;

  xoff := glyph^.xoff + 1;
  yoff := glyph^.yoff + 1;
  x0 := glyph^.x0 + 1;
  y0 := glyph^.y0 + 1;
  x1 := glyph^.x1 - 1;
  y1 := glyph^.y1 - 1;

  if (FONS_ZERO_TOPLEFT in stash^.params.flags) then
  begin
    rx := Floor(x^ + xoff);
    ry := Floor(y^ + yoff);

    q^.x0 := rx;
    q^.y0 := ry;
    q^.x1 := rx + x1 - x0;
    q^.y1 := ry + y1 - y0;

    q^.s0 := x0 * stash^.itw;
    q^.t0 := y0 * stash^.ith;
    q^.s1 := x1 * stash^.itw;
    q^.t1 := y1 * stash^.ith;
  end
  else
  begin
    rx := Floor(x^ + xoff);
    ry := Floor(y^ - yoff);

    q^.x0 := rx;
    q^.y0 := ry;
    q^.x1 := rx + x1 - x0;
    q^.y1 := ry - y1 + y0;

    q^.s0 := x0 * stash^.itw;
    q^.t0 := y0 * stash^.ith;
    q^.s1 := x1 * stash^.itw;
    q^.t1 := y1 * stash^.ith;
  end;

  x^ := x^ + Round(glyph^.xadv / 10.0 + 0.5);
end;

procedure fons__flush(stash: PFONSContext);
begin
  if (stash^.dirtyRect[0] < stash^.dirtyRect[2]) and (stash^.dirtyRect[1] < stash^.dirtyRect[3]) then
  begin
    if Assigned(stash^.params.renderUpdate) then
      stash^.params.renderUpdate(stash^.params.userPtr, @stash^.dirtyRect, stash^.texData);
    stash^.dirtyRect[0] := stash^.params.Width;
    stash^.dirtyRect[1] := stash^.params.Height;
    stash^.dirtyRect[2] := 0;
    stash^.dirtyRect[3] := 0;
  end;

  if stash^.nverts > 0 then
  begin
    if Assigned(stash^.params.renderDraw) then
      stash^.params.renderDraw(stash^.params.userPtr, @stash^.verts, @stash^.tcoords, @stash^.colors, stash^.nverts);
    stash^.nverts := 0;
  end;
end;

procedure fons__vertex(stash: PFONSContext; x, y, s, t: single; c: cardinal);
begin
  stash^.verts[stash^.nverts * 2 + 0] := x;
  stash^.verts[stash^.nverts * 2 + 1] := y;
  stash^.tcoords[stash^.nverts * 2 + 0] := s;
  stash^.tcoords[stash^.nverts * 2 + 1] := t;
  stash^.colors[stash^.nverts] := c;
  Inc(stash^.nverts);
end;

function fons__getVertAlign(stash: PFONSContext; font: PFONSFont; align: int32; isize: smallint): single;
begin
  if (FONS_ZERO_TOPLEFT in stash^.params.flags) then
  begin
    if (FONS_ALIGN_TOP in align) then
      Result := font^.ascender * (isize / 10.0)
    else if (FONS_ALIGN_MIDDLE in align) then
      Result := (font^.ascender + font^.descender) / 2.0 * (isize / 10.0)
    else if (FONS_ALIGN_BASELINE in align) then
      Result := 0.0
    else if (FONS_ALIGN_BOTTOM in align) then
      Result := font^.descender * (isize / 10.0)
    else
      Result := 0.0;
  end
  else
  begin
    if (FONS_ALIGN_TOP in align) then
      Result := -font^.ascender * (isize / 10.0)
    else if (FONS_ALIGN_MIDDLE in align) then
      Result := -(font^.ascender + font^.descender) / 2.0 * (isize / 10.0)
    else if (FONS_ALIGN_BASELINE in align) then
      Result := 0.0
    else if (FONS_ALIGN_BOTTOM in align) then
      Result := -font^.descender * (isize / 10.0)
    else
      Result := 0.0;
  end;
end;

function fonsDrawText(stash: PFONSContext; x, y: single; str, end_: pchar): single;
var
  state: PFONSState;
  codepoint, utf8state: cardinal;
  glyph: PFONSglyph;
  q: TFONSQuad;
  prevGlyphIndex: integer;
  isize, iblur: smallint;
  scale, Width: single;
  font: PFONSFont;
begin
  state := fons__getState(stash);
  if (stash = nil) or (state^.font < 0) or (state^.font >= stash^.nfonts) then
  begin
    Result := x;
    Exit;
  end;
  font := stash^.fonts[state^.font];
  if font^.Data = nil then
  begin
    Result := x;
    Exit;
  end;

  scale := fons__tt_getPixelHeightScale(@font^.font, state^.size / 10.0);

  if end_ = nil then
    end_ := str + StrLen(str);

  if not (FONS_ALIGN_LEFT in state^.align) then
  begin
    Width := fonsTextBounds(stash, x, y, str, end_, nil);
    if (FONS_ALIGN_RIGHT in state^.align) then
      x := x - Width
    else if (FONS_ALIGN_CENTER in state^.align) then
      x := x - Width * 0.5;
  end;

  y := y + fons__getVertAlign(stash, font, state^.align, Round(state^.size * 10.0));

  utf8state := 0;
  prevGlyphIndex := -1;
  isize := Round(state^.size * 10.0);
  iblur := Round(state^.blur);

  while str <> end_ do
  begin
    if fons__decutf8(@utf8state, @codepoint, Ord(str^)) then
    begin
      Inc(str);
      Continue;
    end;
    glyph := fons__getGlyph(stash, font, codepoint, isize, iblur, FONS_GLYPH_BITMAP_REQUIRED);
    if glyph <> nil then
    begin
      fons__getQuad(stash, font, prevGlyphIndex, glyph, scale, state^.spacing, @x, @y, @q);
      if stash^.nverts + 6 > FONS_VERTEX_COUNT then
        fons__flush(stash);

      fons__vertex(stash, q.x0, q.y0, q.s0, q.t0, state^.color);
      fons__vertex(stash, q.x1, q.y1, q.s1, q.t1, state^.color);
      fons__vertex(stash, q.x1, q.y0, q.s1, q.t0, state^.color);

      fons__vertex(stash, q.x0, q.y0, q.s0, q.t0, state^.color);
      fons__vertex(stash, q.x0, q.y1, q.s0, q.t1, state^.color);
      fons__vertex(stash, q.x1, q.y1, q.s1, q.t1, state^.color);
    end;
    prevGlyphIndex := iif(glyph <> nil, glyph^.index, -1);
    Inc(str);
  end;

  fons__flush(stash);
  Result := x;
end;

function fonsTextIterInit(stash: PFONSContext; iter: PFONSTextIter; x, y: single; str, end_: pchar; bitmapOption: TFONSGlyphBitmap): boolean;
var
  state: PFONSState;
  Width: single;
begin
  Result := False;
  FillChar(iter^, SizeOf(TFONSTextIter), 0);

  if stash = nil then
  begin
    Exit;
  end;

  state := fons__getState(stash);
  if (state^.font < 0) or (state^.font >= stash^.nfonts) then
  begin
    Exit;
  end;

  iter^.font := stash^.fonts[state^.font];
  if iter^.font^.Data = nil then
  begin
    Exit;
  end;

  iter^.isize := Round(state^.size * 10.0);
  iter^.iblur := Round(state^.blur);
  iter^.scale := fons__tt_getPixelHeightScale(@iter^.font^.font, iter^.isize / 10.0);

  if not (FONS_ALIGN_LEFT in state^.align) then
  begin
    Width := fonsTextBounds(stash, x, y, str, end_, nil);
    if (FONS_ALIGN_RIGHT in state^.align) then
      x := x - Width
    else if (FONS_ALIGN_CENTER in state^.align) then
      x := x - Width * 0.5;
  end;

  y := y + fons__getVertAlign(stash, iter^.font, state^.align, iter^.isize);

  if end_ = nil then
    end_ := str + StrLen(str);

  iter^.x := x;
  iter^.nextx := x;
  iter^.y := y;
  iter^.nexty := y;
  iter^.spacing := state^.spacing;
  iter^.str := str;
  iter^.Next := str;
  iter^.stop := end_;
  iter^.codepoint := 0;
  iter^.prevGlyphIndex := -1;
  iter^.bitmapOption := bitmapOption;

  Result := true;
end;

function fonsTextIterNext(stash: PFONSContext; iter: PFONSTextIter;
  quad: PFONSQuad): boolean;
var
  glyph: PFONSglyph;
  str: pchar;
begin
  result := false;
  str := iter^.Next;
  iter^.str := iter^.Next;

  if str = iter^.stop then
  begin
    Exit;
  end;

  while str <> iter^.stop do
  begin
    if fons__decutf8(@iter^.utf8state, @iter^.codepoint, Ord(str^)) then
    begin
      Inc(str);
      Continue;
    end;
    Inc(str);

    iter^.x := iter^.nextx;
    iter^.y := iter^.nexty;
    glyph := fons__getGlyph(stash, iter^.font, iter^.codepoint, iter^.isize, iter^.iblur, iter^.bitmapOption);
    if glyph <> nil then
      fons__getQuad(stash, iter^.font, iter^.prevGlyphIndex, glyph, iter^.scale, iter^.spacing, @iter^.nextx, @iter^.nexty, quad);
    iter^.prevGlyphIndex := iif(glyph <> nil, glyph^.index, -1);
    Break;
  end;
  iter^.Next := str;
  Result := true;
end;

function fonsTextBounds(stash: PFONSContext; x, y: single; str, end_: pchar; bounds: PSingle): single;
var
  state: PFONSState;
  codepoint, utf8state: cardinal;
  glyph: PFONSglyph;
  prevGlyphIndex: integer;
  isize, iblur: smallint;
  scale, startx, advance: single;
  font: PFONSFont;
  q: TFONSQuad;
  minx, miny, maxx, maxy: single;
begin
  state := fons__getState(stash);
  if (stash = nil) or (state^.font < 0) or (state^.font >= stash^.nfonts) then
  begin
    Result := x;
    Exit;
  end;
  font := stash^.fonts[state^.font];
  if font^.Data = nil then
  begin
    Result := x;
    Exit;
  end;

  scale := fons__tt_getPixelHeightScale(@font^.font, state^.size / 10.0);
  isize := Round(state^.size * 10.0);
  iblur := Round(state^.blur);

  if end_ = nil then
    end_ := str + StrLen(str);

  startx := x;
  minx := x;
  maxx := x;
  miny := y;
  maxy := y;

  y := y + fons__getVertAlign(stash, font, state^.align, isize);

  utf8state := 0;
  prevGlyphIndex := -1;

  while str <> end_ do
  begin
    if fons__decutf8(@utf8state, @codepoint, Ord(str^)) then
    begin
      Inc(str);
      Continue;
    end;
    glyph := fons__getGlyph(stash, font, codepoint, isize, iblur, FONS_GLYPH_BITMAP_OPTIONAL);
    if glyph <> nil then
    begin
      fons__getQuad(stash, font, prevGlyphIndex, glyph, scale, state^.spacing, @x, @y, @q);
      if q.x0 < minx then minx := q.x0;
      if q.x1 > maxx then maxx := q.x1;
      if (FONS_ZERO_TOPLEFT in stash^.params.flags) then
      begin
        if q.y0 < miny then miny := q.y0;
        if q.y1 > maxy then maxy := q.y1;
      end
      else
      begin
        if q.y1 < miny then miny := q.y1;
        if q.y0 > maxy then maxy := q.y0;
      end;
    end;
    prevGlyphIndex := iif(glyph <> nil, glyph^.index, -1);
    Inc(str);
  end;

  advance := x - startx;

  if not (FONS_ALIGN_LEFT in state^.align) then
  begin
    if (FONS_ALIGN_RIGHT in state^.align) then
    begin
      minx := minx - advance;
      maxx := maxx - advance;
    end
    else if (FONS_ALIGN_CENTER in state^.align) then
    begin
      minx := minx - advance * 0.5;
      maxx := maxx - advance * 0.5;
    end;
  end;

  if bounds <> nil then
  begin
    bounds[0] := minx;
    bounds[1] := miny;
    bounds[2] := maxx;
    bounds[3] := maxy;
  end;

  Result := advance;
end;

procedure fonsLineBounds(stash: PFONSContext; y: single; miny, maxy: PSingle);
var
  state: PFONSState;
  font: PFONSFont;
  scale: single;
begin
  if stash = nil then
    Exit;
  state := fons__getState(stash);
  if (state^.font < 0) or (state^.font >= stash^.nfonts) then
    Exit;
  font := stash^.fonts[state^.font];
  if font^.Data = nil then
    Exit;

  y := y + fons__getVertAlign(stash, font, state^.align, Round(state^.size * 10.0));
  scale := fons__tt_getPixelHeightScale(@font^.font, state^.size / 10.0);

  if (FONS_ZERO_TOPLEFT in stash^.params.flags) then
  begin
    miny^ := y - font^.ascender * scale;
    maxy^ := y - font^.descender * scale;
  end
  else
  begin
    miny^ := y + font^.descender * scale;
    maxy^ := y + font^.ascender * scale;
  end;
end;

procedure fonsVertMetrics(stash: PFONSContext; ascender, descender, lineh: PSingle);
var
  state: PFONSState;
  font: PFONSFont;
  scale: single;
begin
  if stash = nil then
    Exit;
  state := fons__getState(stash);
  if (state^.font < 0) or (state^.font >= stash^.nfonts) then
    Exit;
  font := stash^.fonts[state^.font];
  if font^.Data = nil then
    Exit;

  scale := fons__tt_getPixelHeightScale(@font^.font, state^.size / 10.0);

  if ascender <> nil then
    ascender^ := font^.ascender * scale;
  if descender <> nil then
    descender^ := font^.descender * scale;
  if lineh <> nil then
    lineh^ := font^.lineh * scale;
end;

function fonsGetTextureData(stash: PFONSContext; Width, Height: PInt32): pbyte;
begin
  if stash = nil then
  begin
    Result := nil;
    Exit;
  end;
  Width^ := stash^.params.Width;
  Height^ := stash^.params.Height;
  Result := stash^.texData;
end;

function fonsValidateTexture(stash: PFONSContext; dirty: PInt32): boolean;
begin
  if (stash^.dirtyRect[0] < stash^.dirtyRect[2]) and (stash^.dirtyRect[1] < stash^.dirtyRect[3]) then
  begin
    dirty[0] := stash^.dirtyRect[0];
    dirty[1] := stash^.dirtyRect[1];
    dirty[2] := stash^.dirtyRect[2];
    dirty[3] := stash^.dirtyRect[3];
    stash^.dirtyRect[0] := stash^.params.Width;
    stash^.dirtyRect[1] := stash^.params.Height;
    stash^.dirtyRect[2] := 0;
    stash^.dirtyRect[3] := 0;
    Result := True;
  end
  else
    Result := False;
end;

procedure fonsDrawDebug(stash: PFONSContext; x, y: single);
var
  state: PFONSState;
  i, j: integer;
  font: PFONSFont;
  glyph: PFONSglyph;
  q: TFONSQuad;
  scale, s, t: single;
begin
  if stash = nil then
    Exit;

  state := fons__getState(stash);
  for i := 0 to stash^.nfonts - 1 do
  begin
    font := stash^.fonts[i];
    if font^.Data = nil then
      Continue;

    scale := fons__tt_getPixelHeightScale(@font^.font, state^.size / 10.0);
    y := y + fons__getVertAlign(stash, font, state^.align, Round(state^.size * 10.0));

    for j := 0 to font^.nglyphs - 1 do
    begin
      glyph := @font^.glyphs[j];
      if (glyph^.x0 < 0) or (glyph^.y0 < 0) then
        Continue;

      fons__getQuad(stash, font, -1, glyph, scale, state^.spacing, @x, @y, @q);

      if stash^.nverts + 6 > FONS_VERTEX_COUNT then
        fons__flush(stash);

      s := glyph^.x0 * stash^.itw;
      t := glyph^.y0 * stash^.ith;

      fons__vertex(stash, q.x0, q.y0, s, t, state^.color);
      fons__vertex(stash, q.x1, q.y1, s + (glyph^.x1 - glyph^.x0) * stash^.itw, t + (glyph^.y1 - glyph^.y0) * stash^.ith, state^.color);
      fons__vertex(stash, q.x1, q.y0, s + (glyph^.x1 - glyph^.x0) * stash^.itw, t, state^.color);

      fons__vertex(stash, q.x0, q.y0, s, t, state^.color);
      fons__vertex(stash, q.x0, q.y1, s, t + (glyph^.y1 - glyph^.y0) * stash^.ith, state^.color);
      fons__vertex(stash, q.x1, q.y1, s + (glyph^.x1 - glyph^.x0) * stash^.itw, t + (glyph^.y1 - glyph^.y0) * stash^.ith, state^.color);
    end;
  end;

  fons__flush(stash);
end;


end.
