#ifdef NANOVG_GL2
#define NANOVG_GL2 1
#elif defined(NANOVG_GL3)
#version 150 core
#define NANOVG_GL3 1
#elif defined(NANOVG_GLES2)
#version 100
#define NANOVG_GL2 1
#elif defined(NANOVG_GLES3)
#version 300 es
#define NANOVG_GL3 1
#endif
#ifdef NANOVG_GL_USE_UNIFORMBUFFER
#define USE_UNIFORMBUFFER 1
#else
#define UNIFORMARRAY_SIZE 11
#endif

