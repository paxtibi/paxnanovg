unit pax.gles;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, pax.gl;
const
{$IFDEF WINDOWS}
  // ANGLE su Windows: prima prova libGLESv2.dll (standard), poi GLESv2.dll
  libGLES = 'libGLESv2.dll';
{$ELSEIF DEFINED(ANDROID)}
  libGLES = 'libGLESv2.so';
{$ELSEIF DEFINED(LINUX)}
  libGLES = 'libGLESv2.so';         // Mesa, Raspberry Pi, ecc.
{$ELSEIF DEFINED(DARWIN)}
  libGLES = 'OpenGLES';             // Framework iOS/macOS
{$ELSE}
  libGLES = 'libGLESv2.so';
{$ENDIF}

type
  IGLES_2_0 = interface
    ['{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}']

    // ──────────────────────────────────────────────────────────────
    // Core State Management
    // ──────────────────────────────────────────────────────────────
    procedure glActiveTexture(texture: GLenum);
    procedure glBindTexture(target: GLenum; texture: GLuint);
    procedure glDisable(cap: GLenum);
    procedure glEnable(cap: GLenum);
    function glIsEnabled(cap: GLenum): GLboolean;

    // ──────────────────────────────────────────────────────────────
    // Buffer Objects
    // ──────────────────────────────────────────────────────────────
    procedure glBindBuffer(target: GLenum; buffer: GLuint);
    procedure glBufferData(target: GLenum; size: GLsizeiptr; const Data: Pointer; usage: GLenum);
    procedure glBufferSubData(target: GLenum; offset: GLintptr; size: GLsizeiptr; const Data: Pointer);
    procedure glDeleteBuffers(n: GLsizei; const buffers: PGLuint);
    procedure glGenBuffers(n: GLsizei; buffers: PGLuint);
    function glIsBuffer(buffer: GLuint): GLboolean;
    procedure glGetBufferParameteriv(target: GLenum; pname: GLenum; params: PGLint);

    // ──────────────────────────────────────────────────────────────
    // Framebuffer Objects (via extension OES_framebuffer_object in ES 2.0)
    // ──────────────────────────────────────────────────────────────
    procedure glBindFramebuffer(target: GLenum; framebuffer: GLuint);
    procedure glBindRenderbuffer(target: GLenum; renderbuffer: GLuint);
    procedure glDeleteFramebuffers(n: GLsizei; const framebuffers: PGLuint);
    procedure glDeleteRenderbuffers(n: GLsizei; const renderbuffers: PGLuint);
    procedure glFramebufferRenderbuffer(target: GLenum; attachment: GLenum; renderbuffertarget: GLenum; renderbuffer: GLuint);
    procedure glFramebufferTexture2D(target: GLenum; attachment: GLenum; textarget: GLenum; texture: GLuint; level: GLint);
    procedure glGenFramebuffers(n: GLsizei; framebuffers: PGLuint);
    procedure glGenRenderbuffers(n: GLsizei; renderbuffers: PGLuint);
    procedure glRenderbufferStorage(target: GLenum; internalformat: GLenum; Width: GLsizei; Height: GLsizei);
    procedure glGetFramebufferAttachmentParameteriv(target: GLenum; attachment: GLenum; pname: GLenum; params: PGLint);
    procedure glGetRenderbufferParameteriv(target: GLenum; pname: GLenum; params: PGLint);
    function glCheckFramebufferStatus(target: GLenum): GLenum;
    function glIsFramebuffer(framebuffer: GLuint): GLboolean;
    function glIsRenderbuffer(renderbuffer: GLuint): GLboolean;

    // ──────────────────────────────────────────────────────────────
    // Textures
    // ──────────────────────────────────────────────────────────────
    procedure glCompressedTexImage2D(target: GLenum; level: GLint; internalformat: GLenum; Width: GLsizei; Height: GLsizei; border: GLint; imageSize: GLsizei; const Data: Pointer);
    procedure glCompressedTexSubImage2D(target: GLenum; level: GLint; xoffset: GLint; yoffset: GLint; Width: GLsizei; Height: GLsizei; format: GLenum; imageSize: GLsizei; const Data: Pointer);
    procedure glCopyTexImage2D(target: GLenum; level: GLint; internalformat: GLenum; x: GLint; y: GLint; Width: GLsizei; Height: GLsizei; border: GLint);
    procedure glCopyTexSubImage2D(target: GLenum; level: GLint; xoffset: GLint; yoffset: GLint; x: GLint; y: GLint; Width: GLsizei; Height: GLsizei);
    procedure glGenerateMipmap(target: GLenum);
    procedure glTexImage2D(target: GLenum; level: GLint; internalformat: GLint; Width: GLsizei; Height: GLsizei; border: GLint; format: GLenum; type_: GLenum; const pixels: Pointer);
    procedure glTexSubImage2D(target: GLenum; level: GLint; xoffset: GLint; yoffset: GLint; Width: GLsizei; Height: GLsizei; format: GLenum; type_: GLenum; const pixels: Pointer);
    procedure glTexParameterf(target: GLenum; pname: GLenum; param: GLfloat);
    procedure glTexParameterfv(target: GLenum; pname: GLenum; const params: PGLfloat);
    procedure glTexParameteri(target: GLenum; pname: GLenum; param: GLint);
    procedure glTexParameteriv(target: GLenum; pname: GLenum; const params: PGLint);
    procedure glGetTexParameterfv(target: GLenum; pname: GLenum; params: PGLfloat);
    procedure glGetTexParameteriv(target: GLenum; pname: GLenum; params: PGLint);

    // ──────────────────────────────────────────────────────────────
    // Shaders & Programs
    // ──────────────────────────────────────────────────────────────
    procedure glAttachShader(program_: GLuint; shader: GLuint);
    procedure glBindAttribLocation(program_: GLuint; index: GLuint; const Name: PGLchar);
    procedure glCompileShader(shader: GLuint);
    function glCreateProgram: GLuint;
    function glCreateShader(type_: GLenum): GLuint;
    procedure glDeleteProgram(program_: GLuint);
    procedure glDeleteShader(shader: GLuint);
    procedure glDetachShader(program_: GLuint; shader: GLuint);
    procedure glGetActiveAttrib(program_: GLuint; index: GLuint; bufSize: GLsizei; length: PGLsizei; size: PGLint; type_: PGLenum; Name: PGLchar);
    procedure glGetActiveUniform(program_: GLuint; index: GLuint; bufSize: GLsizei; length: PGLsizei; size: PGLint; type_: PGLenum; Name: PGLchar);
    procedure glGetAttachedShaders(program_: GLuint; maxCount: GLsizei; Count: PGLsizei; shaders: PGLuint);
    function glGetAttribLocation(program_: GLuint; const Name: PGLchar): GLint;
    procedure glGetProgramiv(program_: GLuint; pname: GLenum; params: PGLint);
    procedure glGetProgramInfoLog(program_: GLuint; bufSize: GLsizei; length: PGLsizei; infoLog: PGLchar);
    procedure glGetShaderiv(shader: GLuint; pname: GLenum; params: PGLint);
    procedure glGetShaderInfoLog(shader: GLuint; bufSize: GLsizei; length: PGLsizei; infoLog: PGLchar);
    procedure glGetShaderSource(shader: GLuint; bufSize: GLsizei; length: PGLsizei; Source: PGLchar);
    function glGetUniformLocation(program_: GLuint; const Name: PGLchar): GLint;
    procedure glGetUniformfv(program_: GLuint; location: GLint; params: PGLfloat);
    procedure glGetUniformiv(program_: GLuint; location: GLint; params: PGLint);
    function glIsProgram(program_: GLuint): GLboolean;
    function glIsShader(shader: GLuint): GLboolean;
    procedure glLinkProgram(program_: GLuint);
    procedure glShaderSource(shader: GLuint; Count: GLsizei; const string_: PPGLchar; const length: PGLint);
    procedure glUseProgram(program_: GLuint);
    procedure glValidateProgram(program_: GLuint);

    // ──────────────────────────────────────────────────────────────
    // Vertex Attributes
    // ──────────────────────────────────────────────────────────────
    procedure glDisableVertexAttribArray(index: GLuint);
    procedure glEnableVertexAttribArray(index: GLuint);
    procedure glGetVertexAttribfv(index: GLuint; pname: GLenum; params: PGLfloat);
    procedure glGetVertexAttribiv(index: GLuint; pname: GLenum; params: PGLint);
    procedure glGetVertexAttribPointerv(index: GLuint; pname: GLenum; pointer: PPointer);
    procedure glVertexAttrib1f(index: GLuint; x: GLfloat);
    procedure glVertexAttrib1fv(index: GLuint; const v: PGLfloat);
    procedure glVertexAttrib2f(index: GLuint; x: GLfloat; y: GLfloat);
    procedure glVertexAttrib2fv(index: GLuint; const v: PGLfloat);
    procedure glVertexAttrib3f(index: GLuint; x: GLfloat; y: GLfloat; z: GLfloat);
    procedure glVertexAttrib3fv(index: GLuint; const v: PGLfloat);
    procedure glVertexAttrib4f(index: GLuint; x: GLfloat; y: GLfloat; z: GLfloat; w: GLfloat);
    procedure glVertexAttrib4fv(index: GLuint; const v: PGLfloat);
    procedure glVertexAttribPointer(index: GLuint; size: GLint; type_: GLenum; normalized: GLboolean; stride: GLsizei; const pointer: Pointer);

    // ──────────────────────────────────────────────────────────────
    // Uniforms
    // ──────────────────────────────────────────────────────────────
    procedure glUniform1f(location: GLint; v0: GLfloat);
    procedure glUniform1fv(location: GLint; Count: GLsizei; const Value: PGLfloat);
    procedure glUniform1i(location: GLint; v0: GLint);
    procedure glUniform1iv(location: GLint; Count: GLsizei; const Value: PGLint);
    procedure glUniform2f(location: GLint; v0: GLfloat; v1: GLfloat);
    procedure glUniform2fv(location: GLint; Count: GLsizei; const Value: PGLfloat);
    procedure glUniform2i(location: GLint; v0: GLint; v1: GLint);
    procedure glUniform2iv(location: GLint; Count: GLsizei; const Value: PGLint);
    procedure glUniform3f(location: GLint; v0: GLfloat; v1: GLfloat; v2: GLfloat);
    procedure glUniform3fv(location: GLint; Count: GLsizei; const Value: PGLfloat);
    procedure glUniform3i(location: GLint; v0: GLint; v1: GLint; v2: GLint);
    procedure glUniform3iv(location: GLint; Count: GLsizei; const Value: PGLint);
    procedure glUniform4f(location: GLint; v0: GLfloat; v1: GLfloat; v2: GLfloat; v3: GLfloat);
    procedure glUniform4fv(location: GLint; Count: GLsizei; const Value: PGLfloat);
    procedure glUniform4i(location: GLint; v0: GLint; v1: GLint; v2: GLint; v3: GLint);
    procedure glUniform4iv(location: GLint; Count: GLsizei; const Value: PGLint);
    procedure glUniformMatrix2fv(location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat);
    procedure glUniformMatrix3fv(location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat);
    procedure glUniformMatrix4fv(location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat);

    // ──────────────────────────────────────────────────────────────
    // Drawing Commands
    // ──────────────────────────────────────────────────────────────
    procedure glDrawArrays(mode: GLenum; First: GLint; Count: GLsizei);
    procedure glDrawElements(mode: GLenum; Count: GLsizei; type_: GLenum; const indices: Pointer);

    // ──────────────────────────────────────────────────────────────
    // Rasterization & Framebuffer Control
    // ──────────────────────────────────────────────────────────────
    procedure glClear(mask: GLbitfield);
    procedure glClearColor(red: GLfloat; green: GLfloat; blue: GLfloat; alpha: GLfloat);
    procedure glClearDepthf(depth: GLfloat);
    procedure glClearStencil(s: GLint);
    procedure glColorMask(red: GLboolean; green: GLboolean; blue: GLboolean; alpha: GLboolean);
    procedure glCullFace(mode: GLenum);
    procedure glDepthFunc(func: GLenum);
    procedure glDepthMask(flag: GLboolean);
    procedure glDepthRangef(n: GLfloat; f: GLfloat);
    procedure glFrontFace(mode: GLenum);
    procedure glLineWidth(Width: GLfloat);
    procedure glPolygonOffset(factor: GLfloat; units: GLfloat);
    procedure glScissor(x: GLint; y: GLint; Width: GLsizei; Height: GLsizei);
    procedure glStencilFunc(func: GLenum; ref: GLint; mask: GLuint);
    procedure glStencilFuncSeparate(face: GLenum; func: GLenum; ref: GLint; mask: GLuint);
    procedure glStencilMask(mask: GLuint);
    procedure glStencilMaskSeparate(face: GLenum; mask: GLuint);
    procedure glStencilOp(fail: GLenum; zfail: GLenum; zpass: GLenum);
    procedure glStencilOpSeparate(face: GLenum; fail: GLenum; zfail: GLenum; zpass: GLenum);
    procedure glViewport(x: GLint; y: GLint; Width: GLsizei; Height: GLsizei);

    // ──────────────────────────────────────────────────────────────
    // Blending
    // ──────────────────────────────────────────────────────────────
    procedure glBlendColor(red: GLfloat; green: GLfloat; blue: GLfloat; alpha: GLfloat);
    procedure glBlendEquation(mode: GLenum);
    procedure glBlendEquationSeparate(modeRGB: GLenum; modeAlpha: GLenum);
    procedure glBlendFunc(sfactor: GLenum; dfactor: GLenum);
    procedure glBlendFuncSeparate(srcRGB: GLenum; dstRGB: GLenum; srcAlpha: GLenum; dstAlpha: GLenum);

    // ──────────────────────────────────────────────────────────────
    // Query & Sync
    // ──────────────────────────────────────────────────────────────
    procedure glFinish;
    procedure glFlush;
    function glGetError: GLenum;

    // ──────────────────────────────────────────────────────────────
    // Hints & Pixel Store
    // ──────────────────────────────────────────────────────────────
    procedure glHint(target: GLenum; mode: GLenum);
    procedure glPixelStorei(pname: GLenum; param: GLint);

    // ──────────────────────────────────────────────────────────────
    // Reading Pixels
    // ──────────────────────────────────────────────────────────────
    procedure glReadPixels(x: GLint; y: GLint; Width: GLsizei; Height: GLsizei; format: GLenum; type_: GLenum; pixels: Pointer);

    // ──────────────────────────────────────────────────────────────
    // String & Version Queries
    // ──────────────────────────────────────────────────────────────
    function glGetString(Name: GLenum): PGLubyte;
    procedure glGetIntegerv(pname: GLenum; Data: PGLint);
    procedure glGetFloatv(pname: GLenum; Data: PGLfloat);
    procedure glGetBooleanv(pname: GLenum; Data: PGLboolean);

    // ──────────────────────────────────────────────────────────────
    // Shader Compiler (optional in ES 2.0)
    // ──────────────────────────────────────────────────────────────
    procedure glReleaseShaderCompiler;
    procedure glShaderBinary(Count: GLsizei; const shaders: PGLuint; binaryformat: GLenum; const binary: Pointer; length: GLint);
    procedure glGetShaderPrecisionFormat(shadertype: GLenum; precisiontype: GLenum; range: PGLint; precision: PGLint);
  end;

  IGLES_3_0 = interface(IGLES_2_0)
    ['{6ABF43A4-4331-48FD-AF16-89F440CD0D6A}']

    // ──────────────────────────────────────────────────────────────
    // Vertex Array Objects (VAO) - Core in ES 3.0
    // ──────────────────────────────────────────────────────────────
    procedure glBindVertexArray(array_: GLuint);
    procedure glDeleteVertexArrays(n: GLsizei; const arrays: PGLuint);
    procedure glGenVertexArrays(n: GLsizei; arrays: PGLuint);
    function glIsVertexArray(array_: GLuint): GLboolean;

    // ──────────────────────────────────────────────────────────────
    // Instanced Rendering
    // ──────────────────────────────────────────────────────────────
    procedure glDrawArraysInstanced(mode: GLenum; First: GLint; Count: GLsizei; instancecount: GLsizei);
    procedure glDrawElementsInstanced(mode: GLenum; Count: GLsizei; type_: GLenum; const indices: Pointer; instancecount: GLsizei);
    procedure glVertexAttribDivisor(index: GLuint; divisor: GLuint);

    // ──────────────────────────────────────────────────────────────
    // Immutable Texture Storage (TexStorage)
    // ──────────────────────────────────────────────────────────────
    procedure glTexStorage2D(target: GLenum; levels: GLsizei; internalformat: GLenum; Width: GLsizei; Height: GLsizei);
    procedure glTexStorage3D(target: GLenum; levels: GLsizei; internalformat: GLenum; Width: GLsizei; Height: GLsizei; depth: GLsizei);

    // ──────────────────────────────────────────────────────────────
    // Enhanced Buffer Mapping
    // ──────────────────────────────────────────────────────────────
    function glMapBufferRange(target: GLenum; offset: GLintptr; length: GLsizeiptr; access: GLbitfield): Pointer;
    procedure glFlushMappedBufferRange(target: GLenum; offset: GLintptr; length: GLsizeiptr);
    function glUnmapBuffer(target: GLenum): GLboolean;

    // ──────────────────────────────────────────────────────────────
    // Uniform Buffer Objects (UBO)
    // ──────────────────────────────────────────────────────────────
    procedure glBindBufferBase(target: GLenum; index: GLuint; buffer: GLuint);
    procedure glBindBufferRange(target: GLenum; index: GLuint; buffer: GLuint; offset: GLintptr; size: GLsizeiptr);
    function glGetUniformBlockIndex(program_: GLuint; const uniformBlockName: PGLchar): GLuint;
    procedure glGetActiveUniformBlockiv(program_: GLuint; uniformBlockIndex: GLuint; pname: GLenum; params: PGLint);
    procedure glGetActiveUniformBlockName(program_: GLuint; uniformBlockIndex: GLuint; bufSize: GLsizei; length: PGLsizei; uniformBlockName: PGLchar);
    procedure glUniformBlockBinding(program_: GLuint; uniformBlockIndex: GLuint; uniformBlockBinding: GLuint);
    procedure glGetUniformIndices(program_: GLuint; uniformCount: GLsizei; const uniformNames: PPGLchar; uniformIndices: PGLuint);
    procedure glGetActiveUniformsiv(program_: GLuint; uniformCount: GLsizei; const uniformIndices: PGLuint; pname: GLenum; params: PGLint);

    // ──────────────────────────────────────────────────────────────
    // Transform Feedback (solo buffer binding in ES 3.0, no Begin/End)
    // ──────────────────────────────────────────────────────────────
    procedure glBindTransformFeedback(target: GLenum; id: GLuint);
    procedure glDeleteTransformFeedbacks(n: GLsizei; const ids: PGLuint);
    procedure glGenTransformFeedbacks(n: GLsizei; ids: PGLuint);
    function glIsTransformFeedback(id: GLuint): GLboolean;
    procedure glPauseTransformFeedback;
    procedure glResumeTransformFeedback;

    // ──────────────────────────────────────────────────────────────
    // Sampler Objects
    // ──────────────────────────────────────────────────────────────
    procedure glGenSamplers(Count: GLsizei; samplers: PGLuint);
    procedure glDeleteSamplers(Count: GLsizei; const samplers: PGLuint);
    function glIsSampler(sampler: GLuint): GLboolean;
    procedure glBindSampler(unit_: GLuint; sampler: GLuint);
    procedure glSamplerParameteri(sampler: GLuint; pname: GLenum; param: GLint);
    procedure glSamplerParameteriv(sampler: GLuint; pname: GLenum; const param: PGLint);
    procedure glSamplerParameterf(sampler: GLuint; pname: GLenum; param: GLfloat);
    procedure glSamplerParameterfv(sampler: GLuint; pname: GLenum; const param: PGLfloat);
    procedure glSamplerParameterIiv(sampler: GLuint; pname: GLenum; const param: PGLint);
    procedure glSamplerParameterIuiv(sampler: GLuint; pname: GLenum; const param: PGLuint);
    procedure glGetSamplerParameteriv(sampler: GLuint; pname: GLenum; params: PGLint);
    procedure glGetSamplerParameterIiv(sampler: GLuint; pname: GLenum; params: PGLint);
    procedure glGetSamplerParameterfv(sampler: GLuint; pname: GLenum; params: PGLfloat);
    procedure glGetSamplerParameterIuiv(sampler: GLuint; pname: GLenum; params: PGLuint);

    // ──────────────────────────────────────────────────────────────
    // Sync Objects
    // ──────────────────────────────────────────────────────────────
    function glFenceSync(condition: GLenum; flags: GLbitfield): GLsync;
    function glIsSync(sync: GLsync): GLboolean;
    procedure glDeleteSync(sync: GLsync);
    function glClientWaitSync(sync: GLsync; flags: GLbitfield; timeout: GLuint64): GLenum;
    procedure glWaitSync(sync: GLsync; flags: GLbitfield; timeout: GLuint64);
    procedure glGetSynciv(sync: GLsync; pname: GLenum; bufSize: GLsizei; length: PGLsizei; values: PGLint);
    procedure glGetInteger64v(pname: GLenum; Data: PGLint64);
    procedure glGetInteger64i_v(pname: GLenum; index: GLuint; Data: PGLint64);

    // ──────────────────────────────────────────────────────────────
    // Enhanced Texture Formats & Queries
    // ──────────────────────────────────────────────────────────────
    procedure glTexImage3D(target: GLenum; level: GLint; internalformat: GLint; Width: GLsizei; Height: GLsizei; depth: GLsizei; border: GLint; format: GLenum; type_: GLenum; const pixels: Pointer);
    procedure glTexSubImage3D(target: GLenum; level: GLint; xoffset: GLint; yoffset: GLint; zoffset: GLint; Width: GLsizei; Height: GLsizei; depth: GLsizei; format: GLenum; type_: GLenum; const pixels: Pointer);
    procedure glCopyTexSubImage3D(target: GLenum; level: GLint; xoffset: GLint; yoffset: GLint; zoffset: GLint; x: GLint; y: GLint; Width: GLsizei; Height: GLsizei);
    procedure glCompressedTexImage3D(target: GLenum; level: GLint; internalformat: GLenum; Width: GLsizei; Height: GLsizei; depth: GLsizei; border: GLint; imageSize: GLsizei; const Data: Pointer);
    procedure glCompressedTexSubImage3D(target: GLenum; level: GLint; xoffset: GLint; yoffset: GLint; zoffset: GLint; Width: GLsizei; Height: GLsizei; depth: GLsizei; format: GLenum; imageSize: GLsizei; const Data: Pointer);

    // ──────────────────────────────────────────────────────────────
    // Multisample Renderbuffers
    // ──────────────────────────────────────────────────────────────
    procedure glRenderbufferStorageMultisample(target: GLenum; samples: GLsizei; internalformat: GLenum; Width: GLsizei; Height: GLsizei);
    procedure glFramebufferTextureLayer(target: GLenum; attachment: GLenum; texture: GLuint; level: GLint; layer: GLint);

    // ──────────────────────────────────────────────────────────────
    // Blit Framebuffer
    // ──────────────────────────────────────────────────────────────
    procedure glBlitFramebuffer(srcX0: GLint; srcY0: GLint; srcX1: GLint; srcY1: GLint; dstX0: GLint; dstY0: GLint; dstX1: GLint; dstY1: GLint; mask: GLbitfield; filter: GLenum);

    // ──────────────────────────────────────────────────────────────
    // Invalidate Framebuffer
    // ──────────────────────────────────────────────────────────────
    procedure glInvalidateFramebuffer(target: GLenum; numAttachments: GLsizei; const attachments: PGLenum);
    procedure glInvalidateSubFramebuffer(target: GLenum; numAttachments: GLsizei; const attachments: PGLenum; x: GLint; y: GLint; Width: GLsizei; Height: GLsizei);

    // ──────────────────────────────────────────────────────────────
    // Primitive Restart
    // ──────────────────────────────────────────────────────────────
    procedure glPrimitiveRestartIndex(index: GLuint);

    // ──────────────────────────────────────────────────────────────
    // Enhanced Queries
    // ──────────────────────────────────────────────────────────────
    procedure glBeginQuery(target: GLenum; id: GLuint);
    procedure glEndQuery(target: GLenum);
    procedure glGenQueries(n: GLsizei; ids: PGLuint);
    procedure glDeleteQueries(n: GLsizei; const ids: PGLuint);
    function glIsQuery(id: GLuint): GLboolean;
    procedure glGetQueryiv(target: GLenum; pname: GLenum; params: PGLint);
    procedure glGetQueryObjectuiv(id: GLuint; pname: GLenum; params: PGLuint);
    procedure glGetQueryObjectui64v(id: GLuint; pname: GLenum; params: PGLuint64);

    // ──────────────────────────────────────────────────────────────
    // Enhanced Clear
    // ──────────────────────────────────────────────────────────────
    procedure glClearBufferfv(buffer: GLenum; drawbuffer: GLint; const Value: PGLfloat);
    procedure glClearBufferiv(buffer: GLenum; drawbuffer: GLint; const Value: PGLint);
    procedure glClearBufferuiv(buffer: GLenum; drawbuffer: GLint; const Value: PGLuint);
    procedure glClearBufferfi(buffer: GLenum; drawbuffer: GLint; depth: GLfloat; stencil: GLint);

    // ──────────────────────────────────────────────────────────────
    // New Data Types & Queries
    // ──────────────────────────────────────────────────────────────
    procedure glGetBufferParameteri64v(target: GLenum; pname: GLenum; params: PGLint64);
    procedure glGetIntegeri_v(target: GLenum; index: GLuint; Data: PGLint);
    procedure glGetFloati_v(target: GLenum; index: GLuint; Data: PGLfloat);
    procedure glGetDoublei_v(target: GLenum; index: GLuint; Data: PGLdouble);

    // ──────────────────────────────────────────────────────────────
    // Copy Buffer SubData
    // ──────────────────────────────────────────────────────────────
    procedure glCopyBufferSubData(readTarget: GLenum; writeTarget: GLenum; readOffset: GLintptr; writeOffset: GLintptr; size: GLsizeiptr);

    // ──────────────────────────────────────────────────────────────
    // Debug (solo se KHR_debug è promossa a core - raro in ES 3.0)
    // ──────────────────────────────────────────────────────────────
    // (in ES 3.0 non è core, ma spesso presente come estensione)

  end;

  IGLES_3_1 = interface(IGLES_3_0)
    ['{C3D4E5F6-0718-293A-4B5C-6D7E8F9A0B1C}']

    // ──────────────────────────────────────────────────────────────
    // Compute Shaders
    // ──────────────────────────────────────────────────────────────
    procedure glDispatchCompute(num_groups_x: GLuint; num_groups_y: GLuint; num_groups_z: GLuint);
    procedure glDispatchComputeIndirect(indirect: GLintptr);

    // ──────────────────────────────────────────────────────────────
    // Shader Storage Buffer Objects (SSBO)
    // ──────────────────────────────────────────────────────────────
    procedure glShaderStorageBlockBinding(program_: GLuint; storageBlockIndex: GLuint; storageBlockBinding: GLuint);

    // ──────────────────────────────────────────────────────────────
    // Atomic Counter Buffers
    // ──────────────────────────────────────────────────────────────
    procedure glGetActiveAtomicCounterBufferiv(program_: GLuint; bufferIndex: GLuint; pname: GLenum; params: PGLint);

    // ──────────────────────────────────────────────────────────────
    // Image Load/Store
    // ──────────────────────────────────────────────────────────────
    procedure glBindImageTexture(unit_: GLuint; texture: GLuint; level: GLint; layered: GLboolean; layer: GLint; access: GLenum; format: GLenum);
    procedure glMemoryBarrier(barriers: GLbitfield); overload;

    // ──────────────────────────────────────────────────────────────
    // Program Interface Query (introspezione avanzata shader)
    // ──────────────────────────────────────────────────────────────
    function glGetProgramInterfaceiv(program_: GLuint; programInterface: GLenum; pname: GLenum; params: PGLint): GLenum;
    function glGetProgramResourceIndex(program_: GLuint; programInterface: GLenum; const Name: PGLchar): GLuint;
    function glGetProgramResourceLocation(program_: GLuint; programInterface: GLenum; const Name: PGLchar): GLint;
    function glGetProgramResourceLocationIndex(program_: GLuint; programInterface: GLenum; const Name: PGLchar): GLint;
    procedure glGetProgramResourceName(program_: GLuint; programInterface: GLenum; index: GLuint; bufSize: GLsizei; length: PGLsizei; Name: PGLchar);
    procedure glGetProgramResourceiv(program_: GLuint; programInterface: GLenum; index: GLuint; propCount: GLsizei; const props: PGLenum; bufSize: GLsizei; length: PGLsizei; params: PGLint);

    // ──────────────────────────────────────────────────────────────
    // Separate Shader Objects (programma senza linking)
    // ──────────────────────────────────────────────────────────────
    procedure glUseProgramStages(pipeline: GLuint; stages: GLbitfield; program_: GLuint);
    procedure glActiveShaderProgram(pipeline: GLuint; program_: GLuint);
    function glCreateShaderProgramv(shaderType: GLenum; Count: GLsizei; const strings: PPGLchar): GLuint;
    procedure glBindProgramPipeline(pipeline: GLuint);
    procedure glDeleteProgramPipelines(n: GLsizei; const pipelines: PGLuint);
    procedure glGenProgramPipelines(n: GLsizei; pipelines: PGLuint);
    function glIsProgramPipeline(pipeline: GLuint): GLboolean;
    procedure glGetProgramPipelineiv(pipeline: GLuint; pname: GLenum; params: PGLint);
    procedure glGetProgramPipelineInfoLog(pipeline: GLuint; bufSize: GLsizei; length: PGLsizei; infoLog: PGLchar);
    procedure glValidateProgramPipeline(pipeline: GLuint);
    procedure glProgramUniform1i(program_: GLuint; location: GLint; v0: GLint);
    procedure glProgramUniform1iv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLint);
    procedure glProgramUniform1f(program_: GLuint; location: GLint; v0: GLfloat);
    procedure glProgramUniform1fv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLfloat);
    procedure glProgramUniform1d(program_: GLuint; location: GLint; v0: GLdouble);
    procedure glProgramUniform1dv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLdouble);
    procedure glProgramUniform1ui(program_: GLuint; location: GLint; v0: GLuint);
    procedure glProgramUniform1uiv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLuint);
    procedure glProgramUniform2i(program_: GLuint; location: GLint; v0: GLint; v1: GLint);
    procedure glProgramUniform2iv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLint);
    procedure glProgramUniform2f(program_: GLuint; location: GLint; v0: GLfloat; v1: GLfloat);
    procedure glProgramUniform2fv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLfloat);
    procedure glProgramUniform2d(program_: GLuint; location: GLint; v0: GLdouble; v1: GLdouble);
    procedure glProgramUniform2dv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLdouble);
    procedure glProgramUniform2ui(program_: GLuint; location: GLint; v0: GLuint; v1: GLuint);
    procedure glProgramUniform2uiv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLuint);
    procedure glProgramUniform3i(program_: GLuint; location: GLint; v0: GLint; v1: GLint; v2: GLint);
    procedure glProgramUniform3iv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLint);
    procedure glProgramUniform3f(program_: GLuint; location: GLint; v0: GLfloat; v1: GLfloat; v2: GLfloat);
    procedure glProgramUniform3fv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLfloat);
    procedure glProgramUniform3d(program_: GLuint; location: GLint; v0: GLdouble; v1: GLdouble; v2: GLdouble);
    procedure glProgramUniform3dv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLdouble);
    procedure glProgramUniform3ui(program_: GLuint; location: GLint; v0: GLuint; v1: GLuint; v2: GLuint);
    procedure glProgramUniform3uiv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLuint);
    procedure glProgramUniform4i(program_: GLuint; location: GLint; v0: GLint; v1: GLint; v2: GLint; v3: GLint);
    procedure glProgramUniform4iv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLint);
    procedure glProgramUniform4f(program_: GLuint; location: GLint; v0: GLfloat; v1: GLfloat; v2: GLfloat; v3: GLfloat);
    procedure glProgramUniform4fv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLfloat);
    procedure glProgramUniform4d(program_: GLuint; location: GLint; v0: GLdouble; v1: GLdouble; v2: GLdouble; v3: GLdouble);
    procedure glProgramUniform4dv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLdouble);
    procedure glProgramUniform4ui(program_: GLuint; location: GLint; v0: GLuint; v1: GLuint; v2: GLuint; v3: GLuint);
    procedure glProgramUniform4uiv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLuint);
    procedure glProgramUniformMatrix2fv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat);
    procedure glProgramUniformMatrix3fv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat);
    procedure glProgramUniformMatrix4fv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat);
    procedure glProgramUniformMatrix2dv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLdouble);
    procedure glProgramUniformMatrix3dv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLdouble);
    procedure glProgramUniformMatrix4dv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLdouble);
    procedure glProgramUniformMatrix2x3fv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat);
    procedure glProgramUniformMatrix3x2fv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat);
    procedure glProgramUniformMatrix2x4fv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat);
    procedure glProgramUniformMatrix4x2fv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat);
    procedure glProgramUniformMatrix3x4fv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat);
    procedure glProgramUniformMatrix4x3fv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat);
    procedure glProgramUniformMatrix2x3dv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLdouble);
    procedure glProgramUniformMatrix3x2dv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLdouble);
    procedure glProgramUniformMatrix2x4dv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLdouble);
    procedure glProgramUniformMatrix4x2dv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLdouble);
    procedure glProgramUniformMatrix3x4dv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLdouble);
    procedure glProgramUniformMatrix4x3dv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLdouble);

    // ──────────────────────────────────────────────────────────────
    // Indirect Drawing
    // ──────────────────────────────────────────────────────────────
    procedure glDrawArraysIndirect(mode: GLenum; const indirect: Pointer);
    procedure glDrawElementsIndirect(mode: GLenum; type_: GLenum; const indirect: Pointer);

    // ──────────────────────────────────────────────────────────────
    // Multi-viewport & Scissor
    // ──────────────────────────────────────────────────────────────
    procedure glViewportArrayv(First: GLuint; Count: GLsizei; const v: PGLfloat);
    procedure glViewportIndexedf(index: GLuint; x: GLfloat; y: GLfloat; w: GLfloat; h: GLfloat);
    procedure glViewportIndexedfv(index: GLuint; const v: PGLfloat);
    procedure glScissorArrayv(First: GLuint; Count: GLsizei; const v: PGLint);
    procedure glScissorIndexed(index: GLuint; left: GLint; bottom: GLint; Width: GLsizei; Height: GLsizei);
    procedure glScissorIndexedv(index: GLuint; const v: PGLint);

    // ──────────────────────────────────────────────────────────────
    // Enhanced Depth/Stencil
    // ──────────────────────────────────────────────────────────────
    procedure glDepthRangeArrayv(First: GLuint; Count: GLsizei; const v: PGLclampd);
    procedure glDepthRangeIndexed(index: GLuint; n: GLclampd; f: GLclampd);

    // ──────────────────────────────────────────────────────────────
    // Memory Barrier (fine-grained)
    // ──────────────────────────────────────────────────────────────
    procedure glMemoryBarrierByRegion(barriers: GLbitfield);

    // ──────────────────────────────────────────────────────────────
    // Texture Views (non presente in ES 3.1, solo desktop 4.3+)
    // ──────────────────────────────────────────────────────────────

  end;

  IGLES_3_2 = interface(IGLES_3_1)
    ['{D4E5F607-1829-3A4B-5C6D-7E8F9A0B1C2D}']

    // ──────────────────────────────────────────────────────────────
    // Geometry Shaders (finalmente in ES!)
    // ──────────────────────────────────────────────────────────────
    procedure glPatchParameteri(pname: GLenum; Value: GLint);
    procedure glPatchParameterfv(pname: GLenum; const values: PGLfloat);

    // ──────────────────────────────────────────────────────────────
    // Tessellation Shaders
    // ──────────────────────────────────────────────────────────────
    // (le funzioni di controllo sono già in 3.2 core, gli shader sono opzionali ma supportati)

    // ──────────────────────────────────────────────────────────────
    // Multisample Textures & Immutable Storage Multisample
    // ──────────────────────────────────────────────────────────────
    procedure glTexStorage2DMultisample(target: GLenum; samples: GLsizei; internalformat: GLenum; Width: GLsizei; Height: GLsizei; fixedsamplelocations: GLboolean);

    procedure glTexStorage3DMultisample(target: GLenum; samples: GLsizei; internalformat: GLenum; Width: GLsizei; Height: GLsizei; depth: GLsizei; fixedsamplelocations: GLboolean);

    // ──────────────────────────────────────────────────────────────
    // Advanced Blending (per-colorbuffer blend equations & functions)
    // ──────────────────────────────────────────────────────────────
    procedure glBlendBarrier;

    procedure glBlendEquationi(buf: GLuint; mode: GLenum);
    procedure glBlendEquationSeparatei(buf: GLuint; modeRGB: GLenum; modeAlpha: GLenum);
    procedure glBlendFunci(buf: GLuint; src: GLenum; dst: GLenum);
    procedure glBlendFuncSeparatei(buf: GLuint; srcRGB: GLenum; dstRGB: GLenum; srcAlpha: GLenum; dstAlpha: GLenum);

    // ──────────────────────────────────────────────────────────────
    // Enhanced Memory Barriers
    // ──────────────────────────────────────────────────────────────
    //procedure glMemoryBarrier(barriers: GLbitfield);

    // ──────────────────────────────────────────────────────────────
    // Primitive Bounding Box (per geometry/tessellation clipping)
    // ──────────────────────────────────────────────────────────────
    procedure glPrimitiveBoundingBox(minX, minY, minZ, minW, maxX, maxY, maxZ, maxW: GLfloat);

    // ──────────────────────────────────────────────────────────────
    // Debug Output (KHR_debug promosso a core in ES 3.2)
    // ──────────────────────────────────────────────────────────────
    procedure glDebugMessageControl(Source: GLenum; type_: GLenum; severity: GLenum; Count: GLsizei; const ids: PGLuint; Enabled: GLboolean);
    procedure glDebugMessageInsert(Source: GLenum; type_: GLenum; id: GLuint; severity: GLenum; length: GLsizei; const buf: PGLchar);
    procedure glDebugMessageCallback(callback: GLDEBUGPROC; const userParam: Pointer);
    function glGetDebugMessageLog(Count: GLuint; bufSize: GLsizei; sources: PGLenum; types: PGLenum; ids: PGLuint; severities: PGLenum; lengths: PGLsizei; messageLog: PGLchar): GLuint;
    procedure glPushDebugGroup(Source: GLenum; id: GLuint; length: GLsizei; const message: PGLchar);
    procedure glPopDebugGroup;
    procedure glObjectLabel(identifier: GLenum; Name: GLuint; length: GLsizei; const aLabel: PGLchar);
    procedure glGetObjectLabel(identifier: GLenum; Name: GLuint; bufSize: GLsizei; length: PGLsizei; aLabel: PGLchar);
    procedure glObjectPtrLabel(const ptr: Pointer; length: GLsizei; const aLabel: PGLchar);
    procedure glGetObjectPtrLabel(const ptr: Pointer; bufSize: GLsizei; length: PGLsizei; aLabel: PGLchar);
    procedure glGetPointerv(pname: GLenum; params: PPointer);

    // ──────────────────────────────────────────────────────────────
    // Enhanced Image/Atomic Operations
    // ──────────────────────────────────────────────────────────────
    procedure glMinSampleShading(Value: GLfloat);
    procedure glGetMultisamplefv(pname: GLenum; index: GLuint; val: PGLfloat);
    procedure glSampleMaski(maskNumber: GLuint; mask: GLbitfield);

    // ──────────────────────────────────────────────────────────────
    // Texture Gather & Advanced Sampling
    // ──────────────────────────────────────────────────────────────
    procedure glTexBufferRange(target: GLenum; internalformat: GLenum; buffer: GLuint; offset: GLintptr; size: GLsizeiptr);
    procedure glTextureView(texture: GLuint; target: GLenum; origtexture: GLuint; internalformat: GLenum; minlevel: GLuint; numlevels: GLuint; minlayer: GLuint; numlayers: GLuint);

    // ──────────────────────────────────────────────────────────────
    // Query Enhancements
    // ──────────────────────────────────────────────────────────────
    procedure glGetQueryObjecti64v(id: GLuint; pname: GLenum; params: PGLint64);
    //procedure glGetQueryObjectui64v(id: GLuint; pname: GLenum; params: PGLuint64);

    // ──────────────────────────────────────────────────────────────
    // Framebuffer No-Attachment & Default Framebuffer Enhancements
    // ──────────────────────────────────────────────────────────────
    procedure glFramebufferParameteri(target: GLenum; pname: GLenum; param: GLint);
    procedure glGetFramebufferParameteriv(target: GLenum; pname: GLenum; params: PGLint);

    // ──────────────────────────────────────────────────────────────
    // Enhanced Clear & Invalidate
    // ──────────────────────────────────────────────────────────────
    procedure glClearTexImage(texture: GLuint; level: GLint; format: GLenum; type_: GLenum; const Data: Pointer);
    procedure glClearTexSubImage(texture: GLuint; level: GLint; xoffset: GLint; yoffset: GLint; zoffset: GLint; Width: GLsizei; Height: GLsizei; depth: GLsizei; format: GLenum; type_: GLenum; const Data: Pointer);

    // ──────────────────────────────────────────────────────────────
    // Robust Buffer Access & Graphics Reset
    // ──────────────────────────────────────────────────────────────
    function glGetGraphicsResetStatus: GLenum;
    procedure glReadnPixels(x: GLint; y: GLint; Width: GLsizei; Height: GLsizei; format: GLenum; type_: GLenum; bufSize: GLsizei; Data: Pointer);
    procedure glGetnUniformfv(program_: GLuint; location: GLint; bufSize: GLsizei; params: PGLfloat);
    procedure glGetnUniformiv(program_: GLuint; location: GLint; bufSize: GLsizei; params: PGLint);
    procedure glGetnUniformuiv(program_: GLuint; location: GLint; bufSize: GLsizei; params: PGLuint);

    // ──────────────────────────────────────────────────────────────
    // Compressed Texture Enhancements (ASTC, ETC2, etc. già supportati)
    // ──────────────────────────────────────────────────────────────
    // (nessuna nuova funzione, solo nuovi formati interni)

  end;

  IGLES = IGLES_3_2;

