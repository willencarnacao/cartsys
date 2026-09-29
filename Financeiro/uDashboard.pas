unit uDashboard;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Grids, Vcl.DBGrids, Data.DB, FireDAC.Comp.Client, uDashboardDAO, uGrade;

type
  TPontoMes = record
    Rotulo: string;
    Projetado, Realizado: Currency;
  end;

  TFormDashboard = class(TForm)
    pnlCards: TPanel;
    pnlCardPendente: TPanel;
    lblCardPendenteTitulo: TLabel;
    lblCardPendenteValor: TLabel;
    pnlCardRealizado: TPanel;
    lblCardRealizadoTitulo: TLabel;
    lblCardRealizadoValor: TLabel;
    pnlCardTicket: TPanel;
    lblCardTicketTitulo: TLabel;
    lblCardTicketValor: TLabel;
    pnlCardCanceladas: TPanel;
    lblCardCanceladasTitulo: TLabel;
    lblCardCanceladasValor: TLabel;
    pnlGrafico: TPanel;
    lblGrafico: TLabel;
    pbMes: TPaintBox;
    pnlListas: TPanel;
    lblTopProdutos: TLabel;
    grdProdutos: TDBGrid;
    dsTopProdutos: TDataSource;
    lblTopClientes: TLabel;
    grdClientes: TDBGrid;
    dsTopClientes: TDataSource;
    lblForma: TLabel;
    grdForma: TDBGrid;
    dsForma: TDataSource;
    pnlBotoes: TPanel;
    btnAtualizar: TButton;
    btnFechar: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnAtualizarClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure pbMesPaint(Sender: TObject);
  private
    FoDAO: TDashboardDAO;
    FoQryTopProdutos, FoQryTopClientes, FoQryForma: TFDQuery;
    FaMeses: TArray<TPontoMes>;
    procedure Recarregar;
  public
    class procedure Executar(poDAO: TDashboardDAO);
  end;

implementation

{$R *.dfm}

uses
  System.Math;

class procedure TFormDashboard.Executar(poDAO: TDashboardDAO);
var
  oForm: TFormDashboard;
begin
  oForm := TFormDashboard.Create(nil);
  try
    oForm.FoDAO := poDAO;
    oForm.Recarregar;
    oForm.ShowModal;
  finally
    oForm.Free;
  end;
end;

procedure TFormDashboard.FormCreate(Sender: TObject);
begin
  PrepararGrade(grdProdutos);
  PrepararGrade(grdClientes);
  PrepararGrade(grdForma);
end;

procedure TFormDashboard.FormDestroy(Sender: TObject);
begin
  FoQryTopProdutos.Free;
  FoQryTopClientes.Free;
  FoQryForma.Free;
end;

procedure TFormDashboard.Recarregar;
var
  rIndicadores: TIndicadoresDashboard;
  oQryMes: TFDQuery;
  iIndice: Integer;
begin
  rIndicadores := FoDAO.Indicadores;

  lblCardPendenteTitulo.Caption := Format('Pendentes (%d)', [rIndicadores.QtdPendente]);
  lblCardPendenteValor.Caption := FormatCurr('R$ #,##0.00', rIndicadores.ValorProjetado);

  lblCardRealizadoTitulo.Caption := Format('Finalizados (%d)', [rIndicadores.QtdQuitada]);
  lblCardRealizadoValor.Caption := FormatCurr('R$ #,##0.00', rIndicadores.ValorRealizado);

  lblCardTicketTitulo.Caption := 'Ticket m'#$00E9'dio (quitadas)';
  lblCardTicketValor.Caption := FormatCurr('R$ #,##0.00', rIndicadores.TicketMedio);

  lblCardCanceladasTitulo.Caption := 'Canceladas';
  lblCardCanceladasValor.Caption := IntToStr(rIndicadores.QtdCancelada);

  dsTopProdutos.DataSet := nil;
  FreeAndNil(FoQryTopProdutos);
  FoQryTopProdutos := FoDAO.TopProdutos;
  dsTopProdutos.DataSet := FoQryTopProdutos;
  NomearCampo(FoQryTopProdutos, 'DESCRICAO', 'Produto');
  NomearCampo(FoQryTopProdutos, 'QTD_VENDIDA', 'Qtd.');
  NomearCampo(FoQryTopProdutos, 'VALOR', 'Valor');
  AplicarFormatoMoeda(FoQryTopProdutos, 'VALOR');

  dsTopClientes.DataSet := nil;
  FreeAndNil(FoQryTopClientes);
  FoQryTopClientes := FoDAO.TopClientes;
  dsTopClientes.DataSet := FoQryTopClientes;
  NomearCampo(FoQryTopClientes, 'NOME', 'Cliente');
  NomearCampo(FoQryTopClientes, 'QTD_VENDAS', 'Vendas');
  NomearCampo(FoQryTopClientes, 'VALOR', 'Valor');
  AplicarFormatoMoeda(FoQryTopClientes, 'VALOR');

  dsForma.DataSet := nil;
  FreeAndNil(FoQryForma);
  FoQryForma := FoDAO.VendasPorForma;
  dsForma.DataSet := FoQryForma;
  NomearCampo(FoQryForma, 'FORMA', 'Forma');
  NomearCampo(FoQryForma, 'QTD', 'Qtd.');
  NomearCampo(FoQryForma, 'VALOR', 'Valor');
  AplicarFormatoMoeda(FoQryForma, 'VALOR');

  oQryMes := FoDAO.VendasPorMes;
  try
    SetLength(FaMeses, 0);
    while not oQryMes.Eof do
    begin
      iIndice := Length(FaMeses);
      SetLength(FaMeses, iIndice + 1);
      FaMeses[iIndice].Rotulo := Format('%.2d/%d', [oQryMes.FieldByName('MES').AsInteger,
        oQryMes.FieldByName('ANO').AsInteger]);
      FaMeses[iIndice].Projetado := oQryMes.FieldByName('PROJETADO').AsCurrency;
      FaMeses[iIndice].Realizado := oQryMes.FieldByName('REALIZADO').AsCurrency;
      oQryMes.Next;
    end;
  finally
    oQryMes.Free;
  end;
  pbMes.Invalidate;
