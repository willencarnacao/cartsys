unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.UITypes, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, FireDAC.Comp.Client, uConfig, uEnvioEmail;

type
  TFormPrincipal = class(TForm)
    pnlMenu: TPanel;
    btnClientes: TButton;
    btnProdutos: TButton;
    btnVendas: TButton;
    btnEmail: TButton;
    btnSair: TButton;
    sbStatus: TStatusBar;
    procedure btnClientesClick(Sender: TObject);
    procedure btnProdutosClick(Sender: TObject);
    procedure btnVendasClick(Sender: TObject);
    procedure btnEmailClick(Sender: TObject);
    procedure btnSairClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FiUsuarioId: Int64;
    FoConexao: TFDConnection;
    FrSmtp: TConfigSmtp;
    FoEmail: TServicoEmail;
    FoChaveMestra: TBytes;
    FsArquivoIni: string;
    procedure AtualizarStatusBar(const psNome: string = '');
  public
    property UsuarioId: Int64 read FiUsuarioId write FiUsuarioId;
    property Conexao: TFDConnection read FoConexao write FoConexao;
    property Smtp: TConfigSmtp read FrSmtp write FrSmtp;
    property ChaveMestra: TBytes read FoChaveMestra write FoChaveMestra;
    property ArquivoIni: string read FsArquivoIni write FsArquivoIni;
    procedure PrepararAposLogin;
  end;

var
  FormPrincipal: TFormPrincipal;

implementation

{$R *.dfm}

uses
  Data.DB, uClienteDAO, uClientes, uProdutoDAO, uProdutos, uVendaDAO,
  uVendas, uSmtpConfig, uConfigEmail;

procedure TFormPrincipal.PrepararAposLogin;
var
  oQry: TFDQuery;
begin
  if not Assigned(FoConexao) then
    Exit;

  oQry := TFDQuery.Create(nil);
  try
    oQry.Connection := FoConexao;
    oQry.SQL.Text := 'SELECT NOME FROM USUARIO WHERE ID = :pId';
    oQry.ParamByName('pId').AsLargeInt := FiUsuarioId;
    oQry.Open;
    if not oQry.IsEmpty then
      AtualizarStatusBar(oQry.FieldByName('NOME').AsString)
    else
      AtualizarStatusBar;
  finally
    oQry.Free;
  end;

  FoEmail := TServicoEmail.Create(FoConexao, FrSmtp);
  FoEmail.Iniciar;
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

procedure TFormPrincipal.btnClientesClick(Sender: TObject);
var
  oDAO: TClienteDAO;
begin
  oDAO := TClienteDAO.Create(FoConexao);
  try
    TFormClientes.Executar(oDAO);
  finally
    oDAO.Free;
  end;
end;

procedure TFormPrincipal.btnProdutosClick(Sender: TObject);
var
  oDAO: TProdutoDAO;
begin
  oDAO := TProdutoDAO.Create(FoConexao);
  try
    TFormProdutos.Executar(oDAO);
  finally
    oDAO.Free;
  end;
end;

procedure TFormPrincipal.btnVendasClick(Sender: TObject);
var
  oDAO: TVendaDAO;
  oProdDAO: TProdutoDAO;
  oCliDAO: TClienteDAO;
begin
  oDAO := TVendaDAO.Create(FoConexao);
  oProdDAO := TProdutoDAO.Create(FoConexao);
  oCliDAO := TClienteDAO.Create(FoConexao);
  try
    TFormVendas.Executar(oDAO, oCliDAO, oProdDAO, FiUsuarioId);
  finally
    oCliDAO.Free;
    oProdDAO.Free;
    oDAO.Free;
  end;
end;

procedure TFormPrincipal.btnEmailClick(Sender: TObject);
var
  oDAO: TSmtpDAO;
begin
  oDAO := TSmtpDAO.Create(FoConexao, FoChaveMestra, FsArquivoIni);
  try
    try
      if TFormConfigEmail.Executar(oDAO, oDAO.Carregar(FrSmtp)) then
      begin
        FrSmtp := oDAO.Carregar(FrSmtp);
        if Assigned(FoEmail) then
          FoEmail.AtualizarSmtp(FrSmtp);
      end;
    except
      on E: Exception do
        MessageDlg(E.Message, mtError, [mbOK], 0);
    end;
  finally
    oDAO.Free;
  end;
end;

procedure TFormPrincipal.btnSairClick(Sender: TObject);
begin
  Close;
end;

procedure TFormPrincipal.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FoEmail);
end;

end.