function GLES: IGLES;

implementation

uses
  dynlibs;

var
  singleton: IGLES = nil;

type

  { TGLESBase }

  TGLESBase = class(TInterfacedObject)
  protected
    FHandle: TLibHandle;
  private
    function LoadProc(Name: ansistring): {$ifdef cpui8086}FarPointer{$else}Pointer{$endif};
  protected
    procedure Bind(var FuncPtr: Pointer; const Name: ansistring; Mandatory: boolean = False);
  protected
    procedure bindEntry; virtual;
  public
    procedure LoadLibrary;
    procedure unLoadLibrary;
  public
    destructor Destroy; override;
  end;

  { TOpenGLES_20 }

  TOpenGLES_20 = class(TGLESBase, IGLES_2_0)
  private
    FGLESCheckFramebufferStatus: function(target: GLenum): GLenum; stdcall;
    FGLESActiveTexture: procedure(texture: GLenum); cdecl;
    FGLESAttachShader: procedure(program_: GLuint; shader: GLuint); cdecl;
    FGLESBindAttribLocation: procedure(program_: GLuint; index: GLuint; const Name: PGLchar); cdecl;
    FGLESBindBuffer: procedure(target: GLenum; buffer: GLuint); cdecl;
    FGLESBindFramebuffer: procedure(target: GLenum; framebuffer: GLuint); cdecl;
    FGLESBindRenderbuffer: procedure(target: GLenum; renderbuffer: GLuint); cdecl;
    FGLESBindTexture: procedure(target: GLenum; texture: GLuint); cdecl;
    FGLESBlendColor: procedure(red, green, blue, alpha: GLfloat); cdecl;
    FGLESBlendEquation: procedure(mode: GLenum); cdecl;
    FGLESBlendEquationSeparate: procedure(modeRGB, modeAlpha: GLenum); cdecl;
    FGLESBlendFunc: procedure(sfactor, dfactor: GLenum); cdecl;
    FGLESBlendFuncSeparate: procedure(srcRGB, dstRGB, srcAlpha, dstAlpha: GLenum); cdecl;
    FGLESBufferData: procedure(target: GLenum; size: GLsizeiptr; const Data: Pointer; usage: GLenum); cdecl;
    FGLESBufferSubData: procedure(target: GLenum; offset: GLintptr; size: GLsizeiptr; const Data: Pointer); cdecl;
    FGLESClear: procedure(mask: GLbitfield); cdecl;
    FGLESClearColor: procedure(red, green, blue, alpha: GLfloat); cdecl;
    FGLESClearDepthf: procedure(depth: GLfloat); cdecl;
    FGLESClearStencil: procedure(s: GLint); cdecl;
    FGLESColorMask: procedure(red, green, blue, alpha: GLboolean); cdecl;
    FGLESCompileShader: procedure(shader: GLuint); cdecl;
    FGLESCompressedTexImage2D: procedure(target: GLenum; level: GLint; internalformat: GLenum; Width, Height: GLsizei; border: GLint; imageSize: GLsizei; const Data: Pointer); cdecl;
    FGLESCompressedTexSubImage2D: procedure(target: GLenum; level: GLint; xoffset, yoffset: GLint; Width, Height: GLsizei; format: GLenum; imageSize: GLsizei; const Data: Pointer); cdecl;
    FGLESCopyTexImage2D: procedure(target: GLenum; level: GLint; internalformat: GLenum; x, y: GLint; Width, Height: GLsizei; border: GLint); cdecl;
    FGLESCopyTexSubImage2D: procedure(target: GLenum; level: GLint; xoffset, yoffset, x, y: GLint; Width, Height: GLsizei); cdecl;
    FGLESCreateProgram: function: GLuint; cdecl;
    FGLESCreateShader: function(type_: GLenum): GLuint; cdecl;
    FGLESCullFace: procedure(mode: GLenum); cdecl;
    FGLESDeleteBuffers: procedure(n: GLsizei; const buffers: PGLuint); cdecl;
    FGLESDeleteFramebuffers: procedure(n: GLsizei; const framebuffers: PGLuint); cdecl;
    FGLESDeleteProgram: procedure(program_: GLuint); cdecl;
    FGLESDeleteRenderbuffers: procedure(n: GLsizei; const renderbuffers: PGLuint); cdecl;
    FGLESDeleteShader: procedure(shader: GLuint); cdecl;
    FGLESDeleteTextures: procedure(n: GLsizei; const textures: PGLuint); cdecl;
    FGLESDepthFunc: procedure(func: GLenum); cdecl;
    FGLESDepthMask: procedure(flag: GLboolean); cdecl;
    FGLESDepthRangef: procedure(n, f: GLfloat); cdecl;
    FGLESDetachShader: procedure(program_: GLuint; shader: GLuint); cdecl;
    FGLESDisable: procedure(cap: GLenum); cdecl;
    FGLESDisableVertexAttribArray: procedure(index: GLuint); cdecl;
    FGLESDrawArrays: procedure(mode: GLenum; First: GLint; Count: GLsizei); cdecl;
    FGLESDrawElements: procedure(mode: GLenum; Count: GLsizei; type_: GLenum; const indices: Pointer); cdecl;
    FGLESEnable: procedure(cap: GLenum); cdecl;
    FGLESEnableVertexAttribArray: procedure(index: GLuint); cdecl;
    FGLESFinish: procedure; cdecl;
    FGLESFlush: procedure; cdecl;
    FGLESFramebufferRenderbuffer: procedure(target: GLenum; attachment: GLenum; renderbuffertarget: GLenum; renderbuffer: GLuint); cdecl;
    FGLESFramebufferTexture2D: procedure(target: GLenum; attachment: GLenum; textarget: GLenum; texture: GLuint; level: GLint); cdecl;
    FGLESFrontFace: procedure(mode: GLenum); cdecl;
    FGLESGenBuffers: procedure(n: GLsizei; buffers: PGLuint); cdecl;
    FGLESGenerateMipmap: procedure(target: GLenum); cdecl;
    FGLESGenFramebuffers: procedure(n: GLsizei; framebuffers: PGLuint); cdecl;
    FGLESGenRenderbuffers: procedure(n: GLsizei; renderbuffers: PGLuint); cdecl;
    FGLESGenTextures: procedure(n: GLsizei; textures: PGLuint); cdecl;
    FGLESGetActiveAttrib: procedure(program_: GLuint; index: GLuint; bufSize: GLsizei; length: PGLsizei; size: PGLint; type_: PGLenum; Name: PGLchar); cdecl;
    FGLESGetActiveUniform: procedure(program_: GLuint; index: GLuint; bufSize: GLsizei; length: PGLsizei; size: PGLint; type_: PGLenum; Name: PGLchar); cdecl;
    FGLESGetAttachedShaders: procedure(program_: GLuint; maxCount: GLsizei; Count: PGLsizei; shaders: PGLuint); cdecl;
    FGLESGetAttribLocation: function(program_: GLuint; const Name: PGLchar): GLint; cdecl;
    FGLESGetBooleanv: procedure(pname: GLenum; Data: PGLboolean); cdecl;
    FGLESGetBufferParameteriv: procedure(target: GLenum; pname: GLenum; params: PGLint); cdecl;
    FGLESGetError: function: GLenum; cdecl;
    FGLESGetFloatv: procedure(pname: GLenum; Data: PGLfloat); cdecl;
    FGLESGetFramebufferAttachmentParameteriv: procedure(target: GLenum; attachment: GLenum; pname: GLenum; params: PGLint); cdecl;
    FGLESGetIntegerv: procedure(pname: GLenum; Data: PGLint); cdecl;
    FGLESGetProgramiv: procedure(program_: GLuint; pname: GLenum; params: PGLint); cdecl;
    FGLESGetProgramInfoLog: procedure(program_: GLuint; bufSize: GLsizei; length: PGLsizei; infoLog: PGLchar); cdecl;
    FGLESGetRenderbufferParameteriv: procedure(target: GLenum; pname: GLenum; params: PGLint); cdecl;
    FGLESGetShaderiv: procedure(shader: GLuint; pname: GLenum; params: PGLint); cdecl;
    FGLESGetShaderInfoLog: procedure(shader: GLuint; bufSize: GLsizei; length: PGLsizei; infoLog: PGLchar); cdecl;
    FGLESGetShaderPrecisionFormat: procedure(shadertype: GLenum; precisiontype: GLenum; range: PGLint; precision: PGLint); cdecl;
    FGLESGetShaderSource: procedure(shader: GLuint; bufSize: GLsizei; length: PGLsizei; Source: PGLchar); cdecl;
    FGLESGetString: function(Name: GLenum): PGLubyte; cdecl;
    FGLESGetTexParameterfv: procedure(target: GLenum; pname: GLenum; params: PGLfloat); cdecl;
    FGLESGetTexParameteriv: procedure(target: GLenum; pname: GLenum; params: PGLint); cdecl;
    FGLESGetUniformfv: procedure(program_: GLuint; location: GLint; params: PGLfloat); cdecl;
    FGLESGetUniformiv: procedure(program_: GLuint; location: GLint; params: PGLint); cdecl;
    FGLESGetUniformLocation: function(program_: GLuint; const Name: PGLchar): GLint; cdecl;
    FGLESGetVertexAttribfv: procedure(index: GLuint; pname: GLenum; params: PGLfloat); cdecl;
    FGLESGetVertexAttribiv: procedure(index: GLuint; pname: GLenum; params: PGLint); cdecl;
    FGLESGetVertexAttribPointerv: procedure(index: GLuint; pname: GLenum; pointer: PPointer); cdecl;
    FGLESHint: procedure(target: GLenum; mode: GLenum); cdecl;
    FGLESIsBuffer: function(buffer: GLuint): GLboolean; cdecl;
    FGLESIsEnabled: function(cap: GLenum): GLboolean; cdecl;
    FGLESIsFramebuffer: function(framebuffer: GLuint): GLboolean; cdecl;
    FGLESIsProgram: function(program_: GLuint): GLboolean; cdecl;
    FGLESIsRenderbuffer: function(renderbuffer: GLuint): GLboolean; cdecl;
    FGLESIsShader: function(shader: GLuint): GLboolean; cdecl;
    FGLESIsTexture: function(texture: GLuint): GLboolean; cdecl;
    FGLESLineWidth: procedure(Width: GLfloat); cdecl;
    FGLESLinkProgram: procedure(program_: GLuint); cdecl;
    FGLESPixelStorei: procedure(pname: GLenum; param: GLint); cdecl;
    FGLESPolygonOffset: procedure(factor, units: GLfloat); cdecl;
    FGLESReadPixels: procedure(x, y: GLint; Width, Height: GLsizei; format, type_: GLenum; pixels: Pointer); cdecl;
    FGLESReleaseShaderCompiler: procedure; cdecl;
    FGLESRenderbufferStorage: procedure(target: GLenum; internalformat: GLenum; Width, Height: GLsizei); cdecl;
    FGLESSampleCoverage: procedure(Value: GLfloat; invert: GLboolean); cdecl;
    FGLESScissor: procedure(x, y: GLint; Width, Height: GLsizei); cdecl;
    FGLESShaderBinary: procedure(Count: GLsizei; const shaders: PGLuint; binaryformat: GLenum; const binary: Pointer; length: GLint); cdecl;
    FGLESShaderSource: procedure(shader: GLuint; Count: GLsizei; const string_: PPGLchar; const length: PGLint); cdecl;
    FGLESStencilFunc: procedure(func: GLenum; ref: GLint; mask: GLuint); cdecl;
    FGLESStencilFuncSeparate: procedure(face: GLenum; func: GLenum; ref: GLint; mask: GLuint); cdecl;
    FGLESStencilMask: procedure(mask: GLuint); cdecl;
    FGLESStencilMaskSeparate: procedure(face: GLenum; mask: GLuint); cdecl;
    FGLESStencilOp: procedure(fail, zfail, zpass: GLenum); cdecl;
    FGLESStencilOpSeparate: procedure(face: GLenum; fail, zfail, zpass: GLenum); cdecl;
    FGLESTexImage2D: procedure(target: GLenum; level: GLint; internalformat: GLint; Width, Height: GLsizei; border: GLint; format, type_: GLenum; const pixels: Pointer); cdecl;
    FGLESTexParameterf: procedure(target: GLenum; pname: GLenum; param: GLfloat); cdecl;
    FGLESTexParameterfv: procedure(target: GLenum; pname: GLenum; const params: PGLfloat); cdecl;
    FGLESTexParameteri: procedure(target: GLenum; pname: GLenum; param: GLint); cdecl;
    FGLESTexParameteriv: procedure(target: GLenum; pname: GLenum; const params: PGLint); cdecl;
    FGLESTexSubImage2D: procedure(target: GLenum; level: GLint; xoffset, yoffset: GLint; Width, Height: GLsizei; format, type_: GLenum; const pixels: Pointer); cdecl;
    FGLESUniform1f: procedure(location: GLint; v0: GLfloat); cdecl;
    FGLESUniform1fv: procedure(location: GLint; Count: GLsizei; const Value: PGLfloat); cdecl;
    FGLESUniform1i: procedure(location: GLint; v0: GLint); cdecl;
    FGLESUniform1iv: procedure(location: GLint; Count: GLsizei; const Value: PGLint); cdecl;
    FGLESUniform2f: procedure(location: GLint; v0, v1: GLfloat); cdecl;
    FGLESUniform2fv: procedure(location: GLint; Count: GLsizei; const Value: PGLfloat); cdecl;
    FGLESUniform2i: procedure(location: GLint; v0, v1: GLint); cdecl;
    FGLESUniform2iv: procedure(location: GLint; Count: GLsizei; const Value: PGLint); cdecl;
    FGLESUniform3f: procedure(location: GLint; v0, v1, v2: GLfloat); cdecl;
    FGLESUniform3fv: procedure(location: GLint; Count: GLsizei; const Value: PGLfloat); cdecl;
    FGLESUniform3i: procedure(location: GLint; v0, v1, v2: GLint); cdecl;
    FGLESUniform3iv: procedure(location: GLint; Count: GLsizei; const Value: PGLint); cdecl;
    FGLESUniform4f: procedure(location: GLint; v0, v1, v2, v3: GLfloat); cdecl;
    FGLESUniform4fv: procedure(location: GLint; Count: GLsizei; const Value: PGLfloat); cdecl;
    FGLESUniform4i: procedure(location: GLint; v0, v1, v2, v3: GLint); cdecl;
    FGLESUniform4iv: procedure(location: GLint; Count: GLsizei; const Value: PGLint); cdecl;
    FGLESUniformMatrix2fv: procedure(location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat); cdecl;
    FGLESUniformMatrix3fv: procedure(location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat); cdecl;
    FGLESUniformMatrix4fv: procedure(location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat); cdecl;
    FGLESUseProgram: procedure(program_: GLuint); cdecl;
    FGLESValidateProgram: procedure(program_: GLuint); cdecl;
    FGLESVertexAttrib1f: procedure(index: GLuint; x: GLfloat); cdecl;
    FGLESVertexAttrib1fv: procedure(index: GLuint; const v: PGLfloat); cdecl;
    FGLESVertexAttrib2f: procedure(index: GLuint; x, y: GLfloat); cdecl;
    FGLESVertexAttrib2fv: procedure(index: GLuint; const v: PGLfloat); cdecl;
    FGLESVertexAttrib3f: procedure(index: GLuint; x, y, z: GLfloat); cdecl;
    FGLESVertexAttrib3fv: procedure(index: GLuint; const v: PGLfloat); cdecl;
    FGLESVertexAttrib4f: procedure(index: GLuint; x, y, z, w: GLfloat); cdecl;
    FGLESVertexAttrib4fv: procedure(index: GLuint; const v: PGLfloat); cdecl;
    FGLESVertexAttribPointer: procedure(index: GLuint; size: GLint; type_: GLenum; normalized: GLboolean; stride: GLsizei; const pointer: Pointer); cdecl;
    FGLESViewport: procedure(x, y: GLint; Width, Height: GLsizei); cdecl;
  public
    procedure bindEntry; override;

    // ──────────────────────────────────────────────────────────────
    // Core State Management
    // ──────────────────────────────────────────────────────────────
    procedure glActiveTexture(texture: GLenum);
    procedure glBindTexture(target: GLenum; texture: GLuint);
    procedure glDisable(cap: GLenum);
    procedure glEnable(cap: GLenum);
    function glIsEnabled(cap: GLenum): GLboolean;

    // ──────────────────────────────────────────────────────────────
    // Buffer Objects
    // ──────────────────────────────────────────────────────────────
    procedure glBindBuffer(target: GLenum; buffer: GLuint);
    procedure glBufferData(target: GLenum; size: GLsizeiptr; const Data: Pointer; usage: GLenum);
    procedure glBufferSubData(target: GLenum; offset: GLintptr; size: GLsizeiptr; const Data: Pointer);
    procedure glDeleteBuffers(n: GLsizei; const buffers: PGLuint);
    procedure glGenBuffers(n: GLsizei; buffers: PGLuint);
    function glIsBuffer(buffer: GLuint): GLboolean;
    procedure glGetBufferParameteriv(target: GLenum; pname: GLenum; params: PGLint);

    // ──────────────────────────────────────────────────────────────
    // Framebuffer Objects (via extension OES_framebuffer_object in ES 2.0)
    // ──────────────────────────────────────────────────────────────
    procedure glBindFramebuffer(target: GLenum; framebuffer: GLuint);
    procedure glBindRenderbuffer(target: GLenum; renderbuffer: GLuint);
    procedure glDeleteFramebuffers(n: GLsizei; const framebuffers: PGLuint);
    procedure glDeleteRenderbuffers(n: GLsizei; const renderbuffers: PGLuint);
    procedure glFramebufferRenderbuffer(target: GLenum; attachment: GLenum; renderbuffertarget: GLenum; renderbuffer: GLuint);
    procedure glFramebufferTexture2D(target: GLenum; attachment: GLenum; textarget: GLenum; texture: GLuint; level: GLint);
    procedure glGenFramebuffers(n: GLsizei; framebuffers: PGLuint);
    procedure glGenRenderbuffers(n: GLsizei; renderbuffers: PGLuint);
    procedure glRenderbufferStorage(target: GLenum; internalformat: GLenum; Width: GLsizei; Height: GLsizei);
    procedure glGetFramebufferAttachmentParameteriv(target: GLenum; attachment: GLenum; pname: GLenum; params: PGLint);
    procedure glGetRenderbufferParameteriv(target: GLenum; pname: GLenum; params: PGLint);
    function glIsTexture(texture: GLuint): GLboolean;
    function glIsFramebuffer(framebuffer: GLuint): GLboolean;
    function glIsRenderbuffer(renderbuffer: GLuint): GLboolean;

    // ──────────────────────────────────────────────────────────────
    // Textures
    // ──────────────────────────────────────────────────────────────
    procedure glCompressedTexImage2D(target: GLenum; level: GLint; internalformat: GLenum; Width: GLsizei; Height: GLsizei; border: GLint; imageSize: GLsizei; const Data: Pointer);
    procedure glCompressedTexSubImage2D(target: GLenum; level: GLint; xoffset: GLint; yoffset: GLint; Width: GLsizei; Height: GLsizei; format: GLenum; imageSize: GLsizei; const Data: Pointer);
    procedure glCopyTexImage2D(target: GLenum; level: GLint; internalformat: GLenum; x: GLint; y: GLint; Width: GLsizei; Height: GLsizei; border: GLint);
    procedure glCopyTexSubImage2D(target: GLenum; level: GLint; xoffset: GLint; yoffset: GLint; x: GLint; y: GLint; Width: GLsizei; Height: GLsizei);
    procedure glGenerateMipmap(target: GLenum);
    procedure glTexImage2D(target: GLenum; level: GLint; internalformat: GLint; Width: GLsizei; Height: GLsizei; border: GLint; format: GLenum; type_: GLenum; const pixels: Pointer);
    procedure glTexSubImage2D(target: GLenum; level: GLint; xoffset: GLint; yoffset: GLint; Width: GLsizei; Height: GLsizei; format: GLenum; type_: GLenum; const pixels: Pointer);
    procedure glTexParameterf(target: GLenum; pname: GLenum; param: GLfloat);
    procedure glTexParameterfv(target: GLenum; pname: GLenum; const params: PGLfloat);
    procedure glTexParameteri(target: GLenum; pname: GLenum; param: GLint);
    procedure glTexParameteriv(target: GLenum; pname: GLenum; const params: PGLint);
    procedure glGetTexParameterfv(target: GLenum; pname: GLenum; params: PGLfloat);
    procedure glGetTexParameteriv(target: GLenum; pname: GLenum; params: PGLint);

    // ──────────────────────────────────────────────────────────────
    // Shaders & Programs
    // ──────────────────────────────────────────────────────────────
    procedure glAttachShader(program_: GLuint; shader: GLuint);
    procedure glBindAttribLocation(program_: GLuint; index: GLuint; const Name: PGLchar);
    procedure glCompileShader(shader: GLuint);
    function glCreateProgram: GLuint;
    function glCreateShader(type_: GLenum): GLuint;
    procedure glDeleteProgram(program_: GLuint);
    procedure glDeleteShader(shader: GLuint);
    procedure glDetachShader(program_: GLuint; shader: GLuint);
    procedure glGetActiveAttrib(program_: GLuint; index: GLuint; bufSize: GLsizei; length: PGLsizei; size: PGLint; type_: PGLenum; Name: PGLchar);
    procedure glGetActiveUniform(program_: GLuint; index: GLuint; bufSize: GLsizei; length: PGLsizei; size: PGLint; type_: PGLenum; Name: PGLchar);
    procedure glGetAttachedShaders(program_: GLuint; maxCount: GLsizei; Count: PGLsizei; shaders: PGLuint);
    function glGetAttribLocation(program_: GLuint; const Name: PGLchar): GLint;
    procedure glGetProgramiv(program_: GLuint; pname: GLenum; params: PGLint);
    procedure glGetProgramInfoLog(program_: GLuint; bufSize: GLsizei; length: PGLsizei; infoLog: PGLchar);
    procedure glGetShaderiv(shader: GLuint; pname: GLenum; params: PGLint);
    procedure glGetShaderInfoLog(shader: GLuint; bufSize: GLsizei; length: PGLsizei; infoLog: PGLchar);
    procedure glGetShaderSource(shader: GLuint; bufSize: GLsizei; length: PGLsizei; Source: PGLchar);
    function glGetUniformLocation(program_: GLuint; const Name: PGLchar): GLint;
    procedure glGetUniformfv(program_: GLuint; location: GLint; params: PGLfloat);
    procedure glGetUniformiv(program_: GLuint; location: GLint; params: PGLint);
    function glIsProgram(program_: GLuint): GLboolean;
    function glIsShader(shader: GLuint): GLboolean;
    procedure glLinkProgram(program_: GLuint);
    procedure glShaderSource(shader: GLuint; Count: GLsizei; const string_: PPGLchar; const length: PGLint);
    procedure glUseProgram(program_: GLuint);
    procedure glValidateProgram(program_: GLuint);

    // ──────────────────────────────────────────────────────────────
    // Vertex Attributes
    // ──────────────────────────────────────────────────────────────
    procedure glDisableVertexAttribArray(index: GLuint);
    procedure glEnableVertexAttribArray(index: GLuint);
    procedure glGetVertexAttribfv(index: GLuint; pname: GLenum; params: PGLfloat);
    procedure glGetVertexAttribiv(index: GLuint; pname: GLenum; params: PGLint);
    procedure glGetVertexAttribPointerv(index: GLuint; pname: GLenum; pointer: PPointer);
    procedure glVertexAttrib1f(index: GLuint; x: GLfloat);
    procedure glVertexAttrib1fv(index: GLuint; const v: PGLfloat);
    procedure glVertexAttrib2f(index: GLuint; x: GLfloat; y: GLfloat);
    procedure glVertexAttrib2fv(index: GLuint; const v: PGLfloat);
    procedure glVertexAttrib3f(index: GLuint; x: GLfloat; y: GLfloat; z: GLfloat);
    procedure glVertexAttrib3fv(index: GLuint; const v: PGLfloat);
    procedure glVertexAttrib4f(index: GLuint; x: GLfloat; y: GLfloat; z: GLfloat; w: GLfloat);
    procedure glVertexAttrib4fv(index: GLuint; const v: PGLfloat);
    procedure glVertexAttribPointer(index: GLuint; size: GLint; type_: GLenum; normalized: GLboolean; stride: GLsizei; const pointer: Pointer);

    // ──────────────────────────────────────────────────────────────
    // Uniforms
    // ──────────────────────────────────────────────────────────────
    procedure glUniform1f(location: GLint; v0: GLfloat);
    procedure glUniform1fv(location: GLint; Count: GLsizei; const Value: PGLfloat);
    procedure glUniform1i(location: GLint; v0: GLint);
    procedure glUniform1iv(location: GLint; Count: GLsizei; const Value: PGLint);
    procedure glUniform2f(location: GLint; v0: GLfloat; v1: GLfloat);
    procedure glUniform2fv(location: GLint; Count: GLsizei; const Value: PGLfloat);
    procedure glUniform2i(location: GLint; v0: GLint; v1: GLint);
    procedure glUniform2iv(location: GLint; Count: GLsizei; const Value: PGLint);
    procedure glUniform3f(location: GLint; v0: GLfloat; v1: GLfloat; v2: GLfloat);
    procedure glUniform3fv(location: GLint; Count: GLsizei; const Value: PGLfloat);
    procedure glUniform3i(location: GLint; v0: GLint; v1: GLint; v2: GLint);
    procedure glUniform3iv(location: GLint; Count: GLsizei; const Value: PGLint);
    procedure glUniform4f(location: GLint; v0: GLfloat; v1: GLfloat; v2: GLfloat; v3: GLfloat);
    procedure glUniform4fv(location: GLint; Count: GLsizei; const Value: PGLfloat);
    procedure glUniform4i(location: GLint; v0: GLint; v1: GLint; v2: GLint; v3: GLint);
    procedure glUniform4iv(location: GLint; Count: GLsizei; const Value: PGLint);
    procedure glUniformMatrix2fv(location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat);
    procedure glUniformMatrix3fv(location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat);
    procedure glUniformMatrix4fv(location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat);

    // ──────────────────────────────────────────────────────────────
    // Drawing Commands
    // ──────────────────────────────────────────────────────────────
    procedure glDrawArrays(mode: GLenum; First: GLint; Count: GLsizei);
    procedure glDrawElements(mode: GLenum; Count: GLsizei; type_: GLenum; const indices: Pointer);

    // ──────────────────────────────────────────────────────────────
    // Rasterization & Framebuffer Control
    // ──────────────────────────────────────────────────────────────
    procedure glClear(mask: GLbitfield);
    procedure glClearColor(red: GLfloat; green: GLfloat; blue: GLfloat; alpha: GLfloat);
    procedure glClearDepthf(depth: GLfloat);
    procedure glClearStencil(s: GLint);
    procedure glColorMask(red: GLboolean; green: GLboolean; blue: GLboolean; alpha: GLboolean);
    procedure glCullFace(mode: GLenum);
    procedure glDepthFunc(func: GLenum);
    procedure glDepthMask(flag: GLboolean);
    procedure glDepthRangef(n: GLfloat; f: GLfloat);
    procedure glFrontFace(mode: GLenum);
    procedure glLineWidth(Width: GLfloat);
    procedure glPolygonOffset(factor: GLfloat; units: GLfloat);
    procedure glScissor(x: GLint; y: GLint; Width: GLsizei; Height: GLsizei);
    procedure glStencilFunc(func: GLenum; ref: GLint; mask: GLuint);
    procedure glStencilFuncSeparate(face: GLenum; func: GLenum; ref: GLint; mask: GLuint);
    procedure glStencilMask(mask: GLuint);
    procedure glStencilMaskSeparate(face: GLenum; mask: GLuint);
    procedure glStencilOp(fail: GLenum; zfail: GLenum; zpass: GLenum);
    procedure glStencilOpSeparate(face: GLenum; fail: GLenum; zfail: GLenum; zpass: GLenum);
    procedure glViewport(x: GLint; y: GLint; Width: GLsizei; Height: GLsizei);

    // ──────────────────────────────────────────────────────────────
    // Blending
    // ──────────────────────────────────────────────────────────────
    procedure glBlendColor(red: GLfloat; green: GLfloat; blue: GLfloat; alpha: GLfloat);
    procedure glBlendEquation(mode: GLenum);
    procedure glBlendEquationSeparate(modeRGB: GLenum; modeAlpha: GLenum);
    procedure glBlendFunc(sfactor: GLenum; dfactor: GLenum);
    procedure glBlendFuncSeparate(srcRGB: GLenum; dstRGB: GLenum; srcAlpha: GLenum; dstAlpha: GLenum);

    // ──────────────────────────────────────────────────────────────
    // Query & Sync
    // ──────────────────────────────────────────────────────────────
    procedure glFinish;
    procedure glFlush;
    function glGetError: GLenum;

    // ──────────────────────────────────────────────────────────────
    // Hints & Pixel Store
    // ──────────────────────────────────────────────────────────────
    procedure glHint(target: GLenum; mode: GLenum);
    procedure glPixelStorei(pname: GLenum; param: GLint);

    // ──────────────────────────────────────────────────────────────
    // Reading Pixels
    // ──────────────────────────────────────────────────────────────
    procedure glReadPixels(x: GLint; y: GLint; Width: GLsizei; Height: GLsizei; format: GLenum; type_: GLenum; pixels: Pointer);

    // ──────────────────────────────────────────────────────────────
    // String & Version Queries
    // ──────────────────────────────────────────────────────────────
    function glGetString(Name: GLenum): PGLubyte;
    procedure glGetIntegerv(pname: GLenum; Data: PGLint);
    procedure glGetFloatv(pname: GLenum; Data: PGLfloat);
    procedure glGetBooleanv(pname: GLenum; Data: PGLboolean);

    // ──────────────────────────────────────────────────────────────
    // Shader Compiler (optional in ES 2.0)
    // ──────────────────────────────────────────────────────────────
    procedure glReleaseShaderCompiler;
    procedure glShaderBinary(Count: GLsizei; const shaders: PGLuint; binaryformat: GLenum; const binary: Pointer; length: GLint);
    procedure glGetShaderPrecisionFormat(shadertype: GLenum; precisiontype: GLenum; range: PGLint; precision: PGLint);
    procedure glDeleteTextures(n: GLsizei; const textures: PGLuint);
    procedure glSampleCoverage(Value: GLfloat; invert: GLboolean);
    procedure glGenTextures(n: GLsizei; textures: PGLuint);

    function glCheckFramebufferStatus(target: GLenum): GLenum;
  end;

  { TOpenGLES_3_0 }

  TOpenGLES_3_0 = class(TOpenGLES_20, IGLES_3_0)
  protected
    // Vertex Array Objects (VAO)
    FGLESBindVertexArray: procedure(array_: GLuint); stdcall;
    FGLESDeleteVertexArrays: procedure(n: GLsizei; const arrays: PGLuint); stdcall;
    FGLESGenVertexArrays: procedure(n: GLsizei; arrays: PGLuint); stdcall;
    FGLESIsVertexArray: function(array_: GLuint): GLboolean; stdcall;

    // Instanced Rendering
    FGLESDrawArraysInstanced: procedure(mode: GLenum; First: GLint; Count: GLsizei; instancecount: GLsizei); stdcall;
    FGLESDrawElementsInstanced: procedure(mode: GLenum; Count: GLsizei; type_: GLenum; const indices: Pointer; instancecount: GLsizei); stdcall;
    FGLESVertexAttribDivisor: procedure(index: GLuint; divisor: GLuint); stdcall;

    // Immutable Texture Storage
    FGLESTexStorage2D: procedure(target: GLenum; levels: GLsizei; internalformat: GLenum; Width: GLsizei; Height: GLsizei); stdcall;
    FGLESTexStorage3D: procedure(target: GLenum; levels: GLsizei; internalformat: GLenum; Width: GLsizei; Height: GLsizei; depth: GLsizei); stdcall;

    // Enhanced Buffer Mapping
    FGLESMapBufferRange: function(target: GLenum; offset: GLintptr; length: GLsizeiptr; access: GLbitfield): Pointer; stdcall;
    FGLESFlushMappedBufferRange: procedure(target: GLenum; offset: GLintptr; length: GLsizeiptr); stdcall;
    FGLESUnmapBuffer: function(target: GLenum): GLboolean; stdcall;

    // Uniform Buffer Objects (UBO)
    FGLESBindBufferBase: procedure(target: GLenum; index: GLuint; buffer: GLuint); stdcall;
    FGLESBindBufferRange: procedure(target: GLenum; index: GLuint; buffer: GLuint; offset: GLintptr; size: GLsizeiptr); stdcall;
    FGLESGetUniformBlockIndex: function(program_: GLuint; const uniformBlockName: PGLchar): GLuint; stdcall;
    FGLESGetActiveUniformBlockiv: procedure(program_: GLuint; uniformBlockIndex: GLuint; pname: GLenum; params: PGLint); stdcall;
    FGLESGetActiveUniformBlockName: procedure(program_: GLuint; uniformBlockIndex: GLuint; bufSize: GLsizei; length: PGLsizei; uniformBlockName: PGLchar); stdcall;
    FGLESUniformBlockBinding: procedure(program_: GLuint; uniformBlockIndex: GLuint; uniformBlockBinding: GLuint); stdcall;
    FGLESGetUniformIndices: procedure(program_: GLuint; uniformCount: GLsizei; const uniformNames: PPGLchar; uniformIndices: PGLuint); stdcall;
    FGLESGetActiveUniformsiv: procedure(program_: GLuint; uniformCount: GLsizei; const uniformIndices: PGLuint; pname: GLenum; params: PGLint); stdcall;

    // Transform Feedback (buffer binding only)
    FGLESBindTransformFeedback: procedure(target: GLenum; id: GLuint); stdcall;
    FGLESDeleteTransformFeedbacks: procedure(n: GLsizei; const ids: PGLuint); stdcall;
    FGLESGenTransformFeedbacks: procedure(n: GLsizei; ids: PGLuint); stdcall;
    FGLESIsTransformFeedback: function(id: GLuint): GLboolean; stdcall;
    FGLESPauseTransformFeedback: procedure; stdcall;
    FGLESResumeTransformFeedback: procedure; stdcall;

    // Sampler Objects
    FGLESGenSamplers: procedure(Count: GLsizei; samplers: PGLuint); stdcall;
    FGLESDeleteSamplers: procedure(Count: GLsizei; const samplers: PGLuint); stdcall;
    FGLESIsSampler: function(sampler: GLuint): GLboolean; stdcall;
    FGLESBindSampler: procedure(unit_: GLuint; sampler: GLuint); stdcall;
    FGLESSamplerParameteri: procedure(sampler: GLuint; pname: GLenum; param: GLint); stdcall;
    FGLESSamplerParameteriv: procedure(sampler: GLuint; pname: GLenum; const param: PGLint); stdcall;
    FGLESSamplerParameterf: procedure(sampler: GLuint; pname: GLenum; param: GLfloat); stdcall;
    FGLESSamplerParameterfv: procedure(sampler: GLuint; pname: GLenum; const param: PGLfloat); stdcall;
    FGLESSamplerParameterIiv: procedure(sampler: GLuint; pname: GLenum; const param: PGLint); stdcall;
    FGLESSamplerParameterIuiv: procedure(sampler: GLuint; pname: GLenum; const param: PGLuint); stdcall;
    FGLESGetSamplerParameteriv: procedure(sampler: GLuint; pname: GLenum; params: PGLint); stdcall;
    FGLESGetSamplerParameterIiv: procedure(sampler: GLuint; pname: GLenum; params: PGLint); stdcall;
    FGLESGetSamplerParameterfv: procedure(sampler: GLuint; pname: GLenum; params: PGLfloat); stdcall;
    FGLESGetSamplerParameterIuiv: procedure(sampler: GLuint; pname: GLenum; params: PGLuint); stdcall;

    // Sync Objects
    FGLESFenceSync: function(condition: GLenum; flags: GLbitfield): GLsync; stdcall;
    FGLESIsSync: function(sync: GLsync): GLboolean; stdcall;
    FGLESDeleteSync: procedure(sync: GLsync); stdcall;
    FGLESClientWaitSync: function(sync: GLsync; flags: GLbitfield; timeout: GLuint64): GLenum; stdcall;
    FGLESWaitSync: procedure(sync: GLsync; flags: GLbitfield; timeout: GLuint64); stdcall;
    FGLESGetSynciv: procedure(sync: GLsync; pname: GLenum; bufSize: GLsizei; length: PGLsizei; values: PGLint); stdcall;
    FGLESGetInteger64v: procedure(pname: GLenum; Data: PGLint64); stdcall;
    FGLESGetInteger64i_v: procedure(pname: GLenum; index: GLuint; Data: PGLint64); stdcall;

    // Texture 3D & Enhanced Formats
    FGLESTexImage3D: procedure(target: GLenum; level: GLint; internalformat: GLint; Width, Height, depth: GLsizei; border: GLint; format, type_: GLenum; const pixels: Pointer); stdcall;
    FGLESTexSubImage3D: procedure(target: GLenum; level: GLint; xoffset, yoffset, zoffset: GLint; Width, Height, depth: GLsizei; format, type_: GLenum; const pixels: Pointer); stdcall;
    FGLESCopyTexSubImage3D: procedure(target: GLenum; level: GLint; xoffset, yoffset, zoffset: GLint; x, y: GLint; Width, Height: GLsizei); stdcall;
    FGLESCompressedTexImage3D: procedure(target: GLenum; level: GLint; internalformat: GLenum; Width, Height, depth: GLsizei; border: GLint; imageSize: GLsizei; const Data: Pointer); stdcall;
    FGLESCompressedTexSubImage3D: procedure(target: GLenum; level: GLint; xoffset, yoffset, zoffset: GLint; Width, Height, depth: GLsizei; format: GLenum; imageSize: GLsizei; const Data: Pointer); stdcall;

    // Multisample Renderbuffers & Layered FBO
    FGLESRenderbufferStorageMultisample: procedure(target: GLenum; samples: GLsizei; internalformat: GLenum; Width, Height: GLsizei); stdcall;
    FGLESFramebufferTextureLayer: procedure(target: GLenum; attachment: GLenum; texture: GLuint; level: GLint; layer: GLint); stdcall;

    // Blit Framebuffer
    FGLESBlitFramebuffer: procedure(srcX0, srcY0, srcX1, srcY1, dstX0, dstY0, dstX1, dstY1: GLint; mask: GLbitfield; filter: GLenum); stdcall;

    // Invalidate Framebuffer
    FGLESInvalidateFramebuffer: procedure(target: GLenum; numAttachments: GLsizei; const attachments: PGLenum); stdcall;
    FGLESInvalidateSubFramebuffer: procedure(target: GLenum; numAttachments: GLsizei; const attachments: PGLenum; x, y: GLint; Width, Height: GLsizei); stdcall;

    // Primitive Restart
    FGLESPrimitiveRestartIndex: procedure(index: GLuint); stdcall;

    // Enhanced Queries
    FGLESBeginQuery: procedure(target: GLenum; id: GLuint); stdcall;
    FGLESEndQuery: procedure(target: GLenum); stdcall;
    FGLESGenQueries: procedure(n: GLsizei; ids: PGLuint); stdcall;
    FGLESDeleteQueries: procedure(n: GLsizei; const ids: PGLuint); stdcall;
    FGLESIsQuery: function(id: GLuint): GLboolean; stdcall;
    FGLESGetQueryiv: procedure(target: GLenum; pname: GLenum; params: PGLint); stdcall;
    FGLESGetQueryObjectuiv: procedure(id: GLuint; pname: GLenum; params: PGLuint); stdcall;
    FGLESGetQueryObjectui64v: procedure(id: GLuint; pname: GLenum; params: PGLuint64); stdcall;

    // Enhanced Clear
    FGLESClearBufferfv: procedure(buffer: GLenum; drawbuffer: GLint; const Value: PGLfloat); stdcall;
    FGLESClearBufferiv: procedure(buffer: GLenum; drawbuffer: GLint; const Value: PGLint); stdcall;
    FGLESClearBufferuiv: procedure(buffer: GLenum; drawbuffer: GLint; const Value: PGLuint); stdcall;
    FGLESClearBufferfi: procedure(buffer: GLenum; drawbuffer: GLint; depth: GLfloat; stencil: GLint); stdcall;

    // New Data Type Queries
    FGLESGetBufferParameteri64v: procedure(target: GLenum; pname: GLenum; params: PGLint64); stdcall;
    FGLESGetIntegeri_v: procedure(target: GLenum; index: GLuint; Data: PGLint); stdcall;
    FGLESGetFloati_v: procedure(target: GLenum; index: GLuint; Data: PGLfloat); stdcall;
    FGLESGetDoublei_v: procedure(target: GLenum; index: GLuint; Data: PGLdouble); stdcall;

    // Copy Buffer SubData
    FGLESCopyBufferSubData: procedure(readTarget, writeTarget: GLenum; readOffset, writeOffset: GLintptr; size: GLsizeiptr); stdcall;
  public
    procedure bindEntry; override;
  public
    // ──────────────────────────────────────────────────────────────
    // Vertex Array Objects (VAO) - Core in ES 3.0
    // ──────────────────────────────────────────────────────────────
    procedure glBindVertexArray(array_: GLuint);
    procedure glDeleteVertexArrays(n: GLsizei; const arrays: PGLuint);
    procedure glGenVertexArrays(n: GLsizei; arrays: PGLuint);
    function glIsVertexArray(array_: GLuint): GLboolean;

    // ──────────────────────────────────────────────────────────────
    // Instanced Rendering
    // ──────────────────────────────────────────────────────────────
    procedure glDrawArraysInstanced(mode: GLenum; First: GLint; Count: GLsizei; instancecount: GLsizei);
    procedure glDrawElementsInstanced(mode: GLenum; Count: GLsizei; type_: GLenum; const indices: Pointer; instancecount: GLsizei);
    procedure glVertexAttribDivisor(index: GLuint; divisor: GLuint);

    // ──────────────────────────────────────────────────────────────
    // Immutable Texture Storage (TexStorage)
    // ──────────────────────────────────────────────────────────────
    procedure glTexStorage2D(target: GLenum; levels: GLsizei; internalformat: GLenum; Width: GLsizei; Height: GLsizei);
    procedure glTexStorage3D(target: GLenum; levels: GLsizei; internalformat: GLenum; Width: GLsizei; Height: GLsizei; depth: GLsizei);

    // ──────────────────────────────────────────────────────────────
    // Enhanced Buffer Mapping
    // ──────────────────────────────────────────────────────────────
    function glMapBufferRange(target: GLenum; offset: GLintptr; length: GLsizeiptr; access: GLbitfield): Pointer;
    procedure glFlushMappedBufferRange(target: GLenum; offset: GLintptr; length: GLsizeiptr);
    function glUnmapBuffer(target: GLenum): GLboolean;

    // ──────────────────────────────────────────────────────────────
    // Uniform Buffer Objects (UBO)
    // ──────────────────────────────────────────────────────────────
    procedure glBindBufferBase(target: GLenum; index: GLuint; buffer: GLuint);
    procedure glBindBufferRange(target: GLenum; index: GLuint; buffer: GLuint; offset: GLintptr; size: GLsizeiptr);
    function glGetUniformBlockIndex(program_: GLuint; const uniformBlockName: PGLchar): GLuint;
    procedure glGetActiveUniformBlockiv(program_: GLuint; uniformBlockIndex: GLuint; pname: GLenum; params: PGLint);
    procedure glGetActiveUniformBlockName(program_: GLuint; uniformBlockIndex: GLuint; bufSize: GLsizei; length: PGLsizei; uniformBlockName: PGLchar);
    procedure glUniformBlockBinding(program_: GLuint; uniformBlockIndex: GLuint; uniformBlockBinding: GLuint);
    procedure glGetUniformIndices(program_: GLuint; uniformCount: GLsizei; const uniformNames: PPGLchar; uniformIndices: PGLuint);
    procedure glGetActiveUniformsiv(program_: GLuint; uniformCount: GLsizei; const uniformIndices: PGLuint; pname: GLenum; params: PGLint);

    // ──────────────────────────────────────────────────────────────
    // Transform Feedback (solo buffer binding in ES 3.0, no Begin/End)
    // ──────────────────────────────────────────────────────────────
    procedure glBindTransformFeedback(target: GLenum; id: GLuint);
    procedure glDeleteTransformFeedbacks(n: GLsizei; const ids: PGLuint);
    procedure glGenTransformFeedbacks(n: GLsizei; ids: PGLuint);
    function glIsTransformFeedback(id: GLuint): GLboolean;
    procedure glPauseTransformFeedback;
    procedure glResumeTransformFeedback;

    // ──────────────────────────────────────────────────────────────
    // Sampler Objects
    // ──────────────────────────────────────────────────────────────
    procedure glGenSamplers(Count: GLsizei; samplers: PGLuint);
    procedure glDeleteSamplers(Count: GLsizei; const samplers: PGLuint);
    function glIsSampler(sampler: GLuint): GLboolean;
    procedure glBindSampler(unit_: GLuint; sampler: GLuint);
    procedure glSamplerParameteri(sampler: GLuint; pname: GLenum; param: GLint);
    procedure glSamplerParameteriv(sampler: GLuint; pname: GLenum; const param: PGLint);
    procedure glSamplerParameterf(sampler: GLuint; pname: GLenum; param: GLfloat);
    procedure glSamplerParameterfv(sampler: GLuint; pname: GLenum; const param: PGLfloat);
    procedure glSamplerParameterIiv(sampler: GLuint; pname: GLenum; const param: PGLint);
    procedure glSamplerParameterIuiv(sampler: GLuint; pname: GLenum; const param: PGLuint);
    procedure glGetSamplerParameteriv(sampler: GLuint; pname: GLenum; params: PGLint);
    procedure glGetSamplerParameterIiv(sampler: GLuint; pname: GLenum; params: PGLint);
    procedure glGetSamplerParameterfv(sampler: GLuint; pname: GLenum; params: PGLfloat);
    procedure glGetSamplerParameterIuiv(sampler: GLuint; pname: GLenum; params: PGLuint);

    // ──────────────────────────────────────────────────────────────
    // Sync Objects
    // ──────────────────────────────────────────────────────────────
    function glFenceSync(condition: GLenum; flags: GLbitfield): GLsync;
    function glIsSync(sync: GLsync): GLboolean;
    procedure glDeleteSync(sync: GLsync);
    function glClientWaitSync(sync: GLsync; flags: GLbitfield; timeout: GLuint64): GLenum;
    procedure glWaitSync(sync: GLsync; flags: GLbitfield; timeout: GLuint64);
    procedure glGetSynciv(sync: GLsync; pname: GLenum; bufSize: GLsizei; length: PGLsizei; values: PGLint);
    procedure glGetInteger64v(pname: GLenum; Data: PGLint64);
    procedure glGetInteger64i_v(pname: GLenum; index: GLuint; Data: PGLint64);

    // ──────────────────────────────────────────────────────────────
    // Enhanced Texture Formats & Queries
    // ──────────────────────────────────────────────────────────────
    procedure glTexImage3D(target: GLenum; level: GLint; internalformat: GLint; Width: GLsizei; Height: GLsizei; depth: GLsizei; border: GLint; format: GLenum; type_: GLenum; const pixels: Pointer);
    procedure glTexSubImage3D(target: GLenum; level: GLint; xoffset: GLint; yoffset: GLint; zoffset: GLint; Width: GLsizei; Height: GLsizei; depth: GLsizei; format: GLenum; type_: GLenum; const pixels: Pointer);
    procedure glCopyTexSubImage3D(target: GLenum; level: GLint; xoffset: GLint; yoffset: GLint; zoffset: GLint; x: GLint; y: GLint; Width: GLsizei; Height: GLsizei);
    procedure glCompressedTexImage3D(target: GLenum; level: GLint; internalformat: GLenum; Width: GLsizei; Height: GLsizei; depth: GLsizei; border: GLint; imageSize: GLsizei; const Data: Pointer);
    procedure glCompressedTexSubImage3D(target: GLenum; level: GLint; xoffset: GLint; yoffset: GLint; zoffset: GLint; Width: GLsizei; Height: GLsizei; depth: GLsizei; format: GLenum; imageSize: GLsizei; const Data: Pointer);

    // ──────────────────────────────────────────────────────────────
    // Multisample Renderbuffers
    // ──────────────────────────────────────────────────────────────
    procedure glRenderbufferStorageMultisample(target: GLenum; samples: GLsizei; internalformat: GLenum; Width: GLsizei; Height: GLsizei);
    procedure glFramebufferTextureLayer(target: GLenum; attachment: GLenum; texture: GLuint; level: GLint; layer: GLint);

    // ──────────────────────────────────────────────────────────────
    // Blit Framebuffer
    // ──────────────────────────────────────────────────────────────
    procedure glBlitFramebuffer(srcX0: GLint; srcY0: GLint; srcX1: GLint; srcY1: GLint; dstX0: GLint; dstY0: GLint; dstX1: GLint; dstY1: GLint; mask: GLbitfield; filter: GLenum);

    // ──────────────────────────────────────────────────────────────
    // Invalidate Framebuffer
    // ──────────────────────────────────────────────────────────────
    procedure glInvalidateFramebuffer(target: GLenum; numAttachments: GLsizei; const attachments: PGLenum);
    procedure glInvalidateSubFramebuffer(target: GLenum; numAttachments: GLsizei; const attachments: PGLenum; x: GLint; y: GLint; Width: GLsizei; Height: GLsizei);

    // ──────────────────────────────────────────────────────────────
    // Primitive Restart
    // ──────────────────────────────────────────────────────────────
    procedure glPrimitiveRestartIndex(index: GLuint);

    // ──────────────────────────────────────────────────────────────
    // Enhanced Queries
    // ──────────────────────────────────────────────────────────────
    procedure glBeginQuery(target: GLenum; id: GLuint);
    procedure glEndQuery(target: GLenum);
    procedure glGenQueries(n: GLsizei; ids: PGLuint);
    procedure glDeleteQueries(n: GLsizei; const ids: PGLuint);
    function glIsQuery(id: GLuint): GLboolean;
    procedure glGetQueryiv(target: GLenum; pname: GLenum; params: PGLint);
    procedure glGetQueryObjectuiv(id: GLuint; pname: GLenum; params: PGLuint);
    procedure glGetQueryObjectui64v(id: GLuint; pname: GLenum; params: PGLuint64);

    // ──────────────────────────────────────────────────────────────
    // Enhanced Clear
    // ──────────────────────────────────────────────────────────────
    procedure glClearBufferfv(buffer: GLenum; drawbuffer: GLint; const Value: PGLfloat);
    procedure glClearBufferiv(buffer: GLenum; drawbuffer: GLint; const Value: PGLint);
    procedure glClearBufferuiv(buffer: GLenum; drawbuffer: GLint; const Value: PGLuint);
    procedure glClearBufferfi(buffer: GLenum; drawbuffer: GLint; depth: GLfloat; stencil: GLint);

    // ──────────────────────────────────────────────────────────────
    // New Data Types & Queries
    // ──────────────────────────────────────────────────────────────
    procedure glGetBufferParameteri64v(target: GLenum; pname: GLenum; params: PGLint64);
    procedure glGetIntegeri_v(target: GLenum; index: GLuint; Data: PGLint);
    procedure glGetFloati_v(target: GLenum; index: GLuint; Data: PGLfloat);
    procedure glGetDoublei_v(target: GLenum; index: GLuint; Data: PGLdouble);

    // ──────────────────────────────────────────────────────────────
    // Copy Buffer SubData
    // ──────────────────────────────────────────────────────────────
    procedure glCopyBufferSubData(readTarget: GLenum; writeTarget: GLenum; readOffset: GLintptr; writeOffset: GLintptr; size: GLsizeiptr);
  end;

  { TOpenGLES_3_1 }

  TOpenGLES_3_1 = class(TOpenGLES_3_0, IGLES_3_1)
  protected

    // Compute Shaders
    FGLESDispatchCompute: procedure(num_groups_x, num_groups_y, num_groups_z: GLuint); stdcall;
    FGLESDispatchComputeIndirect: procedure(indirect: GLintptr); stdcall;

    // Shader Storage Buffer Objects (SSBO)
    FGLESShaderStorageBlockBinding: procedure(program_: GLuint; storageBlockIndex: GLuint; storageBlockBinding: GLuint); stdcall;

    // Atomic Counter Buffers
    FGLESGetActiveAtomicCounterBufferiv: procedure(program_: GLuint; bufferIndex: GLuint; pname: GLenum; params: PGLint); stdcall;

    // Image Load/Store
    FGLESBindImageTexture: procedure(unit_: GLuint; texture: GLuint; level: GLint; layered: GLboolean; layer: GLint; access: GLenum; format: GLenum); stdcall;
    FGLESMemoryBarrier: procedure(barriers: GLbitfield); stdcall;

    // Program Interface Query
    FGLESGetProgramInterfaceiv: function(program_: GLuint; programInterface: GLenum; pname: GLenum; params: PGLint): GLenum; stdcall;
    FGLESGetProgramResourceIndex: function(program_: GLuint; programInterface: GLenum; const Name: PGLchar): GLuint; stdcall;
    FGLESGetProgramResourceLocation: function(program_: GLuint; programInterface: GLenum; const Name: PGLchar): GLint; stdcall;
    FGLESGetProgramResourceLocationIndex: function(program_: GLuint; programInterface: GLenum; const Name: PGLchar): GLint; stdcall;
    FGLESGetProgramResourceName: procedure(program_: GLuint; programInterface: GLenum; index: GLuint; bufSize: GLsizei; length: PGLsizei; Name: PGLchar); stdcall;
    FGLESGetProgramResourceiv: procedure(program_: GLuint; programInterface: GLenum; index: GLuint; propCount: GLsizei; const props: PGLenum; bufSize: GLsizei; length: PGLsizei; params: PGLint); stdcall;

    // Separate Shader Objects / Program Pipelines
    FGLESUseProgramStages: procedure(pipeline: GLuint; stages: GLbitfield; program_: GLuint); stdcall;
    FGLESActiveShaderProgram: procedure(pipeline: GLuint; program_: GLuint); stdcall;
    FGLESCreateShaderProgramv: function(shaderType: GLenum; Count: GLsizei; const strings: PPGLchar): GLuint; stdcall;
    FGLESBindProgramPipeline: procedure(pipeline: GLuint); stdcall;
    FGLESDeleteProgramPipelines: procedure(n: GLsizei; const pipelines: PGLuint); stdcall;
    FGLESGenProgramPipelines: procedure(n: GLsizei; pipelines: PGLuint); stdcall;
    FGLESIsProgramPipeline: function(pipeline: GLuint): GLboolean; stdcall;
    FGLESGetProgramPipelineiv: procedure(pipeline: GLuint; pname: GLenum; params: PGLint); stdcall;
    FGLESGetProgramPipelineInfoLog: procedure(pipeline: GLuint; bufSize: GLsizei; length: PGLsizei; infoLog: PGLchar); stdcall;
    FGLESValidateProgramPipeline: procedure(pipeline: GLuint); stdcall;

    // ProgramUniform* (per separate shader objects)
    FGLESProgramUniform1i: procedure(program_: GLuint; location: GLint; v0: GLint); stdcall;
    FGLESProgramUniform1iv: procedure(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLint); stdcall;
    FGLESProgramUniform1f: procedure(program_: GLuint; location: GLint; v0: GLfloat); stdcall;
    FGLESProgramUniform1fv: procedure(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLfloat); stdcall;
    FGLESProgramUniform1d: procedure(program_: GLuint; location: GLint; v0: GLdouble); stdcall;
    FGLESProgramUniform1dv: procedure(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLdouble); stdcall;
    FGLESProgramUniform1ui: procedure(program_: GLuint; location: GLint; v0: GLuint); stdcall;
    FGLESProgramUniform1uiv: procedure(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLuint); stdcall;
    FGLESProgramUniform2i: procedure(program_: GLuint; location: GLint; v0, v1: GLint); stdcall;
    FGLESProgramUniform2iv: procedure(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLint); stdcall;
    FGLESProgramUniform2f: procedure(program_: GLuint; location: GLint; v0, v1: GLfloat); stdcall;
    FGLESProgramUniform2fv: procedure(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLfloat); stdcall;
    FGLESProgramUniform2d: procedure(program_: GLuint; location: GLint; v0, v1: GLdouble); stdcall;
    FGLESProgramUniform2dv: procedure(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLdouble); stdcall;
    FGLESProgramUniform2ui: procedure(program_: GLuint; location: GLint; v0, v1: GLuint); stdcall;
    FGLESProgramUniform2uiv: procedure(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLuint); stdcall;
    FGLESProgramUniform3i: procedure(program_: GLuint; location: GLint; v0, v1, v2: GLint); stdcall;
    FGLESProgramUniform3iv: procedure(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLint); stdcall;
    FGLESProgramUniform3f: procedure(program_: GLuint; location: GLint; v0, v1, v2: GLfloat); stdcall;
    FGLESProgramUniform3fv: procedure(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLfloat); stdcall;
    FGLESProgramUniform3d: procedure(program_: GLuint; location: GLint; v0, v1, v2: GLdouble); stdcall;
    FGLESProgramUniform3dv: procedure(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLdouble); stdcall;
    FGLESProgramUniform3ui: procedure(program_: GLuint; location: GLint; v0, v1, v2: GLuint); stdcall;
    FGLESProgramUniform3uiv: procedure(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLuint); stdcall;
    FGLESProgramUniform4i: procedure(program_: GLuint; location: GLint; v0, v1, v2, v3: GLint); stdcall;
    FGLESProgramUniform4iv: procedure(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLint); stdcall;
    FGLESProgramUniform4f: procedure(program_: GLuint; location: GLint; v0, v1, v2, v3: GLfloat); stdcall;
    FGLESProgramUniform4fv: procedure(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLfloat); stdcall;
    FGLESProgramUniform4d: procedure(program_: GLuint; location: GLint; v0, v1, v2, v3: GLdouble); stdcall;
    FGLESProgramUniform4dv: procedure(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLdouble); stdcall;
    FGLESProgramUniform4ui: procedure(program_: GLuint; location: GLint; v0, v1, v2, v3: GLuint); stdcall;
    FGLESProgramUniform4uiv: procedure(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLuint); stdcall;
    FGLESProgramUniformMatrix2fv: procedure(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat); stdcall;
    FGLESProgramUniformMatrix3fv: procedure(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat); stdcall;
    FGLESProgramUniformMatrix4fv: procedure(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat); stdcall;
    FGLESProgramUniformMatrix2dv: procedure(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLdouble); stdcall;
    FGLESProgramUniformMatrix3dv: procedure(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLdouble); stdcall;
    FGLESProgramUniformMatrix4dv: procedure(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLdouble); stdcall;
    FGLESProgramUniformMatrix2x3fv: procedure(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat); stdcall;
    FGLESProgramUniformMatrix3x2fv: procedure(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat); stdcall;
    FGLESProgramUniformMatrix2x4fv: procedure(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat); stdcall;
    FGLESProgramUniformMatrix4x2fv: procedure(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat); stdcall;
    FGLESProgramUniformMatrix3x4fv: procedure(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat); stdcall;
    FGLESProgramUniformMatrix4x3fv: procedure(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat); stdcall;
    FGLESProgramUniformMatrix2x3dv: procedure(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLdouble); stdcall;
    FGLESProgramUniformMatrix3x2dv: procedure(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLdouble); stdcall;
    FGLESProgramUniformMatrix2x4dv: procedure(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLdouble); stdcall;
    FGLESProgramUniformMatrix4x2dv: procedure(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLdouble); stdcall;
    FGLESProgramUniformMatrix3x4dv: procedure(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLdouble); stdcall;
    FGLESProgramUniformMatrix4x3dv: procedure(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLdouble); stdcall;

    // Indirect Drawing
    FGLESDrawArraysIndirect: procedure(mode: GLenum; const indirect: Pointer); stdcall;
    FGLESDrawElementsIndirect: procedure(mode: GLenum; type_: GLenum; const indirect: Pointer); stdcall;

    // Multi-viewport & Scissor
    FGLESViewportArrayv: procedure(First: GLuint; Count: GLsizei; const v: PGLfloat); stdcall;
    FGLESViewportIndexedf: procedure(index: GLuint; x, y, w, h: GLfloat); stdcall;
    FGLESViewportIndexedfv: procedure(index: GLuint; const v: PGLfloat); stdcall;
    FGLESScissorArrayv: procedure(First: GLuint; Count: GLsizei; const v: PGLint); stdcall;
    FGLESScissorIndexed: procedure(index: GLuint; left, bottom: GLint; Width, Height: GLsizei); stdcall;
    FGLESScissorIndexedv: procedure(index: GLuint; const v: PGLint); stdcall;

    // Enhanced Depth Range
    FGLESDepthRangeArrayv: procedure(First: GLuint; Count: GLsizei; const v: PGLclampd); stdcall;
    FGLESDepthRangeIndexed: procedure(index: GLuint; n, f: GLclampd); stdcall;

    // Fine-grained Memory Barriers
    FGLESMemoryBarrierByRegion: procedure(barriers: GLbitfield); stdcall;
  public
    procedure bindEntry; override;

    // ──────────────────────────────────────────────────────────────
    // Compute Shaders
    // ──────────────────────────────────────────────────────────────
    procedure glDispatchCompute(num_groups_x: GLuint; num_groups_y: GLuint; num_groups_z: GLuint);
    procedure glDispatchComputeIndirect(indirect: GLintptr);

    // ──────────────────────────────────────────────────────────────
    // Shader Storage Buffer Objects (SSBO)
    // ──────────────────────────────────────────────────────────────
    procedure glShaderStorageBlockBinding(program_: GLuint; storageBlockIndex: GLuint; storageBlockBinding: GLuint);

    // ──────────────────────────────────────────────────────────────
    // Atomic Counter Buffers
    // ──────────────────────────────────────────────────────────────
    procedure glGetActiveAtomicCounterBufferiv(program_: GLuint; bufferIndex: GLuint; pname: GLenum; params: PGLint);

    // ──────────────────────────────────────────────────────────────
    // Image Load/Store
    // ──────────────────────────────────────────────────────────────
    procedure glBindImageTexture(unit_: GLuint; texture: GLuint; level: GLint; layered: GLboolean; layer: GLint; access: GLenum; format: GLenum);
    procedure glMemoryBarrier(barriers: GLbitfield); overload;

    // ──────────────────────────────────────────────────────────────
    // Program Interface Query (introspezione avanzata shader)
    // ──────────────────────────────────────────────────────────────
    function glGetProgramInterfaceiv(program_: GLuint; programInterface: GLenum; pname: GLenum; params: PGLint): GLenum;
    function glGetProgramResourceIndex(program_: GLuint; programInterface: GLenum; const Name: PGLchar): GLuint;
    function glGetProgramResourceLocation(program_: GLuint; programInterface: GLenum; const Name: PGLchar): GLint;
    function glGetProgramResourceLocationIndex(program_: GLuint; programInterface: GLenum; const Name: PGLchar): GLint;
    procedure glGetProgramResourceName(program_: GLuint; programInterface: GLenum; index: GLuint; bufSize: GLsizei; length: PGLsizei; Name: PGLchar);
    procedure glGetProgramResourceiv(program_: GLuint; programInterface: GLenum; index: GLuint; propCount: GLsizei; const props: PGLenum; bufSize: GLsizei; length: PGLsizei; params: PGLint);

    // ──────────────────────────────────────────────────────────────
    // Separate Shader Objects (programma senza linking)
    // ──────────────────────────────────────────────────────────────
    procedure glUseProgramStages(pipeline: GLuint; stages: GLbitfield; program_: GLuint);
    procedure glActiveShaderProgram(pipeline: GLuint; program_: GLuint);
    function glCreateShaderProgramv(shaderType: GLenum; Count: GLsizei; const strings: PPGLchar): GLuint;
    procedure glBindProgramPipeline(pipeline: GLuint);
    procedure glDeleteProgramPipelines(n: GLsizei; const pipelines: PGLuint);
    procedure glGenProgramPipelines(n: GLsizei; pipelines: PGLuint);
    function glIsProgramPipeline(pipeline: GLuint): GLboolean;
    procedure glGetProgramPipelineiv(pipeline: GLuint; pname: GLenum; params: PGLint);
    procedure glGetProgramPipelineInfoLog(pipeline: GLuint; bufSize: GLsizei; length: PGLsizei; infoLog: PGLchar);
    procedure glValidateProgramPipeline(pipeline: GLuint);
    procedure glProgramUniform1i(program_: GLuint; location: GLint; v0: GLint);
    procedure glProgramUniform1iv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLint);
    procedure glProgramUniform1f(program_: GLuint; location: GLint; v0: GLfloat);
    procedure glProgramUniform1fv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLfloat);
    procedure glProgramUniform1d(program_: GLuint; location: GLint; v0: GLdouble);
    procedure glProgramUniform1dv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLdouble);
    procedure glProgramUniform1ui(program_: GLuint; location: GLint; v0: GLuint);
    procedure glProgramUniform1uiv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLuint);
    procedure glProgramUniform2i(program_: GLuint; location: GLint; v0: GLint; v1: GLint);
    procedure glProgramUniform2iv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLint);
    procedure glProgramUniform2f(program_: GLuint; location: GLint; v0: GLfloat; v1: GLfloat);
    procedure glProgramUniform2fv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLfloat);
    procedure glProgramUniform2d(program_: GLuint; location: GLint; v0: GLdouble; v1: GLdouble);
    procedure glProgramUniform2dv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLdouble);
    procedure glProgramUniform2ui(program_: GLuint; location: GLint; v0: GLuint; v1: GLuint);
    procedure glProgramUniform2uiv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLuint);
    procedure glProgramUniform3i(program_: GLuint; location: GLint; v0: GLint; v1: GLint; v2: GLint);
    procedure glProgramUniform3iv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLint);
    procedure glProgramUniform3f(program_: GLuint; location: GLint; v0: GLfloat; v1: GLfloat; v2: GLfloat);
    procedure glProgramUniform3fv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLfloat);
    procedure glProgramUniform3d(program_: GLuint; location: GLint; v0: GLdouble; v1: GLdouble; v2: GLdouble);
    procedure glProgramUniform3dv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLdouble);
    procedure glProgramUniform3ui(program_: GLuint; location: GLint; v0: GLuint; v1: GLuint; v2: GLuint);
    procedure glProgramUniform3uiv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLuint);
    procedure glProgramUniform4i(program_: GLuint; location: GLint; v0: GLint; v1: GLint; v2: GLint; v3: GLint);
    procedure glProgramUniform4iv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLint);
    procedure glProgramUniform4f(program_: GLuint; location: GLint; v0: GLfloat; v1: GLfloat; v2: GLfloat; v3: GLfloat);
    procedure glProgramUniform4fv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLfloat);
    procedure glProgramUniform4d(program_: GLuint; location: GLint; v0: GLdouble; v1: GLdouble; v2: GLdouble; v3: GLdouble);
    procedure glProgramUniform4dv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLdouble);
    procedure glProgramUniform4ui(program_: GLuint; location: GLint; v0: GLuint; v1: GLuint; v2: GLuint; v3: GLuint);
    procedure glProgramUniform4uiv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLuint);
    procedure glProgramUniformMatrix2fv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat);
    procedure glProgramUniformMatrix3fv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat);
    procedure glProgramUniformMatrix4fv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat);
    procedure glProgramUniformMatrix2dv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLdouble);
    procedure glProgramUniformMatrix3dv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLdouble);
    procedure glProgramUniformMatrix4dv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLdouble);
    procedure glProgramUniformMatrix2x3fv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat);
    procedure glProgramUniformMatrix3x2fv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat);
    procedure glProgramUniformMatrix2x4fv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat);
    procedure glProgramUniformMatrix4x2fv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat);
    procedure glProgramUniformMatrix3x4fv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat);
    procedure glProgramUniformMatrix4x3fv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat);
    procedure glProgramUniformMatrix2x3dv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLdouble);
    procedure glProgramUniformMatrix3x2dv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLdouble);
    procedure glProgramUniformMatrix2x4dv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLdouble);
    procedure glProgramUniformMatrix4x2dv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLdouble);
    procedure glProgramUniformMatrix3x4dv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLdouble);
    procedure glProgramUniformMatrix4x3dv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLdouble);

    // ──────────────────────────────────────────────────────────────
    // Indirect Drawing
    // ──────────────────────────────────────────────────────────────
    procedure glDrawArraysIndirect(mode: GLenum; const indirect: Pointer);
    procedure glDrawElementsIndirect(mode: GLenum; type_: GLenum; const indirect: Pointer);

    // ──────────────────────────────────────────────────────────────
    // Multi-viewport & Scissor
    // ──────────────────────────────────────────────────────────────
    procedure glViewportArrayv(First: GLuint; Count: GLsizei; const v: PGLfloat);
    procedure glViewportIndexedf(index: GLuint; x: GLfloat; y: GLfloat; w: GLfloat; h: GLfloat);
    procedure glViewportIndexedfv(index: GLuint; const v: PGLfloat);
    procedure glScissorArrayv(First: GLuint; Count: GLsizei; const v: PGLint);
    procedure glScissorIndexed(index: GLuint; left: GLint; bottom: GLint; Width: GLsizei; Height: GLsizei);
    procedure glScissorIndexedv(index: GLuint; const v: PGLint);

    // ──────────────────────────────────────────────────────────────
    // Enhanced Depth/Stencil
    // ──────────────────────────────────────────────────────────────
    procedure glDepthRangeArrayv(First: GLuint; Count: GLsizei; const v: PGLclampd);
    procedure glDepthRangeIndexed(index: GLuint; n: GLclampd; f: GLclampd);

    // ──────────────────────────────────────────────────────────────
    // Memory Barrier (fine-grained)
    // ──────────────────────────────────────────────────────────────
    procedure glMemoryBarrierByRegion(barriers: GLbitfield);
  end;

  TOpenGLES_3_2 = class(TOpenGLES_3_1, IGLES_3_2)
  protected
    // Geometry & Tessellation Shaders (opzionali ma core)
    FGLESPatchParameteri: procedure(pname: GLenum; Value: GLint); stdcall;
    FGLESPatchParameterfv: procedure(pname: GLenum; const values: PGLfloat); stdcall;

    // Multisample Textures
    FGLESTexStorage2DMultisample: procedure(target: GLenum; samples: GLsizei; internalformat: GLenum; Width, Height: GLsizei; fixedsamplelocations: GLboolean); stdcall;
    FGLESTexStorage3DMultisample: procedure(target: GLenum; samples: GLsizei; internalformat: GLenum; Width, Height, depth: GLsizei; fixedsamplelocations: GLboolean); stdcall;

    // Advanced Blending (per-drawbuffer)
    FGLESBlendBarrier: procedure; stdcall;
    FGLESBlendEquationi: procedure(buf: GLuint; mode: GLenum); stdcall;
    FGLESBlendEquationSeparatei: procedure(buf: GLuint; modeRGB, modeAlpha: GLenum); stdcall;
    FGLESBlendFunci: procedure(buf: GLuint; src, dst: GLenum); stdcall;
    FGLESBlendFuncSeparatei: procedure(buf: GLuint; srcRGB, dstRGB, srcAlpha, dstAlpha: GLenum); stdcall;

    // Primitive Bounding Box
    FGLESPrimitiveBoundingBox: procedure(minX, minY, minZ, minW, maxX, maxY, maxZ, maxW: GLfloat); stdcall;

    // Debug Output (core in ES 3.2)
    FGLESDebugMessageControl: procedure(Source, type_, severity: GLenum; Count: GLsizei; const ids: PGLuint; Enabled: GLboolean); stdcall;
    FGLESDebugMessageInsert: procedure(Source, type_: GLenum; id: GLuint; severity: GLenum; length: GLsizei; const buf: PGLchar); stdcall;
    FGLESDebugMessageCallback: procedure(callback: GLDEBUGPROC; const userParam: Pointer); stdcall;
    FGLESGetDebugMessageLog: function(Count: GLuint; bufSize: GLsizei; sources, types: PGLenum; ids: PGLuint; severities: PGLenum; lengths: PGLsizei; messageLog: PGLchar): GLuint; stdcall;
    FGLESPushDebugGroup: procedure(Source: GLenum; id: GLuint; length: GLsizei; const message: PGLchar); stdcall;
    FGLESPopDebugGroup: procedure; stdcall;
    FGLESObjectLabel: procedure(identifier: GLenum; Name: GLuint; length: GLsizei; const aLabel: PGLchar); stdcall;
    FGLESGetObjectLabel: procedure(identifier: GLenum; Name: GLuint; bufSize: GLsizei; length: PGLsizei; aLabel: PGLchar); stdcall;
    FGLESObjectPtrLabel: procedure(const ptr: Pointer; length: GLsizei; const aLabel: PGLchar); stdcall;
    FGLESGetObjectPtrLabel: procedure(const ptr: Pointer; bufSize: GLsizei; length: PGLsizei; aLabel: PGLchar); stdcall;
    FGLESGetPointerv: procedure(pname: GLenum; params: PPointer); stdcall;

    // Enhanced Sampling
    FGLESMinSampleShading: procedure(Value: GLfloat); stdcall;
    FGLESGetMultisamplefv: procedure(pname: GLenum; index: GLuint; val: PGLfloat); stdcall;
    FGLESSampleMaski: procedure(maskNumber: GLuint; mask: GLbitfield); stdcall;

    // Texture Buffer Range & Texture View
    FGLESTexBufferRange: procedure(target: GLenum; internalformat: GLenum; buffer: GLuint; offset: GLintptr; size: GLsizeiptr); stdcall;
    FGLESTextureView: procedure(texture, target, origtexture: GLuint; internalformat: GLenum; minlevel, numlevels, minlayer, numlayers: GLuint); stdcall;

    // Enhanced Queries
    FGLESGetQueryObjecti64v: procedure(id: GLuint; pname: GLenum; params: PGLint64); stdcall;
    // FGLESGetQueryObjectui64v: procedure(id: GLuint; pname: GLenum; params: PGLuint64); stdcall;

    // Framebuffer Parameters
    FGLESFramebufferParameteri: procedure(target: GLenum; pname: GLenum; param: GLint); stdcall;
    FGLESGetFramebufferParameteriv: procedure(target: GLenum; pname: GLenum; params: PGLint); stdcall;

    // ClearTexImage / ClearTexSubImage
    FGLESClearTexImage: procedure(texture: GLuint; level: GLint; format, type_: GLenum; const Data: Pointer); stdcall;
    FGLESClearTexSubImage: procedure(texture: GLuint; level, xoffset, yoffset, zoffset: GLint; Width, Height, depth: GLsizei; format, type_: GLenum; const Data: Pointer); stdcall;

    // Robustness
    FGLESGetGraphicsResetStatus: function: GLenum; stdcall;
    FGLESReadnPixels: procedure(x, y: GLint; Width, Height: GLsizei; format, type_: GLenum; bufSize: GLsizei; Data: Pointer); stdcall;
    FGLESGetnUniformfv: procedure(program_: GLuint; location: GLint; bufSize: GLsizei; params: PGLfloat); stdcall;
    FGLESGetnUniformiv: procedure(program_: GLuint; location: GLint; bufSize: GLsizei; params: PGLint); stdcall;
    FGLESGetnUniformuiv: procedure(program_: GLuint; location: GLint; bufSize: GLsizei; params: PGLuint); stdcall;
  public
    procedure bindEntry; override;

    // ──────────────────────────────────────────────────────────────
    // Geometry Shaders (finalmente in ES!)
    // ──────────────────────────────────────────────────────────────
    procedure glPatchParameteri(pname: GLenum; Value: GLint);
    procedure glPatchParameterfv(pname: GLenum; const values: PGLfloat);

    // ──────────────────────────────────────────────────────────────
    // Tessellation Shaders
    // ──────────────────────────────────────────────────────────────
    // (le funzioni di controllo sono già in 3.2 core, gli shader sono opzionali ma supportati)

    // ──────────────────────────────────────────────────────────────
    // Multisample Textures & Immutable Storage Multisample
    // ──────────────────────────────────────────────────────────────
    procedure glTexStorage2DMultisample(target: GLenum; samples: GLsizei; internalformat: GLenum; Width: GLsizei; Height: GLsizei; fixedsamplelocations: GLboolean);

    procedure glTexStorage3DMultisample(target: GLenum; samples: GLsizei; internalformat: GLenum; Width: GLsizei; Height: GLsizei; depth: GLsizei; fixedsamplelocations: GLboolean);

    // ──────────────────────────────────────────────────────────────
    // Advanced Blending (per-colorbuffer blend equations & functions)
    // ──────────────────────────────────────────────────────────────
    procedure glBlendBarrier;

    procedure glBlendEquationi(buf: GLuint; mode: GLenum);
    procedure glBlendEquationSeparatei(buf: GLuint; modeRGB: GLenum; modeAlpha: GLenum);
    procedure glBlendFunci(buf: GLuint; src: GLenum; dst: GLenum);
    procedure glBlendFuncSeparatei(buf: GLuint; srcRGB: GLenum; dstRGB: GLenum; srcAlpha: GLenum; dstAlpha: GLenum);

    // ──────────────────────────────────────────────────────────────
    // Enhanced Memory Barriers
    // ──────────────────────────────────────────────────────────────
    //procedure glMemoryBarrier(barriers: GLbitfield);

    // ──────────────────────────────────────────────────────────────
    // Primitive Bounding Box (per geometry/tessellation clipping)
    // ──────────────────────────────────────────────────────────────
    procedure glPrimitiveBoundingBox(minX, minY, minZ, minW, maxX, maxY, maxZ, maxW: GLfloat);

    // ──────────────────────────────────────────────────────────────
    // Debug Output (KHR_debug promosso a core in ES 3.2)
    // ──────────────────────────────────────────────────────────────
    procedure glDebugMessageControl(Source: GLenum; type_: GLenum; severity: GLenum; Count: GLsizei; const ids: PGLuint; Enabled: GLboolean);
    procedure glDebugMessageInsert(Source: GLenum; type_: GLenum; id: GLuint; severity: GLenum; length: GLsizei; const buf: PGLchar);
    procedure glDebugMessageCallback(callback: GLDEBUGPROC; const userParam: Pointer);
    function glGetDebugMessageLog(Count: GLuint; bufSize: GLsizei; sources: PGLenum; types: PGLenum; ids: PGLuint; severities: PGLenum; lengths: PGLsizei; messageLog: PGLchar): GLuint;
    procedure glPushDebugGroup(Source: GLenum; id: GLuint; length: GLsizei; const message: PGLchar);
    procedure glPopDebugGroup;
    procedure glObjectLabel(identifier: GLenum; Name: GLuint; length: GLsizei; const aLabel: PGLchar);
    procedure glGetObjectLabel(identifier: GLenum; Name: GLuint; bufSize: GLsizei; length: PGLsizei; aLabel: PGLchar);
    procedure glObjectPtrLabel(const ptr: Pointer; length: GLsizei; const aLabel: PGLchar);
    procedure glGetObjectPtrLabel(const ptr: Pointer; bufSize: GLsizei; length: PGLsizei; aLabel: PGLchar);
    procedure glGetPointerv(pname: GLenum; params: PPointer);

    // ──────────────────────────────────────────────────────────────
    // Enhanced Image/Atomic Operations
    // ──────────────────────────────────────────────────────────────
    procedure glMinSampleShading(Value: GLfloat);
    procedure glGetMultisamplefv(pname: GLenum; index: GLuint; val: PGLfloat);
    procedure glSampleMaski(maskNumber: GLuint; mask: GLbitfield);

    // ──────────────────────────────────────────────────────────────
    // Texture Gather & Advanced Sampling
    // ──────────────────────────────────────────────────────────────
    procedure glTexBufferRange(target: GLenum; internalformat: GLenum; buffer: GLuint; offset: GLintptr; size: GLsizeiptr);
    procedure glTextureView(texture: GLuint; target: GLenum; origtexture: GLuint; internalformat: GLenum; minlevel: GLuint; numlevels: GLuint; minlayer: GLuint; numlayers: GLuint);

    // ──────────────────────────────────────────────────────────────
    // Query Enhancements
    // ──────────────────────────────────────────────────────────────
    procedure glGetQueryObjecti64v(id: GLuint; pname: GLenum; params: PGLint64);
    procedure glGetQueryObjectui64v(id: GLuint; pname: GLenum; params: PGLuint64); reintroduce;

    // ──────────────────────────────────────────────────────────────
    // Framebuffer No-Attachment & Default Framebuffer Enhancements
    // ──────────────────────────────────────────────────────────────
    procedure glFramebufferParameteri(target: GLenum; pname: GLenum; param: GLint);
    procedure glGetFramebufferParameteriv(target: GLenum; pname: GLenum; params: PGLint);

    // ──────────────────────────────────────────────────────────────
    // Enhanced Clear & Invalidate
    // ──────────────────────────────────────────────────────────────
    procedure glClearTexImage(texture: GLuint; level: GLint; format: GLenum; type_: GLenum; const Data: Pointer);
    procedure glClearTexSubImage(texture: GLuint; level: GLint; xoffset: GLint; yoffset: GLint; zoffset: GLint; Width: GLsizei; Height: GLsizei; depth: GLsizei; format: GLenum; type_: GLenum; const Data: Pointer);

    // ──────────────────────────────────────────────────────────────
    // Robust Buffer Access & Graphics Reset
    // ──────────────────────────────────────────────────────────────
    function glGetGraphicsResetStatus: GLenum;
    procedure glReadnPixels(x: GLint; y: GLint; Width: GLsizei; Height: GLsizei; format: GLenum; type_: GLenum; bufSize: GLsizei; Data: Pointer);
    procedure glGetnUniformfv(program_: GLuint; location: GLint; bufSize: GLsizei; params: PGLfloat);
    procedure glGetnUniformiv(program_: GLuint; location: GLint; bufSize: GLsizei; params: PGLint);
    procedure glGetnUniformuiv(program_: GLuint; location: GLint; bufSize: GLsizei; params: PGLuint);
  end;

