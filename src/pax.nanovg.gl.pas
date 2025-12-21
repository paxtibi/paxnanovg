unit pax.nanovg.gl;
{$mode objfpc}{$H+}

interface

uses
  Classes, Math, SysUtils, pax.nanovg, paxutils, pax.gl;

const
  NVG_ANTIALIAS = 1 shl 0; // Indica se viene utilizzato l'antialiasing basato sulla geometria
  NVG_STENCIL_STROKES = 1 shl 1; // Indica se i tratti usano il buffer stencil (più lento, ma gestisce sovrapposizioni)
  NVG_DEBUG = 1 shl 2; // Abilita controlli di debug aggiuntivi

  // Flag aggiuntivi per le immagini
  NVG_IMAGE_NODELETE = 1 shl 16; // Non eliminare l'handle della texture GetOpenGL

  // Costanti per i tipi di shader
  NSVG_SHADER_FILLGRAD = 0;
  NSVG_SHADER_FILLIMG = 1;
  NSVG_SHADER_SIMPLE = 2;
  NSVG_SHADER_IMG = 3;

type
  // Posizioni uniform per lo shader
  TGLNVGUniformLoc = (
    GLNVG_LOC_VIEWSIZE,
    GLNVG_LOC_TEX,
    GLNVG_LOC_FRAG,
    GLNVG_MAX_LOCS
    );

  // Struttura per lo shader GetOpenGL
  TGLNVGShader = record
    Prog: GLuint; // Programma shader
    Frag: GLuint; // Shader frammento
    Vert: GLuint; // Shader vertice
    Loc: array[TGLNVGUniformLoc] of GLint; // Posizioni uniform
  end;
  PGLNVGShader = ^TGLNVGShader;

  // Struttura per la texture
  TGLNVGTexture = record
    ID: int32; // ID della texture
    Tex: GLuint; // Handle GetOpenGL della texture
    Width, Height: int32; // Dimensioni
    TexType: int32; // Tipo (NVG_TEXTURE_RGBA, NVG_TEXTURE_ALPHA)
    Flags: int32; // Flag immagine
  end;
  PGLNVGTexture = ^TGLNVGTexture;

  // Struttura per il blending
  TGLNVGBlend = record
    SrcRGB: GLenum;
    DstRGB: GLenum;
    SrcAlpha: GLenum;
    DstAlpha: GLenum;
  end;
  PGLNVGBlend = ^TGLNVGBlend;

  // Tipi di chiamata
  TGLNVGCallType = (
    GLNVG_NONE = 0,
    GLNVG_FILL,
    GLNVG_CONVEXFILL,
    GLNVG_STROKE,
    GLNVG_TRIANGLES
    );

  // Struttura per una chiamata di rendering
  TGLNVGCall = record
    CallType: TGLNVGCallType; // Tipo di chiamata
    Image: int32; // ID immagine
    PathOffset: int32; // Offset percorsi
    PathCount: int32; // Numero percorsi
    TriangleOffset: int32; // Offset triangoli
    TriangleCount: int32; // Numero triangoli
    UniformOffset: int32; // Offset uniform
    BlendFunc: TGLNVGBlend; // Funzione di blending
  end;
  PGLNVGCall = ^TGLNVGCall;

  // Struttura per un percorso
  TGLNVGPath = record
    FillOffset: int32; // Offset riempimento
    FillCount: int32; // Conteggio vertici riempimento
    StrokeOffset: int32; // Offset tratto
    StrokeCount: int32; // Conteggio vertici tratto
  end;
  PGLNVGPath = ^TGLNVGPath;

  // Struttura per uniform del frammento
  TGLNVGFragUniforms = record
    ScissorMat: array[0..11] of single; // Matrice 3x4 (3 vec4)
    PaintMat: array[0..11] of single; // Matrice 3x4 (3 vec4)
    InnerCol: TNVGColor; // Colore interno
    OuterCol: TNVGColor; // Colore esterno
    ScissorExt: array[0..1] of single; // Estensione scissor
    ScissorScale: array[0..1] of single; // Scala scissor
    Extent: array[0..1] of single; // Estensione pittura
    Radius: single; // Raggio
    Feather: single; // Sfumatura
    StrokeMult: single; // Moltiplicatore tratto
    StrokeThr: single; // Soglia tratto
    TexType: int32; // Tipo texture
    ShaderType: int32; // Tipo shader
  end;
  PGLNVGFragUniforms = ^TGLNVGFragUniforms;

  // Contesto GetOpenGL
  TGLContext = class
    Shader: TGLNVGShader; // Shader
    Textures: PGLNVGTexture; // Array di texture
    View: array[0..1] of single; // Dimensioni viewport
    NTextures: int32; // Numero texture
    CTextures: int32; // Capacità texture
    TextureID: int32; // ID texture corrente
    VertBuf: GLuint; // Buffer vertici
    {$IFDEF NANOVG_GL3}
    VertArr: GLuint; // Array vertici
    {$ENDIF}
    {$IFDEF NANOVG_GL_USE_UNIFORMBUFFER}
    FragBuf: GLuint; // Buffer uniform frammento
    {$ENDIF}
    FragSize: int32; // Dimensione uniform frammento
    Flags: int32; // Flag contesto
    Calls: PGLNVGCall; // Array chiamate
    CCalls: int32; // Capacità chiamate
    NCalls: int32; // Numero chiamate
    Paths: PGLNVGPath; // Array percorsi
    CPaths: int32; // Capacità percorsi
    NPaths: int32; // Numero percorsi
    Verts: PNVGVertex; // Array vertici
    CVerts: int32; // Capacità vertici
    NVerts: int32; // Numero vertici
    Uniforms: pbyte; // Array uniform
    CUniforms: int32; // Capacità uniform
    NUniforms: int32; // Numero uniform
    {$IFDEF NANOVG_GL_USE_STATE_FILTER}
    BoundTexture: GLuint; // Texture legata
    StencilMask: GLuint; // Maschera stencil
    StencilFunc: GLenum; // Funzione stencil
    StencilFuncRef: GLint; // Riferimento stencil
    StencilFuncMask: GLuint; // Maschera funzione stencil
    BlendFunc: TGLNVGBlend; // Funzione blending
    {$ENDIF}
    DummyTex: int32; // Texture vuota
  end;

function nvgCreateGL2(Flags: int32): TNVContext;
procedure nvgDeleteGL2(Ctx: TNVContext);
function nvglCreateImageFromHandleGL2(Ctx: TNVContext; TextureID: GLuint; W, H, ImageFlags: int32): int32;
function nvglImageHandleGL2(Ctx: TNVContext; Image: int32): GLuint;

function nvgCreateGL3(Flags: int32): TNVContext; inline;
procedure nvgDeleteGL3(Ctx: TNVContext); inline;
function nvglCreateImageFromHandleGL3(Ctx: TNVContext; TextureID: GLuint; W, H, ImageFlags: int32): int32; inline;
function nvglImageHandleGL3(Ctx: TNVContext; Image: int32): GLuint; inline;


implementation

uses
  {$ifdef MSWINDOWS}
  Windows,
  {$endif}
  LResources;

  {$R ..\res\shaders.res}


generic function IfThen<T>(val: boolean; const iftrue: T; const iffalse: T): T; inline; overload;
begin
  if val then
    Result := ifTrue
  else
    Result := ifFalse;
end;


function IfThen(val: boolean; const iftrue: pchar; const iffalse: pchar): pchar; inline; overload;
begin
  if val then
    Result := ifTrue
  else
    Result := ifFalse;
end;

function IfThen(val: boolean; const iftrue: boolean; const iffalse: boolean): boolean; inline; overload;
begin
  if val then
    Result := ifTrue
  else
    Result := ifFalse;
end;



function LoadResourceString(ResourceName: string): string;
var
  Res: TResourceStream;
  Str: string = '';
