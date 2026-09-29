unit uVendas;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.UITypes, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Grids, Vcl.DBGrids, Data.DB, Data.SqlTimSt, FireDAC.Comp.Client,
  uVendaDAO, uClienteDAO, uProdutoDAO, uCadVenda, uRelPedido, uTipos, uGrade;

type
  TFormVendas = class(TForm)
    pnlFiltro: TPanel;
    edtFiltro: TEdit;
    btnBuscar: TButton;
    pnlBotoes: TPanel;
    btnNovo: TButton;
    btnAbrir: TButton;
    btnConfirmar: TButton;
    btnExcluir: TButton;
    btnImprimir: TButton;
    btnFechar: TButton;
    grdVendas: TDBGrid;
    dsVendas: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnBuscarClick(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure btnAbrirClick(Sender: TObject);
    procedure btnConfirmarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnImprimirClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure grdVendasDblClick(Sender: TObject);
  private
    FoDAO: TVendaDAO;
    FoCliDAO: TClienteDAO;
    FoProdDAO: TProdutoDAO;
    FiUsuarioId: Int64;
    FoQry: TFDQuery;
    procedure Recarregar;
    function ObterVendaSelecionada(out piId: Int64; out piStatus: Integer): Boolean;
  public
    class procedure Executar(poDAO: TVendaDAO; poCliDAO: TClienteDAO;
      poProdDAO: TProdutoDAO; piUsuarioId: Int64);
  end;

implementation

{$R *.dfm}

class procedure TFormVendas.Executar(poDAO: TVendaDAO; poCliDAO: TClienteDAO;
  poProdDAO: TProdutoDAO; piUsuarioId: Int64);
var
  oForm: TFormVendas;
begin
  oForm := TFormVendas.Create(nil);
  try
    oForm.FoDAO := poDAO;
    oForm.FoCliDAO := poCliDAO;
    oForm.FoProdDAO := poProdDAO;
    oForm.FiUsuarioId := piUsuarioId;
    oForm.Recarregar;
    oForm.ShowModal;
  finally
    oForm.Free;
  end;
end;

procedure TFormVendas.FormCreate(Sender: TObject);
begin
  PrepararGrade(grdVendas);
end;

procedure TFormVendas.FormDestroy(Sender: TObject);
begin
  FoQry.Free;
end;

procedure TFormVendas.Recarregar;
begin
  dsVendas.DataSet := nil;
  FreeAndNil(FoQry);
  FoQry := FoDAO.Listar(edtFiltro.Text);
  FoQry.FieldByName('STATUS').Visible := False;
  NomearCampo(FoQry, 'ID', 'N'#$00BA);
  NomearCampo(FoQry, 'DT_EMISSAO', 'Data');
  NomearCampo(FoQry, 'CLIENTE', 'Cliente');
  NomearCampo(FoQry, 'STATUS_DESC', 'Status');
  NomearCampo(FoQry, 'VL_TOTAL', 'Total');
  FoQry.FieldByName('STATUS_DESC').Visible := True;
  FoQry.FieldByName('ID').DisplayWidth := 8;
  FoQry.FieldByName('CLIENTE').DisplayWidth := 32;
  FoQry.FieldByName('STATUS_DESC').DisplayWidth := 16;
  FoQry.FieldByName('VL_TOTAL').DisplayWidth := 14;
  if FoQry.FieldByName('DT_EMISSAO') is TSQLTimeStampField then
    TSQLTimeStampField(FoQry.FieldByName('DT_EMISSAO')).DisplayFormat := 'dd/mm/yyyy'
  else if FoQry.FieldByName('DT_EMISSAO') is TDateTimeField then
    TDateTimeField(FoQry.FieldByName('DT_EMISSAO')).DisplayFormat := 'dd/mm/yyyy';
  FoQry.FieldByName('DT_EMISSAO').DisplayWidth := 12;
  FoQry.FieldByName('ID').Index := 0;
  FoQry.FieldByName('DT_EMISSAO').Index := 1;
  FoQry.FieldByName('CLIENTE').Index := 2;
  FoQry.FieldByName('STATUS_DESC').Index := 3;
  FoQry.FieldByName('VL_TOTAL').Index := 4;
  AplicarFormatoMoeda(FoQry, 'VL_TOTAL');
  dsVendas.DataSet := FoQry;
end;

function TFormVendas.ObterVendaSelecionada(out piId: Int64; out piStatus: Integer): Boolean;
begin
  Result := Assigned(FoQry) and (not FoQry.IsEmpty);
  if not Result then
  begin
    MessageDlg('Selecione uma venda.', mtWarning, [mbOK], 0);
    Exit;
  end;
  piId := FoQry.FieldByName('ID').AsLargeInt;
  piStatus := FoQry.FieldByName('STATUS').AsInteger;
end;

procedure TFormVendas.btnBuscarClick(Sender: TObject);
begin
  Recarregar;
end;

procedure TFormVendas.btnNovoClick(Sender: TObject);
begin
  if TFormCadVenda.ExecutarNovo(FoDAO, FoCliDAO, FoProdDAO, FiUsuarioId) then
    Recarregar;
end;

procedure TFormVendas.btnAbrirClick(Sender: TObject);
var
  iId: Int64;
  iStatus: Integer;
begin
  if not ObterVendaSelecionada(iId, iStatus) then
    Exit;
  if TFormCadVenda.ExecutarEdicao(FoDAO, FoCliDAO, FoProdDAO, FiUsuarioId, iId) then
    Recarregar;
end;

procedure TFormVendas.btnConfirmarClick(Sender: TObject);
var
  iId: Int64;
  iStatus: Integer;
begin
  if not ObterVendaSelecionada(iId, iStatus) then
    Exit;
  if iStatus <> Ord(vsEmDigitacao) then
  begin
    MessageDlg('S'#$00F3' '#$00E9' poss'#$00ED'vel confirmar venda em digita'#$00E7#$00E3'o.', mtWarning, [mbOK], 0);
    Exit;
  end;
  if MessageDlg('Confirmar a venda selecionada? Depois disso ela vai para o financeiro.',
       mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;
  try
    FoDAO.Confirmar(iId);
    Recarregar;
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TFormVendas.btnExcluirClick(Sender: TObject);
var
  iId: Int64;
  iStatus: Integer;
begin
  if not ObterVendaSelecionada(iId, iStatus) then
    Exit;
  if iStatus <> Ord(vsEmDigitacao) then
  begin
    MessageDlg('S'#$00F3' '#$00E9' poss'#$00ED'vel excluir venda em digita'#$00E7#$00E3'o.', mtWarning, [mbOK], 0);
    Exit;
  end;
  if MessageDlg('Excluir a venda selecionada?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;
  try
    FoDAO.Excluir(iId);
    Recarregar;
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TFormVendas.btnImprimirClick(Sender: TObject);
var
  iId: Int64;
  iStatus: Integer;
  oCab, oItens: TFDQuery;
begin
  if not ObterVendaSelecionada(iId, iStatus) then
    Exit;
  oCab := FoDAO.CarregarCabecalho(iId);
  oItens := FoDAO.CarregarItens(iId);
  try
    VisualizarPedido(oCab, oItens);
  finally
    oItens.Free;
    oCab.Free;
  end;
end;

procedure TFormVendas.grdVendasDblClick(Sender: TObject);
begin
  btnAbrirClick(Sender);
end;

procedure TFormVendas.btnFecharClick(Sender: TObject);
begin
  Close;
end;

end.
