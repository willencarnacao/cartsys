unit uSmtpConfig;

interface

uses
  System.SysUtils, FireDAC.Comp.Client, uConfig;

type
  TSmtpDAO = class
  private
    FoConexao: TFDConnection;
    FoChave: TBytes;
    FsArquivoIni: string;
    procedure GarantirTabela;
    procedure GarantirColunaNome;
    procedure ApagarSenhaDoIni;
  public
    constructor Create(poConexao: TFDConnection; const poChave: TBytes;
      const psArquivoIni: string);
    function Carregar(const prPadrao: TConfigSmtp): TConfigSmtp;
    procedure Gravar(const prSmtp: TConfigSmtp);
  end;

implementation

uses
  Data.DB, System.IniFiles, uCripto;

constructor TSmtpDAO.Create(poConexao: TFDConnection; const poChave: TBytes;
  const psArquivoIni: string);
begin
  inherited Create;
  FoConexao := poConexao;
  FoChave := poChave;
  FsArquivoIni := psArquivoIni;
  GarantirTabela;
  GarantirColunaNome;
end;

procedure TSmtpDAO.GarantirTabela;
var
  oQry: TFDQuery;
begin
  oQry := TFDQuery.Create(nil);
  try
    oQry.Connection := FoConexao;
    oQry.SQL.Text :=
      'SELECT 1 FROM RDB$RELATIONS WHERE TRIM(RDB$RELATION_NAME) = ''CONFIG_SMTP''';
    oQry.Open;
    if not oQry.IsEmpty then
      Exit;
  finally
    oQry.Free;
  end;

  FoConexao.ExecSQL(
    'CREATE TABLE CONFIG_SMTP (' +
    '  ID            SMALLINT NOT NULL,' +
    '  SERVIDOR      VARCHAR(200) DEFAULT '''' NOT NULL,' +
    '  PORTA         INTEGER DEFAULT 587 NOT NULL,' +
    '  USUARIO       VARCHAR(200) DEFAULT '''' NOT NULL,' +
    '  SENHA_CIFRADA VARCHAR(1000) DEFAULT '''' NOT NULL,' +
    '  USAR_TLS      SMALLINT DEFAULT 1 NOT NULL,' +
    '  REMETENTE     VARCHAR(200) DEFAULT '''' NOT NULL,' +
    '  NOME          VARCHAR(120) DEFAULT '''' NOT NULL,' +
    '  CONSTRAINT PK_CONFIG_SMTP PRIMARY KEY (ID))');
end;

procedure TSmtpDAO.GarantirColunaNome;
var
  oQry: TFDQuery;
begin
  oQry := TFDQuery.Create(nil);
  try
    oQry.Connection := FoConexao;
    oQry.SQL.Text :=
      'SELECT 1 FROM RDB$RELATION_FIELDS ' +
      ' WHERE TRIM(RDB$RELATION_NAME) = ''CONFIG_SMTP'' ' +
      '   AND TRIM(RDB$FIELD_NAME) = ''NOME''';
    oQry.Open;
    if not oQry.IsEmpty then
      Exit;
  finally
    oQry.Free;
  end;
  FoConexao.ExecSQL(
    'ALTER TABLE CONFIG_SMTP ADD NOME VARCHAR(120) DEFAULT '''' NOT NULL');
end;

procedure TSmtpDAO.ApagarSenhaDoIni;
var
  oIni: TIniFile;
begin
  if (FsArquivoIni = '') or not FileExists(FsArquivoIni) then
    Exit;
  oIni := TIniFile.Create(FsArquivoIni);
  try
    oIni.DeleteKey('Smtp', 'Senha');
  finally
    oIni.Free;
  end;
end;

function TSmtpDAO.Carregar(const prPadrao: TConfigSmtp): TConfigSmtp;
var
  oQry: TFDQuery;
  sCifrada: string;
begin
  Result := prPadrao;
  oQry := TFDQuery.Create(nil);
  try
    oQry.Connection := FoConexao;
    oQry.SQL.Text :=
      'SELECT SERVIDOR, PORTA, USUARIO, SENHA_CIFRADA, USAR_TLS, REMETENTE, NOME ' +
      '  FROM CONFIG_SMTP WHERE ID = 1';
    oQry.Open;
    if oQry.IsEmpty then
      Exit;

    Result.Servidor := oQry.FieldByName('SERVIDOR').AsString;
    Result.Porta := oQry.FieldByName('PORTA').AsInteger;
    Result.Usuario := oQry.FieldByName('USUARIO').AsString;
    Result.UsarTLS := oQry.FieldByName('USAR_TLS').AsInteger = 1;
    Result.Remetente := oQry.FieldByName('REMETENTE').AsString;
    Result.Nome := oQry.FieldByName('NOME').AsString;
    sCifrada := Trim(oQry.FieldByName('SENHA_CIFRADA').AsString);
    if sCifrada = '' then
      Result.Senha := ''
    else
      Result.Senha := TEncoding.UTF8.GetString(DecifrarSegredo(sCifrada, FoChave));
  finally
    oQry.Free;
  end;
end;

procedure TSmtpDAO.Gravar(const prSmtp: TConfigSmtp);
var
  oQry: TFDQuery;
  sCifrada: string;
  bExiste: Boolean;

  procedure PreencherParametros;
  begin
    oQry.ParamByName('pServidor').AsString := prSmtp.Servidor;
    oQry.ParamByName('pPorta').AsInteger := prSmtp.Porta;
    oQry.ParamByName('pUsuario').AsString := prSmtp.Usuario;
    oQry.ParamByName('pSenha').AsString := sCifrada;
    if prSmtp.UsarTLS then
      oQry.ParamByName('pTls').AsInteger := 1
    else
      oQry.ParamByName('pTls').AsInteger := 0;
    oQry.ParamByName('pRemetente').AsString := prSmtp.Remetente;
    oQry.ParamByName('pNome').AsString := prSmtp.Nome;
  end;

begin
  if Trim(prSmtp.Senha) = '' then
    raise Exception.Create('Informe a senha SMTP.');

  sCifrada := CifrarSegredo(TEncoding.UTF8.GetBytes(prSmtp.Senha), FoChave);
  oQry := TFDQuery.Create(nil);
  try
    oQry.Connection := FoConexao;
    oQry.SQL.Text := 'SELECT 1 FROM CONFIG_SMTP WHERE ID = 1';
    oQry.Open;
    bExiste := not oQry.IsEmpty;
    oQry.Close;

    if bExiste then
      oQry.SQL.Text :=
        'UPDATE CONFIG_SMTP SET SERVIDOR = :pServidor, PORTA = :pPorta, ' +
      '  USUARIO = :pUsuario, SENHA_CIFRADA = :pSenha, USAR_TLS = :pTls, ' +
      '  REMETENTE = :pRemetente, NOME = :pNome WHERE ID = 1'
    else
      oQry.SQL.Text :=
        'INSERT INTO CONFIG_SMTP (ID, SERVIDOR, PORTA, USUARIO, SENHA_CIFRADA, ' +
        '  USAR_TLS, REMETENTE, NOME) VALUES (1, :pServidor, :pPorta, :pUsuario, ' +
        '  :pSenha, :pTls, :pRemetente, :pNome)';
    PreencherParametros;
    oQry.ExecSQL;
  finally
    oQry.Free;
  end;
  ApagarSenhaDoIni;
end;

end.
