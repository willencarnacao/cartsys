unit uHashUtils;

interface

uses
  System.SysUtils, System.Hash;

function HMACSHA256(const poChave, poMensagem: TBytes): TBytes;
function HMACSHA1(const poChave, poMensagem: TBytes): TBytes;

implementation

const
  SHA256_BLOCO = 64;

type
  THashFunc = reference to function(const poDados: TBytes): TBytes;

function AjustarChave(const poChave: TBytes; piTamanhoBloco: Integer;
  poHashFunc: THashFunc): TBytes;
var
  oBase: TBytes;
begin
  if Length(poChave) > piTamanhoBloco then
    oBase := poHashFunc(poChave)
  else
    oBase := Copy(poChave, 0, Length(poChave));

  SetLength(Result, piTamanhoBloco);
  FillChar(Result[0], piTamanhoBloco, 0);
  if Length(oBase) > 0 then
    Move(oBase[0], Result[0], Length(oBase));
end;

function ConcatenarBytes(const poA, poB: TBytes): TBytes;
begin
  SetLength(Result, Length(poA) + Length(poB));
  if Length(poA) > 0 then
    Move(poA[0], Result[0], Length(poA));
  if Length(poB) > 0 then
    Move(poB[0], Result[Length(poA)], Length(poB));
end;

function HMACGenerico(const poChave, poMensagem: TBytes; piTamanhoBloco: Integer;
  poHashFunc: THashFunc): TBytes;
var
  oChave, oIpad, oOpad, oInterno: TBytes;
  iPos: Integer;
begin
  oChave := AjustarChave(poChave, piTamanhoBloco, poHashFunc);

  SetLength(oIpad, piTamanhoBloco);
  SetLength(oOpad, piTamanhoBloco);
  for iPos := 0 to piTamanhoBloco - 1 do
  begin
    oIpad[iPos] := oChave[iPos] xor $36;
    oOpad[iPos] := oChave[iPos] xor $5C;
  end;

  oInterno := poHashFunc(ConcatenarBytes(oIpad, poMensagem));
  Result := poHashFunc(ConcatenarBytes(oOpad, oInterno));
end;

function HashSHA256Bytes(const poDados: TBytes): TBytes;
var
  oHash: THashSHA2;
begin
  oHash := THashSHA2.Create(SHA256);
  oHash.Update(poDados);
  Result := oHash.HashAsBytes;
end;

function HMACSHA256(const poChave, poMensagem: TBytes): TBytes;
begin
  Result := HMACGenerico(poChave, poMensagem, SHA256_BLOCO, HashSHA256Bytes);
end;

function HMACSHA1(const poChave, poMensagem: TBytes): TBytes;
begin
  Result := THashSHA1.GetHMACAsBytes(poMensagem, poChave);
end;

end.
