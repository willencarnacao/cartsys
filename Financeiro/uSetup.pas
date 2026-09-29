unit uSetup;

interface

procedure ExecutarSetup;

implementation

uses
  System.SysUtils, Winapi.Windows, FireDAC.Comp.Client, FireDAC.Stan.Param,
  uConfig, uConexao, uSenha, uTotp, uCripto, uTipos;

function LerEntrada(const psPergunta: string; pbObrigatorio: Boolean = True): string;
begin
  repeat
    Write(psPergunta);
    Readln(Result);
    Result := Trim(Result);
    if (Result = '') and pbObrigatorio then
      Writeln('  -> obrigat'#$00F3'rio, digite novamente.');
  until (Result <> '') or not pbObrigatorio;
end;

function GerarSenhaTemporaria: string;
const

  ALFABETO = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789';
var
  oBytes: TBytes;
  iPos: Integer;
begin
  oBytes := GerarBytesAleatorios(14);
  Result := '';
  for iPos := 0 to High(oBytes) do
    Result := Result + ALFABETO[(oBytes[iPos] mod Length(ALFABETO)) + 1];
end;

procedure ExecutarSetup;
var
  oConfig: TConfig;
  oConexao: TFDConnection;
  oQry: TFDQuery;
  iTotalUsuarios: Integer;
  sLogin, sNome, sEmail, sSenhaTemporaria, sSegredoBase32, sSegredoCifrado: string;
  rSenha: TSenhaGerada;
  sUri: string;
begin
  AllocConsole;
  AssignFile(Output, 'CONOUT$');
  Rewrite(Output);
  AssignFile(Input, 'CONIN$');
  Reset(Input);

  Writeln('=== CartSys - Configura'#$00E7#$00E3'o inicial (Financeiro) ===');
  Writeln;

  try
    oConfig := TConfig.Create;
    try
      oConexao := CriarConexao(oConfig);
      try
        oQry := TFDQuery.Create(nil);
        try
          oQry.Connection := oConexao;
          oQry.SQL.Text := 'SELECT COUNT(*) AS QTD FROM USUARIO';
          oQry.Open;
          iTotalUsuarios := oQry.FieldByName('QTD').AsInteger;

          if iTotalUsuarios > 0 then
          begin
            Writeln('J'#$00E1' existem usu'#$00E1'rios cadastrados (', iTotalUsuarios, '). ');
            Writeln('Este assistente s'#$00F3' roda numa base vazia. Use a tela de ');
            Writeln('Usu'#$00E1'rios, j'#$00E1' logado como administrador, para cadastrar mais gente.');
            Writeln;
            Writeln('Pressione ENTER para sair...');
            Readln;
            Exit;
          end;

          Writeln('Nenhum usu'#$00E1'rio cadastrado. Vamos criar o administrador inicial.');
          Writeln;

          sLogin := LerEntrada('Login do administrador: ');
          sNome  := LerEntrada('Nome completo: ');
          sEmail := LerEntrada('E-mail (opcional): ', False);

          sSenhaTemporaria := GerarSenhaTemporaria;
          rSenha := GerarHashSenha(sSenhaTemporaria);

          sSegredoBase32 := GerarSegredoBase32;
          sSegredoCifrado := CifrarSegredo(TEncoding.ASCII.GetBytes(sSegredoBase32),
            oConfig.ChaveMestraTotp);
          sUri := MontarUriProvisionamento(oConfig.EmissorTotp, sLogin, sSegredoBase32);

          oQry.SQL.Text :=
            'INSERT INTO USUARIO (LOGIN, NOME, EMAIL, SENHA_HASH, SENHA_SALT, ' +
            '  SENHA_ITERACOES, SENHA_TEMPORARIA, TOTP_SEGREDO_CIFRADO, TOTP_CONFIRMADO, ' +
            '  IS_ADMIN, ACESSA_VENDAS, ACESSA_FINANCEIRO, ATIVO) ' +
            'VALUES (:pLogin, :pNome, :pEmail, :pHash, :pSalt, :pIter, 1, :pTotp, 0, ' +
            '  1, 1, 1, 1)';
          oQry.ParamByName('pLogin').AsString := sLogin;
          oQry.ParamByName('pNome').AsString := sNome;
          if sEmail = '' then
            oQry.ParamByName('pEmail').Clear
          else
            oQry.ParamByName('pEmail').AsString := sEmail;
          oQry.ParamByName('pHash').AsString := rSenha.HashBase64;
          oQry.ParamByName('pSalt').AsString := rSenha.SaltBase64;
          oQry.ParamByName('pIter').AsInteger := rSenha.Iteracoes;
          oQry.ParamByName('pTotp').AsString := sSegredoCifrado;
          oQry.ExecSQL;

          Writeln;
          Writeln('=== Administrador criado com sucesso ===');
          Writeln('Login:           ', sLogin);
          Writeln('Senha tempor'#$00E1'ria:', ' ', sSenhaTemporaria);
          Writeln;
          Writeln('No primeiro login, o sistema vai pedir para configurar o app');
          Writeln('autenticador. Se preferir configurar agora, use esta chave:');
          Writeln('  ', sSegredoBase32);
          Writeln('(ou a URI completa, se o seu app aceitar colar um link:)');
          Writeln('  ', sUri);
          Writeln;
          Writeln('Anote a senha tempor'#$00E1'ria agora - ela n'#$00E3'o ser'#$00E1' mostrada de novo.');
          Writeln('Pressione ENTER para concluir...');
          Readln;
        finally
          oQry.Free;
        end;
      finally
        oConexao.Free;
      end;
    finally
      oConfig.Free;
    end;
  except
    on E: Exception do
    begin
      Writeln('ERRO: ', E.Message);
      Writeln('Pressione ENTER para sair...');
      Readln;
    end;
  end;

  CloseFile(Output);
  CloseFile(Input);
  FreeConsole;
end;

end.