function GLES: IGLES;
var
  Base: TOpenGLES_3_2;
begin
  if not assigned(singleton) then
  begin
    base := TOpenGLES_3_2.Create;
    base.LoadLibrary;
    Base.bindEntry;
    singleton := Base;
  end;
  Result := singleton;
end;

{ TGLESBase }

var
  debugFile: Text;

function ifThen(test: boolean; ifTrue, ifFalse: string): string;
begin
  if (test) then exit(ifTrue)
  else
    exit(ifFalse);
end;

function TGLESBase.LoadProc(Name: ansistring): Pointer;
var
  fileName: TFileName;
begin
  fileName := ExpandFileName(ParamStr(0)) + '.gles.log';
  AssignFile(debugFile, fileName);
  if FileExists(fileName) then
    Append(debugFile)
  else
    Rewrite(debugFile);
  Writeln(debugFile, IfThen(assigned(Result), '     found:', ' not found:'), Name);
  Flush(debugFile);
  CloseFile(debugFile);
end;

procedure TGLESBase.Bind(var FuncPtr: Pointer; const Name: ansistring; Mandatory: boolean);
begin
  Pointer(FuncPtr) := LoadProc(Name);
  if (Pointer(FuncPtr) = nil) and Mandatory then
    raise Exception.Create('OpenGLES function not found: ' + Name);
