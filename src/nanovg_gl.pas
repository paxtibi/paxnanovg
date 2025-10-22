unit nanovg_gl;
{
  Copyright (c) 2009-2013 Mikko Mononen memon@inside.org
  Questo software è fornito "così com'è", senza alcuna garanzia esplicita o implicita.
  In nessun caso gli autori saranno responsabili per eventuali danni derivanti dall'uso di questo software.
  È concessa l'autorizzazione a chiunque di utilizzare questo software per qualsiasi scopo,
  incluse applicazioni commerciali, e di modificarlo e ridistribuirlo liberamente,
  soggetto alle seguenti restrizioni:
  1. L'origine di questo software non deve essere rappresentata in modo errato; non devi
     dichiarare di aver scritto il software originale. Se utilizzi questo software in un prodotto,
     un riconoscimento nella documentazione del prodotto sarebbe apprezzato ma non è obbligatorio.
  2. Le versioni modificate del codice sorgente devono essere chiaramente contrassegnate come tali
     e non devono essere rappresentate come il software originale.
  3. Questo avviso non può essere rimosso o modificato da nessuna distribuzione del codice sorgente.
}
{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, NanoVG, GL, LResources;

const
  // Flag di creazione
  NVG_ANTIALIAS = 1 shl 0; // Indica se viene utilizzato l'antialiasing basato sulla geometria
  NVG_STENCIL_STROKES = 1 shl 1; // Indica se i tratti usano il buffer stencil (più lento, ma gestisce sovrapposizioni)
  NVG_DEBUG = 1 shl 2; // Abilita controlli di debug aggiuntivi

  // Flag aggiuntivi per le immagini
  NVG_IMAGE_NODELETE = 1 shl 16; // Non eliminare l'handle della texture OpenGL

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

  // Struttura per lo shader OpenGL
  TGLNVGShader = record
    Prog: GLuint; // Programma shader
    Frag: GLuint; // Shader frammento
    Vert: GLuint; // Shader vertice
    Loc: array[0..Ord(GLNVG_MAX_LOCS)-1] of GLint; // Posizioni uniform
  end;
  PGLNVGShader = ^TGLNVGShader;

  // Struttura per la texture
  TGLNVGTexture = record
    ID: Integer; // ID della texture
    Tex: GLuint; // Handle OpenGL della texture
    Width, Height: Integer; // Dimensioni
    TexType: Integer; // Tipo (NVG_TEXTURE_RGBA, NVG_TEXTURE_ALPHA)
    Flags: Integer; // Flag immagine
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
    Image: Integer; // ID immagine
    PathOffset: Integer; // Offset percorsi
    PathCount: Integer; // Numero percorsi
    TriangleOffset: Integer; // Offset triangoli
    TriangleCount: Integer; // Numero triangoli
    UniformOffset: Integer; // Offset uniform
    BlendFunc: TGLNVGBlend; // Funzione di blending
  end;
  PGLNVGCall = ^TGLNVGCall;

  // Struttura per un percorso
  TGLNVGPath = record
    FillOffset: Integer; // Offset riempimento
    FillCount: Integer; // Conteggio vertici riempimento
    StrokeOffset: Integer; // Offset tratto
    StrokeCount: Integer; // Conteggio vertici tratto
  end;
  PGLNVGPath = ^TGLNVGPath;

  // Struttura per uniform del frammento
  TGLNVGFragUniforms = record
    ScissorMat: array[0..11] of Single; // Matrice 3x4 (3 vec4)
    PaintMat: array[0..11] of Single; // Matrice 3x4 (3 vec4)
    InnerCol: TNVGColor; // Colore interno
    OuterCol: TNVGColor; // Colore esterno
    ScissorExt: array[0..1] of Single; // Estensione scissor
    ScissorScale: array[0..1] of Single; // Scala scissor
    Extent: array[0..1] of Single; // Estensione pittura
    Radius: Single; // Raggio
    Feather: Single; // Sfumatura
    StrokeMult: Single; // Moltiplicatore tratto
    StrokeThr: Single; // Soglia tratto
    TexType: Integer; // Tipo texture
    ShaderType: Integer; // Tipo shader
  end;
  PGLNVGFragUniforms = ^TGLNVGFragUniforms;

  // Contesto OpenGL
  TGLNVGContext = record
    Shader: TGLNVGShader; // Shader
    Textures: PGLNVGTexture; // Array di texture
    View: array[0..1] of Single; // Dimensioni viewport
    NTextures: Integer; // Numero texture
    CTextures: Integer; // Capacità texture
    TextureID: Integer; // ID texture corrente
    VertBuf: GLuint; // Buffer vertici
    {$IFDEF NANOVG_GL3}
    VertArr: GLuint; // Array vertici
    {$ENDIF}
    {$IFDEF NANOVG_GL_USE_UNIFORMBUFFER}
    FragBuf: GLuint; // Buffer uniform frammento
    {$ENDIF}
    FragSize: Integer; // Dimensione uniform frammento
    Flags: Integer; // Flag contesto
    Calls: PGLNVGCall; // Array chiamate
    CCalls: Integer; // Capacità chiamate
    NCalls: Integer; // Numero chiamate
    Paths: PGLNVGPath; // Array percorsi
    CPaths: Integer; // Capacità percorsi
    NPaths: Integer; // Numero percorsi
    Verts: PNVGVertex; // Array vertici
    CVerts: Integer; // Capacità vertici
    NVerts: Integer; // Numero vertici
    Uniforms: PByte; // Array uniform
    CUniforms: Integer; // Capacità uniform
    NUniforms: Integer; // Numero uniform
    {$IFDEF NANOVG_GL_USE_STATE_FILTER}
    BoundTexture: GLuint; // Texture legata
    StencilMask: GLuint; // Maschera stencil
    StencilFunc: GLenum; // Funzione stencil
    StencilFuncRef: GLint; // Riferimento stencil
    StencilFuncMask: GLuint; // Maschera funzione stencil
    BlendFunc: TGLNVGBlend; // Funzione blending
    {$ENDIF}
    DummyTex: Integer; // Texture vuota
  end;
  PGLNVGContext = ^TGLNVGContext;

function nvgCreateGL2(Flags: Integer): PNVGContext;
procedure nvgDeleteGL2(Ctx: PNVGContext);
function nvglCreateImageFromHandleGL2(Ctx: PNVGContext; TextureID: GLuint; W, H, ImageFlags: Integer): Integer;
function nvglImageHandleGL2(Ctx: PNVGContext; Image: Integer): GLuint;

implementation

{$R ..\res\shaders.rc}

uses
  Math;

function LoadResourceString(ResourceName: string): string;
var
  Res: TResourceStream;
  Str: string;
begin
  Res := TResourceStream.Create(HInstance, ResourceName, RT_RCDATA);
  try
    SetLength(Str, Res.Size);
    Res.ReadBuffer(Str[1], Res.Size);
    Result := Str;
  finally
    Res.Free;
  end;
end;

function glnvg__MaxI(A, B: Integer): Integer;
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

procedure glnvg__BindTexture(GL: PGLNVGContext; Tex: GLuint);
begin
  {$IFDEF NANOVG_GL_USE_STATE_FILTER}
  if GL^.BoundTexture <> Tex then
  begin
    GL^.BoundTexture := Tex;
    glBindTexture(GL_TEXTURE_2D, Tex);
  end;
  {$ELSE}
  glBindTexture(GL_TEXTURE_2D, Tex);
  {$ENDIF}
end;

procedure glnvg__StencilMask(GL: PGLNVGContext; Mask: GLuint);
begin
  {$IFDEF NANOVG_GL_USE_STATE_FILTER}
  if GL^.StencilMask <> Mask then
  begin
    GL^.StencilMask := Mask;
    glStencilMask(Mask);
  end;
  {$ELSE}
  glStencilMask(Mask);
  {$ENDIF}
end;

procedure glnvg__StencilFunc(GL: PGLNVGContext; Func: GLenum; Ref: GLint; Mask: GLuint);
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
  glStencilFunc(Func, Ref, Mask);
  {$ENDIF}
end;

procedure glnvg__BlendFuncSeparate(GL: PGLNVGContext; Blend: PGLNVGBlend);
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
  glBlendFuncSeparate(Blend^.SrcRGB, Blend^.DstRGB, Blend^.SrcAlpha, Blend^.DstAlpha);
  {$ENDIF}
end;

function glnvg__AllocTexture(GL: PGLNVGContext): PGLNVGTexture;
var
  I: Integer;
  Textures: PGLNVGTexture;
  CTex: Integer;
begin
  Result := nil;
  for I := 0 to GL^.NTextures - 1 do
  begin
    if GL^.Textures[I].ID = 0 then
    begin
      Result := @GL^.Textures[I];
      Break;
    end;
  end;

  if Result = nil then
  begin
    if GL^.NTextures + 1 > GL^.CTextures then
    begin
      CTex := glnvg__MaxI(GL^.NTextures + 1, 4) + GL^.CTextures div 2;
      ReallocMem(GL^.Textures, SizeOf(TGLNVGTexture) * CTex);
      if GL^.Textures = nil then
        Exit;
      GL^.CTextures := CTex;
    end;
    Result := @GL^.Textures[GL^.NTextures];
    Inc(GL^.NTextures);
  end;

  FillChar(Result^, SizeOf(TGLNVGTexture), 0);
  Inc(GL^.TextureID);
  Result^.ID := GL^.TextureID;
end;

function glnvg__FindTexture(GL: PGLNVGContext; ID: Integer): PGLNVGTexture;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to GL^.NTextures - 1 do
  begin
    if GL^.Textures[I].ID = ID then
    begin
      Result := @GL^.Textures[I];
      Break;
    end;
  end;
end;

function glnvg__DeleteTexture(GL: PGLNVGContext; ID: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to GL^.NTextures - 1 do
  begin
    if GL^.Textures[I].ID = ID then
    begin
      if (GL^.Textures[I].Tex <> 0) and ((GL^.Textures[I].Flags and NVG_IMAGE_NODELETE) = 0) then
        glDeleteTextures(1, @GL^.Textures[I].Tex);
      FillChar(GL^.Textures[I], SizeOf(TGLNVGTexture), 0);
      Result := True;
      Break;
    end;
  end;
end;

procedure glnvg__DumpShaderError(Shader: GLuint; Name, ShaderType: string);
var
  Str: array[0..512] of Char;
  Len: GLsizei;
begin
  Len := 0;
  glGetShaderInfoLog(Shader, 512, @Len, @Str[0]);
  if Len > 512 then
    Len := 512;
  Str[Len] := #0;
  WriteLn(Format('Shader %s/%s error:'#10'%s', [Name, ShaderType, Str]));
end;

procedure glnvg__DumpProgramError(Prog: GLuint; Name: string);
var
  Str: array[0..512] of Char;
  Len: GLsizei;
begin
  Len := 0;
  glGetProgramInfoLog(Prog, 512, @Len, @Str[0]);
  if Len > 512 then
    Len := 512;
  Str[Len] := #0;
  WriteLn(Format('Program %s error:'#10'%s', [Name, Str]));
end;

procedure glnvg__CheckError(GL: PGLNVGContext; Str: string);
var
  Err: GLenum;
begin
  if (GL^.Flags and NVG_DEBUG) = 0 then
    Exit;
  Err := glGetError;
  if Err <> GL_NO_ERROR then
    WriteLn(Format('Error %08x after %s', [Err, Str]));
end;

function glnvg__CreateShader(Shader: PGLNVGShader; Name, Header, Opts, VShader, FShader: string): Boolean;
var
  Status: GLint;
  Prog, Vert, Frag: GLuint;
  Str: array[0..2] of PChar;
begin
  FillChar(Shader^, SizeOf(TGLNVGShader), 0);

  Prog := glCreateProgram;
  Vert := glCreateShader(GL_VERTEX_SHADER);
  Frag := glCreateShader(GL_FRAGMENT_SHADER);

  Str[0] := PChar(Header);
  Str[1] := IfThen(Opts <> '', PChar(Opts), '');
  Str[2] := PChar(VShader);
  glShaderSource(Vert, 3, @Str[0], nil);
  Str[2] := PChar(FShader);
  glShaderSource(Frag, 3, @Str[0], nil);

  glCompileShader(Vert);
  glGetShaderiv(Vert, GL_COMPILE_STATUS, @Status);
  if Status <> GL_TRUE then
  begin
    glnvg__DumpShaderError(Vert, Name, 'vert');
    glDeleteShader(Vert);
    glDeleteShader(Frag);
    glDeleteProgram(Prog);
    Exit(False);
  end;

  glCompileShader(Frag);
  glGetShaderiv(Frag, GL_COMPILE_STATUS, @Status);
  if Status <> GL_TRUE then
  begin
    glnvg__DumpShaderError(Frag, Name, 'frag');
    glDeleteShader(Vert);
    glDeleteShader(Frag);
    glDeleteProgram(Prog);
    Exit(False);
  end;

  glAttachShader(Prog, Vert);
  glAttachShader(Prog, Frag);

  glBindAttribLocation(Prog, 0, 'vertex');
  glBindAttribLocation(Prog, 1, 'tcoord');

  glLinkProgram(Prog);
  glGetProgramiv(Prog, GL_LINK_STATUS, @Status);
  if Status <> GL_TRUE then
  begin
    glnvg__DumpProgramError(Prog, Name);
    glDeleteShader(Vert);
    glDeleteShader(Frag);
    glDeleteProgram(Prog);
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
    glDeleteProgram(Shader^.Prog);
  if Shader^.Vert <> 0 then
    glDeleteShader(Shader^.Vert);
  if Shader^.Frag <> 0 then
    glDeleteShader(Shader^.Frag);
end;

procedure glnvg__GetUniforms(Shader: PGLNVGShader);
begin
  Shader^.Loc[GLNVG_LOC_VIEWSIZE] := glGetUniformLocation(Shader^.Prog, 'viewSize');
  Shader^.Loc[GLNVG_LOC_TEX] := glGetUniformLocation(Shader^.Prog, 'tex');
  {$IFDEF NANOVG_GL_USE_UNIFORMBUFFER}
  Shader^.Loc[GLNVG_LOC_FRAG] := glGetUniformBlockIndex(Shader^.Prog, 'frag');
  {$ELSE}
  Shader^.Loc[GLNVG_LOC_FRAG] := glGetUniformLocation(Shader^.Prog, 'frag');
  {$ENDIF}
end;

function glnvg__RenderCreateTexture(Uptr: Pointer; TexType, W, H, ImageFlags: Integer; Data: PByte): Integer; forward;

function glnvg__RenderCreate(Uptr: Pointer): Integer;
var
  GL: PGLNVGContext;
  Align: Integer;
  ShaderHeader, FillVertShader, FillFragShader: string;
begin
  GL := PGLNVGContext(Uptr);
  Align := 4;

  glnvg__CheckError(GL, 'init');

  // Carica gli shader dalle risorse
  ShaderHeader := LoadResourceString('SHADER_HEADER');
  FillVertShader := LoadResourceString('FILL_VERT_SHADER');
  FillFragShader := LoadResourceString('FILL_FRAG_SHADER');

  if (GL^.Flags and NVG_ANTIALIAS) <> 0 then
  begin
    if not glnvg__CreateShader(@GL^.Shader, 'shader', ShaderHeader, '#define EDGE_AA 1'#10, FillVertShader, FillFragShader) then
      Exit(0);
  end
  else
  begin
    if not glnvg__CreateShader(@GL^.Shader, 'shader', ShaderHeader, '', FillVertShader, FillFragShader) then
      Exit(0);
  end;

  glnvg__CheckError(GL, 'uniform locations');
  glnvg__GetUniforms(@GL^.Shader);

  {$IFDEF NANOVG_GL3}
  glGenVertexArrays(1, @GL^.VertArr);
  {$ENDIF}
  glGenBuffers(1, @GL^.VertBuf);

  {$IFDEF NANOVG_GL_USE_UNIFORMBUFFER}
  glUniformBlockBinding(GL^.Shader.Prog, GL^.Shader.Loc[GLNVG_LOC_FRAG], 0 {GLNVG_FRAG_BINDING});
  glGenBuffers(1, @GL^.FragBuf);
  glGetIntegerv(GL_UNIFORM_BUFFER_OFFSET_ALIGNMENT, @Align);
  {$ENDIF}
  GL^.FragSize := SizeOf(TGLNVGFragUniforms) + Align - SizeOf(TGLNVGFragUniforms) mod Align;

  GL^.DummyTex := glnvg__RenderCreateTexture(GL, NVG_TEXTURE_ALPHA, 1, 1, 0, nil);

  glnvg__CheckError(GL, 'create done');

  glFinish;

  Result := 1;
end;

function glnvg__RenderCreateTexture(Uptr: Pointer; TexType, W, H, ImageFlags: Integer; Data: PByte): Integer;
var
  GL: PGLNVGContext;
  Tex: PGLNVGTexture;
begin
  GL := PGLNVGContext(Uptr);
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

  glGenTextures(1, @Tex^.Tex);
  Tex^.Width := W;
  Tex^.Height := H;
  Tex^.TexType := TexType;
  Tex^.Flags := ImageFlags;
  glnvg__BindTexture(GL, Tex^.Tex);

  glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
  {$IFNDEF NANOVG_GLES2}
  glPixelStorei(GL_UNPACK_ROW_LENGTH, Tex^.Width);
  glPixelStorei(GL_UNPACK_SKIP_PIXELS, 0);
  glPixelStorei(GL_UNPACK_SKIP_ROWS, 0);
  {$ENDIF}

  {$IFDEF NANOVG_GL2}
  if (ImageFlags and NVG_IMAGE_GENERATE_MIPMAPS) <> 0 then
    glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, GL_TRUE);
  {$ENDIF}

  if TexType = NVG_TEXTURE_RGBA then
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, W, H, 0, GL_RGBA, GL_UNSIGNED_BYTE, Data)
  else
    {$IF defined(NANOVG_GLES2) or defined(NANOVG_GL2)}
    glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, W, H, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, Data)
    {$ELSE}
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RED, W, H, 0, GL_RED, GL_UNSIGNED_BYTE, Data);
    {$ENDIF}

  if (ImageFlags and NVG_IMAGE_GENERATE_MIPMAPS) <> 0 then
  begin
    if (ImageFlags and NVG_IMAGE_NEAREST) <> 0 then
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_NEAREST)
    else
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
  end
  else
  begin
    if (ImageFlags and NVG_IMAGE_NEAREST) <> 0 then
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
    else
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  end;

  if (ImageFlags and NVG_IMAGE_NEAREST) <> 0 then
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
  else
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

  if (ImageFlags and NVG_IMAGE_REPEATX) <> 0 then
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT)
  else
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);

  if (ImageFlags and NVG_IMAGE_REPEATY) <> 0 then
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT)
  else
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

  glPixelStorei(GL_UNCHECK_ALIGNMENT, 4);
  {$IFNDEF NANOVG_GLES2}
  glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
  glPixelStorei(GL_UNPACK_SKIP_PIXELS, 0);
  glPixelStorei(GL_UNPACK_SKIP_ROWS, 0);
  {$ENDIF}

  {$IFNDEF NANOVG_GL2}
  if (ImageFlags and NVG_IMAGE_GENERATE_MIPMAPS) <> 0 then
    glGenerateMipmap(GL_TEXTURE_2D);
  {$ENDIF}

  glnvg__CheckError(GL, 'create tex');
  glnvg__BindTexture(GL, 0);

  Result := Tex^.ID;
