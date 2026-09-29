unit uAutenticacao;

interface

uses
  System.SysUtils, System.StrUtils, FireDAC.Comp.Client, FireDAC.Stan.Param, uSenha, uTotp, uCripto, uTipos;

type
  TAutenticacaoService = class
  private
    FoConexao: TFDConnection;
    FoChaveMestraTotp: TBytes;
    FsEmissorTotp: string;

    procedure RegistrarLog(pvUsuarioId: Variant; const psLoginInformado, psModulo: string;
      peResultado: TResultadoLogin; pvAdminId: Variant; const psDetalhe: string = '');
    function BuscarUsuario(const psLogin: string): TFDQuery;
  public
    constructor Create(poConexao: TFDConnection; const poChaveMestraTotp: TBytes;
      const psEmissorTotp: string = 'CartSys');

    function Autenticar(const psLogin, psSenha, psCodigoTotp, psModulo: string;
      out piUsuarioId: Int64; out peResultado: TResultadoLogin;
      out pbPrecisaParear: Boolean; out psUriProvisionamento: string): Boolean;

    function ConfirmarPareamentoTotp(piUsuarioId: Int64;
      const psCodigoDigitado: string): Boolean;

    function PrecisaTrocarSenha(piUsuarioId: Int64): Boolean;

    procedure TrocarSenha(piUsuarioId: Int64; const psSenhaAtual, psNovaSenha: string);

    procedure DesbloquearUsuario(piUsuarioId, piAdminId: Int64);
  end;

implementation

uses
  System.Variants, Data.DB, uDados;

constructor TAutenticacaoService.Create(poConexao: TFDConnection;
  const poChaveMestraTotp: TBytes; const psEmissorTotp: string);
begin
  inherited Create;
  FoConexao := poConexao;
  FoChaveMestraTotp := poChaveMestraTotp;
  FsEmissorTotp := psEmissorTotp;
end;

function TAutenticacaoService.BuscarUsuario(const psLogin: string): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := FoConexao;
  Result.SQL.Text :=
    'SELECT ID, LOGIN, SENHA_HASH, SENHA_SALT, SENHA_ITERACOES, SENHA_TEMPORARIA, ' +
    '       TOTP_SEGREDO_CIFRADO, TOTP_CONFIRMADO, TOTP_ULTIMO_PASSO, ' +
    '       FALHAS_CONSECUTIVAS, BLOQUEADO, ATIVO, ACESSA_VENDAS, ACESSA_FINANCEIRO ' +
    '  FROM USUARIO ' +
    ' WHERE LOGIN = :pLogin';
  Result.ParamByName('pLogin').AsString := psLogin;
  Result.Open;
end;

procedure TAutenticacaoService.RegistrarLog(pvUsuarioId: Variant;
  const psLoginInformado, psModulo: string; peResultado: TResultadoLogin;
  pvAdminId: Variant; const psDetalhe: string);
var
  oQry: TFDQuery;
begin
  oQry := TFDQuery.Create(nil);
  try
    oQry.Connection := FoConexao;
    oQry.SQL.Text :=
      'INSERT INTO LOGIN_LOG (USUARIO_ID, LOGIN_INFORMADO, MODULO, RESULTADO, ADMIN_ID, DETALHE) ' +
      'VALUES (:pUsuarioId, :pLogin, :pModulo, :pResultado, :pAdminId, :pDetalhe)';
    if VarIsNull(pvUsuarioId) then
      LimparParametro(oQry.ParamByName('pUsuarioId'), ftLargeint)
    else
      oQry.ParamByName('pUsuarioId').AsLargeInt := pvUsuarioId;
    oQry.ParamByName('pLogin').AsString := psLoginInformado;
    oQry.ParamByName('pModulo').AsString := psModulo;
    oQry.ParamByName('pResultado').AsInteger := Ord(peResultado);
    if VarIsNull(pvAdminId) then
      LimparParametro(oQry.ParamByName('pAdminId'), ftLargeint)
    else
      oQry.ParamByName('pAdminId').AsLargeInt := pvAdminId;
    if psDetalhe = '' then
      LimparParametro(oQry.ParamByName('pDetalhe'), ftString, 200)
    else
      oQry.ParamByName('pDetalhe').AsString := psDetalhe;
    oQry.ExecSQL;
  finally
    oQry.Free;
  end;
end;

procedure RegistrarFalhaLogin(poConexao: TFDConnection; piUsuarioId: Int64; piFalhas: Integer);
begin
  if piFalhas >= MAX_TENTATIVAS_LOGIN then
    poConexao.ExecSQL(
      'UPDATE USUARIO SET FALHAS_CONSECUTIVAS = :pFalhas, BLOQUEADO = 1, ' +
      'BLOQUEADO_EM = CURRENT_TIMESTAMP WHERE ID = :pId',
      [piFalhas, piUsuarioId])
  else
    poConexao.ExecSQL(
      'UPDATE USUARIO SET FALHAS_CONSECUTIVAS = :pFalhas WHERE ID = :pId',
      [piFalhas, piUsuarioId]);