end;

procedure TGLESBase.bindEntry;
begin

end;

procedure TGLESBase.LoadLibrary;
begin
  FHandle := dynlibs.LoadLibrary(libGLES);
end;

procedure TGLESBase.unLoadLibrary;
begin
  dynlibs.UnloadLibrary(FHandle);
end;

destructor TGLESBase.Destroy;
begin
  unLoadLibrary;
  inherited Destroy;
end;

{ TOpenGLES_20 }

procedure TOpenGLES_20.bindEntry;
begin
  inherited bindEntry;
  Bind(Pointer(FGLESActiveTexture), 'glActiveTexture');
  Bind(Pointer(FGLESAttachShader), 'glAttachShader');
  Bind(Pointer(FGLESBindAttribLocation), 'glBindAttribLocation');
  Bind(Pointer(FGLESBindBuffer), 'glBindBuffer');
  Bind(Pointer(FGLESBindFramebuffer), 'glBindFramebuffer');
  Bind(Pointer(FGLESBindRenderbuffer), 'glBindRenderbuffer');
  Bind(Pointer(FGLESBindTexture), 'glBindTexture');
  Bind(Pointer(FGLESBlendColor), 'glBlendColor');
  Bind(Pointer(FGLESBlendEquation), 'glBlendEquation');
  Bind(Pointer(FGLESBlendEquationSeparate), 'glBlendEquationSeparate');
  Bind(Pointer(FGLESBlendFunc), 'glBlendFunc');
  Bind(Pointer(FGLESBlendFuncSeparate), 'glBlendFuncSeparate');
  Bind(Pointer(FGLESBufferData), 'glBufferData');
  Bind(Pointer(FGLESBufferSubData), 'glBufferSubData');
  Bind(Pointer(FGLESClear), 'glClear');
  Bind(Pointer(FGLESClearColor), 'glClearColor');
  Bind(Pointer(FGLESClearDepthf), 'glClearDepthf');
  Bind(Pointer(FGLESClearStencil), 'glClearStencil');
  Bind(Pointer(FGLESColorMask), 'glColorMask');
  Bind(Pointer(FGLESCompileShader), 'glCompileShader');
  Bind(Pointer(FGLESCompressedTexImage2D), 'glCompressedTexImage2D');
  Bind(Pointer(FGLESCompressedTexSubImage2D), 'glCompressedTexSubImage2D');
  Bind(Pointer(FGLESCopyTexImage2D), 'glCopyTexImage2D');
  Bind(Pointer(FGLESCopyTexSubImage2D), 'glCopyTexSubImage2D');
  Bind(Pointer(FGLESCreateProgram), 'glCreateProgram');
  Bind(Pointer(FGLESCreateShader), 'glCreateShader');
  Bind(Pointer(FGLESCullFace), 'glCullFace');
  Bind(Pointer(FGLESDeleteBuffers), 'glDeleteBuffers');
  Bind(Pointer(FGLESDeleteFramebuffers), 'glDeleteFramebuffers');
  Bind(Pointer(FGLESDeleteProgram), 'glDeleteProgram');
  Bind(Pointer(FGLESDeleteRenderbuffers), 'glDeleteRenderbuffers');
  Bind(Pointer(FGLESDeleteShader), 'glDeleteShader');
  Bind(Pointer(FGLESDeleteTextures), 'glDeleteTextures');
  Bind(Pointer(FGLESDepthFunc), 'glDepthFunc');
  Bind(Pointer(FGLESDepthMask), 'glDepthMask');
  Bind(Pointer(FGLESDepthRangef), 'glDepthRangef');
  Bind(Pointer(FGLESDetachShader), 'glDetachShader');
  Bind(Pointer(FGLESDisable), 'glDisable');
  Bind(Pointer(FGLESDisableVertexAttribArray), 'glDisableVertexAttribArray');
  Bind(Pointer(FGLESDrawArrays), 'glDrawArrays');
  Bind(Pointer(FGLESDrawElements), 'glDrawElements');
  Bind(Pointer(FGLESEnable), 'glEnable');
  Bind(Pointer(FGLESEnableVertexAttribArray), 'glEnableVertexAttribArray');
  Bind(Pointer(FGLESFinish), 'glFinish');
  Bind(Pointer(FGLESFlush), 'glFlush');
  Bind(Pointer(FGLESFramebufferRenderbuffer), 'glFramebufferRenderbuffer');
  Bind(Pointer(FGLESFramebufferTexture2D), 'glFramebufferTexture2D');
  Bind(Pointer(FGLESFrontFace), 'glFrontFace');
  Bind(Pointer(FGLESGenBuffers), 'glGenBuffers');
  Bind(Pointer(FGLESGenerateMipmap), 'glGenerateMipmap');
  Bind(Pointer(FGLESGenFramebuffers), 'glGenFramebuffers');
  Bind(Pointer(FGLESGenRenderbuffers), 'glGenRenderbuffers');
  Bind(Pointer(FGLESGenTextures), 'glGenTextures');
  Bind(Pointer(FGLESGetActiveAttrib), 'glGetActiveAttrib');
  Bind(Pointer(FGLESGetActiveUniform), 'glGetActiveUniform');
  Bind(Pointer(FGLESGetAttachedShaders), 'glGetAttachedShaders');
  Bind(Pointer(FGLESGetAttribLocation), 'glGetAttribLocation');
  Bind(Pointer(FGLESGetBooleanv), 'glGetBooleanv');
  Bind(Pointer(FGLESGetBufferParameteriv), 'glGetBufferParameteriv');
  Bind(Pointer(FGLESGetError), 'glGetError');
  Bind(Pointer(FGLESGetFloatv), 'glGetFloatv');
  Bind(Pointer(FGLESGetFramebufferAttachmentParameteriv), 'glGetFramebufferAttachmentParameteriv');
  Bind(Pointer(FGLESGetIntegerv), 'glGetIntegerv');
  Bind(Pointer(FGLESGetProgramiv), 'glGetProgramiv');
  Bind(Pointer(FGLESGetProgramInfoLog), 'glGetProgramInfoLog');
  Bind(Pointer(FGLESGetRenderbufferParameteriv), 'glGetRenderbufferParameteriv');
  Bind(Pointer(FGLESGetShaderiv), 'glGetShaderiv');
  Bind(Pointer(FGLESGetShaderInfoLog), 'glGetShaderInfoLog');
  Bind(Pointer(FGLESGetShaderPrecisionFormat), 'glGetShaderPrecisionFormat');
  Bind(Pointer(FGLESGetShaderSource), 'glGetShaderSource');
  Bind(Pointer(FGLESGetString), 'glGetString');
  Bind(Pointer(FGLESGetTexParameterfv), 'glGetTexParameterfv');
  Bind(Pointer(FGLESGetTexParameteriv), 'glGetTexParameteriv');
  Bind(Pointer(FGLESGetUniformfv), 'glGetUniformfv');
  Bind(Pointer(FGLESGetUniformiv), 'glGetUniformiv');
  Bind(Pointer(FGLESGetUniformLocation), 'glGetUniformLocation');
  Bind(Pointer(FGLESGetVertexAttribfv), 'glGetVertexAttribfv');
  Bind(Pointer(FGLESGetVertexAttribiv), 'glGetVertexAttribiv');
  Bind(Pointer(FGLESGetVertexAttribPointerv), 'glGetVertexAttribPointerv');
  Bind(Pointer(FGLESHint), 'glHint');
  Bind(Pointer(FGLESIsBuffer), 'glIsBuffer');
  Bind(Pointer(FGLESIsEnabled), 'glIsEnabled');
  Bind(Pointer(FGLESIsFramebuffer), 'glIsFramebuffer');
  Bind(Pointer(FGLESIsProgram), 'glIsProgram');
  Bind(Pointer(FGLESIsRenderbuffer), 'glIsRenderbuffer');
  Bind(Pointer(FGLESIsShader), 'glIsShader');
  Bind(Pointer(FGLESIsTexture), 'glIsTexture');
  Bind(Pointer(FGLESLineWidth), 'glLineWidth');
  Bind(Pointer(FGLESLinkProgram), 'glLinkProgram');
  Bind(Pointer(FGLESPixelStorei), 'glPixelStorei');
  Bind(Pointer(FGLESPolygonOffset), 'glPolygonOffset');
  Bind(Pointer(FGLESReadPixels), 'glReadPixels');
  Bind(Pointer(FGLESReleaseShaderCompiler), 'glReleaseShaderCompiler');
  Bind(Pointer(FGLESRenderbufferStorage), 'glRenderbufferStorage');
  Bind(Pointer(FGLESSampleCoverage), 'glSampleCoverage');
  Bind(Pointer(FGLESScissor), 'glScissor');
  Bind(Pointer(FGLESShaderBinary), 'glShaderBinary');
  Bind(Pointer(FGLESShaderSource), 'glShaderSource');
  Bind(Pointer(FGLESStencilFunc), 'glStencilFunc');
  Bind(Pointer(FGLESStencilFuncSeparate), 'glStencilFuncSeparate');
  Bind(Pointer(FGLESStencilMask), 'glStencilMask');
  Bind(Pointer(FGLESStencilMaskSeparate), 'glStencilMaskSeparate');
  Bind(Pointer(FGLESStencilOp), 'glStencilOp');
  Bind(Pointer(FGLESStencilOpSeparate), 'glStencilOpSeparate');
  Bind(Pointer(FGLESTexImage2D), 'glTexImage2D');
  Bind(Pointer(FGLESTexParameterf), 'glTexParameterf');
  Bind(Pointer(FGLESTexParameterfv), 'glTexParameterfv');
  Bind(Pointer(FGLESTexParameteri), 'glTexParameteri');
  Bind(Pointer(FGLESTexParameteriv), 'glTexParameteriv');
  Bind(Pointer(FGLESTexSubImage2D), 'glTexSubImage2D');
  Bind(Pointer(FGLESUniform1f), 'glUniform1f');
  Bind(Pointer(FGLESUniform1fv), 'glUniform1fv');
  Bind(Pointer(FGLESUniform1i), 'glUniform1i');
  Bind(Pointer(FGLESUniform1iv), 'glUniform1iv');
  Bind(Pointer(FGLESUniform2f), 'glUniform2f');
  Bind(Pointer(FGLESUniform2fv), 'glUniform2fv');
  Bind(Pointer(FGLESUniform2i), 'glUniform2i');
  Bind(Pointer(FGLESUniform2iv), 'glUniform2iv');
  Bind(Pointer(FGLESUniform3f), 'glUniform3f');
  Bind(Pointer(FGLESUniform3fv), 'glUniform3fv');
  Bind(Pointer(FGLESUniform3i), 'glUniform3i');
  Bind(Pointer(FGLESUniform3iv), 'glUniform3iv');
  Bind(Pointer(FGLESUniform4f), 'glUniform4f');
  Bind(Pointer(FGLESUniform4fv), 'glUniform4fv');
  Bind(Pointer(FGLESUniform4i), 'glUniform4i');
  Bind(Pointer(FGLESUniform4iv), 'glUniform4iv');
  Bind(Pointer(FGLESUniformMatrix2fv), 'glUniformMatrix2fv');
  Bind(Pointer(FGLESUniformMatrix3fv), 'glUniformMatrix3fv');
  Bind(Pointer(FGLESUniformMatrix4fv), 'glUniformMatrix4fv');
  Bind(Pointer(FGLESUseProgram), 'glUseProgram');
  Bind(Pointer(FGLESValidateProgram), 'glValidateProgram');
  Bind(Pointer(FGLESVertexAttrib1f), 'glVertexAttrib1f');
  Bind(Pointer(FGLESVertexAttrib1fv), 'glVertexAttrib1fv');
  Bind(Pointer(FGLESVertexAttrib2f), 'glVertexAttrib2f');
  Bind(Pointer(FGLESVertexAttrib2fv), 'glVertexAttrib2fv');
  Bind(Pointer(FGLESVertexAttrib3f), 'glVertexAttrib3f');
  Bind(Pointer(FGLESVertexAttrib3fv), 'glVertexAttrib3fv');
  Bind(Pointer(FGLESVertexAttrib4f), 'glVertexAttrib4f');
  Bind(Pointer(FGLESVertexAttrib4fv), 'glVertexAttrib4fv');
  Bind(Pointer(FGLESVertexAttribPointer), 'glVertexAttribPointer');
  Bind(Pointer(FGLESViewport), 'glViewport');
  Bind(Pointer(FGLESCheckFramebufferStatus), 'glCheckFramebufferStatus');
