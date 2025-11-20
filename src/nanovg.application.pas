unit nanovg.application;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils,
  CustApp,
  pax.nanovg,
  pax.gl,
  pax.glfw,
  pax.nanovg.gl;

type

  { TNanoVGDev }

  TNanoVGDev = class(TCustomApplication)
  protected
    FGLFW: IGLFW;
    FOpenGL: IOpenGL;
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
  end;

implementation


{ TNanoVGDev }

procedure TNanoVGDev.DoRun;
var
  ErrorMsg: string;
begin
  // quick check parameters
  ErrorMsg := CheckOptions('h', 'help');
  if ErrorMsg <> '' then
  begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  // parse parameters
  if HasOption('h', 'help') then
  begin
    WriteHelp;
    Terminate;
    Exit;
  end;
  // stop program loop
  Terminate;
end;

constructor TNanoVGDev.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException := True;
  FGLFW := getGLFW;
  FOpenGL := GetOpenGL;

end;

destructor TNanoVGDev.Destroy;
begin
  FOpenGL := nil;
  FGLFW := nil;
  inherited Destroy;
end;

procedure TNanoVGDev.WriteHelp;
begin
  { add your help code here }
  writeln('Usage: ', ExeName, ' -h');
end;

end.
