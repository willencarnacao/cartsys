unit uClientes;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.UITypes, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Grids, Vcl.DBGrids, Data.DB, FireDAC.Comp.Client,
  uClienteDAO, uCadCliente, uGrade;

type
  TFormClientes = class(TForm)
    pnlFiltro: TPanel;
    edtFiltro: TEdit;
    btnBuscar: TButton;
    pnlBotoes: TPanel;
    btnNovo: TButton;
    btnEditar: TButton;
    btnInativar: TButton;
    btnFechar: TButton;
    grdClientes: TDBGrid;
    dsClientes: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnBuscarClick(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure btnEditarClick(Sender: TObject);
    procedure btnInativarClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
  private
    FoDAO: TClienteDAO;
    FoQry: TFDQuery;
    procedure Recarregar;
  public
    class procedure Executar(poDAO: TClienteDAO);
  end;

implementation

{$R *.dfm}

class procedure TFormClientes.Executar(poDAO: TClienteDAO);
var
  oForm: TFormClientes;
begin
  oForm := TFormClientes.Create(nil);
  try
    oForm.FoDAO := poDAO;
    oForm.Recarregar;
    oForm.ShowModal;
  finally
    oForm.Free;
  end;
end;

procedure TFormClientes.FormCreate(Sender: TObject);
begin
  PrepararGrade(grdClientes);
end;

procedure TFormClientes.FormDestroy(Sender: TObject);
begin
  FoQry.Free;
end;

procedure TFormClientes.Recarregar;
begin
  dsClientes.DataSet := nil;
  FreeAndNil(FoQry);
  FoQry := FoDAO.Listar(edtFiltro.Text);
  dsClientes.DataSet := FoQry;
  NomearCampo(FoQry, 'NOME', 'Nome');
  NomearCampo(FoQry, 'TIPO_PESSOA', 'Tipo');
  NomearCampo(FoQry, 'CPF_CNPJ', 'Documento');
  NomearCampo(FoQry, 'EMAIL', 'E-mail');
  NomearCampo(FoQry, 'CIDADE', 'Cidade');
  NomearCampo(FoQry, 'UF', 'UF');
  NomearCampo(FoQry, 'ATIVO', 'Ativo');
end;

procedure TFormClientes.btnBuscarClick(Sender: TObject);
begin
  Recarregar;
end;

procedure TFormClientes.btnNovoClick(Sender: TObject);
begin
  if TFormCadCliente.ExecutarNovo(FoDAO) then
    Recarregar;
end;

procedure TFormClientes.btnEditarClick(Sender: TObject);
begin
  if not Assigned(FoQry) or FoQry.IsEmpty then
  begin
    MessageDlg('Selecione um cliente.', mtWarning, [mbOK], 0);
    Exit;
  end;
  if TFormCadCliente.ExecutarEdicao(FoDAO, FoQry.FieldByName('ID').AsLargeInt) then
    Recarregar;
end;

procedure TFormClientes.btnInativarClick(Sender: TObject);
begin
  if not Assigned(FoQry) or FoQry.IsEmpty then
  begin
    MessageDlg('Selecione um cliente.', mtWarning, [mbOK], 0);
    Exit;
  end;
  if MessageDlg('Inativar o cliente selecionado?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;
  FoDAO.Inativar(FoQry.FieldByName('ID').AsLargeInt);
  Recarregar;
end;

procedure TFormClientes.btnFecharClick(Sender: TObject);
begin
  Close;
end;

end.
