program nanovgdev;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes,
  SysUtils,
  paxutils_package,
  CustApp,
  nanovg,
  paxgl,
  nanovg_gl { you can add units after this };

type

  { TNanoVGDev }

  TNanoVGDev = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
  end;

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
  end;

  destructor TNanoVGDev.Destroy;
  begin
    inherited Destroy;
  end;

  procedure TNanoVGDev.WriteHelp;
  begin
    { add your help code here }
    writeln('Usage: ', ExeName, ' -h');
  end;

var
  Application: TNanoVGDev;
begin
  Application := TNanoVGDev.Create(nil);
  Application.Title := 'NanoVG DEV';
  Application.Run;
  Application.Free;
end.
