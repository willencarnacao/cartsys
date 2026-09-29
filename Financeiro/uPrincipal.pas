unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.Menus, FireDAC.Comp.Client, uAutenticacao;

type
  TFormPrincipal = class(TForm)
    pnlMenu: TPanel;
    btnQuitacao: TButton;
    btnConsultas: TButton;
    btnDashboard: TButton;
    btnUsuarios: TButton;
    btnSair: TButton;
    sbStatus: TStatusBar;
    procedure btnQuitacaoClick(Sender: TObject);
    procedure btnConsultasClick(Sender: TObject);
    procedure btnDashboardClick(Sender: TObject);
    procedure btnUsuariosClick(Sender: TObject);
    procedure btnSairClick(Sender: TObject);
  private
    FiUsuarioId: Int64;
    FbIsAdmin: Boolean;
    FoConexao: TFDConnection;
    FoAutenticacao: TAutenticacaoService;
    FoChaveMestraTotp: TBytes;
    FsEmissorTotp: string;
    procedure AtualizarStatusBar(const psNome: string = '');
  public
    property UsuarioId: Int64 read FiUsuarioId write FiUsuarioId;
    property Conexao: TFDConnection read FoConexao write FoConexao;
    property Autenticacao: TAutenticacaoService read FoAutenticacao write FoAutenticacao;
    property ChaveMestraTotp: TBytes read FoChaveMestraTotp write FoChaveMestraTotp;
    property EmissorTotp: string read FsEmissorTotp write FsEmissorTotp;
    procedure PrepararAposLogin;
  end;

var
  FormPrincipal: TFormPrincipal;

implementation

{$R *.dfm}

uses
  Data.DB, uUsuarioDAO, uUsuarios, uFinanceiroDAO, uQuitacao,
  uConsultaFinanceira, uDashboardDAO, uDashboard;

procedure TFormPrincipal.PrepararAposLogin;
var
  oQry: TFDQuery;
begin
  if not Assigned(FoConexao) then
    Exit;

  oQry := TFDQuery.Create(nil);
  try
    oQry.Connection := FoConexao;
    oQry.SQL.Text := 'SELECT NOME, IS_ADMIN FROM USUARIO WHERE ID = :pId';
    oQry.ParamByName('pId').AsLargeInt := FiUsuarioId;
    oQry.Open;
    if not oQry.IsEmpty then
    begin
      FbIsAdmin := oQry.FieldByName('IS_ADMIN').AsInteger = 1;
      AtualizarStatusBar(oQry.FieldByName('NOME').AsString);
    end;
  finally
    oQry.Free;
  end;

  btnUsuarios.Visible := FbIsAdmin;
end;

procedure TFormPrincipal.AtualizarStatusBar(const psNome: string);
begin
  if sbStatus.Panels.Count = 0 then
    sbStatus.Panels.Add;
  if psNome <> '' then
    sbStatus.Panels[0].Text := 'Usu'#$00E1'rio: ' + psNome
  else
    sbStatus.Panels[0].Text := 'Usu'#$00E1'rio #' + FiUsuarioId.ToString;
end;

procedure TFormPrincipal.btnQuitacaoClick(Sender: TObject);
var
  oDAO: TFinanceiroDAO;
begin
  oDAO := TFinanceiroDAO.Create(FoConexao);
  try
    TFormQuitacao.Executar(oDAO, FiUsuarioId);
  finally
    oDAO.Free;
  end;
end;

procedure TFormPrincipal.btnConsultasClick(Sender: TObject);
var
  oDAO: TFinanceiroDAO;
begin
  oDAO := TFinanceiroDAO.Create(FoConexao);
  try
    TFormConsultaFinanceira.Executar(oDAO);
  finally
    oDAO.Free;
  end;
end;

procedure TFormPrincipal.btnDashboardClick(Sender: TObject);
var
  oDAO: TDashboardDAO;
begin
  oDAO := TDashboardDAO.Create(FoConexao);
  try
    TFormDashboard.Executar(oDAO);
  finally
    oDAO.Free;
  end;
end;

procedure TFormPrincipal.btnUsuariosClick(Sender: TObject);
var
  oDAO: TUsuarioDAO;
begin
  if not FbIsAdmin then
  begin
    ShowMessage('S'#$00F3' o administrador acessa o cadastro de usu'#$00E1'rios.');
    Exit;
  end;

  oDAO := TUsuarioDAO.Create(FoConexao, FoChaveMestraTotp, FsEmissorTotp);
  try
    TFormUsuarios.Executar(oDAO, FoAutenticacao, FiUsuarioId);
  finally
    oDAO.Free;
  end;
end;

procedure TFormPrincipal.btnSairClick(Sender: TObject);
begin
  Close;
end;

end.