end;

function TAutenticacaoService.Autenticar(const psLogin, psSenha, psCodigoTotp,
  psModulo: string; out piUsuarioId: Int64; out peResultado: TResultadoLogin;
  out pbPrecisaParear: Boolean; out psUriProvisionamento: string): Boolean;
var
  oQry: TFDQuery;
  iUsuarioId: Int64;
  iFalhas: Integer;
  oSegredoClaro: TBytes;
  sSegredoBase32: string;
  iUltimoPasso: Int64;
  bAcessaModulo: Boolean;
begin
  Result := False;
  pbPrecisaParear := False;
  psUriProvisionamento := '';
  piUsuarioId := 0;

  oQry := BuscarUsuario(psLogin);
  try
    if oQry.IsEmpty then
    begin

      peResultado := rlSenhaInvalida;
      RegistrarLog(Null, psLogin, psModulo, peResultado, Null);
      Exit;
    end;

    iUsuarioId := oQry.FieldByName('ID').AsLargeInt;

    if (oQry.FieldByName('ATIVO').AsInteger = 0) or
       (oQry.FieldByName('BLOQUEADO').AsInteger = 1) then
    begin
      peResultado := rlUsuarioBloqueado;
      RegistrarLog(iUsuarioId, psLogin, psModulo, peResultado, Null);
      Exit;
    end;

    case IndexStr(psModulo, [MODULO_VENDAS, MODULO_FINANCEIRO]) of
      0: bAcessaModulo := oQry.FieldByName('ACESSA_VENDAS').AsInteger = 1;
      1: bAcessaModulo := oQry.FieldByName('ACESSA_FINANCEIRO').AsInteger = 1;
    else
      bAcessaModulo := False;
    end;

    if not uSenha.ConferirSenha(psSenha, oQry.FieldByName('SENHA_HASH').AsString,
         oQry.FieldByName('SENHA_SALT').AsString,
         oQry.FieldByName('SENHA_ITERACOES').AsInteger) or not bAcessaModulo then
    begin

      iFalhas := oQry.FieldByName('FALHAS_CONSECUTIVAS').AsInteger + 1;
      RegistrarFalhaLogin(FoConexao, iUsuarioId, iFalhas);

      if iFalhas >= MAX_TENTATIVAS_LOGIN then
        peResultado := rlBloqueioAplicado
      else
        peResultado := rlSenhaInvalida;

      RegistrarLog(iUsuarioId, psLogin, psModulo, peResultado, Null);
      Exit;
    end;

    if oQry.FieldByName('TOTP_CONFIRMADO').AsInteger = 0 then
    begin
      oSegredoClaro := DecifrarSegredo(oQry.FieldByName('TOTP_SEGREDO_CIFRADO').AsString,
        FoChaveMestraTotp);
      sSegredoBase32 := TEncoding.ASCII.GetString(oSegredoClaro);
      psUriProvisionamento := MontarUriProvisionamento(FsEmissorTotp, psLogin, sSegredoBase32);
      pbPrecisaParear := True;
      piUsuarioId := iUsuarioId;

      Exit(False);
    end;

    oSegredoClaro := DecifrarSegredo(oQry.FieldByName('TOTP_SEGREDO_CIFRADO').AsString,
      FoChaveMestraTotp);
    sSegredoBase32 := TEncoding.ASCII.GetString(oSegredoClaro);

    if oQry.FieldByName('TOTP_ULTIMO_PASSO').IsNull then
      iUltimoPasso := 0
    else
      iUltimoPasso := oQry.FieldByName('TOTP_ULTIMO_PASSO').AsLargeInt;

    if not ValidarCodigoTotp(sSegredoBase32, psCodigoTotp, iUltimoPasso) then
    begin
      iFalhas := oQry.FieldByName('FALHAS_CONSECUTIVAS').AsInteger + 1;
      RegistrarFalhaLogin(FoConexao, iUsuarioId, iFalhas);

      if iFalhas >= MAX_TENTATIVAS_LOGIN then
        peResultado := rlBloqueioAplicado
      else
        peResultado := rlCodigoTotpInvalido;

      RegistrarLog(iUsuarioId, psLogin, psModulo, peResultado, Null);
      Exit;
    end;

    FoConexao.StartTransaction;
    try
      FoConexao.ExecSQL('UPDATE USUARIO SET FALHAS_CONSECUTIVAS = 0, ' +
        'TOTP_ULTIMO_PASSO = :pPasso, ULTIMO_LOGIN = CURRENT_TIMESTAMP ' +
        'WHERE ID = :pId', [iUltimoPasso, iUsuarioId]);
      peResultado := rlSucesso;
      RegistrarLog(iUsuarioId, psLogin, psModulo, peResultado, Null);
      FoConexao.Commit;
    except
      FoConexao.Rollback;
      raise;
    end;

    piUsuarioId := iUsuarioId;
    Result := True;
  finally
    oQry.Free;
  end;
