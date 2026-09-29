unit uQuitacaoBaixa;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.UITypes, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  uTipos;

type
  TFormQuitacaoBaixa = class(TForm)
    lblVenda: TLabel;
    lblValor: TLabel;
    edtValor: TEdit;
    lblForma: TLabel;
    cmbForma: TComboBox;
    lblObs: TLabel;
    edtObs: TEdit;
    btnConfirmar: TButton;
    btnCancelar: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnConfirmarClick(Sender: TObject);
  private
    FnValorRecebido: Currency;
    FeFormaPagamento: TFormaPagamento;
  public

    class function Executar(piVendaId: Int64; pnValorSugerido: Currency;
      out pnValorRecebido: Currency; out peFormaPagamento: TFormaPagamento;
      out psObservacao: string): Boolean;
  end;

implementation

{$R *.dfm}

class function TFormQuitacaoBaixa.Executar(piVendaId: Int64; pnValorSugerido: Currency;
  out pnValorRecebido: Currency; out peFormaPagamento: TFormaPagamento;
  out psObservacao: string): Boolean;
var
  oForm: TFormQuitacaoBaixa;
begin
  oForm := TFormQuitacaoBaixa.Create(nil);
  try
    oForm.lblVenda.Caption := Format('Venda #%d', [piVendaId]);
    oForm.edtValor.Text := FormatFloat('0.00', pnValorSugerido);
    Result := oForm.ShowModal = mrOk;
    pnValorRecebido := oForm.FnValorRecebido;
    peFormaPagamento := oForm.FeFormaPagamento;
    psObservacao := oForm.edtObs.Text;
  finally
    oForm.Free;
  end;
end;

procedure TFormQuitacaoBaixa.FormCreate(Sender: TObject);
begin
  cmbForma.Items.Clear;
  cmbForma.Items.Add('Dinheiro');
  cmbForma.Items.Add('PIX');
  cmbForma.Items.Add('Cart'#$00E3'o');
  cmbForma.Items.Add('Boleto');
  cmbForma.ItemIndex := 0;
end;

procedure TFormQuitacaoBaixa.btnConfirmarClick(Sender: TObject);
var
  nValor: Currency;
begin
  if not TryStrToCurr(edtValor.Text, nValor) or (nValor <= 0) then
  begin
    MessageDlg('Informe um valor v'#$00E1'lido, maior que zero.', mtWarning, [mbOK], 0);
    Exit;
  end;
  if cmbForma.ItemIndex < 0 then
  begin
    MessageDlg('Selecione a forma de pagamento.', mtWarning, [mbOK], 0);
    Exit;
  end;

  FnValorRecebido := nValor;
  FeFormaPagamento := TFormaPagamento(cmbForma.ItemIndex + 1);
  ModalResult := mrOk;
end;

end.

