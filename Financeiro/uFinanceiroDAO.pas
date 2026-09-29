unit uFinanceiroDAO;

interface

uses
  System.SysUtils, FireDAC.Comp.Client, FireDAC.Stan.Param, uTipos;

type
  TFinanceiroDAO = class
  private
    FoConexao: TFDConnection;
  public
    constructor Create(poConexao: TFDConnection);

    function ListarPendentes: TFDQuery;

    function ListarPorPeriodo(pdtDataInicial, pdtDataFinal: TDateTime): TFDQuery;

    procedure TotaisPorPeriodo(pdtDataInicial, pdtDataFinal: TDateTime;
      out piQtdQuitada: Integer; out pnValorQuitado: Currency; out piQtdCancelada: Integer);

    procedure Quitar(piVendaId, piUsuarioId: Int64; pnValorRecebido: Currency;
      peFormaPagamento: TFormaPagamento; const psObservacao: string);

    procedure Cancelar(piVendaId, piUsuarioId: Int64; const psMotivo: string);
  end;

implementation

uses
  Data.DB, System.Variants, uDados;

constructor TFinanceiroDAO.Create(poConexao: TFDConnection);
begin
  inherited Create;
  FoConexao := poConexao;
end;

function TFinanceiroDAO.ListarPendentes: TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := FoConexao;
  Result.SQL.Text :=
    'SELECT V.ID, C.NOME AS CLIENTE, V.DT_EMISSAO, V.DT_VENCIMENTO, ' +
    '       V.VL_ITENS, V.VL_DESCONTO, V.VL_TOTAL ' +
    '  FROM VENDA V ' +
    '  JOIN CLIENTE C ON C.ID = V.CLIENTE_ID ' +
    ' WHERE V.STATUS = :pStatus ' +
    ' ORDER BY V.DT_EMISSAO';
  Result.ParamByName('pStatus').AsInteger := Ord(vsPendente);
  Result.Open;
end;

function TFinanceiroDAO.ListarPorPeriodo(pdtDataInicial, pdtDataFinal: TDateTime): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := FoConexao;
  Result.SQL.Text :=
    'SELECT V.ID, C.NOME AS CLIENTE, V.STATUS, ' +
    '       CASE V.STATUS WHEN 3 THEN ''Quitada'' WHEN 4 THEN ''Cancelada'' ELSE ''Outro'' END AS STATUS_DESC, ' +
    '       V.DT_EMISSAO, V.DT_CONFIRMACAO, V.DT_CANCELAMENTO, V.VL_TOTAL, ' +
    '       R.DT_RECEBIMENTO, R.FORMA_PAGAMENTO, ' +
    '       CASE R.FORMA_PAGAMENTO WHEN 1 THEN ''Dinheiro'' WHEN 2 THEN ''PIX'' ' +
    '            WHEN 3 THEN ''' + TXT_CARTAO + ''' WHEN 4 THEN ''Boleto'' ELSE '''' END AS FORMA_DESC, ' +
    '       R.VL_RECEBIDO ' +
    '  FROM VENDA V ' +
    '  JOIN CLIENTE C ON C.ID = V.CLIENTE_ID ' +
    '  LEFT JOIN RECEBIMENTO R ON R.VENDA_ID = V.ID ' +
    ' WHERE V.STATUS IN (:pQuitada, :pCancelada) ' +
    '   AND V.DT_EMISSAO >= :pInicio AND V.DT_EMISSAO < :pFim ' +
    ' ORDER BY V.DT_EMISSAO';
  Result.ParamByName('pQuitada').AsInteger := Ord(vsQuitada);
  Result.ParamByName('pCancelada').AsInteger := Ord(vsCancelada);
  Result.ParamByName('pInicio').AsDate := pdtDataInicial;
  Result.ParamByName('pFim').AsDate := pdtDataFinal + 1;
  Result.Open;
end;

procedure TFinanceiroDAO.TotaisPorPeriodo(pdtDataInicial, pdtDataFinal: TDateTime;
  out piQtdQuitada: Integer; out pnValorQuitado: Currency; out piQtdCancelada: Integer);
var
  oQry: TFDQuery;
