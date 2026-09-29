unit uCripto;

interface

uses
  System.SysUtils, System.NetEncoding, Winapi.Windows, uHashUtils;

function GerarBytesAleatorios(piQuantidade: Integer): TBytes;

function CifrarSegredo(const poTextoClaro: TBytes; const poChaveMestra: TBytes): string;

function DecifrarSegredo(const psTextoCifradoBase64: string;
  const poChaveMestra: TBytes): TBytes;

implementation

const
  BCRYPT_AES_ALGORITHM = 'AES';
  BCRYPT_OBJECT_LENGTH = 'ObjectLength';
  BCRYPT_BLOCK_LENGTH  = 'BlockLength';
  BCRYPT_CHAINING_MODE = 'ChainingMode';
  BCRYPT_CHAIN_MODE_CBC: string = 'ChainingModeCBC';
  BCRYPT_BLOCK_PADDING = $00000001;
  STATUS_SUCCESS = 0;
  TAMANHO_IV = 16;
  TAMANHO_MAC = 32;

type
  TBCryptStatus = LongInt;
  BCRYPT_ALG_HANDLE = Pointer;
  BCRYPT_KEY_HANDLE = Pointer;

function BCryptOpenAlgorithmProvider(var phAlgorithm: BCRYPT_ALG_HANDLE;
  pszAlgId: PWideChar; pszImplementation: PWideChar; dwFlags: ULONG): TBCryptStatus;
  stdcall; external 'bcrypt.dll';

function BCryptCloseAlgorithmProvider(hAlgorithm: BCRYPT_ALG_HANDLE;
  dwFlags: ULONG): TBCryptStatus; stdcall; external 'bcrypt.dll';

function BCryptSetProperty(hObject: Pointer; pszProperty: PWideChar;
  pbInput: Pointer; cbInput: ULONG; dwFlags: ULONG): TBCryptStatus;
  stdcall; external 'bcrypt.dll';

function BCryptGetProperty(hObject: Pointer; pszProperty: PWideChar;
  pbOutput: PByte; cbOutput: ULONG; var pcbResult: ULONG; dwFlags: ULONG): TBCryptStatus;
  stdcall; external 'bcrypt.dll';

function BCryptGenerateSymmetricKey(hAlgorithm: BCRYPT_ALG_HANDLE;
  var phKey: BCRYPT_KEY_HANDLE; pbKeyObject: PByte; cbKeyObject: ULONG;
  pbSecret: PByte; cbSecret: ULONG; dwFlags: ULONG): TBCryptStatus;
  stdcall; external 'bcrypt.dll';

function BCryptDestroyKey(hKey: BCRYPT_KEY_HANDLE): TBCryptStatus;
  stdcall; external 'bcrypt.dll';

function BCryptEncrypt(hKey: BCRYPT_KEY_HANDLE; pbInput: PByte; cbInput: ULONG;
  pPaddingInfo: Pointer; pbIV: PByte; cbIV: ULONG; pbOutput: PByte;
  cbOutput: ULONG; var pcbResult: ULONG; dwFlags: ULONG): TBCryptStatus;
  stdcall; external 'bcrypt.dll';

function BCryptDecrypt(hKey: BCRYPT_KEY_HANDLE; pbInput: PByte; cbInput: ULONG;
  pPaddingInfo: Pointer; pbIV: PByte; cbIV: ULONG; pbOutput: PByte;
  cbOutput: ULONG; var pcbResult: ULONG; dwFlags: ULONG): TBCryptStatus;
  stdcall; external 'bcrypt.dll';

function BCryptGenRandom(hAlgorithm: BCRYPT_ALG_HANDLE; pbBuffer: PByte;
  cbBuffer: ULONG; dwFlags: ULONG): TBCryptStatus; stdcall; external 'bcrypt.dll';

function ConcatenarBytes(const poA, poB: TBytes): TBytes;
begin
  SetLength(Result, Length(poA) + Length(poB));
  if Length(poA) > 0 then
    Move(poA[0], Result[0], Length(poA));
  if Length(poB) > 0 then
    Move(poB[0], Result[Length(poA)], Length(poB));
end;

procedure VerificarStatus(piStatus: TBCryptStatus; const psOperacao: string);
begin
  if piStatus <> STATUS_SUCCESS then
    raise Exception.CreateFmt('Falha na CNG (%s): status 0x%.8x', [psOperacao, piStatus]);
end;

function GerarBytesAleatorios(piQuantidade: Integer): TBytes;
var
  oAlg: BCRYPT_ALG_HANDLE;
  iStatus: TBCryptStatus;