end;

procedure TOpenGLES_20.glActiveTexture(texture: GLenum);
begin
  if Assigned(FGLESActiveTexture) then
    FGLESActiveTexture(texture);
end;

procedure TOpenGLES_20.glAttachShader(program_: GLuint; shader: GLuint);
begin
  if Assigned(FGLESAttachShader) then
    FGLESAttachShader(program_, shader);
end;

procedure TOpenGLES_20.glBindAttribLocation(program_: GLuint; index: GLuint; const Name: PGLchar);
begin
  if Assigned(FGLESBindAttribLocation) then
    FGLESBindAttribLocation(program_, index, Name);
end;

procedure TOpenGLES_20.glBindBuffer(target: GLenum; buffer: GLuint);
begin
  if Assigned(FGLESBindBuffer) then
    FGLESBindBuffer(target, buffer);
end;

procedure TOpenGLES_20.glBindFramebuffer(target: GLenum; framebuffer: GLuint);
begin
  if Assigned(FGLESBindFramebuffer) then
    FGLESBindFramebuffer(target, framebuffer);
end;

procedure TOpenGLES_20.glBindRenderbuffer(target: GLenum; renderbuffer: GLuint);
begin
  if Assigned(FGLESBindRenderbuffer) then
    FGLESBindRenderbuffer(target, renderbuffer);
end;

procedure TOpenGLES_20.glBindTexture(target: GLenum; texture: GLuint);
begin
  if Assigned(FGLESBindTexture) then
    FGLESBindTexture(target, texture);
end;

procedure TOpenGLES_20.glBlendColor(red: GLfloat; green: GLfloat; blue: GLfloat; alpha: GLfloat);
begin
  if Assigned(FGLESBlendColor) then
    FGLESBlendColor(red, green, blue, alpha);
end;

procedure TOpenGLES_20.glBlendEquation(mode: GLenum);
begin
  if Assigned(FGLESBlendEquation) then
    FGLESBlendEquation(mode);
end;

procedure TOpenGLES_20.glBlendEquationSeparate(modeRGB: GLenum; modeAlpha: GLenum);
begin
  if Assigned(FGLESBlendEquationSeparate) then
    FGLESBlendEquationSeparate(modeRGB, modeAlpha);
end;

procedure TOpenGLES_20.glBlendFunc(sfactor: GLenum; dfactor: GLenum);
begin
  if Assigned(FGLESBlendFunc) then
    FGLESBlendFunc(sfactor, dfactor);
end;

procedure TOpenGLES_20.glBlendFuncSeparate(srcRGB: GLenum; dstRGB: GLenum; srcAlpha: GLenum; dstAlpha: GLenum);
begin
  if Assigned(FGLESBlendFuncSeparate) then
    FGLESBlendFuncSeparate(srcRGB, dstRGB, srcAlpha, dstAlpha);
end;

procedure TOpenGLES_20.glBufferData(target: GLenum; size: GLsizeiptr; const Data: Pointer; usage: GLenum);
begin
  if Assigned(FGLESBufferData) then
    FGLESBufferData(target, size, Data, usage);
end;

procedure TOpenGLES_20.glBufferSubData(target: GLenum; offset: GLintptr; size: GLsizeiptr; const Data: Pointer);
begin
  if Assigned(FGLESBufferSubData) then
    FGLESBufferSubData(target, offset, size, Data);
end;

procedure TOpenGLES_20.glClear(mask: GLbitfield);
begin
  if Assigned(FGLESClear) then
    FGLESClear(mask);
end;

procedure TOpenGLES_20.glClearColor(red: GLfloat; green: GLfloat; blue: GLfloat; alpha: GLfloat);
begin
  if Assigned(FGLESClearColor) then
    FGLESClearColor(red, green, blue, alpha);
end;

procedure TOpenGLES_20.glClearDepthf(depth: GLfloat);
begin
  if Assigned(FGLESClearDepthf) then
    FGLESClearDepthf(depth);
end;

procedure TOpenGLES_20.glClearStencil(s: GLint);
begin
  if Assigned(FGLESClearStencil) then
    FGLESClearStencil(s);
end;

procedure TOpenGLES_20.glColorMask(red: GLboolean; green: GLboolean; blue: GLboolean; alpha: GLboolean);
begin
  if Assigned(FGLESColorMask) then
    FGLESColorMask(red, green, blue, alpha);
end;

procedure TOpenGLES_20.glCompileShader(shader: GLuint);
begin
  if Assigned(FGLESCompileShader) then
    FGLESCompileShader(shader);
end;

procedure TOpenGLES_20.glCompressedTexImage2D(target: GLenum; level: GLint; internalformat: GLenum; Width: GLsizei; Height: GLsizei; border: GLint; imageSize: GLsizei; const Data: Pointer);
begin
  if Assigned(FGLESCompressedTexImage2D) then
    FGLESCompressedTexImage2D(target, level, internalformat, Width, Height, border, imageSize, Data);
end;

procedure TOpenGLES_20.glCompressedTexSubImage2D(target: GLenum; level: GLint; xoffset: GLint; yoffset: GLint; Width: GLsizei; Height: GLsizei; format: GLenum; imageSize: GLsizei; const Data: Pointer);
begin
  if Assigned(FGLESCompressedTexSubImage2D) then
    FGLESCompressedTexSubImage2D(target, level, xoffset, yoffset, Width, Height, format, imageSize, Data);
end;

procedure TOpenGLES_20.glCopyTexImage2D(target: GLenum; level: GLint; internalformat: GLenum; x: GLint; y: GLint; Width: GLsizei; Height: GLsizei; border: GLint);
begin
  if Assigned(FGLESCopyTexImage2D) then
    FGLESCopyTexImage2D(target, level, internalformat, x, y, Width, Height, border);
end;

procedure TOpenGLES_20.glCopyTexSubImage2D(target: GLenum; level: GLint; xoffset: GLint; yoffset: GLint; x: GLint; y: GLint; Width: GLsizei; Height: GLsizei);
begin
  if Assigned(FGLESCopyTexSubImage2D) then
    FGLESCopyTexSubImage2D(target, level, xoffset, yoffset, x, y, Width, Height);
end;

function TOpenGLES_20.glCreateProgram: GLuint;
begin
  if Assigned(FGLESCreateProgram) then
    Result := FGLESCreateProgram()
  else
    Result := 0;
end;

function TOpenGLES_20.glCreateShader(type_: GLenum): GLuint;
begin
  if Assigned(FGLESCreateShader) then
    Result := FGLESCreateShader(type_)
  else
    Result := 0;
end;

procedure TOpenGLES_20.glCullFace(mode: GLenum);
begin
  if Assigned(FGLESCullFace) then
    FGLESCullFace(mode);
end;

procedure TOpenGLES_20.glDeleteBuffers(n: GLsizei; const buffers: PGLuint);
begin
  if Assigned(FGLESDeleteBuffers) then
    FGLESDeleteBuffers(n, buffers);
end;

procedure TOpenGLES_20.glDeleteFramebuffers(n: GLsizei; const framebuffers: PGLuint);
begin
  if Assigned(FGLESDeleteFramebuffers) then
    FGLESDeleteFramebuffers(n, framebuffers);
end;

procedure TOpenGLES_20.glDeleteProgram(program_: GLuint);
begin
  if Assigned(FGLESDeleteProgram) then
    FGLESDeleteProgram(program_);
end;

procedure TOpenGLES_20.glDeleteRenderbuffers(n: GLsizei; const renderbuffers: PGLuint);
begin
  if Assigned(FGLESDeleteRenderbuffers) then
    FGLESDeleteRenderbuffers(n, renderbuffers);
end;

procedure TOpenGLES_20.glDeleteShader(shader: GLuint);
begin
  if Assigned(FGLESDeleteShader) then
    FGLESDeleteShader(shader);
end;

procedure TOpenGLES_20.glDeleteTextures(n: GLsizei; const textures: PGLuint);
begin
  if Assigned(FGLESDeleteTextures) then
    FGLESDeleteTextures(n, textures);
end;

procedure TOpenGLES_20.glDepthFunc(func: GLenum);
begin
  if Assigned(FGLESDepthFunc) then
    FGLESDepthFunc(func);
end;

procedure TOpenGLES_20.glDepthMask(flag: GLboolean);
begin
  if Assigned(FGLESDepthMask) then
    FGLESDepthMask(flag);
end;

procedure TOpenGLES_20.glDepthRangef(n: GLfloat; f: GLfloat);
begin
  if Assigned(FGLESDepthRangef) then
    FGLESDepthRangef(n, f);
end;

procedure TOpenGLES_20.glDetachShader(program_: GLuint; shader: GLuint);
begin
  if Assigned(FGLESDetachShader) then
    FGLESDetachShader(program_, shader);
end;

procedure TOpenGLES_20.glDisable(cap: GLenum);
begin
  if Assigned(FGLESDisable) then
    FGLESDisable(cap);
end;

procedure TOpenGLES_20.glDisableVertexAttribArray(index: GLuint);
begin
  if Assigned(FGLESDisableVertexAttribArray) then
    FGLESDisableVertexAttribArray(index);
end;

procedure TOpenGLES_20.glDrawArrays(mode: GLenum; First: GLint; Count: GLsizei);
begin
  if Assigned(FGLESDrawArrays) then
    FGLESDrawArrays(mode, First, Count);
end;

procedure TOpenGLES_20.glDrawElements(mode: GLenum; Count: GLsizei; type_: GLenum; const indices: Pointer);
begin
  if Assigned(FGLESDrawElements) then
    FGLESDrawElements(mode, Count, type_, indices);
end;

procedure TOpenGLES_20.glEnable(cap: GLenum);
begin
  if Assigned(FGLESEnable) then
    FGLESEnable(cap);
end;

procedure TOpenGLES_20.glEnableVertexAttribArray(index: GLuint);
begin
  if Assigned(FGLESEnableVertexAttribArray) then
    FGLESEnableVertexAttribArray(index);
end;

procedure TOpenGLES_20.glFinish;
begin
  if Assigned(FGLESFinish) then
    FGLESFinish();
end;

procedure TOpenGLES_20.glFlush;
begin
  if Assigned(FGLESFlush) then
    FGLESFlush();
end;

procedure TOpenGLES_20.glFramebufferRenderbuffer(target: GLenum; attachment: GLenum; renderbuffertarget: GLenum; renderbuffer: GLuint);
begin
  if Assigned(FGLESFramebufferRenderbuffer) then
    FGLESFramebufferRenderbuffer(target, attachment, renderbuffertarget, renderbuffer);
end;

procedure TOpenGLES_20.glFramebufferTexture2D(target: GLenum; attachment: GLenum; textarget: GLenum; texture: GLuint; level: GLint);
begin
  if Assigned(FGLESFramebufferTexture2D) then
    FGLESFramebufferTexture2D(target, attachment, textarget, texture, level);
end;

procedure TOpenGLES_20.glFrontFace(mode: GLenum);
begin
  if Assigned(FGLESFrontFace) then
    FGLESFrontFace(mode);
end;

procedure TOpenGLES_20.glGenBuffers(n: GLsizei; buffers: PGLuint);
begin
  if Assigned(FGLESGenBuffers) then
    FGLESGenBuffers(n, buffers);
end;

procedure TOpenGLES_20.glGenerateMipmap(target: GLenum);
begin
  if Assigned(FGLESGenerateMipmap) then
    FGLESGenerateMipmap(target);
end;

procedure TOpenGLES_20.glGenFramebuffers(n: GLsizei; framebuffers: PGLuint);
begin
  if Assigned(FGLESGenFramebuffers) then
    FGLESGenFramebuffers(n, framebuffers);
end;

procedure TOpenGLES_20.glGenRenderbuffers(n: GLsizei; renderbuffers: PGLuint);
begin
  if Assigned(FGLESGenRenderbuffers) then
    FGLESGenRenderbuffers(n, renderbuffers);
end;

procedure TOpenGLES_20.glGenTextures(n: GLsizei; textures: PGLuint);
begin
  if Assigned(FGLESGenTextures) then
    FGLESGenTextures(n, textures);
end;

function TOpenGLES_20.glCheckFramebufferStatus(target: GLenum): GLenum;
begin
  if Assigned(FGLESCheckFramebufferStatus) then
    Result := FGLESCheckFramebufferStatus(target)
  else
    Result := GL_FRAMEBUFFER_COMPLETE;
end;

procedure TOpenGLES_20.glGetActiveAttrib(program_: GLuint; index: GLuint; bufSize: GLsizei; length: PGLsizei; size: PGLint; type_: PGLenum; Name: PGLchar);
begin
  if Assigned(FGLESGetActiveAttrib) then
    FGLESGetActiveAttrib(program_, index, bufSize, length, size, type_, Name);
end;

procedure TOpenGLES_20.glGetActiveUniform(program_: GLuint; index: GLuint; bufSize: GLsizei; length: PGLsizei; size: PGLint; type_: PGLenum; Name: PGLchar);
begin
  if Assigned(FGLESGetActiveUniform) then
    FGLESGetActiveUniform(program_, index, bufSize, length, size, type_, Name);
end;

procedure TOpenGLES_20.glGetAttachedShaders(program_: GLuint; maxCount: GLsizei; Count: PGLsizei; shaders: PGLuint);
begin
  if Assigned(FGLESGetAttachedShaders) then
    FGLESGetAttachedShaders(program_, maxCount, Count, shaders);
end;

function TOpenGLES_20.glGetAttribLocation(program_: GLuint; const Name: PGLchar): GLint;
begin
  if Assigned(FGLESGetAttribLocation) then
    Result := FGLESGetAttribLocation(program_, Name)
  else
    Result := -1;
end;

procedure TOpenGLES_20.glGetBooleanv(pname: GLenum; Data: PGLboolean);
begin
  if Assigned(FGLESGetBooleanv) then
    FGLESGetBooleanv(pname, Data);
end;

procedure TOpenGLES_20.glGetBufferParameteriv(target: GLenum; pname: GLenum; params: PGLint);
begin
  if Assigned(FGLESGetBufferParameteriv) then
    FGLESGetBufferParameteriv(target, pname, params);
end;

function TOpenGLES_20.glGetError: GLenum;
begin
  if Assigned(FGLESGetError) then
    Result := FGLESGetError()
  else
    Result := GL_NO_ERROR;
end;

procedure TOpenGLES_20.glGetFloatv(pname: GLenum; Data: PGLfloat);
begin
  if Assigned(FGLESGetFloatv) then
    FGLESGetFloatv(pname, Data);
end;

procedure TOpenGLES_20.glGetFramebufferAttachmentParameteriv(target: GLenum; attachment: GLenum; pname: GLenum; params: PGLint);
begin
  if Assigned(FGLESGetFramebufferAttachmentParameteriv) then
    FGLESGetFramebufferAttachmentParameteriv(target, attachment, pname, params);
end;

procedure TOpenGLES_20.glGetIntegerv(pname: GLenum; Data: PGLint);
begin
  if Assigned(FGLESGetIntegerv) then
    FGLESGetIntegerv(pname, Data);
end;

procedure TOpenGLES_20.glGetProgramiv(program_: GLuint; pname: GLenum; params: PGLint);
begin
  if Assigned(FGLESGetProgramiv) then
    FGLESGetProgramiv(program_, pname, params);
end;

