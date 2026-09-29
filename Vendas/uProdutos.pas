unit uProdutos;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.UITypes, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Grids, Vcl.DBGrids, Data.DB, FireDAC.Comp.Client,
  uProdutoDAO, uCadProduto, uGrade;

type
  TFormProdutos = class(TForm)
    pnlFiltro: TPanel;
    edtFiltro: TEdit;
    btnBuscar: TButton;
    pnlBotoes: TPanel;
    btnNovo: TButton;
    btnEditar: TButton;
    btnInativar: TButton;
    btnFechar: TButton;
    grdProdutos: TDBGrid;
    dsProdutos: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnBuscarClick(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure btnEditarClick(Sender: TObject);
    procedure btnInativarClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
  private
    FoDAO: TProdutoDAO;
    FoQry: TFDQuery;
    procedure Recarregar;
  public
    class procedure Executar(poDAO: TProdutoDAO);
  end;

implementation

{$R *.dfm}

class procedure TFormProdutos.Executar(poDAO: TProdutoDAO);
var
  oForm: TFormProdutos;
begin
  oForm := TFormProdutos.Create(nil);
  try
    oForm.FoDAO := poDAO;
    oForm.Recarregar;
    oForm.ShowModal;
  finally
    oForm.Free;
  end;
end;

procedure TFormProdutos.FormCreate(Sender: TObject);
begin
  PrepararGrade(grdProdutos);
end;

procedure TFormProdutos.FormDestroy(Sender: TObject);
begin
  FoQry.Free;
end;

procedure TFormProdutos.Recarregar;
begin
  dsProdutos.DataSet := nil;
  FreeAndNil(FoQry);
  FoQry := FoDAO.Listar(edtFiltro.Text);
  dsProdutos.DataSet := FoQry;
  NomearCampo(FoQry, 'CODIGO', 'C'#$00F3'digo');
  NomearCampo(FoQry, 'DESCRICAO', 'Descri'#$00E7#$00E3'o');
  NomearCampo(FoQry, 'UNIDADE', 'Un.');
  NomearCampo(FoQry, 'PRECO_VENDA', 'Pre'#$00E7'o');
  NomearCampo(FoQry, 'ATIVO', 'Ativo');
  AplicarFormatoMoeda(FoQry, 'PRECO_VENDA');
end;

procedure TFormProdutos.btnBuscarClick(Sender: TObject);
begin
  Recarregar;
end;

procedure TFormProdutos.btnNovoClick(Sender: TObject);
begin
  if TFormCadProduto.ExecutarNovo(FoDAO) then
    Recarregar;
end;

procedure TFormProdutos.btnEditarClick(Sender: TObject);
begin
  if not Assigned(FoQry) or FoQry.IsEmpty then
  begin
    MessageDlg('Selecione um produto.', mtWarning, [mbOK], 0);
    Exit;
  end;
  if TFormCadProduto.ExecutarEdicao(FoDAO, FoQry.FieldByName('ID').AsLargeInt,
       FoQry.FieldByName('CODIGO').AsString, FoQry.FieldByName('DESCRICAO').AsString,
       FoQry.FieldByName('UNIDADE').AsString, FoQry.FieldByName('PRECO_VENDA').AsCurrency,
       FoQry.FieldByName('ATIVO').AsInteger = 1) then
    Recarregar;
end;

procedure TFormProdutos.btnInativarClick(Sender: TObject);
begin
  if not Assigned(FoQry) or FoQry.IsEmpty then
  begin
    MessageDlg('Selecione um produto.', mtWarning, [mbOK], 0);
    Exit;
  end;
  if MessageDlg('Inativar o produto selecionado?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;
  FoDAO.Inativar(FoQry.FieldByName('ID').AsLargeInt);
  Recarregar;
end;

procedure TFormProdutos.btnFecharClick(Sender: TObject);
begin
  Close;
end;

end.
