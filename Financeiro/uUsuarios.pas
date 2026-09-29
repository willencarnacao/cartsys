unit uUsuarios;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.UITypes, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Grids, Vcl.DBGrids, Data.DB, FireDAC.Comp.Client,
  uUsuarioDAO, uAutenticacao, uCadUsuario, uGrade;

type
  TFormUsuarios = class(TForm)
    pnlBotoes: TPanel;
    btnNovo: TButton;
    btnEditar: TButton;
    btnRedefinirSenha: TButton;
    btnDesbloquear: TButton;
    btnFechar: TButton;
    grdUsuarios: TDBGrid;
    dsUsuarios: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure btnEditarClick(Sender: TObject);
    procedure btnRedefinirSenhaClick(Sender: TObject);
    procedure btnDesbloquearClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
  private
    FoDAO: TUsuarioDAO;
    FoAutenticacao: TAutenticacaoService;
    FiAdminLogadoId: Int64;
    FoQryUsuarios: TFDQuery;

    procedure Recarregar;
    function RegistroSelecionado(out piId: Int64; out psLogin, psNome, psEmail: string;
      out pbIsAdmin, pbAcessaVendas, pbAcessaFinanceiro, pbAtivo, pbBloqueado: Boolean): Boolean;
  public
    class procedure Executar(poDAO: TUsuarioDAO; poAutenticacao: TAutenticacaoService;
      piAdminLogadoId: Int64);
  end;

implementation

{$R *.dfm}

class procedure TFormUsuarios.Executar(poDAO: TUsuarioDAO;
  poAutenticacao: TAutenticacaoService; piAdminLogadoId: Int64);
var
  oForm: TFormUsuarios;
begin
  oForm := TFormUsuarios.Create(nil);
  try
    oForm.FoDAO := poDAO;
    oForm.FoAutenticacao := poAutenticacao;
    oForm.FiAdminLogadoId := piAdminLogadoId;
    oForm.Recarregar;
    oForm.ShowModal;
  finally
    oForm.Free;
  end;
end;

procedure TFormUsuarios.FormCreate(Sender: TObject);
begin
  PrepararGrade(grdUsuarios);
end;

procedure TFormUsuarios.FormDestroy(Sender: TObject);
begin
  FoQryUsuarios.Free;
end;