procedure TOpenGLES_20.glGetProgramInfoLog(program_: GLuint; bufSize: GLsizei; length: PGLsizei; infoLog: PGLchar);
begin
  if Assigned(FGLESGetProgramInfoLog) then
    FGLESGetProgramInfoLog(program_, bufSize, length, infoLog);
end;

procedure TOpenGLES_20.glGetRenderbufferParameteriv(target: GLenum; pname: GLenum; params: PGLint);
begin
  if Assigned(FGLESGetRenderbufferParameteriv) then
    FGLESGetRenderbufferParameteriv(target, pname, params);
end;

procedure TOpenGLES_20.glGetShaderiv(shader: GLuint; pname: GLenum; params: PGLint);
begin
  if Assigned(FGLESGetShaderiv) then
    FGLESGetShaderiv(shader, pname, params);
end;

procedure TOpenGLES_20.glGetShaderInfoLog(shader: GLuint; bufSize: GLsizei; length: PGLsizei; infoLog: PGLchar);
begin
  if Assigned(FGLESGetShaderInfoLog) then
    FGLESGetShaderInfoLog(shader, bufSize, length, infoLog);
end;

procedure TOpenGLES_20.glGetShaderPrecisionFormat(shadertype: GLenum; precisiontype: GLenum; range: PGLint; precision: PGLint);
begin
  if Assigned(FGLESGetShaderPrecisionFormat) then
    FGLESGetShaderPrecisionFormat(shadertype, precisiontype, range, precision);
end;

procedure TOpenGLES_20.glGetShaderSource(shader: GLuint; bufSize: GLsizei; length: PGLsizei; Source: PGLchar);
begin
  if Assigned(FGLESGetShaderSource) then
    FGLESGetShaderSource(shader, bufSize, length, Source);
end;

function TOpenGLES_20.glGetString(Name: GLenum): PGLubyte;
begin
  if Assigned(FGLESGetString) then
    Result := FGLESGetString(Name)
  else
    Result := nil;
end;

procedure TOpenGLES_20.glGetTexParameterfv(target: GLenum; pname: GLenum; params: PGLfloat);
begin
  if Assigned(FGLESGetTexParameterfv) then
    FGLESGetTexParameterfv(target, pname, params);
end;

procedure TOpenGLES_20.glGetTexParameteriv(target: GLenum; pname: GLenum; params: PGLint);
begin
  if Assigned(FGLESGetTexParameteriv) then
    FGLESGetTexParameteriv(target, pname, params);
end;

procedure TOpenGLES_20.glGetUniformfv(program_: GLuint; location: GLint; params: PGLfloat);
begin
  if Assigned(FGLESGetUniformfv) then
    FGLESGetUniformfv(program_, location, params);
end;

procedure TOpenGLES_20.glGetUniformiv(program_: GLuint; location: GLint; params: PGLint);
begin
  if Assigned(FGLESGetUniformiv) then
    FGLESGetUniformiv(program_, location, params);
end;

function TOpenGLES_20.glGetUniformLocation(program_: GLuint; const Name: PGLchar): GLint;
begin
  if Assigned(FGLESGetUniformLocation) then
    Result := FGLESGetUniformLocation(program_, Name)
  else
    Result := -1;
end;

procedure TOpenGLES_20.glGetVertexAttribfv(index: GLuint; pname: GLenum; params: PGLfloat);
begin
  if Assigned(FGLESGetVertexAttribfv) then
    FGLESGetVertexAttribfv(index, pname, params);
end;

procedure TOpenGLES_20.glGetVertexAttribiv(index: GLuint; pname: GLenum; params: PGLint);
begin
  if Assigned(FGLESGetVertexAttribiv) then
    FGLESGetVertexAttribiv(index, pname, params);
end;

procedure TOpenGLES_20.glGetVertexAttribPointerv(index: GLuint; pname: GLenum; pointer: PPointer);
begin
  if Assigned(FGLESGetVertexAttribPointerv) then
    FGLESGetVertexAttribPointerv(index, pname, pointer);
end;

procedure TOpenGLES_20.glHint(target: GLenum; mode: GLenum);
begin
  if Assigned(FGLESHint) then
    FGLESHint(target, mode);
end;

function TOpenGLES_20.glIsBuffer(buffer: GLuint): GLboolean;
begin
  if Assigned(FGLESIsBuffer) then
    Result := FGLESIsBuffer(buffer)
  else
    Result := GL_FALSE;
end;

function TOpenGLES_20.glIsEnabled(cap: GLenum): GLboolean;
begin
  if Assigned(FGLESIsEnabled) then
    Result := FGLESIsEnabled(cap)
  else
    Result := GL_FALSE;
end;

function TOpenGLES_20.glIsFramebuffer(framebuffer: GLuint): GLboolean;
begin
  if Assigned(FGLESIsFramebuffer) then
    Result := FGLESIsFramebuffer(framebuffer)
  else
    Result := GL_FALSE;
end;

function TOpenGLES_20.glIsProgram(program_: GLuint): GLboolean;
begin
  if Assigned(FGLESIsProgram) then
    Result := FGLESIsProgram(program_)
  else
    Result := GL_FALSE;
end;

function TOpenGLES_20.glIsRenderbuffer(renderbuffer: GLuint): GLboolean;
begin
  if Assigned(FGLESIsRenderbuffer) then
    Result := FGLESIsRenderbuffer(renderbuffer)
  else
    Result := GL_FALSE;
end;

function TOpenGLES_20.glIsShader(shader: GLuint): GLboolean;
begin
  if Assigned(FGLESIsShader) then
    Result := FGLESIsShader(shader)
  else
    Result := GL_FALSE;
end;

function TOpenGLES_20.glIsTexture(texture: GLuint): GLboolean;
begin
  if Assigned(FGLESIsTexture) then
    Result := FGLESIsTexture(texture)
  else
    Result := GL_FALSE;
end;

procedure TOpenGLES_20.glLineWidth(Width: GLfloat);
begin
  if Assigned(FGLESLineWidth) then
    FGLESLineWidth(Width);
end;

procedure TOpenGLES_20.glLinkProgram(program_: GLuint);
begin
  if Assigned(FGLESLinkProgram) then
    FGLESLinkProgram(program_);
end;

procedure TOpenGLES_20.glPixelStorei(pname: GLenum; param: GLint);
begin
  if Assigned(FGLESPixelStorei) then
    FGLESPixelStorei(pname, param);
end;

procedure TOpenGLES_20.glPolygonOffset(factor: GLfloat; units: GLfloat);
begin
  if Assigned(FGLESPolygonOffset) then
    FGLESPolygonOffset(factor, units);
end;

procedure TOpenGLES_20.glReadPixels(x: GLint; y: GLint; Width: GLsizei; Height: GLsizei; format: GLenum; type_: GLenum; pixels: Pointer);
begin
  if Assigned(FGLESReadPixels) then
    FGLESReadPixels(x, y, Width, Height, format, type_, pixels);
end;

procedure TOpenGLES_20.glReleaseShaderCompiler;
begin
  if Assigned(FGLESReleaseShaderCompiler) then
    FGLESReleaseShaderCompiler();
end;

procedure TOpenGLES_20.glRenderbufferStorage(target: GLenum; internalformat: GLenum; Width: GLsizei; Height: GLsizei);
begin
  if Assigned(FGLESRenderbufferStorage) then
    FGLESRenderbufferStorage(target, internalformat, Width, Height);
end;

procedure TOpenGLES_20.glSampleCoverage(Value: GLfloat; invert: GLboolean);
begin
  if Assigned(FGLESSampleCoverage) then
    FGLESSampleCoverage(Value, invert);
end;

procedure TOpenGLES_20.glScissor(x: GLint; y: GLint; Width: GLsizei; Height: GLsizei);
begin
  if Assigned(FGLESScissor) then
    FGLESScissor(x, y, Width, Height);
end;

procedure TOpenGLES_20.glShaderBinary(Count: GLsizei; const shaders: PGLuint; binaryformat: GLenum; const binary: Pointer; length: GLint);
begin
  if Assigned(FGLESShaderBinary) then
    FGLESShaderBinary(Count, shaders, binaryformat, binary, length);
end;

procedure TOpenGLES_20.glShaderSource(shader: GLuint; Count: GLsizei; const string_: PPGLchar; const length: PGLint);
begin
  if Assigned(FGLESShaderSource) then
    FGLESShaderSource(shader, Count, string_, length);
end;

procedure TOpenGLES_20.glStencilFunc(func: GLenum; ref: GLint; mask: GLuint);
begin
  if Assigned(FGLESStencilFunc) then
    FGLESStencilFunc(func, ref, mask);
end;

procedure TOpenGLES_20.glStencilFuncSeparate(face: GLenum; func: GLenum; ref: GLint; mask: GLuint);
begin
  if Assigned(FGLESStencilFuncSeparate) then
    FGLESStencilFuncSeparate(face, func, ref, mask);
end;

procedure TOpenGLES_20.glStencilMask(mask: GLuint);
begin
  if Assigned(FGLESStencilMask) then
    FGLESStencilMask(mask);
end;

procedure TOpenGLES_20.glStencilMaskSeparate(face: GLenum; mask: GLuint);
begin
  if Assigned(FGLESStencilMaskSeparate) then
    FGLESStencilMaskSeparate(face, mask);
end;

procedure TOpenGLES_20.glStencilOp(fail: GLenum; zfail: GLenum; zpass: GLenum);
begin
  if Assigned(FGLESStencilOp) then
    FGLESStencilOp(fail, zfail, zpass);
end;

procedure TOpenGLES_20.glStencilOpSeparate(face: GLenum; fail: GLenum; zfail: GLenum; zpass: GLenum);
begin
  if Assigned(FGLESStencilOpSeparate) then
    FGLESStencilOpSeparate(face, fail, zfail, zpass);
end;

procedure TOpenGLES_20.glTexImage2D(target: GLenum; level: GLint; internalformat: GLint; Width: GLsizei; Height: GLsizei; border: GLint; format: GLenum; type_: GLenum; const pixels: Pointer);
begin
  if Assigned(FGLESTexImage2D) then
    FGLESTexImage2D(target, level, internalformat, Width, Height, border, format, type_, pixels);
end;

procedure TOpenGLES_20.glTexParameterf(target: GLenum; pname: GLenum; param: GLfloat);
begin
  if Assigned(FGLESTexParameterf) then
    FGLESTexParameterf(target, pname, param);
end;

procedure TOpenGLES_20.glTexParameterfv(target: GLenum; pname: GLenum; const params: PGLfloat);
begin
  if Assigned(FGLESTexParameterfv) then
    FGLESTexParameterfv(target, pname, params);
end;

procedure TOpenGLES_20.glTexParameteri(target: GLenum; pname: GLenum; param: GLint);
begin
  if Assigned(FGLESTexParameteri) then
    FGLESTexParameteri(target, pname, param);
end;

procedure TOpenGLES_20.glTexParameteriv(target: GLenum; pname: GLenum; const params: PGLint);
begin
  if Assigned(FGLESTexParameteriv) then
    FGLESTexParameteriv(target, pname, params);
end;

procedure TOpenGLES_20.glTexSubImage2D(target: GLenum; level: GLint; xoffset: GLint; yoffset: GLint; Width: GLsizei; Height: GLsizei; format: GLenum; type_: GLenum; const pixels: Pointer);
begin
  if Assigned(FGLESTexSubImage2D) then
    FGLESTexSubImage2D(target, level, xoffset, yoffset, Width, Height, format, type_, pixels);
end;

procedure TOpenGLES_20.glUniform1f(location: GLint; v0: GLfloat);
begin
  if Assigned(FGLESUniform1f) then
    FGLESUniform1f(location, v0);
end;

procedure TOpenGLES_20.glUniform1fv(location: GLint; Count: GLsizei; const Value: PGLfloat);
begin
  if Assigned(FGLESUniform1fv) then
    FGLESUniform1fv(location, Count, Value);
end;

procedure TOpenGLES_20.glUniform1i(location: GLint; v0: GLint);
begin
  if Assigned(FGLESUniform1i) then
    FGLESUniform1i(location, v0);
end;

procedure TOpenGLES_20.glUniform1iv(location: GLint; Count: GLsizei; const Value: PGLint);
begin
  if Assigned(FGLESUniform1iv) then
    FGLESUniform1iv(location, Count, Value);
end;

procedure TOpenGLES_20.glUniform2f(location: GLint; v0: GLfloat; v1: GLfloat);
begin
  if Assigned(FGLESUniform2f) then
    FGLESUniform2f(location, v0, v1);
end;

procedure TOpenGLES_20.glUniform2fv(location: GLint; Count: GLsizei; const Value: PGLfloat);
begin
  if Assigned(FGLESUniform2fv) then
    FGLESUniform2fv(location, Count, Value);
end;

procedure TOpenGLES_20.glUniform2i(location: GLint; v0: GLint; v1: GLint);
begin
  if Assigned(FGLESUniform2i) then
    FGLESUniform2i(location, v0, v1);
end;

procedure TOpenGLES_20.glUniform2iv(location: GLint; Count: GLsizei; const Value: PGLint);
begin
  if Assigned(FGLESUniform2iv) then
    FGLESUniform2iv(location, Count, Value);
end;

procedure TOpenGLES_20.glUniform3f(location: GLint; v0: GLfloat; v1: GLfloat; v2: GLfloat);
begin
  if Assigned(FGLESUniform3f) then
    FGLESUniform3f(location, v0, v1, v2);
end;

procedure TOpenGLES_20.glUniform3fv(location: GLint; Count: GLsizei; const Value: PGLfloat);
begin
  if Assigned(FGLESUniform3fv) then
    FGLESUniform3fv(location, Count, Value);
end;

procedure TOpenGLES_20.glUniform3i(location: GLint; v0: GLint; v1: GLint; v2: GLint);
begin
  if Assigned(FGLESUniform3i) then
    FGLESUniform3i(location, v0, v1, v2);
end;

procedure TOpenGLES_20.glUniform3iv(location: GLint; Count: GLsizei; const Value: PGLint);
begin
  if Assigned(FGLESUniform3iv) then
    FGLESUniform3iv(location, Count, Value);
end;

procedure TOpenGLES_20.glUniform4f(location: GLint; v0: GLfloat; v1: GLfloat; v2: GLfloat; v3: GLfloat);
begin
  if Assigned(FGLESUniform4f) then
    FGLESUniform4f(location, v0, v1, v2, v3);
end;

procedure TOpenGLES_20.glUniform4fv(location: GLint; Count: GLsizei; const Value: PGLfloat);
begin
  if Assigned(FGLESUniform4fv) then
    FGLESUniform4fv(location, Count, Value);
end;

procedure TOpenGLES_20.glUniform4i(location: GLint; v0: GLint; v1: GLint; v2: GLint; v3: GLint);
begin
  if Assigned(FGLESUniform4i) then
    FGLESUniform4i(location, v0, v1, v2, v3);
end;

procedure TOpenGLES_20.glUniform4iv(location: GLint; Count: GLsizei; const Value: PGLint);
begin
  if Assigned(FGLESUniform4iv) then
    FGLESUniform4iv(location, Count, Value);
end;

procedure TOpenGLES_20.glUniformMatrix2fv(location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat);
begin
  if Assigned(FGLESUniformMatrix2fv) then
    FGLESUniformMatrix2fv(location, Count, transpose, Value);
end;

procedure TOpenGLES_20.glUniformMatrix3fv(location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat);
begin
  if Assigned(FGLESUniformMatrix3fv) then
    FGLESUniformMatrix3fv(location, Count, transpose, Value);
end;

procedure TOpenGLES_20.glUniformMatrix4fv(location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat);
begin
  if Assigned(FGLESUniformMatrix4fv) then
    FGLESUniformMatrix4fv(location, Count, transpose, Value);
end;

procedure TOpenGLES_20.glUseProgram(program_: GLuint);
begin
  if Assigned(FGLESUseProgram) then
    FGLESUseProgram(program_);
end;

procedure TOpenGLES_20.glValidateProgram(program_: GLuint);
begin
  if Assigned(FGLESValidateProgram) then
    FGLESValidateProgram(program_);
end;

procedure TOpenGLES_20.glVertexAttrib1f(index: GLuint; x: GLfloat);
begin
  if Assigned(FGLESVertexAttrib1f) then
    FGLESVertexAttrib1f(index, x);
end;

procedure TOpenGLES_20.glVertexAttrib1fv(index: GLuint; const v: PGLfloat);
begin
  if Assigned(FGLESVertexAttrib1fv) then
    FGLESVertexAttrib1fv(index, v);
end;

procedure TOpenGLES_20.glVertexAttrib2f(index: GLuint; x: GLfloat; y: GLfloat);
begin
  if Assigned(FGLESVertexAttrib2f) then
    FGLESVertexAttrib2f(index, x, y);
end;

procedure TOpenGLES_20.glVertexAttrib2fv(index: GLuint; const v: PGLfloat);
begin
  if Assigned(FGLESVertexAttrib2fv) then
    FGLESVertexAttrib2fv(index, v);
end;

procedure TOpenGLES_20.glVertexAttrib3f(index: GLuint; x: GLfloat; y: GLfloat; z: GLfloat);
begin
  if Assigned(FGLESVertexAttrib3f) then
    FGLESVertexAttrib3f(index, x, y, z);
end;

procedure TOpenGLES_20.glVertexAttrib3fv(index: GLuint; const v: PGLfloat);
begin
  if Assigned(FGLESVertexAttrib3fv) then
    FGLESVertexAttrib3fv(index, v);
end;

procedure TOpenGLES_20.glVertexAttrib4f(index: GLuint; x: GLfloat; y: GLfloat; z: GLfloat; w: GLfloat);
begin
  if Assigned(FGLESVertexAttrib4f) then
    FGLESVertexAttrib4f(index, x, y, z, w);
end;

procedure TOpenGLES_20.glVertexAttrib4fv(index: GLuint; const v: PGLfloat);
begin
  if Assigned(FGLESVertexAttrib4fv) then
    FGLESVertexAttrib4fv(index, v);
end;

procedure TOpenGLES_20.glVertexAttribPointer(index: GLuint; size: GLint; type_: GLenum; normalized: GLboolean; stride: GLsizei; const pointer: Pointer);
begin
  if Assigned(FGLESVertexAttribPointer) then
    FGLESVertexAttribPointer(index, size, type_, normalized, stride, pointer);
end;

procedure TOpenGLES_20.glViewport(x: GLint; y: GLint; Width: GLsizei; Height: GLsizei);
begin
  if Assigned(FGLESViewport) then
    FGLESViewport(x, y, Width, Height);
end;

{ TOpenGLES_3_0 }

procedure TOpenGLES_3_0.bindEntry;
begin
  inherited bindEntry;

  // Vertex Array Objects (VAO)
  Bind(Pointer(FGLESBindVertexArray), 'glBindVertexArray');
  Bind(Pointer(FGLESDeleteVertexArrays), 'glDeleteVertexArrays');
  Bind(Pointer(FGLESGenVertexArrays), 'glGenVertexArrays');
  Bind(Pointer(FGLESIsVertexArray), 'glIsVertexArray');

  // Instanced Rendering
  Bind(Pointer(FGLESDrawArraysInstanced), 'glDrawArraysInstanced');
  Bind(Pointer(FGLESDrawElementsInstanced), 'glDrawElementsInstanced');
  Bind(Pointer(FGLESVertexAttribDivisor), 'glVertexAttribDivisor');

  // Immutable Texture Storage
  Bind(Pointer(FGLESTexStorage2D), 'glTexStorage2D');
  Bind(Pointer(FGLESTexStorage3D), 'glTexStorage3D');

  // Enhanced Buffer Mapping
  Bind(Pointer(FGLESMapBufferRange), 'glMapBufferRange');
  Bind(Pointer(FGLESFlushMappedBufferRange), 'glFlushMappedBufferRange');
  Bind(Pointer(FGLESUnmapBuffer), 'glUnmapBuffer');

  // Uniform Buffer Objects (UBO)
  Bind(Pointer(FGLESBindBufferBase), 'glBindBufferBase');
  Bind(Pointer(FGLESBindBufferRange), 'glBindBufferRange');
  Bind(Pointer(FGLESGetUniformBlockIndex), 'glGetUniformBlockIndex');
  Bind(Pointer(FGLESGetActiveUniformBlockiv), 'glGetActiveUniformBlockiv');
  Bind(Pointer(FGLESGetActiveUniformBlockName), 'glGetActiveUniformBlockName');
  Bind(Pointer(FGLESUniformBlockBinding), 'glUniformBlockBinding');
  Bind(Pointer(FGLESGetUniformIndices), 'glGetUniformIndices');
  Bind(Pointer(FGLESGetActiveUniformsiv), 'glGetActiveUniformsiv');

  // Transform Feedback (buffer binding only)
  Bind(Pointer(FGLESBindTransformFeedback), 'glBindTransformFeedback');
  Bind(Pointer(FGLESDeleteTransformFeedbacks), 'glDeleteTransformFeedbacks');
  Bind(Pointer(FGLESGenTransformFeedbacks), 'glGenTransformFeedbacks');
  Bind(Pointer(FGLESIsTransformFeedback), 'glIsTransformFeedback');
  Bind(Pointer(FGLESPauseTransformFeedback), 'glPauseTransformFeedback');
  Bind(Pointer(FGLESResumeTransformFeedback), 'glResumeTransformFeedback');

  // Sampler Objects
  Bind(Pointer(FGLESGenSamplers), 'glGenSamplers');
  Bind(Pointer(FGLESDeleteSamplers), 'glDeleteSamplers');
  Bind(Pointer(FGLESIsSampler), 'glIsSampler');
  Bind(Pointer(FGLESBindSampler), 'glBindSampler');
  Bind(Pointer(FGLESSamplerParameteri), 'glSamplerParameteri');
  Bind(Pointer(FGLESSamplerParameteriv), 'glSamplerParameteriv');
  Bind(Pointer(FGLESSamplerParameterf), 'glSamplerParameterf');
  Bind(Pointer(FGLESSamplerParameterfv), 'glSamplerParameterfv');
  Bind(Pointer(FGLESSamplerParameterIiv), 'glSamplerParameterIiv');
  Bind(Pointer(FGLESSamplerParameterIuiv), 'glSamplerParameterIuiv');
  Bind(Pointer(FGLESGetSamplerParameteriv), 'glGetSamplerParameteriv');
  Bind(Pointer(FGLESGetSamplerParameterIiv), 'glGetSamplerParameterIiv');
  Bind(Pointer(FGLESGetSamplerParameterfv), 'glGetSamplerParameterfv');
  Bind(Pointer(FGLESGetSamplerParameterIuiv), 'glGetSamplerParameterIuiv');

  // Sync Objects
  Bind(Pointer(FGLESFenceSync), 'glFenceSync');
  Bind(Pointer(FGLESIsSync), 'glIsSync');
  Bind(Pointer(FGLESDeleteSync), 'glDeleteSync');
  Bind(Pointer(FGLESClientWaitSync), 'glClientWaitSync');
  Bind(Pointer(FGLESWaitSync), 'glWaitSync');
  Bind(Pointer(FGLESGetSynciv), 'glGetSynciv');
  Bind(Pointer(FGLESGetInteger64v), 'glGetInteger64v');
  Bind(Pointer(FGLESGetInteger64i_v), 'glGetInteger64i_v');

  // Texture 3D & Enhanced Formats
  Bind(Pointer(FGLESTexImage3D), 'glTexImage3D');
  Bind(Pointer(FGLESTexSubImage3D), 'glTexSubImage3D');
  Bind(Pointer(FGLESCopyTexSubImage3D), 'glCopyTexSubImage3D');
  Bind(Pointer(FGLESCompressedTexImage3D), 'glCompressedTexImage3D');
  Bind(Pointer(FGLESCompressedTexSubImage3D), 'glCompressedTexSubImage3D');

  // Multisample Renderbuffers & Layered FBO
  Bind(Pointer(FGLESRenderbufferStorageMultisample), 'glRenderbufferStorageMultisample');
  Bind(Pointer(FGLESFramebufferTextureLayer), 'glFramebufferTextureLayer');

  // Blit Framebuffer
  Bind(Pointer(FGLESBlitFramebuffer), 'glBlitFramebuffer');

  // Invalidate Framebuffer
  Bind(Pointer(FGLESInvalidateFramebuffer), 'glInvalidateFramebuffer');
  Bind(Pointer(FGLESInvalidateSubFramebuffer), 'glInvalidateSubFramebuffer');

  // Primitive Restart
  Bind(Pointer(FGLESPrimitiveRestartIndex), 'glPrimitiveRestartIndex');

  // Enhanced Queries
  Bind(Pointer(FGLESBeginQuery), 'glBeginQuery');
  Bind(Pointer(FGLESEndQuery), 'glEndQuery');
  Bind(Pointer(FGLESGenQueries), 'glGenQueries');
  Bind(Pointer(FGLESDeleteQueries), 'glDeleteQueries');
  Bind(Pointer(FGLESIsQuery), 'glIsQuery');
  Bind(Pointer(FGLESGetQueryiv), 'glGetQueryiv');
  Bind(Pointer(FGLESGetQueryObjectuiv), 'glGetQueryObjectuiv');
  Bind(Pointer(FGLESGetQueryObjectui64v), 'glGetQueryObjectui64v');

  // Enhanced Clear
  Bind(Pointer(FGLESClearBufferfv), 'glClearBufferfv');
  Bind(Pointer(FGLESClearBufferiv), 'glClearBufferiv');
  Bind(Pointer(FGLESClearBufferuiv), 'glClearBufferuiv');
  Bind(Pointer(FGLESClearBufferfi), 'glClearBufferfi');

  // New Data Type Queries
  Bind(Pointer(FGLESGetBufferParameteri64v), 'glGetBufferParameteri64v');
  Bind(Pointer(FGLESGetIntegeri_v), 'glGetIntegeri_v');
  Bind(Pointer(FGLESGetFloati_v), 'glGetFloati_v');
  Bind(Pointer(FGLESGetDoublei_v), 'glGetDoublei_v');

  // Copy Buffer SubData
  Bind(Pointer(FGLESCopyBufferSubData), 'glCopyBufferSubData');

  // Check Framebuffer Status (già in 2.0 ma con nuovi valori)
  Bind(Pointer(FGLESCheckFramebufferStatus), 'glCheckFramebufferStatus');
end;

{ TOpenGLES_3_0 – Implementazione completa dei metodi pubblici di IGLES_3_0 }

procedure TOpenGLES_3_0.glBindVertexArray(array_: GLuint);
begin
  if Assigned(FGLESBindVertexArray) then
    FGLESBindVertexArray(array_);
end;

procedure TOpenGLES_3_0.glDeleteVertexArrays(n: GLsizei; const arrays: PGLuint);
begin
  if Assigned(FGLESDeleteVertexArrays) then
    FGLESDeleteVertexArrays(n, arrays);
end;

procedure TOpenGLES_3_0.glGenVertexArrays(n: GLsizei; arrays: PGLuint);
begin
  if Assigned(FGLESGenVertexArrays) then
    FGLESGenVertexArrays(n, arrays);
end;

function TOpenGLES_3_0.glIsVertexArray(array_: GLuint): GLboolean;
begin
  if Assigned(FGLESIsVertexArray) then
    Result := FGLESIsVertexArray(array_)
  else
    Result := GL_FALSE;
end;

procedure TOpenGLES_3_0.glDrawArraysInstanced(mode: GLenum; First: GLint; Count: GLsizei; instancecount: GLsizei);
begin
  if Assigned(FGLESDrawArraysInstanced) then
    FGLESDrawArraysInstanced(mode, First, Count, instancecount);
end;

procedure TOpenGLES_3_0.glDrawElementsInstanced(mode: GLenum; Count: GLsizei; type_: GLenum; const indices: Pointer; instancecount: GLsizei);
begin
  if Assigned(FGLESDrawElementsInstanced) then
    FGLESDrawElementsInstanced(mode, Count, type_, indices, instancecount);
end;

procedure TOpenGLES_3_0.glVertexAttribDivisor(index: GLuint; divisor: GLuint);
begin
  if Assigned(FGLESVertexAttribDivisor) then
    FGLESVertexAttribDivisor(index, divisor);
end;

procedure TOpenGLES_3_0.glTexStorage2D(target: GLenum; levels: GLsizei; internalformat: GLenum; Width: GLsizei; Height: GLsizei);
begin
  if Assigned(FGLESTexStorage2D) then
    FGLESTexStorage2D(target, levels, internalformat, Width, Height);
end;

procedure TOpenGLES_3_0.glTexStorage3D(target: GLenum; levels: GLsizei; internalformat: GLenum; Width: GLsizei; Height: GLsizei; depth: GLsizei);
begin
  if Assigned(FGLESTexStorage3D) then
    FGLESTexStorage3D(target, levels, internalformat, Width, Height, depth);
end;

function TOpenGLES_3_0.glMapBufferRange(target: GLenum; offset: GLintptr; length: GLsizeiptr; access: GLbitfield): Pointer;
begin
  if Assigned(FGLESMapBufferRange) then
    Result := FGLESMapBufferRange(target, offset, length, access)
  else
    Result := nil;
end;

procedure TOpenGLES_3_0.glFlushMappedBufferRange(target: GLenum; offset: GLintptr; length: GLsizeiptr);
begin
  if Assigned(FGLESFlushMappedBufferRange) then
    FGLESFlushMappedBufferRange(target, offset, length);
end;

function TOpenGLES_3_0.glUnmapBuffer(target: GLenum): GLboolean;
begin
  if Assigned(FGLESUnmapBuffer) then
    Result := FGLESUnmapBuffer(target)
  else
    Result := GL_FALSE;
end;

procedure TOpenGLES_3_0.glBindBufferBase(target: GLenum; index: GLuint; buffer: GLuint);
begin
  if Assigned(FGLESBindBufferBase) then
    FGLESBindBufferBase(target, index, buffer);
end;

procedure TOpenGLES_3_0.glBindBufferRange(target: GLenum; index: GLuint; buffer: GLuint; offset: GLintptr; size: GLsizeiptr);
begin
  if Assigned(FGLESBindBufferRange) then
    FGLESBindBufferRange(target, index, buffer, offset, size);
end;

function TOpenGLES_3_0.glGetUniformBlockIndex(program_: GLuint; const uniformBlockName: PGLchar): GLuint;
begin
  if Assigned(FGLESGetUniformBlockIndex) then
    Result := FGLESGetUniformBlockIndex(program_, uniformBlockName)
  else
    Result := GL_INVALID_INDEX;
end;

procedure TOpenGLES_3_0.glGetActiveUniformBlockiv(program_: GLuint; uniformBlockIndex: GLuint; pname: GLenum; params: PGLint);
begin
  if Assigned(FGLESGetActiveUniformBlockiv) then
    FGLESGetActiveUniformBlockiv(program_, uniformBlockIndex, pname, params);
end;