end;

function glnvg__RenderDeleteTexture(Uptr: Pointer; Image: Integer): Integer;
begin
  Result := Ord(glnvg__DeleteTexture(PGLNVGContext(Uptr), Image));
end;

function glnvg__RenderUpdateTexture(Uptr: Pointer; Image, X, Y, W, H: Integer; Data: PByte): Integer;
var
  GL: PGLNVGContext;
  Tex: PGLNVGTexture;
begin
  GL := PGLNVGContext(Uptr);
  Tex := glnvg__FindTexture(GL, Image);
  if Tex = nil then
    Exit(0);

  glnvg__BindTexture(GL, Tex^.Tex);

  glPixelStorei(GL_UNPACK_ALIGNMENT, 1);

  {$IFNDEF NANOVG_GLES2}
  glPixelStorei(GL_UNPACK_ROW_LENGTH, Tex^.Width);
  glPixelStorei(GL_UNPACK_SKIP_PIXELS, X);
  glPixelStorei(GL_UNPACK_SKIP_ROWS, Y);
  {$ELSE}
  if Tex^.TexType = NVG_TEXTURE_RGBA then
    Inc(Data, Y * Tex^.Width * 4)
  else
    Inc(Data, Y * Tex^.Width);
  X := 0;
  W := Tex^.Width;
  {$ENDIF}

  if Tex^.TexType = NVG_TEXTURE_RGBA then
    glTexSubImage2D(GL_TEXTURE_2D, 0, X, Y, W, H, GL_RGBA, GL_UNSIGNED_BYTE, Data)
  else
    {$IF defined(NANOVG_GLES2) or defined(NANOVG_GL2)}
    glTexSubImage2D(GL_TEXTURE_2D, 0, X, Y, W, H, GL_LUMINANCE, GL_UNSIGNED_BYTE, Data)
    {$ELSE}
    glTexSubImage2D(GL_TEXTURE_2D, 0, X, Y, W, H, GL_RED, GL_UNSIGNED_BYTE, Data);
    {$ENDIF}

  glPixelStorei(GL_UNPACK_ALIGNMENT, 4);
  {$IFNDEF NANOVG_GLES2}
  glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
  glPixelStorei(GL_UNPACK_SKIP_PIXELS, 0);
  glPixelStorei(GL_UNPACK_SKIP_ROWS, 0);
  {$ENDIF}

  glnvg__BindTexture(GL, 0);

  Result := 1;
