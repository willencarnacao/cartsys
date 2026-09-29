unit uSenha;

interface

uses
  System.SysUtils, System.Math, System.NetEncoding, uHashUtils, uTipos;

type

  TSenhaGerada = record
    HashBase64: string;
    SaltBase64: string;
    Iteracoes: Integer;
  end;

function GerarHashSenha(const psSenha: string;
  piIteracoes: Integer = PBKDF2_ITERACOES_PADRAO): TSenhaGerada;

function ConferirSenha(const psSenha, psHashBase64, psSaltBase64: string;
  piIteracoes: Integer): Boolean;

implementation

uses
  uCripto;

function PBKDF2_HMACSHA256(const poSenha, poSalt: TBytes; piIteracoes,
  piTamanhoChave: Integer): TBytes;
var
  iNumBlocos, iBloco, iIter, iByte: Integer;
  oSaltContador, oU, oT: TBytes;
begin
  iNumBlocos := Integer(Ceil(piTamanhoChave / PBKDF2_TAMANHO_HASH));
  SetLength(Result, iNumBlocos * PBKDF2_TAMANHO_HASH);

  for iBloco := 1 to iNumBlocos do
  begin

    SetLength(oSaltContador, Length(poSalt) + 4);
    Move(poSalt[0], oSaltContador[0], Length(poSalt));
    oSaltContador[Length(poSalt) + 0] := Byte(iBloco shr 24);
    oSaltContador[Length(poSalt) + 1] := Byte(iBloco shr 16);
    oSaltContador[Length(poSalt) + 2] := Byte(iBloco shr 8);
    oSaltContador[Length(poSalt) + 3] := Byte(iBloco);

    oU := HMACSHA256(poSenha, oSaltContador);
    oT := Copy(oU, 0, Length(oU));

    for iIter := 2 to piIteracoes do
    begin
      oU := HMACSHA256(poSenha, oU);
      for iByte := 0 to High(oT) do
        oT[iByte] := oT[iByte] xor oU[iByte];
    end;

    Move(oT[0], Result[(iBloco - 1) * PBKDF2_TAMANHO_HASH], Length(oT));
  end;

  SetLength(Result, piTamanhoChave);
end;

function GerarHashSenha(const psSenha: string; piIteracoes: Integer): TSenhaGerada;
var
  oSaltBytes, oSenhaBytes, oHashBytes: TBytes;
begin
  oSaltBytes := GerarBytesAleatorios(PBKDF2_TAMANHO_SALT);
  oSenhaBytes := TEncoding.UTF8.GetBytes(psSenha);

  oHashBytes := PBKDF2_HMACSHA256(oSenhaBytes, oSaltBytes, piIteracoes,
    PBKDF2_TAMANHO_HASH);

  Result.SaltBase64 := TNetEncoding.Base64.EncodeBytesToString(oSaltBytes);
  Result.HashBase64 := TNetEncoding.Base64.EncodeBytesToString(oHashBytes);
  Result.Iteracoes := piIteracoes;
end;

function CompararTempoConstante(const poA, poB: TBytes): Boolean;
var
  iPos: Integer;
  iDiferenca: Byte;
begin

  if Length(poA) <> Length(poB) then
    Exit(False);

  iDiferenca := 0;
  for iPos := 0 to High(poA) do
    iDiferenca := iDiferenca or (poA[iPos] xor poB[iPos]);

  Result := iDiferenca = 0;
end;

function ConferirSenha(const psSenha, psHashBase64, psSaltBase64: string;
  piIteracoes: Integer): Boolean;
var
  oSaltBytes, oSenhaBytes, oHashEsperado, oHashCalculado: TBytes;
begin
  oSaltBytes := TNetEncoding.Base64.DecodeStringToBytes(psSaltBase64);
  oHashEsperado := TNetEncoding.Base64.DecodeStringToBytes(psHashBase64);
  oSenhaBytes := TEncoding.UTF8.GetBytes(psSenha);

  oHashCalculado := PBKDF2_HMACSHA256(oSenhaBytes, oSaltBytes, piIteracoes,
    Length(oHashEsperado));

  Result := CompararTempoConstante(oHashCalculado, oHashEsperado);
end;

end.
