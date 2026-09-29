unit uEnvioEmail;

interface

uses
  System.SysUtils, System.Classes, Vcl.ExtCtrls, FireDAC.Comp.Client,
  FireDAC.Stan.Intf, FireDAC.Stan.Param, uConfig;

type
  TServicoEmail = class
  private
    FoConexao: TFDConnection;
    FrSmtp: TConfigSmtp;
    FoAlerter: TFDEventAlerter;
    FoTimer: TTimer;
    FbProcessando: Boolean;
    FbAvisouSmtp: Boolean;
    function SmtpConfigurado: Boolean;
    procedure AoAlerta(poSender: TFDCustomEventAlerter; const psEventName: string;
      const pvArgument: Variant);
    procedure AoTimer(Sender: TObject);
    procedure ProcessarPendentes;
    procedure EnviarVenda(piOutboxId, piVendaId: Int64);
    procedure MarcarEnvio(piOutboxId: Int64; pbOk: Boolean; const psErro: string);
  public
    constructor Create(poConexao: TFDConnection; const prSmtp: TConfigSmtp);
    destructor Destroy; override;
    procedure Iniciar;
    procedure AtualizarSmtp(const prSmtp: TConfigSmtp);
  end;

procedure EnviarEmailTeste(const prSmtp: TConfigSmtp; const psDestino: string);

implementation

uses
  Data.DB, Vcl.Dialogs, IdSMTP, IdMessage, IdSSLOpenSSL, IdSSLOpenSSLHeaders,
  IdAttachmentFile,
  IdExplicitTLSClientServerBase, FireDAC.Phys.IBWrapper, uVendaDAO, uRelPedido;

const
  MAX_TENTATIVAS_EMAIL = 5;

function SmtpPronto(const prSmtp: TConfigSmtp): Boolean;
begin
  Result := (Trim(prSmtp.Servidor) <> '') and (prSmtp.Porta > 0) and
    (Trim(prSmtp.Usuario) <> '') and (Trim(prSmtp.Senha) <> '') and
    (Trim(prSmtp.Remetente) <> '');
end;

procedure PreencherRemetente(poMsg: TIdMessage; const prSmtp: TConfigSmtp);
begin
  poMsg.CharSet := 'utf-8';
  poMsg.From.Address := prSmtp.Remetente;
  if Trim(prSmtp.Nome) <> '' then
    poMsg.From.Name := prSmtp.Nome
  else
    poMsg.From.Name := 'CartSys';
end;

procedure EntregarMensagem(const prSmtp: TConfigSmtp; poMsg: TIdMessage);
var
  oSmtpCli: TIdSMTP;
  oSsl: TIdSSLIOHandlerSocketOpenSSL;
begin
  if prSmtp.UsarTLS then
  begin
    IdOpenSSLSetLibPath(ExtractFilePath(ParamStr(0)));
    if not LoadOpenSSLLibrary then
      raise Exception.Create(
        'OpenSSL n'#$00E3'o encontrado. Copie libeay32.dll e ssleay32.dll ' +
        'para a pasta do ERP_Vendas.exe.');
  end;

  oSsl := nil;
  oSmtpCli := TIdSMTP.Create(nil);
  try
    if prSmtp.UsarTLS then
    begin
      oSsl := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
      oSsl.SSLOptions.Method := sslvTLSv1_2;
      oSsl.SSLOptions.Mode := sslmClient;
      oSmtpCli.IOHandler := oSsl;
      oSmtpCli.UseTLS := utUseExplicitTLS;
    end
    else
      oSmtpCli.UseTLS := utNoTLSSupport;

    oSmtpCli.Host := prSmtp.Servidor;
    oSmtpCli.Port := prSmtp.Porta;
    oSmtpCli.Username := prSmtp.Usuario;
    oSmtpCli.Password := prSmtp.Senha;
    oSmtpCli.Connect;
    try
      oSmtpCli.Send(poMsg);
    finally
      if oSmtpCli.Connected then
        oSmtpCli.Disconnect;
    end;
  finally
    oSmtpCli.Free;
    oSsl.Free;
  end;
end;

procedure EnviarEmailTeste(const prSmtp: TConfigSmtp; const psDestino: string);
var
  oMsg: TIdMessage;
