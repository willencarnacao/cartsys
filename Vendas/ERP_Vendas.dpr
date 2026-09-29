program ERP_Vendas;

uses
  Vcl.Forms,
  Vcl.Dialogs,
  System.UITypes,
  System.SysUtils,
  FireDAC.Comp.Client,
  uConfig in '..\Comum\uConfig.pas',
  uConexao in '..\Comum\uConexao.pas',
  uAutenticacao in '..\Comum\uAutenticacao.pas',
  uSenha in '..\Comum\uSenha.pas',
  uTotp in '..\Comum\uTotp.pas',
  uCripto in '..\Comum\uCripto.pas',
  uHashUtils in '..\Comum\uHashUtils.pas',
  uTipos in '..\Comum\uTipos.pas',
  uDocumento in '..\Comum\uDocumento.pas',
  uDados in '..\Comum\uDados.pas',
  uGrade in '..\Comum\uGrade.pas',
  uConsulta in '..\Comum\uConsulta.pas' {FormConsulta},
  DelphiZXingQRCode in '..\Comum\DelphiZXingQRCode.pas',
  uQrCode in '..\Comum\uQrCode.pas',
  uLogin in '..\Comum\uLogin.pas',
  uTrocaSenha in '..\Comum\uTrocaSenha.pas',
  uClienteDAO in 'uClienteDAO.pas',
  uProdutoDAO in 'uProdutoDAO.pas',
  uVendaDAO in 'uVendaDAO.pas',
  uClientes in 'uClientes.pas',
  uCadCliente in 'uCadCliente.pas',
  uProdutos in 'uProdutos.pas',
  uCadProduto in 'uCadProduto.pas',
  uConsultaCliente in 'uConsultaCliente.pas',
  uConsultaProduto in 'uConsultaProduto.pas',
  uRelPedido in 'uRelPedido.pas',
  uEnvioEmail in 'uEnvioEmail.pas',
  uSmtpConfig in 'uSmtpConfig.pas',
  uConfigEmail in 'uConfigEmail.pas' {FormConfigEmail},
  uVendas in 'uVendas.pas',
  uCadVenda in 'uCadVenda.pas',
  uPrincipal in 'uPrincipal.pas';

{$R *.res}

procedure Iniciar;
var
  oConfig: TConfig;
  oConexao: TFDConnection;
  oAutenticacao: TAutenticacaoService;
  oSmtp: TSmtpDAO;
  iUsuarioId: Int64;
begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'CartSys - Vendas';

  oConfig := TConfig.Create;
  try
    oConexao := CriarConexao(oConfig);
    try
      oAutenticacao := TAutenticacaoService.Create(oConexao, oConfig.ChaveMestraTotp,
        oConfig.EmissorTotp);
      try
        if TFormLogin.Executar(oAutenticacao, MODULO_VENDAS, iUsuarioId) then
        begin
          Application.CreateForm(TFormPrincipal, FormPrincipal);
          FormPrincipal.Conexao := oConexao;
          FormPrincipal.UsuarioId := iUsuarioId;
          FormPrincipal.ChaveMestra := oConfig.ChaveMestraTotp;
          FormPrincipal.ArquivoIni := oConfig.Arquivo;
          oSmtp := TSmtpDAO.Create(oConexao, FormPrincipal.ChaveMestra,
            FormPrincipal.ArquivoIni);
          try
            FormPrincipal.Smtp := oSmtp.Carregar(oConfig.Smtp);
          finally
            oSmtp.Free;
          end;
          FormPrincipal.PrepararAposLogin;
          Application.Run;
        end;
      finally
        oAutenticacao.Free;
      end;
    finally
      oConexao.Free;
    end;
  finally
    oConfig.Free;
  end;
end;

begin
  try
    Iniciar;
  except
    on E: Exception do
      MessageDlg('N'#$00E3'o foi poss'#$00ED'vel iniciar o CartSys Vendas.'#13#10 + E.Message,
        mtError, [mbOK], 0);
  end;
end.