end;

function glnvg__RenderGetTextureSize(Uptr: Pointer; Image: Integer; W, H: PInteger): Integer;
var
  GL: PGLNVGContext;
  Tex: PGLNVGTexture;
begin
  GL := PGLNVGContext(Uptr);
  Tex := glnvg__FindTexture(GL, Image);
  if Tex = nil then
    Exit(0);
  W^ := Tex^.Width;
  H^ := Tex^.Height;
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

function glnvg__ConvertPaint(GL: PGLNVGContext; Frag: PGLNVGFragUniforms; Paint: PNVGPaint;
  Scissor: PNVGScissor; Width, Fringe, StrokeThr: Single): Boolean;
var
  Tex: PGLNVGTexture;
  InvXform, M1, M2: array[0..5] of Single;
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
    if (Tex^.Flags and NVG_IMAGE_FLIPY) <> 0 then
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
    if Tex^.TexType = NVG_TEXTURE_RGBA then
      Frag^.TexType := IfThen((Tex^.Flags and NVG_IMAGE_PREMULTIPLIED) <> 0, 0.0, 1.0)
    else
      Frag^.TexType := 2.0;
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

function nvg__FragUniformPtr(GL: PGLNVGContext; I: Integer): PGLNVGFragUniforms;
begin
  Result := PGLNVGFragUniforms(PByte(GL^.Uniforms) + I);
