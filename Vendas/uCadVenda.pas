unit uCadVenda;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.DateUtils, System.UITypes,
  System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.Grids, Vcl.DBGrids, Data.DB, FireDAC.Comp.Client, FireDAC.Comp.DataSet,
  FireDAC.Stan.Intf, uVendaDAO, uClienteDAO, uProdutoDAO, uConsultaCliente,
  uConsultaProduto, uTipos, uRelPedido, uGrade, uDados;

type
  TProdRef = record
    Id: Int64;
    Codigo: string;
    Descricao: string;
    Unidade: string;
    Preco: Currency;
  end;

  TFormCadVenda = class(TForm)
    pnlCab: TPanel;
    lblCliente: TLabel;
    edtClienteCodigo: TEdit;
    btnCliente: TButton;
    edtClienteNome: TEdit;
    lblVenc: TLabel;
    dtpVenc: TDateTimePicker;
    lblDesconto: TLabel;
    edtDesconto: TEdit;
    lblObs: TLabel;
    edtObs: TEdit;
    lblStatus: TLabel;
    pnlItem: TPanel;
    lblProduto: TLabel;
    edtProdutoCodigo: TEdit;
    btnProduto: TButton;
    edtProdutoNome: TEdit;
    lblQtd: TLabel;
    edtQtd: TEdit;
    lblPreco: TLabel;
    edtPreco: TEdit;
    lblDescItem: TLabel;
    edtDescItem: TEdit;
    btnAddItem: TButton;
    btnRemItem: TButton;
    grdItens: TDBGrid;
    dsItens: TDataSource;
    pnlRodape: TPanel;
    lblTotal: TLabel;
    btnSalvar: TButton;
    btnImprimir: TButton;
    btnFechar: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnClienteClick(Sender: TObject);
    procedure btnProdutoClick(Sender: TObject);
    procedure btnAddItemClick(Sender: TObject);
    procedure btnRemItemClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnImprimirClick(Sender: TObject);
    procedure dsItensDataChange(Sender: TObject; Field: TField);
    procedure edtItemExit(Sender: TObject);
  private
    FoDAO: TVendaDAO;
    FoCliDAO: TClienteDAO;
    FoProdDAO: TProdutoDAO;
    FiUsuarioId: Int64;
    FiId: Int64;
    FiStatus: Integer;
    FoItens: TFDMemTable;
    FiClienteId: Int64;
    FrProduto: TProdRef;
    FbCarregandoItem: Boolean;
    FbCalculandoItem: Boolean;
    FbInserindoItem: Boolean;
    procedure ConsultarCliente;
    procedure ConsultarProduto;
    procedure ConfigurarGrid;
    procedure AplicarSomenteLeitura;
    procedure RecalcularTotal;
    procedure RecalcularLinha;
    procedure CarregarCamposDoItem;
    procedure GravarProdutoNoItem;
    procedure GravarValoresNoItem;
    procedure ItensAfterPost(DataSet: TDataSet);
    procedure ItemCampoChange(Sender: TField);
    procedure ItensBeforeInsert(DataSet: TDataSet);
    function LerValoresItem(out pnQtd, pnPerc: Double; out pnPreco: Currency): Boolean;
    function MontarItens: TArray<TItemVenda>;
    function ObterClienteSelecionado: Int64;
    function SalvarInterno: Boolean;
  public
    class function ExecutarNovo(poDAO: TVendaDAO; poCliDAO: TClienteDAO;
      poProdDAO: TProdutoDAO; piUsuarioId: Int64): Boolean;
    class function ExecutarEdicao(poDAO: TVendaDAO; poCliDAO: TClienteDAO;
      poProdDAO: TProdutoDAO; piUsuarioId, piId: Int64): Boolean;
  end;

implementation

{$R *.dfm}

procedure Avisar(const psTexto: string);
begin
  MessageDlg(psTexto, mtWarning, [mbOK], 0);
end;