procedure TFormUsuarios.Recarregar;
begin
  dsUsuarios.DataSet := nil;
  FreeAndNil(FoQryUsuarios);
  FoQryUsuarios := FoDAO.Listar;
  dsUsuarios.DataSet := FoQryUsuarios;
  NomearCampo(FoQryUsuarios, 'LOGIN', 'Login');
  NomearCampo(FoQryUsuarios, 'NOME', 'Nome');
  NomearCampo(FoQryUsuarios, 'EMAIL', 'E-mail');
  NomearCampo(FoQryUsuarios, 'IS_ADMIN', 'Admin');
  NomearCampo(FoQryUsuarios, 'ACESSA_VENDAS', 'Vendas');
  NomearCampo(FoQryUsuarios, 'ACESSA_FINANCEIRO', 'Financeiro');
  NomearCampo(FoQryUsuarios, 'ATIVO', 'Ativo');
  NomearCampo(FoQryUsuarios, 'BLOQUEADO', 'Bloqueado');
  NomearCampo(FoQryUsuarios, 'FALHAS_CONSECUTIVAS', 'Falhas');
  NomearCampo(FoQryUsuarios, 'TOTP_CONFIRMADO', '2FA pareado');
  NomearCampo(FoQryUsuarios, 'ULTIMO_LOGIN', #$00DA'ltimo login');
end;

function TFormUsuarios.RegistroSelecionado(out piId: Int64; out psLogin, psNome,
  psEmail: string; out pbIsAdmin, pbAcessaVendas, pbAcessaFinanceiro, pbAtivo,
  pbBloqueado: Boolean): Boolean;
begin
  Result := Assigned(FoQryUsuarios) and not FoQryUsuarios.IsEmpty;
  if not Result then
    Exit;

  piId := FoQryUsuarios.FieldByName('ID').AsLargeInt;
  psLogin := FoQryUsuarios.FieldByName('LOGIN').AsString;
  psNome := FoQryUsuarios.FieldByName('NOME').AsString;
  psEmail := FoQryUsuarios.FieldByName('EMAIL').AsString;
  pbIsAdmin := FoQryUsuarios.FieldByName('IS_ADMIN').AsInteger = 1;
  pbAcessaVendas := FoQryUsuarios.FieldByName('ACESSA_VENDAS').AsInteger = 1;
  pbAcessaFinanceiro := FoQryUsuarios.FieldByName('ACESSA_FINANCEIRO').AsInteger = 1;
  pbAtivo := FoQryUsuarios.FieldByName('ATIVO').AsInteger = 1;
  pbBloqueado := FoQryUsuarios.FieldByName('BLOQUEADO').AsInteger = 1;
end;

procedure TFormUsuarios.btnNovoClick(Sender: TObject);
var
  sSenhaTemporaria: string;
begin
  if TFormCadUsuario.ExecutarNovo(FoDAO, sSenhaTemporaria) then
  begin
    Recarregar;
    MessageDlg('Usu'#$00E1'rio criado.'#13#10#13#10 +
      'Senha tempor'#$00E1'ria (anote agora, n'#$00E3'o ser'#$00E1' mostrada de novo):'#13#10 +
      sSenhaTemporaria, mtInformation, [mbOK], 0);
  end;
end;

procedure TFormUsuarios.btnEditarClick(Sender: TObject);
var
  iId: Int64;
  sLogin, sNome, sEmail: string;
  bIsAdmin, bAcessaVendas, bAcessaFinanceiro, bAtivo, bBloqueado: Boolean;
begin
  if not RegistroSelecionado(iId, sLogin, sNome, sEmail, bIsAdmin, bAcessaVendas,
       bAcessaFinanceiro, bAtivo, bBloqueado) then
  begin
    MessageDlg('Selecione um usu'#$00E1'rio na lista.', mtWarning, [mbOK], 0);
    Exit;
  end;

  if TFormCadUsuario.ExecutarEdicao(FoDAO, iId, sLogin, sNome, sEmail, bIsAdmin,
       bAcessaVendas, bAcessaFinanceiro, bAtivo) then
    Recarregar;
end;

procedure TFormUsuarios.btnRedefinirSenhaClick(Sender: TObject);
var
  iId: Int64;
  sLogin, sNome, sEmail, sNovaSenha: string;
  bIsAdmin, bAcessaVendas, bAcessaFinanceiro, bAtivo, bBloqueado: Boolean;
begin
  if not RegistroSelecionado(iId, sLogin, sNome, sEmail, bIsAdmin, bAcessaVendas,
       bAcessaFinanceiro, bAtivo, bBloqueado) then
  begin
    MessageDlg('Selecione um usu'#$00E1'rio na lista.', mtWarning, [mbOK], 0);
    Exit;
  end;

  if MessageDlg(Format('Gerar uma nova senha tempor'#$00E1'ria para "%s"?', [sLogin]),
       mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  sNovaSenha := FoDAO.RedefinirSenha(iId);
  Recarregar;
  MessageDlg('Nova senha tempor'#$00E1'ria (anote agora, n'#$00E3'o ser'#$00E1' mostrada de novo):'#13#10 +
    sNovaSenha, mtInformation, [mbOK], 0);
end;

procedure TFormUsuarios.btnDesbloquearClick(Sender: TObject);
var
  iId: Int64;
  sLogin, sNome, sEmail: string;
  bIsAdmin, bAcessaVendas, bAcessaFinanceiro, bAtivo, bBloqueado: Boolean;
begin
  if not RegistroSelecionado(iId, sLogin, sNome, sEmail, bIsAdmin, bAcessaVendas,
       bAcessaFinanceiro, bAtivo, bBloqueado) then
  begin
    MessageDlg('Selecione um usu'#$00E1'rio na lista.', mtWarning, [mbOK], 0);
    Exit;
  end;

  if not bBloqueado then
  begin
    MessageDlg('Este usu'#$00E1'rio n'#$00E3'o est'#$00E1' bloqueado.', mtInformation, [mbOK], 0);
    Exit;
  end;

  FoAutenticacao.DesbloquearUsuario(iId, FiAdminLogadoId);
  Recarregar;
  MessageDlg('Usu'#$00E1'rio desbloqueado.', mtInformation, [mbOK], 0);
end;

procedure TFormUsuarios.btnFecharClick(Sender: TObject);
begin
  Close;
end;

end.