end;

procedure glnvg__SetUniforms(GL: PGLNVGContext; UniformOffset, Image: Integer);
var
  Tex: PGLNVGTexture;
  Frag: PGLNVGFragUniforms;
begin
  {$IFDEF NANOVG_GL_USE_UNIFORMBUFFER}
  glBindBufferRange(GL_UNIFORM_BUFFER, 0 {GLNVG_FRAG_BINDING}, GL^.FragBuf, UniformOffset, SizeOf(TGLNVGFragUniforms));
  {$ELSE}
  Frag := nvg__FragUniformPtr(GL, UniformOffset);
  glUniform4fv(GL^.Shader.Loc[GLNVG_LOC_FRAG], 11 {NANOVG_GL_UNIFORMARRAY_SIZE}, @Frag^.ScissorMat[0]);
  {$ENDIF}

  if Image <> 0 then
    Tex := glnvg__FindTexture(GL, Image);
  if Tex = nil then
    Tex := glnvg__FindTexture(GL, GL^.DummyTex);
  glnvg__BindTexture(GL, IfThen(Tex <> nil, Tex^.Tex, 0));
  glnvg__CheckError(GL, 'tex paint tex');
end;

procedure glnvg__RenderViewport(Uptr: Pointer; Width, Height, DevicePixelRatio: Single);
var
  GL: PGLNVGContext;