end;

function TAutenticacaoService.ConfirmarPareamentoTotp(piUsuarioId: Int64;
  const psCodigoDigitado: string): Boolean;
var
  oQry: TFDQuery;
  oSegredoClaro: TBytes;
  sSegredoBase32: string;
  iUltimoPasso: Int64;
begin
  oQry := TFDQuery.Create(nil);
  try
    oQry.Connection := FoConexao;
    oQry.SQL.Text := 'SELECT TOTP_SEGREDO_CIFRADO FROM USUARIO WHERE ID = :pId';
    oQry.ParamByName('pId').AsLargeInt := piUsuarioId;
    oQry.Open;

    if oQry.IsEmpty then
      Exit(False);

    oSegredoClaro := DecifrarSegredo(oQry.FieldByName('TOTP_SEGREDO_CIFRADO').AsString,
      FoChaveMestraTotp);
    sSegredoBase32 := TEncoding.ASCII.GetString(oSegredoClaro);
    iUltimoPasso := 0;

    Result := ValidarCodigoTotp(sSegredoBase32, psCodigoDigitado, iUltimoPasso);
    if Result then
    begin
      FoConexao.ExecSQL('UPDATE USUARIO SET TOTP_CONFIRMADO = 1, TOTP_ULTIMO_PASSO = :pPasso, ' +
        'FALHAS_CONSECUTIVAS = 0, ULTIMO_LOGIN = CURRENT_TIMESTAMP WHERE ID = :pId',
        [iUltimoPasso, piUsuarioId]);
      RegistrarLog(piUsuarioId, '', '', rlSucesso, Null, 'Pareamento TOTP');
    end;
  finally
    oQry.Free;
  end;
end;

function TAutenticacaoService.PrecisaTrocarSenha(piUsuarioId: Int64): Boolean;
var
  oQry: TFDQuery;
begin
  oQry := TFDQuery.Create(nil);
  try
    oQry.Connection := FoConexao;
    oQry.SQL.Text := 'SELECT SENHA_TEMPORARIA FROM USUARIO WHERE ID = :pId';
    oQry.ParamByName('pId').AsLargeInt := piUsuarioId;
    oQry.Open;
    Result := (not oQry.IsEmpty) and (oQry.FieldByName('SENHA_TEMPORARIA').AsInteger = 1);
  finally
    oQry.Free;
  end;
end;

procedure TAutenticacaoService.TrocarSenha(piUsuarioId: Int64; const psSenhaAtual,
  psNovaSenha: string);
var
  oQry: TFDQuery;
  rSenha: TSenhaGerada;
begin
  if Length(psNovaSenha) < 8 then
    raise EArgumentException.Create('A nova senha precisa ter pelo menos 8 caracteres.');
  if psNovaSenha = psSenhaAtual then
    raise EArgumentException.Create('A nova senha precisa ser diferente da atual.');

  oQry := TFDQuery.Create(nil);
  try
    oQry.Connection := FoConexao;
    oQry.SQL.Text :=
      'SELECT SENHA_HASH, SENHA_SALT, SENHA_ITERACOES FROM USUARIO WHERE ID = :pId';
    oQry.ParamByName('pId').AsLargeInt := piUsuarioId;
    oQry.Open;
    if oQry.IsEmpty then
      raise Exception.Create('Usu'#$00E1'rio n'#$00E3'o encontrado.');

    if not ConferirSenha(psSenhaAtual, oQry.FieldByName('SENHA_HASH').AsString,
         oQry.FieldByName('SENHA_SALT').AsString,
         oQry.FieldByName('SENHA_ITERACOES').AsInteger) then
      raise EArgumentException.Create('Senha atual n'#$00E3'o confere.');

    rSenha := GerarHashSenha(psNovaSenha);
    FoConexao.ExecSQL(
      'UPDATE USUARIO SET SENHA_HASH = :pHash, SENHA_SALT = :pSalt, ' +
      '  SENHA_ITERACOES = :pIter, SENHA_TEMPORARIA = 0 WHERE ID = :pId',
      [rSenha.HashBase64, rSenha.SaltBase64, rSenha.Iteracoes, piUsuarioId]);
  finally
    oQry.Free;
  end;
end;

procedure TAutenticacaoService.DesbloquearUsuario(piUsuarioId, piAdminId: Int64);
begin
  FoConexao.ExecSQL('UPDATE USUARIO SET FALHAS_CONSECUTIVAS = 0, BLOQUEADO = 0, ' +
    'BLOQUEADO_EM = NULL WHERE ID = :pId', [piUsuarioId]);
  RegistrarLog(piUsuarioId, '', MODULO_FINANCEIRO, rlDesbloqueioAdmin, piAdminId);
end;

end.
