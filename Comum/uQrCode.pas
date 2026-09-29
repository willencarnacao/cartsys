unit uQrCode;

interface

uses
  Vcl.Graphics;

function GerarQrBitmap(const psTexto: string; piLado: Integer): TBitmap;

implementation

uses
  System.SysUtils, System.Types, System.Math, DelphiZXingQRCode;

function GerarQrBitmap(const psTexto: string; piLado: Integer): TBitmap;
var
  oQr: TDelphiZXingQRCode;
  iTamanho, iModulo, iLinha, iColuna, iX, iY: Integer;
begin
  oQr := TDelphiZXingQRCode.Create;
  try
    oQr.Encoding := qrISO88591;
    oQr.QuietZone := 4;
    oQr.Data := psTexto;
    iTamanho := oQr.Rows;
    if (iTamanho <= 0) or (oQr.Columns <= 0) then
      raise Exception.Create('N'#$00E3'o foi poss'#$00ED'vel gerar o QR Code.');
    iModulo := Max(6, piLado div iTamanho);
    Result := TBitmap.Create;
    Result.PixelFormat := pf32bit;
    Result.SetSize(iTamanho * iModulo, iTamanho * iModulo);
    Result.Canvas.Pen.Style := psClear;
    Result.Canvas.Brush.Style := bsSolid;
    Result.Canvas.Brush.Color := clWhite;
    Result.Canvas.FillRect(Rect(0, 0, Result.Width, Result.Height));
    Result.Canvas.Brush.Color := clBlack;
    for iLinha := 0 to oQr.Rows - 1 do
      for iColuna := 0 to oQr.Columns - 1 do
        if oQr.IsBlack[iLinha, iColuna] then
        begin
          iX := iColuna * iModulo;
          iY := iLinha * iModulo;
          Result.Canvas.FillRect(Rect(iX, iY, iX + iModulo, iY + iModulo));
        end;
  finally
    oQr.Free;
  end;
end;

end.