begin
  GL := PGLNVGContext(Uptr);
  GL^.View[0] := Width;
  GL^.View[1] := Height;
end;

procedure glnvg__Fill(GL: PGLNVGContext; Call: PGLNVGCall);
var
  Paths: PGLNVGPath;
  I, NPaths: Integer;
begin
  Paths := @GL^.Paths[Call^.PathOffset];
  NPaths := Call^.PathCount;

  glEnable(GL_STENCIL_TEST);
  glnvg__StencilMask(GL, $FF);
  glnvg__StencilFunc(GL, GL_ALWAYS, 0, $FF);
  glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE);

  glnvg__SetUniforms(GL, Call^.UniformOffset, 0);
  glnvg__CheckError(GL, 'fill simple');

  glStencilOpSeparate(GL_FRONT, GL_KEEP, GL_KEEP, GL_INCR_WRAP);
  glStencilOpSeparate(GL_BACK, GL_KEEP, GL_KEEP, GL_DECR_WRAP);
  glDisable(GL_CULL_FACE);
  for I := 0 to NPaths - 1 do
    glDrawArrays(GL_TRIANGLE_FAN, Paths[I].FillOffset, Paths[I].FillCount);
  glEnable(GL_CULL_FACE);

  glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);

  glnvg__SetUniforms(GL, Call^.UniformOffset + GL^.FragSize, Call^.Image);
  glnvg__CheckError(GL, 'fill fill');

  if (GL^.Flags and NVG_ANTIALIAS) <> 0 then
  begin
    glnvg__StencilFunc(GL, GL_EQUAL, $00, $FF);
    glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
    for I := 0 to NPaths - 1 do
      glDrawArrays(GL_TRIANGLE_STRIP, Paths[I].StrokeOffset, Paths[I].StrokeCount);
  end;

  glnvg__StencilFunc(GL, GL_NOTEQUAL, $0, $FF);
  glStencilOp(GL_ZERO, GL_ZERO, GL_ZERO);
  glDrawArrays(GL_TRIANGLE_STRIP, Call^.TriangleOffset, Call^.TriangleCount);

  glDisable(GL_STENCIL_TEST);
end;

procedure glnvg__ConvexFill(GL: PGLNVGContext; Call: PGLNVGCall);
var
  Paths: PGLNVGPath;
  I, NPaths: Integer;
begin
  Paths := @GL^.Paths[Call^.PathOffset];
  NPaths := Call^.PathCount;

  glnvg__SetUniforms(GL, Call^.UniformOffset, Call^.Image);
  glnvg__CheckError(GL, 'convex fill');

  for I := 0 to NPaths - 1 do
  begin
    glDrawArrays(GL_TRIANGLE_FAN, Paths[I].FillOffset, Paths[I].FillCount);
    if Paths[I].StrokeCount > 0 then
      glDrawArrays(GL_TRIANGLE_STRIP, Paths[I].StrokeOffset, Paths[I].StrokeCount);
  end;
end;

procedure glnvg__Stroke(GL: PGLNVGContext; Call: PGLNVGCall);
var
  Paths: PGLNVGPath;
  I, NPaths: Integer;
begin
  Paths := @GL^.Paths[Call^.PathOffset];
  NPaths := Call^.PathCount;

  if (GL^.Flags and NVG_STENCIL_STROKES) <> 0 then
  begin
    glEnable(GL_STENCIL_TEST);
    glnvg__StencilMask(GL, $FF);

    glnvg__StencilFunc(GL, GL_EQUAL, $0, $FF);
    glStencilOp(GL_KEEP, GL_KEEP, GL_INCR);
    glnvg__SetUniforms(GL, Call^.UniformOffset + GL^.FragSize, Call^.Image);
    glnvg__CheckError(GL, 'stroke fill 0');
    for I := 0 to NPaths - 1 do
      glDrawArrays(GL_TRIANGLE_STRIP, Paths[I].StrokeOffset, Paths[I].StrokeCount);

    glnvg__SetUniforms(GL, Call^.UniformOffset, Call^.Image);
    glnvg__StencilFunc(GL, GL_EQUAL, $00, $FF);
    glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
    for I := 0 to NPaths - 1 do
      glDrawArrays(GL_TRIANGLE_STRIP, Paths[I].StrokeOffset, Paths[I].StrokeCount);

    glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE);
    glnvg__StencilFunc(GL, GL_ALWAYS, $0, $FF);
    glStencilOp(GL_ZERO, GL_ZERO, GL_ZERO);
    glnvg__CheckError(GL, 'stroke fill 1');
    for I := 0 to NPaths - 1 do
      glDrawArrays(GL_TRIANGLE_STRIP, Paths[I].StrokeOffset, Paths[I].StrokeCount);
    glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);

    glDisable(GL_STENCIL_TEST);
  end
  else
  begin
    glnvg__SetUniforms(GL, Call^.UniformOffset, Call^.Image);
    glnvg__CheckError(GL, 'stroke fill');
    for I := 0 to NPaths - 1 do
      glDrawArrays(GL_TRIANGLE_STRIP, Paths[I].StrokeOffset, Paths[I].StrokeCount);
  end;
end;

procedure glnvg__Triangles(GL: PGLNVGContext; Call: PGLNVGCall);
begin
  glnvg__SetUniforms(GL, Call^.UniformOffset, Call^.Image);
  glnvg__CheckError(GL, 'triangles fill');
  glDrawArrays(GL_TRIANGLES, Call^.TriangleOffset, Call^.TriangleCount);
end;

procedure glnvg__RenderCancel(Uptr: Pointer);
var
  GL: PGLNVGContext;
begin
  GL := PGLNVGContext(Uptr);
  GL^.NVerts := 0;
  GL^.NPaths := 0;
  GL^.NCalls := 0;
  GL^.NUniforms := 0;
end;

function glnvg__ConvertBlendFuncFactor(Factor: Integer): GLenum;
begin
  case Factor of
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
  if (Result.SrcRGB = GL_INVALID_ENUM) or (Result.DstRGB = GL_INVALID_ENUM) or
     (Result.SrcAlpha = GL_INVALID_ENUM) or (Result.DstAlpha = GL_INVALID_ENUM) then
  begin
    Result.SrcRGB := GL_ONE;
    Result.DstRGB := GL_ONE_MINUS_SRC_ALPHA;
    Result.SrcAlpha := GL_ONE;
    Result.DstAlpha := GL_ONE_MINUS_SRC_ALPHA;
  end;
