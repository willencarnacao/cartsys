unit uConfigEmail;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.UITypes, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  uConfig, uSmtpConfig;

type
  TFormConfigEmail = class(TForm)
    lblAviso: TLabel;
    lblServidor: TLabel;
    edtServidor: TEdit;
    lblPorta: TLabel;
    edtPorta: TEdit;
    lblUsuario: TLabel;
    edtUsuario: TEdit;
    lblSenha: TLabel;
    edtSenha: TEdit;
    lblSenhaDica: TLabel;
    chkTls: TCheckBox;
    lblNome: TLabel;
    edtNome: TEdit;
    lblRemetente: TLabel;
    edtRemetente: TEdit;
    lblTeste: TLabel;
    edtTeste: TEdit;
    btnSalvar: TButton;
    btnTeste: TButton;
    btnFechar: TButton;
    procedure FormShow(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnTesteClick(Sender: TObject);
  private
    FoRepo: TSmtpDAO;
    FrAtual: TConfigSmtp;
    FsSenhaAtual: string;
    FbSalvou: Boolean;
    function EmailValido(const psEmail: string): Boolean;
    function MontarSmtp(out prSmtp: TConfigSmtp): Boolean;
  public
    class function Executar(poRepo: TSmtpDAO; const prAtual: TConfigSmtp): Boolean;
  end;

implementation

uses
  uEnvioEmail;

{$R *.dfm}

class function TFormConfigEmail.Executar(poRepo: TSmtpDAO;
  const prAtual: TConfigSmtp): Boolean;
var
  oForm: TFormConfigEmail;
begin
  oForm := TFormConfigEmail.Create(nil);
  try
    oForm.FoRepo := poRepo;
    oForm.FrAtual := prAtual;
    oForm.ShowModal;
    Result := oForm.FbSalvou;
  finally
    oForm.Free;
  end;
end;

function TFormConfigEmail.EmailValido(const psEmail: string): Boolean;
var
  sEmail: string;
  iArroba: Integer;
begin
  sEmail := Trim(psEmail);
  iArroba := Pos('@', sEmail);
  Result := (iArroba > 1) and (Pos('.', Copy(sEmail, iArroba + 1, MaxInt)) > 1) and
    (Pos(' ', sEmail) = 0);
end;

procedure TFormConfigEmail.FormShow(Sender: TObject);
begin
  edtSenha.PasswordChar := '*';
  edtServidor.Text := FrAtual.Servidor;
  if FrAtual.Porta > 0 then
    edtPorta.Text := IntToStr(FrAtual.Porta)
  else
    edtPorta.Text := '587';
  edtUsuario.Text := FrAtual.Usuario;
  edtSenha.Text := '';
  FsSenhaAtual := FrAtual.Senha;
  chkTls.Checked := FrAtual.UsarTLS or (FrAtual.Servidor = '');
  edtNome.Text := FrAtual.Nome;
  edtRemetente.Text := FrAtual.Remetente;
  if (Trim(edtRemetente.Text) = '') and EmailValido(FrAtual.Usuario) then
    edtRemetente.Text := Trim(FrAtual.Usuario);
  edtTeste.Text := edtRemetente.Text;
end;

function TFormConfigEmail.MontarSmtp(out prSmtp: TConfigSmtp): Boolean;
var
  iPorta: Integer;
  sSenha: string;
begin
  Result := False;
  if Trim(edtServidor.Text) = '' then
  begin
    MessageDlg('Informe o servidor SMTP.', mtWarning, [mbOK], 0);
    edtServidor.SetFocus;
    Exit;
  end;
  if not TryStrToInt(Trim(edtPorta.Text), iPorta) or (iPorta < 1) or (iPorta > 65535) then
  begin
    MessageDlg('Informe uma porta entre 1 e 65535.', mtWarning, [mbOK], 0);
    edtPorta.SetFocus;
    Exit;
  end;
  if Trim(edtUsuario.Text) = '' then
  begin
    MessageDlg('Informe o usu'#$00E1'rio SMTP.', mtWarning, [mbOK], 0);
    edtUsuario.SetFocus;
    Exit;
  end;
  sSenha := edtSenha.Text;
  if sSenha = '' then
    sSenha := FsSenhaAtual;
  if sSenha = '' then
  begin
    MessageDlg('Informe a senha SMTP.', mtWarning, [mbOK], 0);
    edtSenha.SetFocus;
    Exit;
  end;
  if (Trim(edtRemetente.Text) = '') and EmailValido(edtUsuario.Text) then
    edtRemetente.Text := Trim(edtUsuario.Text);
  if not EmailValido(edtRemetente.Text) then
  begin
    if (Trim(edtRemetente.Text) <> '') and (Pos('@', edtRemetente.Text) = 0) and
      (Trim(edtNome.Text) = '') then
      edtNome.Text := Trim(edtRemetente.Text);
    MessageDlg('O e-mail do remetente precisa ser um endere'#$00E7'o, por exemplo nome@provedor.com.'#13#10 +
      'O seu nome fica no campo Nome.', mtWarning, [mbOK], 0);
    edtRemetente.SetFocus;
    Exit;
  end;

  prSmtp.Servidor := Trim(edtServidor.Text);
  prSmtp.Porta := iPorta;
  prSmtp.Usuario := Trim(edtUsuario.Text);
  prSmtp.Senha := sSenha;
  prSmtp.UsarTLS := chkTls.Checked;
  prSmtp.Remetente := Trim(edtRemetente.Text);
  prSmtp.Nome := Trim(edtNome.Text);
  Result := True;
end;

procedure TFormConfigEmail.btnSalvarClick(Sender: TObject);
var
  rSmtp: TConfigSmtp;
begin
  if not MontarSmtp(rSmtp) then
    Exit;
  try
    FoRepo.Gravar(rSmtp);
    FsSenhaAtual := rSmtp.Senha;
    FrAtual := rSmtp;
    edtSenha.Text := '';
    FbSalvou := True;
    MessageDlg('Configura'#$00E7#$00E3'o salva. A senha ficou criptografada no banco.',
      mtInformation, [mbOK], 0);
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TFormConfigEmail.btnTesteClick(Sender: TObject);
var
  rSmtp: TConfigSmtp;
begin
  if not MontarSmtp(rSmtp) then
    Exit;
  if not EmailValido(edtTeste.Text) then
  begin
    MessageDlg('Informe um e-mail v'#$00E1'lido para receber o teste.', mtWarning, [mbOK], 0);
    edtTeste.SetFocus;
    Exit;
  end;
  try
    EnviarEmailTeste(rSmtp, Trim(edtTeste.Text));
    MessageDlg('E-mail de teste enviado para ' + Trim(edtTeste.Text) + '.',
      mtInformation, [mbOK], 0);
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

end.
