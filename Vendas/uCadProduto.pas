unit uCadProduto;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.UITypes, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  uProdutoDAO;

type
  TFormCadProduto = class(TForm)
    lblCodigo: TLabel;
    edtCodigo: TEdit;
    lblDescricao: TLabel;
    edtDescricao: TEdit;
    lblUnidade: TLabel;
    edtUnidade: TEdit;
    lblPreco: TLabel;
    edtPreco: TEdit;
    chkAtivo: TCheckBox;
    btnSalvar: TButton;
    btnCancelar: TButton;
    procedure btnSalvarClick(Sender: TObject);
  private
    FoDAO: TProdutoDAO;
    FiId: Int64;
  public
    class function ExecutarNovo(poDAO: TProdutoDAO): Boolean;
    class function ExecutarEdicao(poDAO: TProdutoDAO; piId: Int64;
      const psCodigo, psDescricao, psUnidade: string; pnPreco: Currency; pbAtivo: Boolean): Boolean;
  end;

implementation

{$R *.dfm}

class function TFormCadProduto.ExecutarNovo(poDAO: TProdutoDAO): Boolean;
var
  oForm: TFormCadProduto;
begin
  oForm := TFormCadProduto.Create(nil);
  try
    oForm.FoDAO := poDAO;
    oForm.FiId := 0;
    oForm.Caption := 'Novo produto';
    oForm.edtUnidade.Text := 'UN';
    oForm.edtPreco.Text := '0,00';
    oForm.chkAtivo.Checked := True;
    oForm.chkAtivo.Enabled := False;
    Result := oForm.ShowModal = mrOk;
  finally
    oForm.Free;
  end;
end;

class function TFormCadProduto.ExecutarEdicao(poDAO: TProdutoDAO; piId: Int64;
  const psCodigo, psDescricao, psUnidade: string; pnPreco: Currency; pbAtivo: Boolean): Boolean;
var
  oForm: TFormCadProduto;
begin
  oForm := TFormCadProduto.Create(nil);
  try
    oForm.FoDAO := poDAO;
    oForm.FiId := piId;
    oForm.Caption := 'Editar produto';
    oForm.edtCodigo.Text := psCodigo;
    oForm.edtDescricao.Text := psDescricao;
    oForm.edtUnidade.Text := psUnidade;
    oForm.edtPreco.Text := FormatFloat('0.00', pnPreco);
    oForm.chkAtivo.Checked := pbAtivo;
    Result := oForm.ShowModal = mrOk;
  finally
    oForm.Free;
  end;
end;

procedure TFormCadProduto.btnSalvarClick(Sender: TObject);
var
  nPreco: Currency;
begin
  if not TryStrToCurr(edtPreco.Text, nPreco) then
  begin
    MessageDlg('Informe um pre'#$00E7'o v'#$00E1'lido.', mtWarning, [mbOK], 0);
    Exit;
  end;

  try
    if FiId = 0 then
      FoDAO.Inserir(edtCodigo.Text, edtDescricao.Text, edtUnidade.Text, nPreco)
    else
      FoDAO.Atualizar(FiId, edtCodigo.Text, edtDescricao.Text, edtUnidade.Text, nPreco,
        chkAtivo.Checked);
    ModalResult := mrOk;
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

end.