end;

procedure glnvg__RenderFlush(Uptr: Pointer);
var
  GL: PGLNVGContext;
  I: Integer;
  Call: PGLNVGCall;
begin
  GL := PGLNVGContext(Uptr);
  if GL^.NCalls > 0 then
  begin
    glUseProgram(GL^.Shader.Prog);

    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);
    glFrontFace(GL_CCW);
    glEnable(GL_BLEND);
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_SCISSOR_TEST);
    glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
    glStencilMask($FFFFFFFF);
    glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
    glStencilFunc(GL_ALWAYS, 0, $FFFFFFFF);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, 0);
    {$IFDEF NANOVG_GL_USE_STATE_FILTER}
    GL^.BoundTexture := 0;
    GL^.StencilMask := $FFFFFFFF;
    GL^.StencilFunc := GL_ALWAYS;
    GL^.StencilFuncRef := 0;
    GL^.StencilFuncMask := $FFFFFFFF;
    GL^.BlendFunc.SrcRGB := GL_INVALID_ENUM;
    GL^.BlendFunc.SrcAlpha := GL_INVALID_ENUM;
    GL^.BlendFunc.DstRGB := GL_INVALID_ENUM;
    GL^.BlendFunc.DstAlpha := GL_INVALID_ENUM;
    {$ENDIF}

    {$IFDEF NANOVG_GL_USE_UNIFORMBUFFER}
    glBindBuffer(GL_UNIFORM_BUFFER, GL^.FragBuf);
    glBufferData(GL_UNIFORM_BUFFER, GL^.NUniforms * GL^.FragSize, GL^.Uniforms, GL_STREAM_DRAW);
    {$ENDIF}

    {$IFDEF NANOVG_GL3}
    glBindVertexArray(GL^.VertArr);
    {$ENDIF}
    glBindBuffer(GL_ARRAY_BUFFER, GL^.VertBuf);
    glBufferData(GL_ARRAY_BUFFER, GL^.NVerts * SizeOf(TNVGVertex), GL^.Verts, GL_STREAM_DRAW);
    glEnableVertexAttribArray(0);
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, SizeOf(TNVGVertex), Pointer(0));
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, SizeOf(TNVGVertex), Pointer(2 * SizeOf(Single)));

    glUniform1i(GL^.Shader.Loc[GLNVG_LOC_TEX], 0);
    glUniform2fv(GL^.Shader.Loc[GLNVG_LOC_VIEWSIZE], 1, @GL^.View[0]);

    {$IFDEF NANOVG_GL_USE_UNIFORMBUFFER}
    glBindBuffer(GL_UNIFORM_BUFFER, GL^.FragBuf);
    {$ENDIF}

    for I := 0 to GL^.NCalls - 1 do
    begin
      Call := @GL^.Calls[I];
      glnvg__BlendFuncSeparate(GL, @Call^.BlendFunc);
      case Call^.CallType of
        GLNVG_FILL: glnvg__Fill(GL, Call);
        GLNVG_CONVEXFILL: glnvg__ConvexFill(GL, Call);
        GLNVG_STROKE: glnvg__Stroke(GL, Call);
        GLNVG_TRIANGLES: glnvg__Triangles(GL, Call);
      end;
    end;

    glDisableVertexAttribArray(0);
    glDisableVertexAttribArray(1);
    {$IFDEF NANOVG_GL3}
    glBindVertexArray(0);
    {$ENDIF}
    glDisable(GL_CULL_FACE);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glUseProgram(0);
    glnvg__BindTexture(GL, 0);
  end;

  GL^.NVerts := 0;
  GL^.NPaths := 0;
  GL^.NCalls := 0;
  GL^.NUniforms := 0;
end;

function glnvg__MaxVertCount(Paths: TNVGPathArray; NPaths: Integer): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to NPaths - 1 do
  begin
    Inc(Result, Paths[I].NPoints);
    Inc(Result, Paths[I].NStroke);
  end;
end;

function glnvg__AllocCall(GL: PGLNVGContext): PGLNVGCall;
var
  CCalls: Integer;
begin
  if GL^.NCalls + 1 > GL^.CCalls then
  begin
    CCalls := glnvg__MaxI(GL^.NCalls + 1, 128) + GL^.CCalls div 2;
    ReallocMem(GL^.Calls, SizeOf(TGLNVGCall) * CCalls);
    if GL^.Calls = nil then
      Exit(nil);
    GL^.CCalls := CCalls;
  end;
  Result := @GL^.Calls[GL^.NCalls];
  Inc(GL^.NCalls);
  FillChar(Result^, SizeOf(TGLNVGCall), 0);
end;

function glnvg__AllocPaths(GL: PGLNVGContext; N: Integer): Integer;
var
  CPaths: Integer;
begin
  if GL^.NPaths + N > GL^.CPaths then
  begin
    CPaths := glnvg__MaxI(GL^.NPaths + N, 128) + GL^.CPaths div 2;
    ReallocMem(GL^.Paths, SizeOf(TGLNVGPath) * CPaths);
    if GL^.Paths = nil then
      Exit(-1);
    GL^.CPaths := CPaths;
  end;
  Result := GL^.NPaths;
  Inc(GL^.NPaths, N);
end;

function glnvg__AllocVerts(GL: PGLNVGContext; N: Integer): Integer;
var
  CVerts: Integer;
begin
  if GL^.NVerts + N > GL^.CVerts then
  begin
    CVerts := glnvg__MaxI(GL^.NVerts + N, 4096) + GL^.CVerts div 2;
    ReallocMem(GL^.Verts, SizeOf(TNVGVertex) * CVerts);
    if GL^.Verts = nil then
      Exit(-1);
    GL^.CVerts := CVerts;
  end;
  Result := GL^.NVerts;
  Inc(GL^.NVerts, N);
end;

function glnvg__AllocFragUniforms(GL: PGLNVGContext; N: Integer): Integer;
var
  CUniforms, StructSize: Integer;
