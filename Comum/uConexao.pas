unit uConexao;

interface

uses
  System.SysUtils, FireDAC.Comp.Client, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.DApt, FireDAC.UI.Intf, FireDAC.Stan.Factory, FireDAC.Comp.UI,
  FireDAC.VCLUI.Wait, FireDAC.Phys.Intf, FireDAC.Phys.IBBase, FireDAC.Phys.FB,
  FireDAC.Phys.FBDef, uConfig;

function CriarConexao(const poConfig: TConfig): TFDConnection;

function TestarConexao(const poConfig: TConfig; out psErro: string): Boolean;

implementation

function MontarConexao(const poConfig: TConfig): TFDConnection;
var
  rBanco: TConfigBanco;
begin
  rBanco := poConfig.Banco;

  Result := TFDConnection.Create(nil);
  try
    Result.LoginPrompt := False;
    Result.Params.DriverID := 'FB';
    Result.Params.Database := rBanco.Caminho;
    Result.Params.UserName := rBanco.Usuario;
    Result.Params.Password := rBanco.Senha;
    Result.Params.Add('CharacterSet=UTF8');

    case rBanco.Modo of
      mbServidor:
        begin
          Result.Params.Add('Server=' + rBanco.Servidor);
          Result.Params.Add('Protocol=TCPIP');
        end;
      mbEmbedded:
        begin
          Result.Params.Add('Protocol=Local');

          if FileExists(ExtractFilePath(ParamStr(0)) + 'fbembed.dll') then
            Result.Params.Add('VendorLib=' + ExtractFilePath(ParamStr(0)) + 'fbembed.dll');
        end;
    end;
  except
    Result.Free;
    raise;
  end;
end;

function CriarConexao(const poConfig: TConfig): TFDConnection;
begin
  Result := MontarConexao(poConfig);
  try
    Result.Connected := True;
  except
    on E: Exception do
    begin
      Result.Free;
      raise Exception.CreateFmt(
        'N'#$00E3'o foi poss'#$00ED'vel conectar ao banco CartSys.'#13#10 +
        'Confira o CartSys.ini (Servidor/Caminho/Usuario/Senha) e se o ' +
        'Firebird est'#$00E1' no ar.'#13#10'Detalhe: %s', [E.Message]);
    end;
  end;
end;

function TestarConexao(const poConfig: TConfig; out psErro: string): Boolean;
var
  oConexao: TFDConnection;
begin
  psErro := '';
  oConexao := MontarConexao(poConfig);
  try
    try
      oConexao.Connected := True;
      Result := True;
    except
      on E: Exception do
      begin
        psErro := E.Message;
        Result := False;
      end;
    end;
  finally
    oConexao.Free;
  end;
end;

var
  oWait: TFDGUIxWaitCursor;
  oDriverFB: TFDPhysFBDriverLink;

initialization
  oWait := TFDGUIxWaitCursor.Create(nil);
  oWait.Provider := 'Forms';
  oDriverFB := TFDPhysFBDriverLink.Create(nil);

finalization
  oDriverFB.Free;
  oWait.Free;

end.