begin
  Res := TResourceStream.Create(HInstance, ResourceName, PChar(RT_RCDATA));
  try
    SetLength(Str, Res.Size);
    Res.ReadBuffer(Str[1], Res.Size);
    Result := Str;
  finally
    Res.Free;
  end;
end;

function glnvg__MaxI(A, B: int32): int32;
begin
  if A > B then
    Result := A
  else
    Result := B;
end;

{$IFDEF NANOVG_GLES2}
function glnvg__NearestPow2(Num: Cardinal): Cardinal;
var
  N: Cardinal;
begin
  N := IfThen(Num > 0, Num - 1, 0);
  N := N or (N shr 1);
  N := N or (N shr 2);
  N := N or (N shr 4);
  N := N or (N shr 8);
  N := N or (N shr 16);
  Inc(N);
  Result := N;
end;
{$ENDIF}

procedure glnvg__BindTexture(GL: TGLContext; Tex: GLuint);
begin
  {$IFDEF NANOVG_GL_USE_STATE_FILTER}
  if GL^.BoundTexture <> Tex then
  begin
    GL^.BoundTexture := Tex;
    glBindTexture(GL_TEXTURE_2D, Tex);
  end;
  {$ELSE}
  GetOpenGL.glBindTexture(GL_TEXTURE_2D, Tex);
  {$ENDIF}
end;

procedure glnvg__StencilMask(GL: TGLContext; Mask: GLuint);
begin
  {$IFDEF NANOVG_GL_USE_STATE_FILTER}
  if GL^.StencilMask <> Mask then
  begin
    GL^.StencilMask := Mask;
    glStencilMask(Mask);
  end;
  {$ELSE}
  GetOpenGL.glStencilMask(Mask);
  {$ENDIF}
end;

procedure glnvg__StencilFunc(GL: TGLContext; Func: GLenum; Ref: GLint; Mask: GLuint);
begin
  {$IFDEF NANOVG_GL_USE_STATE_FILTER}
  if (GL^.StencilFunc <> Func) or (GL^.StencilFuncRef <> Ref) or (GL^.StencilFuncMask <> Mask) then
  begin
    GL^.StencilFunc := Func;
    GL^.StencilFuncRef := Ref;
    GL^.StencilFuncMask := Mask;
    glStencilFunc(Func, Ref, Mask);
  end;
  {$ELSE}
  GetOpenGL.glStencilFunc(Func, Ref, Mask);
  {$ENDIF}
end;

procedure glnvg__BlendFuncSeparate(GL: TGLContext; Blend: PGLNVGBlend);
begin
  {$IFDEF NANOVG_GL_USE_STATE_FILTER}
  if (GL^.BlendFunc.SrcRGB <> Blend^.SrcRGB) or
     (GL^.BlendFunc.DstRGB <> Blend^.DstRGB) or
     (GL^.BlendFunc.SrcAlpha <> Blend^.SrcAlpha) or
     (GL^.BlendFunc.DstAlpha <> Blend^.DstAlpha) then
  begin
    GL^.BlendFunc := Blend^;
    glBlendFuncSeparate(Blend^.SrcRGB, Blend^.DstRGB, Blend^.SrcAlpha, Blend^.DstAlpha);
  end;
  {$ELSE}
  GetOpenGL.glBlendFuncSeparate(Blend^.SrcRGB, Blend^.DstRGB, Blend^.SrcAlpha, Blend^.DstAlpha);
  {$ENDIF}
end;

function glnvg__AllocTexture(gl: TGLContext): PGLNVGTexture;
var
  oldTextures: PGLNVGTexture;
  oldCount: int32;
begin
  oldCount := gl.ntextures;

  if gl.ntextures + 1 > gl.ctextures then
  begin
    oldTextures := gl.textures;

    if gl.ctextures = 0 then
      gl.ctextures := 4
    else
      gl.ctextures := gl.ctextures * 2;

    gl.textures := ReAllocMem(gl.textures, gl.ctextures * SizeOf(TGLNVGTexture));

    // COPIA CORRETTA DEI DATI VECCHI
    if oldTextures <> nil then
      Move(oldTextures[0], gl.textures[0], oldCount * SizeOf(TGLNVGTexture));
  end;

  Result := @gl.textures[gl.ntextures];
  Inc(gl.ntextures);

  FillChar(Result^, SizeOf(TGLNVGTexture), 0);
  Result^.ID := gl.ntextures;
end;

function glnvg__FindTexture(GL: TGLContext; ID: int32): PGLNVGTexture;
var
  I: int32;
begin
  Result := nil;
  for I := 0 to GL.NTextures - 1 do
  begin
    if GL.Textures[I].ID = ID then
    begin
      Result := @GL.Textures[I];
      Break;
    end;
  end;
end;

function glnvg__DeleteTexture(GL: TGLContext; ID: int32): boolean;
var
  I: int32;
begin
  Result := False;
  for I := 0 to GL.NTextures - 1 do
  begin
    if GL.Textures[I].ID = ID then
    begin
      if (GL.Textures[I].Tex <> 0) and ((GL.Textures[I].Flags and NVG_IMAGE_NODELETE) = 0) then
        GetOpenGL.glDeleteTextures(1, @GL.Textures[I].Tex);
      FillChar(GL.Textures[I], SizeOf(TGLNVGTexture), 0);
      Result := True;
      Break;
    end;
  end;
end;

procedure glnvg__DumpShaderError(Shader: GLuint; Name, ShaderType: string);
var
  Str: array[0..512] of char;
  Len: GLsizei;