class function TFormCadVenda.ExecutarNovo(poDAO: TVendaDAO; poCliDAO: TClienteDAO;
  poProdDAO: TProdutoDAO; piUsuarioId: Int64): Boolean;
var
  oForm: TFormCadVenda;
begin
  oForm := TFormCadVenda.Create(nil);
  try
    oForm.FoDAO := poDAO;
    oForm.FoCliDAO := poCliDAO;
    oForm.FoProdDAO := poProdDAO;
    oForm.FiUsuarioId := piUsuarioId;
    oForm.FiId := 0;
    oForm.FiStatus := Ord(vsEmDigitacao);
    oForm.Caption := 'Nova venda';
    oForm.lblStatus.Caption := 'Status: em digita'#$00E7#$00E3'o';
    oForm.dtpVenc.Date := IncDay(Date, 30);
    oForm.dtpVenc.Checked := True;
    oForm.edtDesconto.Text := '0,00';
    Result := oForm.ShowModal = mrOk;
  finally
    oForm.Free;
  end;
end;

class function TFormCadVenda.ExecutarEdicao(poDAO: TVendaDAO; poCliDAO: TClienteDAO;
  poProdDAO: TProdutoDAO; piUsuarioId, piId: Int64): Boolean;
var
  oForm: TFormCadVenda;
  oCab, oItens: TFDQuery;
