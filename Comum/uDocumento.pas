unit uDocumento;

interface

function SoDigitos(const psValor: string): string;
function ValidarDocumento(const psValor: string; pbPessoaJuridica: Boolean): Boolean;

implementation

uses
  System.SysUtils;

function SoDigitos(const psValor: string): string;
var
  iPos: Integer;
begin
  Result := '';
  for iPos := 1 to Length(psValor) do
    if CharInSet(psValor[iPos], ['0'..'9']) then
      Result := Result + psValor[iPos];
end;

function CalcularDigitoCpf(const psBase: string; piPesoInicial: Integer): Integer;
var
  iPos, iSoma, iPeso: Integer;
begin
  iSoma := 0;
  iPeso := piPesoInicial;
  for iPos := 1 to Length(psBase) do
  begin
    iSoma := iSoma + (Ord(psBase[iPos]) - Ord('0')) * iPeso;
    Dec(iPeso);
  end;
  Result := 11 - (iSoma mod 11);
  if Result >= 10 then
    Result := 0;
end;

function CalcularDigitoCnpj(const psBase: string; const paPesos: array of Integer): Integer;
var
  iPos, iSoma: Integer;
begin
  iSoma := 0;
  for iPos := 0 to High(paPesos) do
    iSoma := iSoma + (Ord(psBase[iPos + 1]) - Ord('0')) * paPesos[iPos];
  Result := 11 - (iSoma mod 11);
  if Result >= 10 then
    Result := 0;
end;

function TodosDigitosIguais(const psValor: string): Boolean;
var
  iPos: Integer;
begin
  Result := True;
  for iPos := 2 to Length(psValor) do
    if psValor[iPos] <> psValor[1] then
      Exit(False);
end;

function ValidarDocumento(const psValor: string; pbPessoaJuridica: Boolean): Boolean;
var
  sDoc, sBase: string;
  iD1, iD2: Integer;
begin
  sDoc := SoDigitos(psValor);
  if TodosDigitosIguais(sDoc) then
    Exit(False);

  if not pbPessoaJuridica then
  begin
    if Length(sDoc) <> 11 then
      Exit(False);
    sBase := Copy(sDoc, 1, 9);
    iD1 := CalcularDigitoCpf(sBase, 10);
    iD2 := CalcularDigitoCpf(sBase + IntToStr(iD1), 11);
    Result := (sDoc[10] = Chr(Ord('0') + iD1)) and (sDoc[11] = Chr(Ord('0') + iD2));
  end
  else
  begin
    if Length(sDoc) <> 14 then
      Exit(False);
    sBase := Copy(sDoc, 1, 12);
    iD1 := CalcularDigitoCnpj(sBase, [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]);
    iD2 := CalcularDigitoCnpj(sBase + IntToStr(iD1), [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]);
    Result := (sDoc[13] = Chr(Ord('0') + iD1)) and (sDoc[14] = Chr(Ord('0') + iD2));
  end;
end;

end.