begin
  Len := 0;
  GetOpenGL.glGetShaderInfoLog(Shader, 512, @Len, @Str[0]);
  if Len > 512 then
    Len := 512;
  Str[Len] := #0;
  WriteLn(Format('Shader %s/%s error:'#10'%s', [Name, ShaderType, Str]));
end;

procedure glnvg__DumpProgramError(Prog: GLuint; Name: string);
var
  Str: array[0..512] of char;
  Len: GLsizei;
begin
  Len := 0;
  GetOpenGL.glGetProgramInfoLog(Prog, 512, @Len, @Str[0]);
  if Len > 512 then
    Len := 512;
  Str[Len] := #0;
  WriteLn(Format('Program %s error:'#10'%s', [Name, Str]));
end;

procedure glnvg__CheckError(GL: TGLContext; Str: string);
var
  Err: GLenum;
begin
  if (GL.Flags and NVG_DEBUG) = 0 then
    Exit;
  Err := GetOpenGL.glGetError();
  if Err <> GL_NO_ERROR then
    WriteLn(Format('Error %08x after %s', [Err, Str]));
end;

function glnvg__CreateShader(Shader: PGLNVGShader; Name, Header: string; Opts: pchar; VShader, FShader: string): boolean;
var
  Status: GLint;
  Prog, Vert, Frag: GLuint;
  Str: array[0..2] of pchar;
begin
  FillChar(Shader^, SizeOf(TGLNVGShader), 0);
  Prog := GetOpenGL.glCreateProgram();
  Vert := GetOpenGL.glCreateShader(GL_VERTEX_SHADER);
  Frag := GetOpenGL.glCreateShader(GL_FRAGMENT_SHADER);

  Str[0] := PChar(Header);
  Str[1] := IfThen(Opts <> nil, PChar(Opts), '');
  Str[2] := PChar(VShader);
  GetOpenGL.glShaderSource(Vert, 3, @Str[0], nil);
  Str[2] := PChar(FShader);
  GetOpenGL.glShaderSource(Frag, 3, @Str[0], nil);

  GetOpenGL.glCompileShader(Vert);
  GetOpenGL.glGetShaderiv(Vert, GL_COMPILE_STATUS, @Status);
  if Status <> GL_TRUE then
  begin
    glnvg__DumpShaderError(Vert, Name, 'vert');
    GetOpenGL.glDeleteShader(Vert);
    GetOpenGL.glDeleteShader(Frag);
    GetOpenGL.glDeleteProgram(Prog);
    Exit(False);
  end;

  GetOpenGL.glCompileShader(Frag);
  GetOpenGL.glGetShaderiv(Frag, GL_COMPILE_STATUS, @Status);
  if Status <> GL_TRUE then
  begin
    glnvg__DumpShaderError(Frag, Name, 'frag');
    GetOpenGL.glDeleteShader(Vert);
    GetOpenGL.glDeleteShader(Frag);
    GetOpenGL.glDeleteProgram(Prog);
    Exit(False);
  end;

  GetOpenGL.glAttachShader(Prog, Vert);
  GetOpenGL.glAttachShader(Prog, Frag);

  GetOpenGL.glBindAttribLocation(Prog, 0, 'vertex');
  GetOpenGL.glBindAttribLocation(Prog, 1, 'tcoord');

  GetOpenGL.glLinkProgram(Prog);
  GetOpenGL.glGetProgramiv(Prog, GL_LINK_STATUS, @Status);
  if Status <> GL_TRUE then
  begin
    glnvg__DumpProgramError(Prog, Name);
    GetOpenGL.glDeleteShader(Vert);
    GetOpenGL.glDeleteShader(Frag);
    GetOpenGL.glDeleteProgram(Prog);
    Exit(False);
  end;

  Shader^.Prog := Prog;
  Shader^.Vert := Vert;
  Shader^.Frag := Frag;
  Result := True;
end;

procedure glnvg__DeleteShader(Shader: PGLNVGShader);
begin
  if Shader^.Prog <> 0 then
    GetOpenGL.glDeleteProgram(Shader^.Prog);
  if Shader^.Vert <> 0 then
    GetOpenGL.glDeleteShader(Shader^.Vert);
  if Shader^.Frag <> 0 then
    GetOpenGL.glDeleteShader(Shader^.Frag);
end;

procedure glnvg__GetUniforms(Shader: PGLNVGShader);
begin
  Shader^.Loc[GLNVG_LOC_VIEWSIZE] := GetOpenGL.glGetUniformLocation(Shader^.Prog, 'viewSize');
  Shader^.Loc[GLNVG_LOC_TEX] := GetOpenGL.glGetUniformLocation(Shader^.Prog, 'tex');
  {$IFDEF NANOVG_GL_USE_UNIFORMBUFFER}
  Shader^.Loc[GLNVG_LOC_FRAG] := glGetUniformBlockIndex(Shader^.Prog, 'frag');
  {$ELSE}
  Shader^.Loc[GLNVG_LOC_FRAG] := GetOpenGL.glGetUniformLocation(Shader^.Prog, 'frag');
  {$ENDIF}
end;

function glnvg__RenderCreateTexture(Uptr: Pointer; TexType: TNVGTexture; W, H, ImageFlags: int32; Data: pbyte): int32; forward;

function glnvg__RenderCreate(Uptr: Pointer): int32;
var
  GL: TGLContext;
  Align: int32;
  ShaderHeader, FillVertShader, FillFragShader: string;
begin
  GL := TGLContext(Uptr);
  Align := 4;

  glnvg__CheckError(GL, 'init');

  // Carica gli shader dalle risorse
  ShaderHeader := LoadResourceString('SHADER_HEADER');
  FillVertShader := LoadResourceString('FILL_VERT_SHADER');
  FillFragShader := LoadResourceString('FILL_FRAG_SHADER');

  if (GL.Flags and NVG_ANTIALIAS) <> 0 then
  begin
    if not glnvg__CreateShader(@GL.Shader, 'shader', ShaderHeader, '#define EDGE_AA 1'#10, FillVertShader, FillFragShader) then
      Exit(0);
  end
  else
  begin
    if not glnvg__CreateShader(@GL.Shader, 'shader', ShaderHeader, '', FillVertShader, FillFragShader) then
      Exit(0);
  end;

  glnvg__CheckError(GL, 'uniform locations');
  glnvg__GetUniforms(@GL.Shader);

  {$IFDEF NANOVG_GL3}
  glGenVertexArrays(1, @GL.VertArr);
  {$ENDIF}
  GetOpenGL.glGenBuffers(1, @GL.VertBuf);

  {$IFDEF NANOVG_GL_USE_UNIFORMBUFFER}
  glUniformBlockBinding(GL.Shader.Prog, GL.Shader.Loc[GLNVG_LOC_FRAG], 0 {GLNVG_FRAG_BINDING});
  glGenBuffers(1, @GL.FragBuf);
  glGetIntegerv(GL_UNIFORM_BUFFER_OFFSET_ALIGNMENT, @Align);
  {$ENDIF}
  GL.FragSize := SizeOf(TGLNVGFragUniforms) + Align - SizeOf(TGLNVGFragUniforms) mod Align;

  GL.DummyTex := glnvg__RenderCreateTexture(GL, NVG_TEXTURE_ALPHA, 1, 1, 0, nil);

  glnvg__CheckError(GL, 'create done');

  GetOpenGL.glFinish;

  Result := 1;
end;

function glnvg__RenderCreateTexture(Uptr: Pointer; TexType: TNVGTexture; W, H, ImageFlags: int32; Data: pbyte): int32;
var
  GL: TGLContext;
  Tex: PGLNVGTexture;
begin
  GL := TGLContext(Uptr);
  Tex := glnvg__AllocTexture(GL);
  if Tex = nil then
    Exit(0);

  {$IFDEF NANOVG_GLES2}
  if (glnvg__NearestPow2(W) <> Cardinal(W)) or (glnvg__NearestPow2(H) <> Cardinal(H)) then
  begin
    if (ImageFlags and (NVG_IMAGE_REPEATX or NVG_IMAGE_REPEATY)) <> 0 then
    begin
      WriteLn(Format('Repeat X/Y is not supported for non power-of-two textures (%d x %d)', [W, H]));
      ImageFlags := ImageFlags and not (NVG_IMAGE_REPEATX or NVG_IMAGE_REPEATY);
    end;
    if (ImageFlags and NVG_IMAGE_GENERATE_MIPMAPS) <> 0 then
    begin
      WriteLn(Format('Mip-maps is not supported for non power-of-two textures (%d x %d)', [W, H]));
      ImageFlags := ImageFlags and not NVG_IMAGE_GENERATE_MIPMAPS;
    end;
  end;
  {$ENDIF}

  GetOpenGL.glGenTextures(1, @Tex^.Tex);
  Tex^.Width := W;
  Tex^.Height := H;
  Tex^.TexType := TexType;
  Tex^.Flags := ImageFlags;
  glnvg__BindTexture(GL, Tex^.Tex);

  GetOpenGL.glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
  {$IFNDEF NANOVG_GLES2}
  GetOpenGL.glPixelStorei(GL_UNPACK_ROW_LENGTH, Tex^.Width);
  GetOpenGL.glPixelStorei(GL_UNPACK_SKIP_PIXELS, 0);
  GetOpenGL.glPixelStorei(GL_UNPACK_SKIP_ROWS, 0);
  {$ENDIF}

  {$IFDEF NANOVG_GL2}
  if (ImageFlags and NVG_IMAGE_GENERATE_MIPMAPS) <> 0 then
    glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, GL_TRUE);
  {$ENDIF}

  if TexType = NVG_TEXTURE_RGBA then
    GetOpenGL.glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, W, H, 0, GL_RGBA, GL_UNSIGNED_BYTE, Data)
  else
  {$IF defined(NANOVG_GLES2) or defined(NANOVG_GL2)}
    glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, W, H, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, Data);
  {$ELSE}
  GetOpenGL.glTexImage2D(GL_TEXTURE_2D, 0, GL_RED, W, H, 0, GL_RED, GL_UNSIGNED_BYTE, Data);
  {$ENDIF}

  if (ImageFlags and int32(NVG_IMAGE_GENERATE_MIPMAPS)) <> 0 then
  begin
    if (ImageFlags and int32(NVG_IMAGE_NEAREST)) <> 0 then
      GetOpenGL.glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_NEAREST)
    else
      GetOpenGL.glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
  end
  else
  begin
    if (ImageFlags and int32(NVG_IMAGE_NEAREST)) <> 0 then
      GetOpenGL.glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
    else
      GetOpenGL.glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  end;

  if (ImageFlags and int32(NVG_IMAGE_NEAREST)) <> 0 then
    GetOpenGL.glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
  else
    GetOpenGL.glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

  if (ImageFlags and int32(NVG_IMAGE_REPEATX)) <> 0 then
    GetOpenGL.glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT)
  else
    GetOpenGL.glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);

  if (ImageFlags and int32(NVG_IMAGE_REPEATY)) <> 0 then
    GetOpenGL.glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT)
  else
    GetOpenGL.glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

  GetOpenGL.glPixelStorei(GL_UNPACK_ALIGNMENT, 4);
  {$IFNDEF NANOVG_GLES2}
  GetOpenGL.glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
  GetOpenGL.glPixelStorei(GL_UNPACK_SKIP_PIXELS, 0);
  GetOpenGL.glPixelStorei(GL_UNPACK_SKIP_ROWS, 0);
  {$ENDIF}

  {$IFNDEF NANOVG_GL2}
  if (ImageFlags and int32(NVG_IMAGE_GENERATE_MIPMAPS)) <> 0 then
    GetOpenGL.glGenerateMipmap(GL_TEXTURE_2D);
  {$ENDIF}

  glnvg__CheckError(GL, 'create tex');
  glnvg__BindTexture(GL, 0);

  Result := Tex^.ID;