begin
  if not SmtpPronto(prSmtp) then
    raise Exception.Create('Preencha servidor, porta, usu'#$00E1'rio, senha e e-mail do remetente.');
  if Trim(psDestino) = '' then
    raise Exception.Create('Informe o e-mail que vai receber o teste.');

  oMsg := TIdMessage.Create(nil);
  try
    PreencherRemetente(oMsg, prSmtp);
    oMsg.Recipients.EMailAddresses := Trim(psDestino);
    oMsg.Subject := 'CartSys - teste de e-mail';
    oMsg.Body.Text :=
      'Este e-mail confirma que o SMTP do CartSys est'#$00E1' correto.'#13#10#13#10 +
      'CartSys';
    EntregarMensagem(prSmtp, oMsg);
  finally
    oMsg.Free;
  end;
end;

constructor TServicoEmail.Create(poConexao: TFDConnection; const prSmtp: TConfigSmtp);
begin
  inherited Create;
  FoConexao := poConexao;
  FrSmtp := prSmtp;
  FoTimer := TTimer.Create(nil);
  FoTimer.Enabled := False;
  FoTimer.Interval := 60000;
  FoTimer.OnTimer := AoTimer;
end;

destructor TServicoEmail.Destroy;
begin
  if Assigned(FoAlerter) then
  begin
    FoAlerter.Active := False;
    FoAlerter.Free;
  end;
  FoTimer.Free;
  inherited;
end;

procedure TServicoEmail.Iniciar;
begin
  FoAlerter := TFDEventAlerter.Create(nil);
  FoAlerter.Connection := FoConexao;
  FoAlerter.Names.Add('VENDA_QUITADA');
  FoAlerter.Options.Kind := 'Events';
  FoAlerter.OnAlert := AoAlerta;
  try
    FoAlerter.Active := True;
  except
    FoAlerter.Free;
    FoAlerter := nil;
  end;
  FoTimer.Enabled := True;
  ProcessarPendentes;
end;

procedure TServicoEmail.AoAlerta(poSender: TFDCustomEventAlerter;
  const psEventName: string; const pvArgument: Variant);
begin
  TThread.Queue(nil, ProcessarPendentes);
end;

procedure TServicoEmail.AoTimer(Sender: TObject);
begin
  ProcessarPendentes;
end;

function TServicoEmail.SmtpConfigurado: Boolean;
begin
  Result := SmtpPronto(FrSmtp);
end;

procedure TServicoEmail.AtualizarSmtp(const prSmtp: TConfigSmtp);
begin
  FrSmtp := prSmtp;
  FbAvisouSmtp := False;
  ProcessarPendentes;
end;

procedure TServicoEmail.MarcarEnvio(piOutboxId: Int64; pbOk: Boolean; const psErro: string);
var
  oQry: TFDQuery;
begin
  oQry := TFDQuery.Create(nil);
  try
    oQry.Connection := FoConexao;
    if pbOk then
    begin
      oQry.SQL.Text :=
        'UPDATE EMAIL_OUTBOX SET STATUS = 2, DT_ENVIO = CURRENT_TIMESTAMP, ' +
        '  ULTIMO_ERRO = NULL WHERE ID = :pId';
      oQry.ParamByName('pId').AsLargeInt := piOutboxId;
      oQry.ExecSQL;
    end
    else
    begin
      oQry.SQL.Text :=
        'UPDATE EMAIL_OUTBOX SET TENTATIVAS = TENTATIVAS + 1, ULTIMO_ERRO = :pErro, ' +
        '  STATUS = CASE WHEN TENTATIVAS + 1 >= :pMax THEN 3 ELSE STATUS END ' +
        'WHERE ID = :pId';
      oQry.ParamByName('pErro').AsString := Copy(psErro, 1, 500);
      oQry.ParamByName('pMax').AsInteger := MAX_TENTATIVAS_EMAIL;
      oQry.ParamByName('pId').AsLargeInt := piOutboxId;
      oQry.ExecSQL;
    end;
  finally
    oQry.Free;
  end;
end;

procedure TServicoEmail.EnviarVenda(piOutboxId, piVendaId: Int64);
var
  oDAO: TVendaDAO;
  oCab, oItens: TFDQuery;
  sPdf: string;
  oMsg: TIdMessage;
  sEmail: string;
  oQryFail: TFDQuery;
begin
  sPdf := '';
  if not SmtpConfigurado then
    Exit;

  oDAO := TVendaDAO.Create(FoConexao);
  try
    oCab := oDAO.CarregarCabecalho(piVendaId);
    oItens := oDAO.CarregarItens(piVendaId);
    try
      sEmail := Trim(oCab.FieldByName('EMAIL').AsString);
      if sEmail = '' then
      begin
        oQryFail := TFDQuery.Create(nil);
        try
          oQryFail.Connection := FoConexao;
          oQryFail.SQL.Text :=
            'UPDATE EMAIL_OUTBOX SET STATUS = 3, TENTATIVAS = TENTATIVAS + 1, ' +
            '  ULTIMO_ERRO = :pErro WHERE ID = :pId';
          oQryFail.ParamByName('pErro').AsString := 'Cliente sem e-mail cadastrado.';
          oQryFail.ParamByName('pId').AsLargeInt := piOutboxId;
          oQryFail.ExecSQL;
        finally
          oQryFail.Free;
        end;
        Exit;
      end;

      sPdf := IncludeTrailingPathDelimiter(GetEnvironmentVariable('TEMP')) +
        Format('CartSys_Pedido_%d.pdf', [piVendaId]);
      ExportarPedidoPdf(oCab, oItens, sPdf);

      oMsg := TIdMessage.Create(nil);
      try
        PreencherRemetente(oMsg, FrSmtp);
        oMsg.Recipients.EMailAddresses := sEmail;
        oMsg.Subject := Format('Pedido %d quitado - CartSys', [piVendaId]);
        oMsg.Body.Text :=
          'Ol'#$00E1', ' + oCab.FieldByName('CLIENTE').AsString + '.'#13#10#13#10 +
          'Sua venda n'#$00BA' ' + piVendaId.ToString + ' foi quitada.'#13#10 +
          'Segue o pedido em anexo.'#13#10#13#10 +
          'CartSys';
        TIdAttachmentFile.Create(oMsg.MessageParts, sPdf);
        EntregarMensagem(FrSmtp, oMsg);
      finally
        oMsg.Free;
      end;

      MarcarEnvio(piOutboxId, True, '');
    finally
      oItens.Free;
      oCab.Free;
      if (sPdf <> '') and FileExists(sPdf) then
        DeleteFile(sPdf);
    end;
  finally
    oDAO.Free;
  end;
end;

procedure TServicoEmail.ProcessarPendentes;
var
  oQry: TFDQuery;
begin
  if FbProcessando then
    Exit;
  if not SmtpConfigurado then
  begin
    if not FbAvisouSmtp then
    begin
      FbAvisouSmtp := True;
      oQry := TFDQuery.Create(nil);
      try
        oQry.Connection := FoConexao;
        oQry.SQL.Text := 'SELECT COUNT(*) AS QT FROM EMAIL_OUTBOX WHERE STATUS = 1';
        oQry.Open;
        if oQry.FieldByName('QT').AsInteger > 0 then
          MessageDlg('O e-mail da quita'#$00E7#$00E3'o n'#$00E3'o foi enviado. Abra E-mail (SMTP), ' +
            'informe usu'#$00E1'rio, senha e e-mail do remetente e salve. No Gmail use uma senha de app.',
            mtWarning, [mbOK], 0);
      finally
        oQry.Free;
      end;
    end;
    Exit;
  end;
  FbProcessando := True;
  try
    oQry := TFDQuery.Create(nil);
    try
      oQry.Connection := FoConexao;
      oQry.SQL.Text :=
        'SELECT ID, VENDA_ID FROM EMAIL_OUTBOX ' +
        ' WHERE STATUS = 1 AND TENTATIVAS < :pMax ' +
        ' ORDER BY ID';
      oQry.ParamByName('pMax').AsInteger := MAX_TENTATIVAS_EMAIL;
      oQry.Open;
      while not oQry.Eof do
      begin
        try
          EnviarVenda(oQry.FieldByName('ID').AsLargeInt,
            oQry.FieldByName('VENDA_ID').AsLargeInt);
        except
          on E: Exception do
            MarcarEnvio(oQry.FieldByName('ID').AsLargeInt, False, E.Message);
        end;
        oQry.Next;
      end;
    finally
      oQry.Free;
    end;
  finally
    FbProcessando := False;
  end;
end;

end.