begin
  StructSize := GL^.FragSize;
  if GL^.NUniforms + N > GL^.CUniforms then
  begin
    CUniforms := glnvg__MaxI(GL^.NUniforms + N, 128) + GL^.CUniforms div 2;
    ReallocMem(GL^.Uniforms, StructSize * CUniforms);
    if GL^.Uniforms = nil then
      Exit(-1);
    GL^.CUniforms := CUniforms;
  end;
  Result := GL^.NUniforms * StructSize;
  Inc(GL^.NUniforms, N);
end;

procedure glnvg__VSet(Vtx: PNVGVertex; X, Y, U, V: Single);
begin
  Vtx^.X := X;
  Vtx^.Y := Y;
  Vtx^.U := U;
  Vtx^.V := V;
end;

procedure glnvg__RenderFill(Uptr: Pointer; Paint: PNVGPaint; CompositeOperation: TNVGCompositeOperationState;
  Scissor: PNVGScissor; Fringe: Single; Bounds: PSingle; Paths: TNVGPathArray; NPaths: Integer);
var
  GL: PGLNVGContext;
  Call: PGLNVGCall;
  Quad: PNVGVertex;
  Frag: PGLNVGFragUniforms;
  I, MaxVerts, Offset: Integer;
begin
  GL := PGLNVGContext(Uptr);
  Call := glnvg__AllocCall(GL);
  if Call = nil then
    Exit;

  Call^.CallType := GLNVG_FILL;
  Call^.TriangleCount := 4;
  Call^.PathOffset := glnvg__AllocPaths(GL, NPaths);
  if Call^.PathOffset = -1 then
    goto error;
  Call^.PathCount := NPaths;
  Call^.Image := Paint^.Image;
  Call^.BlendFunc := glnvg__BlendCompositeOperation(CompositeOperation);

  if (NPaths = 1) and Paths[0].Closed <> 0 then
  begin
    Call^.CallType := GLNVG_CONVEXFILL;
    Call^.TriangleCount := 0;
  end;

  MaxVerts := glnvg__MaxVertCount(Paths, NPaths) + Call^.TriangleCount;
  Offset := glnvg__AllocVerts(GL, MaxVerts);
  if Offset = -1 then
    goto error;

  for I := 0 to NPaths - 1 do
  begin
    GL^.Paths[Call^.PathOffset + I].FillOffset := Offset;
    GL^.Paths[Call^.PathOffset + I].FillCount := Paths[I].NPoints;
    Move(Paths[I].Points^, GL^.Verts[Offset], SizeOf(TNVGVertex) * Paths[I].NPoints);
    Inc(Offset, Paths[I].NPoints);
    GL^.Paths[Call^.PathOffset + I].StrokeOffset := Offset;
    GL^.Paths[Call^.PathOffset + I].StrokeCount := Paths[I].NStroke;
    Move(Paths[I].Stroke^, GL^.Verts[Offset], SizeOf(TNVGVertex) * Paths[I].NStroke);
    Inc(Offset, Paths[I].NStroke);
  end;

  if Call^.CallType = GLNVG_FILL then
  begin
    Call^.TriangleOffset := Offset;
    Quad := @GL^.Verts[Call^.TriangleOffset];
    glnvg__VSet(@Quad[0], Bounds[2], Bounds[3], 0.5, 1.0);
    glnvg__VSet(@Quad[1], Bounds[2], Bounds[1], 0.5, 1.0);
    glnvg__VSet(@Quad[2], Bounds[0], Bounds[3], 0.5, 1.0);
    glnvg__VSet(@Quad[3], Bounds[0], Bounds[1], 0.5, 1.0);

    Call^.UniformOffset := glnvg__AllocFragUniforms(GL, 2);
    if Call^.UniformOffset = -1 then
      goto error;

    Frag := nvg__FragUniformPtr(GL, Call^.UniformOffset);
    FillChar(Frag^, SizeOf(TGLNVGFragUniforms), 0);
    Frag^.StrokeThr := -1.0;
    Frag^.ShaderType := NSVG_SHADER_SIMPLE;

    glnvg__ConvertPaint(GL, nvg__FragUniformPtr(GL, Call^.UniformOffset + GL^.FragSize), Paint, Scissor, Fringe, Fringe, -1.0);
  end
  else
  begin
    Call^.UniformOffset := glnvg__AllocFragUniforms(GL, 1);
    if Call^.UniformOffset = -1 then
      goto error;
    glnvg__ConvertPaint(GL, nvg__FragUniformPtr(GL, Call^.UniformOffset), Paint, Scissor, Fringe, Fringe, -1.0);
  end;

  Exit;

error:
  if GL^.NCalls > 0 then
    Dec(GL^.NCalls);
end;

procedure glnvg__RenderStroke(Uptr: Pointer; Paint: PNVGPaint; CompositeOperation: TNVGCompositeOperationState;
  Scissor: PNVGScissor; Fringe, StrokeWidth: Single; Paths: TNVGPathArray; NPaths: Integer);
var
  GL: PGLNVGContext;
  Call: PGLNVGCall;
  I, MaxVerts, Offset: Integer;
begin
  GL := PGLNVGContext(Uptr);
  Call := glnvg__AllocCall(GL);
  if Call = nil then
    Exit;

  Call^.CallType := GLNVG_STROKE;
  Call^.PathOffset := glnvg__AllocPaths(GL, NPaths);
  if Call^.PathOffset = -1 then
    goto error;
  Call^.PathCount := NPaths;
  Call^.Image := Paint^.Image;
  Call^.BlendFunc := glnvg__BlendCompositeOperation(CompositeOperation);

  MaxVerts := glnvg__MaxVertCount(Paths, NPaths);
  Offset := glnvg__AllocVerts(GL, MaxVerts);
  if Offset = -1 then
    goto error;

  for I := 0 to NPaths - 1 do
  begin
    GL^.Paths[Call^.PathOffset + I].StrokeOffset := Offset;
    GL^.Paths[Call^.PathOffset + I].StrokeCount := Paths[I].NStroke;
    Move(Paths[I].Stroke^, GL^.Verts[Offset], SizeOf(TNVGVertex) * Paths[I].NStroke);
    Inc(Offset, Paths[I].NStroke);
  end;

  if (GL^.Flags and NVG_STENCIL_STROKES) <> 0 then
  begin
    Call^.UniformOffset := glnvg__AllocFragUniforms(GL, 2);
    if Call^.UniformOffset = -1 then
      goto error;

    glnvg__ConvertPaint(GL, nvg__FragUniformPtr(GL, Call^.UniformOffset), Paint, Scissor, StrokeWidth, Fringe, -1.0);
    glnvg__ConvertPaint(GL, nvg__FragUniformPtr(GL, Call^.UniformOffset + GL^.FragSize), Paint, Scissor, StrokeWidth, Fringe, 1.0 - 0.5/255.0);
  end
  else
  begin
    Call^.UniformOffset := glnvg__AllocFragUniforms(GL, 1);
    if Call^.UniformOffset = -1 then
      goto error;
    glnvg__ConvertPaint(GL, nvg__FragUniformPtr(GL, Call^.UniformOffset), Paint, Scissor, StrokeWidth, Fringe, -1.0);
  end;

  Exit;