end;

function glnvg__RenderDeleteTexture(Uptr: Pointer; Image: int32): int32;
begin
  Result := Ord(glnvg__DeleteTexture(TGLContext(Uptr), Image));
end;

function glnvg__RenderUpdateTexture(Uptr: Pointer; Image, X, Y, W, H: int32; Data: pbyte): int32;
var
  GL: TGLContext;
  Tex: PGLNVGTexture;
begin
  GL := TGLContext(Uptr);
  Tex := glnvg__FindTexture(GL, Image);
  if Tex = nil then
    Exit(0);

  glnvg__BindTexture(GL, Tex^.Tex);

  GetOpenGL.glPixelStorei(GL_UNPACK_ALIGNMENT, 1);

  {$IFNDEF NANOVG_GLES2}
  GetOpenGL.glPixelStorei(GL_UNPACK_ROW_LENGTH, Tex^.Width);
  GetOpenGL.glPixelStorei(GL_UNPACK_SKIP_PIXELS, X);
  GetOpenGL.glPixelStorei(GL_UNPACK_SKIP_ROWS, Y);
  {$ELSE}
  if Tex^.TexType = NVG_TEXTURE_RGBA then
    Inc(Data, Y * Tex^.Width * 4)
  else
    Inc(Data, Y * Tex^.Width);
  X := 0;
  W := Tex^.Width;
  {$ENDIF}

  if Tex^.TexType = int32(NVG_TEXTURE_RGBA) then
  begin
    GetOpenGL.glTexSubImage2D(GL_TEXTURE_2D, 0, X, Y, W, H, GL_RGBA, GL_UNSIGNED_BYTE, Data);
  end
  else
  begin
    {$IF defined(NANOVG_GLES2) or defined(NANOVG_GL2)}
    glTexSubImage2D(GL_TEXTURE_2D, 0, X, Y, W, H, GL_LUMINANCE, GL_UNSIGNED_BYTE, Data);
    {$ELSE}
    GetOpenGL.glTexSubImage2D(GL_TEXTURE_2D, 0, X, Y, W, H, GL_RED, GL_UNSIGNED_BYTE, Data);
    {$ENDIF}
  end;

  GetOpenGL.glPixelStorei(GL_UNPACK_ALIGNMENT, 4);
  {$IFNDEF NANOVG_GLES2}
  GetOpenGL.glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
  GetOpenGL.glPixelStorei(GL_UNPACK_SKIP_PIXELS, 0);
  GetOpenGL.glPixelStorei(GL_UNPACK_SKIP_ROWS, 0);
  {$ENDIF}

  glnvg__BindTexture(GL, 0);

  Result := 1;
end;

function glnvg__RenderGetTextureSize(Uptr: Pointer; Image: int32; var W, H: int32): int32;
var
  GL: TGLContext;
  Tex: PGLNVGTexture;
begin
  GL := TGLContext(Uptr);
  Tex := glnvg__FindTexture(GL, Image);
  if Tex = nil then
    Exit(0);
  W := Tex^.Width;
  H := Tex^.Height;
  Result := 1;
end;

procedure glnvg__XformToMat3x4(M3: PSingle; T: PSingle);
begin
  M3[0] := T[0];
  M3[1] := T[1];
  M3[2] := 0.0;
  M3[3] := 0.0;
  M3[4] := T[2];
  M3[5] := T[3];
  M3[6] := 0.0;
  M3[7] := 0.0;
  M3[8] := T[4];
  M3[9] := T[5];
  M3[10] := 1.0;
  M3[11] := 0.0;
end;

function glnvg__PremulColor(C: TNVGColor): TNVGColor;
begin
  Result := C;
  Result.R := C.R * C.A;
  Result.G := C.G * C.A;
  Result.B := C.B * C.A;
end;

function glnvg__ConvertPaint(GL: TGLContext; Frag: PGLNVGFragUniforms; Paint: PNVGPaint; Scissor: PNVGScissor; Width, Fringe, StrokeThr: single): boolean;
var
  Tex: PGLNVGTexture;
  InvXform, M1, M2: array[0..5] of single;
begin
  FillChar(Frag^, SizeOf(TGLNVGFragUniforms), 0);

  Frag^.InnerCol := glnvg__PremulColor(Paint^.InnerColor);
  Frag^.OuterCol := glnvg__PremulColor(Paint^.OuterColor);

  if (Scissor^.Extent[0] < -0.5) or (Scissor^.Extent[1] < -0.5) then
  begin
    FillChar(Frag^.ScissorMat, SizeOf(Frag^.ScissorMat), 0);
    Frag^.ScissorExt[0] := 1.0;
    Frag^.ScissorExt[1] := 1.0;
    Frag^.ScissorScale[0] := 1.0;
    Frag^.ScissorScale[1] := 1.0;
  end
  else
  begin
    nvgTransformInverse(@InvXform[0], @Scissor^.Xform[0]);
    glnvg__XformToMat3x4(@Frag^.ScissorMat[0], @InvXform[0]);
    Frag^.ScissorExt[0] := Scissor^.Extent[0];
    Frag^.ScissorExt[1] := Scissor^.Extent[1];
    Frag^.ScissorScale[0] := Sqrt(Scissor^.Xform[0] * Scissor^.Xform[0] + Scissor^.Xform[2] * Scissor^.Xform[2]) / Fringe;
    Frag^.ScissorScale[1] := Sqrt(Scissor^.Xform[1] * Scissor^.Xform[1] + Scissor^.Xform[3] * Scissor^.Xform[3]) / Fringe;
  end;

  Move(Paint^.Extent[0], Frag^.Extent[0], SizeOf(Frag^.Extent));
  Frag^.StrokeMult := (Width * 0.5 + Fringe * 0.5) / Fringe;
  Frag^.StrokeThr := StrokeThr;

  if Paint^.Image <> 0 then
  begin
    Tex := glnvg__FindTexture(GL, Paint^.Image);
    if Tex = nil then
      Exit(False);
    if (Tex^.Flags and int32(NVG_IMAGE_FLIPY)) <> 0 then
    begin
      nvgTransformTranslate(@M1[0], 0.0, Frag^.Extent[1] * 0.5);
      nvgTransformMultiply(@M1[0], @Paint^.Xform[0]);
      nvgTransformScale(@M2[0], 1.0, -1.0);
      nvgTransformMultiply(@M2[0], @M1[0]);
      nvgTransformTranslate(@M1[0], 0.0, -Frag^.Extent[1] * 0.5);
      nvgTransformMultiply(@M1[0], @M2[0]);
      nvgTransformInverse(@InvXform[0], @M1[0]);
    end
    else
      nvgTransformInverse(@InvXform[0], @Paint^.Xform[0]);
    Frag^.ShaderType := NSVG_SHADER_FILLIMG;

    {$IFDEF NANOVG_GL_USE_UNIFORMBUFFER}
    if Tex^.TexType = NVG_TEXTURE_RGBA then
      Frag^.TexType := IfThen((Tex^.Flags and NVG_IMAGE_PREMULTIPLIED) <> 0, 0, 1)
    else
      Frag^.TexType := 2;
    {$ELSE}
    if Tex^.TexType = int32(NVG_TEXTURE_RGBA) then
      Frag^.TexType := IfThen((Tex^.Flags and int32(NVG_IMAGE_PREMULTIPLIED)) <> 0, 0, 1)
    else
      Frag^.TexType := 2;
    {$ENDIF}
  end
  else
  begin
    Frag^.ShaderType := NSVG_SHADER_FILLGRAD;
    Frag^.Radius := Paint^.Radius;
    Frag^.Feather := Paint^.Feather;
    nvgTransformInverse(@InvXform[0], @Paint^.Xform[0]);
  end;

  glnvg__XformToMat3x4(@Frag^.PaintMat[0], @InvXform[0]);

  Result := True;