begin
  oForm := TFormCadVenda.Create(nil);
  try
    oForm.FoDAO := poDAO;
    oForm.FoCliDAO := poCliDAO;
    oForm.FoProdDAO := poProdDAO;
    oForm.FiUsuarioId := piUsuarioId;
    oForm.FiId := piId;
    oForm.Caption := 'Venda ' + piId.ToString;

    oCab := poDAO.CarregarCabecalho(piId);
    oItens := poDAO.CarregarItens(piId);
    try
      if oCab.IsEmpty then
        raise Exception.Create('Venda n'#$00E3'o encontrada.');
      oForm.FiStatus := oCab.FieldByName('STATUS').AsInteger;
      oForm.lblStatus.Caption := 'Status: ' +
        ConverterStatusVenda(TVendaStatus(oForm.FiStatus));
      oForm.FiClienteId := oCab.FieldByName('CLIENTE_ID').AsLargeInt;
      oForm.edtClienteCodigo.Text := oCab.FieldByName('CPF_CNPJ').AsString;
      oForm.edtClienteNome.Text := oCab.FieldByName('CLIENTE').AsString;
      if oCab.FieldByName('DT_VENCIMENTO').IsNull then
        oForm.dtpVenc.Checked := False
      else
      begin
        oForm.dtpVenc.Date := oCab.FieldByName('DT_VENCIMENTO').AsDateTime;
        oForm.dtpVenc.Checked := True;
      end;
      oForm.edtDesconto.Text := FormatFloat('0.00', oCab.FieldByName('VL_DESCONTO').AsCurrency);
      oForm.edtObs.Text := oCab.FieldByName('OBSERVACAO').AsString;

      oForm.FbCarregandoItem := True;
      oForm.FbInserindoItem := True;
      try
        while not oItens.Eof do
        begin
          oForm.FoItens.Append;
          oForm.FoItens.FieldByName('PRODUTO_ID').AsLargeInt := oItens.FieldByName('PRODUTO_ID').AsLargeInt;
          oForm.FoItens.FieldByName('CODIGO').AsString := oItens.FieldByName('CODIGO').AsString;
          oForm.FoItens.FieldByName('DESCRICAO').AsString := oItens.FieldByName('DESCRICAO').AsString;
          oForm.FoItens.FieldByName('UNIDADE').AsString := oItens.FieldByName('UNIDADE').AsString;
          oForm.FoItens.FieldByName('QUANTIDADE').AsFloat := oItens.FieldByName('QUANTIDADE').AsFloat;
          oForm.FoItens.FieldByName('PRECO_UNIT').AsCurrency := oItens.FieldByName('PRECO_UNIT').AsCurrency;
          if (oItens.FindField('PERC_DESCONTO') <> nil) and
             (oItens.FieldByName('PERC_DESCONTO').AsFloat <> 0) then
            oForm.FoItens.FieldByName('PERC_DESCONTO').AsFloat :=
              ArredondarPercentual(oItens.FieldByName('PERC_DESCONTO').AsFloat)
          else if oItens.FieldByName('QUANTIDADE').AsFloat * oItens.FieldByName('PRECO_UNIT').AsCurrency > 0 then
            oForm.FoItens.FieldByName('PERC_DESCONTO').AsFloat :=
              ArredondarPercentual(
                oItens.FieldByName('VL_DESCONTO').AsCurrency /
                (oItens.FieldByName('QUANTIDADE').AsFloat * oItens.FieldByName('PRECO_UNIT').AsCurrency) * 100)
          else
            oForm.FoItens.FieldByName('PERC_DESCONTO').AsFloat := 0;
          oForm.RecalcularLinha;
          oForm.FoItens.Post;
          oItens.Next;
        end;
      finally
        oForm.FbInserindoItem := False;
        oForm.FbCarregandoItem := False;
      end;
    finally
      oItens.Free;
      oCab.Free;
    end;

    oForm.RecalcularTotal;
    oForm.FoItens.First;
    oForm.CarregarCamposDoItem;
    if oForm.FiStatus <> Ord(vsEmDigitacao) then
      oForm.AplicarSomenteLeitura;
    Result := oForm.ShowModal = mrOk;
  finally
    oForm.Free;
  end;
end;

procedure TFormCadVenda.FormCreate(Sender: TObject);
begin
  KeyPreview := True;
  FiClienteId := 0;
  FrProduto.Id := 0;
  FbCarregandoItem := False;
  FbCalculandoItem := False;
  FbInserindoItem := False;
  FoItens := TFDMemTable.Create(Self);
  FoItens.FieldDefs.Add('PRODUTO_ID', ftLargeint);
  FoItens.FieldDefs.Add('CODIGO', ftString, 30);
  FoItens.FieldDefs.Add('DESCRICAO', ftString, 150);
  FoItens.FieldDefs.Add('UNIDADE', ftString, 6);
  FoItens.FieldDefs.Add('QUANTIDADE', ftFloat);
  FoItens.FieldDefs.Add('PRECO_UNIT', ftCurrency);
  FoItens.FieldDefs.Add('PERC_DESCONTO', ftFloat);
  FoItens.FieldDefs.Add('VL_DESCONTO', ftCurrency);
  FoItens.FieldDefs.Add('VL_TOTAL', ftCurrency);
  FoItens.CreateDataSet;
  FoItens.FieldByName('QUANTIDADE').OnChange := ItemCampoChange;
  FoItens.FieldByName('PRECO_UNIT').OnChange := ItemCampoChange;
  FoItens.FieldByName('PERC_DESCONTO').OnChange := ItemCampoChange;
  FoItens.AfterPost := ItensAfterPost;
  FoItens.AfterDelete := ItensAfterPost;
  FoItens.BeforeInsert := ItensBeforeInsert;
  dsItens.DataSet := FoItens;
  dsItens.OnDataChange := dsItensDataChange;
  ConfigurarGrid;
  RecalcularTotal;
end;

procedure TFormCadVenda.FormDestroy(Sender: TObject);
begin
  dsItens.DataSet := nil;
end;

procedure TFormCadVenda.ConfigurarGrid;
  procedure AdicionarColuna(const psCampo, psTitulo: string; piLargura: Integer; pbSomenteLeitura: Boolean);
  var
    oCol: TColumn;
  begin
    oCol := grdItens.Columns.Add;
    oCol.FieldName := psCampo;
    oCol.Title.Caption := psTitulo;
    oCol.Width := piLargura;
    oCol.ReadOnly := pbSomenteLeitura;
  end;
begin
  grdItens.ReadOnly := False;
  grdItens.Options := [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines,
    dgRowLines, dgTabs, dgConfirmDelete, dgTitleClick, dgTitleHotTrack];
  FoItens.FieldByName('PRODUTO_ID').Visible := False;
  (FoItens.FieldByName('QUANTIDADE') as TNumericField).DisplayFormat := '0.##';
  (FoItens.FieldByName('PERC_DESCONTO') as TNumericField).DisplayFormat := '0.##';
  AplicarFormatoMoeda(FoItens, 'PRECO_UNIT');
  AplicarFormatoMoeda(FoItens, 'VL_DESCONTO');
  AplicarFormatoMoeda(FoItens, 'VL_TOTAL');
  grdItens.Columns.BeginUpdate;
  try
    grdItens.Columns.Clear;
    AdicionarColuna('CODIGO', TXT_CODIGO, 80, True);
    AdicionarColuna('DESCRICAO', 'Produto', 220, True);
    AdicionarColuna('UNIDADE', 'Un.', 40, True);
    AdicionarColuna('QUANTIDADE', 'Qtd', 70, False);
    AdicionarColuna('PRECO_UNIT', TXT_PRECO, 90, False);
    AdicionarColuna('PERC_DESCONTO', 'Desc. %', 70, False);
    AdicionarColuna('VL_DESCONTO', 'Desconto', 90, True);
    AdicionarColuna('VL_TOTAL', 'Total', 90, True);
  finally
    grdItens.Columns.EndUpdate;
  end;
end;

procedure TFormCadVenda.ConsultarCliente;
var
  iId: Int64;
  sCodigo, sNome: string;
begin
  if TFormConsultaCliente.Consultar(FoCliDAO, iId, sCodigo, sNome) then
  begin
    FiClienteId := iId;
    edtClienteCodigo.Text := sCodigo;
    edtClienteNome.Text := sNome;
  end;
end;

procedure TFormCadVenda.ConsultarProduto;
var
  iId: Int64;
  sCodigo, sDescricao, sUnidade: string;
  nPreco: Currency;
begin
  if TFormConsultaProduto.Consultar(FoProdDAO, iId, sCodigo, sDescricao, sUnidade, nPreco) then
  begin
    FrProduto.Id := iId;
    FrProduto.Codigo := sCodigo;
    FrProduto.Descricao := sDescricao;
    FrProduto.Unidade := sUnidade;
    FrProduto.Preco := nPreco;
    edtProdutoCodigo.Text := sCodigo;
    edtProdutoNome.Text := sDescricao;
    edtPreco.Text := FormatFloat('0.00', nPreco);
    if not FoItens.IsEmpty then
      GravarProdutoNoItem;
  end;
end;

procedure TFormCadVenda.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key <> VK_F4 then
    Exit;
  if (ActiveControl = edtClienteCodigo) or (ActiveControl = edtClienteNome) or
     (ActiveControl = btnCliente) then
  begin
    Key := 0;
    ConsultarCliente;
  end
  else if (ActiveControl = edtProdutoCodigo) or (ActiveControl = edtProdutoNome) or
          (ActiveControl = btnProduto) then
  begin
    Key := 0;
    ConsultarProduto;
  end;
end;

procedure TFormCadVenda.btnClienteClick(Sender: TObject);
begin
  ConsultarCliente;
end;

procedure TFormCadVenda.btnProdutoClick(Sender: TObject);
begin
  ConsultarProduto;
end;

procedure TFormCadVenda.AplicarSomenteLeitura;
begin
  edtClienteCodigo.Enabled := False;
  btnCliente.Enabled := False;
  edtClienteNome.Enabled := False;
  dtpVenc.Enabled := False;
  edtDesconto.Enabled := False;
  edtObs.Enabled := False;
  edtProdutoCodigo.Enabled := False;
  btnProduto.Enabled := False;
  edtProdutoNome.Enabled := False;
  edtQtd.Enabled := False;
  edtPreco.Enabled := False;
  edtDescItem.Enabled := False;
  btnAddItem.Enabled := False;
  btnRemItem.Enabled := False;
  grdItens.ReadOnly := True;
  grdItens.Options := grdItens.Options - [dgEditing];
  btnSalvar.Enabled := False;
end;

procedure TFormCadVenda.RecalcularTotal;
var
  nSomaItens, nDesc: Currency;
  oBm: TBookmark;
begin
  nSomaItens := 0;
  if FoItens.Active and (FoItens.RecordCount > 0) then
  begin
    oBm := FoItens.GetBookmark;
    try
      FoItens.DisableControls;
      FoItens.First;
      while not FoItens.Eof do
      begin
        nSomaItens := nSomaItens + FoItens.FieldByName('VL_TOTAL').AsCurrency;
        FoItens.Next;
      end;
    finally
      if FoItens.BookmarkValid(oBm) then
        FoItens.GotoBookmark(oBm);
      FoItens.FreeBookmark(oBm);
      FoItens.EnableControls;
    end;
  end;
  if not TryStrToCurr(edtDesconto.Text, nDesc) then
    nDesc := 0;
  lblTotal.Caption := 'Total: ' + FormatCurr('R$ #,##0.00', nSomaItens - nDesc);
end;

procedure TFormCadVenda.RecalcularLinha;
var
  nQtd, nPerc: Double;
  nPreco, nBruto, nDesc: Currency;
begin
  if FbCalculandoItem or not FoItens.Active then
    Exit;
  FbCalculandoItem := True;
  try
    if not (FoItens.State in [dsEdit, dsInsert]) then
      FoItens.Edit;
    nQtd := FoItens.FieldByName('QUANTIDADE').AsFloat;
    nPreco := FoItens.FieldByName('PRECO_UNIT').AsCurrency;
    nPerc := ArredondarPercentual(FoItens.FieldByName('PERC_DESCONTO').AsFloat);
    if nQtd < 0 then
      nQtd := 0;
    if nPerc < 0 then
      nPerc := 0;
    if nPerc > 100 then
      nPerc := 100;
    nPerc := ArredondarPercentual(nPerc);
    if FoItens.FieldByName('PERC_DESCONTO').AsFloat <> nPerc then
      FoItens.FieldByName('PERC_DESCONTO').AsFloat := nPerc;
    nBruto := ArredondarMoeda(nQtd * nPreco);
    nDesc := ArredondarMoeda(nBruto * nPerc / 100);
    FoItens.FieldByName('VL_DESCONTO').AsCurrency := nDesc;
    FoItens.FieldByName('VL_TOTAL').AsCurrency := nBruto - nDesc;
  finally
    FbCalculandoItem := False;
  end;
end;

procedure TFormCadVenda.ItensBeforeInsert(DataSet: TDataSet);
begin
  if not FbInserindoItem then
    Abort;
end;

procedure TFormCadVenda.ItemCampoChange(Sender: TField);
begin
  if not FbCarregandoItem then
    RecalcularLinha;
end;

procedure TFormCadVenda.ItensAfterPost(DataSet: TDataSet);
begin
  RecalcularTotal;
end;

procedure TFormCadVenda.CarregarCamposDoItem;
begin
  if FbCarregandoItem then
    Exit;
  FbCarregandoItem := True;
  try
    if (not FoItens.Active) or FoItens.IsEmpty then
    begin
      FrProduto.Id := 0;
      edtProdutoCodigo.Text := '';
      edtProdutoNome.Text := '';
      edtQtd.Text := '1';
      edtPreco.Text := '';
      edtDescItem.Text := '0';
      Exit;
    end;
    FrProduto.Id := FoItens.FieldByName('PRODUTO_ID').AsLargeInt;
    FrProduto.Codigo := FoItens.FieldByName('CODIGO').AsString;
    FrProduto.Descricao := FoItens.FieldByName('DESCRICAO').AsString;
    FrProduto.Unidade := FoItens.FieldByName('UNIDADE').AsString;
    FrProduto.Preco := FoItens.FieldByName('PRECO_UNIT').AsCurrency;
    edtProdutoCodigo.Text := FrProduto.Codigo;
    edtProdutoNome.Text := FrProduto.Descricao;
    edtQtd.Text := FormatFloat('0.##', FoItens.FieldByName('QUANTIDADE').AsFloat);
    edtPreco.Text := FormatFloat('0.00', FoItens.FieldByName('PRECO_UNIT').AsCurrency);
    edtDescItem.Text := FormatFloat('0.##', FoItens.FieldByName('PERC_DESCONTO').AsFloat);
  finally
    FbCarregandoItem := False;
  end;
end;

procedure TFormCadVenda.dsItensDataChange(Sender: TObject; Field: TField);
begin
  if Field = nil then
    CarregarCamposDoItem;
end;

function TFormCadVenda.LerValoresItem(out pnQtd, pnPerc: Double; out pnPreco: Currency): Boolean;
begin
  Result := False;
  if not TryStrToFloat(edtQtd.Text, pnQtd) or (pnQtd <= 0) then
  begin
    Avisar('Quantidade inv'#$00E1'lida.');
    Exit;
  end;
  if not TryStrToCurr(edtPreco.Text, pnPreco) or (pnPreco < 0) then
  begin
    Avisar('Pre'#$00E7'o inv'#$00E1'lido.');
    Exit;
  end;
  if Trim(edtDescItem.Text) = '' then
    pnPerc := 0
  else if not TryStrToFloat(edtDescItem.Text, pnPerc) or (pnPerc < 0) or (pnPerc > 100) then
  begin
    Avisar('Desconto percentual inv'#$00E1'lido (0 a 100).');
    Exit;
  end;
  pnPerc := ArredondarPercentual(pnPerc);
  pnPreco := ArredondarMoeda(pnPreco);
  Result := True;
end;

procedure TFormCadVenda.GravarProdutoNoItem;
begin
  if FoItens.IsEmpty and (FoItens.State <> dsInsert) then
    Exit;
  if not (FoItens.State in [dsEdit, dsInsert]) then
    FoItens.Edit;
  FoItens.FieldByName('PRODUTO_ID').AsLargeInt := FrProduto.Id;
  FoItens.FieldByName('CODIGO').AsString := FrProduto.Codigo;
  FoItens.FieldByName('DESCRICAO').AsString := FrProduto.Descricao;
  FoItens.FieldByName('UNIDADE').AsString := FrProduto.Unidade;
  FoItens.FieldByName('PRECO_UNIT').AsCurrency := FrProduto.Preco;
  RecalcularLinha;
  if FoItens.State in [dsEdit, dsInsert] then
    FoItens.Post;
end;

procedure TFormCadVenda.GravarValoresNoItem;
var
  nQtd, nPerc: Double;
  nPreco: Currency;
begin
  if FbCarregandoItem or FoItens.IsEmpty then
    Exit;
  if not LerValoresItem(nQtd, nPerc, nPreco) then
  begin
    CarregarCamposDoItem;
    Exit;
  end;
  if not (FoItens.State in [dsEdit, dsInsert]) then
    FoItens.Edit;
  FoItens.FieldByName('QUANTIDADE').AsFloat := nQtd;
  FoItens.FieldByName('PRECO_UNIT').AsCurrency := nPreco;
  FoItens.FieldByName('PERC_DESCONTO').AsFloat := nPerc;
  RecalcularLinha;
  if FoItens.State in [dsEdit, dsInsert] then
    FoItens.Post;
end;

procedure TFormCadVenda.edtItemExit(Sender: TObject);
begin
  GravarValoresNoItem;
end;

function TFormCadVenda.ObterClienteSelecionado: Int64;
begin
  Result := FiClienteId;
end;

function TFormCadVenda.MontarItens: TArray<TItemVenda>;
var
  iIndice: Integer;
begin
  SetLength(Result, 0);
  if not FoItens.Active then
    Exit;
  FoItens.DisableControls;
  try
    FoItens.First;
    while not FoItens.Eof do
    begin
      iIndice := Length(Result);
      SetLength(Result, iIndice + 1);
      Result[iIndice].ProdutoId := FoItens.FieldByName('PRODUTO_ID').AsLargeInt;
      Result[iIndice].Quantidade := FoItens.FieldByName('QUANTIDADE').AsFloat;
      Result[iIndice].PrecoUnit := FoItens.FieldByName('PRECO_UNIT').AsCurrency;
      Result[iIndice].Desconto := FoItens.FieldByName('VL_DESCONTO').AsCurrency;
      Result[iIndice].PercDesconto := FoItens.FieldByName('PERC_DESCONTO').AsFloat;
      FoItens.Next;
    end;
  finally
    FoItens.EnableControls;
  end;
end;

procedure TFormCadVenda.btnAddItemClick(Sender: TObject);
var
  nQtd, nPerc: Double;
  nPreco: Currency;
begin
  if FrProduto.Id <= 0 then
  begin
    ConsultarProduto;
    if FrProduto.Id <= 0 then
      Exit;
  end;
  if not LerValoresItem(nQtd, nPerc, nPreco) then
    Exit;

  FbCarregandoItem := True;
  FbInserindoItem := True;
  try
    FoItens.Append;
    FoItens.FieldByName('PRODUTO_ID').AsLargeInt := FrProduto.Id;
    FoItens.FieldByName('CODIGO').AsString := FrProduto.Codigo;
    FoItens.FieldByName('DESCRICAO').AsString := FrProduto.Descricao;
    FoItens.FieldByName('UNIDADE').AsString := FrProduto.Unidade;
    FoItens.FieldByName('QUANTIDADE').AsFloat := nQtd;
    FoItens.FieldByName('PRECO_UNIT').AsCurrency := nPreco;
    FoItens.FieldByName('PERC_DESCONTO').AsFloat := nPerc;
    RecalcularLinha;
    FoItens.Post;
  finally
    FbInserindoItem := False;
    FbCarregandoItem := False;
  end;
  RecalcularTotal;
  CarregarCamposDoItem;
end;

procedure TFormCadVenda.btnRemItemClick(Sender: TObject);
begin
  if FoItens.IsEmpty then
    Exit;
  FoItens.Delete;
  RecalcularTotal;
  CarregarCamposDoItem;
end;

function TFormCadVenda.SalvarInterno: Boolean;
var
  nDesc: Currency;
  dtVenc: TDateTime;
  oItens: TArray<TItemVenda>;
begin
  Result := False;
  if not TryStrToCurr(edtDesconto.Text, nDesc) or (nDesc < 0) then
  begin
    Avisar('Desconto da venda inv'#$00E1'lido.');
    Exit;
  end;
  if dtpVenc.Checked then
    dtVenc := DateOf(dtpVenc.Date)
  else
    dtVenc := 0;

  oItens := MontarItens;
  try
    if FiId = 0 then
      FiId := FoDAO.Inserir(ObterClienteSelecionado, FiUsuarioId, dtVenc, nDesc, edtObs.Text, oItens)
    else
      FoDAO.Atualizar(FiId, ObterClienteSelecionado, dtVenc, nDesc, edtObs.Text, oItens);
    Caption := 'Venda ' + FiId.ToString;
    Result := True;
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TFormCadVenda.btnSalvarClick(Sender: TObject);
begin
  if SalvarInterno then
    ModalResult := mrOk;
end;

procedure TFormCadVenda.btnImprimirClick(Sender: TObject);
var
  oCab, oItens: TFDQuery;
begin
  if FiId = 0 then
  begin
    if not SalvarInterno then
      Exit;
  end;
  oCab := FoDAO.CarregarCabecalho(FiId);
  oItens := FoDAO.CarregarItens(FiId);
  try
    VisualizarPedido(oCab, oItens);
  finally
    oItens.Free;
    oCab.Free;
  end;
end;

end.