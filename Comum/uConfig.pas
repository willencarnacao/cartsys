unit uConfig;

interface

uses
  System.SysUtils, System.IniFiles, System.NetEncoding;

type
  TModoBanco = (mbServidor, mbEmbedded);

  TConfigBanco = record
    Modo: TModoBanco;
    Servidor: string;
    Caminho: string;
    Usuario: string;
    Senha: string;
  end;

  TConfigSmtp = record
    Servidor: string;
    Porta: Integer;
    Usuario: string;
    Senha: string;
    UsarTLS: Boolean;
    Remetente: string;
    Nome: string;
  end;

  TConfig = class
  private
    FsArquivo: string;
    function AbrirIni: TIniFile;
  public
    constructor Create(const psArquivoIni: string = '');
    function Banco: TConfigBanco;
    function Smtp: TConfigSmtp;
    function Arquivo: string;
    function ChaveMestraTotp: TBytes;
    function EmissorTotp: string;
  end;

implementation

function ProcurarCartSysIni(const psPastaExe: string): string;
var
  sDir: string;
  iNivel: Integer;
begin
  Result := psPastaExe + 'CartSys.ini';
  if FileExists(Result) then
    Exit;

  Result := ChangeFileExt(ParamStr(0), '.ini');
  if FileExists(Result) then
    Exit;

  sDir := psPastaExe;
  for iNivel := 1 to 3 do
  begin
    sDir := ExpandFileName(sDir + '..\');
    Result := sDir + 'CartSys.ini';
    if FileExists(Result) then
      Exit;
  end;

  Result := psPastaExe + 'CartSys.ini';
end;

constructor TConfig.Create(const psArquivoIni: string);
begin
  inherited Create;
  if psArquivoIni <> '' then
    FsArquivo := psArquivoIni
  else
    FsArquivo := ProcurarCartSysIni(ExtractFilePath(ParamStr(0)));

  if not FileExists(FsArquivo) then
    raise Exception.CreateFmt(
      'Arquivo de configura'#$00E7#$00E3'o n'#$00E3'o encontrado: %s'#13#10 +
      'Copie o CartSys.ini para a pasta do execut'#$00E1'vel.', [FsArquivo]);
end;

function TConfig.Arquivo: string;
begin
  Result := FsArquivo;
end;

function TConfig.AbrirIni: TIniFile;
begin
  Result := TIniFile.Create(FsArquivo);
end;

function TConfig.Banco: TConfigBanco;
var
  oIni: TIniFile;
  sModo: string;
begin
  oIni := AbrirIni;
  try
    sModo := oIni.ReadString('Banco', 'Modo', 'Servidor');
    if SameText(sModo, 'Embedded') then
      Result.Modo := mbEmbedded
    else
      Result.Modo := mbServidor;

    Result.Servidor := oIni.ReadString('Banco', 'Servidor', 'localhost');
    Result.Caminho  := oIni.ReadString('Banco', 'Caminho', '');
    Result.Usuario  := oIni.ReadString('Banco', 'Usuario', 'SYSDBA');
    Result.Senha    := oIni.ReadString('Banco', 'Senha', 'masterkey');

    if Result.Caminho = '' then
      raise Exception.Create('Configura'#$00E7#$00E3'o inv'#$00E1'lida: [Banco] Caminho n'#$00E3'o informado no INI.');
  finally
    oIni.Free;
  end;
end;

function TConfig.Smtp: TConfigSmtp;
var
  oIni: TIniFile;
begin
  oIni := AbrirIni;
  try
    Result.Servidor  := oIni.ReadString('Smtp', 'Servidor', '');
    Result.Porta     := oIni.ReadInteger('Smtp', 'Porta', 587);
    Result.Usuario   := oIni.ReadString('Smtp', 'Usuario', '');
    Result.Senha     := oIni.ReadString('Smtp', 'Senha', '');
    Result.UsarTLS   := oIni.ReadBool('Smtp', 'UsarTLS', True);
    Result.Remetente := oIni.ReadString('Smtp', 'Remetente', Result.Usuario);
    Result.Nome      := '';
  finally
    oIni.Free;
  end;
end;

function TConfig.ChaveMestraTotp: TBytes;
var
  oIni: TIniFile;
  sBase64: string;
begin
  oIni := AbrirIni;
  try
    sBase64 := oIni.ReadString('Totp', 'ChaveMestraBase64', '');
    if sBase64 = '' then
      raise Exception.Create(
        '[Totp] ChaveMestraBase64 n'#$00E3'o informada no INI. ' +
        'Gere 32 bytes aleat'#$00F3'rios uma vez por instala'#$00E7#$00E3'o e grave em Base64 ' +
        '(por exemplo, com o pr'#$00F3'prio uCripto.GerarBytesAleatorios(32)).');

    Result := TNetEncoding.Base64.DecodeStringToBytes(sBase64);
    if Length(Result) <> 32 then
      raise Exception.Create('[Totp] ChaveMestraBase64 precisa decodificar para exatamente 32 bytes.');
  finally
    oIni.Free;
  end;
end;

function TConfig.EmissorTotp: string;
var
  oIni: TIniFile;
begin
  oIni := AbrirIni;
  try
    Result := oIni.ReadString('Totp', 'Emissor', 'CartSys');
  finally
    oIni.Free;
  end;
end;

end.