end;

procedure TFormDashboard.pbMesPaint(Sender: TObject);
const
  FAIXA_LEGENDA = 22;
  FAIXA_ROTULO = 18;
  MARGEM = 12;
var
  iMes, iGrupo, iBaseX, iBarraW, iBaseY, iAlturaUtil: Integer;
  nMax: Currency;
  rBarra: TRect;
begin
  pbMes.Canvas.Brush.Color := clWindow;
  pbMes.Canvas.FillRect(pbMes.ClientRect);
  pbMes.Canvas.Font.Name := 'Segoe UI';
  pbMes.Canvas.Font.Size := 8;

  pbMes.Canvas.Brush.Color := $00B1C48A;
  pbMes.Canvas.FillRect(Rect(MARGEM, 4, MARGEM + 12, 16));
  pbMes.Canvas.Brush.Style := bsClear;
  pbMes.Canvas.TextOut(MARGEM + 16, 2, 'Projetado');
  pbMes.Canvas.Brush.Style := bsSolid;
  pbMes.Canvas.Brush.Color := $00C47A3A;
  pbMes.Canvas.FillRect(Rect(MARGEM + 90, 4, MARGEM + 102, 16));
  pbMes.Canvas.Brush.Style := bsClear;
  pbMes.Canvas.TextOut(MARGEM + 106, 2, 'Realizado');
  pbMes.Canvas.Brush.Style := bsSolid;

  if Length(FaMeses) = 0 then
  begin
    pbMes.Canvas.Brush.Style := bsClear;
    pbMes.Canvas.TextOut(MARGEM, FAIXA_LEGENDA + 8, 'Sem movimento mensal ainda.');
    Exit;
  end;

  nMax := 1;
  for iMes := 0 to High(FaMeses) do
    nMax := Max(nMax, Max(FaMeses[iMes].Projetado, FaMeses[iMes].Realizado));

  iBaseY := pbMes.Height - FAIXA_ROTULO;
  iAlturaUtil := Max(1, iBaseY - FAIXA_LEGENDA);
  iGrupo := Max(40, (pbMes.Width - MARGEM * 2) div Length(FaMeses));
  iBarraW := Max(8, (iGrupo - 12) div 2);

  for iMes := 0 to High(FaMeses) do
  begin
    iBaseX := MARGEM + iMes * iGrupo;
    rBarra := Rect(iBaseX,
      iBaseY - Trunc((FaMeses[iMes].Projetado / nMax) * iAlturaUtil),
      iBaseX + iBarraW, iBaseY);
    pbMes.Canvas.Brush.Color := $00B1C48A;
    pbMes.Canvas.FillRect(rBarra);

    rBarra := Rect(iBaseX + iBarraW + 2,
      iBaseY - Trunc((FaMeses[iMes].Realizado / nMax) * iAlturaUtil),
      iBaseX + 2 * iBarraW + 2, iBaseY);
    pbMes.Canvas.Brush.Color := $00C47A3A;
    pbMes.Canvas.FillRect(rBarra);

    pbMes.Canvas.Brush.Style := bsClear;
    pbMes.Canvas.TextOut(iBaseX, iBaseY + 2, FaMeses[iMes].Rotulo);
    pbMes.Canvas.Brush.Style := bsSolid;
  end;
end;

procedure TFormDashboard.btnAtualizarClick(Sender: TObject);
begin
  Recarregar;
end;

procedure TFormDashboard.btnFecharClick(Sender: TObject);
begin
  Close;
end;

end.
