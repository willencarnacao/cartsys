unit uDashboardDAO;

interface

uses
  System.SysUtils, FireDAC.Comp.Client, FireDAC.Stan.Param, uTipos;

type
  TIndicadoresDashboard = record
    QtdPendente, QtdQuitada, QtdCancelada: Integer;
    ValorProjetado: Currency;
    ValorRealizado: Currency;
    TicketMedio: Currency;
  end;

  TDashboardDAO = class
  private
    FoConexao: TFDConnection;
  public
    constructor Create(poConexao: TFDConnection);

    function Indicadores: TIndicadoresDashboard;

    function TopProdutos: TFDQuery;

    function TopClientes: TFDQuery;

    function VendasPorMes: TFDQuery;

    function VendasPorForma: TFDQuery;
  end;

implementation

uses
  Data.DB;

constructor TDashboardDAO.Create(poConexao: TFDConnection);
begin
  inherited Create;
  FoConexao := poConexao;
end;

function TDashboardDAO.Indicadores: TIndicadoresDashboard;
var
  oQry: TFDQuery;
begin
  FillChar(Result, SizeOf(Result), 0);

  oQry := TFDQuery.Create(nil);
  try
    oQry.Connection := FoConexao;
    oQry.SQL.Text := 'SELECT STATUS, QTD, VALOR FROM V_DASH_STATUS';
    oQry.Open;
    while not oQry.Eof do
    begin
      case oQry.FieldByName('STATUS').AsInteger of
        Ord(vsPendente):
          begin
            Result.QtdPendente := oQry.FieldByName('QTD').AsInteger;
            Result.ValorProjetado := oQry.FieldByName('VALOR').AsCurrency;
          end;
        Ord(vsQuitada):
          begin
            Result.QtdQuitada := oQry.FieldByName('QTD').AsInteger;
            Result.ValorRealizado := oQry.FieldByName('VALOR').AsCurrency;
          end;
      end;
      oQry.Next;
    end;

    oQry.Close;
    oQry.SQL.Text :=
      'SELECT COUNT(*) AS QTD, COALESCE(AVG(VL_TOTAL), 0) AS TICKET ' +
      '  FROM VENDA WHERE STATUS = :pStatus';
    oQry.ParamByName('pStatus').AsInteger := Ord(vsQuitada);
    oQry.Open;
    Result.TicketMedio := oQry.FieldByName('TICKET').AsCurrency;

    oQry.Close;
    oQry.SQL.Text := 'SELECT COUNT(*) AS QTD FROM VENDA WHERE STATUS = :pStatus';
    oQry.ParamByName('pStatus').AsInteger := Ord(vsCancelada);
    oQry.Open;
    Result.QtdCancelada := oQry.FieldByName('QTD').AsInteger;
  finally
    oQry.Free;
  end;
end;

function TDashboardDAO.TopProdutos: TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := FoConexao;
  Result.SQL.Text :=
    'SELECT FIRST 5 DESCRICAO, QTD_VENDIDA, VALOR ' +
    '  FROM V_RANKING_PRODUTO ' +
    ' ORDER BY VALOR DESC';
  Result.Open;
end;

function TDashboardDAO.TopClientes: TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := FoConexao;
  Result.SQL.Text :=
    'SELECT FIRST 5 NOME, QTD_VENDAS, VALOR ' +
    '  FROM V_RANKING_CLIENTE ' +
    ' ORDER BY VALOR DESC';
  Result.Open;
end;

function TDashboardDAO.VendasPorMes: TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := FoConexao;
  Result.SQL.Text :=
    'SELECT ANO, MES, ' +
    '       SUM(CASE WHEN STATUS = 2 THEN VALOR ELSE 0 END) AS PROJETADO, ' +
    '       SUM(CASE WHEN STATUS = 3 THEN VALOR ELSE 0 END) AS REALIZADO ' +
    '  FROM V_VENDAS_MES ' +
    ' GROUP BY ANO, MES ' +
    ' ORDER BY ANO, MES';
  Result.Open;
end;

function TDashboardDAO.VendasPorForma: TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := FoConexao;
  Result.SQL.Text :=
    'SELECT CASE R.FORMA_PAGAMENTO ' +
    '         WHEN 1 THEN ''Dinheiro'' WHEN 2 THEN ''PIX'' ' +
    '         WHEN 3 THEN ''' + TXT_CARTAO + ''' WHEN 4 THEN ''Boleto'' END AS FORMA, ' +
    '       COUNT(*) AS QTD, SUM(R.VL_RECEBIDO) AS VALOR ' +
    '  FROM RECEBIMENTO R ' +
    ' GROUP BY R.FORMA_PAGAMENTO ' +
    ' ORDER BY VALOR DESC';
  Result.Open;
end;

end.