end;

function nvg__FragUniformPtr(GL: TGLContext; I: int32): PGLNVGFragUniforms;
begin
  Result := PGLNVGFragUniforms(pbyte(GL.Uniforms) + I);
end;

procedure glnvg__SetUniforms(GL: TGLContext; UniformOffset, Image: int32);
var
  Tex: PGLNVGTexture;
  Frag: PGLNVGFragUniforms;
  h: GLenum = 0;
begin
  {$IFDEF NANOVG_GL_USE_UNIFORMBUFFER}
  glBindBufferRange(GL_UNIFORM_BUFFER, 0 {GLNVG_FRAG_BINDING}, GL.FragBuf, UniformOffset, SizeOf(TGLNVGFragUniforms));
  {$ELSE}
  Frag := nvg__FragUniformPtr(GL, UniformOffset);
  GetOpenGL.glUniform4fv(GL.Shader.Loc[GLNVG_LOC_FRAG], 11 {NANOVG_GL_UNIFORMARRAY_SIZE}, @Frag^.ScissorMat[0]);
  {$ENDIF}

  if Image <> 0 then
    Tex := glnvg__FindTexture(GL, Image);
  if Tex = nil then
    Tex := glnvg__FindTexture(GL, GL.DummyTex);
  if Tex <> nil then
    h := Tex^.Tex;
  glnvg__BindTexture(GL, h);
  glnvg__CheckError(GL, 'tex paint tex');
end;

procedure glnvg__RenderViewport(Uptr: Pointer; Width, Height, DevicePixelRatio: single);
var
  GL: TGLContext;
begin
  GL := TGLContext(Uptr);
  GL.View[0] := Width;
  GL.View[1] := Height;
end;

procedure glnvg__Fill(GL: TGLContext; Call: PGLNVGCall);
var
  Paths: PGLNVGPath;
  I, NPaths: int32;
begin
  Paths := @GL.Paths[Call^.PathOffset];
  NPaths := Call^.PathCount;

  GetOpenGL.glEnable(GL_STENCIL_TEST);
  glnvg__StencilMask(GL, $FF);
  glnvg__StencilFunc(GL, GL_ALWAYS, 0, $FF);
  GetOpenGL.glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE);

  glnvg__SetUniforms(GL, Call^.UniformOffset, 0);
  glnvg__CheckError(GL, 'fill simple');

  GetOpenGL.glStencilOpSeparate(GL_FRONT, GL_KEEP, GL_KEEP, GL_INCR_WRAP);
  GetOpenGL.glStencilOpSeparate(GL_BACK, GL_KEEP, GL_KEEP, GL_DECR_WRAP);
  GetOpenGL.glDisable(GL_CULL_FACE);
  for I := 0 to NPaths - 1 do
    GetOpenGL.glDrawArrays(GL_TRIANGLE_FAN, Paths[I].FillOffset, Paths[I].FillCount);
  GetOpenGL.glEnable(GL_CULL_FACE);

  GetOpenGL.glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);

  glnvg__SetUniforms(GL, Call^.UniformOffset + GL.FragSize, Call^.Image);
  glnvg__CheckError(GL, 'fill fill');

  if (GL.Flags and NVG_ANTIALIAS) <> 0 then
  begin
    glnvg__StencilFunc(GL, GL_EQUAL, $00, $FF);
    GetOpenGL.glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
    for I := 0 to NPaths - 1 do
      GetOpenGL.glDrawArrays(GL_TRIANGLE_STRIP, Paths[I].StrokeOffset, Paths[I].StrokeCount);
  end;

  glnvg__StencilFunc(GL, GL_NOTEQUAL, $0, $FF);
  GetOpenGL.glStencilOp(GL_ZERO, GL_ZERO, GL_ZERO);
  GetOpenGL.glDrawArrays(GL_TRIANGLE_STRIP, Call^.TriangleOffset, Call^.TriangleCount);

  GetOpenGL.glDisable(GL_STENCIL_TEST);
end;

procedure glnvg__ConvexFill(GL: TGLContext; Call: PGLNVGCall);
var
  Paths: PGLNVGPath;
  I, NPaths: int32;
begin
  Paths := @GL.Paths[Call^.PathOffset];
  NPaths := Call^.PathCount;

  glnvg__SetUniforms(GL, Call^.UniformOffset, Call^.Image);
  glnvg__CheckError(GL, 'convex fill');

  for I := 0 to NPaths - 1 do
  begin
    GetOpenGL.glDrawArrays(GL_TRIANGLE_FAN, Paths[I].FillOffset, Paths[I].FillCount);
    if Paths[I].StrokeCount > 0 then
      GetOpenGL.glDrawArrays(GL_TRIANGLE_STRIP, Paths[I].StrokeOffset, Paths[I].StrokeCount);
  end;
end;

procedure glnvg__Stroke(GL: TGLContext; Call: PGLNVGCall);
var
  Paths: PGLNVGPath;
  I, NPaths: int32;
begin
  Paths := @GL.Paths[Call^.PathOffset];
  NPaths := Call^.PathCount;

  if (GL.Flags and NVG_STENCIL_STROKES) <> 0 then
  begin
    GetOpenGL.glEnable(GL_STENCIL_TEST);
    glnvg__StencilMask(GL, $FF);

    glnvg__StencilFunc(GL, GL_EQUAL, $0, $FF);
    GetOpenGL.glStencilOp(GL_KEEP, GL_KEEP, GL_INCR);
    glnvg__SetUniforms(GL, Call^.UniformOffset + GL.FragSize, Call^.Image);
    glnvg__CheckError(GL, 'stroke fill 0');
    for I := 0 to NPaths - 1 do
      GetOpenGL.glDrawArrays(GL_TRIANGLE_STRIP, Paths[I].StrokeOffset, Paths[I].StrokeCount);

    glnvg__SetUniforms(GL, Call^.UniformOffset, Call^.Image);
    glnvg__StencilFunc(GL, GL_EQUAL, $00, $FF);
    GetOpenGL.glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
    for I := 0 to NPaths - 1 do
      GetOpenGL.glDrawArrays(GL_TRIANGLE_STRIP, Paths[I].StrokeOffset, Paths[I].StrokeCount);

    GetOpenGL.glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE);
    glnvg__StencilFunc(GL, GL_ALWAYS, $0, $FF);
    GetOpenGL.glStencilOp(GL_ZERO, GL_ZERO, GL_ZERO);
    glnvg__CheckError(GL, 'stroke fill 1');
    for I := 0 to NPaths - 1 do
      GetOpenGL.glDrawArrays(GL_TRIANGLE_STRIP, Paths[I].StrokeOffset, Paths[I].StrokeCount);
    GetOpenGL.glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);

    GetOpenGL.glDisable(GL_STENCIL_TEST);
  end
  else
  begin
    glnvg__SetUniforms(GL, Call^.UniformOffset, Call^.Image);
    glnvg__CheckError(GL, 'stroke fill');
    for I := 0 to NPaths - 1 do
      GetOpenGL.glDrawArrays(GL_TRIANGLE_STRIP, Paths[I].StrokeOffset, Paths[I].StrokeCount);
  end;
