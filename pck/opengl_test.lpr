program opengl_test;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes,
  pax.gl { you can add units after this };

var
  gl: IOpenGL;
begin
  gl := GetOpenGL;
  gl := nil;

end.
