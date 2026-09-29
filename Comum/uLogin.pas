unit uLogin;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.UITypes, Vcl.StdCtrls, Vcl.ExtCtrls,
  uAutenticacao, uTipos, uTrocaSenha, uQrCode;

type
  TFormLogin = class(TForm)
    pnlLogin: TPanel;
    lblTitulo: TLabel;
    lblLogin: TLabel;
    edtLogin: TEdit;
    lblSenha: TLabel;
    edtSenha: TEdit;
    lblCodigo: TLabel;
    edtCodigo: TEdit;
    btnEntrar: TButton;
    pnlPareamento: TPanel;
    lblParInfo: TLabel;
    memoUri: TMemo;
    lblParChaveTitulo: TLabel;
    lblParChave: TLabel;
    imgQr: TImage;
    lblParCodigo: TLabel;
    edtCodigoPareamento: TEdit;
    btnConfirmarPareamento: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnEntrarClick(Sender: TObject);
    procedure btnConfirmarPareamentoClick(Sender: TObject);
    procedure edtCodigoKeyPress(Sender: TObject; var Key: Char);
  private
    FoAutenticacao: TAutenticacaoService;
    FsModulo: string;
    FiUsuarioId: Int64;
    FiUsuarioIdPareamento: Int64;
    FiTentativasPareamento: Integer;

    procedure MostrarPainelPareamento(const psUri: string; piUsuarioId: Int64);
    procedure MostrarErroLogin(peResultado: TResultadoLogin);
    function ExtrairChaveDaUri(const psUri: string): string;
    function ConcluirLogin(piUsuarioId: Int64; const psSenhaUsada: string): Boolean;
  public

    class function Executar(poAutenticacao: TAutenticacaoService;
      const psModulo: string; out piUsuarioId: Int64): Boolean;
  end;

implementation

{$R *.dfm}

class function TFormLogin.Executar(poAutenticacao: TAutenticacaoService;
  const psModulo: string; out piUsuarioId: Int64): Boolean;
var
  oForm: TFormLogin;
begin
  oForm := TFormLogin.Create(nil);
  try
    oForm.FoAutenticacao := poAutenticacao;
    oForm.FsModulo := psModulo;
    Result := oForm.ShowModal = mrOk;
    piUsuarioId := oForm.FiUsuarioId;
  finally
    oForm.Free;
  end;
end;

procedure TFormLogin.FormCreate(Sender: TObject);
begin
  pnlPareamento.Visible := False;
  edtSenha.PasswordChar := '*';
  edtCodigo.MaxLength := TOTP_DIGITOS;
  edtCodigoPareamento.MaxLength := TOTP_DIGITOS;
  FiTentativasPareamento := 0;
  ActiveControl := edtLogin;
end;