end;

procedure glnvg__Triangles(GL: TGLContext; Call: PGLNVGCall);
begin
  glnvg__SetUniforms(GL, Call^.UniformOffset, Call^.Image);
  glnvg__CheckError(GL, 'triangles fill');
  GetOpenGL.glDrawArrays(GL_TRIANGLES, Call^.TriangleOffset, Call^.TriangleCount);
end;

procedure glnvg__RenderCancel(Uptr: Pointer);
var
  GL: TGLContext;
begin
  GL := TGLContext(Uptr);
  GL.NVerts := 0;
  GL.NPaths := 0;
  GL.NCalls := 0;
  GL.NUniforms := 0;
end;

function glnvg__ConvertBlendFuncFactor(Factor: int32): GLenum;
begin
  case TNVGBlendFactor(Factor) of
    NVG_ZERO: Result := GL_ZERO;
    NVG_ONE: Result := GL_ONE;
    NVG_SRC_COLOR: Result := GL_SRC_COLOR;
    NVG_ONE_MINUS_SRC_COLOR: Result := GL_ONE_MINUS_SRC_COLOR;
    NVG_DST_COLOR: Result := GL_DST_COLOR;
    NVG_ONE_MINUS_DST_COLOR: Result := GL_ONE_MINUS_DST_COLOR;
    NVG_SRC_ALPHA: Result := GL_SRC_ALPHA;
    NVG_ONE_MINUS_SRC_ALPHA: Result := GL_ONE_MINUS_SRC_ALPHA;
    NVG_DST_ALPHA: Result := GL_DST_ALPHA;
    NVG_ONE_MINUS_DST_ALPHA: Result := GL_ONE_MINUS_DST_ALPHA;
    NVG_SRC_ALPHA_SATURATE: Result := GL_SRC_ALPHA_SATURATE;
    else
      Result := GL_INVALID_ENUM;
  end;
end;

function glnvg__BlendCompositeOperation(Op: TNVGCompositeOperationState): TGLNVGBlend;
begin
  Result.SrcRGB := glnvg__ConvertBlendFuncFactor(Op.SrcRGB);
  Result.DstRGB := glnvg__ConvertBlendFuncFactor(Op.DstRGB);
  Result.SrcAlpha := glnvg__ConvertBlendFuncFactor(Op.SrcAlpha);
  Result.DstAlpha := glnvg__ConvertBlendFuncFactor(Op.DstAlpha);
  if (Result.SrcRGB = GL_INVALID_ENUM) or (Result.DstRGB = GL_INVALID_ENUM) or (Result.SrcAlpha = GL_INVALID_ENUM) or (Result.DstAlpha = GL_INVALID_ENUM) then
  begin
    Result.SrcRGB := GL_ONE;
    Result.DstRGB := GL_ONE_MINUS_SRC_ALPHA;
    Result.SrcAlpha := GL_ONE;
    Result.DstAlpha := GL_ONE_MINUS_SRC_ALPHA;
  end;
end;

procedure glnvg__RenderFlush(Uptr: Pointer);
var
  GL: TGLContext;
  I: int32;
  Call: PGLNVGCall;
begin
  GL := TGLContext(Uptr);
  if GL.NCalls > 0 then
  begin
    GetOpenGL.glUseProgram(GL.Shader.Prog);

    GetOpenGL.glEnable(GL_CULL_FACE);
    GetOpenGL.glCullFace(GL_BACK);
    GetOpenGL.glFrontFace(GL_CCW);
    GetOpenGL.glEnable(GL_BLEND);
    GetOpenGL.glDisable(GL_DEPTH_TEST);
    GetOpenGL.glDisable(GL_SCISSOR_TEST);
    GetOpenGL.glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
    GetOpenGL.glStencilMask($FFFFFFFF);
    GetOpenGL.glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
    GetOpenGL.glStencilFunc(GL_ALWAYS, 0, $FFFFFFFF);
    GetOpenGL.glActiveTexture(GL_TEXTURE0);
    GetOpenGL.glBindTexture(GL_TEXTURE_2D, 0);
    {$IFDEF NANOVG_GL_USE_STATE_FILTER}
    GL.BoundTexture := 0;
    GL.StencilMask := $FFFFFFFF;
    GL.StencilFunc := GL_ALWAYS;
    GL.StencilFuncRef := 0;
    GL.StencilFuncMask := $FFFFFFFF;
    GL.BlendFunc.SrcRGB := GL_INVALID_ENUM;
    GL.BlendFunc.SrcAlpha := GL_INVALID_ENUM;
    GL.BlendFunc.DstRGB := GL_INVALID_ENUM;
    GL.BlendFunc.DstAlpha := GL_INVALID_ENUM;
    {$ENDIF}

    {$IFDEF NANOVG_GL_USE_UNIFORMBUFFER}
    glBindBuffer(GL_UNIFORM_BUFFER, GL.FragBuf);
    glBufferData(GL_UNIFORM_BUFFER, GL.NUniforms * GL.FragSize, GL.Uniforms, GL_STREAM_DRAW);
    {$ENDIF}

    {$IFDEF NANOVG_GL3}
    glBindVertexArray(GL.VertArr);
    {$ENDIF}
    GetOpenGL.glBindBuffer(GL_ARRAY_BUFFER, GL.VertBuf);
    GetOpenGL.glBufferData(GL_ARRAY_BUFFER, GL.NVerts * SizeOf(TNVGVertex), GL.Verts, GL_STREAM_DRAW);
    GetOpenGL.glEnableVertexAttribArray(0);
    GetOpenGL.glEnableVertexAttribArray(1);
    GetOpenGL.glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, SizeOf(TNVGVertex), Pointer(0));
    GetOpenGL.glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, SizeOf(TNVGVertex), Pointer(2 * SizeOf(single)));

    GetOpenGL.glUniform1i(GL.Shader.Loc[GLNVG_LOC_TEX], 0);
    GetOpenGL.glUniform2fv(GL.Shader.Loc[GLNVG_LOC_VIEWSIZE], 1, @GL.View[0]);

    {$IFDEF NANOVG_GL_USE_UNIFORMBUFFER}
    glBindBuffer(GL_UNIFORM_BUFFER, GL.FragBuf);
    {$ENDIF}

    for I := 0 to GL.NCalls - 1 do
    begin
      Call := @GL.Calls[I];
      glnvg__BlendFuncSeparate(GL, @Call^.BlendFunc);
      case Call^.CallType of
        GLNVG_FILL: glnvg__Fill(GL, Call);
        GLNVG_CONVEXFILL: glnvg__ConvexFill(GL, Call);
        GLNVG_STROKE: glnvg__Stroke(GL, Call);
        GLNVG_TRIANGLES: glnvg__Triangles(GL, Call);
      end;
    end;

    GetOpenGL.glDisableVertexAttribArray(0);
    GetOpenGL.glDisableVertexAttribArray(1);
    {$IFDEF NANOVG_GL3}
    glBindVertexArray(0);
    {$ENDIF}
    GetOpenGL.glDisable(GL_CULL_FACE);
    GetOpenGL.glBindBuffer(GL_ARRAY_BUFFER, 0);
    GetOpenGL.glUseProgram(0);
    glnvg__BindTexture(GL, 0);
  end;

  GL.NVerts := 0;
  GL.NPaths := 0;
  GL.NCalls := 0;
  GL.NUniforms := 0;
end;

