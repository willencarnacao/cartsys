unit uTrocaSenha;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.UITypes, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  uAutenticacao;

type
  TFormTrocaSenha = class(TForm)
    lblInfo: TLabel;
    lblAtual: TLabel;
    edtAtual: TEdit;
    lblNova: TLabel;
    edtNova: TEdit;
    lblConfirma: TLabel;
    edtConfirma: TEdit;
    btnSalvar: TButton;
    btnCancelar: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
  private
    FoAutenticacao: TAutenticacaoService;
    FiUsuarioId: Int64;
  public
    class function Executar(poAutenticacao: TAutenticacaoService; piUsuarioId: Int64;
      const psSenhaAtual: string): Boolean;
  end;

implementation

{$R *.dfm}

class function TFormTrocaSenha.Executar(poAutenticacao: TAutenticacaoService;
  piUsuarioId: Int64; const psSenhaAtual: string): Boolean;
var
  oForm: TFormTrocaSenha;
begin
  oForm := TFormTrocaSenha.Create(nil);
  try
    oForm.FoAutenticacao := poAutenticacao;
    oForm.FiUsuarioId := piUsuarioId;
    oForm.edtAtual.Text := psSenhaAtual;
    Result := oForm.ShowModal = mrOk;
  finally
    oForm.Free;
  end;
end;

procedure TFormTrocaSenha.FormCreate(Sender: TObject);
begin
  edtAtual.PasswordChar := '*';
  edtNova.PasswordChar := '*';
  edtConfirma.PasswordChar := '*';
end;

procedure TFormTrocaSenha.btnSalvarClick(Sender: TObject);
begin
  if edtNova.Text <> edtConfirma.Text then
  begin
    MessageDlg('A confirma'#$00E7#$00E3'o n'#$00E3'o bate com a nova senha.', mtWarning, [mbOK], 0);
    Exit;
  end;

  try
    FoAutenticacao.TrocarSenha(FiUsuarioId, edtAtual.Text, edtNova.Text);
    ModalResult := mrOk;
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

end.
