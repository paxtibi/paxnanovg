unit stb_image;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpImage, fpReadPNG, fpReadJPEG, fpReadBMP;

type
  pbyte = ^byte;
  PInteger = ^integer;

{ Funzioni emulate di stb_image }
function stbi_load(filename: pchar; x, y, channels: PInteger; desired_channels: integer): pbyte; cdecl;
function stbi_load_from_memory(buffer: pbyte; len: integer; x, y, channels: PInteger; desired_channels: integer): pbyte; cdecl;
procedure stbi_image_free(Data: pbyte); cdecl;
procedure stbi_set_unpremultiply_on_load(flag: integer); cdecl;
procedure stbi_convert_iphone_png_to_rgb(flag: integer); cdecl;

var
  // Variabile globale per controllare la premoltiplicazione
  UnpremultiplyOnLoad: boolean = False;

implementation

// Funzione interna per determinare il lettore di immagine in base all'estensione del file
function CreateImageReader(const filename: string): TFPCustomImageReader;
var
  ext: string;
begin
  ext := LowerCase(ExtractFileExt(filename));
  case ext of
    '.png': Result := TFPReaderPNG.Create;
    '.jpg', '.jpeg': Result := TFPReaderJPEG.Create;
    '.bmp': Result := TFPReaderBMP.Create;
    else
      raise Exception.Create('Formato immagine non supportato: ' + ext);
  end;
end;

// Funzione per caricare un'immagine da file
function stbi_load(filename: pchar; x, y, channels: PInteger; desired_channels: integer): pbyte; cdecl;
var
  img: TFPCustomImage;
  reader: TFPCustomImageReader;
  i, j: integer;
  pixel: TFPColor;
  Data, p: pbyte;
  dataSize: integer;
begin
  Result := nil;
  img := TFPMemoryImage.Create(0, 0);
  try
    // Crea il lettore in base al formato del file
    reader := CreateImageReader(StrPas(filename));
    try
      img.LoadFromFile(StrPas(filename), reader);
    finally
      reader.Free;
    end;

    // Imposta le dimensioni
    x^ := img.Width;
    y^ := img.Height;
    channels^ := 4; // Forziamo RGBA per compatibilità con NanoVG

    // Alloca memoria per i dati RGBA
    dataSize := img.Width * img.Height * 4;
    GetMem(Data, dataSize);
    Result := Data;
    p := Data;

    // Copia i pixel in formato RGBA
    for j := 0 to img.Height - 1 do
      for i := 0 to img.Width - 1 do
      begin
        pixel := img.Colors[i, j];
        if UnpremultiplyOnLoad then
        begin
          // Dati non premoltiplicati
          p^ := pixel.Red shr 8;   // Red
          Inc(p);
          p^ := pixel.Green shr 8; // Green
          Inc(p);
          p^ := pixel.Blue shr 8;  // Blue
          Inc(p);
          p^ := pixel.Alpha shr 8; // Alpha
          Inc(p);
        end
        else
        begin
          // Premoltiplicazione dei canali
          if pixel.Alpha > 0 then
          begin
            p^ := (pixel.Red shr 8) * (pixel.Alpha shr 8) div 255;
            Inc(p);
            p^ := (pixel.Green shr 8) * (pixel.Alpha shr 8) div 255;
            Inc(p);
            p^ := (pixel.Blue shr 8) * (pixel.Alpha shr 8) div 255;
            Inc(p);
            p^ := pixel.Alpha shr 8;
            Inc(p);
          end
          else
          begin
            p^ := 0;
            Inc(p); // Red
            p^ := 0;
            Inc(p); // Green
            p^ := 0;
            Inc(p); // Blue
            p^ := 0;
            Inc(p); // Alpha
          end;
        end;
      end;
  except
    on E: Exception do
    begin
      img.Free;
      Exit(nil);
    end;
  end;
  img.Free;
end;

// Funzione per caricare un'immagine da memoria
function stbi_load_from_memory(buffer: pbyte; len: integer; x, y, channels: PInteger; desired_channels: integer): pbyte; cdecl;
var
  img: TFPCustomImage;
  reader: TFPCustomImageReader;
  stream: TMemoryStream;
  i, j: integer;
  pixel: TFPColor;
  Data, p: pbyte;
  dataSize: integer;
begin
  Result := nil;
  img := TFPMemoryImage.Create(0, 0);
  stream := TMemoryStream.Create;
  try
    // Scrivi il buffer nello stream
    stream.Write(buffer^, len);
    stream.Position := 0;

    // Crea il lettore (assumiamo PNG per semplicitÀ, ma puoi estenderlo)
    reader := TFPReaderPNG.Create; // Modifica per supportare altri formati se necessario
    try
      img.LoadFromStream(stream, reader);
    finally
      reader.Free;
    end;

    // Imposta le dimensioni
    x^ := img.Width;
    y^ := img.Height;
    channels^ := 4; // Forziamo RGBA

    // Alloca memoria per i dati RGBA
    dataSize := img.Width * img.Height * 4;
    GetMem(Data, dataSize);
    Result := Data;
    p := Data;

    // Copia i pixel in formato RGBA
    for j := 0 to img.Height - 1 do
      for i := 0 to img.Width - 1 do
      begin
        pixel := img.Colors[i, j];
        if UnpremultiplyOnLoad then
        begin
          p^ := pixel.Red shr 8;
          Inc(p);
          p^ := pixel.Green shr 8;
          Inc(p);
          p^ := pixel.Blue shr 8;
          Inc(p);
          p^ := pixel.Alpha shr 8;
          Inc(p);
        end
        else
        begin
          if pixel.Alpha > 0 then
          begin
            p^ := (pixel.Red shr 8) * (pixel.Alpha shr 8) div 255;
            Inc(p);
            p^ := (pixel.Green shr 8) * (pixel.Alpha shr 8) div 255;
            Inc(p);
            p^ := (pixel.Blue shr 8) * (pixel.Alpha shr 8) div 255;
            Inc(p);
            p^ := pixel.Alpha shr 8;
            Inc(p);
          end
          else
          begin
            p^ := 0;
            Inc(p);
            p^ := 0;
            Inc(p);
            p^ := 0;
            Inc(p);
            p^ := 0;
            Inc(p);
          end;
        end;
      end;
  except
    on E: Exception do
    begin
      img.Free;
      stream.Free;
      Exit(nil);
    end;
  end;
  img.Free;
  stream.Free;
end;

// Funzione per liberare la memoria
procedure stbi_image_free(Data: pbyte); cdecl;
begin
  if Data <> nil then
    FreeMem(Data);
end;

// Funzione per impostare la premoltiplicazione
procedure stbi_set_unpremultiply_on_load(flag: integer); cdecl;
begin
  UnpremultiplyOnLoad := flag <> 0;
end;

// Funzione per compatibilitÀ con i PNG di iPhone (non necessaria con fpImage)
procedure stbi_convert_iphone_png_to_rgb(flag: integer); cdecl;
begin
  // Non necessario, fpImage normalizza i dati automaticamente
end;

end.