function glnvg__MaxVertCount(Paths: PNVGPath; NPaths: int32): int32;
var
  I: int32;
begin
  Result := 0;
  for I := 0 to NPaths - 1 do
  begin
    Inc(Result, Paths[I].nfill);
    Inc(Result, Paths[I].nstroke);
  end;
end;

function glnvg__AllocCall(GL: TGLContext): PGLNVGCall;
var
  CCalls: int32;
begin
  if GL.NCalls + 1 > GL.CCalls then
  begin
    CCalls := glnvg__MaxI(GL.NCalls + 1, 128) + GL.CCalls div 2;
    ReallocMem(GL.Calls, SizeOf(TGLNVGCall) * CCalls);
    if GL.Calls = nil then
      Exit(nil);
    GL.CCalls := CCalls;
  end;
  Result := @GL.Calls[GL.NCalls];
  Inc(GL.NCalls);
  FillChar(Result^, SizeOf(TGLNVGCall), 0);
end;

function glnvg__AllocPaths(GL: TGLContext; N: int32): int32;
var
  CPaths: int32;
begin
  if GL.NPaths + N > GL.CPaths then
  begin
    CPaths := glnvg__MaxI(GL.NPaths + N, 128) + GL.CPaths div 2;
    ReallocMem(GL.Paths, SizeOf(TGLNVGPath) * CPaths);
    if GL.Paths = nil then
      Exit(-1);
    GL.CPaths := CPaths;
  end;
  Result := GL.NPaths;
  Inc(GL.NPaths, N);
end;

function glnvg__AllocVerts(GL: TGLContext; N: int32): int32;
var
  CVerts: int32;
begin
  if GL.NVerts + N > GL.CVerts then
  begin
    CVerts := glnvg__MaxI(GL.NVerts + N, 4096) + GL.CVerts div 2;
    ReallocMem(GL.Verts, SizeOf(TNVGVertex) * CVerts);
    if GL.Verts = nil then
      Exit(-1);
    GL.CVerts := CVerts;
  end;
  Result := GL.NVerts;
  Inc(GL.NVerts, N);
end;

function glnvg__AllocFragUniforms(GL: TGLContext; N: int32): int32;
var
  CUniforms, StructSize: int32;
begin
  StructSize := GL.FragSize;
  if GL.NUniforms + N > GL.CUniforms then
  begin
    CUniforms := glnvg__MaxI(GL.NUniforms + N, 128) + GL.CUniforms div 2;
    ReallocMem(GL.Uniforms, StructSize * CUniforms);
    if GL.Uniforms = nil then
      Exit(-1);
    GL.CUniforms := CUniforms;
  end;
  Result := GL.NUniforms * StructSize;
  Inc(GL.NUniforms, N);
end;

procedure glnvg__VSet(Vtx: PNVGVertex; X, Y, U, V: single);
begin
  Vtx^.X := X;
  Vtx^.Y := Y;
  Vtx^.U := U;
  Vtx^.V := V;
end;

procedure glnvg__RenderFill(Uptr: Pointer; Paint: PNVGPaint; CompositeOperation: TNVGCompositeOperationState; Scissor: PNVGScissor; Fringe: single; Bounds: PSingle; Paths: PNVGPath; NPaths: int32);
var
  GL: TGLContext;
  Call: PGLNVGCall;
  Quad: PNVGVertex;
  Frag: PGLNVGFragUniforms;
  I, MaxVerts, Offset: int32;
begin
  try
    GL := TGLContext(Uptr);
    Call := glnvg__AllocCall(GL);
    if Call = nil then
      Exit;

    Call^.CallType := GLNVG_FILL;
    Call^.TriangleCount := 4;
    Call^.PathOffset := glnvg__AllocPaths(GL, NPaths);
    if Call^.PathOffset = -1 then
      raise ENullPointerException.Create();
    Call^.PathCount := NPaths;
    Call^.Image := Paint^.Image;
    Call^.BlendFunc := glnvg__BlendCompositeOperation(CompositeOperation);

    if (NPaths = 1) and Paths[0].Closed then
    begin
      Call^.CallType := GLNVG_CONVEXFILL;
      Call^.TriangleCount := 0;
    end;

    MaxVerts := glnvg__MaxVertCount(Paths, NPaths) + Call^.TriangleCount;
    Offset := glnvg__AllocVerts(GL, MaxVerts);
    if Offset = -1 then
      raise ENullPointerException.Create;

    for I := 0 to NPaths - 1 do
    begin
      GL.Paths[Call^.PathOffset + I].FillOffset := Offset;
      GL.Paths[Call^.PathOffset + I].FillCount := Paths[I].nfill;
      Move(Paths[I].nfill, GL.Verts[Offset], SizeOf(TNVGVertex) * Paths[I].nfill);
      Inc(Offset, Paths[I].nfill);
      GL.Paths[Call^.PathOffset + I].StrokeOffset := Offset;
      GL.Paths[Call^.PathOffset + I].StrokeCount := Paths[I].NStroke;
      Move(Paths[I].Stroke^, GL.Verts[Offset], SizeOf(TNVGVertex) * Paths[I].NStroke);
      Inc(Offset, Paths[I].NStroke);
    end;

    if Call^.CallType = GLNVG_FILL then
    begin
      Call^.TriangleOffset := Offset;
      Quad := @GL.Verts[Call^.TriangleOffset];
      glnvg__VSet(@Quad[0], Bounds[2], Bounds[3], 0.5, 1.0);
      glnvg__VSet(@Quad[1], Bounds[2], Bounds[1], 0.5, 1.0);
      glnvg__VSet(@Quad[2], Bounds[0], Bounds[3], 0.5, 1.0);
      glnvg__VSet(@Quad[3], Bounds[0], Bounds[1], 0.5, 1.0);

      Call^.UniformOffset := glnvg__AllocFragUniforms(GL, 2);
      if Call^.UniformOffset = -1 then
        raise ENullPointerException.Create;

      Frag := nvg__FragUniformPtr(GL, Call^.UniformOffset);
      FillChar(Frag^, SizeOf(TGLNVGFragUniforms), 0);
      Frag^.StrokeThr := -1.0;
      Frag^.ShaderType := NSVG_SHADER_SIMPLE;

      glnvg__ConvertPaint(GL, nvg__FragUniformPtr(GL, Call^.UniformOffset + GL.FragSize), Paint, Scissor, Fringe, Fringe, -1.0);
    end
    else
    begin
      Call^.UniformOffset := glnvg__AllocFragUniforms(GL, 1);
      if Call^.UniformOffset = -1 then
        raise ENullPointerException.Create;
      glnvg__ConvertPaint(GL, nvg__FragUniformPtr(GL, Call^.UniformOffset), Paint, Scissor, Fringe, Fringe, -1.0);
    end;

    Exit;

  except
    if GL.NCalls > 0 then
      Dec(GL.NCalls);
  end;
end;

procedure glnvg__RenderStroke(Uptr: Pointer; Paint: PNVGPaint; CompositeOperation: TNVGCompositeOperationState; Scissor: PNVGScissor; Fringe, StrokeWidth: single; Paths: PNVGPath; NPaths: int32);
var
  GL: TGLContext;
  Call: PGLNVGCall;
  I, MaxVerts, Offset: int32;