procedure TOpenGLES_3_0.glGetActiveUniformBlockName(program_: GLuint; uniformBlockIndex: GLuint; bufSize: GLsizei; length: PGLsizei; uniformBlockName: PGLchar);
begin
  if Assigned(FGLESGetActiveUniformBlockName) then
    FGLESGetActiveUniformBlockName(program_, uniformBlockIndex, bufSize, length, uniformBlockName);
end;

procedure TOpenGLES_3_0.glUniformBlockBinding(program_: GLuint; uniformBlockIndex: GLuint; uniformBlockBinding: GLuint);
begin
  if Assigned(FGLESUniformBlockBinding) then
    FGLESUniformBlockBinding(program_, uniformBlockIndex, uniformBlockBinding);
end;

procedure TOpenGLES_3_0.glGetUniformIndices(program_: GLuint; uniformCount: GLsizei; const uniformNames: PPGLchar; uniformIndices: PGLuint);
begin
  if Assigned(FGLESGetUniformIndices) then
    FGLESGetUniformIndices(program_, uniformCount, uniformNames, uniformIndices);
end;

procedure TOpenGLES_3_0.glGetActiveUniformsiv(program_: GLuint; uniformCount: GLsizei; const uniformIndices: PGLuint; pname: GLenum; params: PGLint);
begin
  if Assigned(FGLESGetActiveUniformsiv) then
    FGLESGetActiveUniformsiv(program_, uniformCount, uniformIndices, pname, params);
end;

procedure TOpenGLES_3_0.glBindTransformFeedback(target: GLenum; id: GLuint);
begin
  if Assigned(FGLESBindTransformFeedback) then
    FGLESBindTransformFeedback(target, id);
end;

procedure TOpenGLES_3_0.glDeleteTransformFeedbacks(n: GLsizei; const ids: PGLuint);
begin
  if Assigned(FGLESDeleteTransformFeedbacks) then
    FGLESDeleteTransformFeedbacks(n, ids);
end;

procedure TOpenGLES_3_0.glGenTransformFeedbacks(n: GLsizei; ids: PGLuint);
begin
  if Assigned(FGLESGenTransformFeedbacks) then
    FGLESGenTransformFeedbacks(n, ids);
end;

function TOpenGLES_3_0.glIsTransformFeedback(id: GLuint): GLboolean;
begin
  if Assigned(FGLESIsTransformFeedback) then
    Result := FGLESIsTransformFeedback(id)
  else
    Result := GL_FALSE;
end;

procedure TOpenGLES_3_0.glPauseTransformFeedback;
begin
  if Assigned(FGLESPauseTransformFeedback) then
    FGLESPauseTransformFeedback();
end;

procedure TOpenGLES_3_0.glResumeTransformFeedback;
begin
  if Assigned(FGLESResumeTransformFeedback) then
    FGLESResumeTransformFeedback();
end;

procedure TOpenGLES_3_0.glGenSamplers(Count: GLsizei; samplers: PGLuint);
begin
  if Assigned(FGLESGenSamplers) then
    FGLESGenSamplers(Count, samplers);
end;

procedure TOpenGLES_3_0.glDeleteSamplers(Count: GLsizei; const samplers: PGLuint);
begin
  if Assigned(FGLESDeleteSamplers) then
    FGLESDeleteSamplers(Count, samplers);
end;

function TOpenGLES_3_0.glIsSampler(sampler: GLuint): GLboolean;
begin
  if Assigned(FGLESIsSampler) then
    Result := FGLESIsSampler(sampler)
  else
    Result := GL_FALSE;
end;

procedure TOpenGLES_3_0.glBindSampler(unit_: GLuint; sampler: GLuint);
begin
  if Assigned(FGLESBindSampler) then
    FGLESBindSampler(unit_, sampler);
end;

procedure TOpenGLES_3_0.glSamplerParameteri(sampler: GLuint; pname: GLenum; param: GLint);
begin
  if Assigned(FGLESSamplerParameteri) then
    FGLESSamplerParameteri(sampler, pname, param);
end;

procedure TOpenGLES_3_0.glSamplerParameteriv(sampler: GLuint; pname: GLenum; const param: PGLint);
begin
  if Assigned(FGLESSamplerParameteriv) then
    FGLESSamplerParameteriv(sampler, pname, param);
end;

procedure TOpenGLES_3_0.glSamplerParameterf(sampler: GLuint; pname: GLenum; param: GLfloat);
begin
  if Assigned(FGLESSamplerParameterf) then
    FGLESSamplerParameterf(sampler, pname, param);
end;

procedure TOpenGLES_3_0.glSamplerParameterfv(sampler: GLuint; pname: GLenum; const param: PGLfloat);
begin
  if Assigned(FGLESSamplerParameterfv) then
    FGLESSamplerParameterfv(sampler, pname, param);
end;

procedure TOpenGLES_3_0.glSamplerParameterIiv(sampler: GLuint; pname: GLenum; const param: PGLint);
begin
  if Assigned(FGLESSamplerParameterIiv) then
    FGLESSamplerParameterIiv(sampler, pname, param);
end;

procedure TOpenGLES_3_0.glSamplerParameterIuiv(sampler: GLuint; pname: GLenum; const param: PGLuint);
begin
  if Assigned(FGLESSamplerParameterIuiv) then
    FGLESSamplerParameterIuiv(sampler, pname, param);
end;

procedure TOpenGLES_3_0.glGetSamplerParameteriv(sampler: GLuint; pname: GLenum; params: PGLint);
begin
  if Assigned(FGLESGetSamplerParameteriv) then
    FGLESGetSamplerParameteriv(sampler, pname, params);
end;

procedure TOpenGLES_3_0.glGetSamplerParameterIiv(sampler: GLuint; pname: GLenum; params: PGLint);
begin
  if Assigned(FGLESGetSamplerParameterIiv) then
    FGLESGetSamplerParameterIiv(sampler, pname, params);
end;

procedure TOpenGLES_3_0.glGetSamplerParameterfv(sampler: GLuint; pname: GLenum; params: PGLfloat);
begin
  if Assigned(FGLESGetSamplerParameterfv) then
    FGLESGetSamplerParameterfv(sampler, pname, params);
end;

procedure TOpenGLES_3_0.glGetSamplerParameterIuiv(sampler: GLuint; pname: GLenum; params: PGLuint);
begin
  if Assigned(FGLESGetSamplerParameterIuiv) then
    FGLESGetSamplerParameterIuiv(sampler, pname, params);
end;

function TOpenGLES_3_0.glFenceSync(condition: GLenum; flags: GLbitfield): GLsync;
begin
  if Assigned(FGLESFenceSync) then
    Result := FGLESFenceSync(condition, flags)
  else
    Result := nil;
end;

function TOpenGLES_3_0.glIsSync(sync: GLsync): GLboolean;
begin
  if Assigned(FGLESIsSync) then
    Result := FGLESIsSync(sync)
  else
    Result := GL_FALSE;
end;

procedure TOpenGLES_3_0.glDeleteSync(sync: GLsync);
begin
  if Assigned(FGLESDeleteSync) then
    FGLESDeleteSync(sync);
end;

function TOpenGLES_3_0.glClientWaitSync(sync: GLsync; flags: GLbitfield; timeout: GLuint64): GLenum;
begin
  if Assigned(FGLESClientWaitSync) then
    Result := FGLESClientWaitSync(sync, flags, timeout)
  else
    Result := GL_TIMEOUT_EXPIRED;
end;

procedure TOpenGLES_3_0.glWaitSync(sync: GLsync; flags: GLbitfield; timeout: GLuint64);
begin
  if Assigned(FGLESWaitSync) then
    FGLESWaitSync(sync, flags, timeout);
end;

procedure TOpenGLES_3_0.glGetSynciv(sync: GLsync; pname: GLenum; bufSize: GLsizei; length: PGLsizei; values: PGLint);
begin
  if Assigned(FGLESGetSynciv) then
    FGLESGetSynciv(sync, pname, bufSize, length, values);
end;

procedure TOpenGLES_3_0.glGetInteger64v(pname: GLenum; Data: PGLint64);
begin
  if Assigned(FGLESGetInteger64v) then
    FGLESGetInteger64v(pname, Data);
end;

procedure TOpenGLES_3_0.glGetInteger64i_v(pname: GLenum; index: GLuint; Data: PGLint64);
begin
  if Assigned(FGLESGetInteger64i_v) then
    FGLESGetInteger64i_v(pname, index, Data);
end;

procedure TOpenGLES_3_0.glTexImage3D(target: GLenum; level: GLint; internalformat: GLint; Width, Height, depth: GLsizei; border: GLint; format, type_: GLenum; const pixels: Pointer);
begin
  if Assigned(FGLESTexImage3D) then
    FGLESTexImage3D(target, level, internalformat, Width, Height, depth, border, format, type_, pixels);
end;

procedure TOpenGLES_3_0.glTexSubImage3D(target: GLenum; level: GLint; xoffset, yoffset, zoffset: GLint; Width, Height, depth: GLsizei; format, type_: GLenum; const pixels: Pointer);
begin
  if Assigned(FGLESTexSubImage3D) then
    FGLESTexSubImage3D(target, level, xoffset, yoffset, zoffset, Width, Height, depth, format, type_, pixels);
end;

procedure TOpenGLES_3_0.glCopyTexSubImage3D(target: GLenum; level: GLint; xoffset, yoffset, zoffset: GLint; x, y: GLint; Width, Height: GLsizei);
begin
  if Assigned(FGLESCopyTexSubImage3D) then
    FGLESCopyTexSubImage3D(target, level, xoffset, yoffset, zoffset, x, y, Width, Height);
end;

procedure TOpenGLES_3_0.glCompressedTexImage3D(target: GLenum; level: GLint; internalformat: GLenum; Width, Height, depth: GLsizei; border: GLint; imageSize: GLsizei; const Data: Pointer);
begin
  if Assigned(FGLESCompressedTexImage3D) then
    FGLESCompressedTexImage3D(target, level, internalformat, Width, Height, depth, border, imageSize, Data);
end;

procedure TOpenGLES_3_0.glCompressedTexSubImage3D(target: GLenum; level: GLint; xoffset, yoffset, zoffset: GLint; Width, Height, depth: GLsizei; format: GLenum; imageSize: GLsizei; const Data: Pointer);
begin
  if Assigned(FGLESCompressedTexSubImage3D) then
    FGLESCompressedTexSubImage3D(target, level, xoffset, yoffset, zoffset, Width, Height, depth, format, imageSize, Data);
end;

procedure TOpenGLES_3_0.glRenderbufferStorageMultisample(target: GLenum; samples: GLsizei; internalformat: GLenum; Width, Height: GLsizei);
begin
  if Assigned(FGLESRenderbufferStorageMultisample) then
    FGLESRenderbufferStorageMultisample(target, samples, internalformat, Width, Height);
end;

procedure TOpenGLES_3_0.glFramebufferTextureLayer(target: GLenum; attachment: GLenum; texture: GLuint; level: GLint; layer: GLint);
begin
  if Assigned(FGLESFramebufferTextureLayer) then
    FGLESFramebufferTextureLayer(target, attachment, texture, level, layer);
end;

procedure TOpenGLES_3_0.glBlitFramebuffer(srcX0, srcY0, srcX1, srcY1, dstX0, dstY0, dstX1, dstY1: GLint; mask: GLbitfield; filter: GLenum);
begin
  if Assigned(FGLESBlitFramebuffer) then
    FGLESBlitFramebuffer(srcX0, srcY0, srcX1, srcY1, dstX0, dstY0, dstX1, dstY1, mask, filter);
end;

procedure TOpenGLES_3_0.glInvalidateFramebuffer(target: GLenum; numAttachments: GLsizei; const attachments: PGLenum);
begin
  if Assigned(FGLESInvalidateFramebuffer) then
    FGLESInvalidateFramebuffer(target, numAttachments, attachments);
end;

procedure TOpenGLES_3_0.glInvalidateSubFramebuffer(target: GLenum; numAttachments: GLsizei; const attachments: PGLenum; x, y: GLint; Width, Height: GLsizei);
begin
  if Assigned(FGLESInvalidateSubFramebuffer) then
    FGLESInvalidateSubFramebuffer(target, numAttachments, attachments, x, y, Width, Height);
end;

procedure TOpenGLES_3_0.glPrimitiveRestartIndex(index: GLuint);
begin
  if Assigned(FGLESPrimitiveRestartIndex) then
    FGLESPrimitiveRestartIndex(index);
end;

procedure TOpenGLES_3_0.glBeginQuery(target: GLenum; id: GLuint);
begin
  if Assigned(FGLESBeginQuery) then
    FGLESBeginQuery(target, id);
end;

procedure TOpenGLES_3_0.glEndQuery(target: GLenum);
begin
  if Assigned(FGLESEndQuery) then
    FGLESEndQuery(target);
end;

procedure TOpenGLES_3_0.glGenQueries(n: GLsizei; ids: PGLuint);
begin
  if Assigned(FGLESGenQueries) then
    FGLESGenQueries(n, ids);
end;

procedure TOpenGLES_3_0.glDeleteQueries(n: GLsizei; const ids: PGLuint);
begin
  if Assigned(FGLESDeleteQueries) then
    FGLESDeleteQueries(n, ids);
end;

function TOpenGLES_3_0.glIsQuery(id: GLuint): GLboolean;
begin
  if Assigned(FGLESIsQuery) then
    Result := FGLESIsQuery(id)
  else
    Result := GL_FALSE;
end;

procedure TOpenGLES_3_0.glGetQueryiv(target: GLenum; pname: GLenum; params: PGLint);
begin
  if Assigned(FGLESGetQueryiv) then
    FGLESGetQueryiv(target, pname, params);
end;

procedure TOpenGLES_3_0.glGetQueryObjectuiv(id: GLuint; pname: GLenum; params: PGLuint);
begin
  if Assigned(FGLESGetQueryObjectuiv) then
    FGLESGetQueryObjectuiv(id, pname, params);
end;

procedure TOpenGLES_3_0.glGetQueryObjectui64v(id: GLuint; pname: GLenum; params: PGLuint64);
begin
  if Assigned(FGLESGetQueryObjectui64v) then
    FGLESGetQueryObjectui64v(id, pname, params);
end;

procedure TOpenGLES_3_0.glClearBufferfv(buffer: GLenum; drawbuffer: GLint; const Value: PGLfloat);
begin
  if Assigned(FGLESClearBufferfv) then
    FGLESClearBufferfv(buffer, drawbuffer, Value);
end;

procedure TOpenGLES_3_0.glClearBufferiv(buffer: GLenum; drawbuffer: GLint; const Value: PGLint);
begin
  if Assigned(FGLESClearBufferiv) then
    FGLESClearBufferiv(buffer, drawbuffer, Value);
end;

procedure TOpenGLES_3_0.glClearBufferuiv(buffer: GLenum; drawbuffer: GLint; const Value: PGLuint);
begin
  if Assigned(FGLESClearBufferuiv) then
    FGLESClearBufferuiv(buffer, drawbuffer, Value);
end;

procedure TOpenGLES_3_0.glClearBufferfi(buffer: GLenum; drawbuffer: GLint; depth: GLfloat; stencil: GLint);
begin
  if Assigned(FGLESClearBufferfi) then
    FGLESClearBufferfi(buffer, drawbuffer, depth, stencil);
end;

procedure TOpenGLES_3_0.glGetBufferParameteri64v(target: GLenum; pname: GLenum; params: PGLint64);
begin
  if Assigned(FGLESGetBufferParameteri64v) then
    FGLESGetBufferParameteri64v(target, pname, params);
end;

procedure TOpenGLES_3_0.glGetIntegeri_v(target: GLenum; index: GLuint; Data: PGLint);
begin
  if Assigned(FGLESGetIntegeri_v) then
    FGLESGetIntegeri_v(target, index, Data);
end;

procedure TOpenGLES_3_0.glGetFloati_v(target: GLenum; index: GLuint; Data: PGLfloat);
begin
  if Assigned(FGLESGetFloati_v) then
    FGLESGetFloati_v(target, index, Data);
end;

procedure TOpenGLES_3_0.glGetDoublei_v(target: GLenum; index: GLuint; Data: PGLdouble);
begin
  if Assigned(FGLESGetDoublei_v) then
    FGLESGetDoublei_v(target, index, Data);
end;

procedure TOpenGLES_3_0.glCopyBufferSubData(readTarget, writeTarget: GLenum; readOffset, writeOffset: GLintptr; size: GLsizeiptr);
begin
  if Assigned(FGLESCopyBufferSubData) then
    FGLESCopyBufferSubData(readTarget, writeTarget, readOffset, writeOffset, size);
end;


{ TOpenGLES_3_1 }

procedure TOpenGLES_3_1.bindEntry;
begin
  inherited bindEntry;
  // Compute Shaders
  Bind(Pointer(FGLESDispatchCompute), 'glDispatchCompute');
  Bind(Pointer(FGLESDispatchComputeIndirect), 'glDispatchComputeIndirect');
  // Shader Storage Buffer Objects (SSBO)
  Bind(Pointer(FGLESShaderStorageBlockBinding), 'glShaderStorageBlockBinding');
  // Atomic Counter Buffers
  Bind(Pointer(FGLESGetActiveAtomicCounterBufferiv), 'glGetActiveAtomicCounterBufferiv');
  // Image Load/Store
  Bind(Pointer(FGLESBindImageTexture), 'glBindImageTexture');
  Bind(Pointer(FGLESMemoryBarrier), 'glMemoryBarrier');
  // Program Interface Query
  Bind(Pointer(FGLESGetProgramInterfaceiv), 'glGetProgramInterfaceiv');
  Bind(Pointer(FGLESGetProgramResourceIndex), 'glGetProgramResourceIndex');
  Bind(Pointer(FGLESGetProgramResourceLocation), 'glGetProgramResourceLocation');
  Bind(Pointer(FGLESGetProgramResourceLocationIndex), 'glGetProgramResourceLocationIndex');
  Bind(Pointer(FGLESGetProgramResourceName), 'glGetProgramResourceName');
  Bind(Pointer(FGLESGetProgramResourceiv), 'glGetProgramResourceiv');
  // Separate Shader Objects / Program Pipelines
  Bind(Pointer(FGLESUseProgramStages), 'glUseProgramStages');
  Bind(Pointer(FGLESActiveShaderProgram), 'glActiveShaderProgram');
  Bind(Pointer(FGLESCreateShaderProgramv), 'glCreateShaderProgramv');
  Bind(Pointer(FGLESBindProgramPipeline), 'glBindProgramPipeline');
  Bind(Pointer(FGLESDeleteProgramPipelines), 'glDeleteProgramPipelines');
  Bind(Pointer(FGLESGenProgramPipelines), 'glGenProgramPipelines');
  Bind(Pointer(FGLESIsProgramPipeline), 'glIsProgramPipeline');
  Bind(Pointer(FGLESGetProgramPipelineiv), 'glGetProgramPipelineiv');
  Bind(Pointer(FGLESGetProgramPipelineInfoLog), 'glGetProgramPipelineInfoLog');
  Bind(Pointer(FGLESValidateProgramPipeline), 'glValidateProgramPipeline');
  // ProgramUniform* (separate shader objects)
  Bind(Pointer(FGLESProgramUniform1i), 'glProgramUniform1i');
  Bind(Pointer(FGLESProgramUniform1iv), 'glProgramUniform1iv');
  Bind(Pointer(FGLESProgramUniform1f), 'glProgramUniform1f');
  Bind(Pointer(FGLESProgramUniform1fv), 'glProgramUniform1fv');
  Bind(Pointer(FGLESProgramUniform1d), 'glProgramUniform1d');
  Bind(Pointer(FGLESProgramUniform1dv), 'glProgramUniform1dv');
  Bind(Pointer(FGLESProgramUniform1ui), 'glProgramUniform1ui');
  Bind(Pointer(FGLESProgramUniform1uiv), 'glProgramUniform1uiv');
  Bind(Pointer(FGLESProgramUniform2i), 'glProgramUniform2i');
  Bind(Pointer(FGLESProgramUniform2iv), 'glProgramUniform2iv');
  Bind(Pointer(FGLESProgramUniform2f), 'glProgramUniform2f');
  Bind(Pointer(FGLESProgramUniform2fv), 'glProgramUniform2fv');
  Bind(Pointer(FGLESProgramUniform2d), 'glProgramUniform2d');
  Bind(Pointer(FGLESProgramUniform2dv), 'glProgramUniform2dv');
  Bind(Pointer(FGLESProgramUniform2ui), 'glProgramUniform2ui');
  Bind(Pointer(FGLESProgramUniform2uiv), 'glProgramUniform2uiv');
  Bind(Pointer(FGLESProgramUniform3i), 'glProgramUniform3i');
  Bind(Pointer(FGLESProgramUniform3iv), 'glProgramUniform3iv');
  Bind(Pointer(FGLESProgramUniform3f), 'glProgramUniform3f');
  Bind(Pointer(FGLESProgramUniform3fv), 'glProgramUniform3fv');
  Bind(Pointer(FGLESProgramUniform3d), 'glProgramUniform3d');
  Bind(Pointer(FGLESProgramUniform3dv), 'glProgramUniform3dv');
  Bind(Pointer(FGLESProgramUniform3ui), 'glProgramUniform3ui');
  Bind(Pointer(FGLESProgramUniform3uiv), 'glProgramUniform3uiv');
  Bind(Pointer(FGLESProgramUniform4i), 'glProgramUniform4i');
  Bind(Pointer(FGLESProgramUniform4iv), 'glProgramUniform4iv');
  Bind(Pointer(FGLESProgramUniform4f), 'glProgramUniform4f');
  Bind(Pointer(FGLESProgramUniform4fv), 'glProgramUniform4fv');
  Bind(Pointer(FGLESProgramUniform4d), 'glProgramUniform4d');
  Bind(Pointer(FGLESProgramUniform4dv), 'glProgramUniform4dv');
  Bind(Pointer(FGLESProgramUniform4ui), 'glProgramUniform4ui');
  Bind(Pointer(FGLESProgramUniform4uiv), 'glProgramUniform4uiv');
  Bind(Pointer(FGLESProgramUniformMatrix2fv), 'glProgramUniformMatrix2fv');
  Bind(Pointer(FGLESProgramUniformMatrix3fv), 'glProgramUniformMatrix3fv');
  Bind(Pointer(FGLESProgramUniformMatrix4fv), 'glProgramUniformMatrix4fv');
  Bind(Pointer(FGLESProgramUniformMatrix2dv), 'glProgramUniformMatrix2dv');
  Bind(Pointer(FGLESProgramUniformMatrix3dv), 'glProgramUniformMatrix3dv');
  Bind(Pointer(FGLESProgramUniformMatrix4dv), 'glProgramUniformMatrix4dv');
  Bind(Pointer(FGLESProgramUniformMatrix2x3fv), 'glProgramUniformMatrix2x3fv');
  Bind(Pointer(FGLESProgramUniformMatrix3x2fv), 'glProgramUniformMatrix3x2fv');
  Bind(Pointer(FGLESProgramUniformMatrix2x4fv), 'glProgramUniformMatrix2x4fv');
  Bind(Pointer(FGLESProgramUniformMatrix4x2fv), 'glProgramUniformMatrix4x2fv');
  Bind(Pointer(FGLESProgramUniformMatrix3x4fv), 'glProgramUniformMatrix3x4fv');
  Bind(Pointer(FGLESProgramUniformMatrix4x3fv), 'glProgramUniformMatrix4x3fv');
  Bind(Pointer(FGLESProgramUniformMatrix2x3dv), 'glProgramUniformMatrix2x3dv');
  Bind(Pointer(FGLESProgramUniformMatrix3x2dv), 'glProgramUniformMatrix3x2dv');
  Bind(Pointer(FGLESProgramUniformMatrix2x4dv), 'glProgramUniformMatrix2x4dv');
  Bind(Pointer(FGLESProgramUniformMatrix4x2dv), 'glProgramUniformMatrix4x2dv');
  Bind(Pointer(FGLESProgramUniformMatrix3x4dv), 'glProgramUniformMatrix3x4dv');
  Bind(Pointer(FGLESProgramUniformMatrix4x3dv), 'glProgramUniformMatrix4x3dv');
  // Indirect Drawing
  Bind(Pointer(FGLESDrawArraysIndirect), 'glDrawArraysIndirect');
  Bind(Pointer(FGLESDrawElementsIndirect), 'glDrawElementsIndirect');
  // Multi-viewport & Scissor
  Bind(Pointer(FGLESViewportArrayv), 'glViewportArrayv');
  Bind(Pointer(FGLESViewportIndexedf), 'glViewportIndexedf');
  Bind(Pointer(FGLESViewportIndexedfv), 'glViewportIndexedfv');
  Bind(Pointer(FGLESScissorArrayv), 'glScissorArrayv');
  Bind(Pointer(FGLESScissorIndexed), 'glScissorIndexed');
  Bind(Pointer(FGLESScissorIndexedv), 'glScissorIndexedv');
  // Enhanced Depth Range
  Bind(Pointer(FGLESDepthRangeArrayv), 'glDepthRangeArrayv');
  Bind(Pointer(FGLESDepthRangeIndexed), 'glDepthRangeIndexed');
  // Fine-grained Memory Barriers
  Bind(Pointer(FGLESMemoryBarrierByRegion), 'glMemoryBarrierByRegion');
end;

{ TOpenGLES_3_1 – Implementazione completa dei metodi di IGLES_3_1 }

procedure TOpenGLES_3_1.glDispatchCompute(num_groups_x, num_groups_y, num_groups_z: GLuint);
begin
  if Assigned(FGLESDispatchCompute) then
    FGLESDispatchCompute(num_groups_x, num_groups_y, num_groups_z);
end;

procedure TOpenGLES_3_1.glDispatchComputeIndirect(indirect: GLintptr);
begin
  if Assigned(FGLESDispatchComputeIndirect) then
    FGLESDispatchComputeIndirect(indirect);
end;

procedure TOpenGLES_3_1.glShaderStorageBlockBinding(program_: GLuint; storageBlockIndex: GLuint; storageBlockBinding: GLuint);
begin
  if Assigned(FGLESShaderStorageBlockBinding) then
    FGLESShaderStorageBlockBinding(program_, storageBlockIndex, storageBlockBinding);
end;

procedure TOpenGLES_3_1.glGetActiveAtomicCounterBufferiv(program_: GLuint; bufferIndex: GLuint; pname: GLenum; params: PGLint);
begin
  if Assigned(FGLESGetActiveAtomicCounterBufferiv) then
    FGLESGetActiveAtomicCounterBufferiv(program_, bufferIndex, pname, params);
end;

procedure TOpenGLES_3_1.glBindImageTexture(unit_: GLuint; texture: GLuint; level: GLint; layered: GLboolean; layer: GLint; access: GLenum; format: GLenum);
begin
  if Assigned(FGLESBindImageTexture) then
    FGLESBindImageTexture(unit_, texture, level, layered, layer, access, format);
end;

procedure TOpenGLES_3_1.glMemoryBarrier(barriers: GLbitfield);
begin
  if Assigned(FGLESMemoryBarrier) then
    FGLESMemoryBarrier(barriers);
end;

function TOpenGLES_3_1.glGetProgramInterfaceiv(program_: GLuint; programInterface: GLenum; pname: GLenum; params: PGLint): GLenum;
begin
  if Assigned(FGLESGetProgramInterfaceiv) then
    Result := FGLESGetProgramInterfaceiv(program_, programInterface, pname, params)
  else
    Result := 0;
end;

function TOpenGLES_3_1.glGetProgramResourceIndex(program_: GLuint; programInterface: GLenum; const Name: PGLchar): GLuint;
begin
  if Assigned(FGLESGetProgramResourceIndex) then
    Result := FGLESGetProgramResourceIndex(program_, programInterface, Name)
  else
    Result := GL_INVALID_INDEX;
end;

function TOpenGLES_3_1.glGetProgramResourceLocation(program_: GLuint; programInterface: GLenum; const Name: PGLchar): GLint;
begin
  if Assigned(FGLESGetProgramResourceLocation) then
    Result := FGLESGetProgramResourceLocation(program_, programInterface, Name)
  else
    Result := -1;
end;

function TOpenGLES_3_1.glGetProgramResourceLocationIndex(program_: GLuint; programInterface: GLenum; const Name: PGLchar): GLint;
begin
  if Assigned(FGLESGetProgramResourceLocationIndex) then
    Result := FGLESGetProgramResourceLocationIndex(program_, programInterface, Name)
  else
    Result := -1;
end;

procedure TOpenGLES_3_1.glGetProgramResourceName(program_: GLuint; programInterface: GLenum; index: GLuint; bufSize: GLsizei; length: PGLsizei; Name: PGLchar);
begin
  if Assigned(FGLESGetProgramResourceName) then
    FGLESGetProgramResourceName(program_, programInterface, index, bufSize, length, Name);
end;

procedure TOpenGLES_3_1.glGetProgramResourceiv(program_: GLuint; programInterface: GLenum; index: GLuint; propCount: GLsizei; const props: PGLenum; bufSize: GLsizei; length: PGLsizei; params: PGLint);
begin
  if Assigned(FGLESGetProgramResourceiv) then
    FGLESGetProgramResourceiv(program_, programInterface, index, propCount, props, bufSize, length, params);
end;

procedure TOpenGLES_3_1.glUseProgramStages(pipeline: GLuint; stages: GLbitfield; program_: GLuint);
begin
  if Assigned(FGLESUseProgramStages) then
    FGLESUseProgramStages(pipeline, stages, program_);
end;

procedure TOpenGLES_3_1.glActiveShaderProgram(pipeline: GLuint; program_: GLuint);
begin
  if Assigned(FGLESActiveShaderProgram) then
    FGLESActiveShaderProgram(pipeline, program_);
end;

function TOpenGLES_3_1.glCreateShaderProgramv(shaderType: GLenum; Count: GLsizei; const strings: PPGLchar): GLuint;
begin
  if Assigned(FGLESCreateShaderProgramv) then
    Result := FGLESCreateShaderProgramv(shaderType, Count, strings)
  else
    Result := 0;
end;

procedure TOpenGLES_3_1.glBindProgramPipeline(pipeline: GLuint);
begin
  if Assigned(FGLESBindProgramPipeline) then
    FGLESBindProgramPipeline(pipeline);
end;

procedure TOpenGLES_3_1.glDeleteProgramPipelines(n: GLsizei; const pipelines: PGLuint);
begin
  if Assigned(FGLESDeleteProgramPipelines) then
    FGLESDeleteProgramPipelines(n, pipelines);
end;

procedure TOpenGLES_3_1.glGenProgramPipelines(n: GLsizei; pipelines: PGLuint);
begin
  if Assigned(FGLESGenProgramPipelines) then
    FGLESGenProgramPipelines(n, pipelines);
end;

