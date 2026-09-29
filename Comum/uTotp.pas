unit uTotp;

interface

uses
  System.SysUtils, System.DateUtils, uHashUtils, uCripto, uTipos;

function GerarSegredoBase32: string;

function MontarUriProvisionamento(const psEmissor, psConta, psSegredoBase32: string): string;

function GerarCodigoTotp(const psSegredoBase32: string; pdtInstante: TDateTime): string;

function ValidarCodigoTotp(const psSegredoBase32, psCodigoDigitado: string;
  var piUltimoPassoAceito: Int64): Boolean;

implementation

const
  ALFABETO_BASE32 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

function DecodificarBase32(const psSegredo: string): TBytes;
var
  iBuffer: UInt64;
  iBitsNoBuffer, iPos, iChar: Integer;
  cChar: Char;
  iValor: Integer;
  sLimpo: string;
begin
  sLimpo := UpperCase(psSegredo).Replace(' ', '').Replace('-', '').Replace('=', '');
  SetLength(Result, (Length(sLimpo) * 5) div 8);

  iBuffer := 0;
  iBitsNoBuffer := 0;
  iPos := 0;

  for iChar := 1 to Length(sLimpo) do
  begin
    cChar := sLimpo[iChar];
    iValor := Pos(cChar, ALFABETO_BASE32) - 1;
    if iValor < 0 then
      raise EArgumentException.CreateFmt('Caractere Base32 inv'#$00E1'lido: %s', [cChar]);

    iBuffer := (iBuffer shl 5) or UInt64(iValor);
    Inc(iBitsNoBuffer, 5);

    if iBitsNoBuffer >= 8 then
    begin
      Dec(iBitsNoBuffer, 8);
      Result[iPos] := Byte((iBuffer shr iBitsNoBuffer) and $FF);
      Inc(iPos);
    end;
  end;

  SetLength(Result, iPos);
end;

function CodificarBase32(const poDados: TBytes): string;
var
  iBuffer: UInt64;
  iBitsNoBuffer, iPos: Integer;
begin
  Result := '';
  iBuffer := 0;
  iBitsNoBuffer := 0;

  for iPos := 0 to High(poDados) do
  begin
    iBuffer := (iBuffer shl 8) or poDados[iPos];
    Inc(iBitsNoBuffer, 8);

    while iBitsNoBuffer >= 5 do
    begin
      Dec(iBitsNoBuffer, 5);
      Result := Result + ALFABETO_BASE32[((iBuffer shr iBitsNoBuffer) and $1F) + 1];
    end;
  end;

  if iBitsNoBuffer > 0 then
    Result := Result + ALFABETO_BASE32[((iBuffer shl (5 - iBitsNoBuffer)) and $1F) + 1];
end;

function GerarSegredoBase32: string;
begin
  Result := CodificarBase32(GerarBytesAleatorios(20));
end;

function CodificarOtp(const psTexto: string): string;
var
  oBytes: TBytes;
  iPos: Integer;
  iByte: Byte;
begin
  oBytes := TEncoding.UTF8.GetBytes(psTexto);
  Result := '';
  for iPos := 0 to High(oBytes) do
  begin
    iByte := oBytes[iPos];
    if CharInSet(AnsiChar(iByte), ['A'..'Z', 'a'..'z', '0'..'9', '-', '.', '_', '~']) then
      Result := Result + Chr(iByte)
    else
      Result := Result + '%' + IntToHex(iByte, 2);
  end;
end;

function MontarUriProvisionamento(const psEmissor, psConta, psSegredoBase32: string): string;
begin
  Result := Format('otpauth://totp/%s:%s?secret=%s&issuer=%s',
    [CodificarOtp(psEmissor), CodificarOtp(psConta), psSegredoBase32, CodificarOtp(psEmissor)]);
end;

function ContadorParaBytes(piContador: Int64): TBytes;
var
  iPos: Integer;
  iValor: Int64;
begin
  iValor := piContador;
  SetLength(Result, 8);
  for iPos := 7 downto 0 do
  begin
    Result[iPos] := Byte(iValor and $FF);
    iValor := iValor shr 8;
  end;
end;

function CalcularHotp(const poSegredo: TBytes; piContador: Int64): string;
var
  oHash: TBytes;
  iOffset, iDigito: Integer;
  iCodigoBin: UInt32;
  iModulo: UInt32;
begin
  oHash := HMACSHA1(poSegredo, ContadorParaBytes(piContador));

  iOffset := oHash[High(oHash)] and $0F;
  iCodigoBin := ((UInt32(oHash[iOffset])     and $7F) shl 24) or
                ((UInt32(oHash[iOffset + 1]) and $FF) shl 16) or
                ((UInt32(oHash[iOffset + 2]) and $FF) shl 8)  or
                 (UInt32(oHash[iOffset + 3]) and $FF);

  iModulo := 1;
  for iDigito := 1 to TOTP_DIGITOS do
    iModulo := iModulo * 10;

  Result := Format('%.*d', [TOTP_DIGITOS, iCodigoBin mod iModulo]);
end;

function SomenteDigitos(const psTexto: string): Boolean;
var
  iPos: Integer;
begin
  Result := psTexto <> '';
  for iPos := 1 to Length(psTexto) do
    if not CharInSet(psTexto[iPos], ['0'..'9']) then
      Exit(False);
end;

function CalcularPassoAtual(pdtInstante: TDateTime): Int64;
begin
  Result := DateTimeToUnix(pdtInstante, False) div TOTP_PASSO_SEGUNDOS;
end;

function GerarCodigoTotp(const psSegredoBase32: string; pdtInstante: TDateTime): string;
begin
  Result := CalcularHotp(DecodificarBase32(psSegredoBase32), CalcularPassoAtual(pdtInstante));
end;

function ValidarCodigoTotp(const psSegredoBase32, psCodigoDigitado: string;
  var piUltimoPassoAceito: Int64): Boolean;
var
  oSegredo: TBytes;
  iPassoAtual, iPasso: Int64;
  iDelta: Integer;
begin
  Result := False;

  if (Length(psCodigoDigitado) <> TOTP_DIGITOS) or not SomenteDigitos(psCodigoDigitado) then
    Exit(False);

  oSegredo := DecodificarBase32(psSegredoBase32);
  iPassoAtual := CalcularPassoAtual(Now);

  for iDelta := -TOTP_TOLERANCIA_PASSOS to TOTP_TOLERANCIA_PASSOS do
  begin
    iPasso := iPassoAtual + iDelta;

    if iPasso <= piUltimoPassoAceito then
      Continue;

    if CalcularHotp(oSegredo, iPasso) = psCodigoDigitado then
    begin
      piUltimoPassoAceito := iPasso;
      Exit(True);
    end;
  end;
end;

end.
