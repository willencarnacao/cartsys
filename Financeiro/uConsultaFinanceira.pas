unit uConsultaFinanceira;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.DateUtils, System.UITypes,
  System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.Grids, Vcl.DBGrids, Data.DB, FireDAC.Comp.Client,
  uFinanceiroDAO, uTipos, uRelFinanceiro, uGrade;

type
  TFormConsultaFinanceira = class(TForm)
    pnlFiltro: TPanel;
    lblDataInicial: TLabel;
    dtpDataInicial: TDateTimePicker;
    lblDataFinal: TLabel;
    dtpDataFinal: TDateTimePicker;
    btnBuscar: TButton;
    pnlRodape: TPanel;
    lblTotais: TLabel;
    btnImprimir: TButton;
    btnFechar: TButton;
    grdConsulta: TDBGrid;
    dsConsulta: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnBuscarClick(Sender: TObject);
    procedure btnImprimirClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
  private
    FoDAO: TFinanceiroDAO;
    FoQryResultado: TFDQuery;
    procedure AtualizarTotais(pdtDataInicial, pdtDataFinal: TDateTime);
  public
    class procedure Executar(poDAO: TFinanceiroDAO);
  end;

implementation

{$R *.dfm}

class procedure TFormConsultaFinanceira.Executar(poDAO: TFinanceiroDAO);
var
  oForm: TFormConsultaFinanceira;
begin
  oForm := TFormConsultaFinanceira.Create(nil);
  try
    oForm.FoDAO := poDAO;
    oForm.ShowModal;
  finally
    oForm.Free;
  end;
end;

procedure TFormConsultaFinanceira.FormCreate(Sender: TObject);
begin
  PrepararGrade(grdConsulta);
  dtpDataInicial.Date := IncMonth(Date, -1);
  dtpDataFinal.Date := Date;
end;

procedure TFormConsultaFinanceira.FormDestroy(Sender: TObject);
begin
  FoQryResultado.Free;
end;

procedure TFormConsultaFinanceira.btnBuscarClick(Sender: TObject);
var
  dtDataInicial, dtDataFinal: TDateTime;
begin
  dtDataInicial := DateOf(dtpDataInicial.Date);
  dtDataFinal := DateOf(dtpDataFinal.Date);
  if dtDataInicial > dtDataFinal then
  begin
    MessageDlg('A data inicial n'#$00E3'o pode ser depois da data final.', mtWarning, [mbOK], 0);
    Exit;
  end;

  dsConsulta.DataSet := nil;
  FreeAndNil(FoQryResultado);
  FoQryResultado := FoDAO.ListarPorPeriodo(dtDataInicial, dtDataFinal);
  dsConsulta.DataSet := FoQryResultado;
  NomearCampo(FoQryResultado, 'ID', 'Venda');
  NomearCampo(FoQryResultado, 'CLIENTE', 'Cliente');
  NomearCampo(FoQryResultado, 'STATUS_DESC', 'Status');
  NomearCampo(FoQryResultado, 'DT_EMISSAO', 'Emiss'#$00E3'o');
  NomearCampo(FoQryResultado, 'DT_RECEBIMENTO', 'Recebimento');
  NomearCampo(FoQryResultado, 'FORMA_DESC', 'Forma Pgto.');
  NomearCampo(FoQryResultado, 'VL_TOTAL', 'Total');
  AplicarFormatoMoeda(FoQryResultado, 'VL_TOTAL');

  AtualizarTotais(dtDataInicial, dtDataFinal);
end;

procedure TFormConsultaFinanceira.AtualizarTotais(pdtDataInicial, pdtDataFinal: TDateTime);
var
  iQtdQuitada, iQtdCancelada: Integer;
  nValorQuitado: Currency;
begin
  FoDAO.TotaisPorPeriodo(pdtDataInicial, pdtDataFinal, iQtdQuitada, nValorQuitado, iQtdCancelada);
  lblTotais.Caption := Format(
    'Quitadas: %d (%s)     Canceladas: %d',
    [iQtdQuitada, FormatCurr('R$ #,##0.00', nValorQuitado), iQtdCancelada]);
end;

procedure TFormConsultaFinanceira.btnImprimirClick(Sender: TObject);
var
  dtDataInicial, dtDataFinal: TDateTime;
begin
  dtDataInicial := DateOf(dtpDataInicial.Date);
  dtDataFinal := DateOf(dtpDataFinal.Date);
  if not Assigned(FoQryResultado) then
  begin
    MessageDlg('Busque um per'#$00ED'odo v'#$00E1'lido antes de imprimir.', mtWarning, [mbOK], 0);
    Exit;
  end;
  GerarRelatorioFinanceiro(FoQryResultado, dtDataInicial, dtDataFinal);
end;

procedure TFormConsultaFinanceira.btnFecharClick(Sender: TObject);
begin
  Close;
end;

end.