begin
  iStatus := BCryptOpenAlgorithmProvider(oAlg, 'RNG', nil, 0);
  VerificarStatus(iStatus, 'abrir provedor RNG');
  try
    SetLength(Result, piQuantidade);
    iStatus := BCryptGenRandom(oAlg, @Result[0], piQuantidade, 0);
    VerificarStatus(iStatus, 'gerar aleat'#$00F3'rios');
  finally
    BCryptCloseAlgorithmProvider(oAlg, 0);
  end;
end;

procedure AbrirChaveAES(const poChave: TBytes; out poAlg: BCRYPT_ALG_HANDLE;
  out poKey: BCRYPT_KEY_HANDLE; out poObjetoChave: TBytes);
var
  iStatus: TBCryptStatus;
  iTamanhoObjeto, iTamanhoRetornado: ULONG;
begin
  iStatus := BCryptOpenAlgorithmProvider(poAlg, BCRYPT_AES_ALGORITHM, nil, 0);
  VerificarStatus(iStatus, 'abrir provedor AES');

  iStatus := BCryptSetProperty(poAlg, BCRYPT_CHAINING_MODE,
    @BCRYPT_CHAIN_MODE_CBC[1], (Length(BCRYPT_CHAIN_MODE_CBC) + 1) * SizeOf(Char), 0);
  VerificarStatus(iStatus, 'definir modo CBC');

  iStatus := BCryptGetProperty(poAlg, BCRYPT_OBJECT_LENGTH, @iTamanhoObjeto,
    SizeOf(iTamanhoObjeto), iTamanhoRetornado, 0);
  VerificarStatus(iStatus, 'obter tamanho do objeto de chave');

  SetLength(poObjetoChave, iTamanhoObjeto);

  iStatus := BCryptGenerateSymmetricKey(poAlg, poKey, @poObjetoChave[0],
    iTamanhoObjeto, @poChave[0], Length(poChave), 0);
  VerificarStatus(iStatus, 'gerar chave sim'#$00E9'trica');
end;

function CifrarSegredo(const poTextoClaro: TBytes; const poChaveMestra: TBytes): string;
var
  oAlg: BCRYPT_ALG_HANDLE;
  oKey: BCRYPT_KEY_HANDLE;
  oObjetoChave, oIV, oIVTrabalho, oCifrado, oMac, oSaida: TBytes;
  iStatus: TBCryptStatus;
  iTamanhoCifrado: ULONG;
begin
  if Length(poChaveMestra) <> 32 then
    raise EArgumentException.Create('Chave mestra precisa ter 32 bytes (AES-256).');

  AbrirChaveAES(poChaveMestra, oAlg, oKey, oObjetoChave);
  try
    oIV := GerarBytesAleatorios(TAMANHO_IV);
    oIVTrabalho := Copy(oIV, 0, TAMANHO_IV);

    BCryptEncrypt(oKey, @poTextoClaro[0], Length(poTextoClaro), nil,
      @oIVTrabalho[0], TAMANHO_IV, nil, 0, iTamanhoCifrado, BCRYPT_BLOCK_PADDING);

    SetLength(oCifrado, iTamanhoCifrado);
    oIVTrabalho := Copy(oIV, 0, TAMANHO_IV);
    iStatus := BCryptEncrypt(oKey, @poTextoClaro[0], Length(poTextoClaro), nil,
      @oIVTrabalho[0], TAMANHO_IV, @oCifrado[0], iTamanhoCifrado, iTamanhoCifrado,
      BCRYPT_BLOCK_PADDING);
    VerificarStatus(iStatus, 'cifrar');

    oMac := HMACSHA256(HMACSHA256(poChaveMestra, TEncoding.ASCII.GetBytes('MAC')),
      ConcatenarBytes(Copy(oIV, 0, TAMANHO_IV), oCifrado));

    SetLength(oSaida, TAMANHO_IV + Length(oCifrado) + TAMANHO_MAC);
    Move(oIV[0], oSaida[0], TAMANHO_IV);
    Move(oCifrado[0], oSaida[TAMANHO_IV], Length(oCifrado));
    Move(oMac[0], oSaida[TAMANHO_IV + Length(oCifrado)], TAMANHO_MAC);

    Result := TNetEncoding.Base64.EncodeBytesToString(oSaida);
  finally
    BCryptDestroyKey(oKey);
    BCryptCloseAlgorithmProvider(oAlg, 0);
  end;
end;

function DecifrarSegredo(const psTextoCifradoBase64: string;
  const poChaveMestra: TBytes): TBytes;
var
  oAlg: BCRYPT_ALG_HANDLE;
  oKey: BCRYPT_KEY_HANDLE;
  oObjetoChave, oDados, oIV, oIVTrabalho, oCifrado, oMacRecebido, oMacCalculado: TBytes;
  iStatus: TBCryptStatus;
  iTamanhoClaro: ULONG;
begin
  if Length(poChaveMestra) <> 32 then
    raise EArgumentException.Create('Chave mestra precisa ter 32 bytes (AES-256).');

  oDados := TNetEncoding.Base64.DecodeStringToBytes(psTextoCifradoBase64);
  if Length(oDados) < TAMANHO_IV + TAMANHO_MAC then
    raise EArgumentException.Create('Dado cifrado inv'#$00E1'lido ou corrompido.');

  oIV := Copy(oDados, 0, TAMANHO_IV);
  oCifrado := Copy(oDados, TAMANHO_IV, Length(oDados) - TAMANHO_IV - TAMANHO_MAC);
  oMacRecebido := Copy(oDados, Length(oDados) - TAMANHO_MAC, TAMANHO_MAC);

  oMacCalculado := HMACSHA256(HMACSHA256(poChaveMestra, TEncoding.ASCII.GetBytes('MAC')),
    ConcatenarBytes(oIV, oCifrado));

  if not CompareMem(@oMacCalculado[0], @oMacRecebido[0], TAMANHO_MAC) then
    raise EArgumentException.Create('Falha de integridade: segredo cifrado adulterado ou chave incorreta.');

  AbrirChaveAES(poChaveMestra, oAlg, oKey, oObjetoChave);
  try
    oIVTrabalho := Copy(oIV, 0, TAMANHO_IV);
    SetLength(Result, Length(oCifrado));
    iStatus := BCryptDecrypt(oKey, @oCifrado[0], Length(oCifrado), nil,
      @oIVTrabalho[0], TAMANHO_IV, @Result[0], Length(oCifrado), iTamanhoClaro,
      BCRYPT_BLOCK_PADDING);
    VerificarStatus(iStatus, 'decifrar');
    SetLength(Result, iTamanhoClaro);
  finally
    BCryptDestroyKey(oKey);
    BCryptCloseAlgorithmProvider(oAlg, 0);
  end;
end;

end.