procedure TFormLogin.edtCodigoKeyPress(Sender: TObject; var Key: Char);
begin

  if not (CharInSet(Key, ['0'..'9', #8, #13])) then
    Key := #0
  else if Key = #13 then
  begin
    Key := #0;
    if pnlPareamento.Visible then
      btnConfirmarPareamento.Click
    else
      btnEntrar.Click;
  end;
end;

function TFormLogin.ExtrairChaveDaUri(const psUri: string): string;
var
  iInicio, iFim: Integer;
begin

  Result := '';
  iInicio := Pos('secret=', psUri);
  if iInicio = 0 then
    Exit;
  iInicio := iInicio + Length('secret=');
  iFim := Pos('&', psUri, iInicio);
  if iFim = 0 then
    iFim := Length(psUri) + 1;
  Result := Copy(psUri, iInicio, iFim - iInicio);
end;

procedure TFormLogin.MostrarPainelPareamento(const psUri: string; piUsuarioId: Int64);
var
  oQr: TBitmap;
  iAbaixo: Integer;
begin
  FiUsuarioIdPareamento := piUsuarioId;
  memoUri.Lines.Text := psUri;
  lblParChave.Caption := ExtrairChaveDaUri(psUri);
  ClientWidth := 720;
  lblParInfo.AutoSize := False;
  lblParInfo.WordWrap := True;
  lblParInfo.Left := 24;
  lblParInfo.Top := 16;
  lblParInfo.Width := ClientWidth - 48;
  lblParInfo.Height := 56;
  lblParInfo.Caption :=
    'No Authenticator escolha Outra conta, aponte a c'#$00E2'mera para o QR Code.' +
    sLineBreak +
    'Se n'#$00E3'o ler, cadastre a chave manualmente.';
  imgQr.Stretch := False;
  imgQr.Proportional := False;
  imgQr.Center := True;
  oQr := nil;
  try
    oQr := GerarQrBitmap(psUri, 320);
    imgQr.Picture.Assign(oQr);
    imgQr.Width := oQr.Width;
    imgQr.Height := oQr.Height;
  except
    imgQr.Picture.Assign(nil);
  end;
  oQr.Free;
  imgQr.Top := 76;
  imgQr.Left := (ClientWidth - imgQr.Width) div 2;
  iAbaixo := imgQr.Top + imgQr.Height + 12;
  lblParChaveTitulo.Top := iAbaixo;
  lblParChaveTitulo.Width := ClientWidth - 48;
  lblParChave.Top := iAbaixo + 16;
  lblParChave.AutoSize := False;
  lblParChave.WordWrap := True;
  lblParChave.Width := ClientWidth - 48;
  lblParCodigo.Top := iAbaixo + 52;
  lblParCodigo.Width := ClientWidth - 48;
  edtCodigoPareamento.Top := iAbaixo + 70;
  btnConfirmarPareamento.Top := iAbaixo + 110;
  btnConfirmarPareamento.Width := ClientWidth - 48;
  ClientHeight := btnConfirmarPareamento.Top + btnConfirmarPareamento.Height + 24;
  pnlLogin.Visible := False;
  pnlPareamento.Visible := True;
  ActiveControl := edtCodigoPareamento;
end;

function TFormLogin.ConcluirLogin(piUsuarioId: Int64; const psSenhaUsada: string): Boolean;
begin
  Result := True;
  if FoAutenticacao.PrecisaTrocarSenha(piUsuarioId) then
    Result := TFormTrocaSenha.Executar(FoAutenticacao, piUsuarioId, psSenhaUsada);
  if Result then
  begin
    FiUsuarioId := piUsuarioId;
    ModalResult := mrOk;
  end;
end;

procedure TFormLogin.MostrarErroLogin(peResultado: TResultadoLogin);
var
  sTexto: string;
begin
  case peResultado of
    rlSenhaInvalida:
      sTexto := 'Usu'#$00E1'rio ou senha inv'#$00E1'lidos.';
    rlCodigoTotpInvalido:
      sTexto := 'C'#$00F3'digo do aplicativo autenticador inv'#$00E1'lido.';
    rlUsuarioBloqueado:
      sTexto := 'Usu'#$00E1'rio bloqueado. Fale com o administrador.';
    rlBloqueioAplicado:
      sTexto := 'Usu'#$00E1'rio bloqueado ap'#$00F3's v'#$00E1'rias tentativas. Fale com o administrador.';
  else
    sTexto := 'N'#$00E3'o foi poss'#$00ED'vel entrar.';
  end;
  MessageDlg(sTexto, mtWarning, [mbOK], 0);

  edtSenha.Text := '';
  edtCodigo.Text := '';
  ActiveControl := edtLogin;
end;

procedure TFormLogin.btnEntrarClick(Sender: TObject);
var
  eResultado: TResultadoLogin;
  bPrecisaParear: Boolean;
  sUri: string;
  iUsuarioId: Int64;
begin
  if (Trim(edtLogin.Text) = '') or (edtSenha.Text = '') then
  begin
    MessageDlg('Informe usu'#$00E1'rio e senha.', mtWarning, [mbOK], 0);
    Exit;
  end;

  btnEntrar.Enabled := False;
  Screen.Cursor := crHourGlass;
  try
    if FoAutenticacao.Autenticar(Trim(edtLogin.Text), edtSenha.Text, edtCodigo.Text,
         FsModulo, iUsuarioId, eResultado, bPrecisaParear, sUri) then
      ConcluirLogin(iUsuarioId, edtSenha.Text)
    else if bPrecisaParear then
      MostrarPainelPareamento(sUri, iUsuarioId)
    else
      MostrarErroLogin(eResultado);
  finally
    Screen.Cursor := crDefault;
    btnEntrar.Enabled := True;
  end;
end;

procedure TFormLogin.btnConfirmarPareamentoClick(Sender: TObject);
begin
  if edtCodigoPareamento.Text = '' then
  begin
    MessageDlg('Digite o c'#$00F3'digo gerado pelo aplicativo.', mtWarning, [mbOK], 0);
    Exit;
  end;

  btnConfirmarPareamento.Enabled := False;
  Screen.Cursor := crHourGlass;
  try
    if FoAutenticacao.ConfirmarPareamentoTotp(FiUsuarioIdPareamento, edtCodigoPareamento.Text) then
    begin
      ConcluirLogin(FiUsuarioIdPareamento, edtSenha.Text);
      Exit;
    end;

    Inc(FiTentativasPareamento);
    if FiTentativasPareamento >= MAX_TENTATIVAS_LOGIN then
    begin
      MessageDlg('Muitas tentativas de confirma'#$00E7#$00E3'o. Pe'#$00E7'a ao administrador para ' +
        'verificar o cadastro e tente novamente mais tarde.', mtError, [mbOK], 0);
      ModalResult := mrCancel;
      Exit;
    end;

    MessageDlg('C'#$00F3'digo inv'#$00E1'lido. Confira o hor'#$00E1'rio do celular e tente de novo.',
      mtWarning, [mbOK], 0);
    edtCodigoPareamento.Text := '';
    ActiveControl := edtCodigoPareamento;
  finally
    Screen.Cursor := crDefault;
    btnConfirmarPareamento.Enabled := True;
  end;
end;

end.
