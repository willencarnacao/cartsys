unit uQuitacao;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.UITypes, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Grids, Vcl.DBGrids, Data.DB, Data.SqlTimSt, FireDAC.Comp.Client,
  uFinanceiroDAO, uTipos, uQuitacaoBaixa, uGrade;

type
  TFormQuitacao = class(TForm)
    pnlBotoes: TPanel;
    btnQuitar: TButton;
    btnCancelar: TButton;
    btnAtualizar: TButton;
    btnFechar: TButton;
    grdQuitacao: TDBGrid;
    dsPendentes: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnQuitarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnAtualizarClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
  private
    FoDAO: TFinanceiroDAO;
    FiUsuarioId: Int64;
    FoQryPendentes: TFDQuery;
    procedure Recarregar;
    function ObterVendaSelecionada(out piId: Int64; out pnValorTotal: Currency): Boolean;
  public
    class procedure Executar(poDAO: TFinanceiroDAO; piUsuarioId: Int64);
  end;

implementation

{$R *.dfm}

class procedure TFormQuitacao.Executar(poDAO: TFinanceiroDAO; piUsuarioId: Int64);
var
  oForm: TFormQuitacao;
begin
  oForm := TFormQuitacao.Create(nil);
  try
    oForm.FoDAO := poDAO;
    oForm.FiUsuarioId := piUsuarioId;
    oForm.Recarregar;
    oForm.ShowModal;
  finally
    oForm.Free;
  end;
end;

procedure TFormQuitacao.FormCreate(Sender: TObject);
begin
  PrepararGrade(grdQuitacao);
end;

procedure TFormQuitacao.FormDestroy(Sender: TObject);
begin
  FoQryPendentes.Free;
end;

procedure TFormQuitacao.Recarregar;

  procedure FormatarData(const psCampo: string);
  begin
    if FoQryPendentes.FieldByName(psCampo) is TSQLTimeStampField then
      TSQLTimeStampField(FoQryPendentes.FieldByName(psCampo)).DisplayFormat := 'dd/mm/yyyy'
    else if FoQryPendentes.FieldByName(psCampo) is TDateTimeField then
      TDateTimeField(FoQryPendentes.FieldByName(psCampo)).DisplayFormat := 'dd/mm/yyyy';
    FoQryPendentes.FieldByName(psCampo).DisplayWidth := 12;
  end;

begin
  dsPendentes.DataSet := nil;
  FreeAndNil(FoQryPendentes);
  FoQryPendentes := FoDAO.ListarPendentes;
  NomearCampo(FoQryPendentes, 'ID', 'N'#186);
  NomearCampo(FoQryPendentes, 'CLIENTE', 'Cliente');
  NomearCampo(FoQryPendentes, 'DT_EMISSAO', 'Emiss'#227'o');
  NomearCampo(FoQryPendentes, 'DT_VENCIMENTO', 'Vencimento');
  NomearCampo(FoQryPendentes, 'VL_ITENS', 'Itens');
  NomearCampo(FoQryPendentes, 'VL_DESCONTO', 'Desconto');
  NomearCampo(FoQryPendentes, 'VL_TOTAL', 'Total');
  FoQryPendentes.FieldByName('ID').DisplayWidth := 8;
  FoQryPendentes.FieldByName('CLIENTE').DisplayWidth := 32;
  FormatarData('DT_EMISSAO');
  FormatarData('DT_VENCIMENTO');
  FoQryPendentes.FieldByName('VL_ITENS').DisplayWidth := 12;
  FoQryPendentes.FieldByName('VL_DESCONTO').DisplayWidth := 12;
  FoQryPendentes.FieldByName('VL_TOTAL').DisplayWidth := 12;
  AplicarFormatoMoeda(FoQryPendentes, 'VL_ITENS');
  AplicarFormatoMoeda(FoQryPendentes, 'VL_DESCONTO');
  AplicarFormatoMoeda(FoQryPendentes, 'VL_TOTAL');
  dsPendentes.DataSet := FoQryPendentes;
end;

function TFormQuitacao.ObterVendaSelecionada(out piId: Int64; out pnValorTotal: Currency): Boolean;
begin
  Result := Assigned(FoQryPendentes) and not FoQryPendentes.IsEmpty;
  if not Result then
    Exit;
  piId := FoQryPendentes.FieldByName('ID').AsLargeInt;
  pnValorTotal := FoQryPendentes.FieldByName('VL_TOTAL').AsCurrency;
end;

procedure TFormQuitacao.btnQuitarClick(Sender: TObject);
var
  iId: Int64;
  nValorTotal, nValorRecebido: Currency;
  eForma: TFormaPagamento;
  sObs: string;
begin
  if not ObterVendaSelecionada(iId, nValorTotal) then
  begin
    MessageDlg('Selecione uma venda pendente na lista.', mtWarning, [mbOK], 0);
    Exit;
  end;

  if not TFormQuitacaoBaixa.Executar(iId, nValorTotal, nValorRecebido, eForma, sObs) then
    Exit;

  try
    FoDAO.Quitar(iId, FiUsuarioId, nValorRecebido, eForma, sObs);
    Recarregar;
    MessageDlg(Format('Venda #%d quitada. O Vendas vai enviar o e-mail de ' +
      'confirma'#$00E7#$00E3'o para o cliente assim que estiver aberto.', [iId]),
      mtInformation, [mbOK], 0);
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TFormQuitacao.btnCancelarClick(Sender: TObject);
var
  iId: Int64;
  nValorTotal: Currency;
  sMotivo: string;
begin
  if not ObterVendaSelecionada(iId, nValorTotal) then
  begin
    MessageDlg('Selecione uma venda pendente na lista.', mtWarning, [mbOK], 0);
    Exit;
  end;

  sMotivo := '';
  if not InputQuery(Format('Cancelar venda #%d', [iId]), 'Motivo do cancelamento:', sMotivo) then
    Exit;

  try
    FoDAO.Cancelar(iId, FiUsuarioId, sMotivo);
    Recarregar;
    MessageDlg(Format('Venda #%d cancelada.', [iId]), mtInformation, [mbOK], 0);
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TFormQuitacao.btnAtualizarClick(Sender: TObject);
begin
  Recarregar;
end;

procedure TFormQuitacao.btnFecharClick(Sender: TObject);
begin
  Close;
end;

end.