function TOpenGLES_3_1.glIsProgramPipeline(pipeline: GLuint): GLboolean;
begin
  if Assigned(FGLESIsProgramPipeline) then
    Result := FGLESIsProgramPipeline(pipeline)
  else
    Result := GL_FALSE;
end;

procedure TOpenGLES_3_1.glGetProgramPipelineiv(pipeline: GLuint; pname: GLenum; params: PGLint);
begin
  if Assigned(FGLESGetProgramPipelineiv) then
    FGLESGetProgramPipelineiv(pipeline, pname, params);
end;

procedure TOpenGLES_3_1.glGetProgramPipelineInfoLog(pipeline: GLuint; bufSize: GLsizei; length: PGLsizei; infoLog: PGLchar);
begin
  if Assigned(FGLESGetProgramPipelineInfoLog) then
    FGLESGetProgramPipelineInfoLog(pipeline, bufSize, length, infoLog);
end;

procedure TOpenGLES_3_1.glValidateProgramPipeline(pipeline: GLuint);
begin
  if Assigned(FGLESValidateProgramPipeline) then
    FGLESValidateProgramPipeline(pipeline);
end;

// ProgramUniform* – tutti i 60 overload
procedure TOpenGLES_3_1.glProgramUniform1i(program_: GLuint; location: GLint; v0: GLint);
begin
  if Assigned(FGLESProgramUniform1i) then
    FGLESProgramUniform1i(program_, location, v0);
end;

procedure TOpenGLES_3_1.glProgramUniform1iv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLint);
begin
  if Assigned(FGLESProgramUniform1iv) then
    FGLESProgramUniform1iv(program_, location, Count, Value);
end;

procedure TOpenGLES_3_1.glProgramUniform1f(program_: GLuint; location: GLint; v0: GLfloat);
begin
  if Assigned(FGLESProgramUniform1f) then
    FGLESProgramUniform1f(program_, location, v0);
end;

procedure TOpenGLES_3_1.glProgramUniform1fv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLfloat);
begin
  if Assigned(FGLESProgramUniform1fv) then
    FGLESProgramUniform1fv(program_, location, Count, Value);
end;

procedure TOpenGLES_3_1.glProgramUniform1d(program_: GLuint; location: GLint; v0: GLdouble);
begin
  if Assigned(FGLESProgramUniform1d) then
    FGLESProgramUniform1d(program_, location, v0);
end;

procedure TOpenGLES_3_1.glProgramUniform1dv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLdouble);
begin
  if Assigned(FGLESProgramUniform1dv) then
    FGLESProgramUniform1dv(program_, location, Count, Value);
end;

procedure TOpenGLES_3_1.glProgramUniform1ui(program_: GLuint; location: GLint; v0: GLuint);
begin
  if Assigned(FGLESProgramUniform1ui) then
    FGLESProgramUniform1ui(program_, location, v0);
end;

procedure TOpenGLES_3_1.glProgramUniform1uiv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLuint);
begin
  if Assigned(FGLESProgramUniform1uiv) then
    FGLESProgramUniform1uiv(program_, location, Count, Value);
end;

procedure TOpenGLES_3_1.glProgramUniform2i(program_: GLuint; location: GLint; v0, v1: GLint);
begin
  if Assigned(FGLESProgramUniform2i) then
    FGLESProgramUniform2i(program_, location, v0, v1);
end;

procedure TOpenGLES_3_1.glProgramUniform2iv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLint);
begin
  if Assigned(FGLESProgramUniform2iv) then
    FGLESProgramUniform2iv(program_, location, Count, Value);
end;

procedure TOpenGLES_3_1.glProgramUniform2f(program_: GLuint; location: GLint; v0, v1: GLfloat);
begin
  if Assigned(FGLESProgramUniform2f) then
    FGLESProgramUniform2f(program_, location, v0, v1);
end;

procedure TOpenGLES_3_1.glProgramUniform2fv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLfloat);
begin
  if Assigned(FGLESProgramUniform2fv) then
    FGLESProgramUniform2fv(program_, location, Count, Value);
end;

procedure TOpenGLES_3_1.glProgramUniform2d(program_: GLuint; location: GLint; v0, v1: GLdouble);
begin
  if Assigned(FGLESProgramUniform2d) then
    FGLESProgramUniform2d(program_, location, v0, v1);
end;

procedure TOpenGLES_3_1.glProgramUniform2dv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLdouble);
begin
  if Assigned(FGLESProgramUniform2dv) then
    FGLESProgramUniform2dv(program_, location, Count, Value);
end;

procedure TOpenGLES_3_1.glProgramUniform2ui(program_: GLuint; location: GLint; v0, v1: GLuint);
begin
  if Assigned(FGLESProgramUniform2ui) then
    FGLESProgramUniform2ui(program_, location, v0, v1);
end;

procedure TOpenGLES_3_1.glProgramUniform2uiv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLuint);
begin
  if Assigned(FGLESProgramUniform2uiv) then
    FGLESProgramUniform2uiv(program_, location, Count, Value);
end;

procedure TOpenGLES_3_1.glProgramUniform3i(program_: GLuint; location: GLint; v0, v1, v2: GLint);
begin
  if Assigned(FGLESProgramUniform3i) then
    FGLESProgramUniform3i(program_, location, v0, v1, v2);
end;

procedure TOpenGLES_3_1.glProgramUniform3iv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLint);
begin
  if Assigned(FGLESProgramUniform3iv) then
    FGLESProgramUniform3iv(program_, location, Count, Value);
end;

procedure TOpenGLES_3_1.glProgramUniform3f(program_: GLuint; location: GLint; v0, v1, v2: GLfloat);
begin
  if Assigned(FGLESProgramUniform3f) then
    FGLESProgramUniform3f(program_, location, v0, v1, v2);
end;

procedure TOpenGLES_3_1.glProgramUniform3fv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLfloat);
begin
  if Assigned(FGLESProgramUniform3fv) then
    FGLESProgramUniform3fv(program_, location, Count, Value);
end;

procedure TOpenGLES_3_1.glProgramUniform3d(program_: GLuint; location: GLint; v0, v1, v2: GLdouble);
begin
  if Assigned(FGLESProgramUniform3d) then
    FGLESProgramUniform3d(program_, location, v0, v1, v2);
end;

procedure TOpenGLES_3_1.glProgramUniform3dv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLdouble);
begin
  if Assigned(FGLESProgramUniform3dv) then
    FGLESProgramUniform3dv(program_, location, Count, Value);
end;

procedure TOpenGLES_3_1.glProgramUniform3ui(program_: GLuint; location: GLint; v0, v1, v2: GLuint);
begin
  if Assigned(FGLESProgramUniform3ui) then
    FGLESProgramUniform3ui(program_, location, v0, v1, v2);
end;

procedure TOpenGLES_3_1.glProgramUniform3uiv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLuint);
begin
  if Assigned(FGLESProgramUniform3uiv) then
    FGLESProgramUniform3uiv(program_, location, Count, Value);
end;

procedure TOpenGLES_3_1.glProgramUniform4i(program_: GLuint; location: GLint; v0, v1, v2, v3: GLint);
begin
  if Assigned(FGLESProgramUniform4i) then
    FGLESProgramUniform4i(program_, location, v0, v1, v2, v3);
end;

procedure TOpenGLES_3_1.glProgramUniform4iv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLint);
begin
  if Assigned(FGLESProgramUniform4iv) then
    FGLESProgramUniform4iv(program_, location, Count, Value);
end;

procedure TOpenGLES_3_1.glProgramUniform4f(program_: GLuint; location: GLint; v0, v1, v2, v3: GLfloat);
begin
  if Assigned(FGLESProgramUniform4f) then
    FGLESProgramUniform4f(program_, location, v0, v1, v2, v3);
end;

procedure TOpenGLES_3_1.glProgramUniform4fv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLfloat);
begin
  if Assigned(FGLESProgramUniform4fv) then
    FGLESProgramUniform4fv(program_, location, Count, Value);
end;

procedure TOpenGLES_3_1.glProgramUniform4d(program_: GLuint; location: GLint; v0, v1, v2, v3: GLdouble);
begin
  if Assigned(FGLESProgramUniform4d) then
    FGLESProgramUniform4d(program_, location, v0, v1, v2, v3);
end;

procedure TOpenGLES_3_1.glProgramUniform4dv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLdouble);
begin
  if Assigned(FGLESProgramUniform4dv) then
    FGLESProgramUniform4dv(program_, location, Count, Value);
end;

procedure TOpenGLES_3_1.glProgramUniform4ui(program_: GLuint; location: GLint; v0, v1, v2, v3: GLuint);
begin
  if Assigned(FGLESProgramUniform4ui) then
    FGLESProgramUniform4ui(program_, location, v0, v1, v2, v3);
end;

procedure TOpenGLES_3_1.glProgramUniform4uiv(program_: GLuint; location: GLint; Count: GLsizei; const Value: PGLuint);
begin
  if Assigned(FGLESProgramUniform4uiv) then
    FGLESProgramUniform4uiv(program_, location, Count, Value);
end;

procedure TOpenGLES_3_1.glProgramUniformMatrix2fv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat);
begin
  if Assigned(FGLESProgramUniformMatrix2fv) then
    FGLESProgramUniformMatrix2fv(program_, location, Count, transpose, Value);
end;

procedure TOpenGLES_3_1.glProgramUniformMatrix3fv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat);
begin
  if Assigned(FGLESProgramUniformMatrix3fv) then
    FGLESProgramUniformMatrix3fv(program_, location, Count, transpose, Value);
end;

procedure TOpenGLES_3_1.glProgramUniformMatrix4fv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat);
begin
  if Assigned(FGLESProgramUniformMatrix4fv) then
    FGLESProgramUniformMatrix4fv(program_, location, Count, transpose, Value);
end;

procedure TOpenGLES_3_1.glProgramUniformMatrix2dv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLdouble);
begin
  if Assigned(FGLESProgramUniformMatrix2dv) then
    FGLESProgramUniformMatrix2dv(program_, location, Count, transpose, Value);
end;

procedure TOpenGLES_3_1.glProgramUniformMatrix3dv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLdouble);
begin
  if Assigned(FGLESProgramUniformMatrix3dv) then
    FGLESProgramUniformMatrix3dv(program_, location, Count, transpose, Value);
end;

procedure TOpenGLES_3_1.glProgramUniformMatrix4dv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLdouble);
begin
  if Assigned(FGLESProgramUniformMatrix4dv) then
    FGLESProgramUniformMatrix4dv(program_, location, Count, transpose, Value);
end;

procedure TOpenGLES_3_1.glProgramUniformMatrix2x3fv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat);
begin
  if Assigned(FGLESProgramUniformMatrix2x3fv) then
    FGLESProgramUniformMatrix2x3fv(program_, location, Count, transpose, Value);
end;

procedure TOpenGLES_3_1.glProgramUniformMatrix3x2fv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat);
begin
  if Assigned(FGLESProgramUniformMatrix3x2fv) then
    FGLESProgramUniformMatrix3x2fv(program_, location, Count, transpose, Value);
end;

procedure TOpenGLES_3_1.glProgramUniformMatrix2x4fv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat);
begin
  if Assigned(FGLESProgramUniformMatrix2x4fv) then
    FGLESProgramUniformMatrix2x4fv(program_, location, Count, transpose, Value);
end;

procedure TOpenGLES_3_1.glProgramUniformMatrix4x2fv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat);
begin
  if Assigned(FGLESProgramUniformMatrix4x2fv) then
    FGLESProgramUniformMatrix4x2fv(program_, location, Count, transpose, Value);
end;

procedure TOpenGLES_3_1.glProgramUniformMatrix3x4fv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat);
begin
  if Assigned(FGLESProgramUniformMatrix3x4fv) then
    FGLESProgramUniformMatrix3x4fv(program_, location, Count, transpose, Value);
end;

procedure TOpenGLES_3_1.glProgramUniformMatrix4x3fv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLfloat);
begin
  if Assigned(FGLESProgramUniformMatrix4x3fv) then
    FGLESProgramUniformMatrix4x3fv(program_, location, Count, transpose, Value);
end;

procedure TOpenGLES_3_1.glProgramUniformMatrix2x3dv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLdouble);
begin
  if Assigned(FGLESProgramUniformMatrix2x3dv) then
    FGLESProgramUniformMatrix2x3dv(program_, location, Count, transpose, Value);
end;

procedure TOpenGLES_3_1.glProgramUniformMatrix3x2dv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLdouble);
begin
  if Assigned(FGLESProgramUniformMatrix3x2dv) then
    FGLESProgramUniformMatrix3x2dv(program_, location, Count, transpose, Value);
end;

procedure TOpenGLES_3_1.glProgramUniformMatrix2x4dv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLdouble);
begin
  if Assigned(FGLESProgramUniformMatrix2x4dv) then
    FGLESProgramUniformMatrix2x4dv(program_, location, Count, transpose, Value);
end;

procedure TOpenGLES_3_1.glProgramUniformMatrix4x2dv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLdouble);
begin
  if Assigned(FGLESProgramUniformMatrix4x2dv) then
    FGLESProgramUniformMatrix4x2dv(program_, location, Count, transpose, Value);
end;

procedure TOpenGLES_3_1.glProgramUniformMatrix3x4dv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLdouble);
begin
  if Assigned(FGLESProgramUniformMatrix3x4dv) then
    FGLESProgramUniformMatrix3x4dv(program_, location, Count, transpose, Value);
end;

procedure TOpenGLES_3_1.glProgramUniformMatrix4x3dv(program_: GLuint; location: GLint; Count: GLsizei; transpose: GLboolean; const Value: PGLdouble);
begin
  if Assigned(FGLESProgramUniformMatrix4x3dv) then
    FGLESProgramUniformMatrix4x3dv(program_, location, Count, transpose, Value);
end;

procedure TOpenGLES_3_1.glDrawArraysIndirect(mode: GLenum; const indirect: Pointer);
begin
  if Assigned(FGLESDrawArraysIndirect) then
    FGLESDrawArraysIndirect(mode, indirect);
end;

procedure TOpenGLES_3_1.glDrawElementsIndirect(mode: GLenum; type_: GLenum; const indirect: Pointer);
begin
  if Assigned(FGLESDrawElementsIndirect) then
    FGLESDrawElementsIndirect(mode, type_, indirect);
end;

procedure TOpenGLES_3_1.glViewportArrayv(First: GLuint; Count: GLsizei; const v: PGLfloat);
begin
  if Assigned(FGLESViewportArrayv) then
    FGLESViewportArrayv(First, Count, v);
end;

procedure TOpenGLES_3_1.glViewportIndexedf(index: GLuint; x, y, w, h: GLfloat);
begin
  if Assigned(FGLESViewportIndexedf) then
    FGLESViewportIndexedf(index, x, y, w, h);
end;

procedure TOpenGLES_3_1.glViewportIndexedfv(index: GLuint; const v: PGLfloat);
begin
  if Assigned(FGLESViewportIndexedfv) then
    FGLESViewportIndexedfv(index, v);
end;

procedure TOpenGLES_3_1.glScissorArrayv(First: GLuint; Count: GLsizei; const v: PGLint);
begin
  if Assigned(FGLESScissorArrayv) then
    FGLESScissorArrayv(First, Count, v);
end;

procedure TOpenGLES_3_1.glScissorIndexed(index: GLuint; left, bottom: GLint; Width, Height: GLsizei);
begin
  if Assigned(FGLESScissorIndexed) then
    FGLESScissorIndexed(index, left, bottom, Width, Height);
end;

procedure TOpenGLES_3_1.glScissorIndexedv(index: GLuint; const v: PGLint);
begin
  if Assigned(FGLESScissorIndexedv) then
    FGLESScissorIndexedv(index, v);
end;

procedure TOpenGLES_3_1.glDepthRangeArrayv(First: GLuint; Count: GLsizei; const v: PGLclampd);
begin
  if Assigned(FGLESDepthRangeArrayv) then
    FGLESDepthRangeArrayv(First, Count, v);
end;

procedure TOpenGLES_3_1.glDepthRangeIndexed(index: GLuint; n, f: GLclampd);
begin
  if Assigned(FGLESDepthRangeIndexed) then
    FGLESDepthRangeIndexed(index, n, f);
end;

procedure TOpenGLES_3_1.glMemoryBarrierByRegion(barriers: GLbitfield);
begin
  if Assigned(FGLESMemoryBarrierByRegion) then
    FGLESMemoryBarrierByRegion(barriers);
end;

{ TOpenGLES_3_2 }

procedure TOpenGLES_3_2.bindEntry;
begin
  inherited bindEntry;

  // Geometry & Tessellation Shaders
  Bind(Pointer(FGLESPatchParameteri), 'glPatchParameteri');
  Bind(Pointer(FGLESPatchParameterfv), 'glPatchParameterfv');

  // Multisample Textures
  Bind(Pointer(FGLESTexStorage2DMultisample), 'glTexStorage2DMultisample');
  Bind(Pointer(FGLESTexStorage3DMultisample), 'glTexStorage3DMultisample');

  // Advanced Blending (per-drawbuffer)
  Bind(Pointer(FGLESBlendBarrier), 'glBlendBarrier');
  Bind(Pointer(FGLESBlendEquationi), 'glBlendEquationi');
  Bind(Pointer(FGLESBlendEquationSeparatei), 'glBlendEquationSeparatei');
  Bind(Pointer(FGLESBlendFunci), 'glBlendFunci');
  Bind(Pointer(FGLESBlendFuncSeparatei), 'glBlendFuncSeparatei');

  // Primitive Bounding Box
  Bind(Pointer(FGLESPrimitiveBoundingBox), 'glPrimitiveBoundingBox');

  // Debug Output (core in ES 3.2)
  Bind(Pointer(FGLESDebugMessageControl), 'glDebugMessageControl');
  Bind(Pointer(FGLESDebugMessageInsert), 'glDebugMessageInsert');
  Bind(Pointer(FGLESDebugMessageCallback), 'glDebugMessageCallback');
  Bind(Pointer(FGLESGetDebugMessageLog), 'glGetDebugMessageLog');
  Bind(Pointer(FGLESPushDebugGroup), 'glPushDebugGroup');
  Bind(Pointer(FGLESPopDebugGroup), 'glPopDebugGroup');
  Bind(Pointer(FGLESObjectLabel), 'glObjectLabel');
  Bind(Pointer(FGLESGetObjectLabel), 'glGetObjectLabel');
  Bind(Pointer(FGLESObjectPtrLabel), 'glObjectPtrLabel');
  Bind(Pointer(FGLESGetObjectPtrLabel), 'glGetObjectPtrLabel');
  Bind(Pointer(FGLESGetPointerv), 'glGetPointerv');

  // Enhanced Sampling
  Bind(Pointer(FGLESMinSampleShading), 'glMinSampleShading');
  Bind(Pointer(FGLESGetMultisamplefv), 'glGetMultisamplefv');
  Bind(Pointer(FGLESSampleMaski), 'glSampleMaski');

  // Texture Buffer Range & Texture View
  Bind(Pointer(FGLESTexBufferRange), 'glTexBufferRange');
  Bind(Pointer(FGLESTextureView), 'glTextureView');

  // Enhanced Queries
  Bind(Pointer(FGLESGetQueryObjecti64v), 'glGetQueryObjecti64v');
  Bind(Pointer(FGLESGetQueryObjectui64v), 'glGetQueryObjectui64v');

  // Framebuffer Parameters
  Bind(Pointer(FGLESFramebufferParameteri), 'glFramebufferParameteri');
  Bind(Pointer(FGLESGetFramebufferParameteriv), 'glGetFramebufferParameteriv');

  // ClearTexImage / ClearTexSubImage
  Bind(Pointer(FGLESClearTexImage), 'glClearTexImage');
  Bind(Pointer(FGLESClearTexSubImage), 'glClearTexSubImage');

  // Robustness
  Bind(Pointer(FGLESGetGraphicsResetStatus), 'glGetGraphicsResetStatus');
  Bind(Pointer(FGLESReadnPixels), 'glReadnPixels');
  Bind(Pointer(FGLESGetnUniformfv), 'glGetnUniformfv');
  Bind(Pointer(FGLESGetnUniformiv), 'glGetnUniformiv');
  Bind(Pointer(FGLESGetnUniformuiv), 'glGetnUniformuiv');
end;

{ TOpenGLES_3_2 – Implementazione completa dei metodi di IGLES_3_2 }

procedure TOpenGLES_3_2.glPatchParameteri(pname: GLenum; Value: GLint);
begin
  if Assigned(FGLESPatchParameteri) then
    FGLESPatchParameteri(pname, Value);
end;

procedure TOpenGLES_3_2.glPatchParameterfv(pname: GLenum; const values: PGLfloat);
begin
  if Assigned(FGLESPatchParameterfv) then
    FGLESPatchParameterfv(pname, values);
end;

procedure TOpenGLES_3_2.glTexStorage2DMultisample(target: GLenum; samples: GLsizei; internalformat: GLenum; Width, Height: GLsizei; fixedsamplelocations: GLboolean);
begin
  if Assigned(FGLESTexStorage2DMultisample) then
    FGLESTexStorage2DMultisample(target, samples, internalformat, Width, Height, fixedsamplelocations);
end;

procedure TOpenGLES_3_2.glTexStorage3DMultisample(target: GLenum; samples: GLsizei; internalformat: GLenum; Width, Height, depth: GLsizei; fixedsamplelocations: GLboolean);
begin
  if Assigned(FGLESTexStorage3DMultisample) then
    FGLESTexStorage3DMultisample(target, samples, internalformat, Width, Height, depth, fixedsamplelocations);
end;

procedure TOpenGLES_3_2.glBlendBarrier;
begin
  if Assigned(FGLESBlendBarrier) then
    FGLESBlendBarrier();
end;

procedure TOpenGLES_3_2.glBlendEquationi(buf: GLuint; mode: GLenum);
begin
  if Assigned(FGLESBlendEquationi) then
    FGLESBlendEquationi(buf, mode);
end;

procedure TOpenGLES_3_2.glBlendEquationSeparatei(buf: GLuint; modeRGB, modeAlpha: GLenum);
begin
  if Assigned(FGLESBlendEquationSeparatei) then
    FGLESBlendEquationSeparatei(buf, modeRGB, modeAlpha);
end;

procedure TOpenGLES_3_2.glBlendFunci(buf: GLuint; src, dst: GLenum);
begin
  if Assigned(FGLESBlendFunci) then
    FGLESBlendFunci(buf, src, dst);
end;

procedure TOpenGLES_3_2.glBlendFuncSeparatei(buf: GLuint; srcRGB, dstRGB, srcAlpha, dstAlpha: GLenum);
begin
  if Assigned(FGLESBlendFuncSeparatei) then
    FGLESBlendFuncSeparatei(buf, srcRGB, dstRGB, srcAlpha, dstAlpha);
end;

procedure TOpenGLES_3_2.glPrimitiveBoundingBox(minX, minY, minZ, minW, maxX, maxY, maxZ, maxW: GLfloat);
begin
  if Assigned(FGLESPrimitiveBoundingBox) then
    FGLESPrimitiveBoundingBox(minX, minY, minZ, minW, maxX, maxY, maxZ, maxW);
end;

procedure TOpenGLES_3_2.glDebugMessageControl(Source, type_, severity: GLenum; Count: GLsizei; const ids: PGLuint; Enabled: GLboolean);
begin
  if Assigned(FGLESDebugMessageControl) then
    FGLESDebugMessageControl(Source, type_, severity, Count, ids, Enabled);
end;

procedure TOpenGLES_3_2.glDebugMessageInsert(Source, type_: GLenum; id: GLuint; severity: GLenum; length: GLsizei; const buf: PGLchar);
begin
  if Assigned(FGLESDebugMessageInsert) then
    FGLESDebugMessageInsert(Source, type_, id, severity, length, buf);
end;

procedure TOpenGLES_3_2.glDebugMessageCallback(callback: GLDEBUGPROC; const userParam: Pointer);
begin
  if Assigned(FGLESDebugMessageCallback) then
    FGLESDebugMessageCallback(callback, userParam);
end;

function TOpenGLES_3_2.glGetDebugMessageLog(Count: GLuint; bufSize: GLsizei; sources, types: PGLenum; ids: PGLuint; severities: PGLenum; lengths: PGLsizei; messageLog: PGLchar): GLuint;
begin
  if Assigned(FGLESGetDebugMessageLog) then
    Result := FGLESGetDebugMessageLog(Count, bufSize, sources, types, ids, severities, lengths, messageLog)
  else
    Result := 0;
end;

procedure TOpenGLES_3_2.glPushDebugGroup(Source: GLenum; id: GLuint; length: GLsizei; const message: PGLchar);
begin
  if Assigned(FGLESPushDebugGroup) then
    FGLESPushDebugGroup(Source, id, length, message);
end;

procedure TOpenGLES_3_2.glPopDebugGroup;
begin
  if Assigned(FGLESPopDebugGroup) then
    FGLESPopDebugGroup();
end;

procedure TOpenGLES_3_2.glObjectLabel(identifier: GLenum; Name: GLuint; length: GLsizei; const aLabel: PGLchar);
begin
  if Assigned(FGLESObjectLabel) then
    FGLESObjectLabel(identifier, Name, length, aLabel);
end;

procedure TOpenGLES_3_2.glGetObjectLabel(identifier: GLenum; Name: GLuint; bufSize: GLsizei; length: PGLsizei; aLabel: PGLchar);
begin
  if Assigned(FGLESGetObjectLabel) then
    FGLESGetObjectLabel(identifier, Name, bufSize, length, aLabel);
end;

procedure TOpenGLES_3_2.glObjectPtrLabel(const ptr: Pointer; length: GLsizei; const aLabel: PGLchar);
begin
  if Assigned(FGLESObjectPtrLabel) then
    FGLESObjectPtrLabel(ptr, length, aLabel);
end;

procedure TOpenGLES_3_2.glGetObjectPtrLabel(const ptr: Pointer; bufSize: GLsizei; length: PGLsizei; aLabel: PGLchar);
begin
  if Assigned(FGLESGetObjectPtrLabel) then
    FGLESGetObjectPtrLabel(ptr, bufSize, length, aLabel);
end;

procedure TOpenGLES_3_2.glGetPointerv(pname: GLenum; params: PPointer);
begin
  if Assigned(FGLESGetPointerv) then
    FGLESGetPointerv(pname, params);
end;

procedure TOpenGLES_3_2.glMinSampleShading(Value: GLfloat);
begin
  if Assigned(FGLESMinSampleShading) then
    FGLESMinSampleShading(Value);
end;

procedure TOpenGLES_3_2.glGetMultisamplefv(pname: GLenum; index: GLuint; val: PGLfloat);
begin
  if Assigned(FGLESGetMultisamplefv) then
    FGLESGetMultisamplefv(pname, index, val);
end;

procedure TOpenGLES_3_2.glSampleMaski(maskNumber: GLuint; mask: GLbitfield);
begin
  if Assigned(FGLESSampleMaski) then
    FGLESSampleMaski(maskNumber, mask);
end;

procedure TOpenGLES_3_2.glTexBufferRange(target: GLenum; internalformat: GLenum; buffer: GLuint; offset: GLintptr; size: GLsizeiptr);
begin
  if Assigned(FGLESTexBufferRange) then
    FGLESTexBufferRange(target, internalformat, buffer, offset, size);
end;

procedure TOpenGLES_3_2.glTextureView(texture, target, origtexture: GLuint; internalformat: GLenum; minlevel, numlevels, minlayer, numlayers: GLuint);
begin
  if Assigned(FGLESTextureView) then
    FGLESTextureView(texture, target, origtexture, internalformat, minlevel, numlevels, minlayer, numlayers);
end;

procedure TOpenGLES_3_2.glGetQueryObjecti64v(id: GLuint; pname: GLenum; params: PGLint64);
begin
  if Assigned(FGLESGetQueryObjecti64v) then
    FGLESGetQueryObjecti64v(id, pname, params);
end;

procedure TOpenGLES_3_2.glGetQueryObjectui64v(id: GLuint; pname: GLenum; params: PGLuint64);
begin
  if Assigned(FGLESGetQueryObjectui64v) then
    FGLESGetQueryObjectui64v(id, pname, params);
end;

procedure TOpenGLES_3_2.glFramebufferParameteri(target: GLenum; pname: GLenum; param: GLint);
begin
  if Assigned(FGLESFramebufferParameteri) then
    FGLESFramebufferParameteri(target, pname, param);
end;

procedure TOpenGLES_3_2.glGetFramebufferParameteriv(target: GLenum; pname: GLenum; params: PGLint);
begin
  if Assigned(FGLESGetFramebufferParameteriv) then
    FGLESGetFramebufferParameteriv(target, pname, params);
end;

procedure TOpenGLES_3_2.glClearTexImage(texture: GLuint; level: GLint; format, type_: GLenum; const Data: Pointer);
begin
  if Assigned(FGLESClearTexImage) then
    FGLESClearTexImage(texture, level, format, type_, Data);
end;

procedure TOpenGLES_3_2.glClearTexSubImage(texture: GLuint; level, xoffset, yoffset, zoffset: GLint; Width, Height, depth: GLsizei; format, type_: GLenum; const Data: Pointer);
begin
  if Assigned(FGLESClearTexSubImage) then
    FGLESClearTexSubImage(texture, level, xoffset, yoffset, zoffset, Width, Height, depth, format, type_, Data);
end;

function TOpenGLES_3_2.glGetGraphicsResetStatus: GLenum;
begin
  if Assigned(FGLESGetGraphicsResetStatus) then
    Result := FGLESGetGraphicsResetStatus()
  else
    Result := GL_NO_ERROR;
end;

procedure TOpenGLES_3_2.glReadnPixels(x, y: GLint; Width, Height: GLsizei; format, type_: GLenum; bufSize: GLsizei; Data: Pointer);
begin
  if Assigned(FGLESReadnPixels) then
    FGLESReadnPixels(x, y, Width, Height, format, type_, bufSize, Data);
end;

procedure TOpenGLES_3_2.glGetnUniformfv(program_: GLuint; location: GLint; bufSize: GLsizei; params: PGLfloat);
begin
  if Assigned(FGLESGetnUniformfv) then
    FGLESGetnUniformfv(program_, location, bufSize, params);
end;

procedure TOpenGLES_3_2.glGetnUniformiv(program_: GLuint; location: GLint; bufSize: GLsizei; params: PGLint);
begin
  if Assigned(FGLESGetnUniformiv) then
    FGLESGetnUniformiv(program_, location, bufSize, params);
end;

procedure TOpenGLES_3_2.glGetnUniformuiv(program_: GLuint; location: GLint; bufSize: GLsizei; params: PGLuint);
begin
  if Assigned(FGLESGetnUniformuiv) then
    FGLESGetnUniformuiv(program_, location, bufSize, params);
end;

end.
