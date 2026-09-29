program ERP_Financeiro;

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
  DelphiZXingQRCode in '..\Comum\DelphiZXingQRCode.pas',
  uQrCode in '..\Comum\uQrCode.pas',
  uLogin in '..\Comum\uLogin.pas' ,
  uTrocaSenha in '..\Comum\uTrocaSenha.pas' ,
  uSetup in 'uSetup.pas',
  uUsuarioDAO in 'uUsuarioDAO.pas',
  uCadUsuario in 'uCadUsuario.pas' ,
  uUsuarios in 'uUsuarios.pas' ,
  uFinanceiroDAO in 'uFinanceiroDAO.pas',
  uDashboardDAO in 'uDashboardDAO.pas',
  uQuitacaoBaixa in 'uQuitacaoBaixa.pas' ,
  uQuitacao in 'uQuitacao.pas' ,
  uConsultaFinanceira in 'uConsultaFinanceira.pas' ,
  uRelFinanceiro in 'uRelFinanceiro.pas',
  uDashboard in 'uDashboard.pas' ,
  uPrincipal in 'uPrincipal.pas' ;

{$R *.res}

procedure Iniciar;
var
  oConfig: TConfig;
  oConexao: TFDConnection;
  oAutenticacao: TAutenticacaoService;
  iUsuarioId: Int64;
begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'CartSys - Financeiro';

  oConfig := TConfig.Create;
  try
    oConexao := CriarConexao(oConfig);
    try
      oAutenticacao := TAutenticacaoService.Create(oConexao, oConfig.ChaveMestraTotp,
        oConfig.EmissorTotp);
      try
        if TFormLogin.Executar(oAutenticacao, MODULO_FINANCEIRO, iUsuarioId) then
        begin
          Application.CreateForm(TFormPrincipal, FormPrincipal);
          FormPrincipal.Conexao := oConexao;
          FormPrincipal.UsuarioId := iUsuarioId;
          FormPrincipal.Autenticacao := oAutenticacao;
          FormPrincipal.ChaveMestraTotp := oConfig.ChaveMestraTotp;
          FormPrincipal.EmissorTotp := oConfig.EmissorTotp;
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
    if SameText(ParamStr(1), '/setup') then
      ExecutarSetup
    else
      Iniciar;
  except
    on E: Exception do
      MessageDlg('N'#$00E3'o foi poss'#$00ED'vel iniciar o CartSys Financeiro.'#13#10 + E.Message,
        mtError, [mbOK], 0);
  end;
end.