begin
  oQry := TFDQuery.Create(nil);
  try
    oQry.Connection := FoConexao;
    oQry.SQL.Text :=
      'SELECT ' +
      '  SUM(CASE WHEN STATUS = :pQuitada THEN 1 ELSE 0 END) AS QTD_QUITADA, ' +
      '  SUM(CASE WHEN STATUS = :pQuitada THEN VL_TOTAL ELSE 0 END) AS VALOR_QUITADO, ' +
      '  SUM(CASE WHEN STATUS = :pCancelada THEN 1 ELSE 0 END) AS QTD_CANCELADA ' +
      '  FROM VENDA ' +
      ' WHERE STATUS IN (:pQuitada, :pCancelada) ' +
      '   AND DT_EMISSAO >= :pInicio AND DT_EMISSAO < :pFim';
    oQry.ParamByName('pQuitada').AsInteger := Ord(vsQuitada);
    oQry.ParamByName('pCancelada').AsInteger := Ord(vsCancelada);
    oQry.ParamByName('pInicio').AsDate := pdtDataInicial;
    oQry.ParamByName('pFim').AsDate := pdtDataFinal + 1;
    oQry.Open;

    piQtdQuitada := oQry.FieldByName('QTD_QUITADA').AsInteger;
    pnValorQuitado := oQry.FieldByName('VALOR_QUITADO').AsCurrency;
    piQtdCancelada := oQry.FieldByName('QTD_CANCELADA').AsInteger;
  finally
    oQry.Free;
  end;
end;

procedure TFinanceiroDAO.Quitar(piVendaId, piUsuarioId: Int64; pnValorRecebido: Currency;
  peFormaPagamento: TFormaPagamento; const psObservacao: string);
var
  oQry: TFDQuery;
begin
  if pnValorRecebido <= 0 then
    raise EArgumentException.Create('Valor recebido precisa ser maior que zero.');

  FoConexao.StartTransaction;
  try
    oQry := TFDQuery.Create(nil);
    try
      oQry.Connection := FoConexao;

      oQry.SQL.Text :=
        'INSERT INTO RECEBIMENTO (VENDA_ID, VL_RECEBIDO, FORMA_PAGAMENTO, USUARIO_ID, OBSERVACAO) ' +
        'VALUES (:pVenda, :pValor, :pForma, :pUsuario, :pObs)';
      oQry.ParamByName('pVenda').AsLargeInt := piVendaId;
      oQry.ParamByName('pValor').AsCurrency := pnValorRecebido;
      oQry.ParamByName('pForma').AsInteger := Ord(peFormaPagamento);
      oQry.ParamByName('pUsuario').AsLargeInt := piUsuarioId;
      oQry.ParamByName('pObs').Value := TextoOuNulo(psObservacao);
      oQry.ExecSQL;

      oQry.SQL.Text :=
        'UPDATE VENDA SET STATUS = :pNovoStatus ' +
        ' WHERE ID = :pId AND STATUS = :pStatusEsperado';
      oQry.ParamByName('pNovoStatus').AsInteger := Ord(vsQuitada);
      oQry.ParamByName('pId').AsLargeInt := piVendaId;
      oQry.ParamByName('pStatusEsperado').AsInteger := Ord(vsPendente);
      oQry.ExecSQL;

      if oQry.RowsAffected = 0 then
        raise Exception.Create(
          'Esta venda n'#$00E3'o est'#$00E1' mais pendente - outra esta'#$00E7#$00E3'o j'#$00E1' quitou ou ' +
          'cancelou. Atualize a lista e confira.');
    finally
      oQry.Free;
    end;

    FoConexao.Commit;
  except
    FoConexao.Rollback;
    raise;
  end;
end;

procedure TFinanceiroDAO.Cancelar(piVendaId, piUsuarioId: Int64; const psMotivo: string);
var
  oQry: TFDQuery;
begin
  if Trim(psMotivo) = '' then
    raise EArgumentException.Create('Informe o motivo do cancelamento.');

  oQry := TFDQuery.Create(nil);
  try
    oQry.Connection := FoConexao;
    oQry.SQL.Text :=
      'UPDATE VENDA SET STATUS = :pNovoStatus, MOTIVO_CANCELAMENTO = :pMotivo, ' +
      '  USUARIO_CANCEL_ID = :pUsuario ' +
      ' WHERE ID = :pId AND STATUS = :pStatusEsperado';
    oQry.ParamByName('pNovoStatus').AsInteger := Ord(vsCancelada);
    oQry.ParamByName('pMotivo').AsString := Trim(psMotivo);
    oQry.ParamByName('pUsuario').AsLargeInt := piUsuarioId;
    oQry.ParamByName('pId').AsLargeInt := piVendaId;
    oQry.ParamByName('pStatusEsperado').AsInteger := Ord(vsPendente);
    oQry.ExecSQL;

    if oQry.RowsAffected = 0 then
      raise Exception.Create(
        'Esta venda n'#$00E3'o est'#$00E1' mais pendente - outra esta'#$00E7#$00E3'o j'#$00E1' quitou ou ' +
        'cancelou. Atualize a lista e confira.');
  finally
    oQry.Free;
  end;
end;

end.

