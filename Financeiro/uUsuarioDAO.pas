unit uUsuarioDAO;

interface

uses
  System.SysUtils, FireDAC.Comp.Client, FireDAC.Stan.Param, uSenha, uTotp, uCripto;

type
  TUsuarioDAO = class
  private
    FoConexao: TFDConnection;
    FoChaveMestraTotp: TBytes;
    FsEmissorTotp: string;
    function GerarSenhaTemporaria: string;
  public
    constructor Create(poConexao: TFDConnection; const poChaveMestraTotp: TBytes;
      const psEmissorTotp: string);

    function Listar: TFDQuery;

    function LoginExiste(const psLogin: string; piIdIgnorar: Int64 = 0): Boolean;

    function Inserir(const psLogin, psNome, psEmail: string;
      pbIsAdmin, pbAcessaVendas, pbAcessaFinanceiro: Boolean;
      out psSenhaTemporaria: string): Int64;

    procedure Atualizar(piId: Int64; const psNome, psEmail: string;
      pbIsAdmin, pbAcessaVendas, pbAcessaFinanceiro, pbAtivo: Boolean);

    function RedefinirSenha(piId: Int64): string;
  end;

implementation

uses
  Data.DB, System.Variants, uDados;

constructor TUsuarioDAO.Create(poConexao: TFDConnection;
  const poChaveMestraTotp: TBytes; const psEmissorTotp: string);
begin
  inherited Create;
  FoConexao := poConexao;
  FoChaveMestraTotp := poChaveMestraTotp;
  FsEmissorTotp := psEmissorTotp;
end;

function TUsuarioDAO.GerarSenhaTemporaria: string;
const
  ALFABETO = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789';
var
  oBytes: TBytes;
  iPos: Integer;
begin
  oBytes := GerarBytesAleatorios(14);
  Result := '';
  for iPos := 0 to High(oBytes) do
    Result := Result + ALFABETO[(oBytes[iPos] mod Length(ALFABETO)) + 1];
end;

function TUsuarioDAO.Listar: TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := FoConexao;
  Result.SQL.Text :=
    'SELECT ID, LOGIN, NOME, EMAIL, IS_ADMIN, ACESSA_VENDAS, ACESSA_FINANCEIRO, ' +
    '       ATIVO, BLOQUEADO, FALHAS_CONSECUTIVAS, TOTP_CONFIRMADO, ULTIMO_LOGIN ' +
    '  FROM USUARIO ' +
    ' ORDER BY NOME';
  Result.Open;
end;

function TUsuarioDAO.LoginExiste(const psLogin: string; piIdIgnorar: Int64): Boolean;
var
  oQry: TFDQuery;
begin
  oQry := TFDQuery.Create(nil);
  try
    oQry.Connection := FoConexao;
    oQry.SQL.Text := 'SELECT 1 FROM USUARIO WHERE LOGIN = :pLogin AND ID <> :pId';
    oQry.ParamByName('pLogin').AsString := psLogin;
    oQry.ParamByName('pId').AsLargeInt := piIdIgnorar;
    oQry.Open;
    Result := not oQry.IsEmpty;
  finally
    oQry.Free;
  end;
end;

function TUsuarioDAO.Inserir(const psLogin, psNome, psEmail: string; pbIsAdmin,
  pbAcessaVendas, pbAcessaFinanceiro: Boolean; out psSenhaTemporaria: string): Int64;
var
  oQry: TFDQuery;
  rSenha: TSenhaGerada;
  sSegredoBase32, sSegredoCifrado: string;
begin
  if Trim(psLogin) = '' then
    raise EArgumentException.Create('Login '#$00E9' obrigat'#$00F3'rio.');
  if LoginExiste(psLogin) then
    raise EArgumentException.CreateFmt('J'#$00E1' existe um usu'#$00E1'rio com o login "%s".', [psLogin]);

  psSenhaTemporaria := GerarSenhaTemporaria;
  rSenha := GerarHashSenha(psSenhaTemporaria);

  sSegredoBase32 := GerarSegredoBase32;
  sSegredoCifrado := CifrarSegredo(TEncoding.ASCII.GetBytes(sSegredoBase32), FoChaveMestraTotp);

  oQry := TFDQuery.Create(nil);
  try
    oQry.Connection := FoConexao;
    oQry.SQL.Text :=
      'INSERT INTO USUARIO (LOGIN, NOME, EMAIL, SENHA_HASH, SENHA_SALT, ' +
      '  SENHA_ITERACOES, SENHA_TEMPORARIA, TOTP_SEGREDO_CIFRADO, TOTP_CONFIRMADO, ' +
      '  IS_ADMIN, ACESSA_VENDAS, ACESSA_FINANCEIRO, ATIVO) ' +
      'VALUES (:pLogin, :pNome, :pEmail, :pHash, :pSalt, :pIter, 1, :pTotp, 0, ' +
      '  :pAdmin, :pVendas, :pFinanceiro, 1) ' +
      'RETURNING ID';
    oQry.ParamByName('pLogin').AsString := Trim(psLogin);
    oQry.ParamByName('pNome').AsString := Trim(psNome);
    if Trim(psEmail) = '' then
      oQry.ParamByName('pEmail').Clear
    else
      oQry.ParamByName('pEmail').AsString := Trim(psEmail);
    oQry.ParamByName('pHash').AsString := rSenha.HashBase64;
    oQry.ParamByName('pSalt').AsString := rSenha.SaltBase64;
    oQry.ParamByName('pIter').AsInteger := rSenha.Iteracoes;
    oQry.ParamByName('pTotp').AsString := sSegredoCifrado;
    oQry.ParamByName('pAdmin').AsInteger := Ord(pbIsAdmin);
    oQry.ParamByName('pVendas').AsInteger := Ord(pbAcessaVendas);
    oQry.ParamByName('pFinanceiro').AsInteger := Ord(pbAcessaFinanceiro);
    oQry.Open;
    Result := oQry.FieldByName('ID').AsLargeInt;
  finally
    oQry.Free;
  end;
end;

procedure TUsuarioDAO.Atualizar(piId: Int64; const psNome, psEmail: string; pbIsAdmin,
  pbAcessaVendas, pbAcessaFinanceiro, pbAtivo: Boolean);
begin
  if Trim(psNome) = '' then
    raise EArgumentException.Create('Nome '#$00E9' obrigat'#$00F3'rio.');

  FoConexao.ExecSQL(
    'UPDATE USUARIO SET NOME = :pNome, EMAIL = :pEmail, IS_ADMIN = :pAdmin, ' +
    '  ACESSA_VENDAS = :pVendas, ACESSA_FINANCEIRO = :pFinanceiro, ATIVO = :pAtivo ' +
    'WHERE ID = :pId',
    [Trim(psNome), TextoOuNulo(psEmail), Ord(pbIsAdmin), Ord(pbAcessaVendas),
     Ord(pbAcessaFinanceiro), Ord(pbAtivo), piId]);
end;

function TUsuarioDAO.RedefinirSenha(piId: Int64): string;
var
  rSenha: TSenhaGerada;
begin
  Result := GerarSenhaTemporaria;
  rSenha := GerarHashSenha(Result);

  FoConexao.ExecSQL(
    'UPDATE USUARIO SET SENHA_HASH = :pHash, SENHA_SALT = :pSalt, ' +
    '  SENHA_ITERACOES = :pIter, SENHA_TEMPORARIA = 1, FALHAS_CONSECUTIVAS = 0 ' +
    'WHERE ID = :pId',
    [rSenha.HashBase64, rSenha.SaltBase64, rSenha.Iteracoes, piId]);
end;

end.

