unit uCadCliente;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.UITypes, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  uClienteDAO;

type
  TFormCadCliente = class(TForm)
    lblNome: TLabel;
    edtNome: TEdit;
    lblTipo: TLabel;
    cmbTipo: TComboBox;
    lblDoc: TLabel;
    edtDoc: TEdit;
    lblEmail: TLabel;
    edtEmail: TEdit;
    lblFone: TLabel;
    edtFone: TEdit;
    lblCep: TLabel;
    edtCep: TEdit;
    lblLog: TLabel;
    edtLog: TEdit;
    lblNum: TLabel;
    edtNum: TEdit;
    lblBairro: TLabel;
    edtBairro: TEdit;
    lblCidade: TLabel;
    edtCidade: TEdit;
    lblUf: TLabel;
    cmbUf: TComboBox;
    chkAtivo: TCheckBox;
    btnSalvar: TButton;
    btnCancelar: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
  private
    FoDAO: TClienteDAO;
    FiId: Int64;
  public
    class function ExecutarNovo(poDAO: TClienteDAO): Boolean;
    class function ExecutarEdicao(poDAO: TClienteDAO; piId: Int64): Boolean;
  end;

implementation

{$R *.dfm}

uses
  Data.DB, FireDAC.Comp.Client;

class function TFormCadCliente.ExecutarNovo(poDAO: TClienteDAO): Boolean;
var
  oForm: TFormCadCliente;
begin
  oForm := TFormCadCliente.Create(nil);
  try
    oForm.FoDAO := poDAO;
    oForm.FiId := 0;
    oForm.Caption := 'Novo cliente';
    oForm.chkAtivo.Checked := True;
    oForm.chkAtivo.Enabled := False;
    Result := oForm.ShowModal = mrOk;
  finally
    oForm.Free;
  end;
end;

class function TFormCadCliente.ExecutarEdicao(poDAO: TClienteDAO; piId: Int64): Boolean;
var
  oForm: TFormCadCliente;
  oQry: TFDQuery;
begin
  oForm := TFormCadCliente.Create(nil);
  try
    oForm.FoDAO := poDAO;
    oForm.FiId := piId;
    oForm.Caption := 'Editar cliente';
    oQry := poDAO.Carregar(piId);
    try
      if oQry.IsEmpty then
        raise Exception.Create('Cliente n'#$00E3'o encontrado.');
      oForm.edtNome.Text := oQry.FieldByName('NOME').AsString;
      if oQry.FieldByName('TIPO_PESSOA').AsString = 'J' then
        oForm.cmbTipo.ItemIndex := 1
      else
        oForm.cmbTipo.ItemIndex := 0;
      oForm.edtDoc.Text := oQry.FieldByName('CPF_CNPJ').AsString;
      oForm.edtEmail.Text := oQry.FieldByName('EMAIL').AsString;
      oForm.edtFone.Text := oQry.FieldByName('TELEFONE').AsString;
      oForm.edtCep.Text := oQry.FieldByName('CEP').AsString;
      oForm.edtLog.Text := oQry.FieldByName('LOGRADOURO').AsString;
      oForm.edtNum.Text := oQry.FieldByName('NUMERO').AsString;
      oForm.edtBairro.Text := oQry.FieldByName('BAIRRO').AsString;
      oForm.edtCidade.Text := oQry.FieldByName('CIDADE').AsString;
      oForm.cmbUf.ItemIndex := oForm.cmbUf.Items.IndexOf(oQry.FieldByName('UF').AsString);
      oForm.chkAtivo.Checked := oQry.FieldByName('ATIVO').AsInteger = 1;
    finally
      oQry.Free;
    end;
    Result := oForm.ShowModal = mrOk;
  finally
    oForm.Free;
  end;
end;

procedure TFormCadCliente.FormCreate(Sender: TObject);
begin
  cmbTipo.Items.Clear;
  cmbTipo.Items.Add('Pessoa f'#$00ED'sica');
  cmbTipo.Items.Add('Pessoa jur'#$00ED'dica');
  cmbTipo.ItemIndex := 0;
  cmbUf.Items.CommaText :=
    'AC,AL,AP,AM,BA,CE,DF,ES,GO,MA,MT,MS,MG,PA,PB,PR,PE,PI,RJ,RN,RS,RO,RR,SC,SP,SE,TO';
end;

procedure TFormCadCliente.btnSalvarClick(Sender: TObject);
var
  sUf: string;
begin
  if cmbUf.ItemIndex >= 0 then
    sUf := cmbUf.Text
  else
    sUf := '';

  try
    if FiId = 0 then
      FoDAO.Inserir(edtNome.Text, cmbTipo.ItemIndex = 1, edtDoc.Text, edtEmail.Text,
        edtFone.Text, edtCep.Text, edtLog.Text, edtNum.Text, edtBairro.Text,
        edtCidade.Text, sUf)
    else
      FoDAO.Atualizar(FiId, edtNome.Text, cmbTipo.ItemIndex = 1, edtDoc.Text,
        edtEmail.Text, edtFone.Text, edtCep.Text, edtLog.Text, edtNum.Text,
        edtBairro.Text, edtCidade.Text, sUf, chkAtivo.Checked);
    ModalResult := mrOk;
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

end.