error:
  if GL^.NCalls > 0 then
    Dec(GL^.NCalls);
end;

procedure glnvg__RenderTriangles(Uptr: Pointer; Paint: PNVGPaint; CompositeOperation: TNVGCompositeOperationState;
  Scissor: PNVGScissor; Verts: TNVGVertexArray; NVerts: Integer; Fringe: Single);
var
  GL: PGLNVGContext;
  Call: PGLNVGCall;
  Frag: PGLNVGFragUniforms;
begin
  GL := PGLNVGContext(Uptr);
  Call := glnvg__AllocCall(GL);
  if Call = nil then
    Exit;

  Call^.CallType := GLNVG_TRIANGLES;
  Call^.Image := Paint^.Image;
  Call^.BlendFunc := glnvg__BlendCompositeOperation(CompositeOperation);

  Call^.TriangleOffset := glnvg__AllocVerts(GL, NVerts);
  if Call^.TriangleOffset = -1 then
    goto error;
  Call^.TriangleCount := NVerts;

  Move(Verts[0], GL^.Verts[Call^.TriangleOffset], SizeOf(TNVGVertex) * NVerts);

  Call^.UniformOffset := glnvg__AllocFragUniforms(GL, 1);
  if Call^.UniformOffset = -1 then
    goto error;
  Frag := nvg__FragUniformPtr(GL, Call^.UniformOffset);
  glnvg__ConvertPaint(GL, Frag, Paint, Scissor, 1.0, Fringe, -1.0);
  Frag^.ShaderType := NSVG_SHADER_IMG;

  Exit;

error:
  if GL^.NCalls > 0 then
    Dec(GL^.NCalls);
end;

procedure glnvg__RenderDelete(Uptr: Pointer);
var
  GL: PGLNVGContext;
  I: Integer;
begin
  GL := PGLNVGContext(Uptr);
  if GL = nil then
    Exit;

  glnvg__DeleteShader(@GL^.Shader);

  {$IFDEF NANOVG_GL3}
  {$IFDEF NANOVG_GL_USE_UNIFORMBUFFER}
  if GL^.FragBuf <> 0 then
    glDeleteBuffers(1, @GL^.FragBuf);
  {$ENDIF}
  if GL^.VertArr <> 0 then
    glDeleteVertexArrays(1, @GL^.VertArr);
  {$ENDIF}
  if GL^.VertBuf <> 0 then
    glDeleteBuffers(1, @GL^.VertBuf);

  for I := 0 to GL^.NTextures - 1 do
  begin
    if (GL^.Textures[I].Tex <> 0) and ((GL^.Textures[I].Flags and NVG_IMAGE_NODELETE) = 0) then
      glDeleteTextures(1, @GL^.Textures[I].Tex);
  end;
  FreeMem(GL^.Textures);

  FreeMem(GL^.Paths);
  FreeMem(GL^.Verts);
  FreeMem(GL^.Uniforms);
  FreeMem(GL^.Calls);

  FreeMem(GL);
end;

function nvgCreateGL2(Flags: Integer): PNVGContext;
var
  Params: TNVGParams;
  Ctx: PNVGContext;
  GL: PGLNVGContext;
begin
  GetMem(GL, SizeOf(TGLNVGContext));
  if GL = nil then
    Exit(nil);
  FillChar(GL^, SizeOf(TGLNVGContext), 0);

  FillChar(Params, SizeOf(TNVGParams), 0);
  Params.RenderCreate := @glnvg__RenderCreate;
  Params.RenderCreateTexture := @glnvg__RenderCreateTexture;
  Params.RenderDeleteTexture := @glnvg__RenderDeleteTexture;
  Params.RenderUpdateTexture := @glnvg__RenderUpdateTexture;
  Params.RenderGetTextureSize := @glnvg__RenderGetTextureSize;
  Params.RenderViewport := @glnvg__RenderViewport;
  Params.RenderCancel := @glnvg__RenderCancel;
  Params.RenderFlush := @glnvg__RenderFlush;
  Params.RenderFill := @glnvg__RenderFill;
  Params.RenderStroke := @glnvg__RenderStroke;
  Params.RenderTriangles := @glnvg__RenderTriangles;
  Params.RenderDelete := @glnvg__RenderDelete;
  Params.UserPtr := GL;
  Params.EdgeAntiAlias := IfThen((Flags and NVG_ANTIALIAS) <> 0, 1, 0);

  GL^.Flags := Flags;

  Ctx := nvgCreateContext(Params.Width, Params.Height);
  if Ctx = nil then
  begin
    FreeMem(GL);
    Exit(nil);
  end;

  Result := Ctx;
end;

procedure nvgDeleteGL2(Ctx: PNVGContext);
begin
  nvgDestroyContext(Ctx);
end;

function nvglCreateImageFromHandleGL2(Ctx: PNVGContext; TextureID: GLuint; W, H, ImageFlags: Integer): Integer;
var
  GL: PGLNVGContext;
  Tex: PGLNVGTexture;
begin
  GL := PGLNVGContext(Ctx^.Params.UserPtr);
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

function nvglImageHandleGL2(Ctx: PNVGContext; Image: Integer): GLuint;
var
  GL: PGLNVGContext;
  Tex: PGLNVGTexture;
begin
  GL := PGLNVGContext(Ctx^.Params.UserPtr);
  Tex := glnvg__FindTexture(GL, Image);
  if Tex = nil then
    Exit(0);
  Result := Tex^.Tex;
end;

end.