begin
  try
    GL := TGLContext(Uptr);
    Call := glnvg__AllocCall(GL);
    if Call = nil then
      Exit;

    Call^.CallType := GLNVG_STROKE;
    Call^.PathOffset := glnvg__AllocPaths(GL, NPaths);
    if Call^.PathOffset = -1 then raise ENullPointerException.Create();
    Call^.PathCount := NPaths;
    Call^.Image := Paint^.Image;
    Call^.BlendFunc := glnvg__BlendCompositeOperation(CompositeOperation);

    MaxVerts := glnvg__MaxVertCount(Paths, NPaths);
    Offset := glnvg__AllocVerts(GL, MaxVerts);
    if Offset = -1 then raise ENullPointerException.Create();

    for I := 0 to NPaths - 1 do
    begin
      GL.Paths[Call^.PathOffset + I].StrokeOffset := Offset;
      GL.Paths[Call^.PathOffset + I].StrokeCount := Paths[I].NStroke;
      Move(Paths[I].Stroke^, GL.Verts[Offset], SizeOf(TNVGVertex) * Paths[I].NStroke);
      Inc(Offset, Paths[I].NStroke);
    end;

    if (GL.Flags and NVG_STENCIL_STROKES) <> 0 then
    begin
      Call^.UniformOffset := glnvg__AllocFragUniforms(GL, 2);
      if Call^.UniformOffset = -1 then
        raise ENullPointerException.Create();

      glnvg__ConvertPaint(GL, nvg__FragUniformPtr(GL, Call^.UniformOffset), Paint, Scissor, StrokeWidth, Fringe, -1.0);
      glnvg__ConvertPaint(GL, nvg__FragUniformPtr(GL, Call^.UniformOffset + GL.FragSize), Paint, Scissor, StrokeWidth, Fringe, 1.0 - 0.5 / 255.0);
    end
    else
    begin
      Call^.UniformOffset := glnvg__AllocFragUniforms(GL, 1);
      if Call^.UniformOffset = -1 then
        raise ENullPointerException.Create;
      glnvg__ConvertPaint(GL, nvg__FragUniformPtr(GL, Call^.UniformOffset), Paint, Scissor, StrokeWidth, Fringe, -1.0);
    end;

    Exit;

  except
    if GL.NCalls > 0 then
      Dec(GL.NCalls);
  end;
end;

procedure glnvg__RenderTriangles(Uptr: Pointer; Paint: PNVGPaint; CompositeOperation: TNVGCompositeOperationState; Scissor: PNVGScissor; Verts: PNVGVertex; NVerts: int32; Fringe: single);
var
  GL: TGLContext;
  Call: PGLNVGCall;
  Frag: PGLNVGFragUniforms;
begin
  try
    GL := TGLContext(Uptr);
    Call := glnvg__AllocCall(GL);
    if Call = nil then
      Exit;

    Call^.CallType := GLNVG_TRIANGLES;
    Call^.Image := Paint^.Image;
    Call^.BlendFunc := glnvg__BlendCompositeOperation(CompositeOperation);

    Call^.TriangleOffset := glnvg__AllocVerts(GL, NVerts);
    if Call^.TriangleOffset = -1 then
      raise ENullPointerException.Create;
    Call^.TriangleCount := NVerts;

    Move(Verts[0], GL.Verts[Call^.TriangleOffset], SizeOf(TNVGVertex) * NVerts);

    Call^.UniformOffset := glnvg__AllocFragUniforms(GL, 1);
    if Call^.UniformOffset = -1 then
      raise ENullPointerException.Create;
    Frag := nvg__FragUniformPtr(GL, Call^.UniformOffset);
    glnvg__ConvertPaint(GL, Frag, Paint, Scissor, 1.0, Fringe, -1.0);
    Frag^.ShaderType := NSVG_SHADER_IMG;

    Exit;

  except
    if GL.NCalls > 0 then
      Dec(GL.NCalls);
  end;
end;

procedure glnvg__RenderDelete(Uptr: Pointer);
var
  GL: TGLContext;
  I: int32;
begin
  GL := TGLContext(Uptr);
  if GL = nil then
    Exit;

  glnvg__DeleteShader(@GL.Shader);

  {$IFDEF NANOVG_GL3}
  {$IFDEF NANOVG_GL_USE_UNIFORMBUFFER}
  if GL.FragBuf <> 0 then
    glDeleteBuffers(1, @GL.FragBuf);
  {$ENDIF}
  if GL.VertArr <> 0 then
    glDeleteVertexArrays(1, @GL.VertArr);
  {$ENDIF}
  if GL.VertBuf <> 0 then
    GetOpenGL.glDeleteBuffers(1, @GL.VertBuf);

  for I := 0 to GL.NTextures - 1 do
  begin
    if (GL.Textures[I].Tex <> 0) and ((GL.Textures[I].Flags and NVG_IMAGE_NODELETE) = 0) then
      GetOpenGL.glDeleteTextures(1, @GL.Textures[I].Tex);
  end;
  FreeMem(GL.Textures);

  FreeMem(GL.Paths);
  FreeMem(GL.Verts);
  FreeMem(GL.Uniforms);
  FreeMem(GL.Calls);

  FreeMem(GL);
end;

function nvgCreateGL2(Flags: int32): TNVContext;
var
  Params: PNVGParams = nil;
  Ctx: TNVContext;
  gl: TGLContext;
begin
  Result := nil;
  GetMem(Params, SizeOf(TNVGParams));
  gl := TGLContext.Create;
  if gl = nil then
    Exit;

  FillChar(Params^, SizeOf(TNVGParams), 0);
  Params^.RenderCreate := @glnvg__RenderCreate;
  Params^.RenderCreateTexture := @glnvg__RenderCreateTexture;
  Params^.RenderDeleteTexture := @glnvg__RenderDeleteTexture;
  Params^.RenderUpdateTexture := @glnvg__RenderUpdateTexture;
  Params^.RenderGetTextureSize := @glnvg__RenderGetTextureSize;
  Params^.RenderViewport := @glnvg__RenderViewport;
  Params^.RenderCancel := @glnvg__RenderCancel;
  Params^.RenderFlush := @glnvg__RenderFlush;
  Params^.RenderFill := @glnvg__RenderFill;
  Params^.RenderStroke := @glnvg__RenderStroke;
  Params^.RenderTriangles := @glnvg__RenderTriangles;
  Params^.RenderDelete := @glnvg__RenderDelete;
  Params^.UserPtr := GL;
  Params^.EdgeAntiAlias := IfThen((Flags and NVG_ANTIALIAS) <> 0, True, False);
  checkBackEnd(Params);
  GL.Flags := Flags;

  Ctx := nvgCreateInternal(Params);
  if Ctx = nil then
  begin
    GL.Free;
    Result := nil;
  end
  else
    Result := Ctx;
  checkBackEnd(Ctx.params);
end;

procedure nvgDeleteGL2(Ctx: TNVContext);
begin
  nvgDeleteInternal(Ctx);
end;

function nvglCreateImageFromHandleGL2(Ctx: TNVContext; TextureID: GLuint; W, H, ImageFlags: int32): int32;
var
  GL: TGLContext;
  Tex: PGLNVGTexture;
begin
  GL := TGLContext(Ctx.Params^.UserPtr);
  Tex := glnvg__AllocTexture(GL);
  if Tex = nil then
    Exit(0);

  Tex^.TexType := NVG_TEXTURE_RGBA;
  Tex^.Tex := TextureID;
  Tex^.Flags := ImageFlags;
  Tex^.Width := W;
  Tex^.Height := H;

  Result := Tex^.ID;
end;

function nvglImageHandleGL2(Ctx: TNVContext; Image: int32): GLuint;
var
  GL: TGLContext;
  Tex: PGLNVGTexture;
begin
  GL := TGLContext(Ctx.Params^.UserPtr);
  Tex := glnvg__FindTexture(GL, Image);
  if Tex = nil then
    Exit(0);
  Result := Tex^.Tex;
end;

function nvgCreateGL3(Flags: int32): TNVContext; inline;
begin
  Result := nvgCreateGL2(Flags);
end;

procedure nvgDeleteGL3(Ctx: TNVContext); inline;
begin
  nvgDeleteGL2(Ctx);
end;

function nvglCreateImageFromHandleGL3(Ctx: TNVContext; TextureID: GLuint; W, H, ImageFlags: int32): int32; inline;
begin
  Result := nvglCreateImageFromHandleGL2(Ctx, TextureID, W, H, ImageFlags);
end;

function nvglImageHandleGL3(Ctx: TNVContext; Image: int32): GLuint; inline;
begin
  Result := nvglImageHandleGL2(Ctx, Image);
end;

end.
