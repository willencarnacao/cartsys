unit uCadUsuario;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.UITypes, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  uUsuarioDAO;

type
  TFormCadUsuario = class(TForm)
    lblLogin: TLabel;
    edtLogin: TEdit;
    lblNome: TLabel;
    edtNome: TEdit;
    lblEmail: TLabel;
    edtEmail: TEdit;
    chkAdmin: TCheckBox;
    chkVendas: TCheckBox;
    chkFinanceiro: TCheckBox;
    chkAtivo: TCheckBox;
    btnSalvar: TButton;
    btnCancelar: TButton;
    procedure btnSalvarClick(Sender: TObject);
  private
    FoDAO: TUsuarioDAO;
    FiUsuarioId: Int64;
    FsSenhaTemporariaGerada: string;
  public

    class function ExecutarNovo(poDAO: TUsuarioDAO; out psSenhaTemporaria: string): Boolean;

    class function ExecutarEdicao(poDAO: TUsuarioDAO; piUsuarioId: Int64;
      const psLogin, psNome, psEmail: string; pbIsAdmin, pbAcessaVendas,
      pbAcessaFinanceiro, pbAtivo: Boolean): Boolean;
  end;

implementation

{$R *.dfm}

class function TFormCadUsuario.ExecutarNovo(poDAO: TUsuarioDAO;
  out psSenhaTemporaria: string): Boolean;
var
  oForm: TFormCadUsuario;
begin
  oForm := TFormCadUsuario.Create(nil);
  try
    oForm.FoDAO := poDAO;
    oForm.FiUsuarioId := 0;
    oForm.Caption := 'Novo usu'#$00E1'rio';
    oForm.chkAtivo.Checked := True;
    Result := oForm.ShowModal = mrOk;
    psSenhaTemporaria := oForm.FsSenhaTemporariaGerada;
  finally
    oForm.Free;
  end;
end;

class function TFormCadUsuario.ExecutarEdicao(poDAO: TUsuarioDAO; piUsuarioId: Int64;
  const psLogin, psNome, psEmail: string; pbIsAdmin, pbAcessaVendas, pbAcessaFinanceiro,
  pbAtivo: Boolean): Boolean;
var
  oForm: TFormCadUsuario;
begin
  oForm := TFormCadUsuario.Create(nil);
  try
    oForm.FoDAO := poDAO;
    oForm.FiUsuarioId := piUsuarioId;
    oForm.Caption := 'Editar usu'#$00E1'rio';
    oForm.edtLogin.Text := psLogin;
    oForm.edtLogin.Enabled := False;
    oForm.edtNome.Text := psNome;
    oForm.edtEmail.Text := psEmail;
    oForm.chkAdmin.Checked := pbIsAdmin;
    oForm.chkVendas.Checked := pbAcessaVendas;
    oForm.chkFinanceiro.Checked := pbAcessaFinanceiro;
    oForm.chkAtivo.Checked := pbAtivo;
    Result := oForm.ShowModal = mrOk;
  finally
    oForm.Free;
  end;
end;

procedure TFormCadUsuario.btnSalvarClick(Sender: TObject);
begin
  if Trim(edtNome.Text) = '' then
  begin
    MessageDlg('Informe o nome.', mtWarning, [mbOK], 0);
    Exit;
  end;
  if (FiUsuarioId = 0) and (Trim(edtLogin.Text) = '') then
  begin
    MessageDlg('Informe o login.', mtWarning, [mbOK], 0);
    Exit;
  end;
  if not (chkVendas.Checked or chkFinanceiro.Checked) then
  begin
    MessageDlg('Marque acesso a pelo menos um m'#$00F3'dulo.', mtWarning, [mbOK], 0);
    Exit;
  end;

  try
    if FiUsuarioId = 0 then
      FiUsuarioId := FoDAO.Inserir(edtLogin.Text, edtNome.Text, edtEmail.Text,
        chkAdmin.Checked, chkVendas.Checked, chkFinanceiro.Checked,
        FsSenhaTemporariaGerada)
    else
      FoDAO.Atualizar(FiUsuarioId, edtNome.Text, edtEmail.Text, chkAdmin.Checked,
        chkVendas.Checked, chkFinanceiro.Checked, chkAtivo.Checked);

    ModalResult := mrOk;
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

end.

